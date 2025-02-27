import { z } from 'genkit';
import { ai } from '../config';
import { classifyInquiryFlow } from './classify-inquiry';
import { augmentInfo } from './augment-info';
import { generateDraftFlow } from './generate-draft';
import { createEscalation, getCustomerByEmail } from '../db';
import { requiresEscalationFlow } from './requires-escalation';

export const customerServiceFlow = ai.defineFlow(
  {
    name: 'customerServiceFlow',
    inputSchema: z.object({
      from: z.string(),
      to: z.string(), 
      subject: z.string(),
      body: z.string(),
      sentAt: z.string(),
    }),
    outputSchema: z.object({
      response: z.string(),
      escalated: z.boolean(),
    }),
  },
  async (input) => {
    console.log('Starting customerServiceFlow with input:', {
      from: input.from,
      to: input.to,
      subject: input.subject,
      body: input.body,
    });

    // Check if escalation is needed first
    console.log('Checking if escalation is required...');
    const escalationCheck = await requiresEscalationFlow({
      inquiry: input.body,
    });
    
    if (escalationCheck.requiresEscalation) {
      const escalationResult = await escalateToHuman(
        input.body,
        input.from,
        escalationCheck.reason || 'Automated escalation'
      );
      
      return {
        response: escalationResult.message,
        escalated: true,
      };
    }

    // Continue with normal flow if no escalation needed
    // Step 1: Classify the inquiry
    console.log('Step 1: Classifying inquiry...');
    const classificationResult = await classifyInquiryFlow({inquiry: input.body});
    console.log('Classification result:', classificationResult);
    const { intent, subintent } = classificationResult;

    // Step 2: Augment data
    console.log('Step 2: Augmenting data...');
    const augmentedData = await augmentInfo({
      intent,
      customerInquiry: input.body,
      email: input.from,
    });
    console.log('Augmented data:', augmentedData);

    // Step 3: Generate response
    console.log('Step 3: Generating response...');
    const responseResult = await generateDraftFlow({
      intent,
      subintent,
      inquiry: input.body,
      context: {
        ...augmentedData.responseData,
        subject: input.subject,
      },
    });
    console.log('Generated response:', responseResult);

    const result = {
      response: responseResult.draftResponse,
      escalated: false,
    };
    console.log('Final result:', result);
    return result;
  }
);

async function escalateToHuman(inquiry: string, email: string, reason: string) {
  const customer = await getCustomerByEmail(email);

  const escalation = await createEscalation(
    customer ? customer.id : email,
    'Customer Inquiry Escalation',
    `Inquiry: ${inquiry}\n\nReason for escalation: ${reason}`,
    inquiry
  );

  return {
    message: "Your inquiry has been escalated to our customer service team. We'll get back to you as soon as possible.",
    escalationId: escalation.id
  };
} 