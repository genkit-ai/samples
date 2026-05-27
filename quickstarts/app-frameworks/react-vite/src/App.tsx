import { useState } from 'react';
import { streamFlow } from 'genkit/beta/client';
import './App.css';

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

function App() {
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
        url: BACKEND_URL,
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
      <p className="tagline">Backend: <code>{BACKEND_URL}</code></p>
      <form className="prompt" onSubmit={generateRecipe}>
        <input
          type="text"
          value={craving}
          onChange={(e) => setCraving(e.target.value)}
          disabled={isStreaming}
        />
        <button type="submit" disabled={isStreaming}>
          {isStreaming ? 'Cooking…' : 'Suggest a recipe'}
        </button>
      </form>
      {recipe && (
        <article>
          {recipe.title && <h2>{recipe.title}</h2>}
          {recipe.description && <p className="description">{recipe.description}</p>}
          {recipe.ingredients && recipe.ingredients.length > 0 && (
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
          )}
          {recipe.steps && recipe.steps.length > 0 && (
            <>
              <h3>Steps</h3>
              <ol className="steps">
                {recipe.steps.map((step, i) => <li key={i}>{step}</li>)}
              </ol>
            </>
          )}
        </article>
      )}
    </main>
  );
}

export default App;
