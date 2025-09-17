import { useEffect, useState } from "react";

export function UserAvatar() {
  const [avatar, setAvatar] = useState<string | null>(null);

  useEffect(() => {
    const storedAvatar = localStorage.getItem("cartoon-selfie");
    if (storedAvatar) {
      setAvatar(storedAvatar);
    }
  }, []);

  if (!avatar) {
    return null;
  }

  return (
    <div className="absolute top-4 right-4">
      <img src={avatar} alt="Your cartoon selfie" className="w-16 h-16 rounded-full shadow-lg" />
    </div>
  );
}
