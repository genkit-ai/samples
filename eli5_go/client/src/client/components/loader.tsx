import React from "react";

export interface LoaderProps {
  baseColor?: string;
  highlightColor?: string;
}

export function Loader({
  baseColor = "#ddccff",
  highlightColor = "#66aacc",
}: LoaderProps) {
  const style = {
    "--loader-base-color": baseColor,
    "--loader-highlight-color": highlightColor,
  } as React.CSSProperties;

  return <div className="loader" style={style} />;
}
