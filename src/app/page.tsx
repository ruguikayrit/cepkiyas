import Link from "next/link";
import { officialPhones, phones } from "@/data/phones";
import { PhoneCard } from "@/components/phone-card";
import { technicalScore } from "@/lib/score";
import { comparePath } from "@/lib/compare";

const duels = [
  ["iphone-16-pro-max", "galaxy-s25-ultra"],
  ["pixel-9-pro-xl", "xiaomi-15-ultra"],
  ["oneplus-13", "vivo-x200-pro"],
  ["poco-f7-ultra", "redmi-note-14-pro-plus"],
];

export default function Home() {
  const featured = [...officialPhones].sort((a, b) => technicalScore(b) - technicalScore(a)).slice(0, 4);
  const brands = [...new Set(phones.map((phone) => phone.brand))].sort();

  return (
    <div className="shell">
      <div className="section-head">
        <h2>Teknik skoru en yüksekler</h2>
        <Link href="/katalog/telefon" className="mute">
          Tüm katalog →
        </Link>
      </div>
      <div className="card-grid">
        {featured.map((phone) => (
          <PhoneCard key={phone.id} phone={phone} />
        ))}
      </div>

      <div className="section-head">
        <h2>Hazır düellolar</h2>
      </div>
      <div className="duel-grid">
        {duels.map(([a, b]) => {
          const left = phones.find((phone) => phone.slug === a);
          const right = phones.find((phone) => phone.slug === b);
          if (!left || !right) return null;
          return (
            <Link key={`${a}-${b}`} href={comparePath([a, b])} className="duel">
              <div>
                <small>{left.brand}</small>
                <strong>{left.name}</strong>
              </div>
              <span className="mute">vs</span>
              <div>
                <small>{right.brand}</small>
                <strong>{right.name}</strong>
              </div>
            </Link>
          );
        })}
      </div>

      <div className="section-head">
        <h2>Markalar</h2>
      </div>
      <div className="brand-row">
        {brands.map((brand) => (
          <Link
            key={brand}
            href={`/katalog/telefon?gorunum=markalar&marka=${encodeURIComponent(brand)}`}
          >
            {brand}
          </Link>
        ))}
      </div>
    </div>
  );
}
