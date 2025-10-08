package main

import (
	"context"
	"log"
	"net/http"

	"eli5/flows"

	"github.com/firebase/genkit/go/genkit"
	"github.com/firebase/genkit/go/plugins/googlegenai"
	"github.com/firebase/genkit/go/plugins/server"
)

func main() {
	ctx := context.Background()

	g := genkit.Init(ctx,
		genkit.WithPlugins(&googlegenai.GoogleAI{}),
	)

	cartoonifyFlow := flows.DefineCartoonifyFlow(g)
	illustrateFlow := flows.DefineIllustrateFlow(g)
	storifyFlow := flows.DefineStorifyFlow(g)

	mux := http.NewServeMux()
	mux.HandleFunc("OPTIONS /api/cartoonify", corsMiddleware(nil))
	mux.HandleFunc("POST /api/cartoonify", corsMiddleware(genkit.Handler(cartoonifyFlow)))

	mux.HandleFunc("OPTIONS /api/illustrate", corsMiddleware(nil))
	mux.HandleFunc("POST /api/illustrate", corsMiddleware(genkit.Handler(illustrateFlow)))

	mux.HandleFunc("OPTIONS /api/storify", corsMiddleware(nil))
	mux.HandleFunc("POST /api/storify", corsMiddleware(genkit.Handler(storifyFlow)))

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
