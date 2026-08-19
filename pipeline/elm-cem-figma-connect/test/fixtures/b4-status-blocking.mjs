// Fixture for test/publish-check.test.mjs's publishability-guard tests
// (task B4). Stands in for a REAL src/visual/status.mjs (which does not
// exist yet — Plan C). Blocks "m3e-badge" specifically (status "pending",
// not in publish's pass|approved allowlist) so publish() must refuse and
// name it, while every other entry is publishable.
export function status(entry) {
  return entry.cemTag === "m3e-badge" ? "pending" : "approved";
}
