import { create } from 'zustand';

const goBackend = 'http://localhost:3001';
const jsBackend = '';

interface BackendState {
  name: 'go' | 'js';
  url: string;
  toggleBackend: () => void;
}

export const useBackend = create<BackendState>((set) => ({
  name: 'js',
  url: jsBackend,
  toggleBackend: () =>
    set((state) =>
      state.name === 'go'
        ? { name: 'js', url: jsBackend }
        : { name: 'go', url: goBackend }
    ),
}));
