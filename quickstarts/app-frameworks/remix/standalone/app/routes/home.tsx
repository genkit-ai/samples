import { useState } from 'react';
import { streamFlow } from 'genkit/beta/client';

const BACKEND_URL =
  import.meta.env.VITE_BARGAIN_CHEF_URL ?? 'http://localhost:8080/bargainChefFlow';

interface RecipeIngredient {
  name?: string;
  quantity?: string;
  onSale?: boolean;
}
interface Recipe {
  title?: string;
  description?: string;
  servings?: number;
  ingredients?: RecipeIngredient[];
  steps?: string[];
}

export default function Home() {
  const [craving, setCraving] = useState('something warm with chicken');
  const [recipe, setRecipe] = useState<Recipe | null>(null);
  const [isStreaming, setIsStreaming] = useState(false);

  async function generateRecipe(e: React.FormEvent) {
    e.preventDefault();
    if (!craving.trim()) return;
    setRecipe(null);
    setIsStreaming(true);
    try {
      const result = streamFlow({ url: BACKEND_URL, input: { craving } });
      for await (const partial of result.stream) setRecipe(partial as Recipe);
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
        Backend: <code>{BACKEND_URL}</code>
      </p>
      <p className="tagline">
        Tell me what you feel like eating and I&apos;ll suggest a recipe built
        around today&apos;s grocery deals.
      </p>
      <form className="prompt" onSubmit={generateRecipe}>
        <input
          value={craving}
          onChange={(e) => setCraving(e.target.value)}
          disabled={isStreaming}
          placeholder="What are you in the mood for?"
        />
        <button type="submit" disabled={isStreaming}>
          {isStreaming ? 'Cooking…' : 'Suggest a recipe'}
        </button>
      </form>
      {recipe && (
        <article>
          {recipe.title && <h2>{recipe.title}</h2>}
          {recipe.description && <p className="description">{recipe.description}</p>}
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
                {recipe.steps.map((s, i) => (
                  <li key={i}>{s}</li>
                ))}
              </ol>
            </>
          ) : null}
        </article>
      )}
    </main>
  );
}
