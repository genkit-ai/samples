import React, { useState, useEffect, useRef } from 'react';
import { ChatInput } from './components/ChatInput.js';
import { ThoughtBox } from './components/ThoughtBox.js';
import { MessageBubble } from './components/MessageBubble.js';
import { Message, StreamChunk } from './types.js';

export const App: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const abortControllerRef = useRef<AbortController | null>(null);

  // Auto-scroll to bottom on messages update
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'auto' });
  }, [messages]);

  // Clean up pending stream on unmount
  useEffect(() => {
    return () => {
      abortControllerRef.current?.abort();
    };
  }, []);

  const handlePromptSubmit = async (prompt: string) => {
    setLoading(true);

    // Abort any previous request
    abortControllerRef.current?.abort();
    const controller = new AbortController();
    abortControllerRef.current = controller;

    const userMessage: Message = {
      id: crypto.randomUUID(), // Generate unique message IDs
      role: 'user',
      type: 'text',
      content: prompt,
    };

    setMessages((prev) => [...prev, userMessage]);

    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ prompt }),
        signal: controller.signal,
      });

      if (!response.ok) {
        throw new Error(`Network response was not ok (Status: ${response.status})`);
      }
      if (!response.body) {
        throw new Error(`Response body is empty (Status: ${response.status})`);
      }

      const reader = response.body.getReader();
      const decoder = new TextDecoder();
      let buffer = '';

      while (true) {
        const { value, done } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');

        // Store the last partial line in the buffer to prevent parsing
        // errors if a chunk is split mid-line
        buffer = lines.pop() || '';

        const dataPrefix = 'data: ';
        for (const line of lines) {
          const trimmed = line.trim();
          if (trimmed.startsWith(dataPrefix)) {
            const jsonStr = trimmed.slice(dataPrefix.length);
            const chunk = JSON.parse(jsonStr) as StreamChunk;
            handleStreamChunk(chunk);
          }
        }
      }
    } catch (error) {
      if (error instanceof Error && error.name === 'AbortError') {
        return;
      }
      console.error('Streaming error:', error);
      const errorMessage: Message = {
        id: crypto.randomUUID(),
        role: 'system',
        type: 'error',
        content: 'Failed to connect to the agent. Please try again.',
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      if (abortControllerRef.current === controller) {
        setLoading(false);
      }
    }
  };

  const handleStreamChunk = (chunk: StreamChunk) => {
    setMessages((prev) => {
      const last = prev.at(-1);

      if (last && last.id === chunk.messageId) {
        // Update the active message in-place
        const updated = {
          ...last,
          content: last.content + (chunk.content || ''),
          ...(last.type === 'thought' ? { stepName: chunk.currentStep || last.stepName } : {}),
        } as Message;
        return [...prev.slice(0, -1), updated];
      } else {
        // Create a new message block and append it
        const newMessage = {
          id: chunk.messageId,
          type: chunk.type,
          role: chunk.type === 'thought' ? 'model' : chunk.type === 'error' ? 'system' : 'model',
          content: chunk.content || '',
          ...(chunk.type === 'thought' ? { stepName: chunk.currentStep || 'Thinking' } : {}),
        } as Message;
        return [...prev, newMessage];
      }
    });
  };

  return (
    <>
      <section className="chat-messages" aria-label="Chat History">
        {/* Welcome Message */}
        <div className="message system-message">
          <div className="message-content">
            Agent will think out loud and show reasoning
          </div>
        </div>

        {/* Conversation list */}
        {messages.map((msg) => {
          if (msg.type === 'thought') {
            return (
              <ThoughtBox
                key={msg.id}
                content={msg.content}
                stepName={msg.stepName}
              />
            );
          } else {
            return (
              <MessageBubble
                key={msg.id}
                {...msg}
              />
            );
          }
        })}
        <div ref={messagesEndRef} />
      </section>

      <ChatInput onSubmit={handlePromptSubmit} disabled={loading} />
    </>
  );
};

export default App;
