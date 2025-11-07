package flows

import (
	"context"
	"encoding/json"
	"fmt"

	jsonrepair "github.com/RealAlexandreAI/json-repair"
	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
	"google.golang.org/genai"
)

type StorifyRequest struct {
	Question string `json:"question"`
}

type Page struct {
	Text         string `json:"text" jsonschema:"description=1-2 paragraphs of text explaining a key concept or idea about the subject"`
	Illustration string `json:"illustration" jsonschema:"description=a detailed description of the image that should accompany the text for this page of the lesson"`
}

type Storybook struct {
	Status    string `json:"status,omitempty" jsonschema:"description=do not fill this in"`
	BookTitle string `json:"bookTitle,omitempty" jsonschema:"description=a fun title for the lesson"`
	Pages     []Page `json:"pages,omitempty"`
}

func DefineStorifyFlow(g *genkit.Genkit) *core.Flow[*StorifyRequest, *Storybook, *Storybook] {
	return genkit.DefineStreamingFlow(g, "storify", func(ctx context.Context, req *StorifyRequest, sendChunk func(context.Context, *Storybook) error) (*Storybook, error) {
		if sendChunk != nil {
			sendChunk(ctx, &Storybook{Status: "Studying to prepare lesson..."})
		}

		lessonPrompt := `You are an app that helps people understand complex concepts in a simple and fun way. The user has a question that they want explained in an engaging way. Your task is:

1. Search Google to get an accurate and grounded picture of the topic at hand.
2. Generate a "lesson plan" that accurately and approachably explains the core concepts of the lesson.
3. Break the lesson down into no more than 10 key ideas. Make sure to include details that could be turned into nice illustrations.

User question: {{question}}`

		lessonResponse, err := genkit.Generate(ctx, g,
			ai.WithModelName("googleai/gemini-2.5-pro"),
			ai.WithPrompt(lessonPrompt, map[string]any{"question": req.Question}),
			ai.WithConfig(&genai.GenerateContentConfig{
				Temperature: genai.Ptr[float32](0.3),
				Tools: []*genai.Tool{
					{
						GoogleSearch: &genai.GoogleSearch{},
					},
				},
			}),
		)
		if err != nil {
			return nil, fmt.Errorf("failed to generate lesson: %w", err)
		}
		lesson := lessonResponse.Text()

		if sendChunk != nil {
			sendChunk(ctx, &Storybook{Status: "Generating lesson storybook..."})
		}

		storybookPrompt := `You are an app that helps people understand complex concepts in a simple and fun way. The user has a question that they want explained in an engaging way. A lesson plan has already been generated and included below. Your task is to generate up to 10 pages of a simple "storybook lesson" that explains the subject. Each page should include 1-2 paragraphs and a detailed description of an illustration to accompany it.

Illustration descriptions will be generated using an image model starring the user as a cartoon character. Use 'USER' in the image description to incorporate them in. For example: "USER is riding a jeep through the African Serengeti, pointing at a galloping herd of wildebeests." ONLY use USER in image descriptions, not in titles or page text. ONLY include the user when the image might need a stand-in for a person, many pages will not require it. Try to include USER in the first page's illustration.

Your explanations should be approachable, fun, and easy to understand. Write in a simple and clear manner an adult would like to read using concepts that are simple and universal. You should cover all of the most important parts of the topic but you need to keep it short - no more than 10 pages.

=== LESSON ===

{{lesson}}`

		aggregatedJson := ""
		storybook, _, err := genkit.GenerateData[Storybook](ctx, g,
			ai.WithModelName("googleai/gemini-2.5-flash"),
			ai.WithPrompt(storybookPrompt, map[string]any{"lesson": lesson}),
			ai.WithStreaming(func(ctx context.Context, chunk *ai.ModelResponseChunk) error {
				if sendChunk != nil {
					aggregatedJson += chunk.Text()
					j, err := jsonrepair.RepairJSON(aggregatedJson)
					if err != nil {
						return err
					}

					s := &Storybook{}
					json.Unmarshal([]byte(j), s)
					s.Status = "Generating lesson storybook..."

					sendChunk(ctx, s)
				}
				return nil
			}),
		)
		if err != nil {
			return nil, fmt.Errorf("failed to generate storybook: %w", err)
		}

		return storybook, nil
	})
}
