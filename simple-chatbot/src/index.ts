import express from "express";
import { chatFlow, getHistoryFlow } from "./genkit";
import { expressHandler } from '@genkit-ai/express';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const port = 3000;

app.use(express.json());

app.post('/flows/chat', expressHandler(chatFlow));
app.post('/flows/getHistory', expressHandler(getHistoryFlow));

app.use(express.static("ui/dist"));

app.get(/\/(.*)/, (req, res) => {
  res.sendFile(join(__dirname, '..', 'ui', 'dist', 'index.html'));
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}: http://localhost:3000`);
});
