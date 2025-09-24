import { useState, useRef, useEffect } from "react";
import { streamFlow } from "genkit/beta/client";
import type { MessageData, Part } from "genkit";
import './App.css';

function renderPart(part: Part, index: number) {
  if (part.text) {
    return <pre key={index}>{part.text}</pre>;
  }
  if (part.toolRequest) {
    return (
      <div key={index} className="tool-request">
        <strong>Tool: {part.toolRequest.name}</strong>
      </div>
    );
  }
  if (part.toolResponse) {
    return null;
  }
  return null;
}

function App() {
  const [messages, setMessages] = useState<MessageData[]>([]);
  const [input, setInput] = useState("");
  const [showPreview, setShowPreview] = useState(false);
  const [title, setTitle] = useState("New Tab");
  const [loading, setLoading] = useState(false);
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    const iframe = iframeRef.current;
    const handleLoad = () => {
      if (iframe?.contentDocument?.title) {
        setTitle(iframe.contentDocument.title);
      }
    };
    if (showPreview && iframe) {
      iframe.src = "/artifacts/main.html";
      iframe.addEventListener("load", handleLoad);
    }
    return () => {
      if (iframe) {
        iframe.removeEventListener("load", handleLoad);
      }
    };
  }, [showPreview]);

  const handleSend = async () => {
    const userMessage: MessageData = {
      role: "user",
      content: [{ text: input }],
    };
    const newMessages = [...messages, userMessage];
    setMessages(newMessages);
    setInput("");
    setLoading(true);

    const result = streamFlow({
      url: "/flows/agent",
      input: newMessages,
    });
    const stream = result.stream;

    let firstChunk = true;
    const initialMessagesCount = newMessages.length;

    for await (const chunk of stream) {
      if (firstChunk) {
        setLoading(false);
        firstChunk = false;
      }
      if (
        typeof chunk.index !== 'number' ||
        !chunk.role ||
        !chunk.content
      ) {
        continue;
      }

      if (
        chunk.content.some((p: Part) => p.toolRequest?.name === "open_file_preview")
      ) {
        setShowPreview(true);
        if (iframeRef.current) {
          iframeRef.current.src += "";
        }
      }

      setMessages((currentMessages) => {
        const newMessages = [...currentMessages];
        const targetIndex = initialMessagesCount + chunk.index;

        if (newMessages[targetIndex]) {
          // This is a new chunk for an existing message.
          // The chunk content is just the new part, so we need to append it.
          const existingContent = newMessages[targetIndex].content;
          const lastPart = existingContent[existingContent.length - 1];
          const newPart = chunk.content[0];
          if (lastPart?.text && newPart?.text) {
            lastPart.text += newPart.text;
          } else {
            existingContent.push(...chunk.content);
          }
        } else {
          // This is the first chunk for a new message.
          newMessages[targetIndex] = {
            role: chunk.role,
            content: chunk.content,
          };
        }
        return newMessages;
      });
    }

    await result.output;
    if (firstChunk) {
      setLoading(false);
    }
  };

  return (
    <div className="app-container">
      <div className="chat-pane">
        <div className="messages-container">
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
      {showPreview && (
        <div className="preview-pane">
          <div className="browser-window">
            <div className="browser-header">
              <div className="browser-tab">
                <span className="browser-tab-title">{title}</span>
              </div>
            </div>
            <div className="browser-toolbar">
              <div className="dots">
                <span className="dot red"></span>
                <span className="dot yellow"></span>
                <span className="dot green"></span>
              </div>
              <button
                className="refresh-btn"
                onClick={() => {
                  if (iframeRef.current) iframeRef.current.src += "";
                }}
              >
                ⟳
              </button>
              <div className="browser-address-bar">/artifacts/main.html</div>
              <button
                className="pop-out-btn"
                onClick={() => window.open("/artifacts/main.html", "_blank")}
              >
                ↗
              </button>
            </div>
            <div className="browser-content">
              <iframe ref={iframeRef} />
            </div>
          </div>
        </div> 
      )}
    </div>
  );
}

export default App;
