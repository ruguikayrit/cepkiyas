import type { Phone } from "@/types/phone";

export interface SeriesGroup {
  series: string;
  count: number;
  models: Phone[];
}

export interface BrandGroup {
  brand: string;
  count: number;
  series: SeriesGroup[];
}

/** Strip storage / network suffixes for cleaner series labels */
export function normalizeModelName(name: string) {
  return name
    .replace(/\s+\d+\s*(gb|tb)$/i, "")
    .replace(/\s+(5g|4g|lte|wifi|wi-fi)$/i, "")
    .trim();
}

/** Collapse Pro Max / Ultra variants into a series heading (Galaxy S25, iPhone 16). */
export function seriesGroupKey(name: string) {
  let base = normalizeModelName(name);
  const patterns = [
    /\s+Pro Max$/i,
    /\s+Pro Plus$/i,
    /\s+Ultra$/i,
    /\s+Pro$/i,
    /\s+Plus$/i,
    /\s+FE$/i,
    /\s+Edge$/i,
    /\s+Lite$/i,
    /\s+Max$/i,
    /\s+Mini$/i,
    /\s+SE$/i,
    /\s+e$/i,
  ];
  for (const pattern of patterns) {
    if (pattern.test(base)) {
      base = base.replace(pattern, "").trim();
      break;
    }
  }
  return base || normalizeModelName(name);
}

export function buildBrandIndex(list: Phone[]): BrandGroup[] {
  const byBrand = new Map<string, Map<string, Phone[]>>();

  for (const phone of list) {
    if (!byBrand.has(phone.brand)) byBrand.set(phone.brand, new Map());
    const seriesKey = seriesGroupKey(phone.name);
    const seriesMap = byBrand.get(phone.brand)!;
    if (!seriesMap.has(seriesKey)) seriesMap.set(seriesKey, []);
    seriesMap.get(seriesKey)!.push(phone);
  }

  return [...byBrand.entries()]
    .sort((a, b) => a[0].localeCompare(b[0], "tr-TR"))
    .map(([brand, seriesMap]) => {
      const series = [...seriesMap.entries()]
        .map(([series, models]) => ({
          series,
          count: models.length,
          models: [...models].sort(
            (a, b) => b.year - a.year || a.name.localeCompare(b.name, "tr-TR"),
          ),
        }))
        .sort((a, b) => {
          const yearA = a.models[0]?.year ?? 0;
          const yearB = b.models[0]?.year ?? 0;
          return yearB - yearA || a.series.localeCompare(b.series, "tr-TR");
        });

      return {
        brand,
        count: series.reduce((sum, item) => sum + item.count, 0),
        series,
      };
    });
}

export function topBrands(list: Phone[], limit = 12) {
  const counts = new Map<string, number>();
  for (const phone of list) counts.set(phone.brand, (counts.get(phone.brand) ?? 0) + 1);
  return [...counts.entries()]
    .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0], "tr-TR"))
    .slice(0, limit)
    .map(([brand, count]) => ({ brand, count }));
}

export function letterBuckets(brands: BrandGroup[]) {
  const buckets = new Map<string, BrandGroup[]>();
  for (const group of brands) {
    const letter = (group.brand[0] ?? "#").toLocaleUpperCase("tr-TR");
    const key = /[A-ZİĞÜŞÖÇ]/i.test(letter) ? letter : "#";
    if (!buckets.has(key)) buckets.set(key, []);
    buckets.get(key)!.push(group);
  }
  return [...buckets.entries()].sort((a, b) => a[0].localeCompare(b[0], "tr-TR"));
}
