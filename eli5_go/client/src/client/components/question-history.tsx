import { useEffect, useState } from "react";
import { getItem } from "../lib/storage.js";
import { QuestionHistoryItem } from "../hooks/use-story-generator.js";

function timeAgo(timestamp: number): string {
  const now = Date.now();
  const seconds = Math.floor((now - timestamp) / 1000);

  let interval = seconds / 31536000;
  if (interval > 1) {
    return Math.floor(interval) + " years ago";
  }
  interval = seconds / 2592000;
  if (interval > 1) {
    return Math.floor(interval) + " months ago";
  }
  interval = seconds / 86400;
  if (interval > 1) {
    return Math.floor(interval) + " days ago";
  }
  interval = seconds / 3600;
  if (interval > 1) {
    return Math.floor(interval) + " hours ago";
  }
  interval = seconds / 60;
  if (interval > 1) {
    return Math.floor(interval) + " minutes ago";
  }
  return Math.floor(seconds) + " seconds ago";
}

export function QuestionHistory() {
  const [history, setHistory] = useState<QuestionHistoryItem[]>([]);

  useEffect(() => {
    getItem<QuestionHistoryItem[]>("question-history").then((h) => {
      setHistory(h || []);
    });
  }, []);

  if (!history.length) {
    return null;
  }

  return (
    <div className="mt-12 w-full max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
      <h2 className="text-lg font-medium text-foreground/80">Recents</h2>
      <ul className="mt-4 space-y-2">
        {history.map((item) => (
          <li key={item.timestamp}>
            <a
              href={`/?q=${encodeURIComponent(item.question)}`}
              className="block p-4 bg-white/5 rounded-lg hover:bg-white/10"
            >
              <p className="font-medium text-foreground">{item.question}</p>
              <p className="text-sm text-foreground/60 mt-1">
                {timeAgo(item.timestamp)}
              </p>
            </a>
          </li>
        ))}
      </ul>
    </div>
  );
}
