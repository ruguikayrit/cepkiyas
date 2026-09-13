"use client";

import { createContext, useContext, useMemo, useSyncExternalStore } from "react";
import { phones } from "@/data/phones";
import { mergedUserScore, RATING_KEY } from "@/lib/ratings";
import { createStorageStore } from "@/lib/storage-store";
import type { Phone, UserVote } from "@/types/phone";

const store = createStorageStore<Record<string, UserVote>>(RATING_KEY, {});

type RatingsContextValue = {
  votes: Record<string, UserVote>;
  setVote: (phoneId: string, vote: UserVote) => void;
  scoreOf: (phone: Phone) => ReturnType<typeof mergedUserScore>;
  averages: Record<string, number>;
};

const RatingsContext = createContext<RatingsContextValue | null>(null);

export function RatingsProvider({ children }: { children: React.ReactNode }) {
  const votes = useSyncExternalStore(store.subscribe, store.getSnapshot, store.getServerSnapshot);

  const value = useMemo<RatingsContextValue>(() => {
    const averages = Object.fromEntries(
      phones.map((phone) => [phone.id, mergedUserScore(phone, votes[phone.id]).average]),
    );

    return {
      votes,
      setVote: (phoneId, vote) => store.set({ ...votes, [phoneId]: vote }),
      scoreOf: (phone) => mergedUserScore(phone, votes[phone.id]),
      averages,
    };
  }, [votes]);

  return <RatingsContext.Provider value={value}>{children}</RatingsContext.Provider>;
}

export function useRatings() {
  const ctx = useContext(RatingsContext);
  if (!ctx) throw new Error("useRatings must be used within RatingsProvider");
  return ctx;
}
