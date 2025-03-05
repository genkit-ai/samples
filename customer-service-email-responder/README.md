# Customer Service Email Responder with Genkit
This sample helps you use AI to take over your business's email customer support. 

These genkit flows take an email as input. If the email is a question that can be answered with AI, the provided flow will run a genkit flow that:
- classifies the intent
- extracts relevant IDs from the inquiry
- loads corresponding data from a SQLite database
- drafts a response to send back

If the email cannot be answered with AI or requires taking some actions, it will terminate and escalate the inquiry.

This sample demonstrates:
- Answering questions using a database + LLM
- Conditional branching based on intent (different data is added to the prompt based on whether the inquiry was an Order vs. Refund vs. Product question)
- Using an LLM call to escalate the request to a human based on certain conditions

## Prerequisites

Before you begin, make sure you have the following installed:

- Node (v18+)
- npm
- Genkit CLI (v1.0+)

## Getting Started


1. Install dependencies:
   ```
   pnpm i
   ```

2. Set up your environment:
   a. Grab your Google AI Studio API key from [here](aistudio.google.com/apikey).
   b. Set up your environment variables:
      Create a `.env` file in the root directory and add the following:
      ```
      GOOGLE_API_KEY=[YOUR AI STUDIO API KEY]
      ```

   c. Set up the database and seed with sample data:
      ```
      cd src/
      npx prisma generate
      npx prisma migrate dev --name init
      npm run prisma:seed
      cd ../
      ```

3. Test the email responder with sample data
   
   After seeding the database, you can test the chatbot with these example queries that match our seed data:

   ```bash
   # In a different terminal
   npm run genkit:dev

   # Test the classify inquiry flow to detect intent
   genkit flow:run classifyInquiryFlow '{
     "inquiry": "Is the Classic Blue T-Shirt for $19.99 still in stock?"
   }'

   # Test e2e CS flow (generates a email response to the input inquiry)
   genkit flow:run customerServiceFlow '{
     "from": "john.doe@example.com",
     "to": "support@company.com",
     "subject": "Product Catalog",
     "body": "Do you guys carry shirts?",
     "sentAt": "2024-03-14T12:00:00Z",
     "threadHistory": []
   }'
   ```

   ### Seeded Data Reference
   The SQLite database comes pre-seeded with some data so that you can
   easily test out your queries.

   #### Products:
   - Classic Blue T-Shirt ($19.99, SKU: BLU-TSHIRT-M)
   - Running Shoes ($89.99, SKU: RUN-SHOE-42)
   - Denim Jeans ($49.99, SKU: DEN-JEAN-32)
   - Leather Wallet ($29.99, SKU: LEA-WALL-01)
   - Wireless Headphones ($149.99, SKU: WIR-HEAD-BK)

   #### Customers and Their Orders:
   - John Doe (john.doe@example.com)
     - Order TRACK123456: 2 Blue T-Shirts, 1 Running Shoes (DELIVERED)
   - Jane Smith (jane.smith@example.com)
     - Order TRACK789012: 1 Denim Jeans (PROCESSING)
   - Bob Wilson (bob.wilson@example.com)
     - Order TRACK345678: 1 Leather Wallet, 1 Wireless Headphones (PENDING)
