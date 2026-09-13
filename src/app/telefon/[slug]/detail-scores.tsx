"use client";

import { ScoreRing } from "@/components/score-ring";
import { useRatings } from "@/context/ratings-context";
import { globalIndex, technicalScore } from "@/lib/score";
import type { Phone } from "@/types/phone";

export function DetailScores({ phone }: { phone: Phone }) {
  const { scoreOf } = useRatings();
  const technical = technicalScore(phone);
  const user = scoreOf(phone);

  return (
    <div className="detail-scores">
      <ScoreRing value={technical} label="Teknik" size={88} />
      <ScoreRing value={user.average * 10} label="Kullanıcı" size={88} />
      <ScoreRing value={globalIndex(technical, user.average)} label="Endeks" size={88} />
    </div>
  );
}
