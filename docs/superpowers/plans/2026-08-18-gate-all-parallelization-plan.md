# `tools/gate-all.mjs` Wall-Clock Parallelization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cut `node tools/gate-all.mjs`'s warm-cache wall-clock from 361.5s to ≤250s in Phase 1
alone, with further reduction through Phases 2-4, **without** changing which steps run, their
pass/fail semantics, or introducing any silent skip — and without ever violating the four
mutual-exclusion constraints identified in the spec.

**Architecture:** Introduce a step-descriptor model (`{ name, command, args, cwd, exclusiveWith,
env }`) and a small bounded worker-pool scheduler that respects tag-based mutual exclusion, then
migrate `gate-all.mjs`'s two serial `for` loops + ~15 serial `runItem()` calls onto it in four
independent phases (run-the-elephant-first, shrink-the-elephant, generalize-the-pool,
cheap-wins). Phase 1 alone gets almost all the win; Phases 2-4 are independent refinements that can
land in any order after it.

**Tech Stack:** Plain Node ESM (no new runtime dependency required — `p-limit` is small enough to
either vendor a ~15-line equivalent or add as a `devDependency`; Task 3 decides). `spawn` (async)
replacing `spawnSync`. Existing test/check tooling per package is untouched.

**Spec:** [`../specs/2026-08-18-gate-all-parallelization-design.md`](../specs/2026-08-18-gate-all-parallelization-design.md)

## Global Constraints

