package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/genkit"
	"github.com/firebase/genkit/go/plugins/googlegenai"
	genkitmw "github.com/firebase/genkit/go/plugins/middleware"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

type BargainChefInput struct {
	Craving string `json:"craving" jsonschema:"description=What the user feels like eating right now."`
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

type SaleIngredient struct {
	Name  string `json:"name"`
	Price string `json:"price"`
}

type SaleInput struct {
	DayType string `json:"dayType" jsonschema:"enum=weekday,enum=weekend,description=Whether to fetch weekday or weekend sale prices."`
}

func main() {
	ctx := context.Background()

	g := genkit.Init(ctx,
		genkit.WithPlugins(&googlegenai.GoogleAI{}, &genkitmw.Middleware{}),
	)

	getIngredientsOnSale := genkit.DefineTool(g, "getIngredientsOnSale",
		"Returns the ingredients on sale at the local grocery store, with prices. The sale set differs between weekdays and weekends.",
		func(ctx *ai.ToolContext, input SaleInput) ([]SaleIngredient, error) {
			if input.DayType == "weekend" {
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
		func(ctx context.Context, input BargainChefInput, sendChunk func(context.Context, Recipe) error) (Recipe, error) {
			today := time.Now().Weekday().String()

			prompt := fmt.Sprintf(`Today is %s. The user is craving: %s.

Call the getIngredientsOnSale tool with the dayType that matches today. Saturday and Sunday are weekends; all other days are weekdays. Then propose ONE recipe that takes advantage of those deals. For each ingredient, set onSale=true if it appears in the tool's response, false otherwise.`, today, input.Craving)

			var final Recipe
			stream := genkit.GenerateDataStream[Recipe](ctx, g,
				ai.WithModelName("googleai/gemini-flash-latest"),
				ai.WithPrompt(prompt),
				ai.WithTools(getIngredientsOnSale),
				ai.WithUse(&genkitmw.Retry{MaxRetries: 3}),
			)
			for result, err := range stream {
				if err != nil {
					return Recipe{}, fmt.Errorf("failed to generate recipe: %w", err)
				}
				if result.Done {
					if result.Response != nil {
						if outErr := result.Response.Output(&final); outErr != nil {
							return Recipe{}, outErr
						}
					}
					break
				}
				if sendChunk != nil {
					if err := sendChunk(ctx, result.Chunk); err != nil {
						return Recipe{}, err
					}
				}
			}

			return final, nil
		},
	)

	e := echo.New()
	e.Use(middleware.Logger())
	e.Use(middleware.CORS())
	e.POST("/bargainChefFlow", echo.WrapHandler(genkit.Handler(bargainChefFlow)))

	log.Println("Echo server listening on http://localhost:8080")
	if err := e.Start(":8080"); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
