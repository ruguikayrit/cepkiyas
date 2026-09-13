import { specGroups } from "@/data/spec-schema";
import { boolLabel, formatPrice } from "@/lib/format";
import type { Phone } from "@/types/phone";

export function SpecTable({ phone }: { phone: Phone }) {
  return (
    <div className="spec-stack">
      {specGroups.map((group) => (
        <section key={group.id} className="spec-block">
          <h3>{group.label}</h3>
          <dl>
            {group.rows.map((row) => {
              const raw = row.value(phone);
              const text =
                row.id === "price" && typeof raw === "number"
                  ? formatPrice(raw)
                  : typeof raw === "boolean"
                    ? boolLabel(raw)
                    : String(raw);
              return (
                <div key={row.id}>
                  <dt>{row.label}</dt>
                  <dd>{text}</dd>
                </div>
              );
            })}
          </dl>
        </section>
      ))}
      <section className="spec-block">
        <h3>Sensörler</h3>
        <p className="chip-list">
          {phone.sensors.map((sensor) => (
            <span key={sensor}>{sensor}</span>
          ))}
        </p>
        <h3 style={{ marginTop: 18 }}>Kamera özellikleri</h3>
        <p className="chip-list">
          {phone.camera.features.map((feature) => (
            <span key={feature}>{feature}</span>
          ))}
        </p>
      </section>
    </div>
  );
}
