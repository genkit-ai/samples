import React, { useMemo } from 'react';
import { marked } from 'marked';
import DOMPurify from 'dompurify';

interface MessageBubbleProps {
  role: 'user' | 'model' | 'system';
  type: 'text' | 'error';
  content: string;
}

export const MessageBubble: React.FC<MessageBubbleProps> = ({ role, type, content }) => {
  const sanitizedHtml = useMemo(() => {
    if (role === 'model' && type === 'text') {
      try {
        const rawHtml = marked.parse(content, { breaks: true }) as string;
        return DOMPurify.sanitize(rawHtml);
      } catch (err) {
        console.error('Markdown parsing/sanitization error:', err);
        return '';
      }
    }
    return '';
  }, [content, role, type]);

  // Determine container classes
  let containerClass = 'message';
  if (role === 'user') {
    containerClass += ' user-message';
  } else if (role === 'model') {
    containerClass += ' model-message';
  } else if (role === 'system') {
    containerClass += ' system-message';
    if (type === 'error') {
      containerClass += ' error';
    }
  }

  return (
    <div className={containerClass}>
      {role === 'model' && type === 'text' && sanitizedHtml ? (
        <div
          className="message-content"
          dangerouslySetInnerHTML={{ __html: sanitizedHtml }}
        />
      ) : (
        <div className="message-content">{content}</div>
      )}
    </div>
  );
};
