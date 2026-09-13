import { notFound } from "next/navigation";
import { Suspense } from "react";
import { CatalogClient } from "@/app/telefonlar/catalog-client";
import { getCategory } from "@/lib/catalog-taxonomy";

export function generateStaticParams() {
  return [{ category: "telefon" }];
}

export async function generateMetadata({ params }: { params: Promise<{ category: string }> }) {
  const { category: slug } = await params;
  const cat = getCategory(slug);
  if (!cat) return { title: "Katalog" };
  return { title: cat.label };
}

export default async function CatalogCategoryPage({ params }: { params: Promise<{ category: string }> }) {
  const { category: slug } = await params;
  const cat = getCategory(slug);
  if (!cat) notFound();

  if (cat.status === "soon") {
    return (
      <div className="shell catalog-soon">
        <h1>{cat.label}</h1>
        <p className="mute">{cat.description}</p>
        <p>Bu ürün grubu kataloga ekleniyor. Şimdilik telefon kataloğunu kullanabilirsin.</p>
        <a href="/katalog/telefon" className="btn">
          Telefonlara git
        </a>
      </div>
    );
  }

  if (slug !== "telefon") notFound();

  return (
    <Suspense>
      <CatalogClient categorySlug={slug} />
    </Suspense>
  );
}
