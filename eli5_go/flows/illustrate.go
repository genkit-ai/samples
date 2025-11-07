package flows

import (
	"context"
	"fmt"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
)

type IllustrationRequest struct {
	UserImage    string `json:"userImage" jsonschema:"description=the user's image as a data URI"`
	Illustration string `json:"illustration" jsonschema:"description=a description of the illustration to generate"`
	Question     string `json:"question" jsonschema:"description=the question the story is about"`
}

func DefineIllustrateFlow(g *genkit.Genkit) *core.Flow[*IllustrationRequest, string, struct{}] {
	return genkit.DefineFlow(g, "illustrate", func(ctx context.Context, req *IllustrationRequest) (string, error) {
		resp, err := genkit.Generate(ctx, g,
			ai.WithModelName("googleai/gemini-2.5-flash-image-preview"),
			ai.WithMessages(
				ai.NewUserMessage(
					ai.NewTextPart("[USER]:\n"),
					ai.NewMediaPart("image/jpeg", req.UserImage),
					ai.NewTextPart(fmt.Sprintf("You are illustrating a page in an educational storybook for a child. The story is about the question \"%s\". Generate the illustration described below in a friendly cartoon style. ONLY illustrate exactly what is described below. The illustration should be colorful with full-image backgrounds.\n\n%s", req.Question, req.Illustration)),
				),
			),
		)
		if err != nil {
			return "", err
		}

		if len(resp.Message.Content) > 0 {
			for _, part := range resp.Message.Content {
				if part.IsMedia() {
					return part.Text, nil
				}
			}
		}

		return "", fmt.Errorf("no image was generated")
	})
}
