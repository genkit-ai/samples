import { GenerateResponseChunk } from "genkit";
import { ai, z } from "../genkit.js";

const generateLesson = ai.prompt("generate-lesson");
const generateStorybook = ai.prompt("generate-storybook");

const PageSchema = z.object({
  text: z
    .string()
    .describe(
      "1-2 paragraphs of text explaining a key concept or idea about the subject",
    ),
  illustration: z
    .string()
    .describe(
      "a detailed description of the image that should accompany the text for this page of the lesson",
    ),
});
const StorybookSchema = ai.defineSchema(
  "Storybook",
  z.object({
    status: z.string().optional().describe("do not fill this in"),
    bookTitle: z.string().optional().describe("a fun title for the lesson"),
    pages: z.array(PageSchema).optional(),
  }),
);
export type Storybook = z.infer<typeof StorybookSchema>;

export const storify = ai.defineFlow(
  {
    name: "storify",
    inputSchema: z.object({
      question: z.string(),
    }),
    streamSchema: StorybookSchema,
    outputSchema: StorybookSchema,
  },
  async ({ question }, { sendChunk }) => {
    let latestChunk: Storybook = {};
    const update = (latest: any) => {
      latestChunk = latest;
      sendChunk(latestChunk);
    };
    update({ status: "Researching topic..." });
    const { text: lesson } = await generateLesson({ question });
    update({ status: "Research complete, generating lesson..." });
    const { output } = await generateStorybook(
      { lesson },
      {
        onChunk: (chunk) =>
          update({
            ...(chunk.output as Storybook),
            status: "Generating lesson storybook...",
          }),
      },
    );
    return output;
  },
);
