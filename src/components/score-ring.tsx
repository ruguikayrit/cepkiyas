import { formatScore } from "@/lib/format";
import { scoreTone } from "@/lib/score";

export function ScoreRing({
  value,
  label,
  size = 72,
}: {
  value: number;
  label?: string;
  size?: number;
}) {
  const safe = Number.isFinite(value) ? value : 0;
  const tone = scoreTone(safe);
  const radius = 18;
  const circ = 2 * Math.PI * radius;
  const offset = circ - (Math.min(safe, 100) / 100) * circ;

  return (
    <div className="score-ring" style={{ width: size, height: size }}>
      <svg viewBox="0 0 44 44" width={size} height={size}>
        <circle cx="22" cy="22" r={radius} className="score-ring-track" />
        <circle
          cx="22"
          cy="22"
          r={radius}
          className={`score-ring-value tone-${tone}`}
          strokeDasharray={circ}
          strokeDashoffset={offset}
        />
      </svg>
      <div className="score-ring-label">
        <strong>{formatScore(safe)}</strong>
        {label ? <span>{label}</span> : null}
      </div>
    </div>
  );
}

export function ScorePill({ value, label }: { value: number; label: string }) {
  return (
    <div className={`score-pill tone-${scoreTone(value)}`}>
      <em>{formatScore(value)}</em>
      <span>{label}</span>
    </div>
  );
}
