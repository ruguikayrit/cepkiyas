import type { Phone } from "@/types/phone";
import overlayJson from "@/data/specs-overlay.json";

export interface CatalogRow {
  id: string;
  slug: string;
  brand: string;
  name: string;
  fullName: string;
  year: number;
  priceTRY: number;
  popularity: number;
  os: string;
  osFamily: "iOS" | "Android" | "HarmonyOS";
  accent: string;
  sourceUrl: string;
  officialId?: string | null;
  ram: number;
  storage: number;
  foldable: boolean;
  network5g: boolean;
}

interface SpecOverlay {
  image?: string;
  sourceUrl?: string;
  os?: string;
  chipset?: string;
  displaySize?: number;
  displayType?: string;
  refreshRate?: number;
  brightness?: number;
  height?: number;
  width?: number;
  thickness?: number;
  weight?: number;
  capacity?: number;
  wiredWatt?: number;
  ram?: number;
  storage?: number;
  mainMp?: number;
  ipRating?: string;
  network5g?: boolean;
}

const overlay = overlayJson as Record<string, SpecOverlay>;

export function hydrateListing(row: CatalogRow): Phone {
  const extra = overlay[row.id] ?? {};
  const ram = extra.ram || row.ram;
  const storage = extra.storage || row.storage;
  const highlights = [
    extra.chipset,
    extra.displaySize ? `${extra.displaySize}"` : "",
    extra.capacity ? `${extra.capacity} mAh` : "",
  ].filter(Boolean) as string[];

  return {
    id: row.id,
    slug: row.slug,
    brand: row.brand,
    name: row.name,
    fullName: row.fullName,
    year: row.year,
    releaseDate: `${row.year}-01-01`,
    priceTRY: row.priceTRY,
    popularity: row.popularity,
    os: extra.os || row.os,
    osFamily: row.osFamily,
    colors: [{ name: "Varsayılan", hex: row.accent }],
    accent: row.accent,
    highlights: highlights.length ? highlights : [row.brand, `${row.year}`],
    image: extra.image || "",
    sourceUrl: extra.sourceUrl || row.sourceUrl,
    seedRatings: { average: 7, count: 0, camera: 7, performance: 7, battery: 7, display: 7, design: 7 },
    display: {
      size: extra.displaySize || 0,
      type: extra.displayType || "Belirtilmedi",
      resolution: "Belirtilmedi",
      refreshRate: extra.refreshRate || 0,
      brightness: extra.brightness || 0,
      protection: "Belirtilmedi",
      ppi: 0,
      ratio: "Belirtilmedi",
      hdr: Boolean(extra.refreshRate && extra.refreshRate >= 90),
      alwaysOn: false,
    },
    body: {
      height: extra.height || 0,
      width: extra.width || 0,
      thickness: extra.thickness || 0,
      weight: extra.weight || 0,
      material: "Belirtilmedi",
      ipRating: extra.ipRating || "Belirtilmedi",
      foldable: row.foldable,
    },
    performance: {
      chipset: extra.chipset || "Belirtilmedi",
      cpu: "Belirtilmedi",
      gpu: "Belirtilmedi",
      processNm: 0,
      cores: 0,
    },
    memory: {
      ram,
      storage,
      expandable: false,
    },
    camera: {
      rear: [{ name: "Ana", mp: extra.mainMp || 0, aperture: "—" }],
      front: { name: "Ön", mp: 0, aperture: "—" },
      features: [],
      dxomark: null,
      video: "Belirtilmedi",
    },
    battery: {
      capacity: extra.capacity ?? null,
      capacityNote: extra.capacity ? undefined : "Çapraz kaynakta mAh yok",
      wiredWatt: extra.wiredWatt || 0,
      wirelessWatt: 0,
      reverse: false,
      estimatedHours: 0,
    },
    connectivity: {
      network5g: extra.network5g ?? row.network5g,
      wifi: "Belirtilmedi",
      bluetooth: "Belirtilmedi",
      nfc: false,
      usb: "Belirtilmedi",
      sim: "Belirtilmedi",
      esim: row.brand === "Apple",
      infrared: false,
    },
    audio: { speakers: "Belirtilmedi", jack: false, dolby: false },
    features: { fingerprint: "Belirtilmedi", faceUnlock: false, stylus: false },
    sensors: [],
    benchmarks: { antutu: 0, geekbenchSingle: 0, geekbenchMulti: 0 },
  };
}
