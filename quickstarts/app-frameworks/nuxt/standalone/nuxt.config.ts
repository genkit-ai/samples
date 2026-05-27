export default defineNuxtConfig({
  compatibilityDate: '2025-01-01',
  devtools: { enabled: true },
  runtimeConfig: {
    public: {
      bargainChefUrl: 'http://localhost:8080/bargainChefFlow',
    },
  },
});
