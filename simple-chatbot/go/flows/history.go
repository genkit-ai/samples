package flows

import (
	"context"

	"simple-chatbot/go/history"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
)

// HistoryRequest is the input for the getHistory flow.
type HistoryRequest struct {
	SessionID string `json:"sessionId"`
}

// DefineHistoryFlow defines a flow for retrieving chat history.
func DefineHistoryFlow(g *genkit.Genkit) *core.Flow[*HistoryRequest, []*ai.Message, struct{}] {
	return genkit.DefineFlow(g, "getHistory", func(ctx context.Context, req *HistoryRequest) ([]*ai.Message, error) {
		h := history.Load(req.SessionID)
		// Always initialize messages as a non-nil slice to ensure it serializes to `[]` instead of `null`.
		messages := []*ai.Message{}
		if h == nil {
			return messages, nil
		}
		for _, msg := range h {
			if msg.Role != "system" {
				messages = append(messages, msg)
			}
		}
		return messages, nil
	})
}
