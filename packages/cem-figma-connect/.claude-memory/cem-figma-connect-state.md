---
name: cem-figma-connect-state
description: cem-figma-connect (CEM↔Figma Code Connect gen) — 43 components banked + appendSets "2nd-set" mechanism COMPLETE (2026-07-19 late): 11 2nd-sets banked (toggle button x4, toggle icon-button x4, Extended FAB, tab content x2) via applyManualToExisting (merge parking fix) + axisGridSets (visual-sampler exclusion). All AF-07 render-verified, match byte-stable, check 0-drift, full suite green (modulo AF-03 publish-check flake, passes isolated). 2 "Secondary tabs" sets parked (library gap — m3e-tab has no secondary affordance), FLAGGED for Jack. Publish still blocked on org PAT.
metadata: 
  node_type: memory
  type: project
  originSessionId: 13773566-6623-443c-9045-3fb7e873ac01
---

**🟢 FIGMA→ELM EMIT PARITY — PLAN EXECUTED, branch `elm-emit-gap-closure` READY FOR JACK (2026-07-20).** Figma Connect emits TWO targets (`html-label`→web-components, `elm.mjs`→elm; runner `src/emit/run.mjs`). Elm was at 40/43; **now 43/43** (wc-only=[], elm-only=[]). Fable (`claude-fable-5`) planned it (`plans/2026-07-20-elm-emit-gap-closure.md`; 3 decisions folded in as amendments A1–A3); I executed all 5 tasks (opus) after a background sonnet subagent flaked (2 frictions logged re: in-harness subagent final-message truncation + SendMessage unavailable). **5 commits on `elm-emit-gap-closure` (base b66a1c9): 3901b2d facts-builder group support; 5f787b2 remeasure→f1c7beb (+2 progress aliases, accepted additive-only drift Jack-approved); 875c9f0 float set-attrs; e623eb6 icon branch+A2+A3; 9598ac7 full regen 43/43.** Mechanisms: **(icon)** parallel iconTable branch in elm.mjs → 141 `M3e.Icon.view [ M3e.Icon.name "x" (,filled True) ] []` (was `elm.mjs` explicit `return []` on kind:iconTable). **(progress)** elm-m3e unifies circular/linear as ONE `M3e.Progress` module w/ group constructors; taught `elm-facts.build.mjs` to parse `groupConstructors` + measure per-variant ALIAS facts (`parseSetterSignature`, `measureGroupAliases`, `setterArgTypes`) → both CEM tags emit via existing emitEntry, ZERO emitter hardcoding (honors CARDINAL RULE). **Amendments Jack chose:** A1 elm-m3e refactor in-flight → facts re-derivable, never pin dangling 93d2edc, accept-and-rebank additive drift after inspecting; A2 **`[]` for no-text children KIT-WIDE** (was `[ Kit.text "" ]`; seam import dropped when unused; record/pipeline forms guarded — they need a content element); A3 **single provenance stamp** — dropped per-file `elm-m3e @ <commit>` header, provenance lives once in elm-facts.json top-level `elmM3eCommit` (so a remeasure churns 0 files). **CRITICAL LANDMINE fixed:** committed `elmM3eCommit 93d2edc` was a DANGLING commit from rewritten history; real checkout `~/Documents/code/elm-m3e`@f1c7beb renamed Facts.elm `surfaces`→`facets` — running the OLD builder would've silently hollowed every surface (0 matched===0 total, no alarm). Builder fixed first, remeasure gated additions-only. Verified vs real elm-m3e source (M3e.Progress exposes circular/linear+setters; all 6 Token enum values exist; value:Float) — no hallucinations. **Evidence:** byte-stable double-emit, web-components tree BYTE-IDENTICAL (html-label untouched), check gate 0-drift/0-orphan, full suite 686/687 (only failure = pre-existing AF-03 publish-check flake, passes 43/43 isolated). Delegated reviewer (sonnet) found only 1 NON-blocking pre-existing wart: 38 emitted files (incl. base app-bar) `import M3e.Token` without using it (importsFor adds tokenModule unconditionally — pre-existing, valid Elm, possible future cleanup like A2). **✅ MERGED to main + PUSHED 2026-07-20 (origin/main = `43163fa`, ff-merge; branch deleted).** The push also carried the earlier unpushed local-main session work (appendSets banking `23deb7e`, gate fix `b66a1c9`, etc. — origin was stale at aa44179). Housekeeping commits folded in on merge: `42936f4` server --host, `6ed900f` overrides.json (bottom-sheet+snackbar approvals), `43163fa` plan docs. Post-merge sanity: 43/43 parity, elm tests 55/55.

