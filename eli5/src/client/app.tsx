import { useEffect, useState } from "react";
import { Selfie } from "./components/selfie.js";
import { Story } from "./components/story.js";
import { UserAvatar } from "./components/user-avatar.js";
import { Welcome } from "./components/welcome.js";
import { useBackend } from "./hooks/use-backend.js";
import { useStoryGenerator } from "./hooks/use-story-generator.js";
import { getItem } from "./lib/storage.js";

export default function App() {
  const [hasSelfie, setHasSelfie] = useState(false);
  const [question, setQuestion] = useState<string | null>(null);
  const [initialQuestion, setInitialQuestion] = useState<string | undefined>();
  const { storybook, loading, generateStory } = useStoryGenerator();
  const { name, toggleBackend } = useBackend();

  useEffect(() => {
    async function checkSelfie() {
      const storedSelfie = await getItem("cartoon-selfie");
      if (storedSelfie) {
        setHasSelfie(true);
      }
    }
    checkSelfie();

    const handlePopState = () => {
      const params = new URLSearchParams(window.location.search);
      const q = params.get("q");
      setQuestion(q);
    };

    window.addEventListener("popstate", handlePopState);

    return () => {
      window.removeEventListener("popstate", handlePopState);
    };
  }, []);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const q = params.get("q");
    if (q) {
      const cacheKey = `story-cache:${q}`;
      getItem(cacheKey).then((cachedStory) => {
        if (cachedStory) {
          setQuestion(q);
        } else {
          setInitialQuestion(q);
          window.history.replaceState({}, "", window.location.pathname);
        }
      });
    }
  }, []);

  useEffect(() => {
    if (question) {
      generateStory(question);
    }
  }, [question]);

  const handleQuestion = (q: string) => {
    setQuestion(q);
    window.history.pushState({}, "", `?q=${encodeURIComponent(q)}`);
  };

  return (
    <div className="min-h-screen bg-background font-sans relative">
      <div className="absolute top-4 left-4">
        <button
          onClick={toggleBackend}
          className="px-4 py-2 rounded-md bg-gray-800 text-white"
        >
          API backend: {name.toUpperCase()}
        </button>
      </div>
      {hasSelfie && <UserAvatar onEdit={() => setHasSelfie(false)} />}
      <main className="py-12">
        {!question && (
          <div className="text-center">
            <h1 className="text-[212px] leading-[212px] font-extrabold tracking-tighter text-transparent bg-clip-text bg-gradient-to-br from-brand-secondary to-brand-primary flex justify-center">
              <div>ELI</div>
              <div className="scale-125 pl-4 text-brand-secondary text-shadow-lg text-shadow-purple-100">
                5
              </div>
            </h1>
            <p className="mt-6 max-w-md mx-auto text-base text-foreground/80 sm:text-lg md:mt-8 md:text-xl md:max-w-3xl">
              Submit a question and get a simple explanation.
            </p>
          </div>
        )}
        <div className="mt-12">
          {question ? (
            <Story
              question={question}
              storybook={storybook}
              loading={loading}
              onClose={() => {
                setQuestion(null);
                window.history.pushState({}, "", "/");
              }}
            />
          ) : hasSelfie ? (
            <Welcome
              onQuestion={handleQuestion}
              initialQuestion={initialQuestion}
            />
          ) : (
            <Selfie onSelfieTaken={() => setHasSelfie(true)} />
          )}
        </div>
      </main>
    </div>
  );
}
