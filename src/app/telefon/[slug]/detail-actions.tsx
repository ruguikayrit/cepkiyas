"use client";

import { useCompare } from "@/context/compare-context";

export function DetailActions({ id }: { id: string }) {
  const { toggle, has } = useCompare();
  const selected = has(id);

  return (
    <div style={{ marginTop: 16 }}>
      <button type="button" className={selected ? "chip active" : "btn"} onClick={() => toggle(id)}>
        {selected ? "Kıyastan çıkar" : "Kıyasa ekle"}
      </button>
    </div>
  );
}
