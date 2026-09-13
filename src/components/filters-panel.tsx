"use client";

import { useMemo, useState, type ReactNode } from "react";
import { brands, phones as catalog, years } from "@/data/phones";
import { countBy, isFilterActive, type CatalogFilters } from "@/lib/filters";
import { formatPrice } from "@/lib/format";

export function FiltersPanel({
  filters,
  priceMax,
  onChange,
  onClear,
}: {
  filters: CatalogFilters;
  priceMax: number;
  onChange: (next: CatalogFilters) => void;
  onClear: () => void;
}) {
  const [brandQuery, setBrandQuery] = useState("");
  const brandCounts = useMemo(() => countBy(catalog, (phone) => phone.brand), []);
  const yearCounts = useMemo(() => countBy(catalog, (phone) => phone.year), []);
  const osCounts = useMemo(() => countBy(catalog, (phone) => phone.osFamily), []);
  const fiveG = useMemo(() => catalog.filter((phone) => phone.connectivity.network5g).length, []);
  const foldable = useMemo(() => catalog.filter((phone) => phone.body.foldable).length, []);
  const visibleBrands = brands.filter((brand) =>
    brand.toLocaleLowerCase("tr-TR").includes(brandQuery.trim().toLocaleLowerCase("tr-TR")),
  );
  const active = isFilterActive(filters, priceMax);

  const toggle = (key: "brands" | "years" | "os", value: string | number) => {
    const current = filters[key] as Array<string | number>;
    const next = current.includes(value)
      ? current.filter((item) => item !== value)
      : [...current, value];
    onChange({ ...filters, [key]: next });
  };

  return (
    <aside className="filters shop-filters">
      <div className="filters-head">
        <strong>Filtreler</strong>
        {active ? (
          <button type="button" className="filters-clear" onClick={onClear}>
            Temizle
          </button>
        ) : null}
      </div>

      <Facet title="Marka" open>
        <input
          className="brand-search"
          value={brandQuery}
          onChange={(event) => setBrandQuery(event.target.value)}
          placeholder="Marka ara"
        />
        <div className="brand-list">
          {visibleBrands.map((brand) => (
            <label key={brand} className="facet-check">
              <input
                type="checkbox"
                checked={filters.brands.includes(brand)}
                onChange={() => toggle("brands", brand)}
              />
              <span>{brand}</span>
              <em>{brandCounts.get(brand) ?? 0}</em>
            </label>
          ))}
        </div>
      </Facet>

      <Facet title="Fiyat" open>
        <div className="price-dual">
          <label>
            <span>Min</span>
            <input
              type="number"
              min={0}
              max={priceMax}
              step={1000}
              value={filters.minPrice || ""}
              placeholder="0"
              onChange={(event) =>
                onChange({ ...filters, minPrice: Math.max(0, Number(event.target.value) || 0) })
              }
            />
          </label>
          <label>
            <span>Max</span>
            <input
              type="number"
              min={0}
              max={priceMax}
              step={1000}
              value={filters.maxPrice}
              onChange={(event) =>
                onChange({
                  ...filters,
                  maxPrice: Math.min(priceMax, Math.max(0, Number(event.target.value) || 0)),
                })
              }
            />
          </label>
        </div>
        <input
          type="range"
          min={0}
          max={priceMax}
          step={1000}
          value={filters.maxPrice}
          onChange={(event) => onChange({ ...filters, maxPrice: Number(event.target.value) })}
        />
        <small className="mute">{formatPrice(filters.maxPrice)} üst sınır</small>
      </Facet>

      <Facet title="Yıl">
        {years.map((year) => (
          <label key={year} className="facet-check">
            <input
              type="checkbox"
              checked={filters.years.includes(year)}
              onChange={() => toggle("years", year)}
            />
            <span>{year}</span>
            <em>{yearCounts.get(year) ?? 0}</em>
          </label>
        ))}
      </Facet>

      <Facet title="İşletim sistemi">
        {(["iOS", "Android", "HarmonyOS"] as const).map((os) => (
          <label key={os} className="facet-check">
            <input type="checkbox" checked={filters.os.includes(os)} onChange={() => toggle("os", os)} />
            <span>{os}</span>
            <em>{osCounts.get(os) ?? 0}</em>
          </label>
        ))}
      </Facet>

      <Facet title="Bellek">
        <label className="field">
          <span>RAM</span>
          <select
            value={filters.minRam}
            onChange={(event) => onChange({ ...filters, minRam: Number(event.target.value) })}
          >
            {[0, 8, 12, 16].map((ram) => (
              <option key={ram} value={ram}>
                {ram === 0 ? "Tümü" : `${ram} GB ve üzeri`}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          <span>Depolama</span>
          <select
            value={filters.minStorage}
            onChange={(event) => onChange({ ...filters, minStorage: Number(event.target.value) })}
          >
            {[0, 128, 256, 512].map((storage) => (
              <option key={storage} value={storage}>
                {storage === 0 ? "Tümü" : `${storage} GB ve üzeri`}
              </option>
            ))}
          </select>
        </label>
      </Facet>

      <Facet title="Özellikler">
        <label className="facet-check">
          <input
            type="checkbox"
            checked={filters.only5g}
            onChange={(event) => onChange({ ...filters, only5g: event.target.checked })}
          />
          <span>5G</span>
          <em>{fiveG}</em>
        </label>
        <label className="facet-check">
          <input
            type="checkbox"
            checked={filters.foldable}
            onChange={(event) => onChange({ ...filters, foldable: event.target.checked })}
          />
          <span>Katlanır</span>
          <em>{foldable}</em>
        </label>
      </Facet>
    </aside>
  );
}

function Facet({
  title,
  open = false,
  children,
}: {
  title: string;
  open?: boolean;
  children: ReactNode;
}) {
  const [expanded, setExpanded] = useState(open);
  return (
    <section className={`facet ${expanded ? "open" : ""}`}>
      <button type="button" className="facet-head" onClick={() => setExpanded((value) => !value)}>
        <span>{title}</span>
        <span aria-hidden>{expanded ? "−" : "+"}</span>
      </button>
      {expanded ? <div className="facet-body">{children}</div> : null}
    </section>
  );
}