**📐 SURFACE-AREA AUDIT — DEFINITIVE COVERAGE MODEL (2026-07-20, Jack-directed).** Cross-referenced our banks against the REAL m3e component set (repo `matraic/m3e`, `packages/web/src/` = ~55 component folders; CEM manifest `test/fixtures/m3e-web-2.5.14/dist/custom-elements.json` = **121 custom elements**). **47 banked.** The other 74 are NOT gaps: **(a) children/sub-parts** (button-segment, menu-item-checkbox/radio, nav-menu-item, chip, tab-panel, list-item-button, dialog-action/trigger, slider-thumb, *-toggle/*-trigger, option/optgroup, month/year-view, step/step-panel, breadcrumb-item, tree-item, slide…) → **covered by their banked PARENT via composition** — Jack's rule: "as long as the parent composes the sub-component correctly we don't bind the child standalone; only delve in if the parent can't be opinionated about descendants, and it can." **(b) pure primitives/infra** (ripple, state-layer, focus-ring/trap, elevation, pseudo-checkbox/radio, text-highlight/overflow, scroll-container, floating-panel, theme/theme-icon, heading, content-pane, toc, textarea-autosize) → **no Figma node, not user-facing → never bindable.** **(c) m3e-only top-level additions NOT in the Figma M3 Design Kit** (autocomplete, breadcrumb, paginator, select, skeleton, split-pane, stepper, tree) → **no Figma node → structurally unbindable** (verified: `divider`/`carousel` DO have nodes; those 8 do not). **NO clean bindable gaps remain.** Two components have a Figma node but resist a clean bind: **m3e-divider** (Figma only has "Divider with subhead" `51816:5872` = line+text composition; m3e-divider has **zero slots**, it's just a line primitive → covered in-context inside banked lists/menus, NOT a standalone bind) and **m3e-slide-group/carousel** (`53912:27480`+`54577:26060` exist, but code renders BLANK standalone — host-dependent, same hard class as fab-menu/loading-indicator). **ACTION taken:** removed the 3 provisional child composites I'd added for review (button-segment/menu-item-checkbox/nav-menu-item) from manual-correspondence + correspondence (byte-reverted to committed 47-entry baseline); confirmed they're not matcher-reachable (only appeared because manually added). **Jack's 2 review approvals landed in overrides.json:** m3e-bottom-sheet ("looks fine, can omit sheet content; notch missing in code; largely correct") + m3e-snackbar ("looks great!"). Review queue now **0 pending**. Added opt-in `--host` to review server (`--host 0.0.0.0` → tailnet at `http://jacks-macbook-pro.tail93dc3b.ts.net:4747` / `100.91.86.46:4747`; loopback stays default so tests unaffected).

**🖥️ VISUAL REVIEW SERVER LOADED FOR JACK (2026-07-20).** Running at **http://127.0.0.1:4747** (`node src/visual/review/server.mjs --profile m3-kit --port 4747`) with **6 eyeball items**, each showing code-render vs Figma-export vs pixel-diff (all 18 artifacts serve HTTP 200): m3e-snackbar (0.167), m3e-bottom-sheet default (0.087) + axis-modal-true (0.639), m3e-button-segment (0.636), m3e-menu-item-checkbox (0.603), m3e-nav-menu-item (0.269). High ratios are the alignment gap Jack wants judged (tight code-element bounds vs full Figma set) — approve/reject/retarget writes `overrides.json`.
- **Mechanism to inject a review item = provisional gateable cemTag:** add to `manual-correspondence.json` a single primary figmaSet with **NO slugSuffix** (so `axisGridSets` includes it → `sampleDefault` returns exactly 1 "default" state) → `node src/cli.mjs match` → write a custom record via `comparePngFiles({entryId,stateId:"default",codePath,figmaPath,thresholds,entry})` + `writeResultRecord(rec,{cacheDir:abs render-cache, runId:"bridge-review"})`, appending to `render-cache/results/bridge-review.jsonl`. Code+figma PNGs must live UNDER `render-cache/` (server `/api/image` only serves there) — copied into `render-cache/bridge/{code,figma}/`. Only real CEM-manifest tags pass match (the 3 composites are real).
- **UNCOMMITTED, INTENTIONAL:** `correspondence.json`+`manual-correspondence.json` carry the 3 provisional composites (m3e-button-segment/menu-item-checkbox/nav-menu-item, status:proposed) — must stay dirty for the server to read them; Jack's review decides. Real code renders driven from `/tmp/review-code-specs.json`.
- **NOT gateable (skipped):** m3e-fab-menu (harness `<m3e-fab-menu>` stays `hidden` — popover=manual, `.show()` no-op → Playwright visible-locator times out; figma side never runs) + m3e-loading-indicator (blank both sides). Harness limit, not plugin.
- **Captured but UN-surfaceable (not real cemTags → match rejects):** Secondary tabs icon+label `54563:40366` / label-only `54563:40319` / List dialog `52112:28937` — figma+code pairs persisted at `render-cache/bridge/extra/{code,figma}/`. To surface, either invent no cemTag OR retarget the approved parent (m3e-tab/m3e-dialog) — not done (would un-approve primaries).
- Plugin ALIVE on channel **cem-7ed786** (build .8-drop-guard, M3 Design Kit); relay `bun extract/relay/socket.ts` running.

**⭐ appendSets 2nd-SET MECHANISM COMPLETE + 11 BANKED (2026-07-19 late).** The deferred "2nd-set" path (append a Figma set to an ALREADY-CONFIRMED cemTag) now FULLY WORKS; 11 bindings banked on local main. 3 commits: `76a8e83` (merge parking fix), `d470cfe` (visual-sampler fix), `23deb7e` (the bank). Banked: **m3e-button +4 toggle** (filled/elevated/outlined/tonal), **m3e-icon-button +4 toggle**, **m3e-fab +Extended FAB**, **m3e-tab +2 primary content** (icon-only, label-only). Component count still 43; these add SET-bindings (~45→56). All 11 AF-07-verified (rendered the EMITTED example via render-batch, eyeballed each PNG — every variant distinct + faithful); `match` byte-stable (285-line additive diff, 0 deletions → 43 primary banks byte-identical); `check` 0-drift/0-orphan; full suite 670/671 (the 1 = AF-03 publish-check flake, passes 43/43 isolated).

Two fixes completed the mechanism — **the parking wall was the real blocker** (all 4 targets are status:confirmed/provenance:human → `mergeCorrespondence` parks any figmaSets change in `proposedUpdate`, so appended sets never reached live figmaSets/emit):
1. **`applyManualToExisting(existing, manual)`** in `src/correspond/merge.mjs` — mirrors manual-correspondence onto the `existing` merge input too (idempotent, confirmed-safe, never throws), so a manual set on a confirmed entry is applied to BOTH merge inputs → lands live, not parked. Byte-stable because proposed==existing once live. `applyManualCorrespondence` (proposed side) UNCHANGED → its 19 tests stay green. Shared `toAppendedFigmaSet` helper for byte-identical key order.
2. **`axisGridSets(entry)`** in `src/visual/sample.mjs` — excludes representative-example 2nd-sets (inline `example`/`slugSuffix`) from sampleDefault/sampleAudit (they're not axis-grid variants; driving a toggle set through button's Type×Size grid resolves no variant → driveState threw). Button sample stays 10 default / 50 audit.

GOTCHAS this session: (a) **`slugSuffix` REPLACES the slug** (not appends) — commit ce1f33c; so `slugSuffix:"toggle-filled"` → `m3e-button-toggle-filled`. (b) The #531 "boolean bound to a plain attribute" test was a RED HERRING — its real breakage was a trailing `buttonEntry length===5` assert (buttonEntry is DERIVED from real correspondence, not a hardcoded synthetic). (c) button's shape is hardcoded across ~8 test files (sample/drive/audit, html-label, elm-emitter, emitter-api, correspond A8, smoke file-list+manifest) — the "trap"; all updated. (d) toggle/selected/variant are real m3e-button CEM attrs (emit renders them; html-label:806 only filters figma-axis-pin keys like Style). (e) the profile's figma export is `research/figma-dumps/figma-export.m3-kit.json` (NOT test/fixtures). (f) AF-03 publish-check flake is REAL/pre-existing (confirmed passes isolated 3×).

**🔶 OPEN DECISION for Jack (per his "never claim a ceiling" standing correction — FLAGGED, not silently dropped):** the 2 "Secondary tabs" sets (icon+label, label-only) are NOT banked. Evidence: m3e-tab CEM has attrs [disabled, for, selected] + slots [(default), icon] — NO primary/secondary affordance (secondary is an m3e-tabs container-layout concern). So a secondary tab binds to `<m3e-tab>` markup IDENTICAL to primary → content-faithful but style-unfaithful. By CORRECTNESS-first I parked them as a library gap; but they're bankable-as-redundant (2 files, same content as the primary variants) in ~5 min if Jack prefers completeness. Awaiting his call. The goldmine's other ~13 2nd-sets (nav-bar-vertical, list dialogs, list-item density/swipe, menu-baseline/vibrant, carousel, 2nd datepicker/search modes) remain open — the mechanism now handles them all.

Plan doc: `plans/2026-07-19-appendsets-bank-execution.md`. Mechanism design: `plans/2026-07-19-append-sets-mechanism-design.md`.

**⚙️ AUTONOMY MANDATE (Jack, 2026-07-18 — persist across EVERY compaction):** work AUTONOMOUSLY on cem-figma-connect
banking; proceed with as much as possible WITHOUT stopping unless absolutely needed; if genuinely BLOCKED (e.g. need a
live Figma channel/reload, or a real design decision), PING Jack rather than spin. Priorities in order: **CORRECTNESS
(faithful binds only — AF-07 eyeball, never trust a ratio) → COMPLETENESS → MAX COVERAGE** (bank as many real
components as render faithfully). Don't over-ask; make sensible calls and keep moving. Current push: bank the 8
contains-tier matches (blocked on faithful RENDERING — content injection for containers, style-match for avatar, live
capture for degenerate/hidden ones).

**⭐ REPRESENTATIVE-EXAMPLE EMISSION + MAX-COVERAGE SWEEP (2026-07-19, AF-17) — BANKED 12→28.** Jack approved the
composite-banking policy ("bank with a representative example; the BINDING is Code Connect's value, not showcase-pixel-
repro"). Shipped `profiles/m3-kit/examples.json` (`cemTag → {children: ChildSpec[]}`) + `src/emit/example-content.mjs`
(`renderChildrenHtml` / `validateExamples`) + both emitters inject the children when a cemTag has an entry (else
byte-identical). Banked via `gate:"example-verified"` (distinct from pixel `gate:"approved"` — provenance stays honest).
**Swept all 16 proposed** with `scripts/render-batch.mjs` (new tool: one browser/bundle over N markups + optional
post-mount `js` hook to force-open JS-shown overlays via `.show()`), AF-07-eyeballing each PNG. Banked this session (16):
fab, avatar, segmented-button, split-button, button-group, card, menu-item, nav-item, app-bar, list, toolbar, tabs,
dialog, menu, tooltip, rich-tooltip. Commits: 02f6e0b (card/menu-item/nav-item/app-bar #18–21), 1758fc6 (list/toolbar/
tabs/dialog #22–25), 32e7254 (menu/tooltip/rich-tooltip #26–28), e83216c (render-batch tool). All gates green: byte-stable
(21→25→28, existing banks byte-IDENTICAL), 0-drift, 611 tests modulo the AF-03 flake (#571 runCheck, passes 43/0 isolated).
**Two-path emit rule:** a real TEXT→content binding (tooltip "Supporting text") banks via STANDARD emit to PRESERVE it
(`<m3e-tooltip>${supporting}</m3e-tooltip>`); an examples.json entry would OVERRIDE + lose it. Unmapped/absent content →
examples.json children. **Walls:** 0-figmaSets = UNBANKABLE (icon/tab canonical-only — name matched, no Figma node to
bind); loading-indicator animation-frozen (harness disables motion). **DEFERRED (design-bearing, wants a plan):** circular/
linear-progress need per-set static root-attr injection (`value`/`indeterminate`) — an examples.json root-`attrs` extension
+ avatar-style unmapped-axis pin for EMISSION; rushing the determinate/indeterminate split risks an unsound bank.
**Still need a live channel:** slider, snackbar, fab-menu, bottom-sheet (+ loading-indicator).

**⭐ PROGRESS-INDICATOR INCREMENT (2026-07-19, AF-18) — BANKED 28→30, TRUE OFFLINE CEILING = 30.** Jack chose to build this
(design-bearing, "proceed" at current tier). New emit-time config `profiles/m3-kit/set-attrs.json` (`cemTag → setName →
{attr:value}`) injects per-set static attrs into the example ROOT (NOT the filename — `setSlugOf` reads fixedAttrs only, so
a representative `value` there would poison the filename `…-70`). Banked m3e-circular-progress-indicator #29 + m3e-linear-
progress-indicator #30 (each 2 sets). **Soundness core:** circular's 2 sets had EMPTY fixedAttrs (the matcher binds enum
qualifiers, but circular's state is an `indeterminate` BOOLEAN) → both would emit IDENTICAL code (avatar false-pass class);
fixed by distinct per-set attrs (determinate→value=70 render-faithful 70%; indeterminate→indeterminate=true/mode=indeterminate,
binding-correct but render frozen by the motion-disabled harness). **Web-components ONLY** — not in elm-facts, so the elm
emitter `return []`s (quiet skip); elm manifest stays 28, wc manifest 30. **Bug fixed (0682d3e):** `check.mjs
computeInMemoryEmit` threaded `examples` but not `setAttrs` → false drift (RECURRING — same as the examples.json check gap;
buildEmitContext's 2 callers hand-maintain the param list → Eddie: spread computeEmitEntries so new ctx fields flow to both).
Mechanism: set-attrs.json + validateSetAttrs + both emitters' root-attr merge (fail-loud on unknown setName) + check thread.
Commits: b3f3e8e/08dcbed/8a46779 (mechanism), 0682d3e (check fix), f96b8b3 (bank). 628 tests green modulo AF-03 flake #588
(passes 43/0 isolated). Design: `plans/2026-07-19-progress-set-attrs-design.md`.

**cem-figma-connect** (`~/Documents/code/cem-figma-connect`, on `main`, direct-to-main commits):
merges a CEM (@m3e/web manifest) with a Figma M3 kit export to generate Figma **Code Connect**,
gated by a **pixel-diff visual gate** (Playwright + @m3e/web render ↔ native-2x Figma export). Two
emit surfaces: web-components + **Elm**. THE map: `plans/plan/E-breadth-triage.md`. Frictions:
`plans/AUTONOMOUS-SESSION-FRICTIONS.md`. Live bridge was channel `cem-7e8c65` (needs the Figma-desktop
plugin running — a human step). Gallery for human review: `node /tmp/gen-gallery.mjs <repo>/render-cache/gate`
→ served over Tailscale (`python3 -m http.server 8099 --bind 100.91.86.46 --directory render-cache/gate`);
the review webapp is `src/visual/review/server.mjs` (failures-only, single-run).

**Build loop**: `gate.mjs --tag=<cemTag> --channel=<ch>` → add `{cemTag,status:"confirmed",gate:"approved",note}`
to `overrides.json` → `confirm → gap → emit`. FOUR tracer tests hard-code the confirmed set (grow each bank):
`test/correspond.test.mjs` (A8 CONFIRMED_TAGS + byte-stable re-match), `smoke.test.mjs`, `html-label.test.mjs`,
`emitter-api.test.mjs`.

**GATE-SOUNDNESS FIX (2026-07-14, user-caught — critical):** the diff FALSE-PASSED when a side was
blank/degenerate or sizes mismatched wildly — `normalizeScale` downscaled the larger image to the smaller's
width for ANY ratio≥1.5 (no upper bound), collapsing a 96×/688×/8.75× mismatch to a ~1px compare → ~0.
Fixed in `src/visual/diff.mjs`: `SCALE_NORMALIZE_MAX_RATIO=2.5` (ratio>2.5 diffs honestly) + a degenerate
guard (fully-transparent render OR <8px dimension, e.g. a 1×1 Figma export → `pass:false, diffRatio:1, reason`).
LESSON: 0.000 can be a FALSE pass; always eyeball code-vs-figma-vs-diff renders + check dimensions, not just
the ratio. The user's gallery review caught 3 false banks.

**SP1 — COMPREHENSIVE FIGMA CAPTURE — ACCEPTANCE MET (2026-07-15; all 7 tasks + live run; 566 tests green):**
LIVE OUTCOME: definition-first captures → **all 12 banked re-gate PASS OFFLINE** (icon-button 0.705→0.0008,
search-bar 0.124→0.0068, list-item 0.150→0.0777, badge 0.285→0.0547, button→0.095; others already clean). The gate
now needs NO live bridge for captured variants. Full sweep DONE: **144/171 sets, 3,575 renders, ~36MB** (30MB PNGs +
6.1MB contentTree-heavy sidecar). **D3 = GITIGNORE** (user chose): captures kept LOCAL, not committed — gate uses them
where present, falls back to live export on fresh clone/CI; `.gitignore` has `profiles/*/captures/` + `figma-captures.json`.
27 sets skipped, 144/171 captured. **100%-COVERAGE ATTEMPT (2026-07-17..18) — CLOSED, fill-container capture blocked by
a Figma render limit (Jack: accept).** Root cause took FOUR wrong guesses before the truth (AF-11/13/14): NOT dump
staleness (a fresh re-extraction gave an IDENTICAL 171-set list — `capture` reads the set-list from the dump but renders
LIVE, so a same-structure refresh changes nothing), NOT payload size (chunked `limit=1` still stalls), NOT asset-I/O.
TRUTH: fill-container components (snackbar + the 27 density/showcase scaffolding holdouts) stall SYNCHRONOUSLY in the
temp-frame render path (`createInstance`/resize/export) — a `limit=1` on an idle, build-verified plugin doesn't return,
AND a `setTimeout` guard never fires (thread blocked) → one stall WEDGES the plugin until reload. The 144 fast sets all
took the DEFINITION path; only the temp-frame (fill-container) path blocks. Snackbar (`53977:33575`) hits it too — NOT
the easy win predicted. DECISION: fill-container components use the gate's LIVE-EXPORT fallback (already built), not
offline capture; snackbar stays unbanked-via-capture. Shipped + KEPT (sound): capture_set **pagination** (`.6`,
offset/limit/total + client merge), **ping echoes build** (`ping.build`; verify reload via ping BEFORE any capture —
a new WS channel does NOT prove a code reload, AF-12), export.mjs **180s var/style timeout + `--reuse-tokens-on-failure`**
(team-library variable service hangs on this kit). REMOVED: the ineffective `.7` per-variant guard → **`.8-drop-guard`**
(a JS timer can't bound a synchronous native block, AF-14). Dump refresh reverted (identical). **LESSON (hard):** `ping`
to confirm idle BEFORE every single live capture probe; NEVER fire a 2nd probe until the 1st returns — one sync block
wedges everything, and I contaminated the measurement TWICE by piling probes onto a wedged thread. **PIVOT (AF-10, user chose):** the design's
instance-FIRST render was WRONG — largest-placed-instance grabbed non-representative usages (icon-button default
came back 240×104 aspect-2.31 outlier vs true 96×96). Replaced with **definition-FIRST** (`renderNodeControlled`,
shared by capture_set + export_node_as_image): export the clean definition; only if degenerate (fill-container e.g.
snackbar) render a controlled off-canvas temp-frame instance. **Dropped the doc-instance search entirely** (removed
findRenderableInstance + the memoized instance-index) — which also dissolved the AF-09 perf problem at its source.
Plugin builds: `.3-capture-set → .4-capture-index → .5-definition-first → .6-capture-chunked → .7-per-variant-timeout`
(current source; `.7` NOT yet reload-verified live). The "218/674 capture errors = dump staleness" note here is
CORRECTED by AF-13 above — the sets exist live; the failures are the per-variant `exportAsync` stall on asset-heavy
scaffolding. Runner skip-and-continues (returns {captures,skipped}) + tolerates error-variants (no imageData). Tasks as landed:
Goal: capture EVERY variant's real render + boundsPx + content-tree ONCE into a committed sidecar so the gate
runs fully OFFLINE (no live bridge per gate) and fill-container/bounds/blank cases are fixed BY CONSTRUCTION.
Spec `plans/2026-07-15-comprehensive-figma-capture-design.md`; plan `...-plan.md` (7 TDD tasks). Landed:
- **T1** `src/capture/captures.mjs` — pure sidecar helpers (emptyCaptures/upsertSetCaptures/resolveCaptureByVariant/load/save).
- **T2** `extract/capture.mjs` — `runCapture({...})` runner: writes PNGs to `<rendersRoot>/<setId>/<variantId>.png`,
  incremental resumable sidecar flush, strips imageData; `bridgeCaptureSet(channel,scale)`.
- **T3** `src/cli.mjs` `capture` subcommand (`--channel/--scale/--only/--force`).
- **T4** `extract/plugin/code.js` `capture_set` cmd — `renderNodeControlled` DEFINITION-FIRST (def → if degenerate,
  controlled temp-frame instance at fixed width, `try/finally` cleanup, pre-sweeps `__cem-capture-temp__`) + boundsPx
  (PNG IHDR) + `serializeContentTree`. NO doc-instance search. `PLUGIN_BUILD="a3-generalized-extract.5-definition-first"`. ES2019-clean.
- **T5** `src/visual/gate.mjs` `resolveFigmaRender(captures,variantNodeId)` — uses captured PNG offline when resolved,
  live `exportFigmaNode` byte-identical fallback when absent.
- **T6** `src/visual/{drive,harness/page}.mjs` — captured `boundsPx` threads driveState→`toHarnessUrlParams`
  (`boundsPx.w`/`.h`)→page.mjs sizes el to boundsPx÷2 (deviceScaleFactor 2) as PRIMARY; the hand-tuned per-tag
  blocks (shape 320/search-bar 360/list-item 239/**bottom-sheet 434**) are FALLBACK behind one `hasBounds` boolean.
  ZERO behavior change when no boundsPx (current state) → the 12 banked gate identically today.
- **T7 (LIVE, DONE for acceptance):** `node src/cli.mjs capture --profile m3-kit --channel=<ch> --scale=2 [--force] [--only=<ids>]`
  over the WS bridge (NO token — bridge, not REST; plugin must be reloaded each run → new channel). Re-gate loop:
  `for t in <12 tags>; do node src/visual/gate.mjs --tag=$t --channel=<ch>; done` → all 12 PASS offline. Capture is
  resumable (per-set sidecar flush) + skip-tolerant. Remaining: finish/curate the full sweep + commit the capture per D3.
The fill-container snackbar (1×1 standalone) + bounds/blank cases below are now handled by definition-first + captured
renders, SUPERSEDING the "harness sizing/content pass NOT executed" notes further down.

**BANKED = 28 as of 2026-07-19** (see the ⭐ REPRESENTATIVE-EXAMPLE block up top for the +16). The 14 pixel-gated banks below are the original core; the other 14 are `gate:"example-verified"` composites. **Original 14 (pixel-gated):** button, icon-button, badge, switch, filter-chip,
input-chip, suggestion-chip, assist-chip, checkbox, **search-bar** (literalIcon/input emit; 0.0068),
**list-item** (text-tier + harness content; 0.0777), **shape** (35 variants; scale-invariant compare;
repointed to real Shape Set; 0.0033), **fab** (#13, 2026-07-18, `benignAaTags` tier 0.0985<0.10 — curved-shape +
icon-glyph AA, offline; a440e01), **avatar** (#14, 2026-07-18, contains-tier match; 0.0000 via `fixedAttrs:{Style:
"Monogram"}` pinning the unmapped Style axis to the monogram Figma variant — code Letter="A" is a monogram; commits
abd0ef5 gate-fix + 70c56b9 bank). **GATE FIX (abd0ef5):** `fixedAttrs` now pins an UNMAPPED Figma axis's variant for
gating (fixes a FALSE-PASS class — unmapped distinguishing axis → gate compares code vs a variant it can't represent,
low ratio hides it). Emitter dual-semantics: fusion fixedAttrs keys = CODE attr names; axis-pin keys = FIGMA axis names
(emitters now filter figmaAxisNames). **OFFLINE CEILING = 14 (AF-16):** all other offline-gateable proposed are
containers (card 0.96 full-showcase; button-group/dialog/app-bar render BLANK→near-degenerate false-lows) or composites
(segmented/split/fab-menu diverge ~0.4) — need CONTENT the harness can't faithfully repro. **NEEDS LIVE CAPTURE:**
tooltip, circular/linear-progress, slider (0 good captures — thin/hidden). **OPEN POLICY Q (Jack):** bank rich
composites with a representative example vs pixel-gate-the-showcase (weakens AF-07 discipline). **NOT published** (needs an
org/enterprise Figma PAT; personal = 403 Write; file `UtwpUdPiOZEuxp8Nq1d5yQ`). Emitter handles: text→content,
boolean→slot, defaultSlotIcon, visibilityAxis conditional icon, literalIcon→slot, text→input-slot, multi-boolean
axis; elm.mjs canon has a digit-name "value"-prefix fallback (shapes like 4-sided-cookie). Gate has: tiered
threshold, degenerate guard + ratio cap (soundness), scale-invariant compare (`scaleInvariantTags`), text-tier
(`textTierTags`), **benignAa tier** (`benignAaTags` — non-text icon/shape AA at 0.10, e.g. fab).

**MATCHER GAP FIXED — "contains" tier SHIPPED (2026-07-18, AF-15):** answering "only 13?" — CEM has 121 elems but ~94
are primitives/sub-parts; the real gap was a MATCHER miss, not a ceiling (Jack caught my wrong "no match exists" claim;
the components were in the dump — the matcher dropped descriptive-QUALIFIER-prefixed sets `Generic avatar`/`Stacked card`/
`Connected button group`/`Circular-determinate…` because slugify doesn't strip qualifiers → exact-miss + fuzzy 0.42<0.5).
Built a **contains tier** (`src/match/qualifier.mjs` + normalize token helpers + matcher wiring; brainstorm→spec `plans/
2026-07-18-qualifier-aware-matcher-design.md`→plan→subagent-driven, 8 commits, reviewed+APPROVED+fix-pass): token-subset
(longest-CEM-wins) head-noun match, qualifier→fixed-attr via existing valueMatch + fusion leftover, or gap when
unresolvable. **10 new `tier:contains` PROPOSED entries**: avatar, tooltip, card (orientation), button-group (variant),
circular/linear-progress (indeterminate), dialog+slider (canonical), + menu-item/nav-item (sub-parts). radio is a gap
(`radio-button`⊇`button` ordinal tie → button, safe). 13 confirmed + emit BYTE-IDENTICAL; byte-stable re-match holds;
594 tests green (1 pre-existing flaky publish-check #554 = AF-03 render-cache test-isolation race, NOT a regression —
`check` reports 0 drift). **NEXT (follow-on): BANK the ~8 new real components** — each: `gate.mjs --tag=<t>` (OFFLINE,
sets already captured) → if pass + human eyeball → overrides.json + confirm→gap→emit + update the 4 tracer tests (like fab).
Start with the clean singles (avatar/tooltip) + attr-fused (card/button-group/progress). The OTHER 4 earlier-"proposed"
were MIS-matches (tabs→Radio buttons etc.) — separate matcher concern. (B) **composite fidelity** — the
only offline-gateable proposed remainders (fab-menu, segmented-button, split-button) are COMPOSITES that RENDER with
harness content injection but have real code-vs-Figma layout DIVERGENCE (segmented-button stuck 0.39–0.44 across
no-pin/width-pin/both-dims-pin/equal-width-flex — the m3e component distributes segments differently than the design;
NOT a sizing fix). Composites = the Q2-skip category; uncertain payoff. Content-injection pass CONCLUDED: proved
injection makes them render, but banking composites needs deep fidelity work (possibly unachievable if code≠design).
Recommend lever A (matcher gaps) next. `m3e-button-segment`/`m3e-split-button`(leading/trailing-button slots)/
`m3e-fab-menu` child tags noted for any future composite attempt.

**REMAINING (not banked):**
- **fab** (~0.40): size+color right; the ICON renders small/mispositioned inside the fab (code icon
  offset/clipped vs Figma centered), + a Size=Default intrinsic-size question (user: "select a smaller size").
  Needs icon-render investigation.
- **bottom-sheet** (~0.64): sized to 868×1004 + content, but the interior is a content-shell mismatch → defer.
- **snackbar**: Figma FILL-CONTAINER → 1×1 export standalone → needs instance-node export (plugin change) → defer.
- SKIPPED per Q2: rich-tooltip, app-bar, toolbar, 6 composites.

**UNBANKED false passes (2026-07-14) + root causes + remaining work:**
- **shape**: matcher grabbed the WRONG node — internal leading-dot `.Shape` (corner-radius token util, exports
  1×1) instead of the real **Shape Set** `58548:7248` (35 visual shapes). FIXED the repoint (35 `Shape→name`
  variants) + matcher now de-prioritizes leading-dot internal COMPONENT_SETs from the exact tier + harness fills
  (`--m3e-shape-container-color`) + sizes (380px) m3e-shape. Renders correctly now; **0.22 edge residual = size/
  padding** (Figma shapes have whitespace padding; code shape insets ~5%). Tune the box size / trim figma padding → then bankable.
- **snackbar**: Figma component uses FILL-CONTAINER width → exports **1×1 blank** standalone. Variations won't help
  (all share it). Needs an **instance-node export** (target a placed instance with real bounds, not the component
  def) — a plugin/schema change — or defer.
- **list-item**: Figma fine (560×160); code renders **blank** (no content). Needs **content injection** (headline
  "Label text" + supporting + overline + leading icon, per the Figma default). Text-tier (0.10).

**Also failing (never banked), per user review — all harness sizing/padding vs Figma node bounds:**
- **bottom-sheet**: renders collapsed (no explicit height) → set explicit W/H (figma ~960×1588).
- **search-bar**: code 556px vs figma 720px → set explicit width. (Icons are correct: menu-leading/search-trailing.)
- **fab**: 0.48 — Figma fab has intrinsic padding for the shadow/elevation; code renders tighter → pad code or trim
  figma's shadow padding.
The harness sizing/content pass (list-item/bottom-sheet/search-bar/shape/fab) is fully specified but NOT executed
(subagent session limit hit 2026-07-14). All are page.mjs (per-tag element sizing/content) + measure-before-size.

**Capabilities built + committed this session** (~21 commits): RC2 default-slot icon; driver standalone path +
null→omit-attr + `displayNameOf` `#` fix; chip Configuration→slot-visibility (general `visibilityAxis` + conditional-
getEnum emit); **tiered gate threshold** (`isTextBearing`=has kind:text prop → 0.10, else 0.02); popover/open **reveal**
harness; **multi-boolean axis** (checkbox); literal-icon + input-slot; matcher leading-dot hygiene; **gate soundness fix**.

**User decisions (2026-07-14):** assist-chip icon OMIT; checkbox = codegen multi-attr (no manual); "no synthetic"=no fake
*components* (example content OK); tiered threshold; SKIP app-bar/toolbar/rich-tooltip + composites (baked Figma content
not in dump). **Gotchas:** `pnpm test` (scoped glob); render-cache footgun closed (gate writes `render-cache/gate/<runId>/`).

Related: [[elm-m3e-docs-barrel-conversion]].
