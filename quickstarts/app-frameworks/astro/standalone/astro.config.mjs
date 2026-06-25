import { defineConfig } from 'astro/config';

// No server-side flow runs here — the page calls a standalone backend over HTTP,
// so static output is fine. Vite still bundles the inline <script> for the browser.
export default defineConfig({});
