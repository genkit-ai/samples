import { ai } from '../config';
import { z } from 'genkit';

export const extractInfoFlow = ai.defineFlow(
  {
    name: 'extractInfoFlow',
    inputSchema: z.object({
      inquiry: z.string(),
    }),
    outputSchema: z.object({
      productId: z.number(),
      orderId: z.number(),
      customerId: z.number(),
      issue: z.string(),
    }),
  },
  async (input) => {
    const { output } = await ai.generate({
      prompt: `
      ### TASK
      Extract key information from the following customer inquiry.
      
      Please provide the following information:
      - Product ID (if mentioned)
      - Order ID (if mentioned)
      - Customer ID (if mentioned)
      - Main issue or question
      
      Important: If any of the requested information is not available in the inquiry, provide an empty string for that field. Do NOT invent or hallucinate any information.
      
      ### CUSTOMER INQUIRY
      ${input.inquiry}
      `,
      output: {
        schema: z.object({
          productId: z.string(),
          orderId: z.string(),
          customerId: z.string(),
          issue: z.string(),
        })
      }
    });

    return {
      productId: output?.productId ? parseInt(output.productId, 10) : 0,
      orderId: output?.orderId ? parseInt(output.orderId, 10) : 0,
      customerId: output?.customerId ? parseInt(output.customerId, 10) : 0,
      issue: output?.issue || "",
    };
  }
); 