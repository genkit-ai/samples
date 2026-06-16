import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    // Port for the Vite development frontend server
    port: 5173,
    watch: {
      // Ignore Genkit trace files to prevent infinite Vite reload loops
      ignored: ['**/.genkit/**/*'],
    },
    // Proxy configuration to forward API calls to the Express backend
    proxy: {
      '/api': {
        // Target is the backend Express server port
        target: 'http://127.0.0.1:' + (process.env.PORT || 3000),
        changeOrigin: true,
        secure: false,
      },
    },
  },
});
