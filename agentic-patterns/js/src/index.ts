import express from "express";
import { expressHandler } from '@genkit-ai/express';
import { storyWriterFlow, imageGeneratorFlow } from "./sequential-processing.js";
import { routerFlow } from "./conditional-routing.js";
import { marketingCopyFlow } from "./parallel-execution.js";
import { toolCallingFlow } from "./tool-calling.js";
import { agenticRagFlow, indexMenu } from "./agentic-rag.js";
import { iterativeRefinementFlow } from "./iterative-refinement.js";
import { researchAgent } from "./autonomous-operation.js";
import { statefulChatFlow } from "./stateful-interactions.js";

const app = express();
const port = 3000;

app.use(express.json());

app.post('/flows/storyWriter', expressHandler(storyWriterFlow));
app.post('/flows/imageGenerator', expressHandler(imageGeneratorFlow));
app.post('/flows/router', expressHandler(routerFlow));
app.post('/flows/marketingCopy', expressHandler(marketingCopyFlow));
app.post('/flows/toolCalling', expressHandler(toolCallingFlow));
app.post('/flows/agenticRag', expressHandler(agenticRagFlow));
app.post('/flows/indexMenu', expressHandler(indexMenu));
app.post('/flows/iterativeRefinement', expressHandler(iterativeRefinementFlow));
app.post('/flows/researchAgent', expressHandler(researchAgent));
app.post('/flows/statefulChat', expressHandler(statefulChatFlow));

app.listen(port, () => {
  console.log(`Server listening on port ${port}: http://localhost:3000`);
  console.log('Available flows:');
  console.log('  POST /flows/storyWriter');
  console.log('  POST /flows/imageGenerator');
  console.log('  POST /flows/router');
  console.log('  POST /flows/marketingCopy');
  console.log('  POST /flows/toolCalling');
  console.log('  POST /flows/agenticRag');
  console.log('  POST /flows/indexMenu');
  console.log('  POST /flows/iterativeRefinement');
  console.log('  POST /flows/researchAgent');
  console.log('  POST /flows/statefulChat');
});
