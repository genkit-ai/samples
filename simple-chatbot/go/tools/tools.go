package tools

import (
	"errors"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/genkit"
)

// TempConversionInput defines the input structure for the tool.
type TempConversionInput struct {
	Temperature float64 `json:"temperature"`
	From        string  `json:"from" jsonschema_description:"Unit to convert from (celsius or fahrenheit)"`
	To          string  `json:"to" jsonschema_description:"Unit to convert to (celsius or fahrenheit)"`
}

// DefineTempConversionTool defines the temperature conversion tool.
func DefineTempConversionTool(g *genkit.Genkit) ai.Tool {
	return genkit.DefineTool(
		g, "convertTemperature", "Converts temperature from one unit to another.",
		func(ctx *ai.ToolContext, input TempConversionInput) (float64, error) {
			if input.From == input.To {
				return input.Temperature, nil
			}
			if input.From == "celsius" && input.To == "fahrenheit" {
				return (input.Temperature*9)/5 + 32, nil
			}
			if input.From == "fahrenheit" && input.To == "celsius" {
				return ((input.Temperature - 32) * 5) / 9, nil
			}
			return 0, errors.New("invalid temperature conversion units")
		},
	)
}
