import { Suspense } from "react";
import { CatalogClient } from "@/app/telefonlar/catalog-client";

export const metadata = {
  title: "Telefonlar",
};

export default function CatalogPage() {
  return (
    <Suspense>
      <CatalogClient />
    </Suspense>
  );
}
