import { EmojiFaceGenerator } from '@/components/emoji-face-generator';
import { PartyPopper } from 'lucide-react';

export default function Home() {
  return (
    <main className="flex min-h-screen w-full flex-col items-center justify-center p-4">
      <div className="flex flex-col items-center text-center mb-8">
        <h1 className="font-headline text-4xl md:text-5xl font-bold tracking-tight text-primary flex items-center gap-3">
          <PartyPopper className="h-10 w-10" />
          Emoji Face
        </h1>
        <p className="mt-2 text-lg text-muted-foreground max-w-md">
          Take a selfie, pick an emoji, and let AI work its magic to match your expression!
        </p>
      </div>
      <EmojiFaceGenerator />
    </main>
  );
}
