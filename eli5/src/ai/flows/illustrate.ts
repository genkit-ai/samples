import { ai, z } from "../genkit.js";
import { googleAI } from "@genkit-ai/google-genai";

export const illustrationSchema = z.object({
  userImage: z.string().describe("the user's image as a data URI"),
  illustration: z
    .string()
    .describe("a description of the illustration to generate"),
  question: z.string().describe("the question the story is about"),
});

export const illustrate = ai.defineFlow(
  {
    name: "illustrate",
    inputSchema: illustrationSchema,
    outputSchema: z.string(),
  },
  async ({
    userImage,
    illustration,
    question,
  }: z.infer<typeof illustrationSchema>) => {
    const { media } = await ai.generate({
      model: googleAI.model("gemini-2.5-flash-image-preview"),
      config: { responseModalities: ["TEXT", "IMAGE"] },
      prompt: [
        { text: "[USER]:\n" },
        { media: { url: userImage } },
        {
          text: `You are illustrating a page in an educational storybook for a child. The story is about the question \"${question}\". Generate the illustration described below in a friendly cartoon style. ONLY illustrate exactly what is described below. The illustration should be colorful with full-image backgrounds.\n\n${illustration}`,
        },
      ],
    });
    if (!media) {
      throw new Error("Image generation failed.");
    }
    return media.url;
  },
);
