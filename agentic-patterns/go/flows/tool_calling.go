package flows

import (
	"context"
	"fmt"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
)

type ToolCallingRequest struct {
	Prompt string `json:"prompt"`
}

type GetWeatherRequest struct {
	Location string `json:"location"`
}

func DefineToolCallingFlow(g *genkit.Genkit) *core.Flow[*ToolCallingRequest, string, struct{}] {
	getWeather := genkit.DefineTool(g,
		"getWeather",
		"Get the current weather in a given location.",
		func(ctx *ai.ToolContext, req *GetWeatherRequest) (string, error) {
			// In a real app, you would call a weather API here.
			return fmt.Sprintf("The weather in %s is 75°F and sunny.", req.Location), nil
		},
	)

	return genkit.DefineFlow(g, "toolCallingFlow",
		func(ctx context.Context, req *ToolCallingRequest) (string, error) {
			response, err := genkit.Generate(ctx, g,
				ai.WithPrompt(req.Prompt, nil),
				ai.WithTools(getWeather),
			)
			if err != nil {
				return "", err
			}
			return response.Text(), nil
		},
	)
}
