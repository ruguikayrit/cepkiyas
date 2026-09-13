"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useRef, useState } from "react";
import { brands, officialPhones, phones } from "@/data/phones";
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
  const router = useRouter();
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

  const q = query.trim().toLocaleLowerCase("tr-TR");

  const brandHits = useMemo(() => {
    if (!q) return [];
    return brands.filter((brand) => brand.toLocaleLowerCase("tr-TR").includes(q)).slice(0, 6);
  }, [q]);

  const results = useMemo(() => {
    const list = q
      ? phones.filter((phone) =>
          `${phone.fullName} ${phone.brand} ${phone.performance.chipset} ${phone.os}`
            .toLocaleLowerCase("tr-TR")
            .includes(q),
        )
      : officialPhones.slice(0, 8);
    return { items: list.slice(0, 10), total: list.length };
  }, [q]);

  const goCatalog = () => {
    const href = q ? `/katalog/telefon?q=${encodeURIComponent(query.trim())}` : "/katalog/telefon";
    router.push(href);
    onClose();
  };

  if (!open) return null;

  return (
    <div className="search-overlay" onClick={onClose}>
      <div className="search-panel" onClick={(event) => event.stopPropagation()}>
        <form
          onSubmit={(event) => {
            event.preventDefault();
            goCatalog();
          }}
        >
          <input
            ref={inputRef}
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Ürün, marka veya model ara"
            autoComplete="off"
          />
        </form>
        {brandHits.length ? (
          <div className="search-brands">
            {brandHits.map((brand) => (
              <Link
                key={brand}
                href={`/katalog/telefon?gorunum=markalar&marka=${encodeURIComponent(brand)}`}
                onClick={onClose}
              >
                {brand}
              </Link>
            ))}
          </div>
        ) : null}
        <ul>
          {results.items.map((phone) => (
            <li key={phone.id}>
              <Link href={`/telefon/${phone.slug}`} onClick={onClose}>
                <PhoneVisual phone={phone} size="sm" />
                <span>
                  <strong>{phone.fullName}</strong>
                  <small>
                    {phone.brand}
                    {phone.performance.chipset ? ` · ${phone.performance.chipset}` : ""}
                    {` · ${formatPrice(phone.priceTRY)}`}
                  </small>
                </span>
                <em>{technicalScore(phone).toFixed(1)}</em>
              </Link>
            </li>
          ))}
          {results.items.length === 0 ? <li className="empty">Eşleşen ürün yok.</li> : null}
        </ul>
        {q ? (
          <button type="button" className="search-all" onClick={goCatalog}>
            Tüm sonuçları gör{results.total ? ` (${results.total})` : ""}
          </button>
        ) : null}
      </div>
    </div>
  );
}
