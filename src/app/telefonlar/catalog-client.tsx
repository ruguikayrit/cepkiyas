"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { phones } from "@/data/phones";
import { FiltersPanel } from "@/components/filters-panel";
import { ShopCard } from "@/components/phone-card";
import { useRatings } from "@/context/ratings-context";
import {
  defaultFilters,
  filterChips,
  filterPhones,
  isFilterActive,
  sortOptions,
  type CatalogFilters,
} from "@/lib/filters";

const PAGE_SIZE = 24;
const priceMax = Math.max(200000, ...phones.map((phone) => phone.priceTRY));

export function CatalogClient() {
  const router = useRouter();
  const params = useSearchParams();
  const qParam = params.get("q") ?? "";
  const markaParam = params.get("marka");
  const { averages } = useRatings();
  const [page, setPage] = useState(0);
  const [drawer, setDrawer] = useState(false);
  const [filters, setFilters] = useState<CatalogFilters>(() => {
    const base = defaultFilters(priceMax);
    return {
      ...base,
      query: qParam,
      brands: markaParam ? [markaParam] : [],
    };
  });

  useEffect(() => {
    setFilters((prev) => ({
      ...prev,
      query: qParam,
      brands: markaParam
        ? prev.brands.includes(markaParam)
          ? prev.brands
          : [markaParam, ...prev.brands]
        : prev.brands,
    }));
    setPage(0);
  }, [qParam, markaParam]);

  const list = useMemo(() => filterPhones(phones, filters, averages), [filters, averages]);
  const chips = filterChips(filters, priceMax);
  const active = isFilterActive(filters, priceMax);
  const pageCount = Math.max(1, Math.ceil(list.length / PAGE_SIZE));
  const safePage = Math.min(page, pageCount - 1);
  const visible = list.slice(safePage * PAGE_SIZE, safePage * PAGE_SIZE + PAGE_SIZE);

  const apply = (next: CatalogFilters, syncUrl = true) => {
    setPage(0);
    setFilters(next);
    if (!syncUrl) return;
    const usp = new URLSearchParams();
    if (next.query.trim()) usp.set("q", next.query.trim());
    if (next.brands.length === 1) usp.set("marka", next.brands[0]);
    const qs = usp.toString();
    router.replace(qs ? `/telefonlar?${qs}` : "/telefonlar", { scroll: false });
  };

  const clear = () => apply(defaultFilters(priceMax));

  const goPage = (nextPage: number) => {
    setPage(nextPage);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const panel = (
    <FiltersPanel
      filters={filters}
      priceMax={priceMax}
      onChange={apply}
      onClear={clear}
    />
  );

  return (
    <div className="shell catalog shop-catalog">
      <div className="filters-desktop">{panel}</div>

      {drawer ? (
        <div className="filters-backdrop" onClick={() => setDrawer(false)}>
          <div className="filters-drawer" onClick={(event) => event.stopPropagation()}>
            <div className="filters-drawer-bar">
              <strong>Filtrele</strong>
              <button type="button" className="ghost mini" onClick={() => setDrawer(false)}>
                Kapat
              </button>
            </div>
            {panel}
          </div>
        </div>
      ) : null}

      <section className="shop-results">
        <form
          className="shop-search"
          onSubmit={(event) => {
            event.preventDefault();
            apply(filters);
          }}
        >
          <span aria-hidden>⌕</span>
          <input
            value={filters.query}
            onChange={(event) => apply({ ...filters, query: event.target.value }, false)}
            onBlur={(event) => apply({ ...filters, query: event.currentTarget.value })}
            placeholder="Ürün, marka veya model ara"
          />
        </form>

        <div className="shop-toolbar">
          <div>
            <h1>Telefonlar</h1>
            <p className="mute">
              {list.length.toLocaleString("tr-TR")} ürün
              {pageCount > 1 ? ` · sayfa ${safePage + 1}/${pageCount}` : ""}
            </p>
          </div>
          <div className="shop-toolbar-actions">
            <button type="button" className="shop-filter-btn" onClick={() => setDrawer(true)}>
              Filtrele{active ? ` (${chips.length})` : ""}
            </button>
            <label className="shop-sort">
              <span>Sırala</span>
              <select
                value={filters.sort}
                onChange={(event) =>
                  apply({ ...filters, sort: event.target.value as CatalogFilters["sort"] })
                }
              >
                {sortOptions.map((sort) => (
                  <option key={sort.id} value={sort.id}>
                    {sort.label}
                  </option>
                ))}
              </select>
            </label>
          </div>
        </div>

        {chips.length ? (
          <div className="shop-chips">
            {chips.map((chip) => (
              <button key={chip.id} type="button" className="shop-chip" onClick={() => apply(chip.next)}>
                {chip.label}
                <span aria-hidden>×</span>
              </button>
            ))}
            <button type="button" className="shop-chip-clear" onClick={clear}>
              Filtreleri temizle
            </button>
          </div>
        ) : null}

        <div className="shop-grid">
          {visible.map((phone) => (
            <ShopCard key={phone.id} phone={phone} />
          ))}
        </div>
        {list.length === 0 ? (
          <div className="empty-state">
            Bu kriterlere uyan ürün yok.
            {active ? (
              <>
                {" "}
                <button type="button" className="shop-chip-clear" onClick={clear}>
                  Filtreleri temizle
                </button>
              </>
            ) : null}
          </div>
        ) : null}
        <Pager page={safePage} pageCount={pageCount} onPage={goPage} />
      </section>
    </div>
  );
}

function Pager({
  page,
  pageCount,
  onPage,
}: {
  page: number;
  pageCount: number;
  onPage: (page: number) => void;
}) {
  if (pageCount <= 1) return null;
  const windowSize = 2;
  const numbers = new Set<number>([0, pageCount - 1]);
  for (let i = page - windowSize; i <= page + windowSize; i += 1) {
    if (i >= 0 && i < pageCount) numbers.add(i);
  }
  const sorted = [...numbers].sort((a, b) => a - b);
  const items: Array<number | "gap"> = [];
  sorted.forEach((n, index) => {
    if (index && n - sorted[index - 1] > 1) items.push("gap");
    items.push(n);
  });

  return (
    <nav className="pager" aria-label="Sayfalar">
      <button type="button" className="chip" disabled={page === 0} onClick={() => onPage(page - 1)}>
        Önceki
      </button>
      {items.map((item, index) =>
        item === "gap" ? (
          <span key={`gap-${index}`} className="pager-gap">
            …
          </span>
        ) : (
          <button
            key={item}
            type="button"
            className={item === page ? "chip active" : "chip"}
            onClick={() => onPage(item)}
          >
            {item + 1}
          </button>
        ),
      )}
      <button
        type="button"
        className="chip"
        disabled={page >= pageCount - 1}
        onClick={() => onPage(page + 1)}
      >
        Sonraki
      </button>
    </nav>
  );
}
