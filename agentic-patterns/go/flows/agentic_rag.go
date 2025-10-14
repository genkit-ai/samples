package flows

import (
	"context"
	"strings"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
	"github.com/firebase/genkit/go/plugins/localvec"
)

type AgenticRagRequest struct {
	Question string `json:"question"`
}

type MenuRagToolRequest struct {
	Query string `json:"query"`
}

func DefineAgenticRagFlow(g *genkit.Genkit, retriever ai.RetrieverArg) *core.Flow[*AgenticRagRequest, string, struct{}] {

	menuRagTool := genkit.DefineTool(g,
		"menuRagTool",
		"Use to retrieve information from the Genkit Grub Pub menu.",
		func(ctx *ai.ToolContext, req *MenuRagToolRequest) (string, error) {
			response, err := genkit.Retrieve(ctx.Context, g,
				ai.WithRetriever(retriever),
				ai.WithDocs(ai.DocumentFromText(req.Query, nil)),
				ai.WithConfig(&localvec.RetrieverOptions{K: 3}),
			)
			if err != nil {
				return "", err
			}
			var b strings.Builder
			for _, doc := range response.Documents {
				for _, part := range doc.Content {
					b.WriteString(part.Text)
					b.WriteString("\n")
				}
			}
			return b.String(), nil
		},
	)

	return genkit.DefineFlow(g, "agenticRagFlow",
		func(ctx context.Context, req *AgenticRagRequest) (string, error) {
			llmResponse, err := genkit.Generate(ctx, g,
				ai.WithPrompt(req.Question, nil),
				ai.WithTools(menuRagTool),
				ai.WithSystem(`You are a helpful AI assistant that can answer questions about the food available on the menu at Genkit Grub Pub.
Use the provided tool to answer questions.
If you don't know, do not make up an answer.
Do not add or change items on the menu.`),
			)
			if err != nil {
				return "", err
			}
			return llmResponse.Text(), nil
		},
	)
}

func DefineIndexMenuFlow(g *genkit.Genkit, docStore *localvec.DocStore) *core.Flow[struct{}, struct{}, struct{}] {
	return genkit.DefineFlow(g, "indexMenu",
		func(ctx context.Context, req struct{}) (struct{}, error) {
			menuItems := []string{
				"Classic Burger: A juicy beef patty with lettuce, tomato, and our special sauce.",
				"Vegetarian Burger: A delicious plant-based patty with avocado and sprouts.",
				"Fries: Crispy golden fries, lightly salted.",
				"Milkshake: A thick and creamy milkshake, available in vanilla, chocolate, and strawberry.",
				"Salad: A fresh garden salad with your choice of dressing.",
				"Chicken Sandwich: Grilled chicken breast with honey mustard on a brioche bun.",
				"Fish and Chips: Beer-battered cod with a side of tartar sauce.",
				"Onion Rings: Thick-cut onion rings, fried to perfection.",
				"Ice Cream Sundae: Two scoops of vanilla ice cream with chocolate sauce and a cherry on top.",
				"Apple Pie: A classic apple pie with a flaky crust, served warm.",
			}

			var docs []*ai.Document
			for _, item := range menuItems {
				docs = append(docs, ai.DocumentFromText(item, nil))
			}

			err := localvec.Index(ctx, docs, docStore)
			if err != nil {
				return struct{}{}, err
			}
			return struct{}{}, nil
		},
	)
}
