import express from 'express';
import cors from 'cors';
import { expressHandler } from '@genkit-ai/express';
import { bargainChefFlow } from './bargainChefFlow.js';

const app = express();

app.use(cors());
app.use(express.json());
app.post('/bargainChefFlow', expressHandler(bargainChefFlow));

app.listen(8080, () => {
  console.log('Express server listening on http://localhost:8080');
});
