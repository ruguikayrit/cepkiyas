import type { Phone, RatingCategory, UserVote } from "@/types/phone";

export const RATING_KEY = "cepkiyas.votes.v1";

export const ratingCategories: { id: RatingCategory; label: string }[] = [
  { id: "overall", label: "Genel" },
  { id: "camera", label: "Kamera" },
  { id: "performance", label: "Performans" },
  { id: "battery", label: "Batarya" },
  { id: "display", label: "Ekran" },
  { id: "design", label: "Tasarım" },
];

export function emptyVote(): UserVote {
  return {
    overall: 0,
    camera: 0,
    performance: 0,
    battery: 0,
    display: 0,
    design: 0,
  };
}

export function readVotes(): Record<string, UserVote> {
  if (typeof window === "undefined") return {};
  try {
    const raw = window.localStorage.getItem(RATING_KEY);
    return raw ? (JSON.parse(raw) as Record<string, UserVote>) : {};
  } catch {
    return {};
  }
}

export function writeVotes(votes: Record<string, UserVote>) {
  window.localStorage.setItem(RATING_KEY, JSON.stringify(votes));
}

export function mergedUserScore(phone: Phone, vote?: UserVote) {
  const seedTotal = phone.seedRatings.average * phone.seedRatings.count;
  const extra = vote?.overall ? vote.overall : 0;
  const extraCount = vote?.overall ? 1 : 0;
  const count = phone.seedRatings.count + extraCount;
  const average = (seedTotal + extra) / count;

  const breakdown = {
    camera: blend(phone.seedRatings.camera, vote?.camera),
    performance: blend(phone.seedRatings.performance, vote?.performance),
    battery: blend(phone.seedRatings.battery, vote?.battery),
    display: blend(phone.seedRatings.display, vote?.display),
    design: blend(phone.seedRatings.design, vote?.design),
  };

  return {
    average: Math.round(average * 10) / 10,
    count,
    breakdown,
    mine: vote,
  };
}

function blend(seed: number, mine?: number) {
  if (!mine) return seed;
  return Math.round(((seed * 12 + mine) / 13) * 10) / 10;
}
