package flows

import (
	"context"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
)

type RouterRequest struct {
	Query string `json:"query"`
}

type Intent struct {
	Intent string `json:"intent" jsonschema_enum:"question,creative"`
}

func DefineRouterFlow(g *genkit.Genkit) *core.Flow[*RouterRequest, string, struct{}] {
	return genkit.DefineFlow(g, "routerFlow",
		func(ctx context.Context, req *RouterRequest) (string, error) {
			// Step 1: Classify the user's intent
			intent, _, err := genkit.GenerateData[Intent](ctx, g,
				ai.WithPrompt("Classify the user's query as either a 'question' or a 'creative' request. Query: %v", req.Query),
			)
			if err != nil {
				return "", err
			}

			// Step 2: Route based on the intent
			switch intent.Intent {
			case "question":
				// Handle as a straightforward question
				answerResponse, err := genkit.Generate(ctx, g,
					ai.WithPrompt("Answer the following question: %v", req.Query),
				)
				if err != nil {
					return "", err
				}
				return answerResponse.Text(), nil
			case "creative":
				// Handle as a creative writing prompt
				creativeResponse, err := genkit.Generate(ctx, g,
					ai.WithPrompt("Write a short poem about: %v", req.Query),
				)
				if err != nil {
					return "", err
				}
				return creativeResponse.Text(), nil
			default:
				return "Sorry, I couldn't determine how to handle your request.", nil
			}
		},
	)
}
