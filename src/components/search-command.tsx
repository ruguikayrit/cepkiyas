"use client";

import Link from "next/link";
import { useEffect, useMemo, useRef, useState } from "react";
import { officialPhones, phones } from "@/data/phones";
import { PhoneVisual } from "@/components/phone-visual";
import { formatPrice } from "@/lib/format";
import { technicalScore } from "@/lib/score";

export function SearchCommand({
  open,
  onClose,
}: {
  open: boolean;
  onClose: () => void;
}) {
  const [query, setQuery] = useState("");
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (!open) return;
    const t = window.setTimeout(() => inputRef.current?.focus(), 20);
    return () => window.clearTimeout(t);
  }, [open]);

  useEffect(() => {
    if (!open) return;
    const onKey = (event: KeyboardEvent) => {
      if (event.key === "Escape") onClose();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open, onClose]);

  const results = useMemo(() => {
    const q = query.trim().toLocaleLowerCase("tr-TR");
    const list = q
      ? phones.filter((phone) =>
          `${phone.fullName} ${phone.performance.chipset} ${phone.os}`
            .toLocaleLowerCase("tr-TR")
            .includes(q),
        )
      : officialPhones.slice(0, 8);
    return list.slice(0, 8);
  }, [query]);

  if (!open) return null;

  return (
    <div className="search-overlay" onClick={onClose}>
      <div className="search-panel" onClick={(event) => event.stopPropagation()}>
        <input
          ref={inputRef}
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="iPhone, S25 Ultra, Snapdragon 8 Elite…"
        />
        <ul>
          {results.map((phone) => (
            <li key={phone.id}>
              <Link href={`/telefon/${phone.slug}`} onClick={onClose}>
                <PhoneVisual phone={phone} size="sm" />
                <span>
                  <strong>{phone.fullName}</strong>
                  <small>
                    {phone.performance.chipset} · {formatPrice(phone.priceTRY)}
                  </small>
                </span>
                <em>{technicalScore(phone).toFixed(1)}</em>
              </Link>
            </li>
          ))}
          {results.length === 0 ? <li className="empty">Eşleşen model yok.</li> : null}
        </ul>
      </div>
    </div>
  );
}
