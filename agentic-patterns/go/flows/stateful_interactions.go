package flows

import (
	"context"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
)

type StatefulChatRequest struct {
	SessionID string `json:"sessionId"`
	Message   string `json:"message"`
}

// A simple in-memory store for conversation history.
// In a real app, you would use a database like Firestore or Redis.
var historyStore = make(map[string][]*ai.Message)

func loadHistory(sessionID string) []*ai.Message {
	return historyStore[sessionID]
}

func saveHistory(sessionID string, history []*ai.Message) {
	historyStore[sessionID] = history
}

func DefineStatefulChatFlow(g *genkit.Genkit) *core.Flow[*StatefulChatRequest, string, struct{}] {
	return genkit.DefineFlow(g, "statefulChatFlow",
		func(ctx context.Context, req *StatefulChatRequest) (string, error) {
			// 1. Load history.
			history := loadHistory(req.SessionID)

			// 2. Append new message.
			history = append(history, ai.NewUserMessage(ai.NewTextPart(req.Message)))

			// 3. Generate response with history.
			response, err := genkit.Generate(ctx, g,
				ai.WithMessages(history...),
			)
			if err != nil {
				return "", err
			}

			// 4. Save updated history.
			saveHistory(req.SessionID, response.History())

			return response.Text(), nil
		},
	)
}
