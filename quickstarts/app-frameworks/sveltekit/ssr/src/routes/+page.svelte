<script lang="ts">
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

  let craving = $state('something warm with chicken');
  let recipe = $state<Recipe | null>(null);
  let isStreaming = $state(false);

  async function generateRecipe(e: Event) {
    e.preventDefault();
    if (!craving.trim()) return;
    recipe = null;
    isStreaming = true;
    try {
      const result = streamFlow({
        url: '/api/bargainChefFlow',
        input: { craving },
      });
      for await (const partial of result.stream) {
        recipe = partial as Recipe;
      }
      await result.output;
    } catch (err) {
      console.error('Failed to generate recipe', err);
    } finally {
      isStreaming = false;
    }
  }
</script>

<main>
  <h1>Bargain Chef</h1>
  <p class="tagline">Tell me what you feel like eating and I'll suggest a recipe.</p>
  <form class="prompt" onsubmit={generateRecipe}>
    <input type="text" bind:value={craving} disabled={isStreaming} />
    <button type="submit" disabled={isStreaming}>
      {isStreaming ? 'Cooking…' : 'Suggest a recipe'}
    </button>
  </form>
  {#if recipe}
    <article>
      {#if recipe.title}<h2>{recipe.title}</h2>{/if}
      {#if recipe.description}<p class="description">{recipe.description}</p>{/if}
      {#if recipe.ingredients?.length}
        <h3>Ingredients</h3>
        <ul class="ingredients">
          {#each recipe.ingredients as ing}
            <li>{ing.quantity} {ing.name}{#if ing.onSale} <span class="badge">on sale</span>{/if}</li>
          {/each}
        </ul>
      {/if}
      {#if recipe.steps?.length}
        <h3>Steps</h3>
        <ol class="steps">{#each recipe.steps as step}<li>{step}</li>{/each}</ol>
      {/if}
    </article>
  {/if}
</main>

<style>
  :global(body) { font-family: -apple-system, sans-serif; color: #1a1a1a; background: #fafafa; margin: 0; }
  main { max-width: 640px; margin: 0 auto; padding: 3rem 1.5rem; }
  h1 { font-size: 2rem; margin: 0 0 0.25rem; }
  .tagline { color: #555; margin: 0 0 2rem; }
  .prompt { display: flex; gap: 0.5rem; margin-bottom: 2.5rem; }
  .prompt input { flex: 1; font: inherit; padding: 0.75rem 1rem; border: 1px solid #d0d0d0; border-radius: 8px; }
  .prompt button { font: inherit; font-weight: 500; padding: 0.75rem 1.25rem; border: 0; border-radius: 8px; background: #1a1a1a; color: #fff; cursor: pointer; }
  .prompt button:disabled { background: #999; cursor: not-allowed; }
  article { background: #fff; border: 1px solid #e5e5e5; border-radius: 12px; padding: 1.5rem 1.75rem; }
  .badge { display: inline-block; margin-left: 0.4rem; padding: 0.05rem 0.5rem; font-size: 0.75rem; background: #e8f5e9; color: #2e7d32; border-radius: 999px; }
</style>
