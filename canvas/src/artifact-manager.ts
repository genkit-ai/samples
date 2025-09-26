import { promises as fs } from "fs";
import { glob } from "glob";
import * as path from "path";

export interface ArtifactManager {
  readFile(path: string): Promise<string>;
  writeFile(path: string, content: string): Promise<void>;
  listFiles(path: string, recursive?: boolean): Promise<string[]>;
  searchFiles(
    path: string,
    regex: string,
    file_pattern?: string
  ): Promise<string>;
}

export interface FileSystemArtifactManagerOptions {
  rootDir?: string;
}

export class FileSystemArtifactManager implements ArtifactManager {
  private rootDir: string;

  constructor(options?: FileSystemArtifactManagerOptions) {
    this.rootDir = options?.rootDir || process.cwd();
  }

  private resolvePath(p: string): string {
    return path.join(this.rootDir, p);
  }

  async readFile(p: string): Promise<string> {
    return await fs.readFile(this.resolvePath(p), "utf-8");
  }

  async writeFile(p: string, content: string): Promise<void> {
    await fs.writeFile(this.resolvePath(p), content, "utf-8");
  }

  async listFiles(p: string, recursive?: boolean): Promise<string[]> {
    const files = await fs.readdir(this.resolvePath(p), {
      recursive: recursive || false,
      withFileTypes: true,
    });
    return files.map((f) => (f.isDirectory() ? `${f.name}/` : f.name));
  }

  async searchFiles(
    p: string,
    regex: string,
    file_pattern?: string
  ): Promise<string> {
    const searchPath = this.resolvePath(p);
    const files = await glob(`${searchPath}/**/${file_pattern || "*"}`);
    let results = "";

    for (const file of files) {
      try {
        const content = await fs.readFile(file, "utf-8");
        const lines = content.split("\n");
        const re = new RegExp(regex, "g");
        let match;
        while ((match = re.exec(content)) !== null) {
          const lineNum =
            content.substring(0, match.index).split("\n").length - 1;
          const start = Math.max(0, lineNum - 2);
          const end = Math.min(lines.length, lineNum + 3);
          const relativePath = path.relative(this.rootDir, file);
          results += `\n${relativePath}:${lineNum + 1}\n`;
          results += lines.slice(start, end).join("\n");
          results += "\n";
        }
      } catch (e) {
        // ignore files that can't be read
      }
    }
    return results.trim() || "no matches found";
  }
}

export class InMemoryArtifactManager implements ArtifactManager {
  private files: Map<string, string> = new Map();

  async readFile(path: string): Promise<string> {
    if (this.files.has(path)) {
      return this.files.get(path)!;
    }
    throw new Error(`File not found: ${path}`);
  }

  async writeFile(path: string, content: string): Promise<void> {
    this.files.set(path, content);
  }

  async listFiles(path: string, recursive?: boolean): Promise<string[]> {
    const allFiles = Array.from(this.files.keys());
    if (path === "" || path === "/") {
      return allFiles;
    }
    const filtered = allFiles.filter((p) => p.startsWith(path + "/"));
    if (recursive) {
      return filtered;
    }
    const result = new Set<string>();
    for (const p of filtered) {
      const relative = p.substring(path.length + 1);
      const parts = relative.split("/");
      result.add(parts.length > 1 ? `${parts[0]}/` : parts[0]);
    }
    return Array.from(result);
  }

  async searchFiles(
    path: string,
    regex: string,
    file_pattern?: string
  ): Promise<string> {
    let results = "";
    const re = new RegExp(regex, "g");

    for (const [filePath, content] of this.files.entries()) {
      if (!filePath.startsWith(path)) {
        continue;
      }
      // This is a very basic glob implementation.
      if (file_pattern && !filePath.endsWith(file_pattern.replace("*", ""))) {
        continue;
      }

      const lines = content.split("\n");
      let match;
      while ((match = re.exec(content)) !== null) {
        const lineNum =
          content.substring(0, match.index).split("\n").length - 1;
        const start = Math.max(0, lineNum - 2);
        const end = Math.min(lines.length, lineNum + 3);
        results += `\n${filePath}:${lineNum + 1}\n`;
        results += lines.slice(start, end).join("\n");
        results += "\n";
      }
    }
    return results.trim() || "no matches found";
  }
}
