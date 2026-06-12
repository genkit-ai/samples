import React, { useState } from 'react';

interface ThoughtBoxProps {
  content: string;
  stepName?: string;
}

export const ThoughtBox: React.FC<ThoughtBoxProps> = ({ content, stepName }) => {
  const [isOpen, setIsOpen] = useState(false);
  const activeStep = stepName || 'Thinking';

  return (
    <div className="message thought-message">
      <div className="thought-box">
        <div className="thought-header">
          {/* Use key={activeStep} on indicator and label to trigger a re-animation on step change */}
          <div key={`indicator-${activeStep}`} className="thought-indicator indicator-animate" />
          <div key={`label-${activeStep}`} className="thought-step-label step-animate">
            Thinking: {activeStep}
          </div>
        </div>
        <details
          className="thought-details"
          onToggle={(e) => setIsOpen((e.target as HTMLDetailsElement).open)}
        >
          <summary className="thought-summary">
            <span className="summary-text">
              {isOpen ? 'Hide Full Reasoning' : 'Show Full Reasoning'}
            </span>
          </summary>
          <div className="thought-body">{content}</div>
        </details>
      </div>
    </div>
  );
};
