import './globals.css';

export const metadata = {
  title: 'Bargain Chef',
  description: 'Genkit Next.js App Router quickstart',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
