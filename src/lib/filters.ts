import type { Phone, SortKey } from "@/types/phone";
import { smartScore, technicalScore } from "@/lib/score";

export const sortOptions: { id: SortKey; label: string }[] = [
  { id: "smart", label: "Önerilen" },
  { id: "popular", label: "Çok incelenen" },
  { id: "newest", label: "En yeni" },
  { id: "price-asc", label: "En düşük fiyat" },
  { id: "price-desc", label: "En yüksek fiyat" },
  { id: "technical", label: "Teknik puan" },
  { id: "user", label: "Kullanıcı puanı" },
  { id: "name", label: "Ada göre" },
];

export interface CatalogFilters {
  query: string;
  brands: string[];
  years: number[];
  os: string[];
  minPrice: number;
  maxPrice: number;
  minRam: number;
  minStorage: number;
  only5g: boolean;
  foldable: boolean;
  sort: SortKey;
}

export function isFilterActive(filters: CatalogFilters, priceMax: number) {
  return Boolean(
    filters.query.trim() ||
      filters.brands.length ||
      filters.years.length ||
      filters.os.length ||
      filters.minPrice > 0 ||
      filters.maxPrice < priceMax ||
      filters.minRam ||
      filters.minStorage ||
      filters.only5g ||
      filters.foldable,
  );
}

export function filterChips(filters: CatalogFilters, priceMax: number) {
  const chips: { id: string; label: string; next: CatalogFilters }[] = [];
  if (filters.query.trim()) {
    chips.push({ id: "q", label: `"${filters.query.trim()}"`, next: { ...filters, query: "" } });
  }
  for (const brand of filters.brands) {
    chips.push({
      id: `brand-${brand}`,
      label: brand,
      next: { ...filters, brands: filters.brands.filter((item) => item !== brand) },
    });
  }
  for (const year of filters.years) {
    chips.push({
      id: `year-${year}`,
      label: String(year),
      next: { ...filters, years: filters.years.filter((item) => item !== year) },
    });
  }
  for (const os of filters.os) {
    chips.push({
      id: `os-${os}`,
      label: os,
      next: { ...filters, os: filters.os.filter((item) => item !== os) },
    });
  }
  if (filters.minPrice > 0 || filters.maxPrice < priceMax) {
    chips.push({
      id: "price",
      label: `${filters.minPrice.toLocaleString("tr-TR")} – ${filters.maxPrice.toLocaleString("tr-TR")} ₺`,
      next: { ...filters, minPrice: 0, maxPrice: priceMax },
    });
  }
  if (filters.minRam) {
    chips.push({ id: "ram", label: `${filters.minRam} GB+ RAM`, next: { ...filters, minRam: 0 } });
  }
  if (filters.minStorage) {
    chips.push({
      id: "storage",
      label: `${filters.minStorage} GB+ depolama`,
      next: { ...filters, minStorage: 0 },
    });
  }
  if (filters.only5g) chips.push({ id: "5g", label: "5G", next: { ...filters, only5g: false } });
  if (filters.foldable) chips.push({ id: "fold", label: "Katlanır", next: { ...filters, foldable: false } });
  return chips;
}

export function countBy<T extends string | number>(list: Phone[], key: (phone: Phone) => T) {
  const counts = new Map<T, number>();
  for (const phone of list) {
    const value = key(phone);
    counts.set(value, (counts.get(value) ?? 0) + 1);
  }
  return counts;
}

export function defaultFilters(priceMax: number): CatalogFilters {
  return {
    query: "",
    brands: [],
    years: [],
    os: [],
    minPrice: 0,
    maxPrice: priceMax,
    minRam: 0,
    minStorage: 0,
    only5g: false,
    foldable: false,
    sort: "smart",
  };
}

export function filterPhones(
  list: Phone[],
  filters: CatalogFilters,
  userAverages: Record<string, number>,
) {
  const q = filters.query.trim().toLocaleLowerCase("tr-TR");

  const filtered = list.filter((phone) => {
    const haystack = `${phone.fullName} ${phone.performance.chipset} ${phone.os}`.toLocaleLowerCase("tr-TR");
    if (q && !haystack.includes(q)) return false;
    if (filters.brands.length && !filters.brands.includes(phone.brand)) return false;
    if (filters.years.length && !filters.years.includes(phone.year)) return false;
    if (filters.os.length && !filters.os.includes(phone.osFamily)) return false;
    if (phone.priceTRY > 0 && (phone.priceTRY < filters.minPrice || phone.priceTRY > filters.maxPrice)) return false;
    if (filters.minRam && phone.memory.ram > 0 && phone.memory.ram < filters.minRam) return false;
    if (filters.minStorage && phone.memory.storage > 0 && phone.memory.storage < filters.minStorage) return false;
    if (filters.only5g && !phone.connectivity.network5g) return false;
    if (filters.foldable && !phone.body.foldable) return false;
    return true;
  });

  return filtered.sort((a, b) => {
    switch (filters.sort) {
      case "technical":
        return technicalScore(b) - technicalScore(a);
      case "user":
        return (userAverages[b.id] ?? 0) - (userAverages[a.id] ?? 0);
      case "price-asc":
        return (a.priceTRY || Number.POSITIVE_INFINITY) - (b.priceTRY || Number.POSITIVE_INFINITY);
      case "price-desc":
        return (b.priceTRY || 0) - (a.priceTRY || 0);
      case "newest":
        return +new Date(b.releaseDate) - +new Date(a.releaseDate);
      case "popular":
        return b.popularity - a.popularity;
      case "name":
        return a.fullName.localeCompare(b.fullName, "tr");
      default:
        return (
          smartScore(b, userAverages[b.id] ?? b.seedRatings.average) -
          smartScore(a, userAverages[a.id] ?? a.seedRatings.average)
        );
    }
  });
}
