<script setup lang="ts">
import { ref } from 'vue';
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

// Set VITE_BARGAIN_CHEF_URL to point at a different backend.
const FLOW_URL =
  import.meta.env.VITE_BARGAIN_CHEF_URL ??
  'http://localhost:8080/bargainChefFlow';

const craving = ref('something warm with chicken');
const recipe = ref<Recipe | null>(null);
const isStreaming = ref(false);

async function generateRecipe() {
  if (!craving.value.trim()) return;
  recipe.value = null;
  isStreaming.value = true;
  try {
    const result = streamFlow({
      url: FLOW_URL,
      input: { craving: craving.value },
    });
    for await (const partial of result.stream) {
      recipe.value = partial as Recipe;
    }
    await result.output;
  } catch (err) {
    console.error('Failed to generate recipe', err);
  } finally {
    isStreaming.value = false;
  }
}
</script>

<template>
  <main>
    <h1>Bargain Chef</h1>
    <p class="tagline">
      Tell me what you feel like eating and I'll suggest a recipe built around
      today's grocery deals.
    </p>

    <form class="prompt" @submit.prevent="generateRecipe">
      <input
        type="text"
        v-model="craving"
        name="craving"
        placeholder="What are you in the mood for?"
        :disabled="isStreaming"
      />
      <button type="submit" :disabled="isStreaming">
        {{ isStreaming ? 'Cooking…' : 'Suggest a recipe' }}
      </button>
    </form>

    <article v-if="recipe">
      <h2 v-if="recipe.title">{{ recipe.title }}</h2>
      <p v-if="recipe.description" class="description">
        {{ recipe.description }}
      </p>
      <p v-if="recipe.servings" class="serves">
        <strong>Serves:</strong> {{ recipe.servings }}
      </p>

      <template v-if="recipe.ingredients?.length">
        <h3>Ingredients</h3>
        <ul class="ingredients">
          <li v-for="(ing, i) in recipe.ingredients" :key="i">
            {{ ing.quantity }} {{ ing.name }}
            <span v-if="ing.onSale" class="badge">on sale</span>
          </li>
        </ul>
      </template>

      <template v-if="recipe.steps?.length">
        <h3>Steps</h3>
        <ol class="steps">
          <li v-for="(step, i) in recipe.steps" :key="i">{{ step }}</li>
        </ol>
      </template>
    </article>
  </main>
</template>

<style scoped>
main {
  max-width: 640px;
  margin: 0 auto;
  padding: 3rem 1.5rem;
  font-family:
    -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue',
    Arial, sans-serif;
  color: #1a1a1a;
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
  transition:
    border-color 120ms ease,
    box-shadow 120ms ease;
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
