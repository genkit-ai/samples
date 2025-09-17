import type { Storybook } from "../../ai/flows/storify.js";

interface Page {
  text: string;
  illustration: string;
}

export function Story({
  storybook,
  loading,
}: {
  storybook: Storybook & { illustrations?: (string | null)[] };
  loading: boolean;
}) {
  const pages = storybook.pages || [];
  const title = storybook.bookTitle;

  return (
    <div className="fixed inset-0 bg-background font-sans">
      {title && (
        <div className="sticky top-0 bg-background/80 backdrop-blur-sm z-10 py-4">
          <h1 className="text-3xl font-bold text-center">{title}</h1>
        </div>
      )}
      {loading && !pages.length && (
        <div className="fixed inset-0 z-20 flex flex-col items-center justify-center bg-background/80 backdrop-blur-sm">
          <div className="h-12 w-12 animate-spin rounded-full border-b-2 border-current" />
          <div className="mt-4 text-lg">
            {storybook.status || "Preparing to research..."}
          </div>
        </div>
      )}
      <div className="snap-y snap-mandatory h-screen overflow-y-scroll">
        {pages.map((page: Page, i: number) => {
          const illustration = storybook.illustrations?.[i];
          return (
            <div
              key={i}
              className="snap-start w-screen h-screen flex flex-col items-center justify-center"
            >
              <div className="w-full max-w-xl h-1/2 flex items-center justify-center">
                {illustration ? (
                  <img
                    src={illustration}
                    alt={`Illustration for: ${page.text}`}
                    className="w-full h-full object-contain rounded-lg"
                  />
                ) : (
                  <div className="text-gray-400">
                    Generating illustration...
                  </div>
                )}
              </div>
              <div className="mt-4 text-lg text-justify max-w-xl px-4">
                {page.text}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
