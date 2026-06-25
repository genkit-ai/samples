package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/genkit"
	"github.com/firebase/genkit/go/plugins/googlegenai"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"google.golang.org/genai"
)

type SaleItem struct {
	Name  string `json:"name" jsonschema:"description=The ingredient name"`
	Price string `json:"price" jsonschema:"description=The sale price, including units"`
}

type IngredientsOnSaleInput struct {
	DayType string `json:"dayType" jsonschema:"enum=weekday,enum=weekend,description=Whether to fetch weekday or weekend sale prices"`
}

type RecipeIngredient struct {
	Name     string `json:"name" jsonschema:"description=Ingredient name"`
	Quantity string `json:"quantity" jsonschema:"description=Amount needed (e.g. '2 cups', '1 lb')"`
	OnSale   bool   `json:"onSale" jsonschema:"description=True if this ingredient is in the sale list"`
}

type Recipe struct {
	Title       string             `json:"title" jsonschema:"description=Recipe title"`
	Description string             `json:"description" jsonschema:"description=Short description of the dish"`
	Servings    int                `json:"servings" jsonschema:"description=Number of servings"`
	Ingredients []RecipeIngredient `json:"ingredients" jsonschema:"description=The ingredient list"`
	Steps       []string           `json:"steps" jsonschema:"description=The ordered preparation steps"`
}

type BargainChefInput struct {
	Craving string `json:"craving" jsonschema:"description=What the user feels like eating right now"`
}

func main() {
	ctx := context.Background()

	g := genkit.Init(ctx,
		genkit.WithPlugins(&googlegenai.GoogleAI{}),
	)

	getIngredientsOnSale := genkit.DefineTool(g, "getIngredientsOnSale",
		"Returns the ingredients on sale at the local grocery store, with prices. The sale set differs between weekdays and weekends.",
		func(toolCtx *ai.ToolContext, input IngredientsOnSaleInput) ([]SaleItem, error) {
			if input.DayType == "weekend" {
				return []SaleItem{
					{Name: "chicken breast", Price: "$2.99/lb"},
					{Name: "pasta", Price: "$0.79"},
					{Name: "canned tomatoes", Price: "$0.99"},
					{Name: "garlic", Price: "$0.50 / head"},
					{Name: "olive oil", Price: "$6.99"},
				}, nil
			}
			return []SaleItem{
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
		func(ctx context.Context, input BargainChefInput, sendChunk func(context.Context, *Recipe) error) (*Recipe, error) {
			today := time.Now().Weekday().String()

			prompt := fmt.Sprintf(`Today is %s. The user is craving: %s.

Call the getIngredientsOnSale tool with the dayType that matches today. Saturday and Sunday are weekends; all other days are weekdays. Then propose ONE recipe that takes advantage of those deals. For each ingredient, set onSale=true if it appears in the tool's response, false otherwise.`, today, input.Craving)

			stream := genkit.GenerateDataStream[*Recipe](ctx, g,
				ai.WithModelName("googleai/gemini-flash-latest"),
				ai.WithConfig(&genai.GenerateContentConfig{
					ThinkingConfig: &genai.ThinkingConfig{
						ThinkingLevel: genai.ThinkingLevelMinimal,
					},
				}),
				ai.WithTools(getIngredientsOnSale),
				ai.WithPrompt(prompt),
			)

			for result, err := range stream {
				if err != nil {
					return nil, fmt.Errorf("failed to generate recipe: %w", err)
				}
				if result.Done {
					return result.Output, nil
				}
				if result.Chunk != nil {
					if err := sendChunk(ctx, result.Chunk); err != nil {
						return nil, err
					}
				}
			}

			return nil, fmt.Errorf("stream ended without a final recipe")
		},
	)

	r := gin.Default()
	r.Use(cors.Default())
	r.POST("/bargainChefFlow", gin.WrapH(genkit.Handler(bargainChefFlow)))

	log.Println("Gin server listening on http://localhost:8080")
	if err := r.Run(":8080"); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
