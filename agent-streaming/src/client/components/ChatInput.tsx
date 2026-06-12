import React, { useState, useRef, useEffect } from 'react';

interface ChatInputProps {
  onSubmit: (prompt: string) => void;
  disabled: boolean;
}

export const ChatInput: React.FC<ChatInputProps> = ({ onSubmit, disabled }) => {
  const [input, setInput] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const trimmed = input.trim();
    if (trimmed && !disabled) {
      onSubmit(trimmed);
      setInput('');
    }
  };

  // Keep focus on input when transition completes or loading ends
  useEffect(() => {
    if (!disabled) {
      inputRef.current?.focus();
    }
  }, [disabled]);

  return (
    <form className="chat-input-form" id="chat-form" onSubmit={handleSubmit}>
      <input
        ref={inputRef}
        type="text"
        id="prompt-input"
        placeholder="Type a message..."
        autoComplete="off"
        required
        value={input}
        onChange={(e) => setInput(e.target.value)}
        disabled={disabled}
      />
      <button
        type="submit"
        id="send-button"
        aria-label="Send message"
        disabled={disabled || !input.trim()}
      >
        <svg viewBox="0 0 24 24" width="24" height="24">
          <path fill="currentColor" d="M2,21L23,12L2,3V10L17,12L2,14V21Z" />
        </svg>
      </button>
    </form>
  );
};
