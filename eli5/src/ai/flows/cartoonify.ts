import { ai } from "../genkit.js";
import { googleAI } from "@genkit-ai/google-genai";
import { z } from "genkit";

const CartoonifyRequestSchema = z.object({
  image: z
    .string()
    .describe("A data URI of an image of a person to cartoonify"),
});

type CartoonifyRequest = z.infer<typeof CartoonifyRequestSchema>;

export const cartoonify = ai.defineFlow(
  {
    name: "cartoonify",
    inputSchema: CartoonifyRequestSchema,
    outputSchema: z.string(),
  },
  async ({ image }: CartoonifyRequest) => {
    const { media } = await ai.generate({
      model: googleAI.model("gemini-2.5-flash-image-preview"),
      config: { responseModalities: ["TEXT", "IMAGE"] },
      prompt: [
        {
          text: "Transform the person in the following image into a full-body cartoon character in a neutral pose. The background should be white.",
        },
        { media: { url: image } },
      ],
    });
    if (!media) {
      throw new Error("Image generation failed.");
    }
    return media.url;
  },
);
