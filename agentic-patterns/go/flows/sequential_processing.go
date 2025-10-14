package flows

import (
	"context"
	"errors"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
)

type StoryWriterRequest struct {
	Topic string `json:"topic"`
}

type StoryIdea struct {
	Idea string `json:"idea" jsonschema_description:"A short, compelling story concept"`
}

type ImageGeneratorRequest struct {
	Concept string `json:"concept"`
}

func DefineStoryWriterFlow(g *genkit.Genkit) *core.Flow[*StoryWriterRequest, string, struct{}] {
	return genkit.DefineFlow(g, "storyWriterFlow",
		func(ctx context.Context, req *StoryWriterRequest) (string, error) {
			// Step 1: Generate a creative story idea
			idea, _, err := genkit.GenerateData[StoryIdea](ctx, g,
				ai.WithPrompt("Generate a unique story idea about a %v.", req.Topic),
			)
			if err != nil {
				return "", err
			}

			// Step 2: Use the idea to write the beginning of the story
			storyResponse, err := genkit.Generate(ctx, g,
				ai.WithPrompt("Write the opening paragraph for a story based on this idea: %v", idea.Idea),
			)
			if err != nil {
				return "", err
			}
			return storyResponse.Text(), nil
		},
	)
}

func DefineImageGeneratorFlow(g *genkit.Genkit) *core.Flow[*ImageGeneratorRequest, string, struct{}] {
	return genkit.DefineFlow(g, "imageGeneratorFlow",
		func(ctx context.Context, req *ImageGeneratorRequest) (string, error) {
			// Step 1: Use a text model to generate a rich image prompt
			promptResponse, err := genkit.Generate(ctx, g,
				ai.WithModelName("googleai/gemini-2.5-flash"),
				ai.WithPrompt("Create a detailed, artistic prompt for an image generation model. The concept is: \"%v\".", req.Concept),
			)
			if err != nil {
				return "", err
			}
			imagePrompt := promptResponse.Text()

			// Step 2: Use the generated prompt to create an image
			imageResponse, err := genkit.Generate(ctx, g,
				ai.WithModelName("googleai/imagen-3.0-generate-002"),
				ai.WithPrompt(imagePrompt, nil),
			)
			if err != nil {
				return "", err
			}
			for _, m := range imageResponse.Message.Content {
				if m.IsMedia() {
					return m.Text, nil
				}
			}
			return "", errors.New("did not generate an image")
		},
	)
}
