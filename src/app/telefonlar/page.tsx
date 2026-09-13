import { Suspense } from "react";
import { CatalogClient } from "@/app/telefonlar/catalog-client";

export const metadata = {
  title: "Katalog",
};

export default function CatalogPage() {
  return (
    <Suspense>
      <CatalogClient />
    </Suspense>
  );
}
