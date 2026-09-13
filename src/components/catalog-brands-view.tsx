"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import type { BrandGroup } from "@/lib/catalog-grouping";
import { letterBuckets } from "@/lib/catalog-grouping";
import { formatPrice } from "@/lib/format";
import { technicalScore } from "@/lib/score";
import type { Phone } from "@/types/phone";

export function CatalogBrandsView({
  index,
  basePath,
  brandFilter,
  onBrandSelect,
}: {
  index: BrandGroup[];
  basePath: string;
  brandFilter: string | null;
  onBrandSelect: (brand: string | null) => void;
}) {
  const [query, setQuery] = useState("");
  const filtered = useMemo(() => {
    const q = query.trim().toLocaleLowerCase("tr-TR");
    if (!q) return index;
    return index.filter((group) => group.brand.toLocaleLowerCase("tr-TR").includes(q));
  }, [index, query]);

  const buckets = useMemo(() => letterBuckets(filtered), [filtered]);
  const focused = brandFilter ? index.find((g) => g.brand === brandFilter) : null;

  return (
    <div className="brand-directory">
      <div className="brand-directory-toolbar">
        <input
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="Marka ara…"
          aria-label="Marka ara"
        />
        {brandFilter ? (
          <button type="button" className="shop-chip-clear" onClick={() => onBrandSelect(null)}>
            Tüm markalar
          </button>
        ) : null}
      </div>

      {!focused ? (
        <div className="brand-directory-index">
          {buckets.map(([letter, groups]) => (
            <section key={letter} className="brand-letter-block">
              <h3>{letter}</h3>
              <div className="brand-card-grid">
                {groups.map((group) => (
                  <button
                    key={group.brand}
                    type="button"
                    className="brand-card"
                    onClick={() => onBrandSelect(group.brand)}
                  >
                    <strong>{group.brand}</strong>
                    <span>{group.count} model</span>
                    <small>{group.series.length} seri</small>
                  </button>
                ))}
              </div>
            </section>
          ))}
          {filtered.length === 0 ? <p className="mute empty-state">Eşleşen marka yok.</p> : null}
        </div>
      ) : (
        <BrandSeriesPanel group={focused} basePath={basePath} onBack={() => onBrandSelect(null)} />
      )}
    </div>
  );
}

function BrandSeriesPanel({
  group,
  basePath,
  onBack,
}: {
  group: BrandGroup;
  basePath: string;
  onBack: () => void;
}) {
  return (
    <div className="brand-series-panel">
      <div className="brand-series-head">
        <button type="button" className="ghost mini" onClick={onBack}>
          ← Markalar
        </button>
        <div>
          <h2>{group.brand}</h2>
          <p className="mute">
            {group.count} model · {group.series.length} seri
          </p>
        </div>
        <Link href={`${basePath}?gorunum=urunler&marka=${encodeURIComponent(group.brand)}`} className="btn">
          Tümünü listele
        </Link>
      </div>
      <div className="series-stack">
        {group.series.map((item) => (
          <section key={item.series} className="series-block">
            <div className="series-block-head">
              <h3>{item.series}</h3>
              <span className="mute">{item.count} varyant</span>
            </div>
            <ul className="series-model-list">
              {item.models.map((phone) => (
                <ModelRow key={phone.id} phone={phone} />
              ))}
            </ul>
          </section>
        ))}
      </div>
    </div>
  );
}

function ModelRow({ phone }: { phone: Phone }) {
  const score = technicalScore(phone);
  return (
    <li>
      <Link href={`/telefon/${phone.slug}`}>
        <span>
          <strong>{phone.name}</strong>
          <small>
            {phone.year}
            {phone.memory.ram ? ` · ${phone.memory.ram} GB RAM` : ""}
            {phone.memory.storage ? ` · ${phone.memory.storage} GB` : ""}
          </small>
        </span>
        <em>{formatPrice(phone.priceTRY)}</em>
        <b>{score.toFixed(1)}</b>
      </Link>
    </li>
  );
}
