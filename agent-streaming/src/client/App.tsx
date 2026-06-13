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
    if (chunk.type === 'thought') {
      const stepName = chunk.currentStep || 'Thinking';
      const content = chunk.content || '';

      setMessages((prev) => {
        const last = prev[prev.length - 1];
        if (last && last.role === 'model' && last.type === 'thought') {
          // Update the active thought message
          const updated: Message = {
            ...last,
            content: last.content + content,
            stepName: chunk.currentStep || last.stepName,
          };
          return [...prev.slice(0, -1), updated];
        } else {
          // Create a new thought message
          const newThought: Message = {
            id: crypto.randomUUID(),
            role: 'model',
            type: 'thought',
            content: content,
            stepName: stepName,
          };
          return [...prev, newThought];
        }
      });
    } else if (chunk.type === 'text') {
      const content = chunk.content || '';

      setMessages((prev) => {
        const last = prev[prev.length - 1];
        if (last && last.role === 'model' && last.type === 'text') {
          // Update the active text response
          const updated: Message = {
            ...last,
            content: last.content + content,
          };
          return [...prev.slice(0, -1), updated];
        } else {
          // Create a new text response
          const newText: Message = {
            id: crypto.randomUUID(),
            role: 'model',
            type: 'text',
            content: content,
          };
          return [...prev, newText];
        }
      });
    } else if (chunk.type === 'error') {
      const errorMessage: Message = {
        id: crypto.randomUUID(),
        role: 'system',
        type: 'error',
        content: chunk.content,
      };
      setMessages((prev) => [...prev, errorMessage]);
    }
  };

  return (
    <>
      <div className="chat-messages">
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
                role={msg.role}
                type={msg.type}
                content={msg.content}
              />
            );
          }
        })}
        <div ref={messagesEndRef} />
      </div>

      <ChatInput onSubmit={handlePromptSubmit} disabled={loading} />
    </>
  );
};

export default App;
