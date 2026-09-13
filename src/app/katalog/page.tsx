import Link from "next/link";
import { phones } from "@/data/phones";
import { buildBrandIndex, topBrands } from "@/lib/catalog-grouping";
import { categoryHref, productCategories } from "@/lib/catalog-taxonomy";

export const metadata = {
  title: "Katalog",
};

export default function CatalogHubPage() {
  const phoneCount = phones.length;
  const featured = topBrands(phones, 16);
  const brandTotal = buildBrandIndex(phones).length;

  return (
    <div className="shell catalog-hub">
      <header className="catalog-hub-hero">
        <div>
          <small className="mute">TeknoKıyas kataloğu</small>
          <h1>Ne kıyaslamak istiyorsun?</h1>
          <p className="mute">
            Önce ürün grubu, sonra marka ve seri, en sonda model. Filtre, arama ve kıyas aynı akışta kalır.
          </p>
        </div>
        <div className="catalog-hub-stats">
          <div className="stat">
            <strong>{phoneCount.toLocaleString("tr-TR")}</strong>
            <span className="mute">Telefon</span>
          </div>
          <div className="stat">
            <strong>{brandTotal}</strong>
            <span className="mute">Marka</span>
          </div>
          <div className="stat">
            <strong>{productCategories.length}</strong>
            <span className="mute">Ürün grubu</span>
          </div>
        </div>
      </header>

      <section>
        <h2>Ürün grupları</h2>
        <div className="catalog-hub-grid">
          {productCategories.map((cat) => {
            const active = cat.status === "active";
            const count = cat.id === "telefon" ? phoneCount : undefined;
            const inner = (
              <>
                <strong>{cat.label}</strong>
                <p>{cat.description}</p>
                {active && count != null ? (
                  <span className="catalog-hub-count">{count.toLocaleString("tr-TR")} model</span>
                ) : (
                  <span className="catalog-hub-soon">Yakında</span>
                )}
              </>
            );
            return active ? (
              <Link key={cat.id} href={categoryHref(cat.slug)} className="catalog-hub-card active">
                {inner}
              </Link>
            ) : (
              <div key={cat.id} className="catalog-hub-card">
                {inner}
              </div>
            );
          })}
        </div>
      </section>

      <section>
        <div className="section-head">
          <h2>Öne çıkan telefon markaları</h2>
          <Link href="/katalog/telefon?gorunum=markalar" className="mute">
            Tüm markalar →
          </Link>
        </div>
        <div className="brand-row">
          {featured.map(({ brand, count }) => (
            <Link
              key={brand}
              href={`/katalog/telefon?gorunum=markalar&marka=${encodeURIComponent(brand)}`}
            >
              {brand}
              <small>{count}</small>
            </Link>
          ))}
        </div>
      </section>

      <section className="catalog-hub-cta">
        <Link href="/katalog/telefon" className="btn">
          Telefon kataloğuna git
        </Link>
        <Link href="/katalog/telefon?gorunum=markalar" className="ghost">
          Marka & seri dizini
        </Link>
      </section>
    </div>
  );
}
