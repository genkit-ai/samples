const { genkit, z } = require('genkit');
const { googleAI } = require('@genkit-ai/google-genai');

const ai = genkit({
  plugins: [googleAI()],
});

// Define the schema for the streaming chunks
const StreamChunkSchema = z.object({
  type: z.enum(['thought', 'text']),
  content: z.string(),
  currentStep: z.string().optional(),
});

const streamingThoughtsFlow = ai.defineFlow(
  {
    name: 'streamingThoughtsFlow',
    inputSchema: z.string().describe('The prompt for the agent'),
    outputSchema: z.string().describe('The final text response'),
    streamSchema: StreamChunkSchema,
  },
  async (prompt, { sendChunk }) => {
    // Generate a stream using the Google AI plugin.
    // We use gemini-2.5-pro which natively supports thinkingConfig and provides deeper reasoning.
    const { stream, response } = await ai.generateStream({
      model: googleAI.model('gemini-2.5-pro'),
      prompt,
      config: {
        thinkingConfig: {
          includeThoughts: true,
          thinkingBudget: 2048,
        },
      },
    });

    let accumulatedThoughts = "";

    // Consume the stream as it arrives
    for await (const chunk of stream) {
      // Process Thoughts
      const thoughtText = chunk.custom?.thought || chunk.thoughtSummary?.() || chunk.thought;

      if (thoughtText) {
        accumulatedThoughts += thoughtText;

        // Extract the most recent thought title wrapped in ** **
        const matches = [...accumulatedThoughts.matchAll(/\*\*(.*?)\*\*/g)];
        const lastStep = matches.length > 0 ? matches[matches.length - 1][1] : undefined;

        sendChunk({
          type: 'thought',
          content: thoughtText,
          currentStep: lastStep,
        });
      }

      // Process response
      const text = chunk.text;
      if (text) {
        sendChunk({
          type: 'text',
          content: text,
        });
      }
    }

    // Wait for the full response and return the complete text
    const finalResponse = await response;
    return finalResponse.text;
  }
);

module.exports = { ai, streamingThoughtsFlow };
