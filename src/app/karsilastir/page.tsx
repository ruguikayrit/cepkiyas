import { Suspense } from "react";
import { CompareClient } from "@/app/karsilastir/compare-client";

export const metadata = {
  title: "Kıyasla",
};

export default function ComparePage() {
  return (
    <Suspense>
      <CompareClient />
    </Suspense>
  );
}
