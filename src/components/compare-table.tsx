"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { specGroups } from "@/data/spec-schema";
import { PhoneVisual } from "@/components/phone-visual";
import { ScoreRing } from "@/components/score-ring";
import { useCompare } from "@/context/compare-context";
import { useRatings } from "@/context/ratings-context";
import { displaySpec, rowHasDifference, winnersForRow } from "@/lib/compare";
import { formatPrice } from "@/lib/format";
import { globalIndex, technicalScore } from "@/lib/score";
import type { Phone } from "@/types/phone";

export function CompareTable({ phones }: { phones: Phone[] }) {
  const [diffOnly, setDiffOnly] = useState(false);
  const { remove } = useCompare();
  const { scoreOf } = useRatings();

  const scored = useMemo(
    () =>
      phones.map((phone) => {
        const technical = technicalScore(phone);
        const user = scoreOf(phone);
        return { phone, technical, user, index: globalIndex(technical, user.average) };
      }),
    [phones, scoreOf],
  );

  return (
    <div className="compare-wrap">
      <div className="compare-toolbar">
        <label>
          <input type="checkbox" checked={diffOnly} onChange={(event) => setDiffOnly(event.target.checked)} />
          Sadece farklar
        </label>
        <span className="mute">Yeşil hücre, o satırdaki daha iyi değeri gösterir.</span>
      </div>

      <div className="compare-scroll">
        <table className="compare-table">
          <thead>
            <tr>
              <th />
              {scored.map(({ phone, technical, user, index }) => (
                <th key={phone.id}>
                  <div className="compare-head">
                    <button type="button" className="ghost mini" onClick={() => remove(phone.id)}>
                      Çıkar
                    </button>
                    <PhoneVisual phone={phone} />
                    <Link href={`/telefon/${phone.slug}`}>{phone.fullName}</Link>
                    <small>{formatPrice(phone.priceTRY)}</small>
                    <div className="compare-scores">
                      <ScoreRing value={technical} label="Teknik" size={64} />
                      <ScoreRing value={user.average * 10} label="Kullanıcı" size={64} />
                      <ScoreRing value={index} label="Endeks" size={64} />
                    </div>
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {specGroups.map((group) => {
              const rows = group.rows.filter((row) => !diffOnly || rowHasDifference(phones, row));
              if (rows.length === 0) return null;
              return (
                <CompareGroup key={group.id} label={group.label} colSpan={phones.length + 1}>
                  {rows.map((row) => {
                    const winners = winnersForRow(phones, row);
                    return (
                      <tr key={row.id}>
                        <th>{row.label}</th>
                        {phones.map((phone) => (
                          <td key={phone.id} className={winners.includes(phone.id) ? "win" : undefined}>
                            {row.id === "price" ? formatPrice(phone.priceTRY) : displaySpec(phone, row)}
                          </td>
                        ))}
                      </tr>
                    );
                  })}
                </CompareGroup>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function CompareGroup({
  label,
  colSpan,
  children,
}: {
  label: string;
  colSpan: number;
  children: React.ReactNode;
}) {
  return (
    <>
      <tr className="group-row">
        <th colSpan={colSpan}>{label}</th>
      </tr>
      {children}
    </>
  );
}

