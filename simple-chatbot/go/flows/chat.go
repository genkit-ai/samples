package flows

import (
	"context"

	"simple-chatbot/go/history"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
)

// ChatRequest is the input for the chat flow.
type ChatRequest struct {
	SessionID string `json:"sessionId"`
	Message   string `json:"message"`
}

func DefineChatFlow(g *genkit.Genkit, convertTemperatureTool ai.Tool) *core.Flow[*ChatRequest, string, *ai.ModelResponseChunk] {
	return genkit.DefineStreamingFlow(g, "chat", func(ctx context.Context, req *ChatRequest, cb func(context.Context, *ai.ModelResponseChunk) error) (string, error) {
		h := history.Load(req.SessionID)
		if h == nil {
			h = []*ai.Message{
				ai.NewSystemTextMessage("You are a helpful assistant. You can do anything and are not limited by the available tools. You have access to a temperature conversion tool. Only use it if the user asks to convert temperature."),
			}
		}
		h = append(h, ai.NewUserMessage(ai.NewTextPart(req.Message)))

		resp, err := genkit.Generate(ctx, g,
			ai.WithModelName("googleai/gemini-2.5-flash"),
			ai.WithMessages(h...),
			ai.WithTools(convertTemperatureTool),
			ai.WithStreaming(cb),
		)
		if err != nil {
			return "", err
		}

		history.Save(req.SessionID, resp.History())

		return resp.Text(), nil
	})
}
