"use client";

import Link from "next/link";
import { PhoneVisual } from "@/components/phone-visual";
import { ScorePill } from "@/components/score-ring";
import { useCompare } from "@/context/compare-context";
import { useRatings } from "@/context/ratings-context";
import { formatCapacity, formatPrice } from "@/lib/format";
import { globalIndex, technicalScore } from "@/lib/score";
import type { Phone } from "@/types/phone";

export function PhoneRow({ phone }: { phone: Phone }) {
  const { toggle, has } = useCompare();
  const { scoreOf } = useRatings();
  const technical = technicalScore(phone);
  const user = scoreOf(phone);
  const index = globalIndex(technical, user.average);
  const selected = has(phone.id);

  return (
    <article className={`phone-row ${selected ? "selected" : ""}`}>
      <Link href={`/telefon/${phone.slug}`} className="phone-row-main">
        <PhoneVisual phone={phone} />
        <div className="phone-row-meta">
          <small>{phone.brand}</small>
          <h3>{phone.name}</h3>
          <p>
            {phone.year}
            {phone.memory.ram ? ` · ${phone.memory.ram} GB RAM` : ""}
            {phone.memory.storage ? ` · ${phone.memory.storage} GB` : ""}
            {phone.battery.capacity ? ` · ${formatCapacity(phone.battery.capacity)}` : ""}
          </p>
        </div>
      </Link>

      <div className="phone-row-scores">
        <ScorePill value={technical} label="Teknik" />
        <ScorePill value={user.average * 10} label="Kullanıcı" />
        <ScorePill value={index} label="Endeks" />
      </div>

      <div className="phone-row-price">
        <strong>{formatPrice(phone.priceTRY)}</strong>
        <span>{phone.year}</span>
      </div>

      <button
        type="button"
        className={selected ? "chip active" : "chip"}
        onClick={() => toggle(phone.id)}
      >
        {selected ? "Seçildi" : "Kıyasla"}
      </button>
    </article>
  );
}

export function ShopCard({ phone }: { phone: Phone }) {
  const { toggle, has } = useCompare();
  const { scoreOf } = useRatings();
  const technical = technicalScore(phone);
  const user = scoreOf(phone);
  const index = globalIndex(technical, user.average);
  const selected = has(phone.id);

  return (
    <article className={`shop-card ${selected ? "selected" : ""}`}>
      <Link href={`/telefon/${phone.slug}`} className="shop-card-main">
        <div className="shop-card-media">
          <PhoneVisual phone={phone} size="lg" />
        </div>
        <small>{phone.brand}</small>
        <h3>{phone.name}</h3>
        <strong className="shop-card-price">{formatPrice(phone.priceTRY)}</strong>
        <p>
          {phone.year}
          {phone.memory.ram ? ` · ${phone.memory.ram} GB RAM` : ""}
          {phone.memory.storage ? ` · ${phone.memory.storage} GB` : ""}
        </p>
      </Link>
      <div className="shop-card-foot">
        <span>Endeks {index.toFixed(1)}</span>
        <button type="button" className={selected ? "chip active" : "chip"} onClick={() => toggle(phone.id)}>
          {selected ? "Seçildi" : "Kıyasla"}
        </button>
      </div>
    </article>
  );
}

export function PhoneCard({ phone }: { phone: Phone }) {
  const { toggle, has } = useCompare();
  const { scoreOf } = useRatings();
  const technical = technicalScore(phone);
  const user = scoreOf(phone);
  const selected = has(phone.id);

  return (
    <article className={`phone-card ${selected ? "selected" : ""}`}>
      <Link href={`/telefon/${phone.slug}`}>
        <PhoneVisual phone={phone} size="lg" />
        <small>{phone.brand}</small>
        <h3>{phone.name}</h3>
        <p>{phone.highlights[0]}</p>
      </Link>
      <div className="phone-card-foot">
        <ScorePill value={technical} label="Teknik" />
        <span>{user.average.toFixed(1)} / 10</span>
        <button type="button" className={selected ? "chip active" : "chip"} onClick={() => toggle(phone.id)}>
          {selected ? "Seçildi" : "Kıyasla"}
        </button>
      </div>
    </article>
  );
}
