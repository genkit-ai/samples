const { ai, streamingThoughtsFlow } = require('./src/index.js');

async function runTest() {
  console.log('Starting streaming thoughts test...');
  try {
    const responseStream = streamingThoughtsFlow.stream(
      'Provide a detailed, step-by-step logic puzzle explanation of how to cross a river with a wolf, a goat, and a cabbage.'
    );

    for await (const chunk of responseStream.stream) {
      if (chunk.type === 'thought') {
        process.stdout.write(`[THOUGHT]: ${chunk.content}\n`);
      } else if (chunk.type === 'text') {
        process.stdout.write(chunk.content);
      }
    }

    const finalResult = await responseStream.output;
    console.log('\n\n--- FINAL RESPONSE ---');
    console.log(finalResult);
  } catch (error) {
    console.error('Error running test:', error);
  }
}

runTest();
