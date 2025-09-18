import type { Storybook } from "../../ai/flows/storify.js";
import { X } from "lucide-react";
import { Loader } from "./loader.js";

interface Page {
  text: string;
  illustration: string;
}

export function Story({
  storybook,
  loading,
  onClose,
}: {
  storybook: Storybook & { illustrations?: (string | null)[] };
  loading: boolean;
  onClose: () => void;
}) {
  const pages = storybook.pages || [];
  const title = storybook.bookTitle;

  console.log("[Story.tsx] Rendering with:", {
    loading,
    status: storybook.status,
    pagesLength: pages.length,
  });

  return (
    <div className="fixed inset-0 bg-gradient-to-tr from-purple-100 to-teal-100 font-sans">
      {title && (
        <div className="sticky top-0 z-10 bg-gradient-to-br from-purple-600 to-indigo-800 text-white shadow-md">
          <div className="flex items-center p-2 px-4">
            <div className="font-bold text-lg">ELI5</div>
            <h1 className="flex-1 text-xl font-bold text-center whitespace-nowrap overflow-hidden text-ellipsis">
              {title}
            </h1>
            <div className="flex justify-end">
              <button
                onClick={onClose}
                className="p-1 rounded-full hover:bg-white/20"
              >
                <X size={24} />
              </button>
            </div>
          </div>
        </div>
      )}
      {loading && !pages.length && (
        <div className="fixed inset-0 z-20 flex flex-col items-center justify-center bg-background/80 backdrop-blur-sm">
          <Loader />
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
              className="snap-start w-screen h-[calc(100vh-90px)] flex flex-col items-center justify-center p-4 sm:p-8"
            >
              <div className="bg-white/90 backdrop-blur-lg rounded-xl shadow-2xl p-6 sm:p-8 lg:p-12 max-w-4xl w-full">
                <div className="w-full aspect-video flex items-center justify-center mb-6">
                  {illustration ? (
                    <img
                      src={illustration}
                      alt={`Illustration for: ${page.text}`}
                      className="w-full h-full object-contain rounded-lg"
                    />
                  ) : (
                    <div className="w-full h-full rounded-lg cool-shimmer-loader flex items-center justify-center">
                      <div className="text-gray-500 z-10">
                        Generating illustration...
                      </div>
                    </div>
                  )}
                </div>
                <div className="text-lg text-justify">{page.text}</div>
              </div>
            </div>
          );
        })}
        <div className="h-64"></div>
      </div>
    </div>
  );
}
