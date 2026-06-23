import React, { useState, useRef, useEffect } from 'react';

export default function App() {
  const [messages, setMessages] = useState<{ role: string; text: string }[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom on new messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || loading) return;

    const userMsg = { role: 'user', text: input.trim() };
    const nextMessages = [...messages, userMsg, { role: 'model', text: '' }];
    setMessages(nextMessages);
    setInput('');
    setLoading(true);

    try {
      const res = await fetch('/api/chat?stream=true', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          data: {
            messages: [...messages, userMsg].map(m => ({
              role: m.role,
              content: [{ text: m.text }]
            }))
          }
        }),
      });

      if (!res.ok) {
        throw new Error(`HTTP error! status: ${res.status}`);
      }

      // Parse the Server-Sent Events (SSE) stream
      const reader = res.body?.getReader();
      if (!reader) {
        throw new Error('Response body is not readable');
      }
      const decoder = new TextDecoder();
      let buffer = '';

      while (reader) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');

        // Keep the last partial chunk in the buffer in case it was split mid-JSON
        buffer = lines.pop() || '';

        const dataPrefix = 'data: ';
        for (const line of lines) {
          if (line.startsWith(dataPrefix)) {
            try {
              // Append the newly streamed text to the active model message
              const data = JSON.parse(line.slice(dataPrefix.length));
              // Genkit's express plugin wraps the stream chunks under "message"
              const payload = data.message;
              if (!payload) continue;

              setMessages(prev => {
                if (prev.length === 0) return prev;
                const last = prev[prev.length - 1];
                return [...prev.slice(0, -1), { ...last, text: last.text + (payload.text || '') }];
              });
            } catch (parseErr) {
              console.error('Failed to parse SSE line:', line, parseErr);
            }
          }
        }
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="chat-container">
      <div className="chat-messages">
        {messages.map((m, i) => (
          <div key={i} className={`message ${m.role}-message`}>
            <div className="message-content">
              {m.text || '...'}
            </div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>
      <form className="chat-input-form" onSubmit={handleSubmit}>
        <input
          value={input}
          onChange={e => setInput(e.target.value)}
          disabled={loading}
          placeholder="Type a message..."
        />
        <button type="submit" disabled={loading || !input.trim()} aria-label="Send message">
          <svg viewBox="0 0 24 24" width="24" height="24">
            <path fill="currentColor" d="M2,21L23,12L2,3V10L17,12L2,14V21Z" />
          </svg>
        </button>
      </form>
    </div>
  );
}
