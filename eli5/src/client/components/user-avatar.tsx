import { useEffect, useState } from "react";
import { getItem } from "../lib/storage.js";

export function UserAvatar({ onEdit }: { onEdit: () => void }) {
  const [avatar, setAvatar] = useState<string | null>(null);

  useEffect(() => {
    async function getAvatar() {
      const storedAvatar = await getItem<string>("cartoon-selfie");
      if (storedAvatar) {
        setAvatar(storedAvatar);
      }
    }
    getAvatar();
  }, []);

  if (!avatar) {
    return null;
  }

  return (
    <div className="absolute top-4 right-4 cursor-pointer" onClick={onEdit}>
      <div
        className="w-16 h-16 rounded-full shadow-lg"
        style={{
          backgroundImage: `url(${avatar})`,
          backgroundSize: "300%",
          backgroundPosition: "top",
          imageRendering: "crisp-edges",
        }}
      />
    </div>
  );
}
