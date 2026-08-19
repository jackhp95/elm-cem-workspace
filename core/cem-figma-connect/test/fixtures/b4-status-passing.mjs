// Fixture for test/publish-check.test.mjs's publishability-guard tests
// (task B4). Stands in for a REAL src/visual/status.mjs (which does not
// exist yet — Plan C) so publish()'s "module present" branch can be
// exercised without ever creating a file at that real path. Every entry
// reads as publishable.
export function status(_entry) {
  return "approved";
}
