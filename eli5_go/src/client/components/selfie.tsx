import { runFlow } from "genkit/beta/client";
import { useEffect, useRef, useState } from "react";
import { CameraIcon, FileIcon } from "./icons.js";
import { getItem, setItem } from "../lib/storage.js";
import { Loader } from "./loader.js";

function CameraView({
  onCapture,
  onCancel,
}: {
  onCapture: (dataUri: string) => void;
  onCancel: () => void;
}) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [stream, setStream] = useState<MediaStream | null>(null);

  useState(() => {
    async function setupCamera() {
      try {
        const mediaStream = await navigator.mediaDevices.getUserMedia({
          video: true,
        });
        setStream(mediaStream);
        if (videoRef.current) {
          videoRef.current.srcObject = mediaStream;
        }
      } catch (error) {
        console.error("Error accessing camera:", error);
      }
    }
    setupCamera();

    return () => {
      stream?.getTracks().forEach((track) => track.stop());
    };
  });

  const handleCapture = () => {
    if (videoRef.current) {
      const canvas = document.createElement("canvas");
      canvas.width = videoRef.current.videoWidth;
      canvas.height = videoRef.current.videoHeight;
      const context = canvas.getContext("2d");
      context?.drawImage(videoRef.current, 0, 0, canvas.width, canvas.height);
      const dataUri = canvas.toDataURL("image/png");
      onCapture(dataUri);
    }
  };

  return (
    <div>
      <video
        ref={videoRef}
        autoPlay
        playsInline
        className="rounded-lg shadow-lg"
      />
      <div className="grid grid-cols-2 gap-4 mt-4">
        <button
          type="button"
          onClick={handleCapture}
          className="bg-brand-primary hover:bg-brand-primary/90 text-white font-bold py-3 px-4 rounded-lg"
        >
          Take Selfie
        </button>
        <button
          type="button"
          onClick={onCancel}
          className="bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-3 px-4 rounded-lg"
        >
          Cancel
        </button>
      </div>
    </div>
  );
}

export function Selfie({ onSelfieTaken }: { onSelfieTaken: () => void }) {
  const url = "";
  const [loading, setLoading] = useState(false);
  const [previewImage, setPreviewImage] = useState<string | null>(null);
  const [showCamera, setShowCamera] = useState(false);
  const [existingSelfie, setExistingSelfie] = useState<string | null>(null);

  useEffect(() => {
    async function checkExistingSelfie() {
      const storedSelfie = await getItem<string>("cartoon-selfie");
      if (storedSelfie) {
        setExistingSelfie(storedSelfie);
        setPreviewImage(storedSelfie);
      }
    }
    checkExistingSelfie();
  }, []);

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        setPreviewImage(e.target?.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const cartoonifyAndStore = async () => {
    if (!previewImage) return;
    setLoading(true);
    try {
      const result = await runFlow({
        url: `${url}/api/cartoonify`,
        input: { image: previewImage },
      });
      await setItem("cartoon-selfie", result);
      onSelfieTaken();
    } catch (error) {
      console.error("Error cartoonifying image:", error);
    } finally {
      setLoading(false);
    }
  };

  const reset = () => {
    setPreviewImage(null);
    setShowCamera(false);
  };

  if (showCamera) {
    return (
      <CameraView
        onCapture={(dataUri) => {
          setPreviewImage(dataUri);
          setShowCamera(false);
        }}
        onCancel={reset}
      />
    );
  }

  return (
    <div className="w-full max-w-md mx-auto">
      <div className="bg-surface rounded-lg shadow-sm overflow-hidden">
        <div className="p-6">
          <h2 className="text-2xl font-bold text-center mb-4 text-foreground">
            {previewImage
              ? loading
                ? "Cartoonifying..."
                : "Is this you?"
              : "First, a Selfie!"}
          </h2>
          {loading ? (
            <div className="p-10 flex justify-center">
              <Loader />
            </div>
          ) : previewImage ? (
            <div>
              <img
                src={previewImage}
                alt="Your selfie"
                className="rounded-lg shadow-lg"
              />
              <div className="grid grid-cols-2 gap-4 mt-4">
                <button
                  type="button"
                  onClick={
                    existingSelfie && previewImage === existingSelfie
                      ? onSelfieTaken
                      : cartoonifyAndStore
                  }
                  className="bg-brand-primary hover:bg-brand-primary/90 text-white font-bold py-3 px-4 rounded-lg"
                >
                  {existingSelfie && previewImage === existingSelfie
                    ? "Done"
                    : "Looks Good!"}
                </button>
                <button
                  type="button"
                  onClick={reset}
                  className="bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-3 px-4 rounded-lg"
                >
                  {existingSelfie ? "Change Selfie" : "Try Again"}
                </button>
              </div>
            </div>
          ) : (
            <div className="grid grid-cols-2 gap-4">
              <div>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleFileChange}
                  className="hidden"
                  id="file-upload"
                />
                <label
                  htmlFor="file-upload"
                  className="bg-brand-secondary hover:bg-brand-secondary/90 text-white font-bold py-3 px-4 rounded-lg flex flex-col items-center justify-center cursor-pointer"
                >
                  <FileIcon className="w-8 h-8 mb-2" />
                  <span>Upload a File</span>
                </label>
              </div>
              <button
                type="button"
                onClick={() => setShowCamera(true)}
                className="bg-brand-accent hover:bg-brand-accent/90 text-white font-bold py-3 px-4 rounded-lg flex flex-col items-center justify-center"
              >
                <CameraIcon className="w-8 h-8 mb-2" />
                <span>Take a Picture</span>
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
