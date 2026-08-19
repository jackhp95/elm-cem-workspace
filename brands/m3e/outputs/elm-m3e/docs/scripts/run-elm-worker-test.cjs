// Generic node runner for self-checking `Platform.worker` Elm test modules
// (compiled with `elm make`) that emit a structured `RESULT ok=<passed>/<total>`
// line through an `emit : String -> Cmd msg` port. See tests/FoldTest.elm and
// tests/ScaleTest.elm for the pattern this expects.
// Usage: node scripts/run-elm-worker-test.cjs <compiled-elm.js> <ModuleName>
const { Elm } = require(require("path").resolve(process.argv[2]));
const moduleName = process.argv[3];
const app = Elm[moduleName].init();
app.ports.emit.subscribe((out) => {
  console.log(out);
  // Exit code keys off the harness's structured `RESULT ok=<passed>/<total>`
  // line — never a substring match on human-readable PASS/FAIL text (a case
  // *named* with "FAIL" must not false-positive the run).
  const m = out.match(/^RESULT ok=(\d+)\/(\d+)$/m);
  if (!m) {
    console.error("run-elm-worker-test: missing structured RESULT line");
    process.exit(2);
  }
  process.exit(Number(m[1]) === Number(m[2]) ? 0 : 1);
});
