"use client";

import { createContext, useContext, useMemo, useSyncExternalStore } from "react";
import { getPhone } from "@/data/phones";
import { createStorageStore } from "@/lib/storage-store";
import type { Phone } from "@/types/phone";

const MAX = 4;
const store = createStorageStore<string[]>("cepkiyas.compare.v1", []);

type CompareContextValue = {
  ids: string[];
  phones: Phone[];
  toggle: (id: string) => void;
  addMany: (incoming: string[]) => void;
  replace: (incoming: string[]) => void;
  remove: (id: string) => void;
  clear: () => void;
  has: (id: string) => boolean;
};

const CompareContext = createContext<CompareContextValue | null>(null);

export function CompareProvider({ children }: { children: React.ReactNode }) {
  const ids = useSyncExternalStore(store.subscribe, store.getSnapshot, store.getServerSnapshot);

  const value = useMemo<CompareContextValue>(() => {
    const phones = ids.map((id) => getPhone(id)).filter((phone): phone is Phone => Boolean(phone));
    return {
      ids,
      phones,
      toggle: (id) => {
        if (ids.includes(id)) store.set(ids.filter((item) => item !== id));
        else if (ids.length >= MAX) store.set([...ids.slice(1), id]);
        else store.set([...ids, id]);
      },
      addMany: (incoming) => {
        const next = [...ids];
        incoming.forEach((id) => {
          if (!next.includes(id) && next.length < MAX) next.push(id);
        });
        store.set(next);
      },
      replace: (incoming) => store.set(incoming.slice(0, MAX)),
      remove: (id) => store.set(ids.filter((item) => item !== id)),
      clear: () => store.set([]),
      has: (id) => ids.includes(id),
    };
  }, [ids]);

  return <CompareContext.Provider value={value}>{children}</CompareContext.Provider>;
}

export function useCompare() {
  const ctx = useContext(CompareContext);
  if (!ctx) throw new Error("useCompare must be used within CompareProvider");
  return ctx;
}
