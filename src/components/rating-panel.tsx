"use client";

import { useState } from "react";
import { useRatings } from "@/context/ratings-context";
import { emptyVote, ratingCategories } from "@/lib/ratings";
import { formatCount, formatScore } from "@/lib/format";
import type { Phone, RatingCategory, UserVote } from "@/types/phone";

export function RatingPanel({ phone }: { phone: Phone }) {
  const { scoreOf, setVote } = useRatings();
  const score = scoreOf(phone);
  const [draft, setDraft] = useState<UserVote | null>(null);
  const [saved, setSaved] = useState(false);
  const view = draft ?? score.mine ?? emptyVote();

  const setCategory = (id: RatingCategory, value: number) => {
    setDraft({
      ...view,
      [id]: value,
      overall: id === "overall" ? value : view.overall || value,
    });
    setSaved(false);
  };

  const submit = () => {
    if (!view.overall) return;
    setVote(phone.id, view);
    setSaved(true);
  };

  return (
    <section className="rating-panel">
      <div className="rating-hero">
        <div>
          <small>Küresel kullanıcı puanı</small>
          <strong>{formatScore(score.average)}</strong>
          <span>/ 10 · {formatCount(score.count)} oy</span>
        </div>
        <ul>
          {(
            Object.entries(score.breakdown) as [
              Exclude<RatingCategory, "overall">,
              number,
            ][]
          ).map(([id, value]) => (
              <li key={id}>
                <span>{ratingCategories.find((item) => item.id === id)?.label}</span>
                <b>{formatScore(value)}</b>
                <i style={{ width: `${value * 10}%` }} />
              </li>
            ))}
        </ul>
      </div>

      <div className="rating-form">
        <h3>Puan ver</h3>
        <p>Oyun bu tarayıcıda saklanır ve küresel ortalamaya eklenir.</p>
        {ratingCategories.map((item) => (
          <label key={item.id}>
            <span>{item.label}</span>
            <div className="pips">
              {Array.from({ length: 10 }, (_, index) => {
                const value = index + 1;
                return (
                  <button
                    key={value}
                    type="button"
                    className={view[item.id] >= value ? "on" : undefined}
                    onClick={() => setCategory(item.id, value)}
                  >
                    {value}
                  </button>
                );
              })}
            </div>
          </label>
        ))}
        <button type="button" className="btn" onClick={submit} disabled={!view.overall}>
          {saved || score.mine ? "Oyu güncelle" : "Oyu kaydet"}
        </button>
      </div>
    </section>
  );
}
