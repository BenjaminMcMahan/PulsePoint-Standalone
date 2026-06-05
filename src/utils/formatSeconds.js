export function formatSecondsAsMinutesSeconds(value, { compact = false } = {}) {
  const sec = Math.max(0, Math.round(Number(value) || 0));
  const minutes = Math.floor(sec / 60);
  const seconds = sec % 60;

  if (!minutes) {
    return compact ? `${seconds}s` : `${seconds} second${seconds === 1 ? "" : "s"}`;
  }
  if (!seconds) {
    return compact ? `${minutes}m` : `${minutes} minute${minutes === 1 ? "" : "s"}`;
  }
  return compact
    ? `${minutes}m ${seconds}s`
    : `${minutes} minute${minutes === 1 ? "" : "s"} and ${seconds} second${seconds === 1 ? "" : "s"}`;
}

/**
 * Converts raw second values in user-facing text to minutes + seconds.
 * Keeps short sub-minute values as seconds.
 */
export function fmtSecondsInText(text) {
  if (!text) return text;
  return String(text)
    .replace(/\b(\d{2,})\s*seconds?\b/gi, (match, n) => {
      const sec = Math.round(Number(n));
      if (!Number.isFinite(sec) || sec < 60) return match;
      return formatSecondsAsMinutesSeconds(sec);
    })
    .replace(/\b(\d{3,})s\b/g, (match, n) => {
      const sec = Math.round(Number(n));
      if (!Number.isFinite(sec) || sec < 60) return match;
      return formatSecondsAsMinutesSeconds(sec);
    });
}

export function fmtSecondsInCompactText(text) {
  if (!text) return text;
  return String(text).replace(/\b(\d{3,})\s*seconds?\b/gi, (_, n) => {
    const sec = Math.round(Number(n));
    if (sec < 100) return `${sec}s`;
    return formatSecondsAsMinutesSeconds(sec, { compact: true });
  });
}
