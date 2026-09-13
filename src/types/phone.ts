export type Brand = string;

export interface CameraLens {
  name: string;
  mp: number;
  aperture: string;
  ois?: boolean;
}

export interface SeedRatings {
  average: number;
  count: number;
  camera: number;
  performance: number;
  battery: number;
  display: number;
  design: number;
}

export interface Phone {
  id: string;
  slug: string;
  brand: Brand;
  name: string;
  fullName: string;
  year: number;
  releaseDate: string;
  priceTRY: number;
  popularity: number;
  os: string;
  osFamily: "iOS" | "Android" | "HarmonyOS";
  colors: { name: string; hex: string }[];
  accent: string;
  highlights: string[];
  image: string;
  sourceUrl: string;
  seedRatings: SeedRatings;
  display: {
    size: number;
    type: string;
    resolution: string;
    refreshRate: number;
    brightness: number;
    protection: string;
    ppi: number;
    ratio: string;
    hdr: boolean;
    alwaysOn: boolean;
  };
  body: {
    height: number;
    width: number;
    thickness: number;
    weight: number;
    material: string;
    ipRating: string;
    foldable: boolean;
  };
  performance: {
    chipset: string;
    cpu: string;
    gpu: string;
    processNm: number;
    cores: number;
  };
  memory: {
    ram: number;
    storage: number;
    expandable: boolean;
  };
  camera: {
    rear: CameraLens[];
    front: CameraLens;
    features: string[];
    dxomark: number | null;
    video: string;
  };
  battery: {
    capacity: number | null;
    capacityNote?: string;
    wiredWatt: number;
    wirelessWatt: number;
    reverse: boolean;
    estimatedHours: number;
    hoursNote?: string;
  };
  connectivity: {
    network5g: boolean;
    wifi: string;
    bluetooth: string;
    nfc: boolean;
    usb: string;
    sim: string;
    esim: boolean;
    infrared: boolean;
  };
  audio: {
    speakers: string;
    jack: boolean;
    dolby: boolean;
  };
  features: {
    fingerprint: string;
    faceUnlock: boolean;
    stylus: boolean;
  };
  sensors: string[];
  benchmarks: {
    antutu: number;
    geekbenchSingle: number;
    geekbenchMulti: number;
  };
}

export type RatingCategory =
  | "overall"
  | "camera"
  | "performance"
  | "battery"
  | "display"
  | "design";

export type UserVote = Record<RatingCategory, number>;

export type SortKey =
  | "smart"
  | "technical"
  | "user"
  | "price-asc"
  | "price-desc"
  | "newest"
  | "popular"
  | "name";
