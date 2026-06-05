package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"time"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/genkit"
	"github.com/firebase/genkit/go/plugins/googlegenai"
)

type DayType string

const (
	DayTypeWeekday DayType = "weekday"
	DayTypeWeekend DayType = "weekend"
)

type SaleQuery struct {
	DayType DayType `json:"dayType" jsonschema:"enum=weekday,enum=weekend,description=Whether to fetch weekday or weekend sale prices."`
}

type SaleIngredient struct {
	Name  string `json:"name"`
	Price string `json:"price"`
}

type RecipeIngredient struct {
	Name     string `json:"name"`
	Quantity string `json:"quantity"`
	OnSale   bool   `json:"onSale"`
}

type Recipe struct {
	Title       string             `json:"title"`
	Description string             `json:"description"`
	Servings    int                `json:"servings"`
	Ingredients []RecipeIngredient `json:"ingredients"`
	Steps       []string           `json:"steps"`
}

type CravingInput struct {
	Craving string `json:"craving" jsonschema:"description=What the user feels like eating right now."`
}

func main() {
	ctx := context.Background()

	g := genkit.Init(ctx,
		genkit.WithPlugins(&googlegenai.GoogleAI{}),
	)

	getIngredientsOnSale := genkit.DefineTool(g, "getIngredientsOnSale",
		"Returns the ingredients on sale at the local grocery store, with prices. The sale set differs between weekdays and weekends.",
		func(toolCtx *ai.ToolContext, input SaleQuery) ([]SaleIngredient, error) {
			// Mock data: in a real app, query a pricing database.
			if input.DayType == DayTypeWeekend {
				return []SaleIngredient{
					{Name: "chicken breast", Price: "$2.99/lb"},
					{Name: "pasta", Price: "$0.79"},
					{Name: "canned tomatoes", Price: "$0.99"},
					{Name: "garlic", Price: "$0.50 / head"},
					{Name: "olive oil", Price: "$6.99"},
				}, nil
			}
			return []SaleIngredient{
				{Name: "eggs", Price: "$3.49 / dozen"},
				{Name: "spinach", Price: "$1.99"},
				{Name: "parmesan", Price: "$4.99"},
				{Name: "lemons", Price: "$0.50 each"},
				{Name: "rice", Price: "$2.49"},
				{Name: "butter", Price: "$3.99"},
			}, nil
		},
	)

	bargainChefFlow := genkit.DefineStreamingFlow(g, "bargainChefFlow",
		func(ctx context.Context, input CravingInput, sendChunk func(context.Context, *Recipe) error) (*Recipe, error) {
			today := time.Now().Weekday().String()

			prompt := "Today is " + today + ". The user is craving: " + input.Craving + ".\n\n" +
				"Call the getIngredientsOnSale tool with the dayType that matches today. Saturday and Sunday are weekends; all other days are weekdays. " +
				"Then propose ONE recipe that takes advantage of those deals. For each ingredient, set onSale=true if it appears in the tool's response, false otherwise."

			var final *Recipe
			for value, err := range genkit.GenerateDataStream[*Recipe](ctx, g,
				ai.WithModelName("googleai/gemini-flash-latest"),
				ai.WithPrompt(prompt),
				ai.WithTools(getIngredientsOnSale),
			) {
				if err != nil {
					return nil, err
				}
				if value.Done {
					final = value.Output
					break
				}
				if value.Chunk != nil {
					if err := sendChunk(ctx, value.Chunk); err != nil {
						return nil, err
					}
				}
			}

			if final == nil {
				return nil, errors.New("failed to generate recipe")
			}
			return final, nil
		},
	)

	mux := http.NewServeMux()
	mux.Handle("POST /bargainChefFlow", withCORS(genkit.Handler(bargainChefFlow)))

	log.Println("net/http server listening on http://localhost:8080")
	if err := http.ListenAndServe(":8080", mux); err != nil {
		log.Fatalf("server error: %v", err)
	}
}

// withCORS allows a browser-based frontend to call the flow from any origin.
// In production, restrict the allowed origin to your frontend's domain.
func withCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Accept")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}
