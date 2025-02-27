import { ai } from '../config';
import { z } from 'genkit';

const classifyOutput = z.object({
  intent: z.string(),
  subintent: z.string(),
});

export const classifyInquiryFlow = ai.defineFlow(
  {
    name: 'classifyInquiryFlow',
    inputSchema: z.object({
      inquiry: z.string(),
    }),
    outputSchema: classifyOutput,
  },
  async function main(input) {
    try {
      const { output } = await ai.generate({
        prompt: 
        `Classify the following customer inquiry into one of these intent/subintent pairs:
        - Catalog/GeneralQuestion
        - Catalog/ProductAvailability
        - Product/GeneralQuestion
        - Product/StockAvailability
        - Product/PriceInquiry
        - Order/GeneralQuestion
        - Order/TrackingStatus
        - Order/CancellationRequest
        - Returns/ProcessInquiry
        - Returns/RefundStatus
        - Shipping/DeliveryTimeframe
        - Shipping/CostInquiry
        - Account/LoginIssue
        - Account/UpdateInformation
        - Payment/MethodInquiry
        - Payment/TransactionIssue
        - Warranty/CoverageInquiry
        - Warranty/ClaimProcess
        - Feedback/ProductReview
        - Feedback/CustomerService
        - Other/Other

        Customer inquiry: ${input.inquiry}

        Classification:`,
        output: { schema: classifyOutput }
      });
      console.log('Classifying inquiry:', input.inquiry, output);
      if (output == null) {
        throw new Error("Response doesn't satisfy schema.");
      }
      return output;
    } catch (error) {
      console.error('Error in classifyInquiryFlow:', error);
      throw error;
    }
  }
); 