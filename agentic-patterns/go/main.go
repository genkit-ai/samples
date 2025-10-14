package main

import (
	"context"
	"log"
	"net/http"

	"agentic-patterns/go/flows"

	"github.com/firebase/genkit/go/genkit"
	"github.com/firebase/genkit/go/plugins/googlegenai"
	"github.com/firebase/genkit/go/plugins/localvec"
	"github.com/firebase/genkit/go/plugins/server"
)

func main() {
	ctx := context.Background()

	g := genkit.Init(ctx,
		genkit.WithPlugins(&googlegenai.GoogleAI{}),
		genkit.WithDefaultModel("googleai/gemini-2.5-flash"),
	)

	embedder := googlegenai.GoogleAIEmbedder(g, "embedding-001")
	if err := localvec.Init(); err != nil {
		panic(err)
	}
	docStore, retriever, err := localvec.DefineRetriever(g, "menuQA", localvec.Config{Embedder: embedder}, nil)
	if err != nil {
		panic(err)
	}

	storyWriterFlow := flows.DefineStoryWriterFlow(g)
	imageGeneratorFlow := flows.DefineImageGeneratorFlow(g)
	routerFlow := flows.DefineRouterFlow(g)
	marketingCopyFlow := flows.DefineMarketingCopyFlow(g)
	toolCallingFlow := flows.DefineToolCallingFlow(g)
	agenticRagFlow := flows.DefineAgenticRagFlow(g, retriever)
	indexMenuFlow := flows.DefineIndexMenuFlow(g, docStore)
	iterativeRefinementFlow := flows.DefineIterativeRefinementFlow(g)
	researchAgentFlow := flows.DefineResearchAgentFlow(g)
	statefulChatFlow := flows.DefineStatefulChatFlow(g)

	mux := http.NewServeMux()
	mux.HandleFunc("OPTIONS /api/storyWriterFlow", corsMiddleware(nil))
	mux.HandleFunc("POST /api/storyWriterFlow", corsMiddleware(genkit.Handler(storyWriterFlow)))

	mux.HandleFunc("OPTIONS /api/imageGeneratorFlow", corsMiddleware(nil))
	mux.HandleFunc("POST /api/imageGeneratorFlow", corsMiddleware(genkit.Handler(imageGeneratorFlow)))

	mux.HandleFunc("OPTIONS /api/routerFlow", corsMiddleware(nil))
	mux.HandleFunc("POST /api/routerFlow", corsMiddleware(genkit.Handler(routerFlow)))

	mux.HandleFunc("OPTIONS /api/marketingCopyFlow", corsMiddleware(nil))
	mux.HandleFunc("POST /api/marketingCopyFlow", corsMiddleware(genkit.Handler(marketingCopyFlow)))

	mux.HandleFunc("OPTIONS /api/toolCallingFlow", corsMiddleware(nil))
	mux.HandleFunc("POST /api/toolCallingFlow", corsMiddleware(genkit.Handler(toolCallingFlow)))

	mux.HandleFunc("OPTIONS /api/agenticRagFlow", corsMiddleware(nil))
	mux.HandleFunc("POST /api/agenticRagFlow", corsMiddleware(genkit.Handler(agenticRagFlow)))

	mux.HandleFunc("OPTIONS /api/indexMenu", corsMiddleware(nil))
	mux.HandleFunc("POST /api/indexMenu", corsMiddleware(genkit.Handler(indexMenuFlow)))

	mux.HandleFunc("OPTIONS /api/iterativeRefinementFlow", corsMiddleware(nil))
	mux.HandleFunc("POST /api/iterativeRefinementFlow", corsMiddleware(genkit.Handler(iterativeRefinementFlow)))

	mux.HandleFunc("OPTIONS /api/researchAgent", corsMiddleware(nil))
	mux.HandleFunc("POST /api/researchAgent", corsMiddleware(genkit.Handler(researchAgentFlow)))

	mux.HandleFunc("OPTIONS /api/statefulChatFlow", corsMiddleware(nil))
	mux.HandleFunc("POST /api/statefulChatFlow", corsMiddleware(genkit.Handler(statefulChatFlow)))

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
