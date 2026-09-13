"use client";

import { CompareProvider } from "@/context/compare-context";
import { RatingsProvider } from "@/context/ratings-context";
import { CompareTray } from "@/components/compare-tray";

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <RatingsProvider>
      <CompareProvider>
        {children}
        <CompareTray />
      </CompareProvider>
    </RatingsProvider>
  );
}
