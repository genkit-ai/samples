import { z } from 'genkit';
import { ai } from './genkit.js';
import { googleAI } from '@genkit-ai/google-genai';

// A tool for the agent to search the web
const searchWeb = ai.defineTool(
  {
    name: 'searchWeb',
    description: 'Search the web for information on a given topic.',
    inputSchema: z.object({ query: z.string() }),
    outputSchema: z.string(),
  },
  async ({ query }) => {
    // In a real app, you would implement a web search API call here.
    return `You found search results for: ${query}`;
  }
);

// A tool for the agent to ask the user a question
const askUser = ai.defineInterrupt(
  {
    name: 'askUser',
    description: 'Ask the user a clarifying question.',
    inputSchema: z.object({ question: z.string() }),
    outputSchema: z.string(),
  },
);

export const researchAgent = ai.defineFlow(
  {
    name: 'researchAgent',
    inputSchema: z.object({ task: z.string() }),
    outputSchema: z.string(),
  },
  async ({ task }) => {
    let response = await ai.generate({
      system: `You are a helpful research assistant. Your goal is to provide a comprehensive answer to the user's task.`,
      prompt: `Your task is: ${task}. Use the available tools to accomplish this.`,
      model: googleAI.model('gemini-2.5-pro'),
      tools: [searchWeb, askUser],
      maxTurns: 5, // Limit the number of back-and-forth turns
    });

    // Handle potential interrupts (e.g., asking the user a question)
    while (response.interrupts.length > 0) {
      const interrupt = response.interrupts[0];
      if (interrupt.toolRequest.name === 'askUser') {
        const question = (interrupt.toolRequest.input as any).question;
        
        // In a real app, you would present the question to the user and get their answer.
        const userAnswer = await Promise.resolve(`The user answered: "Sample answer for '${question}'"`);

        response = await ai.generate({
          messages: response.messages,
          tools: [searchWeb, askUser],
          resume: {
            respond: [askUser.respond(interrupt, userAnswer)],
          },
        });
      } else {
        // Handle other unexpected interrupts if necessary
        break;
      }
    }

    return response.text;
  }
);
