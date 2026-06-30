import React, { useState, useRef, useEffect } from 'react';
import { remoteAgent, AgentChat } from 'genkit/beta/client';
import { ApprovalPrompt } from './ApprovalPrompt';

export interface ToolCall {
  name: string;
  input: any;
  state: 'running' | 'completed';
  ref?: string;
}

function ToolCallBox({ tc }: { tc: ToolCall }) {
  const [isOpen, setIsOpen] = useState(tc.state === 'running');

  const [prevTcState, setPrevTcState] = useState(tc.state);

  if (tc.state !== prevTcState) {
    setPrevTcState(tc.state);
    setIsOpen(tc.state === 'running');
  }
  return (
    <div className="message tool-message">
      <div className="tool-box">
        <div className="tool-header">
          <div key={`label-${tc.name}`} className="tool-step-label step-animate">
            {tc.state === 'running' ? 'Using' : 'Used'} tool: <code>{tc.name}</code>
          </div>
        </div>
        <details
          className="tool-details"
          open={isOpen}
          onToggle={(e) => setIsOpen(e.currentTarget.open)}
        >
          <summary className="tool-summary">
            <span className="summary-text">
              {isOpen ? 'Hide Tool Details' : 'Show Tool Details'}
            </span>
          </summary>
          <div className="tool-body">
            <div>Input: {JSON.stringify(tc.input, null, 2)}</div>
          </div>
        </details>
      </div>
    </div>
  );
}

// In a production app, you would save session IDs in a database 
// and retrieve them from the server to persist history across devices.
function useSessionId() {
  const [sessionId] = useState(() => {
    let id = sessionStorage.getItem('chat_session_id');
    if (!id) {
      id = crypto.randomUUID();
      sessionStorage.setItem('chat_session_id', id);
    }
    return id;
  });
  return sessionId;
}

export default function App() {
  const sessionId = useSessionId();
  const [messages, setMessages] = useState<{
    role: string;
    text: string;
    toolCalls?: ToolCall[];
  }[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const abortControllerRef = useRef<AbortController | null>(null);
  // Instantiate a stateful AgentChat instance
  const agentRef = useRef<AgentChat | null>(null);
  if (!agentRef.current) {
    agentRef.current = remoteAgent({ url: '/api/agent' }).chat({ sessionId });
  }

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

  const consumeTurn = async (turn: any) => {
    // 2. Consume the AsyncIterable stream of AgentChunks incrementally
    for await (const chunk of turn.stream) {
      setMessages(prev => {
        if (prev.length === 0) return prev;
        const last = prev[prev.length - 1];
        let updated = { ...last };

        // chunk.text contains the delta (new characters) for this chunk
        if (chunk.text) {
          updated.text = (updated.text || '') + chunk.text;
        }
        // chunk.toolRequests contains newly yielded ToolRequestParts
        if (chunk.toolRequests && chunk.toolRequests.length > 0) {
          const newToolCalls = chunk.toolRequests
            .filter((tr: any) => !(updated.toolCalls || []).some((tc: any) => tc.ref === tr.toolRequest.ref))
            .map((tr: any) => ({
              name: tr.toolRequest.name,
              input: tr.toolRequest.input,
              ref: tr.toolRequest.ref,
              state: 'running' as const
            }));
          updated.toolCalls = [...(updated.toolCalls || []), ...newToolCalls];
        }

        return [...prev.slice(0, -1), updated];
      });
    }

    // 3. Wait for AgentResponse
    const res = await turn.response;

    // 4. Update UI with final completed tool responses
    if (res.message && res.message.content) {
      setMessages(prev => {
        if (prev.length === 0) return prev;
        const last = prev[prev.length - 1];
        // Since turn.response has resolved, any tools that were 'running' during this turn are now 'completed'
        let toolCalls: ToolCall[] = [...(last.toolCalls || [])].map(tc => ({
          ...tc,
          state: res.finishReason === 'interrupted' ? tc.state : 'completed'
        }));

        // Iterate over the raw message parts to find toolRequests
        for (const part of res.message!.content) {
          if (part.toolRequest && !toolCalls.some(tc => tc.ref === part.toolRequest!.ref)) {
            toolCalls.push({
              name: part.toolRequest.name,
              input: part.toolRequest.input,
              ref: part.toolRequest.ref,
              state: res.finishReason === 'interrupted' ? 'running' : 'completed' // if it bypassed stream, it's also already completed unless interrupted
            });
          }
        }
        return [...prev.slice(0, -1), { ...last, toolCalls }];
      });
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || loading) return;

    const controller = new AbortController();
    abortControllerRef.current = controller;

    const userMsg = { role: 'user', text: input.trim() };
    const nextMessages = [...messages, userMsg, { role: 'model', text: '' }];
    setMessages(nextMessages);
    setInput('');
    setLoading(true);

    try {
      // 1. sendStream creates a turn and automatically manages passing message history
      const turn = agentRef.current!.sendStream(input.trim(), {
        abortSignal: controller.signal
      });

      await consumeTurn(turn);
    } catch (err) {
      if (err instanceof Error && err.name === 'AbortError') {
        console.log('Fetch aborted.');
      } else {
        console.error(err);
      }
    } finally {
      if (!controller.signal.aborted) {
        setLoading(false);
      }
    }
  };

  const handleDecision = async (tc: ToolCall, approved: boolean, autoApprove?: boolean) => {
    const controller = new AbortController();
    abortControllerRef.current = controller;
    setLoading(true);

    try {
      const resumePayload = approved
        ? {
            restart: [{
              toolRequest: {
                name: tc.name,
                ref: tc.ref,
                input: tc.input
              },
              metadata: { resumed: { toolApproved: true, autoApprove } }
            }]
          }
        : {
            respond: [{
              toolResponse: {
                name: tc.name,
                ref: tc.ref,
                output: 'Error: User rejected the action.'
              }
            }]
          };

      const turn = agentRef.current!.resumeStream(resumePayload, {
        abortSignal: controller.signal
      });

      await consumeTurn(turn);
    } catch (err) {
      if (err instanceof Error && err.name === 'AbortError') {
        console.log('Fetch aborted.');
      } else {
        console.error(err);
      }
    } finally {
      if (!controller.signal.aborted) {
        setLoading(false);
      }
    }
  };

  const pendingTool = messages.at(-1)?.toolCalls?.find(tc => tc.state === 'running');

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
        {!loading && pendingTool && (
          <ApprovalPrompt
            toolName={pendingTool.name}
            toolInput={pendingTool.input}
            onDecision={(approved, autoApprove) => handleDecision(pendingTool, approved, autoApprove)}
          />
        )}
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
