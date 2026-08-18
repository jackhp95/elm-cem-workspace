# Spec — `tools/gate-all.mjs` wall-clock parallelization

Status: **DRAFT, awaiting Jack's async review** (see §7 — brainstorming's approval gate could not
run synchronously; see note below). Author: background research/design agent, 2026-08-18.
Classification: **architectural** (changes the core dispatch mechanism every package's pre-push
depends on — not a bounded single-file tweak).

## 0. Why this is "architectural," and how the brainstorming gate was handled

`superpowers:brainstorming` calls for presenting the design to the user before locking it in. This
agent is running in the background with no synchronous channel to Jack. Per the task's own
instructions, the resolution is: make the best-supported call from the evidence already gathered
this session, write it down explicitly, and flag every judgment call as an **open question** in
§7 rather than silently deciding or blocking indefinitely. This document IS that presentation —
Jack's review of it, after the fact, is the approval gate. Nothing here should be treated as
already-approved; §7's open questions are the specific decision points that most need his sign-off
before implementation starts.

The reason this counts as "architectural" rather than "bounded": `gate-all.mjs`'s dispatch loop
(two `for` loops + ~15 serial `runItem()` calls, all `spawnSync`) is the thing every package's
pre-push gate funnels through. Changing it from "serial, blocking, one output stream" to "some
steps run concurrently, with explicit mutual-exclusion" touches the shared contract every future
gate author relies on (how a new check gets registered, whether it can assume exclusive access to
`docs/dist`/port 1239/`ELM_HOME`, how failures get attributed to the right step in a merged output
stream). That's a design decision, not a local optimization.

## 1. Problem statement

Warm-cache `node tools/gate-all.mjs` (invoked by `hooks/pre-push`) takes **361.5s (6.0 min)**
wall-clock, dominated by one step: `elm-m3e: test:browser` alone is **231.9s — 64% of the total**.
Everything else sums to ~130s and is *embarrassingly parallel* — each step reads only its own
package directory + already-installed `node_modules`, with no shared mutable state, EXCEPT for four
specific exceptions (§2). `gate-all.mjs` currently has **zero top-level parallelism**: two plain
serial loops plus ~15 serial `runItem()` calls, all using blocking `spawnSync`
(`tools/gate-all.mjs:96`).

This is a real cost, not perceived: 15-20 minutes was Jack's estimate before measurement; the
measured warm figure (6 min) is better than feared but still gates every push, and the shape of the
fix (one huge step + a pile of small independent ones) is exactly the case parallelization was
built for.

## 2. The four constraints a design MUST respect

Any scheduling model that ignores these will produce nondeterministic gate results — worse than the
status quo, where "slow but always correct" is currently true.

1. **`docs/dist` is not idempotent-safe to read concurrently with a write.** `elm-m3e:
   test:browser` WRITES into tracked `packages/elm-m3e/docs/dist/` (confirmed empirically — a prior
   run left ~280 modified/deleted tracked files there, meaning something in the browser-test chain
   mutates that tree in place). Meanwhile `tools/check-drift.mjs`'s `regeneratePackageOutput`
   (`tools/lib/check-drift-core.mjs:95`) rsyncs elm-m3e-adjacent package dirs, and
   `tools/copy-fidelity.mjs` enumerates the working tree via `git ls-files`. Racing `test:browser`
   against any drift/fidelity gate touching that subtree is a read/write race with no ordering
   guarantee today (only accidental, because everything is currently serial).
