import type { Phone } from "@/types/phone";
import type { SpecRow } from "@/data/spec-schema";
import { boolLabel, formatPrice } from "@/lib/format";

export function displaySpec(phone: Phone, row: SpecRow) {
  const raw = row.value(phone);
  if (typeof raw === "boolean") return boolLabel(raw);
  if (row.id === "price" && typeof raw === "number") return formatPrice(raw);
  return String(raw);
}

export function winnersForRow(phones: Phone[], row: SpecRow) {
  if (row.direction === "none" || phones.length < 2 || !row.numeric) return [];

  const values = phones.map((phone) => row.numeric!(phone));
  const usable = values.filter((value) => Number.isFinite(value));
  if (usable.length === 0) return [];

  const target =
    row.direction === "lower" ? Math.min(...usable) : Math.max(...usable);

  const allEqual = usable.every((value) => value === usable[0]);
  if (allEqual) return [];

  return phones
    .map((phone, index) => ({ phone, value: values[index] }))
    .filter((entry) => entry.value === target)
    .map((entry) => entry.phone.id);
}

export function rowHasDifference(phones: Phone[], row: SpecRow) {
  const values = phones.map((phone) => displaySpec(phone, row));
  return new Set(values).size > 1;
}

export function comparePath(slugs: string[]) {
  const params = new URLSearchParams();
  if (slugs.length) params.set("p", slugs.join(","));
  return `/karsilastir${params.toString() ? `?${params.toString()}` : ""}`;
}
