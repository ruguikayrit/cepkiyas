"use client";

import Link from "next/link";
import { categoryHref, productCategories, type ProductCategory } from "@/lib/catalog-taxonomy";

export function CatalogCategoryNav({
  activeSlug,
  counts,
}: {
  activeSlug: string;
  counts?: Record<string, number>;
}) {
  return (
    <nav className="catalog-cat-nav" aria-label="Ürün grupları">
      {productCategories.map((cat) => (
        <CategoryChip key={cat.id} cat={cat} active={cat.slug === activeSlug} count={counts?.[cat.slug]} />
      ))}
    </nav>
  );
}

function CategoryChip({
  cat,
  active,
  count,
}: {
  cat: ProductCategory;
  active: boolean;
  count?: number;
}) {
  const soon = cat.status === "soon";
  const label = count != null && cat.status === "active" ? `${cat.shortLabel} · ${count.toLocaleString("tr-TR")}` : cat.shortLabel;

  if (soon) {
    return (
      <span className="catalog-cat-chip soon" title={`${cat.label} — yakında`}>
        {cat.shortLabel}
        <small>Yakında</small>
      </span>
    );
  }

  return (
    <Link href={categoryHref(cat.slug)} className={active ? "catalog-cat-chip active" : "catalog-cat-chip"}>
      {label}
    </Link>
  );
}
