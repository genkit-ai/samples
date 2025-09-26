import { Genkit, z } from "genkit";
import { ArtifactManager } from "./artifact-manager";

export const toolNames = [
  "find_and_replace",
  "read_file",
  "search_files",
  "list_files",
  "write_to_file",
];

export const agentToolNames = [
  "find_and_replace",
  "read_file",
  "write_to_file",
];

export function defineTools(ai: Genkit, manager: ArtifactManager) {
  ai.defineTool(
    {
      name: "find_and_replace",
      description:
        "Performs a search and replace operation on a file. This tool is used to make targeted modifications to existing files. You can specify one or more blocks of text to find and replace. This is the preferred tool for making small changes to large files, as it avoids having to rewrite the entire file.",

      inputSchema: z.object({
        path: z
          .string()
          .describe(
            "The path of the file to modify (relative to the current working directory {{CWD}})"
          ),
        diff: z.string()
          .describe(`Use one or more SEARCH/REPLACE blocks to specify the changes.
  \`\`\`
  ------- SEARCH
  [The exact lines of code to find]
  =======
  [The new lines of code to replace them with]
  +++++++ REPLACE
  \`\`\`
  ### Guidelines for find_and_replace:
  *   **Exact Matches Only**: The content in the SEARCH block must be an *exact* character-for-character match of the content in the file, including indentation, whitespace, and line endings.
  *   **One Replacement per Block**: Each SEARCH/REPLACE block will only replace the *first* occurrence of the SEARCH content. To make multiple changes, use multiple SEARCH/REPLACE blocks.
  *   **Be Specific, but Concise**: Include enough lines in your SEARCH block to be unique, but avoid including long sections of unchanged code.
  *   **Ordering**: When using multiple blocks, they should be ordered as they appear in the file.
  *   **Inserting Code**: To insert new code, SEARCH for the line you want to insert before or after. In the REPLACE block, include the new code along with the original line from the SEARCH block.
  *   **Deleting Code**: To delete code, leave the REPLACE section empty.
  *   **Moving Code**: To move code, use two SEARCH/REPLACE blocks. First, a block to delete the code from its original location. Second, a block to insert the code in its new location.`),
      }),
    },
    async ({ path, diff }) => {
      try {
        let content = await manager.readFile(path);
        const originalContent = content;

        const blocks = diff.split("------- SEARCH").slice(1);

        for (let i = 0; i < blocks.length; i++) {
          const block = blocks[i];
          const parts = block.split("=======");
          const search = parts[0].trim();
          const replace = parts[1].split("+++++++ REPLACE")[0].trim();

          if (!content.includes(search)) {
            return `failed to find search term in block ${i + 1}: \n${search}`;
          }

          content = content.replace(search, replace);
        }

        if (content !== originalContent) {
          await manager.writeFile(path, content);
          return `successfully completed find_and_replace in ${path}`;
        } else {
          return `no changes made to ${path}`;
        }
      } catch (error) {
        return `failed to complete find_and_replace in ${path}: ${error.message}`;
      }
    }
  );

  ai.defineTool(
    {
      name: "read_file",
      description:
        "Reads the entire content of a file at a given path. Use this to inspect source code, configuration files, or any other text-based file. It can also extract text from PDF and DOCX documents. This tool is not for reading directory listings; use `list_files` for that purpose.",
      inputSchema: z.object({
        path: z
          .string()
          .describe(
            "The path of the file to read (relative to the current working directory {{CWD}})"
          ),
      }),
    },
    async ({ path }) => {
      try {
        return await manager.readFile(path);
      } catch (error) {
        return `failed to read file ${path}: ${error.message}`;
      }
    }
  );

  ai.defineTool(
    {
      name: "search_files",
      description:
        "Searches for a regex pattern within files in a given directory. It returns the matching lines along with surrounding lines for context. This is useful for finding code patterns, locating specific functions or variables, or tracking down where a piece of text is used.",
      inputSchema: z.object({
        path: z
          .string()
          .describe(
            "The path of the directory to search in (relative to the current working directory). This directory will be recursively searched."
          ),
        regex: z
          .string()
          .describe(
            "The regular expression pattern to search for. Uses Rust regex syntax."
          ),
        file_pattern: z
          .string()
          .optional()
          .describe(
            "Glob pattern to filter files (e.g., '*.ts' for TypeScript files). If not provided, it will search all files (*)."
          ),
      }),
    },
    async ({ path, regex, file_pattern }) => {
      try {
        return await manager.searchFiles(path, regex, file_pattern);
      } catch (error) {
        return `failed to search files: ${error.message}`;
      }
    }
  );

  ai.defineTool(
    {
      name: "list_files",
      description:
        "Lists the files and subdirectories within a specified directory. It can list recursively to include all nested files and directories, or just the top-level contents.",
      inputSchema: z.object({
        path: z
          .string()
          .describe(
            "The path of the directory to list contents for (relative to the current working directory)"
          ),
        recursive: z
          .boolean()
          .optional()
          .describe(
            "Whether to list files recursively. Use true for recursive listing, false or omit for top-level only."
          ),
      }),
    },
    async ({ path, recursive }) => {
      try {
        const files = await manager.listFiles(path, recursive);
        return files.join("\n");
      } catch (error) {
        return `failed to list files in ${path}: ${error.message}`;
      }
    }
  );

  ai.defineTool(
    {
      name: "write_to_file",
      description:
        "Writes content to a file. This will create the file if it doesn't exist, or completely overwrite it if it does. Any necessary parent directories will be created automatically. Use this for creating new files or for replacing the entire content of an existing file.",
      inputSchema: z.object({
        path: z
          .string()
          .describe(
            "The path of the file to write to (relative to the current working directory)"
          ),
        content: z
          .string()
          .describe(
            "The content to write to the file. ALWAYS provide the COMPLETE intended content of the file, without any truncation or omissions. You MUST include ALL parts of the file, even if they haven't been modified."
          ),
      }),
    },
    async ({ path, content }) => {
      try {
        await manager.writeFile(path, content);
        return `successfully wrote to ${path}`;
      } catch (error) {
        return `failed to write to ${path}: ${error.message}`;
      }
    }
  );
}
