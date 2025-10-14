import { z } from 'genkit';
import { ai } from './genkit.js';

// Define a tool that can be called by the LLM
const getWeather = ai.defineTool(
  {
    name: 'getWeather',
    description: 'Get the current weather in a given location.',
    inputSchema: z.object({ location: z.string() }),
    outputSchema: z.string(),
  },
  async ({ location }) => {
    // In a real app, you would call a weather API here.
    return `The weather in ${location} is 75°F and sunny.`;
  }
);

export const toolCallingFlow = ai.defineFlow(
  {
    name: 'toolCallingFlow',
    inputSchema: z.object({ prompt: z.string() }),
    outputSchema: z.string(),
  },
  async ({ prompt }) => {
    const response = await ai.generate({
      prompt: prompt,
      tools: [getWeather],
    });

    return response.text;
  }
);
