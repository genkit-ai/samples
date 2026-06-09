document.addEventListener('DOMContentLoaded', () => {
  const chatForm = document.getElementById('chat-form');
  const promptInput = document.getElementById('prompt-input');
  const chatMessages = document.getElementById('chat-messages');
  const sendButton = document.getElementById('send-button');

  chatForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const prompt = promptInput.value.trim();
    if (!prompt) return;

    // Clear input
    promptInput.value = '';
    promptInput.disabled = true;
    sendButton.disabled = true;

    // Append User Message Safely
    appendUserMessage(prompt);

    // Setup streaming state
    let activeThoughtElement = null;
    let activeThoughtBody = null;
    let activeStepName = null;

    let activeTextMessageElement = null;
    let activeTextMessageContent = null;

    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ prompt }),
      });

      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      if (!response.body) {
        throw new Error('Response body is null');
      }
      const reader = response.body.getReader();

      const decoder = new TextDecoder();
      let buffer = '';

      while (true) {
        const { value, done } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');

        // Keep the last partial line in the buffer
        buffer = lines.pop();

        for (const line of lines) {
          const trimmed = line.trim();
          if (trimmed.startsWith('data: ')) {
            const jsonStr = trimmed.slice(6);
            try {
              const chunk = JSON.parse(jsonStr);
              handleStreamChunk(chunk);
            } catch (err) {
              console.error('Failed to parse SSE JSON:', err);
            }
          }
        }
      }
    } catch (error) {
      console.error('Streaming error:', error);
      appendErrorMessage('Failed to connect to the agent. Please try again.');
    } finally {
      promptInput.disabled = false;
      sendButton.disabled = false;
      promptInput.focus();
    }

    // Handle each chunk type safely using standard elements & textContent
    function handleStreamChunk(chunk) {
      if (chunk.type === 'thought') {
        const stepName = chunk.currentStep || 'Thinking';
        const content = chunk.content;

        // If the step changed or we don't have an active thought bubble, create a new one
        if (stepName !== activeStepName || !activeThoughtElement) {
          if (activeThoughtBody) {
            activeThoughtBody.textContent = activeThoughtBody.textContent.trim();
          }
          activeStepName = stepName;
          createThoughtBubble(stepName);
        }

        // Append content to the current thought bubble's body
        if (activeThoughtBody) {
          activeThoughtBody.textContent += content;
        }
      } else if (chunk.type === 'text') {
        const content = chunk.content;
        
        // If we don't have an active text bubble yet, create one
        if (!activeTextMessageElement) {
          if (activeThoughtBody) {
            activeThoughtBody.textContent = activeThoughtBody.textContent.trim();
          }
          createTextBubble();
        }

        // Append text to the text bubble
        if (activeTextMessageContent) {
          activeTextMessageContent.textContent += content;
        }
      } else if (chunk.type === 'error') {
        appendErrorMessage(chunk.content);
      }
      
      // Auto scroll to bottom
      chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    // Helper functions to safely manipulate DOM to prevent XSS
    function createThoughtBubble(stepName) {
      const messageDiv = document.createElement('div');
      messageDiv.className = 'message thought-message';

      const contentDiv = document.createElement('div');
      contentDiv.className = 'message-content';

      const details = document.createElement('details');
      details.className = 'thought-details';

      const summary = document.createElement('summary');
      summary.className = 'thought-summary';
      summary.textContent = `Thinking: ${stepName}`;

      const body = document.createElement('div');
      body.className = 'thought-body';
      body.textContent = ''; // starts empty

      details.appendChild(summary);
      details.appendChild(body);
      contentDiv.appendChild(details);
      messageDiv.appendChild(contentDiv);
      chatMessages.appendChild(messageDiv);

      activeThoughtElement = messageDiv;
      activeThoughtBody = body;
    }

    function createTextBubble() {
      const messageDiv = document.createElement('div');
      messageDiv.className = 'message model-message';

      const contentDiv = document.createElement('div');
      contentDiv.className = 'message-content';
      contentDiv.textContent = ''; // starts empty

      messageDiv.appendChild(contentDiv);
      chatMessages.appendChild(messageDiv);

      activeTextMessageElement = messageDiv;
      activeTextMessageContent = contentDiv;
    }

  });

  function appendUserMessage(text) {
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message user-message';

    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content';
    contentDiv.textContent = text; // Safe text assignment

    messageDiv.appendChild(contentDiv);
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
  }

  function appendErrorMessage(text) {
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message system-message error';

    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content';
    contentDiv.textContent = text;

    messageDiv.appendChild(contentDiv);
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
  }
});
