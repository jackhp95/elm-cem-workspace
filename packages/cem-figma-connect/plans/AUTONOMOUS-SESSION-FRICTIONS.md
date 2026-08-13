# Autonomous session frictions (2026-07-14, orchestrated)

Frictions found while orchestrating the "bank 4 + breadth" handoff work. One entry
per friction, so future subagents/prompts don't re-hit them. Lead persists these
(subagents RETURN frictions in their final message; lead writes them here to avoid
concurrent-write conflicts across worktrees).

Format: `### AF-NN — <title> (<stage>)` / **Problem** / **Resolution/Guidance** / **Status**.

---

### AF-01 — Figma bridge / publish externally blocked on this device (all stages)
**Problem:** Code Connect *Write* scope is 403 on the `jack` device's personal Figma
account (File Read 200 only). So `publish`, live `get_code_connect_map`, AND new pixel-gate
runs (the gate hits live Figma `export_node_as_image`) cannot run here.
**Guidance:** Treat the pixel gate as the ceiling of local verification. Only components
whose gate ALREADY passed (results cached under `render-cache/gate/<runId>/results/`) can be
banked without a fresh gate. New-component pixel verification defers to an org/enterprise
account. Everything up to (not including) publish + fresh gates is fair game.
**Status:** open (external; needs entitled Figma account).

### AF-02 — verification bounds parallelism this session (orchestration)
**Problem:** The breadth work (~20 components) is where fan-out would pay off, but each
component's TRUTH signal is the pixel gate (AF-01, blocked) or an open user decision. Landing
breadth code in parallel worktrees would produce code that can't be verified-before-merge —
violating the merge-gate rule.
**Guidance:** This session's safely-autonomous work is the UNIT-verifiable slice (banking of
already-gated components; emitter/matcher/harness code changes provable by `node --test`).
Pixel confirmation + publish are a separate supervised pass. Parallelize only genuinely
independent, unit-verifiable units.
**Status:** by-design.

### AF-03 — test/run footguns (all stages)
**Problem:** (a) `src/visual/status.test.mjs`/`test/publish-check.test.mjs` read
`render-cache/results/`; a stray gate run was thought to redden them. (b) Bare `node --test`
mis-discovers `.d.ts` fixtures.
**CORRECTION (verified this session):** (a) was ALREADY closed — `gate.mjs` writes to
`render-cache/gate/<runId>/results/` (commit 47af057), NOT the shared `render-cache/results/`,
and `status()` checks `overrides.json` BEFORE reading any results file, so the two tests were
already immune. Further hardened them to pass an explicit empty `resultsDir` (belt-and-suspenders),
so the `rm -rf render-cache/results` prelude is no longer strictly needed. The earlier claim here
relayed the OLD (pre-47af057) handoff gotcha unverified — lesson: verify a carried-forward gotcha
still applies before repeating it. (b) still holds.
**Guidance:** `pnpm test` (scoped glob, not bare `node --test`). For a single file,
`node --test <path-to-file>.test.mjs` is fine.
**Status:** (a) resolved; (b) worked-around.

### AF-04 — worktree isolation lacks node_modules / render-cache (orchestration)
**Problem:** Fresh git worktrees don't carry gitignored `node_modules` or `render-cache`.
A worktree agent can't `pnpm test` (full) or run the live gate without setup.
**Guidance:** Worktree-isolate only tasks provable with builtins + in-repo files (the emitters
have "no new runtime deps" — a `node --test <onefile>` unit test runs on builtins alone).
Foundational/shared-artifact work (banking regenerates `correspondence.json` + `generated/`)
stays in the main tree, serialized.
**Status:** by-design.

### AF-05 — worktree-isolated agent's edits ALSO appeared in the main tree (orchestration)
**Problem:** Dispatched a `general-purpose` agent with `isolation:"worktree"` concurrently
with a main-tree agent. The worktree agent's edit (`test/elm-emitter.test.mjs`, +134 lines)
ended up in the MAIN working tree too — identical copy in both the worktree and main,
both uncommitted at the same base. The two agents happened to edit DISJOINT files, so
nothing corrupted; had they touched the same file, it would have raced.
**Guidance:** Don't rely on `isolation:"worktree"` to sandbox concurrent edits to the SAME
file in this repo/harness. For parallel agents that might touch the same file, serialize or
partition by file ownership. Combined with AF-04 (worktrees lack node_modules/render-cache),
the practical rule for THIS repo: prefer SEQUENTIAL main-tree agents with lead verification
between them, unless tasks are provably file-disjoint AND unit-verifiable. Verified the
outcome was clean; removed the stray worktree with `git worktree remove --force`.
**Status:** worked-around.

