import { createFileRoute } from '@tanstack/react-router';
import { useState } from 'react';
import { streamFlow } from 'genkit/beta/client';
import type {
  BargainChefInput,
  PartialRecipe,
  Recipe,
} from '~/genkit/bargainChefFlow';

// API route where your bargainChefFlow is served.
const FLOW_URL = '/api/bargainChefFlow';

export const Route = createFileRoute('/')({
  component: Home,
});

function Home() {
  const [craving, setCraving] = useState('something warm with chicken');
  const [recipe, setRecipe] = useState<PartialRecipe | null>(null);
  const [isStreaming, setIsStreaming] = useState(false);

  async function generateRecipe(e: React.FormEvent) {
    e.preventDefault();
    if (!craving.trim()) return;
    setRecipe(null);
    setIsStreaming(true);
    try {
      const input: BargainChefInput = { craving };
      // streamFlow's generics are <FinalOutput, StreamChunk>.
      const result = streamFlow<Recipe, PartialRecipe>({
        url: FLOW_URL,
        input,
      });
      // result.stream is an async iterable of partial recipes.
      // Each chunk is the accumulated output so far.
      for await (const partial of result.stream) {
        setRecipe(partial);
      }
      // Wait for the final validated output and surface any errors.
      await result.output;
    } catch (err) {
      console.error('Failed to generate recipe', err);
    } finally {
      setIsStreaming(false);
    }
  }

  return (
    <main>
      <h1>Bargain Chef</h1>
      <p className="tagline">
        Tell me what you feel like eating and I'll suggest a recipe built
        around today's grocery deals.
      </p>

      <form className="prompt" onSubmit={generateRecipe}>
        <input
          type="text"
          value={craving}
          onChange={(e) => setCraving(e.target.value)}
          name="craving"
          placeholder="What are you in the mood for?"
          disabled={isStreaming}
        />
        <button type="submit" disabled={isStreaming}>
          {isStreaming ? 'Cooking…' : 'Suggest a recipe'}
        </button>
      </form>

      {recipe && (
        <article>
          {recipe.title && <h2>{recipe.title}</h2>}
          {recipe.description && (
            <p className="description">{recipe.description}</p>
          )}
          {recipe.servings && (
            <p className="serves">
              <strong>Serves:</strong> {recipe.servings}
            </p>
          )}

          {recipe.ingredients?.length ? (
            <>
              <h3>Ingredients</h3>
              <ul className="ingredients">
                {recipe.ingredients.map((ing, i) => (
                  <li key={i}>
                    {ing.quantity} {ing.name}
                    {ing.onSale && <span className="badge">on sale</span>}
                  </li>
                ))}
              </ul>
            </>
          ) : null}

          {recipe.steps?.length ? (
            <>
              <h3>Steps</h3>
              <ol className="steps">
                {recipe.steps.map((step, i) => (
                  <li key={i}>{step}</li>
                ))}
              </ol>
            </>
          ) : null}
        </article>
      )}
    </main>
  );
}
