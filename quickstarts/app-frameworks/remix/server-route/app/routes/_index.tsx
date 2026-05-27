import { useState } from 'react';
import { streamFlow } from 'genkit/beta/client';

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

export default function Index() {
  const [craving, setCraving] = useState('something warm with chicken');
  const [recipe, setRecipe] = useState<Recipe | null>(null);
  const [isStreaming, setIsStreaming] = useState(false);

  async function generateRecipe(e: React.FormEvent) {
    e.preventDefault();
    if (!craving.trim()) return;
    setRecipe(null);
    setIsStreaming(true);
    try {
      const result = streamFlow({
        url: '/api/bargainChefFlow',
        input: { craving },
      });
      for await (const partial of result.stream) {
        setRecipe(partial as Recipe);
      }
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
      <form onSubmit={generateRecipe}>
        <input value={craving} onChange={(e) => setCraving(e.target.value)} disabled={isStreaming} />
        <button type="submit" disabled={isStreaming}>
          {isStreaming ? 'Cooking…' : 'Suggest a recipe'}
        </button>
      </form>
      {recipe && (
        <article>
          {recipe.title && <h2>{recipe.title}</h2>}
          {recipe.description && <p>{recipe.description}</p>}
          {recipe.ingredients && (
            <ul>
              {recipe.ingredients.map((ing, i) => (
                <li key={i}>{ing.quantity} {ing.name}{ing.onSale ? ' (on sale)' : ''}</li>
              ))}
            </ul>
          )}
          {recipe.steps && (
            <ol>{recipe.steps.map((s, i) => <li key={i}>{s}</li>)}</ol>
          )}
        </article>
      )}
    </main>
  );
}
