import { z } from 'genkit';
import { ai } from '../config';
import { getCustomerByEmail, getOrderById, getProductById, getRecentOrdersByEmail, listProducts } from '../db';
import { extractInfoFlow } from './extract-info';

export const augmentInfo = ai.defineFlow(
  {
    name: 'augmentInfoFlow',
    inputSchema: z.object({
      intent: z.string(),
      customerInquiry: z.string(),
      email: z.string(),
    }),
    outputSchema: z.object({
      responseData: z.record(z.unknown()),
    }),
  },
  async (input) => {
    let responseData = {};
    switch (input.intent) {
      case 'Catalog':
        const products = await listProducts();
        responseData = { catalog: products };
        break;
      case 'Product':
        const productInfo = await extractInfoFlow({ inquiry: input.customerInquiry });
        if (productInfo.productId) {
          const product = await getProductById(productInfo.productId);
          responseData = { product };
        } else {
          const products = await listProducts();
          responseData = { products };
        }
        break;
      case 'Order':
        const orderInfo = await extractInfoFlow({ inquiry: input.customerInquiry });
        console.log(orderInfo);
        console.log('Extracted order info:', orderInfo);
        if (orderInfo.orderId) {
          const order = await getOrderById(orderInfo.orderId);
          console.log('Retrieved order:', order);
          responseData = { order };
        } else {
          const recentOrders = await getRecentOrdersByEmail(input.email);
          responseData = { recentOrders };
        }
        break;
      case 'Other':
        const customer = await getCustomerByEmail(input.email);
        responseData = { customer };
        break;
    }
    return { responseData };
  }
); 