"use client";

import { useState } from "react";
import { brands, years } from "@/data/phones";
import type { CatalogFilters } from "@/lib/filters";
import { formatPrice } from "@/lib/format";
import type { SortKey } from "@/types/phone";

const sorts: { id: SortKey; label: string }[] = [
  { id: "smart", label: "Akıllı sıralama" },
  { id: "technical", label: "Teknik puan" },
  { id: "user", label: "Kullanıcı puanı" },
  { id: "popular", label: "Popülerlik" },
  { id: "newest", label: "Yeniden eskiye" },
  { id: "price-asc", label: "En düşük fiyat" },
  { id: "price-desc", label: "En yüksek fiyat" },
  { id: "name", label: "Ada göre" },
];

export function FiltersPanel({
  filters,
  priceMax,
  onChange,
}: {
  filters: CatalogFilters;
  priceMax: number;
  onChange: (next: CatalogFilters) => void;
}) {
  const [brandQuery, setBrandQuery] = useState("");
  const visibleBrands = brands.filter((brand) =>
    brand.toLocaleLowerCase("tr-TR").includes(brandQuery.trim().toLocaleLowerCase("tr-TR")),
  );

  const toggle = (key: "brands" | "years" | "os", value: string | number) => {
    const current = filters[key] as Array<string | number>;
    const next = current.includes(value)
      ? current.filter((item) => item !== value)
      : [...current, value];
    onChange({ ...filters, [key]: next });
  };

  return (
    <aside className="filters">
      <label className="field">
        <span>Katalogda ara</span>
        <input
          value={filters.query}
          onChange={(event) => onChange({ ...filters, query: event.target.value })}
          placeholder="Model, yonga, sistem…"
        />
      </label>

      <label className="field">
        <span>Sırala</span>
        <select
          value={filters.sort}
          onChange={(event) => onChange({ ...filters, sort: event.target.value as SortKey })}
        >
          {sorts.map((sort) => (
            <option key={sort.id} value={sort.id}>
              {sort.label}
            </option>
          ))}
        </select>
      </label>

      <fieldset className="brand-field">
        <legend>Marka ({brands.length})</legend>
        <input
          className="brand-search"
          value={brandQuery}
          onChange={(event) => setBrandQuery(event.target.value)}
          placeholder="Marka ara…"
        />
        <div className="brand-list">
          {visibleBrands.map((brand) => (
            <label key={brand} className="check">
              <input
                type="checkbox"
                checked={filters.brands.includes(brand)}
                onChange={() => toggle("brands", brand)}
              />
              {brand}
            </label>
          ))}
        </div>
      </fieldset>

      <fieldset>
        <legend>Yıl</legend>
        {years.map((year) => (
          <label key={year} className="check">
            <input
              type="checkbox"
              checked={filters.years.includes(year)}
              onChange={() => toggle("years", year)}
            />
            {year}
          </label>
        ))}
      </fieldset>

      <fieldset>
        <legend>Sistem</legend>
        {["iOS", "Android", "HarmonyOS"].map((os) => (
          <label key={os} className="check">
            <input type="checkbox" checked={filters.os.includes(os)} onChange={() => toggle("os", os)} />
            {os}
          </label>
        ))}
      </fieldset>

      <label className="field">
        <span>Fiyat · {formatPrice(filters.maxPrice)}</span>
        <input
          type="range"
          min={0}
          max={priceMax}
          step={1000}
          value={filters.maxPrice}
          onChange={(event) => onChange({ ...filters, maxPrice: Number(event.target.value) })}
        />
      </label>

      <label className="field">
        <span>Min. RAM</span>
        <select
          value={filters.minRam}
          onChange={(event) => onChange({ ...filters, minRam: Number(event.target.value) })}
        >
          {[0, 8, 12, 16].map((ram) => (
            <option key={ram} value={ram}>
              {ram === 0 ? "Tümü" : `${ram} GB+`}
            </option>
          ))}
        </select>
      </label>

      <label className="field">
        <span>Min. depolama</span>
        <select
          value={filters.minStorage}
          onChange={(event) => onChange({ ...filters, minStorage: Number(event.target.value) })}
        >
          {[0, 128, 256, 512].map((storage) => (
            <option key={storage} value={storage}>
              {storage === 0 ? "Tümü" : `${storage} GB+`}
            </option>
          ))}
        </select>
      </label>

      <label className="check">
        <input
          type="checkbox"
          checked={filters.only5g}
          onChange={(event) => onChange({ ...filters, only5g: event.target.checked })}
        />
        Yalnızca 5G
      </label>
      <label className="check">
        <input
          type="checkbox"
          checked={filters.foldable}
          onChange={(event) => onChange({ ...filters, foldable: event.target.checked })}
        />
        Katlanır
      </label>
    </aside>
  );
}
