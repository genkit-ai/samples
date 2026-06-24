<script setup lang="ts">
import { ref } from 'vue';
import { streamFlow } from 'genkit/beta/client';

const config = useRuntimeConfig();
const backendUrl = config.public.bargainChefUrl as string;

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

const craving = ref('something warm with chicken');
const recipe = ref<Recipe | null>(null);
const isStreaming = ref(false);

async function generateRecipe() {
  if (!craving.value.trim()) return;
  recipe.value = null;
  isStreaming.value = true;
  try {
    const result = streamFlow({ url: backendUrl, input: { craving: craving.value } });
    for await (const partial of result.stream) recipe.value = partial as Recipe;
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
    <p class="tagline">Backend: <code>{{ backendUrl }}</code></p>
    <p class="tagline" style="font-size: 1rem">Tell me what you feel like eating and I'll suggest a recipe built around today's grocery deals.</p>
    <form class="prompt" @submit.prevent="generateRecipe">
      <input type="text" v-model="craving" :disabled="isStreaming" />
      <button type="submit" :disabled="isStreaming">
        {{ isStreaming ? 'Cooking…' : 'Suggest a recipe' }}
      </button>
    </form>
    <article v-if="recipe">
      <h2 v-if="recipe.title">{{ recipe.title }}</h2>
      <p class="description" v-if="recipe.description">{{ recipe.description }}</p>
      <template v-if="recipe.ingredients && recipe.ingredients.length">
        <h3>Ingredients</h3>
        <ul class="ingredients">
          <li v-for="(ing, i) in recipe.ingredients" :key="i">
            {{ ing.quantity }} {{ ing.name }}
            <span class="badge" v-if="ing.onSale">on sale</span>
          </li>
        </ul>
      </template>
      <template v-if="recipe.steps && recipe.steps.length">
        <h3>Steps</h3>
        <ol class="steps">
          <li v-for="(step, i) in recipe.steps" :key="i">{{ step }}</li>
        </ol>
      </template>
    </article>
  </main>
</template>

<style>
body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; color: #1a1a1a; background: #fafafa; margin: 0; padding: 3rem 1.5rem; }
main { max-width: 640px; margin: 0 auto; }
h1 { font-size: 2rem; margin: 0 0 0.25rem; }
.tagline { color: #555; margin: 0 0 2rem; font-size: 0.85rem; }
.prompt { display: flex; gap: 0.5rem; margin-bottom: 2.5rem; }
.prompt input { flex: 1; font: inherit; padding: 0.75rem 1rem; border: 1px solid #d0d0d0; border-radius: 8px; }
.prompt button { font: inherit; font-weight: 500; padding: 0.75rem 1.25rem; border: 0; border-radius: 8px; background: #1a1a1a; color: #fff; cursor: pointer; }
.prompt button:disabled { background: #999; cursor: not-allowed; }
article { background: #fff; border: 1px solid #e5e5e5; border-radius: 12px; padding: 1.5rem 1.75rem; }
.badge { display: inline-block; margin-left: 0.4rem; padding: 0.05rem 0.5rem; font-size: 0.75rem; background: #e8f5e9; color: #2e7d32; border-radius: 999px; }
.ingredients, .steps { padding-left: 1.25rem; line-height: 1.6; }
</style>
