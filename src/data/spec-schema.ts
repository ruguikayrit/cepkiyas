import type { Phone } from "@/types/phone";
import { boolLabel, formatCapacity, formatHours, formatNumber } from "@/lib/format";

export type CompareDirection = "higher" | "lower" | "boolean" | "ip" | "none";

export interface SpecRow {
  id: string;
  label: string;
  direction: CompareDirection;
  value: (phone: Phone) => string | number | boolean;
  numeric?: (phone: Phone) => number;
}

export interface SpecGroup {
  id: string;
  label: string;
  rows: SpecRow[];
}

function ipNumeric(rating: string) {
  const match = rating.match(/IP(\d)(\d)/i);
  if (!match) return 0;
  return Number(match[1]) * 10 + Number(match[2]);
}

export const specGroups: SpecGroup[] = [
  {
    id: "summary",
    label: "Özet",
    rows: [
      { id: "os", label: "İşletim sistemi", direction: "none", value: (p) => p.os },
      { id: "year", label: "Çıkış yılı", direction: "higher", value: (p) => p.year, numeric: (p) => p.year },
      { id: "price", label: "Liste fiyatı", direction: "lower", value: (p) => (p.priceTRY ? p.priceTRY : "Fiyat yok"), numeric: (p) => p.priceTRY || Number.MAX_SAFE_INTEGER },
    ],
  },
  {
    id: "display",
    label: "Ekran",
    rows: [
      { id: "size", label: "Boyut", direction: "higher", value: (p) => (p.display.size ? `${p.display.size} inç` : "Belirtilmedi"), numeric: (p) => p.display.size },
      { id: "type", label: "Teknoloji", direction: "none", value: (p) => p.display.type },
      { id: "res", label: "Çözünürlük", direction: "none", value: (p) => p.display.resolution },
      { id: "hz", label: "Yenileme hızı", direction: "higher", value: (p) => (p.display.refreshRate ? `${p.display.refreshRate} Hz` : "Belirtilmedi"), numeric: (p) => p.display.refreshRate },
      { id: "nit", label: "Tepe parlaklık", direction: "higher", value: (p) => (p.display.brightness ? `${formatNumber(p.display.brightness)} nit` : "Belirtilmedi"), numeric: (p) => p.display.brightness },
      { id: "ppi", label: "Piksel yoğunluğu", direction: "higher", value: (p) => (p.display.ppi ? `${p.display.ppi} ppi` : "Belirtilmedi"), numeric: (p) => p.display.ppi },
      { id: "glass", label: "Koruma", direction: "none", value: (p) => p.display.protection },
      { id: "hdr", label: "HDR", direction: "boolean", value: (p) => p.display.hdr, numeric: (p) => (p.display.hdr ? 1 : 0) },
      { id: "aod", label: "Always-on", direction: "boolean", value: (p) => p.display.alwaysOn, numeric: (p) => (p.display.alwaysOn ? 1 : 0) },
    ],
  },
  {
    id: "body",
    label: "Gövde",
    rows: [
      { id: "dims", label: "Ölçüler", direction: "none", value: (p) => (p.body.height ? `${p.body.height} × ${p.body.width} × ${p.body.thickness} mm` : "Belirtilmedi") },
      { id: "thick", label: "Kalınlık", direction: "lower", value: (p) => (p.body.thickness ? `${p.body.thickness} mm` : "Belirtilmedi"), numeric: (p) => p.body.thickness || Number.MAX_SAFE_INTEGER },
      { id: "weight", label: "Ağırlık", direction: "lower", value: (p) => (p.body.weight ? `${p.body.weight} g` : "Belirtilmedi"), numeric: (p) => p.body.weight || Number.MAX_SAFE_INTEGER },
      { id: "material", label: "Malzeme", direction: "none", value: (p) => p.body.material },
      { id: "ip", label: "Dayanıklılık", direction: "ip", value: (p) => p.body.ipRating, numeric: (p) => ipNumeric(p.body.ipRating) },
      { id: "fold", label: "Katlanır", direction: "none", value: (p) => boolLabel(p.body.foldable) },
    ],
  },
  {
    id: "performance",
    label: "Performans",
    rows: [
      { id: "chip", label: "Yonga seti", direction: "none", value: (p) => p.performance.chipset },
      { id: "cpu", label: "İşlemci", direction: "none", value: (p) => p.performance.cpu },
      { id: "gpu", label: "GPU", direction: "none", value: (p) => p.performance.gpu },
      { id: "nm", label: "Üretim", direction: "lower", value: (p) => (p.performance.processNm ? `${p.performance.processNm} nm` : "Belirtilmedi"), numeric: (p) => p.performance.processNm || Number.MAX_SAFE_INTEGER },
      { id: "antutu", label: "AnTuTu", direction: "higher", value: (p) => (p.benchmarks.antutu ? formatNumber(p.benchmarks.antutu) : "Belirtilmedi"), numeric: (p) => p.benchmarks.antutu },
      { id: "gb1", label: "Geekbench tek", direction: "higher", value: (p) => (p.benchmarks.geekbenchSingle ? formatNumber(p.benchmarks.geekbenchSingle) : "Belirtilmedi"), numeric: (p) => p.benchmarks.geekbenchSingle },
      { id: "gb2", label: "Geekbench çoklu", direction: "higher", value: (p) => (p.benchmarks.geekbenchMulti ? formatNumber(p.benchmarks.geekbenchMulti) : "Belirtilmedi"), numeric: (p) => p.benchmarks.geekbenchMulti },
    ],
  },
  {
    id: "memory",
    label: "Bellek",
    rows: [
      { id: "ram", label: "RAM", direction: "higher", value: (p) => (p.memory.ram ? `${p.memory.ram} GB` : "Belirtilmedi"), numeric: (p) => p.memory.ram },
      { id: "storage", label: "Depolama", direction: "higher", value: (p) => (p.memory.storage ? `${p.memory.storage} GB` : "Belirtilmedi"), numeric: (p) => p.memory.storage },
      { id: "sd", label: "MicroSD", direction: "boolean", value: (p) => p.memory.expandable, numeric: (p) => (p.memory.expandable ? 1 : 0) },
    ],
  },
  {
    id: "camera",
    label: "Kamera",
    rows: [
      { id: "main", label: "Ana kamera", direction: "higher", value: (p) => (p.camera.rear[0]?.mp ? `${p.camera.rear[0].mp} MP ${p.camera.rear[0].aperture}` : "Belirtilmedi"), numeric: (p) => p.camera.rear[0]?.mp ?? 0 },
      { id: "lenses", label: "Arka kurulum", direction: "higher", value: (p) => (p.camera.rear[0]?.mp ? p.camera.rear.map((l) => `${l.name} ${l.mp} MP`).join(" · ") : "Belirtilmedi"), numeric: (p) => (p.camera.rear[0]?.mp ? p.camera.rear.length : 0) },
      { id: "front", label: "Ön kamera", direction: "higher", value: (p) => (p.camera.front.mp ? `${p.camera.front.mp} MP` : "Belirtilmedi"), numeric: (p) => p.camera.front.mp },
      { id: "video", label: "Video", direction: "none", value: (p) => p.camera.video },
      { id: "dxo", label: "DxOMark", direction: "higher", value: (p) => (p.camera.dxomark ? String(p.camera.dxomark) : "—"), numeric: (p) => p.camera.dxomark ?? 0 },
    ],
  },
  {
    id: "battery",
    label: "Batarya",
    rows: [
      { id: "cap", label: "Kapasite", direction: "higher", value: (p) => formatCapacity(p.battery.capacity, p.battery.capacityNote), numeric: (p) => p.battery.capacity ?? 0 },
      { id: "wired", label: "Kablolu şarj", direction: "higher", value: (p) => (p.battery.wiredWatt ? `${p.battery.wiredWatt} W` : "Belirtilmedi"), numeric: (p) => p.battery.wiredWatt },
      { id: "wireless", label: "Kablosuz şarj", direction: "higher", value: (p) => (p.battery.wirelessWatt ? `${p.battery.wirelessWatt} W` : "Yok"), numeric: (p) => p.battery.wirelessWatt },
      { id: "reverse", label: "Ters şarj", direction: "boolean", value: (p) => p.battery.reverse, numeric: (p) => (p.battery.reverse ? 1 : 0) },
      { id: "hours", label: "Kullanım süresi", direction: "higher", value: (p) => formatHours(p.battery.estimatedHours, p.battery.hoursNote), numeric: (p) => p.battery.estimatedHours },
    ],
  },
  {
    id: "connect",
    label: "Bağlantı",
    rows: [
      { id: "5g", label: "5G", direction: "boolean", value: (p) => p.connectivity.network5g, numeric: (p) => (p.connectivity.network5g ? 1 : 0) },
      { id: "wifi", label: "Wi-Fi", direction: "none", value: (p) => p.connectivity.wifi },
      { id: "bt", label: "Bluetooth", direction: "none", value: (p) => p.connectivity.bluetooth },
      { id: "nfc", label: "NFC", direction: "boolean", value: (p) => p.connectivity.nfc, numeric: (p) => (p.connectivity.nfc ? 1 : 0) },
      { id: "usb", label: "USB", direction: "none", value: (p) => p.connectivity.usb },
      { id: "sim", label: "SIM", direction: "none", value: (p) => p.connectivity.sim },
      { id: "esim", label: "eSIM", direction: "boolean", value: (p) => p.connectivity.esim, numeric: (p) => (p.connectivity.esim ? 1 : 0) },
    ],
  },
  {
    id: "other",
    label: "Diğer",
    rows: [
      { id: "speakers", label: "Hoparlör", direction: "none", value: (p) => p.audio.speakers },
      { id: "jack", label: "3.5 mm jack", direction: "boolean", value: (p) => p.audio.jack, numeric: (p) => (p.audio.jack ? 1 : 0) },
      { id: "fp", label: "Parmak izi", direction: "none", value: (p) => p.features.fingerprint },
      { id: "face", label: "Yüz tanıma", direction: "boolean", value: (p) => p.features.faceUnlock, numeric: (p) => (p.features.faceUnlock ? 1 : 0) },
      { id: "pen", label: "Kalem", direction: "boolean", value: (p) => p.features.stylus, numeric: (p) => (p.features.stylus ? 1 : 0) },
    ],
  },
];
