import { z } from 'genkit';
import { ai } from '../config';

const escalationPrompt = (inquiry: string) => `You are a customer service triage system. Your role is to determine if a customer inquiry requires human escalation.

ESCALATION RULES:
- Escalate all refund-related inquiries
- Escalate all order cancellation requests
- Handle through AI: product inquiries, catalog questions, and order status questions

Analyze the inquiry and determine if it requires escalation based on these rules.

Customer inquiry: ${inquiry}

Respond with whether this requires escalation and if so, provide the reason.`;

export const requiresEscalationFlow = ai.defineFlow(
  {
    name: 'requiresEscalationFlow',
    inputSchema: z.object({
      inquiry: z.string(),
    }),
    outputSchema: z.object({
      requiresEscalation: z.boolean(),
      reason: z.string().optional(),
    }),
  },
  async (input) => {
    const { output } = await ai.generate({
      prompt: escalationPrompt(input.inquiry),
      output: {
        schema: z.object({
          requiresEscalation: z.boolean(),
          reason: z.string().optional()
        })
      }
    });
    
    return {
      requiresEscalation: output?.requiresEscalation || false,
      reason: output?.reason
    };
  }
); 