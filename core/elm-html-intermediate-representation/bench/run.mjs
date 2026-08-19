// Driver for bench/src/Bench.elm. Reporting only — deliberately NOT a gate:
// microbenchmark thresholds in CI are flaky, and the number is what reviewers
// need, not a pass/fail bit.
//
// Timing note: the Elm work runs SYNCHRONOUSLY inside `ports.request.send`,
// but outgoing-port callback DELIVERY is deferred, so checksums are collected
// at the end rather than per call. `assertSynchronous` re-verifies the timing
// assumption on every run instead of trusting it.

import { createRequire } from "node:module";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);
const mod = require(path.join(here, "bench.js"));
const app = ((mod && mod.Elm) || globalThis.Elm).Bench.init({});

const seen = [];
app.ports.result.subscribe((v) => seen.push(v));

const ITERS = Number(process.env.ITERS || 200000);
const ROUNDS = Number(process.env.ROUNDS || 7);
const SHAPES = ["small", "typical", "heavy", "bools"];
const VARIANTS = ["legacy", "merged"];

function time(name, iters) {
  const t0 = process.hrtime.bigint();
  app.ports.request.send([name, iters]);
  return Number(process.hrtime.bigint() - t0) / 1e6;
}

function assertSynchronous() {
  // If the work were deferred, elapsed would not scale with iteration count.
  const small = time("typical/legacy", 50000);
  const large = time("typical/legacy", 400000);
  if (large < small * 3) {
    console.error(
      `FATAL: work does not appear synchronous inside port.send ` +
        `(50k took ${small.toFixed(1)}ms, 400k took ${large.toFixed(1)}ms). ` +
        `Timings would be meaningless.`,
    );
    process.exit(1);
  }
}

assertSynchronous();
for (const s of SHAPES) for (const v of VARIANTS) time(`${s}/${v}`, 20000); // warm up

const results = {};
// Interleaved rounds so drift and thermal effects hit both variants equally.
for (let r = 0; r < ROUNDS; r++)
  for (const s of SHAPES)
    for (const v of VARIANTS) {
      const k = `${s}/${v}`;
      (results[k] = results[k] || []).push(time(k, ITERS));
    }

const median = (a) => a.slice().sort((x, y) => x - y)[a.length >> 1];

console.log(`iters=${ITERS} rounds=${ROUNDS} node=${process.version}`);
console.log(`(full node construction: attributes + VirtualDom.node)\n`);
console.log("shape     legacy ns/node   merged ns/node   overhead   added");
for (const s of SHAPES) {
  const legacy = median(results[`${s}/legacy`]);
  const merged = median(results[`${s}/merged`]);
  const ns = (ms) => ((ms * 1e6) / ITERS).toFixed(0);
  console.log(
    s.padEnd(9),
    ns(legacy).padStart(14),
    ns(merged).padStart(16),
    `${((merged / legacy - 1) * 100).toFixed(1)}%`.padStart(10),
    `${ns(merged - legacy)}ns`.padStart(8),
  );
}

const perNode = (median(results["typical/merged"]) - median(results["typical/legacy"])) * 1e6 / ITERS;
console.log(
  `\nA full 1000-node re-render pays ~${((perNode * 1000) / 1e6).toFixed(2)} ms ` +
    `of this — for scale, a 60fps frame budget is 16.7 ms.`,
);

// Callback delivery is deferred, so this must run after the event loop turns.
setTimeout(() => {
  if (seen.length === 0) {
    console.error("\nFATAL: no checksums delivered — the harness measured nothing.");
    process.exit(1);
  }
  const bad = seen.filter((v) => v !== ITERS && v !== 20000 && v !== 50000 && v !== 400000);
  if (bad.length) {
    console.error(`\nFATAL: unexpected checksums (work() returned -1?): ${bad.slice(0, 5)}`);
    process.exit(1);
  }
}, 0);
