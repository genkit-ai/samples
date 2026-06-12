import { marked } from 'marked';
import DOMPurify from 'dompurify';

interface StreamChunk {
  type: 'thought' | 'text' | 'error';
  content: string;
  currentStep?: string;
}

document.addEventListener('DOMContentLoaded', () => {
  const chatForm = document.getElementById('chat-form') as HTMLFormElement;
  const promptInput = document.getElementById('prompt-input') as HTMLInputElement;
  const chatMessages = document.getElementById('chat-messages') as HTMLDivElement;
  const sendButton = document.getElementById('send-button') as HTMLButtonElement;

  chatForm.addEventListener('submit', async (e: Event) => {
    e.preventDefault();
    const prompt = promptInput.value.trim();
    if (!prompt) return;

    // Clear input
    promptInput.value = '';
    promptInput.disabled = true;
    sendButton.disabled = true;

    // Append User Message Safely
    appendUserMessage(prompt);

    // Setup streaming state for unified thinking card
    let activeThoughtElement: HTMLDivElement | null = null;
    let activeThoughtStepLabel: HTMLDivElement | null = null;
    let activeThoughtIndicator: HTMLDivElement | null = null;
    let activeThoughtBody: HTMLDivElement | null = null;
    let activeStepName: string | null = null;

    let activeTextMessageElement: HTMLDivElement | null = null;
    let activeTextMessageContent: HTMLDivElement | null = null;
    let accumulatedModelText: string = '';

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
        buffer = lines.pop() || '';

        for (const line of lines) {
          const trimmed = line.trim();
          if (trimmed.startsWith('data: ')) {
            const jsonStr = trimmed.slice(6);
            try {
              const chunk = JSON.parse(jsonStr) as StreamChunk;
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
    function handleStreamChunk(chunk: StreamChunk) {
      if (chunk.type === 'thought') {
        const stepName = chunk.currentStep || 'Thinking';
        const content = chunk.content || '';

        // If we don't have an active thought card yet, create one
        if (!activeThoughtElement) {
          activeStepName = stepName;
          createThoughtContainer(stepName);
        } else if (stepName !== activeStepName) {
          // Update existing thought card for NEW THINKING animation
          activeStepName = stepName;
          if (activeThoughtStepLabel && activeThoughtIndicator) {
            activeThoughtStepLabel.textContent = `Thinking: ${stepName}`;
            
            // Re-trigger new thinking animation
            activeThoughtStepLabel.classList.remove('step-animate');
            activeThoughtIndicator.classList.remove('indicator-animate');
            void activeThoughtStepLabel.offsetWidth; // trigger reflow
            activeThoughtStepLabel.classList.add('step-animate');
            activeThoughtIndicator.classList.add('indicator-animate');
          }
        }

        // Append content to the thought body safely
        if (activeThoughtBody) {
          activeThoughtBody.textContent += content;
        }
      } else if (chunk.type === 'text') {
        const content = chunk.content || '';
        accumulatedModelText += content;
        
        // If we don't have an active text bubble yet, create one
        if (!activeTextMessageElement) {
          if (activeThoughtBody) {
            activeThoughtBody.textContent = activeThoughtBody.textContent.trim();
          }
          createTextBubble();
        }

        // STRICT SECURE PIPELINE: 1. Parse MD -> 2. Sanitize HTML -> 3. Render via innerHTML
        if (activeTextMessageContent) {
          try {
            const rawHtml = marked.parse(accumulatedModelText, { breaks: true }) as string;
            const safeHtml = DOMPurify.sanitize(rawHtml);
            activeTextMessageContent.innerHTML = safeHtml;
          } catch (err) {
            console.error('Markdown runtime parsing error:', err);
            activeTextMessageContent.textContent = accumulatedModelText;
          }
        }
      } else if (chunk.type === 'error') {
        appendErrorMessage(chunk.content);
      }
      
      // Auto scroll to bottom
      chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    // Helper functions to safely manipulate DOM to prevent XSS
    function createThoughtContainer(stepName: string) {
      const messageDiv = document.createElement('div');
      messageDiv.className = 'message thought-message';

      const contentDiv = document.createElement('div');
      contentDiv.className = 'thought-box';

      const headerDiv = document.createElement('div');
      headerDiv.className = 'thought-header';

      const indicatorDiv = document.createElement('div');
      indicatorDiv.className = 'thought-indicator indicator-animate';

      const stepLabelDiv = document.createElement('div');
      stepLabelDiv.className = 'thought-step-label step-animate';
      stepLabelDiv.textContent = `Thinking: ${stepName}`;

      headerDiv.appendChild(indicatorDiv);
      headerDiv.appendChild(stepLabelDiv);

      const details = document.createElement('details');
      details.className = 'thought-details';

      const summary = document.createElement('summary');
      summary.className = 'thought-summary';

      const summaryText = document.createElement('span');
      summaryText.className = 'summary-text';
      summaryText.textContent = 'Show Full Reasoning';

      summary.appendChild(summaryText);

      const body = document.createElement('div');
      body.className = 'thought-body';
      body.textContent = ''; // starts empty

      details.appendChild(summary);
      details.appendChild(body);

      details.addEventListener('toggle', () => {
        summaryText.textContent = details.open ? 'Hide Full Reasoning' : 'Show Full Reasoning';
      });

      contentDiv.appendChild(headerDiv);
      contentDiv.appendChild(details);
      messageDiv.appendChild(contentDiv);
      chatMessages.appendChild(messageDiv);

      activeThoughtElement = messageDiv;
      activeThoughtStepLabel = stepLabelDiv;
      activeThoughtIndicator = indicatorDiv;
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

  function appendUserMessage(text: string) {
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message user-message';

    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content';
    contentDiv.textContent = text; // Safe text assignment

    messageDiv.appendChild(contentDiv);
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
  }

  function appendErrorMessage(text: string) {
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
