import React, { useState, useRef, useEffect } from 'react';

function ToolCallBox({ tc, onDecision }: { tc: any, onDecision?: (approved: boolean) => void }) {
  const [isOpen, setIsOpen] = useState(false);
  return (
    <div className="message tool-message">
      <div className="tool-box">
        <div className="tool-header">
          <div key={`indicator-${tc.name}`} className="tool-indicator indicator-animate" />
          <div key={`label-${tc.name}`} className="tool-step-label step-animate">
            Used tool: <code>{tc.name}</code>
          </div>
        </div>
        <details
          className="tool-details"
          onToggle={(e) => setIsOpen(e.currentTarget.open)}
        >
          <summary className="tool-summary">
            <span className="summary-text">
              {isOpen ? 'Hide Tool Details' : 'Show Tool Details'}
            </span>
            {tc.state === 'running' && (
              <span className="tool-status running">Running...</span>
            )}
            {tc.state === 'approval-required' && (
              <span className="tool-status approval">Needs Approval</span>
            )}
          </summary>
          <div className="tool-body">
            <div>Input: {JSON.stringify(tc.input, null, 2)}</div>
            {tc.state === 'approval-required' && onDecision && (
              <ApprovalPrompt onDecision={onDecision} />
            )}
            {tc.output && (
              <div style={{ marginTop: '12px', borderTop: '1px solid #27272a', paddingTop: '12px', whiteSpace: 'pre-wrap' }}>
                Result: {typeof tc.output === 'object' ? JSON.stringify(tc.output, null, 2) : String(tc.output)}
              </div>
            )}
          </div>
        </details>
      </div>
    </div>
  );
}

export default function App() {
  const [messages, setMessages] = useState<{
    role: string;
    text: string;
    toolCalls?: ToolCall[];
  }[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const abortControllerRef = useRef<AbortController | null>(null);

  // Auto-scroll to bottom on new messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Abort request on component unmount
  useEffect(() => {
    return () => {
      abortControllerRef.current?.abort();
    };
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || loading) return;

    abortControllerRef.current?.abort();
    const controller = new AbortController();
    abortControllerRef.current = controller;

    const userMsg = { role: 'user', text: input.trim() };
    const nextMessages = [...messages, userMsg, { role: 'model', text: '' }];
    setMessages(nextMessages);
    setInput('');
    setLoading(true);

    try {
      const res = await fetch('/api/chat?stream=true', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        signal: controller.signal,
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
                if (payload.text) {
                  return [...prev.slice(0, -1), { ...last, text: last.text + (payload.text || '') }];
                }

                if (payload.toolRequest) {
                  const tc = {
                    name: payload.toolRequest.name,
                    input: payload.toolRequest.input,
                    state: 'running' as const
                  };
                  const toolCalls = [...(last.toolCalls || []), tc];
                  return [...prev.slice(0, -1), { ...last, toolCalls }];
                }

                if (payload.toolResponse) {
                  const toolCalls = (last.toolCalls || []).map(tc => {
                    const isMatch = payload.toolResponse.ref
                      ? tc.ref === payload.toolResponse.ref
                      : (tc.name === payload.toolResponse.name && tc.state === 'running');
                    if (isMatch) {
                      return { ...tc, output: payload.toolResponse.output, state: 'completed' as const };
                    }
                    return tc;
                  });
                  return [...prev.slice(0, -1), { ...last, toolCalls }];
                }

                return prev;
              });
            } catch (parseErr) {
              console.error('Failed to parse SSE line:', line, parseErr);
            }
          }
        }
      }
    } catch (err: any) {
      if (err.name === 'AbortError') {
        console.log('Fetch aborted.');
      } else {
        console.error(err);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="chat-container">
      <div className="chat-messages">
        {/* Welcome Message */}
        <div className="message system-message">
          <div className="message-content">
            Hint: Ask to read the menu or order a coffee.
          </div>
        </div>
        {messages.map((m, i) => (
          <React.Fragment key={i}>
            {m.toolCalls && m.toolCalls.map((tc, idx) => (
              <ToolCallBox 
                key={tc.ref || `tc-${i}-${idx}`} 
                tc={tc} 
                onDecision={(approved) => console.log('Decision:', approved)} 
              />
            ))}
            {(m.text || (!m.toolCalls || m.toolCalls.length === 0)) && (
              <div className={`message ${m.role}-message`}>
                <div className="message-content">
                  {m.text ? <div className="message-text">{m.text}</div> : '...'}
                </div>
              </div>
            )}
          </React.Fragment>
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
