"use client";

import { useState, useRef, useEffect, useCallback } from "react";
import Image from "next/image";
import { Camera, Download, RefreshCw, Wand2, Loader2, ArrowLeft } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { applyEmojiExpressionAction } from "@/app/actions";
import { useToast } from "@/hooks/use-toast";
import { cn } from "@/lib/utils";
import { Skeleton } from "@/components/ui/skeleton";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";

type Step = "capture" | "edit" | "generating" | "result";
type TransformationMode = 'silly' | 'realistic';

const EMOJI_CATEGORIES = {
  "People": ['😊', '😂', '😍', '🤔', '😎', '😢', '😠', '😮', '🥳', '🤯', '🤩', '😴', '🤤', '🤠', '😇', '🤡', '🤖', '👻', '💀', '👽', '🥰', '😘', '🤫', '🤨', '🤢', '🤮', '🤧', '🥵', '🥶', '🥴', '😵', '🥺', '😭', '😱', '🤪', '😬', '🙄', '😏', '🤐', '🤗', '🤓', '🤑', '😲', '😥', '😈', '👿', '👹', '👺', '💩'],
  "Animals": ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🐔', '🐧', '🐦', '🐤', '🐺', '🐗', '🐴', '🦄', '🐝', '🐛', '🦋', '🐌', '🐞', '🐜', '🦗', '🕷️', '🦂', '🐢', '🐍', '🦎', '🦖', '🦕', '🐙', '🦑', '🦐', '🦀', '🐡', '🐠', '🐟', '🐬', '🐳', '🐋', '🦈', '🐊', '🐅', '🐆', '🦓', '🦍', '🐘', '🦏', '🐪', '🐫', '🦒', '🐃', '🐂', '🐄', '🐎', '🐖', '🐏', '🐑', '🐐', '🦌', '🐕', '🐩', '🐈', '🐓', '🦃', '🕊️', '🐇', '🐁', '🐀', '🐿️', '🦔'],
  "Food": ['🍎', '🍌', '🍉', '🍇', '🍓', '🍑', '🍍', '🥥', '🥝', '🍅', '🍆', '🥑', '🥦', '🌶️', '🌽', '🥕', '🥐', '🍔', '🍕', '🍟', '🌭', '🍿', '🥨', '🥞', '🧇', '🧀', '🍖', '🍗', '🥩', '🥓', '🍩', '🍪', '🎂', '🍰', '🧁', '🥧', '🍫', '🍬', '🍭', '🍮', '🍯', '🍼', '🥛', '☕', '🍵', '🍶', '🍾', '🍷', '🍸', '🍹', '🍺', '🍻', '🥂', '🥃', '🥤', '🧃', '🧉', '🧊'],
  "Travel": ['🚗', '✈️', '🚀', '⛵️', '🏝️', '🌋', '🏞️', '🏠', '🗽', '🗼', '🏰', '🏯', '🏟️', '🗺️', '🌍', '🌎', '🌏', '🚂', '🚄', '🚅', '🚇', '🚈', '🚉', '🚊', '🚝', '🚞', '🚋', '🚌', '🚍', '🚎', '🚐', '🚑', '🚒', '🚓', '🚔', '🚕', '🚖', '🚚', '🚛', '🚜', '🚲', '🛵', '🏍️', '🛺', '🚁', '🚟', '🚠', '🚡', '🚢', '🚤', '🛥️', '🛳️', '⛴️', '⛽', '🚧', '🚦', '🚥'],
};

