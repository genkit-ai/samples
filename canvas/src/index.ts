import express from "express";
import mime from "mime-types";
import {
  InMemoryArtifactManager,
} from "./artifact-manager";
import { ai } from "./genkit";
import { defineTools } from "./tools";
import {expressHandler} from '@genkit-ai/express'
import { defineAgent } from "./agent";
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const manager = new InMemoryArtifactManager();

defineTools(ai, manager);
const agent = defineAgent(ai, manager);

const app = express();
const port = 3000;

app.use(express.json());

app.get(/^\/artifacts\/(.*)/, async (req, res) => {
  const path = req.params[0];
  try {
    const content = await manager.readFile(path);
    const contentType = mime.lookup(path) || "text/plain";
    res.type(contentType).send(content);
  } catch (error) {
    res.status(404).send(error.message);
  }
});

app.post('/flows/agent', expressHandler(agent))

app.use(express.static("ui/dist"));

app.get(/\/(.*)/, (req, res) => {
  res.sendFile(join(__dirname, '..', 'ui', 'dist', 'index.html'));
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}: http://localhost:3000`);
});
