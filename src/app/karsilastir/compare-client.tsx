"use client";

import { useEffect, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { phones } from "@/data/phones";
import { CompareTable } from "@/components/compare-table";
import { PhoneVisual } from "@/components/phone-visual";
import { useCompare } from "@/context/compare-context";

export function CompareClient() {
  const params = useSearchParams();
  const { phones: selected, toggle, has, replace } = useCompare();
  const [query, setQuery] = useState("");

  useEffect(() => {
    const fromUrl = params.get("p")?.split(",").filter(Boolean) ?? [];
    const ids = fromUrl
      .map((slug) => phones.find((item) => item.slug === slug)?.id)
      .filter((id): id is string => Boolean(id));
    if (ids.length) replace(ids);
    // hydrate once from URL
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const suggestions = useMemo(() => {
    const q = query.trim().toLocaleLowerCase("tr-TR");
    return phones
      .filter((phone) => !has(phone.id))
      .filter((phone) =>
        q ? `${phone.fullName} ${phone.brand}`.toLocaleLowerCase("tr-TR").includes(q) : true,
      )
      .slice(0, 9);
  }, [query, has]);

  return (
    <div className="shell">
      <div className="section-head" style={{ marginTop: 0 }}>
        <div>
          <h2>Yan yana kıyas</h2>
          <p className="mute">
            En fazla 4 model. Satır kazananı yeşil; fiyat ve kalınlık gibi ölçütlerde düşük değer kazanır.
          </p>
        </div>
      </div>

      <div className="picker">
        <input
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="Kıyasa model ekle…"
        />
        <div className="picker-list">
          {suggestions.map((phone) => (
            <button key={phone.id} type="button" className="picker-item" onClick={() => toggle(phone.id)}>
              <PhoneVisual phone={phone} size="sm" />
              <span>
                <strong>{phone.name}</strong>
                <small className="mute">{phone.brand}</small>
              </span>
            </button>
          ))}
        </div>
      </div>

      {selected.length >= 2 ? (
        <CompareTable phones={selected} />
      ) : (
        <div className="empty-state">Kıyas tablosu için en az iki telefon seçin.</div>
      )}
    </div>
  );
}
