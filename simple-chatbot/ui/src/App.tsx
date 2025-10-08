import { useState, useRef, useEffect } from "react";
import { runFlow, streamFlow } from "genkit/beta/client";
import type { GenerateResponseChunkData, GenerateResponseData, MessageData, Part, Role } from "genkit";
import { v4 as uuidv4 } from 'uuid';
import './App.css';

function renderPart(part: Part, index: number) {
  if (part.text) {
    return <pre key={index}>{part.text}</pre>;
  }
  if (part.toolRequest) {
    return (
      <div key={index} className="tool-request">
        <strong>Tool: {part.toolRequest.name}</strong>
        <pre>{JSON.stringify(part.toolRequest.input, null, 2)}</pre>
      </div>
    );
  }
  if (part.toolResponse) {
    return (
      <div key={index} className="tool-response">
        <strong>Tool response:</strong>
        <pre>{JSON.stringify(part.toolResponse.output, null, 2)}</pre>
      </div>
    );
  }
  return null;
}

function updateMessages(
  chunk: GenerateResponseChunkData,
  initialMessagesCount: number
) {
  return (currentMessages: MessageData[]): MessageData[] => {
    if (
      typeof chunk.index !== 'number' ||
      !chunk.role ||
      !chunk.content
    ) {
      return currentMessages;
    }

    const newMessages = [...currentMessages];
    const targetIndex = initialMessagesCount + chunk.index;

    if (newMessages[targetIndex]) {
      const existingContent = newMessages[targetIndex].content;
      const lastPart = existingContent[existingContent.length - 1];
      const newPart = chunk.content[0];

      if (lastPart?.text && newPart?.text) {
        // This is a new chunk for an existing message.
        // The chunk content is just the new part, so we need to append it.
        const updatedPart = { ...lastPart, text: lastPart.text + newPart.text };
        const updatedContent = [...existingContent.slice(0, -1), updatedPart];
        newMessages[targetIndex] = {
          ...newMessages[targetIndex],
          content: updatedContent,
        };
      } else {
        newMessages[targetIndex] = {
          ...newMessages[targetIndex],
          content: [...existingContent, ...chunk.content],
        };
      }
    } else {
      // This is the first chunk for a new message.
      newMessages[targetIndex] = {
        role: chunk.role as Role,
        content: chunk.content,
      };
    }
    return newMessages;
  };
}

function App() {
  const [messages, setMessages] = useState<MessageData[]>([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [sessionId, setSessionId] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const sessionIdFromUrl = urlParams.get('sessionId');
    if (sessionIdFromUrl) {
      setSessionId(sessionIdFromUrl);
    } else {
      const newSessionId = uuidv4();
      window.history.replaceState({}, '', `?sessionId=${newSessionId}`);
      setSessionId(newSessionId);
    }
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    if (sessionId) {
      loadHistory();
    }
  }, [sessionId]);

  const loadHistory = async () => {
    setLoading(true);
    // Use `runFlow` to execute a flow and receive the full response at once.
    // This is useful for operations that do not need to be streamed,
    // like fetching the chat history.
    const history = await runFlow({
        url: '/flows/getHistory',
        input: { sessionId },
    });
    setMessages(history);
    setLoading(false);
  };

  const startNewConversation = () => {
    window.location.href = window.location.origin;
  };

  const handleSend = async () => {
    const userMessage: MessageData = {
      role: "user",
      content: [{ text: input }],
    };
    const newMessages = [...messages, userMessage];
    setMessages(newMessages);
    setInput("");
    setLoading(true);

    try {
      // Use `streamFlow` to execute a flow and receive data in chunks.
      // This is ideal for real-time applications like chatbots,
      // allowing the UI to update as the response is generated.
      const { stream } = streamFlow<GenerateResponseData, GenerateResponseChunkData>({
        url: "/flows/chat",
        input: { sessionId, message: input },
      });

      let firstChunk = true;
      const initialMessagesCount = newMessages.length;

      for await (const chunk of stream) {
        if (firstChunk) {
          setLoading(false);
          firstChunk = false;
        }
        setMessages(updateMessages(chunk, initialMessagesCount));
      }
      if (firstChunk) {
        // Stream was empty
        setLoading(false);
      }
    } catch (err) {
      console.error(err);
      setLoading(false);
      const errorTime = new Date().toLocaleTimeString();
      const errorMessage: MessageData = {
        role: "model",
        content: [{ text: `An error occurred at ${errorTime}. Check the console for details.` }],
      };
      setMessages((currentMessages) => [...currentMessages, errorMessage]);
    }
  };

  return (
    <div className="app-container">
      <div className="chat-pane">
        <div className="messages-container">
          {messages.length === 0 && !loading && (
            <div className="zero-state">
              <h1>Simple Chatbot</h1>
              <p>Start a new conversation by typing a message below.</p>
            </div>
          )}
          {messages.map((msg, i) => (
            <div
              key={i}
              className={`message-bubble ${msg.role} ${
                msg.content.some((p) => p.toolRequest || p.toolResponse)
                  ? 'tool-call'
                  : ''
              }`}
            >
              {msg.content.map(renderPart)}
            </div>
          ))}
          {loading && (
            <div className="message-bubble model">
              <div className="spinner" />
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>
        <div className="input-area">
          <button
            onClick={startNewConversation}
            className="new-conversation"
            title="New Conversation"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <line x1="12" y1="5" x2="12" y2="19"></line>
              <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
          </button>
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && handleSend()}
            placeholder="Type your message..."
          />
          <button onClick={handleSend} disabled={loading}>
            Send
          </button>
        </div>
      </div>
    </div>
  );
}

export default App;