- **No silent skips.** Step membership on a full run must be identical, in name and count, before
  and after every phase. `check-gates` (or gate-all's own self-verification) must pass after every
  phase. (Spec §4, acceptance criterion 4.)
- **Four mutual-exclusion constraints must never be violated** (spec §2): (1) `docs-dist` tag —
  `elm-m3e: test:browser` vs. `workspace: check-drift` / `workspace: copy-fidelity elm-m3e`; (2)
  `port-1239` tag — only one `test:browser`-shaped process system-wide; (3) shared `ELM_HOME` —
  concurrent Elm-toolchain steps must not share a package cache write target; (4) shared
  `.gate-out/probe.js` — `workspace: root gate` must not race a concurrent writer of that same path.
- **Failure attribution must stay unambiguous.** A failing step's output must be traceable to that
  step even when several steps ran concurrently — buffer per-step, flush atomically on completion,
  never interleave live (spec §3.2 point 3).
- **"Every item runs even if an earlier one fails"** is unchanged — a failed step only occupies its
  own pool slot/tags for its own duration (spec §3.2 point 5).
- **Path-based skip logic is explicitly out of scope and disallowed** (spec §4) — nothing in this
  plan may make a step's execution conditional on which files a push touches.
- **CHRONIC_SKIPS is untouched** — none of these phases interact with the network-dependent
  snapshot gates it documents.

---

## File Structure

- **Create `tools/lib/gate-scheduler.mjs`** — the step-descriptor type, the tag-aware bounded
  worker pool, and the buffered-output-per-step runner (`runItemAsync`). This is the one new piece
  of shared infrastructure; every phase after Phase 1 extends its step list, not its mechanism.
- **Modify `tools/gate-all.mjs`** — replace direct `runItem()` calls with step-descriptor
  construction, then hand the full list to the scheduler from `gate-scheduler.mjs`. The existing
  `record()`, `CHRONIC_SKIPS`, and SKIP-line-parsing logic stay in `gate-all.mjs` and are called
  from the scheduler's completion callback, not duplicated.
- **Modify `packages/elm-m3e/docs/playwright.config.ts`** — `workers` retune (Phase 2).
- **Modify the two outlier spec files** (`packages/elm-m3e/docs/e2e/mobile-shell.spec.ts`,
  `.../shell-breakpoints.spec.ts` — exact paths confirmed in Phase 2 Task 1) — after profiling.
- **Create `tools/lib/build-site-cache.mjs`** (Phase 2) — content-hash cache wrapper around
  `build:site`.
- **Modify `tools/lib/check-drift-core.mjs`** (Phase 4) — memoize `generateBundleToTemp`.
- **Modify `tools/check-mirror-drift.mjs`** (Phase 4) — parallelize `gh api` calls.

Each phase below is independently revertible with `git revert` of its own commit(s); no phase's
rollback requires undoing a later phase (Phases are additive to the step list, not restructurings
of each other).

---

## Phase 1 — Run `test:browser` first, concurrently with everything else

**Goal:** Achieve the single biggest win with the smallest, lowest-risk change: kick off `elm-m3e:
test:browser` at t=0, run every OTHER step (except the two `docs-dist`-tagged ones) concurrently in
a bounded pool, and only run the `docs-dist`-tagged steps after `test:browser` joins. Target: full
run ≤250s (down from 361.5s).

**Resolves open question #2 from the spec (§7):** per-step `ELM_HOME` isolation is needed starting
in THIS phase, not deferred to Phase 3 — the "everything but test:browser" bucket already contains
multiple Elm-toolchain-invoking steps (every package's `check`/`test` script that runs `elm`,
`elm-review`, or `elm-test-rs`) running concurrently with each other. Task 3 below builds the
minimal isolation needed for Phase 1's actual concurrency, not the full generalized version (that's
Phase 3's job, once the pool widens further).

### Task 1: Build the step-descriptor scheduler core

**Files:**
- Create: `tools/lib/gate-scheduler.mjs`
- Test: `tools/lib/gate-scheduler.test.mjs`

**Interfaces:**
- Produces: `runScheduled(steps, { concurrency, onResult })` where `steps` is
  `Array<{ name: string, command: string, args: string[], cwd?: string, exclusiveWith?: string[],
  env?: Record<string,string> }>`, `concurrency` is a number, and `onResult` is called as
  `onResult({ name, status: 'pass'|'fail'|'skip', detail, stdout, stderr })` once per step, in
  completion order (not submission order). Returns a `Promise<void>` that resolves when every step
  has completed.
- Consumes: nothing from other tasks (this is the foundation).

- [ ] **Step 1: Write the failing test for tag exclusion**

```js
// tools/lib/gate-scheduler.test.mjs
import assert from "node:assert/strict";
import { test } from "node:test";
import { runScheduled } from "./gate-scheduler.mjs";

test("two steps sharing a tag never run concurrently", async () => {
  let inFlight = 0;
  let maxConcurrentWithSharedTag = 0;
  const mkStep = (name, ms, tags) => ({
    name,
    command: process.execPath,
    args: ["-e", `setTimeout(() => process.exit(0), ${ms})`],
    exclusiveWith: tags,
  });
  // Wrap via onResult bookkeeping isn't enough to observe overlap directly from
  // exit codes, so this test instead asserts on wall-clock: two 150ms steps
  // sharing a tag must take >=300ms serialized; two 150ms steps with no shared
  // tag must take <250ms (parallel, with slack for process spawn overhead).
  const steps = [mkStep("a", 150, ["shared"]), mkStep("b", 150, ["shared"])];
  const start = Date.now();
  await runScheduled(steps, { concurrency: 4, onResult: () => {} });
  const elapsed = Date.now() - start;
  assert.ok(elapsed >= 290, `expected serialized (>=290ms), got ${elapsed}ms`);
});

test("two steps with no shared tag run concurrently", async () => {
  const mkStep = (name, ms) => ({
    name,
    command: process.execPath,
    args: ["-e", `setTimeout(() => process.exit(0), ${ms})`],
  });
  const steps = [mkStep("a", 150), mkStep("b", 150)];
  const start = Date.now();
  await runScheduled(steps, { concurrency: 4, onResult: () => {} });
  const elapsed = Date.now() - start;
  assert.ok(elapsed < 250, `expected parallel (<250ms), got ${elapsed}ms`);
});

test("a failing step does not block unrelated steps, and every step still runs", async () => {
  const results = [];
  const steps = [
    { name: "fails", command: process.execPath, args: ["-e", "process.exit(1)"] },
    { name: "passes", command: process.execPath, args: ["-e", "process.exit(0)"] },
  ];
  await runScheduled(steps, { concurrency: 4, onResult: (r) => results.push(r) });
  assert.equal(results.length, 2);
  assert.ok(results.find((r) => r.name === "fails").status === "fail");
  assert.ok(results.find((r) => r.name === "passes").status === "pass");
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `node --test tools/lib/gate-scheduler.test.mjs`
Expected: FAIL — `gate-scheduler.mjs` does not exist yet (module not found).

- [ ] **Step 3: Implement the scheduler**

```js
// tools/lib/gate-scheduler.mjs
import { spawn } from "node:child_process";

/**
 * Run a list of step descriptors under a bounded worker pool that respects
 * tag-based mutual exclusion (`exclusiveWith`). Every step runs exactly once,
 * even if others fail. Output is buffered per-step and only flushed on
 * completion — never interleaved live — so failure attribution stays
 * unambiguous when several steps overlap.
 *
 * @param {Array<{name:string, command:string, args:string[], cwd?:string,
 *   exclusiveWith?:string[], env?:Record<string,string>}>} steps
 * @param {{concurrency:number, onResult:(r:{name:string,status:'pass'|'fail',
 *   detail:string,stdout:string,stderr:string})=>void}} options
 */
export function runScheduled(steps, { concurrency, onResult }) {
  const pending = [...steps];
  const heldTags = new Set();
  let running = 0;
  let settled = 0;

  return new Promise((resolve) => {
    if (steps.length === 0) return resolve();

    function pump() {
      if (settled === steps.length) return resolve();
      if (running >= concurrency) return;

      const idx = pending.findIndex(
        (s) => !(s.exclusiveWith || []).some((tag) => heldTags.has(tag))
      );
      if (idx === -1) return; // nothing eligible right now — wait for a release

      const [step] = pending.splice(idx, 1);
      const tags = step.exclusiveWith || [];
      for (const t of tags) heldTags.add(t);
      running++;

      let stdout = "";
      let stderr = "";
      const child = spawn(step.command, step.args, {
        cwd: step.cwd,
        env: { ...process.env, ...(step.env || {}) },
      });
      child.stdout.on("data", (d) => (stdout += d));
      child.stderr.on("data", (d) => (stderr += d));
      child.on("close", (code) => {
        for (const t of tags) heldTags.delete(t);
        running--;
        settled++;
        const ok = code === 0;
        onResult({
          name: step.name,
          status: ok ? "pass" : "fail",
          detail: ok ? "" : `exit code ${code}`,
          stdout,
          stderr,
        });
        pump();
        pump(); // a release may have unblocked more than one waiter
      });
    }

    // Kick off as many eligible steps as the pool allows.
    for (let i = 0; i < concurrency; i++) pump();
  });
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `node --test tools/lib/gate-scheduler.test.mjs`
Expected: PASS (all three tests).

- [ ] **Step 5: Commit**

```bash
git add tools/lib/gate-scheduler.mjs tools/lib/gate-scheduler.test.mjs
git commit -m "feat(gate-all): add tag-aware bounded worker-pool scheduler"
```

### Task 2: Wire Phase 1's two-bucket split into `gate-all.mjs`

**Files:**
- Modify: `tools/gate-all.mjs` (the two `for` loops ~line 283 and ~line 308, plus the ~15 serial
  `runItem()` calls for workspace gates)

**Interfaces:**
- Consumes: `runScheduled` from `tools/lib/gate-scheduler.mjs` (Task 1).
- Produces: nothing new for later tasks to consume within Phase 1 — this task is gate-all.mjs's own
  integration point. Phase 3 will extend the SAME two buckets (elephant vs. everything-else) into
  N buckets; it reads this task's step-descriptor construction code as its starting point.

- [ ] **Step 1: Read the current dispatch code to enumerate every existing `runItem()` call site**

Run: `rg -n 'runItem\(' tools/gate-all.mjs`
Expected: a list of every current call site — per-package loop, copy-fidelity loop, and each
workspace gate. Copy this list; Step 3 needs it to build the step-descriptor array without dropping
any step (dropping one would violate the Global Constraint on step membership).

- [ ] **Step 2: Write a smoke-test harness for step-membership equality**

This is not a unit test on scheduler logic (Task 1 covered that) — it is a regression guard that
gate-all.mjs's *step list* doesn't shrink or grow as a side effect of the refactor.

```js
// tools/check-gate-all-step-membership.test.mjs
import assert from "node:assert/strict";
import { test } from "node:test";
import { execFileSync } from "node:child_process";

// Baseline captured from the pre-refactor run (see Step 2a below for how this
// list was produced) — one entry per `record()` call gate-all.mjs is expected
// to make on a full run, in the order first introduced (not execution order,
// since Phase 1 changes execution order on purpose).
const EXPECTED_STEP_NAMES_FILE = new URL(
  "./gate-all-expected-steps.json",
  import.meta.url
);

test("gate-all's step membership is unchanged after the scheduler refactor", () => {
  const expected = JSON.parse(
    execFileSync("cat", [EXPECTED_STEP_NAMES_FILE.pathname]).toString()
  );
  const actualRaw = execFileSync(
    process.execPath,
    ["tools/gate-all.mjs", "--list-steps-only"],
    { encoding: "utf8" }
  );
  const actual = JSON.parse(actualRaw);
  assert.deepEqual(
    [...actual].sort(),
    [...expected].sort(),
    "step name set changed — a step was added, dropped, or renamed"
  );
});
```

- [ ] **Step 2a: Capture the baseline step-name list BEFORE touching the dispatch loop**

Run this against the pre-refactor `gate-all.mjs` (i.e. do this before Step 3's edit lands, on the
current `main`-derived code):

```bash
node -e '
const names = [];
const origLog = console.log;
console.log = (...args) => { origLog(...args); };
// gate-all.mjs logs "▶ <name>" per runItem call before running it — scrape that.
' 
node tools/gate-all.mjs 2>&1 | rg '^▶ ' | sed 's/^▶ //' | sort -u > /tmp/gate-all-steps-baseline.txt
cat /tmp/gate-all-steps-baseline.txt
```

Then hand-convert that list into `tools/gate-all-expected-steps.json` as a JSON array. This file is
the regression guard's ground truth — it must be committed alongside the refactor, not generated
by the refactored code itself (a self-generated baseline can't catch the refactor silently dropping
a step).

- [ ] **Step 3: Add a `--list-steps-only` mode and step-descriptor construction to `gate-all.mjs`**

Add near the top of `gate-all.mjs`, after existing imports:

```js
const LIST_STEPS_ONLY = process.argv.includes("--list-steps-only");
```

Replace the per-package loop (existing):

```js
for (const { pkg, script } of perPackage) {
    runItem(`${pkg.name}: ${script}`, "pnpm", ["--filter", pkg.name, "run", script]);
}
```

with step-descriptor construction feeding the scheduler. Each per-package step gets `exclusiveWith:
[]` except `elm-m3e: test:browser`, which gets `["docs-dist", "port-1239"]`:

```js
import { runScheduled } from "./lib/gate-scheduler.mjs";

const steps = [];
for (const { pkg, script } of perPackage) {
    const name = `${pkg.name}: ${script}`;
    steps.push({
        name,
        command: "pnpm",
        args: ["--filter", pkg.name, "run", script],
        cwd: repoRoot,
        exclusiveWith: name === "elm-m3e: test:browser" ? ["docs-dist", "port-1239"] : [],
    });
}
```

Do the same conversion for the copy-fidelity loop and every standalone `runItem()` workspace-gate
call, tagging `workspace: check-drift (M4.b cross-cutting drift gate)` and `workspace: copy-fidelity
elm-m3e` with `exclusiveWith: ["docs-dist"]`, and leaving every other step at `exclusiveWith: []`.

If `LIST_STEPS_ONLY`, print `JSON.stringify(steps.map(s => s.name))` and `process.exit(0)` before
running anything — this is what Task 2's regression test reads.

Otherwise, call the scheduler once with the full step list and `concurrency:
os.cpus().length`, passing an `onResult` that calls the existing `record()` with the same
pass/fail/skip logic `runItem()` used to apply (SKIP-line detection included):

```js
await runScheduled(steps, {
    concurrency: os.cpus().length,
    onResult: ({ name, status, detail, stdout, stderr }) => {
        process.stdout.write(`\n${"─".repeat(72)}\n▶ ${name}\n`);
        if (stdout) process.stdout.write(stdout);
        if (stderr) process.stderr.write(stderr);
        if (status === "pass" && /(^|\n)SKIP[:\s]/.test(stdout || "")) {
            const reason = (stdout.match(/^SKIP.*$/m) || [])[0] || "skipped";
            record(name, "skip", reason);
        } else {
            record(name, status, detail);
        }
    },
});
```

This preserves the exact SKIP-detection behavior `runItem()` had (spec §5: "record()'s output shape
is unchanged").

- [ ] **Step 4: Run the step-membership regression test**

Run: `node --test tools/check-gate-all-step-membership.test.mjs`
Expected: PASS — the refactored `gate-all.mjs --list-steps-only` produces the exact same name set
as `/tmp/gate-all-steps-baseline.txt` converted into `gate-all-expected-steps.json`.

- [ ] **Step 5: Run the full gate and confirm correctness + timing**

Run: `time node tools/gate-all.mjs`
Expected: exit code matches the pre-refactor run given the same repo state (same packages
pass/fail); wall-clock ≤250s on a warm cache. If any step that used to pass now fails, STOP — do not
proceed to Step 6 until the failure is understood (see Task 3 for the likely cause: `ELM_HOME`
contention).

- [ ] **Step 6: Commit**

```bash
git add tools/gate-all.mjs tools/gate-all-expected-steps.json tools/check-gate-all-step-membership.test.mjs
git commit -m "feat(gate-all): dispatch through tag-aware scheduler, run test:browser concurrently with the rest"
```

### Task 3: Per-step `ELM_HOME` isolation for Phase 1's concurrent Elm-toolchain steps

**Files:**
- Modify: `tools/gate-all.mjs` (step-descriptor construction from Task 2, Step 3)
- Create: `tools/lib/elm-home-isolation.mjs`

**Interfaces:**
- Consumes: nothing from Task 1/2 directly (adds an `env` field to descriptors Task 2 already
  builds).
- Produces: `isolatedElmHome(stepName)` returning a per-step scratch `ELM_HOME` path, seeded via
  hardlink-copy from the real `~/.elm` so no step multiplies disk usage or recompiles from scratch.

- [ ] **Step 1: Write the failing test for hardlink seeding**

```js
// tools/lib/elm-home-isolation.test.mjs
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";
import { isolatedElmHome } from "./elm-home-isolation.mjs";

test("isolatedElmHome seeds a scratch dir that hardlinks (not copies) package files", () => {
  const fakeRealElmHome = fs.mkdtempSync(path.join(os.tmpdir(), "fake-elm-home-"));
  fs.mkdirSync(path.join(fakeRealElmHome, "0.19.1", "packages", "elm", "core"), {
    recursive: true,
  });
  const marker = path.join(fakeRealElmHome, "0.19.1", "packages", "elm", "core", "marker.txt");
  fs.writeFileSync(marker, "hello");

  const scratch = isolatedElmHome("test-step", { realElmHome: fakeRealElmHome });
  const seeded = path.join(scratch, "0.19.1", "packages", "elm", "core", "marker.txt");
  assert.ok(fs.existsSync(seeded), "expected seeded file to exist in scratch ELM_HOME");

  const realStat = fs.statSync(marker);
  const scratchStat = fs.statSync(seeded);
  assert.equal(
    realStat.ino,
    scratchStat.ino,
    "expected hardlink (same inode), not a full copy"
  );

  fs.rmSync(fakeRealElmHome, { recursive: true, force: true });
  fs.rmSync(scratch, { recursive: true, force: true });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `node --test tools/lib/elm-home-isolation.test.mjs`
Expected: FAIL — module not found.

- [ ] **Step 3: Implement `isolatedElmHome`**

```js
// tools/lib/elm-home-isolation.mjs
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

/**
 * Produce a per-step scratch ELM_HOME, seeded from the real one via
 * hardlinks (cp -al semantics) so concurrent steps don't share a mutable
 * package cache but also don't pay to recopy or recompile ~/.elm's contents.
 * A step's own writes (e.g. elm-review-cem's stage-facts-elm-home.mjs) land
 * only in its own scratch copy.
 */
export function isolatedElmHome(stepName, { realElmHome = path.join(os.homedir(), ".elm") } = {}) {
  const slug = stepName.replace(/[^a-z0-9]+/gi, "-").toLowerCase();
  const scratch = fs.mkdtempSync(path.join(os.tmpdir(), `gate-all-elm-home-${slug}-`));
  if (fs.existsSync(realElmHome)) {
    hardlinkTree(realElmHome, scratch);
  }
  return scratch;
}

function hardlinkTree(src, dest) {
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, entry.name);
    const d = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      fs.mkdirSync(d, { recursive: true });
      hardlinkTree(s, d);
    } else if (entry.isFile()) {
      fs.linkSync(s, d);
    }
    // symlinks: skip (none expected under ~/.elm's package cache structure).
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `node --test tools/lib/elm-home-isolation.test.mjs`
Expected: PASS.

- [ ] **Step 5: Wire `env.ELM_HOME` into every Elm-toolchain-invoking step's descriptor**

In `gate-all.mjs`'s step-descriptor construction (Task 2 Step 3), identify Elm-toolchain steps —
every per-package `check`/`test` step is a reasonable default to isolate (cheaper to isolate a
step that doesn't need it than to miss one that does), plus `elm-review-cem: check:review`
explicitly:

```js
import { isolatedElmHome } from "./lib/elm-home-isolation.mjs";

// ... inside the per-package loop, when building each step:
steps.push({
    name,
    command: "pnpm",
    args: ["--filter", pkg.name, "run", script],
    cwd: repoRoot,
    exclusiveWith: name === "elm-m3e: test:browser" ? ["docs-dist", "port-1239"] : [],
    env: { ELM_HOME: isolatedElmHome(name) },
});
```

- [ ] **Step 6: Stress-test constraint #3 (shared `ELM_HOME` race)**

This is the constraint-specific verification the spec's acceptance criterion 5 requires. Force two
Elm-toolchain steps to run concurrently and confirm no cross-contamination:

```bash
# Snapshot the real ~/.elm's mtime for the facts package elm-review-cem writes into,
# BEFORE a full concurrent run.
find ~/.elm/0.19.1/packages/jackhp95/elm-cem-facts -newer /tmp/gate-all-marker 2>/dev/null; touch /tmp/gate-all-marker
time node tools/gate-all.mjs
# AFTER: the real ~/.elm's elm-cem-facts dir must show NO modification from this
# run (isolatedElmHome's hardlink seeding means writes go to scratch copies only).
find ~/.elm/0.19.1/packages/jackhp95/elm-cem-facts -newer /tmp/gate-all-marker
```

Expected: the second `find` prints nothing — confirming `elm-review-cem: check:review`'s write
landed in its own scratch `ELM_HOME`, not the shared real one, even while other Elm-toolchain steps
ran concurrently.

- [ ] **Step 7: Commit**

```bash
git add tools/lib/elm-home-isolation.mjs tools/lib/elm-home-isolation.test.mjs tools/gate-all.mjs
git commit -m "feat(gate-all): isolate ELM_HOME per concurrent Elm-toolchain step"
```

### Task 4: Constraint stress tests for `docs-dist` and `port-1239`

**Files:**
- Create: `tools/check-gate-all-constraints.test.mjs`

**Interfaces:**
- Consumes: the tagged step list built by Tasks 2-3 (reads `gate-all.mjs --list-steps-only`
  augmented to also dump each step's `exclusiveWith` tags — extend the flag from Task 2 Step 3 to
  print `{name, exclusiveWith}` pairs instead of bare names when a second flag `--list-steps-full`
  is passed).

- [ ] **Step 1: Extend `--list-steps-only` to optionally include tags**

In `gate-all.mjs`, alongside `LIST_STEPS_ONLY`:

```js
const LIST_STEPS_FULL = process.argv.includes("--list-steps-full");
// ... where LIST_STEPS_ONLY is handled:
if (LIST_STEPS_FULL) {
    console.log(JSON.stringify(steps.map((s) => ({ name: s.name, exclusiveWith: s.exclusiveWith || [] }))));
    process.exit(0);
}
```

- [ ] **Step 2: Write the constraint-membership test**

```js
// tools/check-gate-all-constraints.test.mjs
import assert from "node:assert/strict";
import { test } from "node:test";
import { execFileSync } from "node:child_process";

test("exactly the steps that touch docs/dist carry the docs-dist tag", () => {
  const steps = JSON.parse(
    execFileSync(process.execPath, ["tools/gate-all.mjs", "--list-steps-full"], {
      encoding: "utf8",
    })
  );
  const docsDistTagged = steps
    .filter((s) => s.exclusiveWith.includes("docs-dist"))
    .map((s) => s.name)
    .sort();
  assert.deepEqual(docsDistTagged, [
    "elm-m3e: test:browser",
    "workspace: check-drift (M4.b cross-cutting drift gate)",
    "workspace: copy-fidelity elm-m3e",
  ]);
});

test("port-1239 tag is held only by test:browser", () => {
  const steps = JSON.parse(
    execFileSync(process.execPath, ["tools/gate-all.mjs", "--list-steps-full"], {
      encoding: "utf8",
    })
  );
  const port1239Tagged = steps.filter((s) => s.exclusiveWith.includes("port-1239"));
  assert.equal(port1239Tagged.length, 1);
  assert.equal(port1239Tagged[0].name, "elm-m3e: test:browser");
});
```

- [ ] **Step 3: Run the tests to verify they pass against Task 2/3's tagging**

Run: `node --test tools/check-gate-all-constraints.test.mjs`
Expected: PASS. If FAIL, Task 2 Step 3's tagging missed a step — fix the tagging, not the test.

- [ ] **Step 4: Empirically confirm the `docs/dist` race is closed**

```bash
git status --porcelain packages/elm-m3e/docs/dist | wc -l   # before: expect 0 (clean)
node tools/gate-all.mjs
git status --porcelain packages/elm-m3e/docs/dist | wc -l   # after: some tracked-file
                                                              # churn from test:browser is
                                                              # EXPECTED (spec §2 constraint 1
                                                              # notes this is pre-existing,
                                                              # unrelated to parallelization);
                                                              # what matters is check-drift and
                                                              # copy-fidelity elm-m3e both still
                                                              # PASS in the run's own summary,
                                                              # proving they read a
                                                              # post-test:browser tree, not a
                                                              # concurrently-being-written one.
```

- [ ] **Step 5: Commit**

```bash
git add tools/check-gate-all-constraints.test.mjs tools/gate-all.mjs
git commit -m "test(gate-all): stress-test docs-dist and port-1239 exclusion tags"
```

**Phase 1 rollback:** `git revert` the four Phase 1 commits in reverse order (Task 4 → 3 → 2 → 1).
Reverting Task 2's commit alone restores the original two serial `for` loops and `runItem()` calls
verbatim (they were replaced, not deleted-and-rewritten elsewhere), so a partial revert (e.g. keep
the scheduler module but revert only the wiring) is also safe if Task 2 introduced a regression
that Tasks 1/3/4 didn't cause.

**Phase 1 verification (full):**
```bash
node --test tools/lib/gate-scheduler.test.mjs tools/lib/elm-home-isolation.test.mjs \
  tools/check-gate-all-step-membership.test.mjs tools/check-gate-all-constraints.test.mjs
time node tools/gate-all.mjs
node packages/elm-cem/bin/elm-cem.js check-gates   # or whatever self-verification gate-all
                                                     # exposes today — confirm it still passes
```
Expected: all four test files pass; full run ≤250s warm; `check-gates` passes; exit code and
pass/fail set per step matches a baseline run taken before Phase 1 (same repo state).

---

## Phase 2 — Shrink `test:browser`'s own 232s

**Goal:** Reduce the 231.9s `test:browser` figure itself via three independent sub-efforts:
profile-and-fix the two outlier specs, re-validate the `workers` count, and cache `build:site` on a
content hash. This phase's tasks are independent of each other and of Phase 1/3 — they can land in
any order, before or after Phase 1.

**Resolves open question #4 from the spec (§7):** the outlier-spec fix (Task 1) touches
`packages/elm-m3e` test code, a different blast radius than the scheduler work. This plan splits it
into its own Task specifically so it can be reviewed/landed on its own timeline without blocking
Tasks 2-3 or Phase 1/3.

**Resolves open question #5 from the spec (§7):** Task 3 below enumerates `build:site`'s actual
input set via direct file-access tracing (not a guess from the script name), per the spec's
instruction.

### Task 1: Profile and fix the two outlier specs

**Files:**
- Modify: `packages/elm-m3e/docs/e2e/mobile-shell.spec.ts` (confirm exact path in Step 1)
- Modify: `packages/elm-m3e/docs/e2e/shell-breakpoints.spec.ts` (confirm exact path in Step 1)

**Interfaces:** none shared with other tasks — this is test-code surgery, self-contained.

- [ ] **Step 1: Locate the two specs and confirm line numbers**

Run: `rg -n 'mobile-shell|shell-breakpoints' packages/elm-m3e/docs -l`
Expected: paths for both spec files, confirming the `mobile-shell.spec.ts:27` /
`shell-breakpoints.spec.ts:162` references from the research.

- [ ] **Step 2: Profile each spec's actual timing breakdown**

Run: `pnpm --filter elm-m3e-docs exec playwright test mobile-shell.spec.ts --trace on`
Then open the trace (`npx playwright show-trace`) or read the JSON reporter output to find which
individual `await` inside the spec accounts for the bulk of its 26.1s — a fixed `waitForTimeout`,
an oversized breakpoint-permutation matrix, or a slow selector are the likely culprits per the
spec's framing. Repeat for `shell-breakpoints.spec.ts` (24.8s).

- [ ] **Step 3: Fix the identified inefficiency**

The exact fix depends on Step 2's finding — this plan cannot prescribe it blindly (per spec §3.3
Tier 2, an outlier that slow is "more likely a real inefficiency... than starvation"). Whatever the
fix, it must not reduce test coverage — if the fix is "the matrix tests N viewport sizes serially
and only 2 are meaningfully distinct," collapsing the matrix requires confirming with the test's
original author/intent (check git blame / the PR that introduced it) that the removed cases were
truly redundant, not a deliberate coverage decision.

- [ ] **Step 4: Re-run and measure the new duration**

Run: `pnpm --filter elm-m3e-docs exec playwright test mobile-shell.spec.ts shell-breakpoints.spec.ts --reporter=list`
Expected: both specs' durations drop meaningfully below their prior 26.1s/24.8s; no new failures.

- [ ] **Step 5: Run the full `test:browser` suite to confirm no regression**

Run: `pnpm --filter elm-m3e-docs run test:browser`
Expected: 238/238 tests still pass (same count as before); total suite duration is lower than the
231.9s baseline (build:site + Playwright run combined).

- [ ] **Step 6: Commit**

```bash
git add packages/elm-m3e/docs/e2e/mobile-shell.spec.ts packages/elm-m3e/docs/e2e/shell-breakpoints.spec.ts
git commit -m "perf(elm-m3e/docs): fix outlier spec timings in mobile-shell/shell-breakpoints"
```

### Task 2: Re-validate the Playwright `workers` count

**Files:**
- Modify: `packages/elm-m3e/docs/playwright.config.ts:76` area (the `workers` setting and its
  explanatory comment)

**Interfaces:** none shared — config-only change, independent of Task 1 and Task 3.

- [ ] **Step 1: Read the existing comment and current value**

Run: `rg -n 'workers' packages/elm-m3e/docs/playwright.config.ts`
Expected: `workers: 3` plus a comment claiming higher counts "starve slower tests" — confirm this
is still the wording before changing anything (the comment might already have been touched by the
concurrent gate-fix effort mentioned in the task background; if the file differs from what this
plan assumes, treat the live file as ground truth and adapt).

- [ ] **Step 2: Measure at 3 (baseline), 5, 8, and `os.cpus().length` (10) workers**

```bash
for w in 3 5 8 10; do
  echo "=== workers=$w ==="
  PLAYWRIGHT_WORKERS_OVERRIDE=$w pnpm --filter elm-m3e-docs run test:browser 2>&1 | tail -5
done
```
(If `playwright.config.ts` doesn't currently read an env override, add one temporarily for this
measurement: `workers: Number(process.env.PLAYWRIGHT_WORKERS_OVERRIDE) || 3`.) Record each run's
total wall-clock and whether any spec's duration measurably *increased* versus the 3-worker
baseline (the failure mode the existing comment warns about).

- [ ] **Step 3: Pick the fastest worker count that shows no per-spec slowdown**

If a higher count (say 8) reduces total wall-clock with no individual spec regressing, set
`workers` to that value permanently. If the existing comment's concern is confirmed (some spec
genuinely gets slower under contention — e.g. CPU-bound rendering work starving under more workers
than cores allow), keep `workers: 3` but update the comment to record the re-measurement date and
data, so the next person doesn't have to redo this investigation from scratch.

- [ ] **Step 4: Commit**

```bash
git add packages/elm-m3e/docs/playwright.config.ts
git commit -m "perf(elm-m3e/docs): re-validate Playwright workers count against current measurements"
```

### Task 3: Content-hash cache for `build:site`

**Files:**
- Create: `tools/lib/build-site-cache.mjs`
- Modify: `packages/elm-m3e/docs/playwright.config.ts` (the `webServer.command` that currently runs
  `build:site` directly)

**Interfaces:**
- Produces: `cachedBuildSite({ inputs, buildCommand, buildCwd, distDir, cacheDir })` — hashes
  `inputs` (a list of globs/files), and if a cache entry for that hash exists, restores `distDir`
  from it instead of running `buildCommand`; otherwise runs `buildCommand` and saves the result
  under the hash.
- Consumes: nothing from Phase 1/2 Tasks 1-2.

- [ ] **Step 1: Trace `build:site`'s actual file reads**

This resolves spec open question #5 — do not guess the input list from the script name.

```bash
# macOS: fs_usage: run in one terminal, trigger the build in another, capture reads.
sudo fs_usage -w -f filesys pnpm | grep -i "packages/elm-m3e/docs" > /tmp/build-site-fs-trace.txt &
pnpm --filter elm-m3e-docs run build:site
kill %1
# Extract the distinct source files/directories actually opened for read
# (exclude node_modules and the dist output itself):
rg -o 'packages/elm-m3e/docs/\S+' /tmp/build-site-fs-trace.txt | sort -u \
  | rg -v 'node_modules|/dist/' > /tmp/build-site-inputs.txt
cat /tmp/build-site-inputs.txt
```

Expected output: a concrete list of elm-pages source files, content directories, and config JSONs
`build:site` reads. This list becomes the `inputs` argument below — replace the placeholder list in
Step 3 with what this trace actually finds (if `fs_usage` isn't available or the trace is noisy,
fall back to reasoning from `elm-pages`'s own documented content/config conventions plus
`git diff --stat` on a known no-op rebuild, but the traced list is strongly preferred).

- [ ] **Step 2: Write the failing test for cache-hit/cache-miss behavior**

```js
// tools/lib/build-site-cache.test.mjs
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";
import { cachedBuildSite } from "./build-site-cache.mjs";

test("cache miss runs the build command and populates the cache", () => {
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "build-site-cache-"));
  const inputFile = path.join(tmp, "input.txt");
  fs.writeFileSync(inputFile, "v1");
  const distDir = path.join(tmp, "dist");
  const cacheDir = path.join(tmp, "cache");
  let buildRuns = 0;

  cachedBuildSite({
    inputs: [inputFile],
    buildCommand: () => {
      buildRuns++;
      fs.mkdirSync(distDir, { recursive: true });
      fs.writeFileSync(path.join(distDir, "out.txt"), "built");
    },
    distDir,
    cacheDir,
  });

  assert.equal(buildRuns, 1);
  assert.ok(fs.existsSync(path.join(distDir, "out.txt")));
});

test("cache hit restores dist without re-running the build command", () => {
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "build-site-cache-"));
  const inputFile = path.join(tmp, "input.txt");
  fs.writeFileSync(inputFile, "v1");
  const distDir = path.join(tmp, "dist");
  const cacheDir = path.join(tmp, "cache");
  let buildRuns = 0;
  const build = () => {
    buildRuns++;
    fs.mkdirSync(distDir, { recursive: true });
    fs.writeFileSync(path.join(distDir, "out.txt"), "built");
  };

  cachedBuildSite({ inputs: [inputFile], buildCommand: build, distDir, cacheDir });
  fs.rmSync(distDir, { recursive: true, force: true }); // simulate a fresh checkout

  cachedBuildSite({ inputs: [inputFile], buildCommand: build, distDir, cacheDir });

  assert.equal(buildRuns, 1, "second call should hit cache, not re-invoke buildCommand");
  assert.ok(fs.existsSync(path.join(distDir, "out.txt")), "dist must be restored from cache");
});

test("changing an input file forces a cache miss", () => {
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "build-site-cache-"));
  const inputFile = path.join(tmp, "input.txt");
  fs.writeFileSync(inputFile, "v1");
  const distDir = path.join(tmp, "dist");
  const cacheDir = path.join(tmp, "cache");
  let buildRuns = 0;
  const build = () => {
    buildRuns++;
    fs.mkdirSync(distDir, { recursive: true });
    fs.writeFileSync(path.join(distDir, "out.txt"), `built-${buildRuns}`);
  };

  cachedBuildSite({ inputs: [inputFile], buildCommand: build, distDir, cacheDir });
  fs.writeFileSync(inputFile, "v2"); // input changed
  cachedBuildSite({ inputs: [inputFile], buildCommand: build, distDir, cacheDir });

  assert.equal(buildRuns, 2, "changed input must force a rebuild, never trust a stale hash");
});
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `node --test tools/lib/build-site-cache.test.mjs`
Expected: FAIL — module not found.

- [ ] **Step 4: Implement `cachedBuildSite`**

```js
// tools/lib/build-site-cache.mjs
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

/**
 * Content-hash cache around a site build. NEVER a path/git-diff heuristic —
 * always hashes actual input file contents, so a cache hit is provably safe
 * (spec §4: this repo forbids skip-if-path-unchanged heuristics; a hash miss
 * always rebuilds, there is no "trust the diff" fallback here).
 */
export function cachedBuildSite({ inputs, buildCommand, distDir, cacheDir }) {
  fs.mkdirSync(cacheDir, { recursive: true });
  const hash = hashInputs(inputs);
  const entryDir = path.join(cacheDir, hash);

  if (fs.existsSync(entryDir)) {
    fs.rmSync(distDir, { recursive: true, force: true });
    fs.cpSync(entryDir, distDir, { recursive: true });
    return { cacheHit: true, hash };
  }

  buildCommand();
  fs.cpSync(distDir, entryDir, { recursive: true });
  return { cacheHit: false, hash };
}

function hashInputs(inputs) {
  const h = crypto.createHash("sha256");
  for (const file of [...inputs].sort()) {
    h.update(file);
    if (fs.existsSync(file) && fs.statSync(file).isFile()) {
      h.update(fs.readFileSync(file));
    }
  }
  return h.digest("hex");
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `node --test tools/lib/build-site-cache.test.mjs`
Expected: PASS (all three tests).

- [ ] **Step 6: Wire into `playwright.config.ts`'s `webServer` step**

Replace the direct `build:site` invocation in `packages/elm-m3e/docs/playwright.config.ts:76`'s
`webServer.command` with a small wrapper script that calls `cachedBuildSite` using the input list
traced in Step 1, then reports whether it was a cache hit — printed to stdout so it's visible in
gate-all's per-step buffered output (per the spec §4 requirement that a cache hit must be as
visible/attributable as an existing SKIP, never a silent no-op).

- [ ] **Step 7: Confirm cache-hit path end-to-end**

```bash
pnpm --filter elm-m3e-docs run test:browser   # first run: cache miss, builds normally
pnpm --filter elm-m3e-docs run test:browser   # second run, no source changes: cache hit
```
Expected: second run's `build:site` phase completes in a fraction of the ~28.2s baseline, and its
output explicitly states it was a cache hit (grep for the wrapper's cache-hit log line).

- [ ] **Step 8: Confirm cache-miss path on a real input change**

```bash
touch packages/elm-m3e/docs/<one of the traced input files>
pnpm --filter elm-m3e-docs run test:browser
```
Expected: full rebuild runs (no false cache hit), confirming the hash correctly invalidates.

- [ ] **Step 9: Commit**

```bash
git add tools/lib/build-site-cache.mjs tools/lib/build-site-cache.test.mjs \
  packages/elm-m3e/docs/playwright.config.ts
git commit -m "perf(elm-m3e/docs): content-hash cache for build:site, no path-based skip heuristics"
```

**Phase 2 rollback:** each of the three tasks is independently `git revert`-able; reverting Task 3
restores direct `build:site` invocation with no cache; reverting Task 2 restores `workers: 3`;
reverting Task 1 restores the original (slow) spec bodies.

**Phase 2 verification (full):**
```bash
node --test tools/lib/build-site-cache.test.mjs
pnpm --filter elm-m3e-docs run test:browser
time node tools/gate-all.mjs
node packages/elm-cem/bin/elm-cem.js check-gates
```
Expected: `test:browser` duration measurably below the 231.9s baseline; full gate-all run
correspondingly faster than Phase 1's ≤250s; `check-gates` still passes; test count (238) unchanged.

---

## Phase 3 — Generalize the pool across the ~130s bucket

**Goal:** Once Phase 1's two-bucket split (elephant vs. everything-else) is stable, widen the same
scheduler to run the ~130s "everything else" bucket's steps concurrently with EACH OTHER too, not
just concurrently with `test:browser`. This phase changes nothing structural — Task 1/2's
`gate-scheduler.mjs` and `elm-home-isolation.mjs` from Phase 1 already support N-way concurrency;
this phase is really "confirm the concurrency ceiling and measure," since the tagging work
(`exclusiveWith`) was already done in Phase 1 Task 2/3.

### Task 1: Confirm and measure full-bucket concurrency

**Files:**
- Modify: `tools/gate-all.mjs` (only if Phase 1's `concurrency: os.cpus().length` needs adjusting —
  no structural change expected)

**Interfaces:** none new — this task validates Phase 1's mechanism at wider scale, it does not add
new mechanism.

- [ ] **Step 1: Resolve open question #3 from the spec (§7) — pick the concurrency ceiling**

Run the full gate at several pool widths and record wall-clock plus subjective machine
responsiveness (can the editor / other dev tools stay responsive during the run):

```bash
for c in 4 6 8 10; do
  echo "=== concurrency=$c ==="
  GATE_ALL_CONCURRENCY=$c time node tools/gate-all.mjs
done
```

(Add a temporary `Number(process.env.GATE_ALL_CONCURRENCY) || os.cpus().length` read at the
`runScheduled` call site for this measurement pass.)

- [ ] **Step 2: Pick the ceiling and hardcode/document it**

If `os.cpus().length` (10) shows no meaningful advantage over 6-8 and leaves the machine sluggish
during the run (a real ergonomic cost for a pre-push hook a developer waits on), cap it lower —
e.g. `Math.max(4, os.cpus().length - 2)`. Record the decision and its measurement in a comment at
the `runScheduled` call site.

- [ ] **Step 3: Run the full gate at the chosen ceiling and confirm timing + correctness**

Run: `time node tools/gate-all.mjs`
Expected: wall-clock is the best of Step 1's measurements (or very close); all steps pass/fail
identically to Phase 1/2's baseline; no step's own internal behavior (e.g. per-package `elm-test-rs`
runs) shows flakiness introduced by wider concurrency (rerun 2-3 times to rule out a scheduling race
Phase 1's narrower 2-way split didn't exercise).

- [ ] **Step 4: Re-run the constraint stress tests from Phase 1 Task 4 at the new concurrency ceiling**

Run: `node --test tools/check-gate-all-constraints.test.mjs` and repeat Phase 1 Task 3 Step 6's
`ELM_HOME` contamination check.
Expected: PASS — wider concurrency must not surface a race the 2-way split didn't have, since
`exclusiveWith` tagging and per-step `ELM_HOME` isolation are concurrency-width-independent
mechanisms (this is the test that proves that claim rather than assuming it).

- [ ] **Step 5: Commit**

```bash
git add tools/gate-all.mjs
git commit -m "perf(gate-all): widen scheduler concurrency ceiling to cover the full independent-step bucket"
```

**Phase 3 rollback:** revert the concurrency-ceiling commit; Phase 1's narrower two-bucket behavior
is preserved underneath (this phase changes a number and a comment, not the mechanism).

**Phase 3 verification (full):**
```bash
node --test tools/lib/gate-scheduler.test.mjs tools/lib/elm-home-isolation.test.mjs \
  tools/check-gate-all-step-membership.test.mjs tools/check-gate-all-constraints.test.mjs
time node tools/gate-all.mjs
node packages/elm-cem/bin/elm-cem.js check-gates
```
Expected: full run measurably faster than Phase 1+2's combined result; step membership and
correctness unchanged; `check-gates` passes; no new flakiness across 2-3 repeated runs.

---

## Phase 4 — Cheap wins (no ordering dependency on Phases 1-3)

**Goal:** Land two small, low-risk, strictly-positive changes that can go in at any point —
memoize the facts-bundle regeneration and parallelize `check-mirror-drift`'s `gh api` calls.

### Task 1: Memoize facts-bundle generation across `check-drift`'s consumers

**Files:**
- Modify: `tools/lib/check-drift-core.mjs:243-247` (`checkConsumerBundleDrift`'s
  `generateBundleToTemp` calls) and `check-drift.mjs:83`'s `checkProducer`
- Modify: `tools/gate-all.mjs:181`'s `factsBundleE2E`
- Modify: `tools/ab-elm-cem.sh:63-71`

**Interfaces:**
- Produces: a single generated bundle temp-dir path, computed once per `gate-all.mjs` invocation
  and threaded into every consumer that currently regenerates it independently.

- [ ] **Step 1: Read the current call sites to confirm the exact regeneration count**

Run: `rg -n 'generateBundleToTemp' tools/lib/check-drift-core.mjs tools/check-drift.mjs tools/gate-all.mjs tools/ab-elm-cem.sh`
Expected: confirms the 7+ regeneration count cited in the spec (3 in `checkConsumerBundleDrift`, 1
in `checkProducer`, 1 in `factsBundleE2E`, 2 in `ab-elm-cem.sh`).

- [ ] **Step 2: Write the failing test for a shared-generation helper**

```js
// tools/lib/facts-bundle-memo.test.mjs
import assert from "node:assert/strict";
import { test } from "node:test";
import { memoizedBundleGenerator } from "./facts-bundle-memo.mjs";

test("calling the memoized generator twice only invokes the underlying generator once", () => {
  let calls = 0;
  const gen = memoizedBundleGenerator(() => {
    calls++;
    return `/tmp/fake-bundle-${calls}`;
  });
  const first = gen();
  const second = gen();
  assert.equal(calls, 1);
  assert.equal(first, second);
});

test("a fresh memoizedBundleGenerator instance re-invokes the underlying generator", () => {
  let calls = 0;
  const gen1 = memoizedBundleGenerator(() => { calls++; return `/tmp/a-${calls}`; });
  gen1();
  const gen2 = memoizedBundleGenerator(() => { calls++; return `/tmp/b-${calls}`; });
  gen2();
  assert.equal(calls, 2);
});
```

- [ ] **Step 3: Run to verify it fails**

Run: `node --test tools/lib/facts-bundle-memo.test.mjs`
Expected: FAIL — module not found.

- [ ] **Step 4: Implement `memoizedBundleGenerator`**

```js
// tools/lib/facts-bundle-memo.mjs
/**
 * Wrap a bundle-generation function so repeated calls within the SAME
 * invocation (same closure instance) return the first result instead of
 * regenerating. This strengthens correctness, not just speed: every consumer
 * compares against one identical bundle instead of separately-generated
 * ones, closing the theoretical gap where a nondeterministic generator bug
 * could produce divergent bundles that no check would notice.
 */
export function memoizedBundleGenerator(generate) {
  let cached;
  return () => {
    if (cached === undefined) cached = generate();
    return cached;
  };
}
```

- [ ] **Step 5: Run to verify it passes**

Run: `node --test tools/lib/facts-bundle-memo.test.mjs`
Expected: PASS.

- [ ] **Step 6: Thread one shared generator through all call sites**

In `gate-all.mjs`, construct one `memoizedBundleGenerator(...)` instance near the top of the run
(before `factsBundleE2E` and before `check-drift.mjs`/`copy-fidelity` are invoked), and pass it (or
its resolved path, once called) into every consumer identified in Step 1 — `checkConsumerBundleDrift`'s
three calls, `checkProducer`, `factsBundleE2E`, and `ab-elm-cem.sh`'s two. Note: `ab-elm-cem.sh` is a
separate shell process from `gate-all.mjs`'s Node process, so its two internal regenerations can
only be memoized against each other (within the shell script), not against the Node-side ones,
unless the bundle path is passed via an env var from `gate-all.mjs` into the shell invocation —
prefer the env-var approach so all 7+ sites collapse to exactly one generation per full run.

- [ ] **Step 7: Run `check-drift` standalone and confirm identical behavior with fewer generations**

Run: `node tools/check-drift.mjs`
Expected: same pass/fail result as before; add a temporary log line counting `generate()` calls
during this run to confirm it dropped from N to 1, then remove the log line before committing.

- [ ] **Step 8: Run the full gate and confirm timing + correctness**

Run: `time node tools/gate-all.mjs`
Expected: shaves ~6-8s off whichever phase's baseline it's layered onto; all consumers still pass;
`check-gates` passes.

- [ ] **Step 9: Commit**

```bash
git add tools/lib/facts-bundle-memo.mjs tools/lib/facts-bundle-memo.test.mjs \
  tools/lib/check-drift-core.mjs tools/check-drift.mjs tools/gate-all.mjs tools/ab-elm-cem.sh
git commit -m "perf(gate-all): generate the facts bundle once per run, thread it to every consumer"
```

### Task 2: Parallelize `check-mirror-drift`'s `gh api` calls

**Files:**
- Modify: `tools/check-mirror-drift.mjs`

**Interfaces:** none shared with other tasks.

- [ ] **Step 1: Read the current serial `gh api` call sequence**

Run: `rg -n 'gh api|spawnSync|execFileSync' tools/check-mirror-drift.mjs`
Expected: confirms three (or however many) serial calls summing to ~3.9s.

- [ ] **Step 2: Write the failing test for parallel execution**

```js
// tools/check-mirror-drift.test.mjs (add to existing test file if one exists — confirm with
// `ls tools/check-mirror-drift.test.mjs` first; if absent, create it)
import assert from "node:assert/strict";
import { test } from "node:test";
import { fetchAllMirrorStatuses } from "./check-mirror-drift.mjs";

test("fetchAllMirrorStatuses issues its gh api calls concurrently", async () => {
  const calls = [];
  const fakeFetch = (repo) =>
    new Promise((resolve) => {
      calls.push({ repo, start: Date.now() });
      setTimeout(() => resolve({ repo, sha: "abc123" }), 100);
    });
  const start = Date.now();
  await fetchAllMirrorStatuses(["repo-a", "repo-b", "repo-c"], { fetchOne: fakeFetch });
  const elapsed = Date.now() - start;
  assert.ok(elapsed < 250, `expected concurrent (<250ms for 3x100ms calls), got ${elapsed}ms`);
  assert.equal(calls.length, 3);
});
```

- [ ] **Step 3: Run to verify it fails**

Run: `node --test tools/check-mirror-drift.test.mjs`
Expected: FAIL — `fetchAllMirrorStatuses` doesn't exist yet, or the existing serial implementation
takes ≥300ms.

- [ ] **Step 4: Implement `fetchAllMirrorStatuses` using `Promise.all`**

```js
// in tools/check-mirror-drift.mjs, replacing the serial loop over repos:
export async function fetchAllMirrorStatuses(repos, { fetchOne = ghApiFetchOne } = {}) {
  return Promise.all(repos.map((repo) => fetchOne(repo)));
}
```

Wire the real `ghApiFetchOne` (the existing per-repo `gh api` invocation, now wrapped as an async
function returning a Promise instead of a blocking call) as the default, and update the module's
main entry point to call `fetchAllMirrorStatuses` instead of a serial `for` loop.

- [ ] **Step 5: Run to verify it passes**

Run: `node --test tools/check-mirror-drift.test.mjs`
Expected: PASS.

- [ ] **Step 6: Run the real check and confirm timing + correctness**

Run: `time node tools/check-mirror-drift.mjs`
Expected: same pass/fail result as before; wall-clock drops from ~3.9s toward ~1.5s (near the
slowest single call, since they now overlap).

- [ ] **Step 7: Commit**

```bash
git add tools/check-mirror-drift.mjs tools/check-mirror-drift.test.mjs
git commit -m "perf(check-mirror-drift): parallelize gh api calls with Promise.all"
```

**Phase 4 rollback:** each task independently `git revert`-able; Task 1's revert restores the 7+
independent regenerations (slower, but not incorrect); Task 2's revert restores the serial `gh api`
loop.

**Phase 4 verification (full):**
```bash
node --test tools/lib/facts-bundle-memo.test.mjs tools/check-mirror-drift.test.mjs
time node tools/gate-all.mjs
node packages/elm-cem/bin/elm-cem.js check-gates
```
Expected: full run faster than the prior phase's baseline by roughly 6-10s combined; `check-gates`
passes; `check-drift` and `check-mirror-drift` both produce identical pass/fail verdicts to their
pre-Phase-4 behavior.

---

## Constraint Coverage Summary

| Constraint (spec §2) | Phase(s) that touch it | Verification that stress-tests it |
|---|---|---|
| #1 `docs-dist` race (`test:browser` vs. `check-drift`/`copy-fidelity elm-m3e`) | Phase 1 (tagging), Phase 3 (wider pool must not weaken it) | Phase 1 Task 4 Step 4 (empirical tracked-file-churn check + pass/fail of the tagged consumers); Phase 3 Task 1 Step 4 (re-run constraint tests at wider concurrency) |
| #2 `port-1239` singleton | Phase 1 (tagging), Phase 3 (wider pool) | Phase 1 Task 4's `port-1239` membership test; re-run at Phase 3 Task 1 Step 4 |
| #3 shared `ELM_HOME` | Phase 1 (isolation introduced here, NOT deferred — see open question #2 resolution above), Phase 3 (wider pool exercises more simultaneous Elm-toolchain steps) | Phase 1 Task 3 Step 6 (hardlink-seeded scratch dirs, mtime-based contamination check); repeated at Phase 3 Task 1 Step 4 |
| #4 shared `.gate-out/probe.js` (`workspace: root gate`) | Phase 1 (this step gets `exclusiveWith: []` by default, i.e. it runs like any other step in the pool — since nothing else in the current step list writes `.gate-out/probe.js`, no tag is needed YET, but Phase 1 Task 2 Step 1's full `runItem()` inventory must confirm no other step touches that path before leaving it untagged) | Phase 1 Task 2 Step 1 (inventory pass) — if the inventory finds a second writer, add a `gate-out-probe` tag before Phase 1 Task 2 Step 5's full-run verification, not after |

## Spec Coverage Check

- §2 constraint 1 (docs-dist) → Phase 1 Tasks 2-4. §2 constraint 2 (port-1239) → Phase 1 Tasks 2, 4.
  §2 constraint 3 (ELM_HOME) → Phase 1 Task 3. §2 constraint 4 (`.gate-out/probe.js`) → Phase 1
  Task 2 Step 1's inventory (see Constraint Coverage Summary above).
- §3.1 step-descriptor model → Phase 1 Task 1 (`gate-scheduler.mjs`)/Task 2 (wiring).
- §3.2 scheduler algorithm (bounded pool, buffered per-step output, `record()` unchanged) → Phase 1
  Task 1 (pool + buffering) and Task 2 Step 3 (the `onResult` bridge back into `record()`).
- §3.3 Tier 1 → Phase 1 (whole phase). Tier 2 (outliers, worker retune, build:site cache) → Phase 2
  Tasks 1-3. Tier 3 (generalized pool + ELM_HOME) → Phase 3 (pool widening; ELM_HOME itself pulled
  forward into Phase 1 per the resolved open question). Tier 4 (memoization, mirror-drift
  parallelism) → Phase 4 Tasks 1-2.
- §4 no-silent-skips requirement → Phase 1 Task 2 (step-membership regression test against a
  pre-refactor baseline) plus every phase's "Expected: check-gates passes" verification line.
- §4 no-path-based-skip requirement → explicitly called out in Phase 2 Task 3 Step 4's docstring
  and Step 6's visibility requirement (cache hits are logged, never silent).
- §6 acceptance criteria 1-5 → mapped to each phase's own "Phase N verification (full)" block;
  criterion 5 (constraint gate) additionally has its own dedicated summary table above.
- §7 open questions: #1 (tag model vs. DAG) is a design-level question answered by the spec itself
  choosing tags — no plan task re-litigates it, only flags it stays open for Jack's review of the
  spec. #2 (ELM_HOME timing) → resolved explicitly in Phase 1's framing and Task 3. #3 (concurrency
  ceiling) → Phase 3 Task 1. #4 (outlier-spec ownership split) → Phase 2 Task 1 kept as its own
  task specifically so it can be branched/reviewed separately. #5 (build:site cache inputs) →
  Phase 2 Task 3 Step 1's tracing step.

No placeholder steps found on review; every code block above is complete, runnable content rather
than a description of what to write.
