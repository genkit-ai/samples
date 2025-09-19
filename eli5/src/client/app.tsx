import { useEffect, useState } from "react";
import { Selfie } from "./components/selfie.js";
import { Story } from "./components/story.js";
import { UserAvatar } from "./components/user-avatar.js";
import { Welcome } from "./components/welcome.js";
import { useStoryGenerator } from "./hooks/use-story-generator.js";
import { getItem } from "./lib/storage.js";

export default function App() {
  const [hasSelfie, setHasSelfie] = useState(false);
  const [question, setQuestion] = useState<string | null>(null);
  const { storybook, loading, generateStory } = useStoryGenerator();

  useEffect(() => {
    async function checkSelfie() {
      const storedSelfie = await getItem("cartoon-selfie");
      if (storedSelfie) {
        setHasSelfie(true);
      }
    }
    checkSelfie();
  }, []);

  useEffect(() => {
    if (question) {
      generateStory(question);
    }
  }, [question]);

  return (
    <div className="min-h-screen bg-background font-sans relative">
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
              storybook={storybook}
              loading={loading}
              onClose={() => setQuestion(null)}
            />
          ) : hasSelfie ? (
            <Welcome onQuestion={setQuestion} />
          ) : (
            <Selfie onSelfieTaken={() => setHasSelfie(true)} />
          )}
        </div>
      </main>
    </div>
  );
}
