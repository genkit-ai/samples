import { Component, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { streamFlow } from 'genkit/beta/client';
import type {
  BargainChefInput,
  PartialRecipe,
  Recipe,
} from '../genkit/bargainChefFlow';

const FLOW_URL = '/api/bargainChefFlow';

@Component({
  selector: 'app-root',
  imports: [FormsModule],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  craving = signal('something warm with chicken');
  recipe = signal<PartialRecipe | null>(null);
  isStreaming = signal(false);

  async generateRecipe() {
    if (!this.craving().trim()) return;
    this.recipe.set(null);
    this.isStreaming.set(true);
    try {
      const input: BargainChefInput = { craving: this.craving() };
      const result = streamFlow<Recipe, PartialRecipe>({
        url: FLOW_URL,
        input,
      });
      for await (const partial of result.stream) {
        this.recipe.set(partial);
      }
      await result.output;
    } catch (err) {
      console.error('Failed to generate recipe', err);
    } finally {
      this.isStreaming.set(false);
    }
  }
}
