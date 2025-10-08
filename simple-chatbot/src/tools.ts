import { GenkitBeta, z } from 'genkit/beta';

export const toolNames = ['temperatureConverter'];

export function defineTools(ai: GenkitBeta) {
  ai.defineTool(
    {
      name: 'temperatureConverter',
      description: 'Converts temperature between Celsius and Fahrenheit.',
      inputSchema: z.object({
        temperature: z.number(),
        from: z.enum(['C', 'F']),
        to: z.enum(['C', 'F']),
      }),
      outputSchema: z.number(),
    },
    async ({ temperature, from, to }) => {
      if (from === 'C' && to === 'F') {
        return (temperature * 9) / 5 + 32;
      }
      if (from === 'F' && to === 'C') {
        return ((temperature - 32) * 5) / 9;
      }
      throw new Error('Invalid conversion units.');
    }
  );
}
