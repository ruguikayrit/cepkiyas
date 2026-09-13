import Link from "next/link";
import { notFound } from "next/navigation";
import { getPhone, officialPhones, phones } from "@/data/phones";
import { PhoneVisual } from "@/components/phone-visual";
import { RatingPanel } from "@/components/rating-panel";
import { SpecTable } from "@/components/spec-table";
import { DetailActions } from "@/app/telefon/[slug]/detail-actions";
import { DetailScores } from "@/app/telefon/[slug]/detail-scores";
import { formatCapacity, formatPrice } from "@/lib/format";
import { categoryScores } from "@/lib/score";

export const dynamicParams = true;

export function generateStaticParams() {
  return officialPhones.map((phone) => ({ slug: phone.slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const phone = getPhone(slug);
  return {
    title: phone?.fullName ?? "Telefon",
    description: phone ? `${phone.fullName} teknik özellikleri, puanları ve kıyası.` : undefined,
  };
}

export default async function PhonePage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const phone = getPhone(slug);
  if (!phone) notFound();

  const cats = categoryScores(phone);
  const similar = phones
    .filter((item) => item.id !== phone.id && item.brand === phone.brand)
    .sort((a, b) => Number(Boolean(b.image)) - Number(Boolean(a.image)))
    .slice(0, 3);

  return (
    <div className="shell">
      <div className="detail-hero">
        <PhoneVisual phone={phone} size="lg" />
        <div>
          <small className="mute">
            {phone.brand} · {phone.year}
          </small>
          <h1 style={{ margin: "6px 0 8px", letterSpacing: "-0.04em", fontSize: 36 }}>{phone.fullName}</h1>
          <p className="mute">{phone.highlights.join(" · ")}</p>
          <p style={{ marginTop: 12 }}>
            <strong>{formatPrice(phone.priceTRY)}</strong>
          </p>
          <p className="mute" style={{ marginTop: 8, fontSize: 12 }}>
            {/apple\.com|samsung\.com|mi\.com|google\.com|oneplus|nothing\.tech|honor\.com|oppo\.com|vivo\.com|po\.co|huawei\.com|realme\.com/.test(
              phone.sourceUrl,
            ) ? (
              <>
                Teknik veriler{" "}
                <a href={phone.sourceUrl} target="_blank" rel="noreferrer" style={{ color: "var(--mint)" }}>
                  resmi üretici sayfasından
                </a>
              </>
            ) : phone.sourceUrl.includes("wikipedia.org") || phone.sourceUrl.includes("wikidata.org") ? (
              <>
                Özellikler Wikipedia / Wikidata kayıtlarıyla çapraz kontrol edildi.{" "}
                <a href={phone.sourceUrl} target="_blank" rel="noreferrer" style={{ color: "var(--mint)" }}>
                  Kaynak
                </a>
              </>
            ) : (
              "Katalog kaydı. Ayrıntılı resmi ölçüm henüz eklenmedi."
            )}
          </p>
          <div className="chip-list" style={{ marginTop: 12 }}>
            {phone.colors.map((color) => (
              <span key={color.name}>{color.name}</span>
            ))}
          </div>
          <DetailActions id={phone.id} />
        </div>
        <DetailScores phone={phone} />
      </div>

      <div className="key-grid">
        <div>
          <small>Ekran</small>
          <strong>
            {phone.display.size ? `${phone.display.size}" ${phone.display.refreshRate} Hz` : "Belirtilmedi"}
          </strong>
        </div>
        <div>
          <small>Bellek</small>
          <strong>
            {phone.memory.ram || phone.memory.storage
              ? `${phone.memory.ram || "—"} / ${phone.memory.storage || "—"} GB`
              : "Belirtilmedi"}
          </strong>
        </div>
        <div>
          <small>Batarya</small>
          <strong>
            {formatCapacity(phone.battery.capacity, phone.battery.capacityNote)}
            {phone.battery.wiredWatt ? ` · ${phone.battery.wiredWatt} W` : ""}
          </strong>
        </div>
        <div>
          <small>Yonga</small>
          <strong>{phone.performance.chipset}</strong>
        </div>
      </div>

      <div className="key-grid">
        {Object.entries(cats).map(([key, value]) => (
          <div key={key}>
            <small>Teknik · {key}</small>
            <strong>{value.toFixed(1)}</strong>
          </div>
        ))}
      </div>

      <RatingPanel phone={phone} />
      <SpecTable phone={phone} />

      {similar.length > 0 ? (
        <>
          <div className="section-head">
            <h2>Yakın modeller</h2>
          </div>
          <div className="brand-row">
            {similar.map((item) => (
              <Link key={item.id} href={`/telefon/${item.slug}`}>
                {item.fullName}
              </Link>
            ))}
          </div>
        </>
      ) : null}
    </div>
  );
}
