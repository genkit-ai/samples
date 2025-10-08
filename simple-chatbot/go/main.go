package main

import (
	"context"
	"log"
	"net/http"

	"simple-chatbot/go/flows"
	"simple-chatbot/go/tools"

	"github.com/firebase/genkit/go/genkit"
	"github.com/firebase/genkit/go/plugins/googlegenai"
	"github.com/firebase/genkit/go/plugins/server"
)

func main() {
	ctx := context.Background()

	g := genkit.Init(ctx,
		genkit.WithPlugins(&googlegenai.GoogleAI{}),
	)

	tools.DefineTempConversionTool(g)

	chatFlow := flows.DefineChatFlow(g)
	historyFlow := flows.DefineHistoryFlow(g)

	mux := http.NewServeMux()
	mux.HandleFunc("OPTIONS /flows/chat", corsMiddleware(nil))
	mux.HandleFunc("POST /flows/chat", corsMiddleware(genkit.Handler(chatFlow)))

	mux.HandleFunc("OPTIONS /flows/getHistory", corsMiddleware(nil))
	mux.HandleFunc("POST /flows/getHistory", corsMiddleware(genkit.Handler(historyFlow)))

	log.Println("Starting server on http://localhost:3001")
	log.Fatal(server.Start(ctx, "127.0.0.1:3001", mux))
}

func corsMiddleware(next http.Handler) http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		if next != nil {
			next.ServeHTTP(w, r)
		}
	})
}