2. **Port 1239 is a global singleton.** `test:browser`'s `pretest:browser` script runs
   `lsof -ti:1239 | xargs kill -9` before starting its own server. Only one `test:browser`-shaped
   process may be in flight system-wide at a time, and starting a second one will kill an unrelated
   process holding that port (there is exactly one `test:browser` step today, but any future
   parallel step that also binds 1239, or any manual `pnpm dev` running concurrently on the
   developer's machine, is at risk).
3. **`ELM_HOME` is shared, global, mutable state.** `elm-review-cem: check:review` runs
   `bin/stage-facts-elm-home.mjs`, which writes into
   `~/.elm/0.19.1/packages/jackhp95/elm-cem-facts/` — a location read by every other concurrent
   `elm` / `elm-review` / `elm-test-rs` invocation in any OTHER package, because Elm 0.19 resolves
   packages out of a single global `ELM_HOME` by default. Elm 0.19 does not document this location
   as safe for concurrent writers; running `check:review` concurrently with any other package's
   Elm-toolchain step is an unverified race.
4. **`workspace: root gate` compiles into a shared scratch file.** `tools/gate.mjs:36` compiles into
   `.gate-out/probe.js`; running it concurrently with anything else that writes the same path would
   race on that file.

## 3. Design: tag-based exclusion sets over a bounded worker pool

### 3.1 Step model

Replace each bare `runItem(name, command, args, options)` call with a **step descriptor**:

```
{
  name: "elm-m3e: test:browser",
  command: "pnpm", args: [...], cwd: ...,
  exclusiveWith: ["docs-dist", "port-1239"],   // tags this step cannot run alongside
  env: { ELM_HOME: perStepElmHome },            // isolation, see §3.4
}
```

`exclusiveWith` is a set of opaque string tags, not a full dependency graph — a **conflict-tag
model**, not a DAG. A DAG (explicit "step B depends on step A") was considered and rejected for v1:
none of the four constraints are true sequencing dependencies (A's *output* feeds B) — they are all
"these two must not be in flight at the same moment," which a shared-tag exclusion set expresses
directly with far less machinery. If a genuine producer→consumer dependency is discovered later
(none is known today), the model can grow a `dependsOn` field without disturbing `exclusiveWith`.

Tags used at launch:
- `docs-dist` — held by `elm-m3e: test:browser`, and by any drift/fidelity check that reads
  `packages/elm-m3e/docs/dist` (`workspace: check-drift`, `workspace: copy-fidelity elm-m3e`).
- `port-1239` — held by `elm-m3e: test:browser` only today; reserved so a future second consumer of
  that port is forced to declare it rather than silently colliding.
- `elm-home:<pkg>` — see §3.4; each step gets its own by default, so this tag is really "opt out of
  isolation," used only if a step must share state on purpose (none currently do).

### 3.2 Scheduler

A small bounded worker pool (`p-limit`-style, concurrency = `os.cpus().length`, 10 on the
measurement machine) replaces the two `for` loops and the ~15 serial `runItem()` calls. Algorithm:

1. Build the full step list (per-package `check`/`test` from `discoverPackages()`, the
   copy-fidelity sweep, and all workspace-level gates) as descriptors, each carrying its tag set.
2. The scheduler pulls from a ready queue. A step is eligible to start iff none of its tags are
   currently held by an in-flight step and the pool has a free worker slot.
3. `spawnSync` becomes `spawn` (async); each step's stdout/stderr is **buffered per-step**, not
   interleaved live, and flushed to the console atomically when that step finishes — this is what
   keeps failure attribution unambiguous under concurrency (a requirement carried over from the
   current single-stream design, which is already careful about this — see `runItem`'s SKIP-line
   parsing).
4. `record()` remains a single accumulator; the pool serializes calls into it (it's cheap and
   already single-threaded conceptually — no change needed there beyond calling it from callbacks
   instead of inline).
5. Every step still runs even if an earlier one failed — unchanged from today's "one run shows the
   whole picture" invariant. Nothing about parallelizing changes this; a failed step just occupies
   its pool slot and tags for its own duration like any other.

### 3.3 Phased rollout

**Tier 1 — run the elephant first, alone, concurrently with everything else.**
Kick off `elm-m3e: test:browser` (tagged `docs-dist`, `port-1239`) at t=0. Simultaneously start the
bounded pool over every OTHER step that does not carry `docs-dist`. Steps carrying `docs-dist`
(`check-drift`, `copy-fidelity elm-m3e`) queue behind `test:browser` and run after it joins — but by
then the other ~130s of independent work has already finished, so they're the only things left,
same as today's tail. Expected wall-clock: **max(232s, ~130s) + drift/fidelity tail ≈ 240-250s**,
down from 361.5s. This is the single highest-leverage, lowest-risk change (no reordering within the
~130s group needed yet) and should land first, standalone.

**Tier 2 — attack `test:browser`'s own 232s directly**, independent of Tier 1 and safe to land
before or after it:
- Profile and fix the two 25s+ outlier specs (`mobile-shell.spec.ts:27` at 26.1s,
  `shell-breakpoints.spec.ts:162` at 24.8s) — investigate why they're 3-5x the median spec duration
  before assuming a worker-count retune fixes it; an outlier that slow is more likely a real
  inefficiency (e.g. a fixed-duration wait, an oversized viewport matrix) than starvation.
- Re-validate the `workers: 3` setting in `packages/elm-m3e/docs/playwright.config.ts` — the
  existing code comment claims a higher count "starves slower tests," but 475.9s of summed
  individual durations over 3 workers gives a 158.6s theoretical floor against a measured 170s
  actual — only 7% overhead, meaning the comment's premise should be re-measured at 5, 8, 10
  workers now that this analysis exists, not trusted as-is.
- Cache `build:site` (the elm-pages build + search-index gen that Playwright's `webServer` runs,
  `packages/elm-m3e/docs/playwright.config.ts:76`, ≈28.2s) on a content hash of its actual inputs, so
  a push that doesn't touch anything `build:site` reads gets to skip straight to a cached dist. This
  must be a **cache-and-verify**, not a **skip-if-path-unchanged** — see §4's hard constraint on
  silent skips; a stale-cache false-negative would be worse than the 28s it saves.

**Tier 3 — bounded pool over the remaining ~130s**, this is the mechanism described in §3.2 applied
beyond Tier 1's simple "one big thing vs. everything else" split — once Tier 1 is landed and stable,
extend the same pool to also parallelize *within* the ~130s group (currently it would run serially
inside that bucket even under Tier 1, since Tier 1 only needed one split). Requires:
- Async `spawn` conversion (§3.2 point 3).
- Per-step `ELM_HOME` isolation (§3.4) to neutralize constraint #3.
- Buffered per-step output (§3.2 point 3) so a 10-wide pool's output stays attributable.

**Tier 4 — cheap wins, land anytime, no ordering dependency on the above:**
- Memoize facts-bundle generation across `check-drift`'s multiple consumers
  (`tools/lib/check-drift-core.mjs:243-247`'s `checkConsumerBundleDrift` calls
  `generateBundleToTemp` once per consumer with zero memoization — 3 consumers = 3 identical
  generations) plus `checkProducer` (`check-drift.mjs:83`), plus `factsBundleE2E`
  (`gate-all.mjs:181`), plus 2 more inside `ab-elm-cem.sh:63-71` — 7+ regenerations of an identical
  bundle per full run, ~1.5-2s each. Generate once, pass the same temp-dir path to every consumer.
  This is a strict correctness improvement too: today's separately-generated bundles could in
  principle diverge from each other on a nondeterministic generator bug and no check would notice;
  one shared bundle makes every consumer comparison apples-to-apples.
- Parallelize `check-mirror-drift`'s serial `gh api` calls with `Promise.all` (3.9s → ~1.5s).

### 3.4 Per-step `ELM_HOME` isolation (needed for Tier 3, not Tier 1)

Each pool worker that invokes an Elm-toolchain command (`elm`, `elm-review`, `elm-test-rs`) gets its
own `ELM_HOME` pointed at a per-run scratch directory seeded (hardlinked or `cp -al`'d, not
recopied, to avoid multiplying disk/time cost) from the real `~/.elm`. `elm-review-cem:
check:review`'s `stage-facts-elm-home.mjs` write only affects its own scratch copy, not the shared
one other concurrent steps read from mid-run. This is scoped to Tier 3 because Tier 1 only ever runs
ONE Elm-toolchain-touching step at a time within the "everything but test:browser" pool as currently
proposed (the ~130s bucket does include multiple packages' `check`/`test` scripts, which DO invoke
Elm tooling — so this is actually needed as of Tier 1's very first real concurrency, not deferrable
to Tier 3; flagged as a correction to keep in mind during implementation planning, see §7).

## 4. Hard requirement: no silent skips

This repo has documented prior audit history treating "a gate becomes silently skippable" as a real
bug class — see `CHRONIC_SKIPS` in `tools/gate-all.mjs` (~lines 73-82), added because a past audit
(Finding 1.10) found gates that had silently never run for real, and
`packages/elm-cem/bin/elm-cem.js:55`'s `check-gates` subcommand exists specifically to assert no
check is silently skippable.

Acceptance criterion, non-negotiable: **after every tier of this work, `check-gates` (or whatever
gate-all's own self-verification currently is) must still pass**, and the set of steps that
actually execute on a full run must be identical in membership to today's set — parallelization
changes *when* and *how* steps run, never *whether* they run. If Tier 2's `build:site` caching
produces a cache hit, that MUST show up in the gate's summary output the same way an existing SKIP
does — named, reasoned, attributable — never a silent no-op.

Explicitly, per the research's ranked recommendation #5: **path-based skip logic (e.g. "skip
elm-m3e's checks if this push doesn't touch packages/elm-m3e") is out of scope and recommended
against.** `test:browser` — the one step big enough to be worth skipping — has inputs spanning
nearly the whole repo (generated docs tree, elm-m3e src, `@m3e/web`, config JSONs), so it isn't
safely scopeable by path anyway. This spec's Tier 2 cache is content-hash-based specifically to
avoid this trap (a hash miss always reruns; there is no "trust the git diff" heuristic anywhere in
this design).

## 5. What does NOT change

- The set of steps run, and their pass/fail semantics, are unchanged.
- `record()`'s output shape (name/status/detail) is unchanged; only the concurrency of what calls
  it changes.
- `CHRONIC_SKIPS` and its reasoning are unchanged — this work does not touch network-dependent
  snapshot gates.
- The "every item runs even if an earlier one fails" invariant is unchanged (§3.2 point 5).
- Nothing under `packages/` or `tools/gate-all.mjs` itself changes as part of THIS document — this
  spec is design-only; implementation is a separate, later effort (see the companion plan).

## 6. Acceptance criteria

1. **Tier 1 wall-clock target:** full warm-cache `gate-all` run completes in **≤ 250s** (down from
   361.5s), measured the same way the baseline was measured (warm cache, same machine class).
2. **Tier 2 (after outlier fixes + worker retune) additional target:** `test:browser` itself drops
   from 231.9s to a re-measured figure; no fixed number committed here since it depends on what the
   outlier-spec investigation finds — but the plan must include a re-measurement step, not just a
   changed config.
3. **Tier 3 target:** the remaining ~130s bucket's wall-clock (once running inside the same pool
   concurrently with each other, not just concurrently with `test:browser`) drops meaningfully below
   130s — exact target TBD pending real scheduling overhead measurement, but the pool should not
   regress below Tier 1's already-achieved number.
4. **Correctness gate (blocking, all tiers):** `check-gates` (or equivalent self-verification) still
   passes; step membership is unchanged; no step becomes silently skippable; failure attribution in
   merged/buffered output remains unambiguous (a step's failure output must be traceable to that step
   even when several ran concurrently).
5. **Constraint gate (blocking, all tiers):** none of the four constraints in §2 may be violated —
   verified by an explicit stress test in the plan (e.g. force `test:browser` and a `docs-dist`-tagged
   step to both be schedulable and confirm the scheduler serializes them; force two Elm-toolchain
   steps to run concurrently under Tier 3 and confirm no `ELM_HOME` contamination via a diff of
   staged facts before/after).

## 7. Open questions for Jack (flagged, not resolved — this is the async review gate)

1. **Tag model vs. full DAG (§3.1):** this spec chose "exclusion tags" over "explicit dependency
   graph" because none of the four known constraints are true producer→consumer dependencies. If
   Jack knows of a dependency this research missed, the model needs a `dependsOn` field added before
   implementation, not after.
2. **`ELM_HOME` isolation scope (§3.4):** flagged above as needed starting at Tier 1 (not deferrable
   to Tier 3 as the ranked recommendations implied), because Tier 1's "everything but test:browser"
   pool already contains multiple Elm-toolchain-invoking steps running concurrently. Confirm this
   correction before implementation — if wrong, Tier 1 could ship with an unverified race exactly
   like the ones this spec exists to close.
3. **Concurrency ceiling:** is `os.cpus().length` (10 on the measurement machine) the right pool
   width, or should it be capped lower to leave headroom for the developer's editor/other processes
   during a pre-push hook? No data either way; picked as a starting default.
4. **Tier 2 outlier-spec ownership:** fixing `mobile-shell.spec.ts` / `shell-breakpoints.spec.ts`
   directly touches test code under `packages/elm-m3e`, which is a different blast radius (and
   possibly a different owner/timeline) than the scheduler work in Tiers 1/3/4. Should Tier 2 be
   split into its own separate plan/branch so the dispatch-mechanism work isn't blocked on
   Playwright spec surgery, or is one engineer expected to do both?
5. **`build:site` cache invalidation inputs (Tier 2):** the content-hash cache needs an explicit,
   enumerated input list (elm-pages source, `docs/dist` templates, config JSONs, `@m3e/web` version)
   to hash over. This spec does not enumerate that list — it should be pinned down during
   implementation planning, ideally by someone who can trace `build:site`'s actual file reads (e.g.
   via `strace`/`fs_usage`) rather than guessing from the script name.
