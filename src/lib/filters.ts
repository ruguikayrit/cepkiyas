import type { Phone, SortKey } from "@/types/phone";
import { smartScore, technicalScore } from "@/lib/score";

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
