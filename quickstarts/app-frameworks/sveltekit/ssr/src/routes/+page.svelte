<script lang="ts">
  import { streamFlow } from 'genkit/beta/client';
  import type {
    BargainChefInput,
    PartialRecipe,
    Recipe,
  } from '$lib/genkit/bargainChefFlow';

  // API route where your bargainChefFlow is served.
  const FLOW_URL = '/api/bargainChefFlow';

  let craving = $state('something warm with chicken');
  let recipe = $state<PartialRecipe | null>(null);
  let isStreaming = $state(false);

  async function generateRecipe() {
    if (!craving.trim()) return;
    recipe = null;
    isStreaming = true;
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
        recipe = partial;
      }
      // Wait for the final validated output and surface any errors.
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
  <p class="tagline">Tell me what you feel like eating and I'll suggest a recipe built around today's grocery deals.</p>

  <form class="prompt" onsubmit={(e) => { e.preventDefault(); generateRecipe(); }}>
    <input
      type="text"
      bind:value={craving}
      name="craving"
      placeholder="What are you in the mood for?"
      disabled={isStreaming}
    />
    <button type="submit" disabled={isStreaming}>
      {isStreaming ? 'Cooking…' : 'Suggest a recipe'}
    </button>
  </form>

  {#if recipe}
    <article>
      {#if recipe.title}<h2>{recipe.title}</h2>{/if}
      {#if recipe.description}<p class="description">{recipe.description}</p>{/if}
      {#if recipe.servings}<p class="serves"><strong>Serves:</strong> {recipe.servings}</p>{/if}

      {#if recipe.ingredients?.length}
        <h3>Ingredients</h3>
        <ul class="ingredients">
          {#each recipe.ingredients as ing}
            <li>
              {ing.quantity} {ing.name}
              {#if ing.onSale}<span class="badge">on sale</span>{/if}
            </li>
          {/each}
        </ul>
      {/if}

      {#if recipe.steps?.length}
        <h3>Steps</h3>
        <ol class="steps">
          {#each recipe.steps as step}
            <li>{step}</li>
          {/each}
        </ol>
      {/if}
    </article>
  {/if}
</main>

<style>
  :global(body) {
    font-family:
      -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue',
      Arial, sans-serif;
    color: #1a1a1a;
    background: #fafafa;
    min-height: 100vh;
    margin: 0;
  }

  main {
    max-width: 640px;
    margin: 0 auto;
    padding: 3rem 1.5rem;
  }

  h1 {
    font-size: 2rem;
    margin: 0 0 0.25rem;
    letter-spacing: -0.01em;
  }

  .tagline {
    color: #555;
    margin: 0 0 2rem;
  }

  .prompt {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 2.5rem;
  }

  .prompt input {
    flex: 1;
    font: inherit;
    font-size: 1rem;
    padding: 0.75rem 1rem;
    border: 1px solid #d0d0d0;
    border-radius: 8px;
    background: #fff;
    transition: border-color 120ms ease, box-shadow 120ms ease;
  }

  .prompt input:focus {
    outline: none;
    border-color: #2563eb;
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
  }

  .prompt input:disabled {
    background: #f1f1f1;
    color: #888;
  }

  .prompt button {
    font: inherit;
    font-size: 1rem;
    font-weight: 500;
    padding: 0.75rem 1.25rem;
    border: 0;
    border-radius: 8px;
    background: #1a1a1a;
    color: #fff;
    cursor: pointer;
    transition: background 120ms ease;
    white-space: nowrap;
  }

  .prompt button:hover:not(:disabled) {
    background: #2563eb;
  }

  .prompt button:disabled {
    background: #999;
    cursor: not-allowed;
  }

  article {
    background: #fff;
    border: 1px solid #e5e5e5;
    border-radius: 12px;
    padding: 1.5rem 1.75rem;
  }

  article h2 {
    font-size: 1.5rem;
    margin: 0 0 0.5rem;
  }

  article h3 {
    font-size: 1rem;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: #666;
    margin: 1.5rem 0 0.5rem;
  }

  .description {
    color: #444;
    margin: 0 0 1rem;
  }

  .serves {
    color: #555;
    margin: 0;
    font-size: 0.95rem;
  }

  .ingredients,
  .steps {
    padding-left: 1.25rem;
    line-height: 1.6;
  }

  .ingredients li {
    margin-bottom: 0.25rem;
  }

  .steps li {
    margin-bottom: 0.5rem;
  }

  .badge {
    display: inline-block;
    margin-left: 0.4rem;
    padding: 0.05rem 0.5rem;
    font-size: 0.75rem;
    font-weight: 500;
    background: #e8f5e9;
    color: #2e7d32;
    border-radius: 999px;
  }

  @media (max-width: 480px) {
    .prompt {
      flex-direction: column;
    }
    .prompt button {
      width: 100%;
    }
  }
</style>
