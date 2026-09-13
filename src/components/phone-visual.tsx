import type { Phone } from "@/types/phone";

export function PhoneVisual({
  phone,
  size = "md",
}: {
  phone: Phone;
  size?: "sm" | "md" | "lg";
}) {
  return (
    <div className={`phone-visual size-${size}`} aria-hidden={size === "sm"}>
      {phone.image ? (
        <img src={phone.image} alt={size === "sm" ? "" : phone.fullName} className="phone-visual-photo" />
      ) : (
        <div
          className="phone-visual-fallback"
          style={{ background: `linear-gradient(160deg, ${phone.accent} 0%, #0c0d10 72%)` }}
        >
          <span>{phone.brand}</span>
        </div>
      )}
    </div>
  );
}