### AF-06 — "driver/data singles" weren't quick; the gate is the ground truth (breadth)
**Problem:** fab/snackbar/rich-tooltip looked like mechanical driver fixes, but after landing
sound, unit-tested driver code (standalone path, null→omit, `#`-name fix), 0/3 passed the gate:
fab 0.48 (real render mismatch), rich-tooltip + snackbar produced ZERO render PNGs (bare shells
render empty). Code that unit-tests green can still render empty/wrong — only the pixel gate reveals it.
**Guidance:** For each breadth component, GATE before assuming a fix works. Most remaining
shells/chips render empty as bare tags → they need **representative-content injection** (decision
#3), which is the pivotal cross-cutting capability, not per-component driver tweaks. Bank only on a
passing gate; land reusable infra separately even when its target component isn't yet bankable.
**Status:** open (content-injection capability pending).

### AF-07 — the GATE ITSELF false-passed (blank/degenerate/size-mismatch) — user-caught (verification)
**Problem:** 3 components banked at 0.000-0.006 (shape/list-item/snackbar) were FALSE passes. The diff
collapsed a blank/degenerate side (a 1×1 Figma export) or a gross size mismatch (8×) to ~0 via UNBOUNDED
scale-normalization (`normalizeScale` downscaled the larger image to the smaller's width for any ratio≥1.5).
The gate — the ground-truth verifier — was itself unsound. The green ratio hid it; only eyeballing the
code-vs-figma-vs-diff renders + their DIMENSIONS revealed it (shape figma 1×1, snackbar figma 1×1, list-item
code 64×112 vs figma 560×160).
**Resolution:** `src/visual/diff.mjs` — `SCALE_NORMALIZE_MAX_RATIO=2.5` (ratio>2.5 diffs honestly) + a
degenerate guard (fully-transparent OR <8px dimension → `pass:false, diffRatio:1, reason`). Re-gated all 12;
unbanked the 3 (→ 9 genuine). Root causes: shape matched an internal leading-dot node; snackbar Figma is
FILL-CONTAINER (1×1 standalone); list-item code renders blank.
**Guidance:** NEVER trust a 0.000 alone — it can be a degenerate/tautological pass. For every bank, confirm
BOTH renders are non-blank and similar-sized (dimensions + a gallery eyeball), not just the ratio. Adversarial
human/visual review before trusting a gate's pass is mandatory (this is the WS2 tautology lesson, in the visual
domain). A convenience to serve the gallery over Tailscale: `python3 -m http.server 8099 --bind <ts-ip>
--directory render-cache/gate` after `node /tmp/gen-gallery.mjs <repo>/render-cache/gate`.
**Status:** resolved (gate hardened + 3 unbanked); the 3 have follow-up fixes (see cem-figma-connect-state memory).

### AF-08 — converting N cases to a new pattern misses the sibling the spec didn't name (SP1 Task 6)
**Problem:** Task 6 demoted the hand-tuned per-tag size blocks (shape/search-bar/list-item) to FALLBACK behind
captured `boundsPx`. The spec NAMED those three, so the implementer gated exactly those three — and left
`m3e-bottom-sheet`'s `el.style.width = "434px"` un-gated. Bottom-sheet is the same structural case (a hand-tuned
size that captured bounds should override), but the spec's example list didn't enumerate it, so it was skipped.
The code-quality reviewer (2nd of the two-stage review) caught it; the spec-compliance reviewer (1st stage) had
already passed it as "spec-compliant" — because it WAS compliant with the letter of the spec. Also surfaced a
split-param gap: primary guard `boundsW && boundsH` vs fallback guard `!boundsW` could both skip if only one param
was present. Fixed by consolidating to one `hasBounds = Boolean(boundsW && boundsH)` used on both sides.
**Guidance:** When a task converts a *category* of cases to a new mechanism, sweep EVERY member of that category,
not just the spec-enumerated examples — grep for the pattern (here: every `el.style.width`/`height` per-tag block)
and gate them all. Spec-compliance review checks "did it do what the spec said"; only code-quality review reliably
catches "the spec's example list was incomplete." Both stages are load-bearing — this is why the two-stage review
exists. Corollary: when two guards encode the same predicate, derive them from ONE boolean so they can't diverge.
**Status:** resolved (commit 9bddaaf; `hasBounds` unifies primary+fallback; bottom-sheet width gated).

### AF-09 — a faked bridge seam hides BOTH a wire-param mismatch AND an O(n²) scale blowup (SP1 Task 7 live smoke)
**Problem:** The capture runner's unit tests inject a FAKE `captureSet` (a plain async fn returning canned variants).
That fake validated the runner's file-writing/resume logic perfectly — but it never exercised the real WS wire
contract to the plugin. Two bugs hid behind it, both only surfacing on the FIRST live smoke:
  1. **Wire-param seam:** `bridgeCaptureSet` sent `{ setNodeId, scale }`, but the plugin's dispatcher pulls the
     target off `params.nodeId` (uniform across every bridge command). Plugin answered `capture_set(...): nodeId
     required`. The fake ignored param names, so 4 green unit tests said nothing about the mismatch.
  2. **Scale blowup:** `capture_set` calls `findRenderableInstance` per variant, which ran `loadAllPagesAsync()` +
     a full-document `findAllWithCriteria({types:["INSTANCE"]})` scan (awaiting `getMainComponentAsync` per instance)
     on EVERY call — O(variants × instances). Button-filled (50 variants) timed out at 120s; the full kit is 6,598
     variant renders across 171 sets (largest set = 600), so the naive version was untenable, not just slow.
