import { useState, useRef } from "react";
import { runFlow, streamFlow } from "genkit/beta/client";
import { getItem, setItem } from "../lib/storage.js";
import { type Storybook } from "../lib/types.js";

export interface QuestionHistoryItem {
  question: string;
  timestamp: number;
}

async function updateQuestionHistory(question: string) {
  const history =
    (await getItem<QuestionHistoryItem[]>("question-history")) || [];
  const newHistory = [
    { question, timestamp: Date.now() },
    ...history.filter((item) => item.question !== question),
  ];
  await setItem("question-history", newHistory);
}

export function useStoryGenerator() {
  const url = "";
  const [storybook, setStorybook] = useState<
    Storybook & { illustrations?: (string | null)[] }
  >({});
  const [loading, setLoading] = useState(false);

  const illustrationsRef = useRef<(string | null)[]>([]);

  const generateStory = async (question: string) => {
    updateQuestionHistory(question);
    console.log("[StoryGenerator] Starting story generation for:", question);
    setLoading(true);
    setStorybook({});
    illustrationsRef.current = [];

    const cacheKey = `story-cache:${question}`;
    const cachedStory = await getItem<Storybook>(cacheKey);
    const userImage = await getItem<string>("cartoon-selfie");

    if (!userImage) {
      console.error(
        "[StoryGenerator] User image not found. Cannot generate illustrations."
      );
      setLoading(false);
      return;
    }

    const illustrationPromises: Promise<void>[] = [];

    const generateIllustration = (page: any, index: number) => {
      console.log(`[StoryGenerator] Queuing illustration for page ${index}`);
      const promise = (async () => {
        const cacheKey = `illustration-cache:${question}:${index}`;
        try {
          let imageUrl = await getItem<string>(cacheKey);
          if (imageUrl) {
            console.log(
              `[StoryGenerator] Illustration for page ${index} found in cache.`
            );
          } else {
            console.log(
              `[StoryGenerator] Generating illustration for page ${index}.`
            );
            imageUrl = await runFlow<string>({
              url: `${url}/api/illustrate`,
              input: {
                userImage,
                illustration: page.illustration,
                question,
              },
            });
            await setItem(cacheKey, imageUrl);
            console.log(
              `[StoryGenerator] Illustration for page ${index} generated and cached.`
            );
          }

          illustrationsRef.current[index] = imageUrl;
          console.log(
            `[StoryGenerator] Updated illustrationsRef for page ${index}:`,
            [...illustrationsRef.current]
          );
          setStorybook((prev) => {
            const newIllustrations = [...illustrationsRef.current];
            console.log(
              `[StoryGenerator] setStorybook update for page ${index}. New illustration array:`,
              newIllustrations
            );
            return {
              ...prev,
              illustrations: newIllustrations,
            };
          });
        } catch (e) {
          console.error(
            `[StoryGenerator] Error generating illustration for page ${index}:`,
            e
          );
        }
      })();
      illustrationPromises.push(promise);
    };

    try {
      if (cachedStory) {
        console.log("[StoryGenerator] Found cached story.");
        illustrationsRef.current = cachedStory.pages?.map(() => null) || [];
        setStorybook({
          ...cachedStory,
          illustrations: [...illustrationsRef.current],
        });
        if (cachedStory.pages) {
          console.log(
            `[StoryGenerator] Generating ${cachedStory.pages.length} illustrations from cached story.`
          );
          cachedStory.pages.forEach((page, index) => {
            generateIllustration(page, index);
          });
        }
      } else {
        console.log(
          "[StoryGenerator] No cached story found, streaming new story."
        );
        const flow = streamFlow<Storybook, Storybook>({
          url: `${url}/api/storify`,
          input: { question },
        });

        let processedPagesCount = 0;
        let currentBookForProcessing: Storybook & {
          illustrations?: (string | null)[];
        } = {};

        for await (const chunk of flow.stream) {
          currentBookForProcessing = { ...currentBookForProcessing, ...chunk };

          if (currentBookForProcessing.pages) {
            const pagesToProcessUntil =
              currentBookForProcessing.pages.length - 1;
            if (pagesToProcessUntil > processedPagesCount) {
              console.log(
                `[StoryGenerator] Processing pages from ${processedPagesCount} to ${
                  pagesToProcessUntil - 1
                }.`
              );
              while (
                illustrationsRef.current.length <
                currentBookForProcessing.pages.length
              ) {
                illustrationsRef.current.push(null);
              }
              for (let i = processedPagesCount; i < pagesToProcessUntil; i++) {
                generateIllustration(currentBookForProcessing.pages[i], i);
              }
              processedPagesCount = pagesToProcessUntil;
            }
          }

          setStorybook({
            ...currentBookForProcessing,
            illustrations: [...illustrationsRef.current],
          });
        }

        const finalBook = await flow.output;
        console.log("[StoryGenerator] Story streaming finished.");
        if (finalBook) {
          if (finalBook.pages && finalBook.pages.length > processedPagesCount) {
            console.log(
              `[StoryGenerator] Processing remaining pages from ${processedPagesCount} to ${
                finalBook.pages.length - 1
              }.`
            );
            for (let i = processedPagesCount; i < finalBook.pages.length; i++) {
              generateIllustration(finalBook.pages[i], i);
            }
          }
          setStorybook((prev) => ({ ...prev, ...finalBook }));
          await setItem(cacheKey, finalBook);
          console.log("[StoryGenerator] Final story book saved to cache.");
        }
      }
      await Promise.all(illustrationPromises);
      console.log("[StoryGenerator] All illustration promises settled.");
    } catch (error) {
      console.error("[StoryGenerator] Error generating story:", error);
    } finally {
      console.log("[StoryGenerator] Story generation process finished.");
      setLoading(false);
    }
  };

  return {
    storybook,
    loading,
    generateStory,
  };
}
