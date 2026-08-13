// Fixture for test/publish-check.test.mjs's task-C7 per-binding-gate tests.
// Stands in for a REAL src/visual/status.mjs the same way
// b4-status-blocking.mjs/b4-status-passing.mjs do (task B4/C6), but reports
// "failed" (not "pending") for "m3e-badge" specifically, WITH a diffPaths
// export — so the gate's "for `failed`, surface the diff artifact path"
// requirement (this task's brief) can be exercised without any real
// render-cache/results/ setup. "m3e-bottom-sheet" is publishable.
export function status(entry) {
  return entry.cemTag === "m3e-badge" ? "failed" : "pass";
}

export function diffPaths(entry) {
  return entry.cemTag === "m3e-badge" ? ["/fake/render-cache/diffs/m3e-badge__default.png"] : [];
}
