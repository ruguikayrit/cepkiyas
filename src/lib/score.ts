import type { Phone } from "@/types/phone";
import { phones } from "@/data/phones";

function clamp(value: number, min = 0, max = 100) {
  return Math.min(max, Math.max(min, value));
}

function rangeOf(values: number[]) {
  const finite = values.filter((value) => Number.isFinite(value));
  if (finite.length === 0) return { min: 0, max: 1 };
  const min = Math.min(...finite);
  const max = Math.max(...finite);
  return { min, max };
}

function norm(value: number, min: number, max: number, invert = false) {
  if (max === min) return 70;
  const raw = ((value - min) / (max - min)) * 100;
  return clamp(invert ? 100 - raw : raw);
}

function ipRank(rating: string) {
  const match = rating.match(/IP(\d)(\d)/i);
  if (!match) return 0;
  return Number(match[1]) * 10 + Number(match[2]);
}

function rearMp(phone: Phone) {
  return phone.camera.rear.reduce((sum, lens) => sum + lens.mp, 0);
}

function cameraRaw(phone: Phone) {
  const dxo = phone.camera.dxomark ?? (rearMp(phone) > 0 ? 118 : 0);
  return dxo * 2 + rearMp(phone);
}

const scored = phones.filter((phone) => phone.image);
const catalogBase = scored.length ? scored : phones;

const catalog = {
  antutu: rangeOf(catalogBase.map((p) => p.benchmarks.antutu)),
  geek: rangeOf(catalogBase.map((p) => p.benchmarks.geekbenchMulti)),
  camera: rangeOf(catalogBase.map((p) => cameraRaw(p))),
  display: rangeOf(catalogBase.map((p) => displayRaw(p))),
  battery: rangeOf(catalogBase.map((p) => batteryRaw(p))),
  memory: rangeOf(catalogBase.map((p) => memoryRaw(p))),
  body: rangeOf(catalogBase.map((p) => bodyRaw(p))),
};

function displayRaw(phone: Phone) {
  return (
    phone.display.size * 8 +
    phone.display.refreshRate * 0.25 +
    phone.display.brightness / 80 +
    phone.display.ppi / 12
  );
}

function batteryRaw(phone: Phone) {
  const capacity = phone.battery.capacity ?? phone.battery.estimatedHours * 155;
  return capacity + phone.battery.wiredWatt * 8 + phone.battery.estimatedHours * 40;
}

function memoryRaw(phone: Phone) {
  return phone.memory.ram * 18 + phone.memory.storage * 0.08;
}

function bodyRaw(phone: Phone) {
  const weight = phone.body.weight || 200;
  const thickness = phone.body.thickness || 8.2;
  return ipRank(phone.body.ipRating) * 2 + (280 - weight) + (12 - thickness) * 8;
}

function featureRaw(phone: Phone) {
  let score = 40;
  if (phone.connectivity.network5g) score += 10;
  if (phone.connectivity.nfc) score += 6;
  if (phone.connectivity.esim) score += 5;
  if (phone.battery.wirelessWatt > 0) score += 8;
  if (phone.battery.reverse) score += 4;
  if (phone.audio.dolby) score += 4;
  if (phone.features.stylus) score += 6;
  if (phone.features.faceUnlock) score += 4;
  if (phone.display.alwaysOn) score += 4;
  if (phone.display.hdr) score += 4;
  if (phone.connectivity.wifi.includes("7")) score += 5;
  return clamp(score);
}

export function technicalScore(phone: Phone) {
  const performance =
    norm(phone.benchmarks.antutu, catalog.antutu.min, catalog.antutu.max) * 0.65 +
    norm(phone.benchmarks.geekbenchMulti, catalog.geek.min, catalog.geek.max) * 0.35;

  const camera = norm(cameraRaw(phone), catalog.camera.min, catalog.camera.max);

  const display = norm(displayRaw(phone), catalog.display.min, catalog.display.max);
  const battery = norm(batteryRaw(phone), catalog.battery.min, catalog.battery.max);
  const memory = norm(memoryRaw(phone), catalog.memory.min, catalog.memory.max);
  const body = norm(bodyRaw(phone), catalog.body.min, catalog.body.max);
  const extras = featureRaw(phone);

  const total =
    performance * 0.22 +
    camera * 0.18 +
    display * 0.14 +
    battery * 0.16 +
    memory * 0.1 +
    body * 0.08 +
    extras * 0.12;

  return Math.round(total * 10) / 10;
}

export function categoryScores(phone: Phone) {
  return {
    performans: Math.round(norm(phone.benchmarks.antutu, catalog.antutu.min, catalog.antutu.max) * 10) / 10,
    kamera: Math.round(norm(cameraRaw(phone), catalog.camera.min, catalog.camera.max) * 10) / 10,
    ekran: Math.round(norm(displayRaw(phone), catalog.display.min, catalog.display.max) * 10) / 10,
    batarya: Math.round(norm(batteryRaw(phone), catalog.battery.min, catalog.battery.max) * 10) / 10,
    bellek: Math.round(norm(memoryRaw(phone), catalog.memory.min, catalog.memory.max) * 10) / 10,
  };
}

export function recencyScore(phone: Phone) {
  const age = (Date.now() - new Date(phone.releaseDate).getTime()) / (1000 * 60 * 60 * 24);
  return clamp(100 - age / 8);
}

export function smartScore(phone: Phone, userAverage: number) {
  return (
    phone.popularity * 0.38 +
    technicalScore(phone) * 0.32 +
    userAverage * 10 * 0.18 +
    recencyScore(phone) * 0.12
  );
}

export function globalIndex(technical: number, userAverage: number) {
  return Math.round((technical * 0.55 + userAverage * 10 * 0.45) * 10) / 10;
}

export function scoreTone(score: number) {
  if (score >= 88) return "high";
  if (score >= 76) return "mid";
  return "low";
}
