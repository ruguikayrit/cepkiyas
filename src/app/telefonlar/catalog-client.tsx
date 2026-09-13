"use client";

import { useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { phones } from "@/data/phones";
import { FiltersPanel } from "@/components/filters-panel";
import { PhoneRow } from "@/components/phone-card";
import { useRatings } from "@/context/ratings-context";
import { defaultFilters, filterPhones } from "@/lib/filters";

const PAGE_SIZE = 40;
const priceMax = Math.max(200000, ...phones.map((phone) => phone.priceTRY));

export function CatalogClient() {
  const params = useSearchParams();
  const brandFromUrl = params.get("marka");
  const { averages } = useRatings();
  const [page, setPage] = useState(0);
  const [filters, setFilters] = useState(() => {
    const base = defaultFilters(priceMax);
    return brandFromUrl ? { ...base, brands: [brandFromUrl] } : base;
  });

  const list = useMemo(() => filterPhones(phones, filters, averages), [filters, averages]);
  const pageCount = Math.max(1, Math.ceil(list.length / PAGE_SIZE));
  const safePage = Math.min(page, pageCount - 1);
  const visible = list.slice(safePage * PAGE_SIZE, safePage * PAGE_SIZE + PAGE_SIZE);

  return (
    <div className="shell catalog">
      <FiltersPanel
        filters={filters}
        priceMax={priceMax}
        onChange={(next) => {
          setPage(0);
          setFilters(next);
        }}
      />
      <section>
        <div className="section-head" style={{ marginTop: 0 }}>
          <div>
            <h2>Telefon kataloğu</h2>
            <p className="mute">
              {list.length} model · sayfa {safePage + 1}/{pageCount}
            </p>
          </div>
        </div>
        <div className="row-list">
          {visible.map((phone) => (
            <PhoneRow key={phone.id} phone={phone} />
          ))}
          {list.length === 0 ? <div className="empty-state">Bu filtrelere uyan model yok.</div> : null}
        </div>
        {pageCount > 1 ? (
          <div className="pager">
            <button type="button" className="chip" disabled={safePage === 0} onClick={() => setPage(safePage - 1)}>
              Önceki
            </button>
            <button type="button" className="chip" disabled={safePage >= pageCount - 1} onClick={() => setPage(safePage + 1)}>
              Sonraki
            </button>
          </div>
        ) : null}
      </section>
    </div>
  );
}
