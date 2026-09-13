export type CategoryStatus = "active" | "soon";

export interface ProductCategory {
  id: string;
  slug: string;
  label: string;
  shortLabel: string;
  description: string;
  status: CategoryStatus;
  /** Product count when active; omit for upcoming categories */
  count?: number;
}

export const productCategories: ProductCategory[] = [
  {
    id: "telefon",
    slug: "telefon",
    label: "Telefon",
    shortLabel: "Telefon",
    description: "Akıllı telefonlar · teknik puan · kıyas · kullanıcı oyu",
    status: "active",
  },
  {
    id: "tablet",
    slug: "tablet",
    label: "Tablet",
    shortLabel: "Tablet",
    description: "iPad, Galaxy Tab ve diğer tabletler",
    status: "soon",
  },
  {
    id: "bilgisayar",
    slug: "bilgisayar",
    label: "Bilgisayar",
    shortLabel: "PC",
    description: "Dizüstü, masaüstü ve mini PC",
    status: "soon",
  },
  {
    id: "akilli-saat",
    slug: "akilli-saat",
    label: "Akıllı saat",
    shortLabel: "Saat",
    description: "Apple Watch, Galaxy Watch ve benzeri",
    status: "soon",
  },
  {
    id: "kulaklik",
    slug: "kulaklik",
    label: "Kulaklık",
    shortLabel: "Kulaklık",
    description: "Kablosuz ve kablolu kulaklıklar",
    status: "soon",
  },
  {
    id: "televizyon",
    slug: "televizyon",
    label: "Televizyon",
    shortLabel: "TV",
    description: "Smart TV ve monitör-TV",
    status: "soon",
  },
];

export function getCategory(slug: string) {
  return productCategories.find((item) => item.slug === slug);
}

export function categoryHref(slug: string) {
  return `/katalog/${slug}`;
}
