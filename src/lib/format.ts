const trNumber = new Intl.NumberFormat("tr-TR");
const trCurrency = new Intl.NumberFormat("tr-TR", {
  style: "currency",
  currency: "TRY",
  maximumFractionDigits: 0,
});

export function formatNumber(value: number) {
  return trNumber.format(value);
}

export function formatPrice(value: number) {
  if (!value) return "Fiyat yok";
  return trCurrency.format(value);
}

export function formatScore(value: number) {
  if (!Number.isFinite(value)) return "—";
  return value.toLocaleString("tr-TR", {
    minimumFractionDigits: 1,
    maximumFractionDigits: 1,
  });
}

export function formatCount(value: number) {
  if (value >= 1000) {
    return `${(value / 1000).toLocaleString("tr-TR", { maximumFractionDigits: 1 })} B`;
  }
  return trNumber.format(value);
}

export function boolLabel(value: boolean) {
  return value ? "Var" : "Yok";
}

export function formatCapacity(capacity: number | null, note?: string) {
  if (capacity == null) {
    return note ?? "Üretici belirtmedi";
  }
  return `${formatNumber(capacity)} mAh`;
}

export function formatHours(hours: number, note?: string) {
  if (!hours) return note ?? "Belirtilmedi";
  return note ? `${hours} saat · ${note}` : `${hours} saat`;
}
