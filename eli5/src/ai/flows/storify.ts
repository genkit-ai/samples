import { GenerateResponseChunk, StreamingCallback } from "genkit";
import { ai, z } from "../genkit.js";

const generateLesson = ai.prompt("generate-lesson");
const generateStorybook = ai.prompt("generate-storybook");

const PageSchema = z.object({
  text: z
    .string()
    .describe(
      "1-2 paragraphs of text explaining a key concept or idea about the subject"
    ),
  illustration: z
    .string()
    .describe(
      "a detailed description of the image that should accompany the text for this page of the lesson"
    ),
});
const StorybookSchema = ai.defineSchema(
  "Storybook",
  z.object({
    status: z.string().optional().describe("do not fill this in"),
    bookTitle: z.string().optional().describe("a fun title for the lesson"),
    pages: z.array(PageSchema).optional(),
  })
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
    const stopSendingTimeouts = startSendingStatusUpdates(sendChunk);
    const { text: lesson } = await generateLesson({ question });
    stopSendingTimeouts();
    update({ status: "Planning complete, generating lesson..." });
    const { output } = await generateStorybook(
      { lesson },
      {
        onChunk: (chunk) =>
          update({
            ...(chunk.output as Storybook),
            status: "Generating lesson storybook...",
          }),
      }
    );
    return output;
  }
);

const WITTY_STATUS_UPDATES = [
  // Short & Snappy
  "Consulting the oracle...",
  "Waking the hive mind...",
  "Querying the matrix...",
  "Following the data trail...",
  "Rummaging through the archives...",
  "Summoning insights...",
  "Connecting the dots...",
  "Interrogating the knowledge base...",
  "Engaging the datasphere...",
  "Pinging the collective...",
  "Scanning the ether...",
  "Drilling for data...",

  // Playful & Nerdy
  "Compiling the codex...",
  "Warming up the neurons...",
  "Checking the footnotes...",
  "Consulting the elder brains...",
  "Sifting through the terabytes...",
  "Polishing the monocle...",
  "Engaging the cogitator...",
  "Reticulating splines...",
  "Aligning the data streams...",
  "Checking the lore...",
  "Buffering knowledge...",
  "Booting up the gray matter...",

  // Detective / Explorer Theme
  "On the hunt for facts...",
  "Turning over digital stones...",
  "Scouring the stacks...",
  "Now playing: Data Detective...",
  "Venturing into the data woods...",
  "Following the breadcrumbs...",
  "Uncovering the clues...",
  "Going down the rabbit hole...",
  "Mapping the information...",
  "On a fact-finding mission...",
  "Dusting for digital prints...",
  "Sleuthing for sources...",

  // Slightly Absurd & Humorous
  "Asking the squirrels...",
  "Translating the ancient scrolls...",
  "Figuring out which way is up...",
  "Herding the wild facts...",
  "Dusting off the grimoires...",
  "Rattling the cages of knowledge...",
  "Tickling the servers...",
  "Wrangling the rogue data...",
  "Chasing the elusive answer...",
  "Poking the info-nest...",
  "Shaking the magic 8-ball...",
  "Listening to the static...",

  // "Deep Work" / Intellectual
  "Entering the thinking vortex...",
  "Deep in the data mines...",
  "Forging the mental links...",
  "Synthesizing the strands...",
  "Distilling the information...",
  "Pondering the problem...",
  "Unraveling the complexity...",
  "Building the case...",
  "Assembling the puzzle...",
  "Cracking the code...",
  "Navigating the noise...",
  "Parsing the patterns...",
];

function startSendingStatusUpdates(
  sendChunk: StreamingCallback<z.infer<typeof StorybookSchema>>
): () => void {
  const to = setInterval(() => {
    sendChunk({
      status:
        WITTY_STATUS_UPDATES[
          Math.floor(Math.random() * WITTY_STATUS_UPDATES.length)
        ],
    });
  }, 5000);

  return to.close;
}
