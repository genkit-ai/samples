import { z } from 'genkit';
import { ai } from '../config';

export const generateDraftFlow = ai.defineFlow(
  {
    name: 'generateDraftFlow',
    inputSchema: z.object({
      intent: z.string(),
      subintent: z.string(),
      inquiry: z.string(),
      context: z.record(z.unknown()),
      handlerResult: z.unknown(),
    }),
    outputSchema: z.object({
      draftResponse: z.string(),
    }),
  },
  async (input) => {
    const { output } = await ai.generate({
      prompt: `
      ### TASK
      Generate a customer service response based on the following information.
      
      ### CUSTOMER INQUIRY
      ${input.inquiry}
      
      ### CONTEXT
      Intent: ${input.intent}
      Subintent: ${input.subintent}
      
      Additional Context:
      ${JSON.stringify(input.context, null, 2)}
      
      Handler Result:
      ${JSON.stringify(input.handlerResult, null, 2)}
      
      ### INSTRUCTIONS
      - Be professional and courteous
      - Address the customer's specific concerns
      - Include relevant information from the context
      - Keep the tone friendly but business-appropriate
      - Be concise but thorough
      `,
      output: {
        schema: z.object({
          draftResponse: z.string()
        })
      }
    });
    
    return { draftResponse: output?.draftResponse || "" };
  }
); 