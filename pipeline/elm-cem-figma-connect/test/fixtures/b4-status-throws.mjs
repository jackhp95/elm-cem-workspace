// Fixture for test/publish-check.test.mjs's regression test for the
// live-test finding: `statusFn` throwing for ONE cemTag must not kill the
// whole publish run. Stands in for a REAL src/visual/status.mjs the same
// way b4-status-{passing,blocking,failing}.mjs do, but THROWS for
// "m3e-badge" specifically (simulating src/visual/status.mjs -> sample.mjs
// -> drive.mjs's definitionsFor throwing on a data shape it can't derive
// axis defaults from) while "m3e-bottom-sheet" remains publishable.
export function status(entry) {
  if (entry.cemTag === "m3e-badge") {
    throw new Error("fixture: simulated statusFn throw for m3e-badge");
  }
  return "pass";
}
