import React, { useState, useRef, useEffect } from 'react';

interface ApprovalPromptProps {
  toolName: string;
  toolInput: any;
  onDecision: (approved: boolean, autoApproveSession?: boolean) => void;
}

const APPROVAL_OPTIONS = [
  { id: 1, label: 'Yes', approved: true, autoApprove: false },
  { id: 2, label: 'Yes, and always allow for this session', approved: true, autoApprove: true },
  { id: 3, label: 'No', approved: false, autoApprove: false, isReject: true }
];

export function ApprovalPrompt({ toolName, toolInput, onDecision }: ApprovalPromptProps) {
  const [selected, setSelected] = useState<number | null>(null);
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  const handleSelect = (optionNum: number, approved: boolean, autoApprove?: boolean) => {
    if (selected !== null) return;
    setSelected(optionNum);

    // 250ms delay so the user can see checkmark animation
    // before the prompt disappears and the backend stream resumes.
    timeoutRef.current = setTimeout(() => {
      onDecision(approved, autoApprove);
    }, 250);
  };



  const renderCheckOrNumber = (num: number) => {
    if (selected === num) {
      return (
        <svg viewBox="0 0 24 24" width="14" height="14" className="check-icon">
          <path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
        </svg>
      );
    }
    return String(num);
  };

  return (
    <div className="message approval-message animate-slide-up">
      <div className="approval-bubble">
        <div className="approval-body">
          <div className="approval-warning">
            <span>Allow agent to run <code>{toolName}</code>?</span>
          </div>

          <pre className="tool-args-preview">
            <code>{JSON.stringify(toolInput, null, 2)}</code>
          </pre>

          <div className="approval-options-stack">
            {APPROVAL_OPTIONS.map((opt) => (
              <button
                key={opt.id}
                className={`approval-option-card ${opt.isReject ? 'reject' : ''} ${selected === opt.id ? 'selected' : ''}`}
                onClick={() => handleSelect(opt.id, opt.approved, opt.autoApprove)}
                disabled={selected !== null}
              >
                <span className="option-key">{renderCheckOrNumber(opt.id)}</span>
                <span className="option-label">{opt.label}</span>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
