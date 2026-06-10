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
    // We use gemini-3.5-flash which natively supports thinkingConfig and provides deeper reasoning.
    const { stream, response } = await ai.generateStream({
      model: googleAI.model('gemini-3.5-flash'),
      prompt,
      config: {
        thinkingConfig: {
          includeThoughts: true,
          thinkingBudget: -1, // Default thinking budget
        },
      },
    });

    let accumulatedThoughts = "";

    // Consume the stream as it arrives
    for await (const chunk of stream) {
      // Process Thoughts
      // Gemini 3.5/2.5 models populate thoughts in `chunk.reasoning`. If using other
      // model providers or custom adapters, you may need to change this to chunk.thought,
      // chunk.custom?.thought, or manually iterate over `chunk.content` parts.
      const thoughtText = chunk.reasoning || '';

      if (thoughtText) {
        accumulatedThoughts += thoughtText;

        // Extract the most recent thought title wrapped in ** **
        const match = accumulatedThoughts.match(/.*\*\*(.*?)\*\*/s);
        const lastStep = match ? match[1] : undefined;

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