**Resolution:** (1) Runner now sends `{ nodeId: setNodeId }`; `bridgeCaptureSet` takes an injectable `query` fn so a
test pins the exact wire shape (`{ nodeId, scale }`) — a real-contract probe, not a behavior fake. (2) Plugin
memoizes a `mainComponentId -> largest instance` index once per run (`buildInstanceIndex`/`getInstanceIndex`);
per-variant lookup is now O(1). Runner per-set timeout raised 120s→300s for the biggest sets + the one-time index
build. Plugin build bumped `.3-capture-set` → `.4-capture-index` (needs a reload).
**Guidance:** When a test fakes a process/network boundary, ALSO add a probe that asserts the REAL wire contract
(inject the transport, assert the exact serialized shape) — a behavior fake proves your side, not the seam. And
LIVE-SMOKE ONE real, representative (non-trivial-sized) unit before any large sweep: the smoke reveals wire-shape,
payload-size, and per-item cost that fakes and single-item tests never will. For any "do X for every child" plugin
op, check whether X does a document-wide scan — hoist/memoize it before it runs thousands of times.
**Status:** superseded by AF-10 (the memoized-index `.4` fix was itself replaced by definition-first `.5`, which
removes the doc scan entirely — see below). Wire-param seam fix stands.

### AF-10 — the render heuristic's DEFAULT was backwards: instance-first mis-captured normal components (SP1 re-gate)
**Problem:** `renderVariant` was instance-FIRST (search the doc for the largest placed instance → definition →
temp-frame). Chosen to fix fill-container snackbar (definition collapses to 1x1). But the FIRST full re-gate of the
12 banked against real captures exposed it: 5 failed, worst icon-button default 0.705. The captured "Round/Small/
Default" icon-button came back 240x104 (aspect 2.31 — a UNIQUE outlier; 79/150 of its siblings are 1.00 square)
because the largest placed instance anywhere in the doc was a non-representative usage; another variant captured as
a degenerate 1x1 instance. Instance-first optimized for ONE edge case (snackbar) and silently corrupted the common
case. The unit tests (fake captureSet) and even the live SMOKE (which only checked "does a set return renders",
Button, which happens to have clean instances) both passed — only eyeballing code-vs-figma across ALL 12 (a human
gallery review, cf. AF-07) revealed it. The `.4` memoized-index "fix" had made the WRONG behavior fast, not correct.
**Resolution:** Jack chose definition-FIRST + drop the doc-instance search entirely. New `renderNodeControlled`
(shared by `capture_set` + `export_node_as_image`): export the DEFINITION (clean canonical render); only if it's
degenerate, render a CONTROLLED off-canvas temp-frame instance at a fixed width. No document scan at all — which
ALSO dissolves the AF-09 perf problem at its source (there is nothing to memoize). Removed `findRenderableInstance`
+ `buildInstanceIndex`/`getInstanceIndex`. Plugin `.4-capture-index` → `.5-definition-first`.
**Guidance:** When a heuristic has a "normal path" and an "edge-case path", make the NORMAL case the default and the
edge case the fallback — not the reverse. A special case (fill-container) justifies a fallback, never the primary
behavior for everything. And a perf optimization is worthless until the thing it speeds up is CORRECT: verify
output quality on a representative sample BEFORE optimizing throughput (AF-09 memoized a scan that shouldn't exist).
The trustworthy signal was the adversarial full re-gate + human visual review, not any green test — bank/accept only
after eyeballing real output across the whole set (AF-07 lesson, re-confirmed in a second domain).
**Status:** fix committed + node-verified (564 green, plugin syntax-checked); awaits the `.5` reload to re-capture + re-gate.
**LIVE RESULT (after `.5` reload):** all 12 banked re-gate PASS offline (icon-button 0.705→0.0008, search-bar
0.124→0.0068, list-item 0.150→0.0777, badge 0.285→0.0547, button→0.095). Definition-first fixed every regression.

### AF-11 — the dump goes STALE and one-response-per-set doesn't scale (SP1 full sweep)
**Problem:** Two independent limits surfaced only on the FULL 171-set sweep (acceptance — 12 banked — had passed):
  1. **Dump staleness.** `capture_set` resolves variant/set nodes by id from `research/figma-dumps/figma-export.m3-kit.json`.
     That dump is OLDER than the live Figma file, so ~674 variant records + 24 whole sets came back "in get_name: node
     does not exist" (deleted/regenerated nodes — e.g. 'List item -4 Density baseline', Segmented button, internal .Shape).
     Benign (none banked), but it means the dump and the live file silently diverge over time; a comprehensive capture
     is only as complete as the dump is fresh.
  2. **Payload scale.** capture_set returns EVERY variant's base64 PNG in ONE WS response. A 480-variant set ships a
     huge single message → >300s → timeout. 3 mega-sets (480/480/120) skipped. Final coverage 144/171 sets, 3,575 renders.
**Resolution / deferral:** Runner now skip-and-continues (AF-09 commit), so the sweep completes with a `{skipped}`
report instead of aborting. Storage = gitignore (D3), so partial coverage is fine — regenerate on demand. TRUE 100%
coverage is a documented FOLLOW-UP, not SP1: (a) re-export a fresh dump to kill the staleness errors; (b) chunk
capture_set with offset/limit (or stream per-variant) so mega-sets fit the WS timeout. Neither blocks any banked binding.
**Guidance:** A pipeline keyed off a cached snapshot (a dump, an export, a scrape) must treat "node not found" as
EXPECTED drift, not a bug — report it as a freshness signal, don't crash. And any "return all N children in one
response" bridge op has an implicit size ceiling: design for chunking BEFORE N gets large (here N reached 480). Verify
scale limits on the biggest real input, not the median one — acceptance (small banked sets) passed while the sweep
(mega-sets) did not.
**Status:** SP1 acceptance MET + committed. **PARTLY WRONG — see AF-13:** claim (1) "dump staleness" was a
MISDIAGNOSIS (a fresh re-extraction produced an IDENTICAL 171-set list; the 24 sets exist live). Claim (2) "payload
scale" was also incomplete — chunking shipped but even a chunk of 1 hangs on the affected sets, so the real limit is
per-variant RENDER cost, not response size. The true root cause of BOTH the 24 "stale" sets and the 3 "mega" sets is
one thing: a per-variant `exportAsync` stall on asset-heavy scaffolding (AF-13).

### AF-12 — "new WS channel" does NOT prove the plugin reloaded its code (100%-coverage, capture_set chunking)
**Problem:** After shipping `.6-capture-chunked` (capture_set gains offset/limit), asked for a plugin reload; got a
fresh channel `cem-f71bd7` and assumed the new code was live. It wasn't — a paginated `capture_set{limit:2}` still
timed out, i.e. the plugin IGNORED limit and rendered all 120 variants → it was running the OLD `.5-definition-first`
code (no offset/limit). A new channel comes from the UI (ui.html) reconnecting to the relay; that is INDEPENDENT of
whether Figma re-read code.js from disk. So "I reloaded, here's the new channel" silently shipped stale code against
a new wire contract. Worse: each probe made the stale plugin start an all-120 render (single-threaded), and it WEDGED
— even `ping` then timed out (jobs queued), so it needed a hard reload to recover.
**Resolution:** `ping` now returns `{ build: PLUGIN_BUILD }` (commit 677ebaa). The reload protocol is now VERIFIABLE:
after any reload, `wsQuery("ping")` and assert `res.build === "<source build>"` BEFORE running a capture. No build
field / mismatched build ⇒ the reload didn't take, don't proceed. There is no plugin build step (manifest `main:
"code.js"` loads `extract/plugin/code.js` directly), so a genuine re-run from Plugins→Development always loads disk.
**Guidance:** For a live plugin/bridge over a reconnecting transport, NEVER treat a new connection/channel/session id
as proof of a code reload — the transport and the code have independent lifecycles. Bake a version/build echo into a
cheap health call and verify it after every deploy/reload. And note the single-threaded footgun: probing a busy Figma
plugin queues work and can wedge it (ping included) — verify build FIRST, then capture; if wedged, only a reload clears it.
**Status:** ping-build affordance committed + PROVEN (a `.6` reload verified clean via ping-build on first use, after an
earlier reload had silently NOT taken). This affordance immediately earned its keep.

### AF-13 — chased a coverage ghost: three wrong diagnoses before the real one (per-variant export stall) (100%-coverage)
**Problem:** The 27 uncaptured sets (of 171) were diagnosed THREE times wrong before the truth, each time acting on the
guess before proving it:
  1. "Dump staleness" (AF-11) → drove a full dump RE-EXTRACTION. But the fresh dump was byte-structurally the SAME
     171 sets; the sets exist live. The `capture` CLI only reads the SET LIST from the dump and renders variants LIVE,
     so a same-structure refresh cannot change capture coverage at all. Wasted a live extraction (harmless — banked
     survived, tokens carried) chasing a non-cause.
  2. "Payload too big for one WS response" → drove `capture_set` PAGINATION (offset/limit). Correct infra, but a
     paginated `limit=1` STILL didn't return in 90s on an idle, build-verified plugin — so response size was never the
     binding limit for these sets.
  3. "Fill-container temp-frame hang" → I told Jack the mega-sets hang on the temp-frame path and had him authorize a
     "fix fill-container render." But my evidence was CONTAMINATED: the `limit=1/5` probes ran while the single-threaded
     plugin was still churning a prior all-120 job, so they measured queue backup, not per-variant cost.
  **The real cause (clean data — idle plugin, build verified, `limit=1`):** a single variant of a heavy set
  (`59106:13028`, a List-item DENSITY baseline) does not return in 90s. These sets carry image/video/avatar fills
  ("Show image"/"Show video thumbnail" axes); `exportAsync` stalls loading those assets. It's a Figma-export limitation
  on asset-heavy SCAFFOLDING sets — none are banked components. Every real component captures fast + re-gates green.
**Resolution:** Corrected AF-11. Added a per-variant timeout guard (`raceTimeout`, plugin `.7-per-variant-timeout`) so
a stall becomes a recorded error + the sweep completes + the sidecar shows exactly which variants stall (diagnosis as a
byproduct). Reframed the leftover "fix fill-container" work onto SNACKBAR specifically (a real component, fill-container
but NOT asset-heavy → a separate, tractable problem). Both parked pending a `.7` reload (Jack deferred).
**Guidance:** When a probe measures a shared, single-threaded resource, ISOLATE it first — an idle, verified baseline —
before drawing a conclusion; a contaminated measurement is worse than none because it feels like evidence. Don't act on
a diagnosis (re-extract, add pagination, ask for authorization) until ONE clean measurement confirms it — I shipped two
real code changes + a live extraction against three wrong guesses. And "100% coverage" of a vendor artifact can be
capped by the VENDOR (Figma can't export these), not your pipeline — verify the ceiling is yours to move before promising it.
**Status:** root cause PARTLY corrected again by AF-14 — the mechanism is a SYNCHRONOUS thread block (not async asset
I/O), which is why the `.7` guard (a `setTimeout` race) can't bound it, and snackbar (NOT asset-heavy) stalls too.

### AF-14 — the guard can't catch a SYNCHRONOUS block, and I re-contaminated the measurement (snackbar, `.7` live)
**Problem:** After a VERIFIED `.7` reload (ping-build confirmed — that part worked), I tried to capture snackbar
(`53977:33575`, fill-container, predicted "tractable" in AF-13). It timed out. Two hard findings + one repeated mistake:
  1. **The `.7` per-variant guard is INEFFECTIVE.** A clean `limit=1` on snackbar did not return in 30s AND the 15s
     `raceTimeout` never fired. A `setTimeout`-based race can only fire if the JS event loop is free; here the render
     BLOCKS THE THREAD SYNCHRONOUSLY, so the timer callback never runs. You cannot bound a synchronous native stall with
     a JS timer from inside the same isolate. The guard I shipped in `.7` does nothing for the actual failure mode.
  2. **The stall is compute-bound, not asset I/O.** If it were async image loading (AF-13's guess), the event loop would
     be free and the guard WOULD fire. It doesn't → the block is synchronous (temp-frame `createInstance`/auto-layout
     reflow, or Figma's synchronous rasterization of a complex fill-container node). So AF-13's "exportAsync loads image
     assets" mechanism is also wrong. And snackbar — NOT asset-heavy — stalls too, so "asset-heavy" was never the axis;
     the common factor is the fill-container TEMP-FRAME render path (the 144 fast sets all took the DEFINITION path).
  3. **I contaminated the measurement AGAIN (the exact AF-13 lesson).** The first snackbar `--only` call blocked the
     single thread; my follow-up snackbar `limit=1` probe and a switch "control" both queued behind that wedged job and
     timed out — so the switch "control" (a known-good definition set) looked like it hung, when it was just blocked
     behind snackbar. `ping` then confirmed the plugin fully wedged (no response in 20s). One synchronous block wedges
     the entire plugin until reload; there is no draining.
**Resolution (pending Jack's call):** The `.7` guard should be considered non-functional for this class (candidate for
removal). Snackbar is NOT a quick win — it hits the same synchronous fill-container render block as the scaffolding
sets. Real paths forward, each needing reload(s): (a) INSTRUMENT `renderNodeControlled` (timing log around definition-
export vs createInstance vs temp-frame-export) to isolate the exact blocking call, then route around it; (b) for
snackbar, try exporting a PLACED INSTANCE (no createInstance/resize) — but if the block is in `exportAsync` itself,
that stalls too. Both uncertain. Or ACCEPT: fill-container components use the gate's live-export fallback, not offline
capture; snackbar stays unbanked-via-capture.
**Guidance:** (1) A JS timeout guard is worthless against a synchronous/native block in the same isolate — know whether
a stall is I/O-bound (awaitable, guardable) or compute-bound (thread-blocking, NOT guardable) before "adding a timeout."
(2) I violated the AF-13 isolation lesson ONE probe after writing it — writing a lesson down is not the same as
following it. Hard rule for this plugin: `ping` to confirm idle BEFORE every single live capture probe, and NEVER fire
a second probe until the first returns. One block wedges everything.
**Status:** RESOLVED — Jack chose accept-and-close. Ineffective `.7` guard removed (`.8-drop-guard`, commit 5a6a2d0);
fill-container components (snackbar + the ~27 scaffolding holdouts) use the gate's live-export fallback, not offline
capture. The 12 real banks + 144 definition-path captured sets stand. Thread closed; plugin can be closed at leisure.

### AF-15 — "only 13 components?" was a MATCHER gap, not a coverage ceiling; + subagent-plan execution notes (matcher tier)
**Problem/finding:** Jack pushed back on my claim that card/avatar/tooltip/dialog/breadcrumb "have no match at all" — CORRECTLY.
They all EXIST in the Figma dump; the MATCHER just dropped them because the kit prefixes sets with descriptive qualifiers
(`Generic avatar`, `Stacked card`, `Connected button group`, `Circular-determinate…`) that `slugify` doesn't strip →
exact-miss + fuzzy score ~0.42 < 0.5. 18 CEM tags had a token-containment set the matcher ignored; ~9 real components.
LESSON: "no correspondence produced" ≠ "no Figma component exists" — I reported a matcher miss as an absence without
checking the dump. When asserting a NEGATIVE (nothing matches), grep the source of truth first.
**Built (brainstorm→spec→plan→subagent-driven):** a new **"contains" matcher tier** (`src/match/qualifier.mjs` + normalize
helpers + matcher wiring) binding qualifier-prefixed sets to their bare CEM tag via token-subset (longest-CEM-wins),
resolving the qualifier to a fixed attr (reusing `valueMatch` + fusion's leftover) or gapping when unresolvable. Result:
**10 new `tier:contains` proposed entries** (avatar, tooltip, card, button-group, circular/linear-progress, dialog, slider
+ menu-item/nav-item sub-parts); 13 confirmed bindings + emit BYTE-IDENTICAL; byte-stable re-match holds. 8 commits,
reviewed + APPROVED + a fix-pass (determinism tiebreak, gap-report contains inclusion, DRY helpers to normalize.mjs).
**Execution frictions (observed):** (1) plan UNDER-SCOPED the tier-value plumbing — a new `tier`/`matcherKind` value needs
`schema.json` enum + `gap-report.mjs` counting/coverage updates; the plan only listed matcher.mjs, so the implementer
correctly expanded to 9 files. (2) plan TEST-FILE PATHS wrong twice (`src/match/normalize.test.mjs` & `matcher.test.mjs`
didn't exist there; the real matcher tests live in `test/`) → a duplicate `matcher.test.mjs` I renamed to
`matcher-contains.test.mjs`. (3) plan TEST ASSERTIONS used title-case for slug-derived LOWERCASE tokens (`"Connected"` vs
`"connected"`) — a TDD implementer correctly went BLOCKED rather than guess (the process working). (4) I wrote a FALSE
"avoid import cycle" claim into the spec (no cycle exists) that caused needless helper duplication — the code reviewer
caught it. (5) `m3e-radio` is an unavoidable gap: `radio-button` slug contains `button`, the 1-token ordinal tie picks
`m3e-button` (consumed) → radio drops rather than mis-bind (safe). (6) pre-existing FLAKY test: `test/publish-check.test.mjs`
#554 (`runCheck`) fails in the FULL suite but passes in isolation (43/0) and `check` reports 0 drift — an AF-03-class
render-cache/generated shared-state race between concurrent tests, NOT a matcher regression. Worth a separate test-isolation fix.
**Guidance:** When planning a change that introduces a new ENUM/tier VALUE, enumerate every consumer of that field
(schema, reports, counters, tests) as tasks — a value isn't "added" until all consumers handle it. Verify test-file
PATHS against the repo before writing plan code (grep for the existing test). Don't assert architectural constraints
(cycles, coupling) in a spec without checking the actual import graph.
**Status:** matcher tier SHIPPED + green; banking the ~8 newly-matched real components (gate→confirm→emit→tracer) is the follow-on.

### AF-16 — banking the contains-tier matches: avatar #14 (+ a gate false-pass fix), then the OFFLINE ceiling (matching ≠ banking)
**Finding:** Jack said "bank the 8" autonomously (max coverage/correctness/completeness). Reality: **matching ≠ banking** —
the matcher matched 8 correctly, but banking needs FAITHFUL rendering, which most can't achieve. Triaged all offline-gateable
proposed components (gate each vs its captured render, AF-07 eyeball):
  - **avatar → BANKED #14.** Gated 0.07 "pass" but that was a FALSE pass (code monogram "A" vs Figma person-icon default).
    Root cause: avatar's `Style` axis is UNMAPPED (no CEM attr), so the gate pinned the Figma side to the axis's default
    variant (person) while the code (Letter text) renders a MONOGRAM — non-comparable, yet low-ratio because both are
    circles. FIX (`src/visual/drive.mjs`, commit abd0ef5): a figmaSet's `fixedAttrs` may pin an UNMAPPED axis's Figma
    variant for gating — `fixedAttrs:{Style:"Monogram"}` compares the code monogram against the Figma **monogram** variant
    → 0.0000, faithful. Banked (commit 70c56b9). ALSO found+fixed an emitter bug: html-label.mjs + elm.mjs treated ALL
    `fixedAttrs` keys as CEM attr names → axis-pin keys (Style) must be filtered out (fusion fixedAttrs use CODE attr
    names, axis-pins use FIGMA axis names — dual semantics, now commented). LESSON: an unmapped distinguishing axis is a
    gate FALSE-PASS trap — the gate compares the code render against a Figma variant the code can't represent; the low
    ratio hides it. Always eyeball (AF-07), and pin the comparable variant.
  - **OFFLINE CEILING = 14.** The other offline-gateable proposed are all containers/composites: card (0.96 — Figma is a
    full showcase: avatar+header+media image+title/body+2 buttons), button-group/dialog/app-bar (render BLANK as bare
    tags → 0.00–0.06 near-degenerate false-lows), segmented/split-button/fab-menu (composites that DIVERGE ~0.4, per the
    earlier content-injection finding). None fit the avatar pattern (simple + variant-misaligned); they need representative
    CONTENT the harness can't faithfully reproduce (rich showcases) — the same wall as segmented-button. Grinding them is
    low-EV.
  - **NEEDS LIVE CAPTURE (blocked):** tooltip, circular/linear-progress-indicator, slider — 0 good captured renders
    (thin/hidden-by-default; degenerate in the SP1 sweep). These SIMPLE components would likely bank cleanly IF captured
    faithfully → need a fresh live channel (plugin reload). May still hit the SP1 degenerate/thin issue; uncertain.
**Open policy question for Jack (composite banking):** rich components (card/dialog/app-bar/button-group) have CORRECT
bindings but the pixel-gate demands the code reproduce the Figma SHOWCASE, which is infeasible. Banking them with a
representative example (not showcase-pixel-matching) would unlock big coverage but weakens the AF-07 gate discipline. A
real decision, not mine to make unilaterally.
**Status:** 14 banked (avatar added offline + a gate correctness fix); offline ceiling reached; PINGED Jack for a live
channel (simple components) + the composite-banking policy call.

### AF-17 — representative-example coverage sweep: 12→28 banked; force-render unlocks overlays; 0-set = unbankable (autonomous max-coverage push)
**Finding:** After Jack approved the composite-banking policy ("bank with a representative example; the binding is the value,
not showcase-pixel-repro"), swept ALL 16 proposed components for offline example-banking. Grew banked **12 → 28** across
this session. Method that worked, in order of leverage:
  1. **`scripts/render-batch.mjs`** (new, committed e83216c) — one browser/bundle reused across N markups → eyeball a whole
     batch of candidate examples at once instead of N slow `render-example.mjs` launches. This is the AF-07 discipline at
     scale; the size-clustering heuristic (identical byte size = identical blank-stage baseline) pre-triages blanks, but
     ALWAYS eyeball (never trust the ratio/size alone — that's the whole AF-07 lesson).
  2. **Force-render for JS-shown overlays.** menu/tooltip/rich-tooltip render BLANK as static markup (shown via a JS API,
     not an attr). Added an optional post-mount `js` hook to render-batch that calls `.show(anchor)` / sets `isOpen` — this
     revealed faithful renders for menu (Cut/Copy/Paste), tooltip, rich-tooltip → all 3 BANKED (#26–28). fab-menu's
     `.show()` was a no-op (still blank) and snackbar has NO show() (queue-based `current` field) → both still need live.
  3. **`open`-attr composites just work.** dialog was thought "degenerate 32×32" — that was the CLOSED state; `<m3e-dialog
     open>` + header/content/actions renders a textbook Material dialog → BANKED #25. Lesson: a component thought
     unbankable may just need its meaningful state attr.
  4. **width-collapse ≠ unfaithful.** linear-progress collapses to a dot standalone (fills its container's width); wrapped
     in `width:320px` it renders a faithful M3 bar. The BARE emitted binding stays the correct Code Connect reference —
     collapse-in-isolation is a harness artifact, not a component defect. (Deferred anyway — see below.)
**Two hard walls hit:**
  - **0 figma sets = UNBANKABLE (canonical-only match).** icon and tab are `proposed` but have `figmaSets:[]` — the matcher's
    canonical-only mode matched the NAME but there's no concrete Figma component/node to attach Code Connect to. Emit has
    nothing to bind. Correctly undroppable-into-a-bank. (Not a bug — the match is real, but a match without a Figma node
    can't become a binding.)
  - **animation-frozen.** loading-indicator renders a solid square — it's an animated morphing shape and the harness disables
    motion for determinism (`reducedMotion:reduce`, `animations:disabled`). Can't verify offline; needs live or a
    motion-enabled capture.
**Two-path emit for example-banking (important pattern):** a component with a real TEXT→`content` binding (tooltip:
"Supporting text"→content) banks via STANDARD emit to PRESERVE that binding (`<m3e-tooltip>${supporting}</m3e-tooltip>`);
adding an examples.json entry would OVERRIDE and lose the binding. Components with unmapped/absent content props (menu,
rich-tooltip, dialog, list, toolbar, tabs) need examples.json explicit children. Decide per-component by inspecting the
correspondence props BEFORE writing an examples.json entry.
**DEFERRED — needs a root-attrs emission increment (design-bearing):** circular/linear-progress each have 2 sets
(determinate/indeterminate) split by an UNMAPPED axis + need a representative `value`/`indeterminate` in the emitted
example to render meaningfully. That's per-set static root-attr injection — an extension of examples.json (add an optional
root `attrs` map) PLUS the avatar-style unmapped-axis pin, but for EMISSION not gating. Real feature; wants a plan (not
rushed — rushing the determinate/indeterminate distinction risks an UNSOUND bank, the exact avatar false-pass class).
**Tooling friction (logged, non-blocking):** a PreToolUse hook MANDATES `graphify query` before grep, but
`graphify-out/graph.json` does not exist (`graphify` errors "graph file not found"). The hook's premise is stale/wrong for
this repo — fell back to targeted Read/grep. Eddie: the hook fires unconditionally without checking the graph exists.
**Status:** 28 banked, all gates green (byte-stable, 0-drift, 611 tests modulo the AF-03 flake). Remaining 9 proposed:
icon+tab (0-set, unbankable), circular/linear-progress (deferred root-attrs increment), slider/loading-indicator/snackbar/
fab-menu/bottom-sheet (need live channel). Publish still blocked on org PAT.

### AF-18 — progress-indicator increment: per-set example attrs (set-attrs.json), the filename trap, and check.mjs threading gap (RECURRING) — banked 28→30
**Finding:** Banked circular + linear progress (each 2 sets: determinate/indeterminate) via a new emit-time config
`profiles/m3-kit/set-attrs.json` (`cemTag → setName → {attr:value}`) merged into the example root attrs. Design at
`plans/2026-07-19-progress-set-attrs-design.md`. Key discoveries + traps, in order:
  - **The soundness bug (why this needed care):** circular's 2 sets had EMPTY `fixedAttrs` — the contains-matcher's
    qualifier resolver (`qualifier.mjs:resolveMemberToAttr`) only binds ENUM values, and circular distinguishes state with
    an `indeterminate` BOOLEAN (not a `mode` enum like linear). So both circular sets would emit IDENTICAL code — the
    determinate + indeterminate Figma sets collapsing to one binding (the avatar false-pass class). Linear was already
    sound (its `mode` enum matched). Fixed by giving each set distinct attrs via set-attrs.
  - **The filename trap (killed the "obvious" fix):** `setSlugOf` derives each file's name from `fixedAttrs` VALUES. So
    putting a representative `value="70"` in fixedAttrs → `…-70.figma.ts`, and circular's boolean → `…-true.figma.ts`.
    Representative/state attrs therefore MUST travel a channel that feeds the example markup but NOT the filename → emit-
    time set-attrs, not match-merged fixedAttrs. (The Explore agent recommended match-merge for auditability; the filename
    coupling — which the agent's map surfaced but didn't weight — overrode that. Read the map, then re-derive; don't adopt
    a sub-agent's recommendation verbatim.)
  - **Indeterminate can't render faithfully offline** (animation frozen by `reducedMotion:reduce` — circular→ambiguous arc,
    linear→empty track), but confirming a cemTag emits ALL its sets (all-or-nothing per tag). Banked anyway: the
    indeterminate BINDING is provably correct (`indeterminate`/`mode=indeterminate` are the exact CEM attrs); the render
    limit is the harness, not the binding (same as tooltip/menu hidden-by-default). Honest per-set notes record which sets
    are render-faithful (determinate) vs binding-only (indeterminate).
  - **Elm skips gracefully:** circular/linear aren't in elm-facts → the elm emitter `return []`s (quiet no-op, run.mjs
    `continue`s). So they bank WEB-COMPONENTS ONLY (+4 wc files, +0 elm). The prior invariant "every confirmed ∈ elm-facts"
    is now relaxed. The bank's smoke tracer must update the wc manifest (28→30 keys) but LEAVE the elm manifest at 28.
  - **RECURRING BUG — check.mjs / run.mjs context divergence (2nd occurrence):** the mechanism subagent threaded `setAttrs`
    through the EMIT path (`run.mjs`) but not the parallel `check.mjs computeInMemoryEmit` (it destructured + passed
    `examples` but not `setAttrs`) → `check` regenerated the 3 set-attrs files WITHOUT their attrs → FALSE DRIFT (caught by
    the `check` gate + the publish-check test, NOT by the mechanism's own tests, which didn't confirm a set-attrs
    component). This is the EXACT same gap the examples.json work hit (memory: "check.mjs false-drift"). **Root pattern:**
    `buildEmitContext` is called from two places (run.mjs emit + check.mjs regen) with a hand-maintained param list; every
    new ctx field must be added in BOTH or check silently false-drifts. **Eddie improvement:** have check.mjs spread the
    whole `computeEmitEntries` result into `buildEmitContext` (or make buildEmitContext take the result object) so new ctx
    fields flow to both paths automatically — this bug will recur a 3rd time otherwise. Fixed here (commit 0682d3e) by
    threading setAttrs; verified 0 other callers diverge.
  - **Sub-agent truncation:** the bank subagent's return was truncated mid-tracer-edit (smoke manifest keys + html-label
    confirmedTags left un-updated, uncommitted). Verified repo state directly (never trust a truncated return), finished the
    tracers by hand, found+fixed the check.mjs drift, committed. LESSON: on a truncated/incomplete sub-agent return, re-derive
    state from the repo, don't assume DONE.
**Status:** **30 banked**, all gates green (0-drift after the check fix, byte-stable — 28 prior banks byte-identical, 628
tests modulo the AF-03 flake #588 which passes 43/0 isolated). **TRUE OFFLINE CEILING = 30.** Remaining 7 proposed: icon+tab
(0-set unbankable), slider/snackbar/fab-menu/bottom-sheet/loading-indicator (need a LIVE channel — hidden/animated/host-
sized offline). Publish blocked on org PAT.
