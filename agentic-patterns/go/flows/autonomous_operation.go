package flows

import (
	"context"
	"fmt"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
)

type ResearchAgentRequest struct {
	Task string `json:"task"`
}

type SearchWebRequest struct {
	Query string `json:"query"`
}

type AskUserRequest struct {
	Question string `json:"question"`
}

func DefineResearchAgentFlow(g *genkit.Genkit) *core.Flow[*ResearchAgentRequest, string, struct{}] {
	searchWeb := genkit.DefineTool(g,
		"searchWeb",
		"Search the web for information on a given topic.",
		func(ctx *ai.ToolContext, req *SearchWebRequest) (string, error) {
			// In a real app, you would implement a web search API call here.
			return fmt.Sprintf("You found search results for: %s", req.Query), nil
		},
	)

	askUser := genkit.DefineTool(g,
		"askUser",
		"Ask the user a clarifying question.",
		func(ctx *ai.ToolContext, req *AskUserRequest) (string, error) {
			// This tool interrupts the flow to ask the user a question.
			return "", ctx.Interrupt(&ai.InterruptOptions{
				Metadata: map[string]any{
					"question": req.Question,
				},
			})
		},
	)

	return genkit.DefineFlow(g, "researchAgent",
		func(ctx context.Context, req *ResearchAgentRequest) (string, error) {
			response, err := genkit.Generate(ctx, g,
				ai.WithSystem("You are a helpful research assistant. Your goal is to provide a comprehensive answer to the user's task."),
				ai.WithPrompt("Your task is: %v. Use the available tools to accomplish this.", req.Task),
				ai.WithModelName("googleai/gemini-2.5-pro"),
				ai.WithTools(searchWeb, askUser),
				ai.WithMaxTurns(5), // Limit the number of back-and-forth turns
			)
			if err != nil {
				return "", err
			}

			for response.FinishReason == ai.FinishReasonInterrupted {
				var answers []*ai.Part
				for _, part := range response.Interrupts() {
					if part.ToolRequest.Name == "askUser" {
						// In a real app, you would present the question to the user and get their answer.
						question := part.ToolRequest.Input.(map[string]any)["question"]
						userAnswer := fmt.Sprintf("The user answered: \"Sample answer for '%s'\"", question)
						answers = append(answers, askUser.Respond(part, userAnswer, nil))
					}
				}

				response, err = genkit.Generate(ctx, g,
					ai.WithMessages(response.History()...),
					ai.WithTools(searchWeb, askUser),
					ai.WithToolResponses(answers...),
				)
				if err != nil {
					return "", err
				}
			}

			return response.Text(), nil
		},
	)
}
