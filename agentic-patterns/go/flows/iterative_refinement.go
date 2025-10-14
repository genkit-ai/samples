package flows

import (
	"context"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
)

type IterativeRefinementRequest struct {
	Topic string `json:"topic"`
}

type Evaluation struct {
	Critique  string `json:"critique"`
	Satisfied bool   `json:"satisfied"`
}

func DefineIterativeRefinementFlow(g *genkit.Genkit) *core.Flow[*IterativeRefinementRequest, string, struct{}] {
	return genkit.DefineFlow(g, "iterativeRefinementFlow",
		func(ctx context.Context, req *IterativeRefinementRequest) (string, error) {
			// Step 1: Generate the initial draft.
			resp, err := genkit.Generate(ctx, g,
				ai.WithPrompt("Write a short, single-paragraph blog post about: %v.", req.Topic),
			)
			if err != nil {
				return "", err
			}
			content := resp.Text()

			// Step 2: Iteratively refine the content.
			for i := 0; i < 3; i++ {
				// The "Evaluator" provides feedback.
				eval, _, err := genkit.GenerateData[Evaluation](ctx, g,
					ai.WithPrompt("Critique the following blog post. Is it clear, concise, and engaging? Provide specific feedback for improvement. Post: \"%v\"", content),
				)
				if err != nil {
					return "", err
				}
				if eval.Satisfied {
					break
				}

				// The "Optimizer" refines the content based on feedback.
				resp, err := genkit.Generate(ctx, g,
					ai.WithPrompt("Revise the following blog post based on the feedback provided.\nPost: \"%v\"\nFeedback: \"%v\"", content, eval.Critique),
				)
				if err != nil {
					return "", err
				}
				content = resp.Text()
			}
			return content, nil
		},
	)
}
