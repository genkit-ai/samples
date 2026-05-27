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
	"github.com/firebase/genkit/go/plugins/middleware"
	"github.com/go-chi/chi/v5"
	chimw "github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
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
		genkit.WithPlugins(&googlegenai.GoogleAI{}, &middleware.Middleware{}),
	)

	getIngredientsOnSale := genkit.DefineTool(g, "getIngredientsOnSale",
		"Returns the ingredients on sale at the local grocery store, with prices. The sale set differs between weekdays and weekends.",
		func(toolCtx *ai.ToolContext, input SaleQuery) ([]SaleIngredient, error) {
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
		func(ctx context.Context, input CravingInput, sendChunk func(context.Context, Recipe) error) (Recipe, error) {
			today := time.Now().Weekday().String()

			prompt := "Today is " + today + ". The user is craving: " + input.Craving + ".\n\n" +
				"Call the getIngredientsOnSale tool with the dayType that matches today. Saturday and Sunday are weekends; all other days are weekdays. " +
				"Then propose ONE recipe that takes advantage of those deals. For each ingredient, set onSale=true if it appears in the tool's response, false otherwise."

			var final Recipe
			for value, err := range genkit.GenerateDataStream[Recipe](ctx, g,
				ai.WithModelName("googleai/gemini-flash-latest"),
				ai.WithPrompt(prompt),
				ai.WithTools(getIngredientsOnSale),
				ai.WithUse(&middleware.Retry{MaxRetries: 3}),
			) {
				if err != nil {
					return Recipe{}, err
				}
				if value.Done {
					if value.Response != nil {
						if outErr := value.Response.Output(&final); outErr != nil {
							return Recipe{}, outErr
						}
					}
					break
				}
				if sendChunk != nil {
					if err := sendChunk(ctx, value.Chunk); err != nil {
						return Recipe{}, err
					}
				}
			}

			if final.Title == "" {
				return Recipe{}, errors.New("failed to generate recipe")
			}
			return final, nil
		},
	)

	r := chi.NewRouter()
	r.Use(chimw.Logger)
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"POST", "OPTIONS"},
		AllowedHeaders: []string{"Content-Type", "Accept"},
	}))
	r.Post("/bargainChefFlow", genkit.Handler(bargainChefFlow))

	log.Println("Chi server listening on http://localhost:8080")
	if err := http.ListenAndServe(":8080", r); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