export function EmojiFaceGenerator() {
  const [step, setStep] = useState<Step>("capture");
  const [selfie, setSelfie] = useState<string | null>(null);
  const [modifiedSelfie, setModifiedSelfie] = useState<string | null>(null);
  const [selectedEmoji, setSelectedEmoji] = useState<string | null>(null);
  const [transformationMode, setTransformationMode] = useState<TransformationMode>('silly');
  const [isCameraReady, setIsCameraReady] = useState(false);
  const [cameraError, setCameraError] = useState<string | null>(null);

  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const { toast } = useToast();

  const startCamera = useCallback(async () => {
    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user' } });
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
          setIsCameraReady(true);
          setCameraError(null);
        }
      } catch (err) {
        console.error("Error accessing camera:", err);
        setCameraError("Could not access camera. Please check permissions and try again.");
        setIsCameraReady(false);
      }
    } else {
      setCameraError("Your browser does not support camera access.");
    }
  }, []);

  useEffect(() => {
    if (step === 'capture') {
      startCamera();
    }
    return () => {
      if (videoRef.current && videoRef.current.srcObject) {
        (videoRef.current.srcObject as MediaStream).getTracks().forEach(track => track.stop());
      }
    };
  }, [step, startCamera]);

  const takePicture = () => {
    const video = videoRef.current;
    const canvas = canvasRef.current;
    if (video && canvas && isCameraReady) {
      const context = canvas.getContext('2d');
      if (context) {
        const { videoWidth, videoHeight } = video;
        canvas.width = videoWidth;
        canvas.height = videoHeight;
        context.translate(videoWidth, 0);
        context.scale(-1, 1);
        context.drawImage(video, 0, 0, videoWidth, videoHeight);
        const data = canvas.toDataURL('image/png');
        setSelfie(data);
        setStep('edit');
      }
    }
  };

  const handleApplyExpression = async () => {
    if (!selfie || !selectedEmoji) return;

    setStep("generating");
    try {
      const result = await applyEmojiExpressionAction({
        selfieDataUri: selfie,
        emoji: selectedEmoji,
        transformationMode,
      });

      if ('error' in result) {
         toast({
            variant: "destructive",
            title: "Generation Failed",
            description: result.error,
          });
         setStep("edit");
      } else if(result.modifiedImageDataUri) {
        setModifiedSelfie(result.modifiedImageDataUri);
        setStep("result");
      } else {
        throw new Error("Invalid response from server.");
      }
    } catch (e) {
      console.error(e);
      toast({
        variant: "destructive",
        title: "An Error Occurred",
        description: "Something went wrong. Please try again.",
      });
      setStep("edit");
    }
  };

  const downloadImage = () => {
    if (!modifiedSelfie) return;
    const link = document.createElement('a');
    link.href = modifiedSelfie;
    link.download = `emoji-face-${selectedEmoji}.png`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };
  
  const resetAll = () => {
    setStep('capture');
    setSelfie(null);
    setModifiedSelfie(null);
    setSelectedEmoji(null);
  };

  const resetToEdit = () => {
    setStep('edit');
    setModifiedSelfie(null);
  }

  const renderCaptureStep = () => (
    <Card className="w-full max-w-lg overflow-hidden shadow-2xl">
      <CardHeader>
        <CardTitle>Take a Selfie</CardTitle>
        <CardDescription>Position your face in the frame and capture your picture.</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="aspect-square w-full rounded-lg bg-secondary flex items-center justify-center overflow-hidden border">
           {cameraError ? (
            <div className="text-center text-destructive p-4">
              <p>{cameraError}</p>
              <Button onClick={startCamera} className="mt-4">Try Again</Button>
            </div>
          ) : (
            <video
              ref={videoRef}
              autoPlay
              playsInline
              muted
              className={cn("h-full w-full object-cover scale-x-[-1]", isCameraReady ? 'opacity-100' : 'opacity-0')}
              onCanPlay={() => setIsCameraReady(true)}
            />
          )}
          {!isCameraReady && !cameraError && <Loader2 className="h-12 w-12 animate-spin text-primary" />}
        </div>
        <canvas ref={canvasRef} className="hidden" />
      </CardContent>
      <CardFooter>
        <Button onClick={takePicture} disabled={!isCameraReady} className="w-full" size="lg">
          <Camera className="mr-2 h-5 w-5" />
          Take Picture
        </Button>
      </CardFooter>
    </Card>
  );

  const renderEditStep = () => (
    <Card className="w-full max-w-lg overflow-hidden shadow-2xl">
      <CardHeader>
        <CardTitle>Customize Your Emoji Face</CardTitle>
        <CardDescription>Choose an emoji and a transformation style.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        {selfie && (
          <div className="aspect-square w-full rounded-lg bg-secondary overflow-hidden border">
            <Image src={selfie} alt="Your selfie" width={500} height={500} className="h-full w-full object-cover" />
          </div>
        )}
        <div className="space-y-4">
          <Label className="font-medium">Transformation Style</Label>
          <RadioGroup
            value={transformationMode}
            onValueChange={(value: string) => setTransformationMode(value as TransformationMode)}
            className="grid grid-cols-2 gap-4"
          >
            <div>
              <RadioGroupItem value="silly" id="silly" className="peer sr-only" />
              <Label
                htmlFor="silly"
                className="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-popover p-4 hover:bg-accent hover:text-accent-foreground peer-data-[state=checked]:border-primary [&:has([data-state=checked])]:border-primary"
              >
                🤪 Silly
                <span className="text-xs text-center mt-1 text-muted-foreground">Maximum creativity, expect wild results.</span>
              </Label>
            </div>
            <div>
              <RadioGroupItem value="realistic" id="realistic" className="peer sr-only" />
              <Label
                htmlFor="realistic"
                className="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-popover p-4 hover:bg-accent hover:text-accent-foreground peer-data-[state=checked]:border-primary [&:has([data-state=checked])]:border-primary"
              >
                🙂 Realistic
                 <span className="text-xs text-center mt-1 text-muted-foreground">Subtle changes, keeps your original face.</span>
              </Label>
            </div>
          </RadioGroup>
        </div>
        <div className="space-y-2">
            <Label className="font-medium">Pick an Emoji</Label>
            <Tabs defaultValue={Object.keys(EMOJI_CATEGORIES)[0]} className="w-full">
            <TabsList className="grid w-full grid-cols-4 h-auto">
                {Object.keys(EMOJI_CATEGORIES).map(category => (
                <TabsTrigger key={category} value={category} className="text-xs md:text-sm">{category}</TabsTrigger>
                ))}
            </TabsList>
            {Object.entries(EMOJI_CATEGORIES).map(([category, emojis]) => (
                <TabsContent key={category} value={category}>
                <div className="grid grid-cols-5 md:grid-cols-7 gap-2 pt-4 max-h-48 overflow-y-auto">
                    {emojis.map((emoji, index) => (
                    <Button
                        key={`${emoji}-${index}`}
                        variant={selectedEmoji === emoji ? 'default' : 'secondary'}
                        onClick={() => setSelectedEmoji(emoji)}
                        className="text-2xl aspect-square h-auto w-auto transition-transform duration-200 hover:scale-110"
                        aria-label={`Select emoji ${emoji}`}
                    >
                        {emoji}
                    </Button>
                    ))}
                </div>
                </TabsContent>
            ))}
            </Tabs>
        </div>
      </CardContent>
      <CardFooter className="grid grid-cols-2 gap-4">
        <Button onClick={resetAll} variant="outline">
          <ArrowLeft className="mr-2 h-5 w-5" />
          Retake
        </Button>
        <Button onClick={handleApplyExpression} disabled={!selectedEmoji} size="lg" className="bg-accent hover:bg-accent/90 text-accent-foreground">
          <Wand2 className="mr-2 h-5 w-5" />
          Apply Expression
        </Button>
      </CardFooter>
    </Card>
  );

 const renderGeneratingStep = () => (
    <Card className="w-full max-w-lg overflow-hidden shadow-2xl">
      <CardHeader className="text-center">
        <CardTitle>Applying Expression...</CardTitle>
        <CardDescription>Our AI is working its magic. Please wait a moment.</CardDescription>
      </CardHeader>
      <CardContent className="grid grid-cols-1 md:grid-cols-2 gap-4 items-center">
          <div className="aspect-square w-full rounded-lg bg-secondary overflow-hidden border">
             {selfie && <Image src={selfie} alt="Your selfie" width={500} height={500} className="h-full w-full object-cover" />}
          </div>
          <div className="aspect-square w-full rounded-lg bg-secondary overflow-hidden border flex items-center justify-center">
            <div className="flex flex-col items-center gap-4 text-primary">
              <div className="text-6xl">{selectedEmoji}</div>
              <Loader2 className="h-16 w-16 animate-spin" />
            </div>
          </div>
      </CardContent>
    </Card>
  );

  const renderResultStep = () => (
    <Card className="w-full max-w-xl overflow-hidden shadow-2xl">
      <CardHeader>
        <CardTitle>Here's Your Emoji Face!</CardTitle>
        <CardDescription>Your selfie now has the expression of {selectedEmoji}.</CardDescription>
      </CardHeader>
      <CardContent className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="space-y-2">
            <h3 className="text-center font-medium text-muted-foreground">Original</h3>
            <div className="aspect-square w-full rounded-lg bg-secondary overflow-hidden border">
                {selfie && <Image src={selfie} alt="Your selfie" width={500} height={500} className="h-full w-full object-cover" />}
            </div>
        </div>
        <div className="space-y-2">
            <h3 className="text-center font-medium text-muted-foreground">Emoji-fied {selectedEmoji}</h3>
            <div className="aspect-square w-full rounded-lg bg-secondary overflow-hidden border">
                {modifiedSelfie ? <Image src={modifiedSelfie} alt="Modified selfie" width={500} height={500} className="h-full w-full object-cover" /> : <Skeleton className="h-full w-full" />}
            </div>
        </div>
      </CardContent>
      <CardFooter className="grid grid-cols-2 md:grid-cols-3 gap-4">
        <Button onClick={resetToEdit} variant="outline">
          <RefreshCw className="mr-2 h-5 w-5" />
          Try Another
        </Button>
        <Button onClick={downloadImage} className="md:col-span-1">
          <Download className="mr-2 h-5 w-5" />
          Download
        </Button>
         <Button onClick={resetAll} variant="secondary" className="col-span-2 md:col-span-1">
          Start Over
        </Button>
      </CardFooter>
    </Card>
  );

  switch (step) {
    case 'capture':
      return renderCaptureStep();
    case 'edit':
      return renderEditStep();
    case 'generating':
      return renderGeneratingStep();
    case 'result':
      return renderResultStep();
    default:
      return renderCaptureStep();
  }
}
