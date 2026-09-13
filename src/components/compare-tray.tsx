"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useCompare } from "@/context/compare-context";
import { PhoneVisual } from "@/components/phone-visual";
import { comparePath } from "@/lib/compare";

export function CompareTray() {
  const { phones, remove, clear } = useCompare();
  const pathname = usePathname();

  if (phones.length === 0 || pathname === "/karsilastir") return null;

  return (
    <div className="compare-tray">
      <div className="shell tray-inner">
        <div className="tray-phones">
          {phones.map((phone) => (
            <div key={phone.id} className="tray-phone">
              <PhoneVisual phone={phone} size="sm" />
              <span>{phone.name}</span>
              <button type="button" onClick={() => remove(phone.id)} aria-label="Çıkar">
                ×
              </button>
            </div>
          ))}
        </div>
        <div className="tray-actions">
          <button type="button" className="ghost" onClick={clear}>
            Temizle
          </button>
          <Link
            href={comparePath(phones.map((phone) => phone.slug))}
            className={phones.length < 2 ? "btn disabled" : "btn"}
            aria-disabled={phones.length < 2}
          >
            Kıyasla{phones.length > 1 ? ` (${phones.length})` : ""}
          </Link>
        </div>
      </div>
    </div>
  );
}
