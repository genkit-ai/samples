package flows

import (
	"context"
	"fmt"

	"github.com/firebase/genkit/go/ai"
	"github.com/firebase/genkit/go/core"
	"github.com/firebase/genkit/go/genkit"
)

type MarketingCopyRequest struct {
	Product string `json:"product"`
}

type MarketingCopyResponse struct {
	Name    string `json:"name"`
	Tagline string `json:"tagline"`
}

func DefineMarketingCopyFlow(g *genkit.Genkit) *core.Flow[*MarketingCopyRequest, *MarketingCopyResponse, struct{}] {
	return genkit.DefineFlow(g, "marketingCopyFlow",
		func(ctx context.Context, req *MarketingCopyRequest) (*MarketingCopyResponse, error) {
			type result struct {
				key   string
				value string
				err   error
			}
			ch := make(chan result, 2)

			// Task 1: Generate a creative name
			go func() {
				resp, err := genkit.Generate(ctx, g,
					ai.WithPrompt("Generate a creative name for a new product: %v.", req.Product),
				)
				if err != nil {
					ch <- result{key: "name", err: err}
					return
				}
				ch <- result{key: "name", value: resp.Text()}
			}()

			// Task 2: Generate a catchy tagline
			go func() {
				resp, err := genkit.Generate(ctx, g,
					ai.WithPrompt("Generate a catchy tagline for a new product: %v.", req.Product),
				)
				if err != nil {
					ch <- result{key: "tagline", err: err}
					return
				}
				ch <- result{key: "tagline", value: resp.Text()}
			}()

			response := &MarketingCopyResponse{}
			var errs []error
			for i := 0; i < 2; i++ {
				r := <-ch
				if r.err != nil {
					errs = append(errs, r.err)
				} else {
					if r.key == "name" {
						response.Name = r.value
					} else if r.key == "tagline" {
						response.Tagline = r.value
					}
				}
			}

			if len(errs) > 0 {
				return nil, fmt.Errorf("failed to generate marketing copy: %v", errs)
			}

			return response, nil
		},
	)
}
