export interface Page {
  text: string;
  illustration: string;
}

export interface Storybook {
  status?: string;
  bookTitle?: string;
  pages?: Page[];
}
