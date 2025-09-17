import { useEffect, useState } from "react";
import { Selfie } from "./components/selfie.js";
import { Story } from "./components/story.js";
import { UserAvatar } from "./components/user-avatar.js";
import { Welcome } from "./components/welcome.js";
import { runFlow, streamFlow } from "genkit/beta/client";
import type { Storybook } from "../ai/flows/storify.js";

export default function App() {
  const [hasSelfie, setHasSelfie] = useState(false);
  const [question, setQuestion] = useState<string | null>(null);
  const [storybook, setStorybook] = useState<
    Storybook & { illustrations?: (string | null)[] }
  >({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const storedSelfie = localStorage.getItem("cartoon-selfie");
    if (storedSelfie) {
      setHasSelfie(true);
    }
  }, []);

  const generateIllustrations = async (book: Storybook, question: string) => {
    const userImage = localStorage.getItem("cartoon-selfie");
    if (!userImage || !book.pages || !question) {
      return;
    }

    setStorybook((prev) => ({
      ...prev,
      illustrations: book.pages!.map(() => null),
    }));

    const queue = book.pages.map((page, index) => ({ page, index }));

    const worker = async () => {
      while (true) {
        const item = queue.shift();
        if (!item) {
          return;
        }
        const { page, index } = item;
        try {
          const imageUrl = await runFlow<string>({
            url: "/api/illustrate",
            input: {
              userImage,
              illustration: page.illustration,
              question,
            },
          });
          setStorybook((prev) => {
            const newIllustrations = [...(prev.illustrations || [])];
            newIllustrations[index] = imageUrl;
            return { ...prev, illustrations: newIllustrations };
          });
        } catch (e) {
          console.error(e);
        }
      }
    };

    await Promise.all([worker(), worker()]);
  };

  const handleQuestionSubmit = async (question: string) => {
    setQuestion(question);
    setLoading(true);
    setStorybook({});

    const cacheKey = `story-cache:${question}`;
    const cachedStory = localStorage.getItem(cacheKey);

    try {
      let storybookToIllustrate: Storybook;
      if (cachedStory) {
        storybookToIllustrate = JSON.parse(cachedStory);
        setStorybook(storybookToIllustrate);
      } else {
        const flow = streamFlow<Storybook, Storybook>({
          url: "/api/storify",
          input: { question },
        });
        for await (const chunk of flow.stream) {
          setStorybook(chunk);
        }
        const finalBook = await flow.output;
        setStorybook(finalBook);
        localStorage.setItem(cacheKey, JSON.stringify(finalBook));
        storybookToIllustrate = finalBook;
      }
      await generateIllustrations(storybookToIllustrate, question);
    } catch (error) {
      console.error("Error generating story:", error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background font-sans relative">
      {hasSelfie && <UserAvatar />}
      <main className="py-12">
        {!question && (
          <div className="text-center">
            <h1 className="text-8xl font-extrabold tracking-tight text-transparent bg-clip-text bg-gradient-to-r from-brand-primary to-brand-accent">
              ELI5
            </h1>
            <p className="mt-3 max-w-md mx-auto text-base text-foreground/80 sm:text-lg md:mt-5 md:text-xl md:max-w-3xl">
              Submit a question and get a simple explanation.
            </p>
          </div>
        )}
        <div className="mt-12">
          {question ? (
            <Story storybook={storybook} loading={loading} />
          ) : hasSelfie ? (
            <Welcome onQuestion={handleQuestionSubmit} />
          ) : (
            <Selfie onSelfieTaken={() => setHasSelfie(true)} />
          )}
        </div>
      </main>
    </div>
  );
}
