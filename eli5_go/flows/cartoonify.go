package flows

import (
	"context"
	"fmt"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
)

type CartoonifyRequest struct {
	Image string `json:"image" jsonschema:"description=A data URI of an image of a person to cartoonify"`
}

func DefineCartoonifyFlow(g *genkit.Genkit) *core.Flow[*CartoonifyRequest, string, struct{}] {
	return genkit.DefineFlow(g, "cartoonify", func(ctx context.Context, req *CartoonifyRequest) (string, error) {
		resp, err := genkit.Generate(ctx, g,
			ai.WithModelName("googleai/gemini-2.5-flash-image-preview"),
			ai.WithMessages(
				ai.NewUserMessage(
					ai.NewTextPart("Transform the person in the following image into a full-body cartoon character in a neutral pose. The background should be white."),
					ai.NewMediaPart("image/jpeg", req.Image),
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
