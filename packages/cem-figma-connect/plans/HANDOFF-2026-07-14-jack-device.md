> ⚠️ **HISTORICAL SNAPSHOT (2026-07-14, session 2) — do not treat as current.** For the
> current state read [`../STATUS.md`](../STATUS.md). Work has continued past this snapshot.
> Note: the "publish target `UtwpUdPiOZEuxp8Nq1d5yQ` … (settled)" claim below **conflicts**
> with the plans, which name `KujuFlfJSwHI6ua1b7RZvL` — the canonical `--file-key` is an
> open owner decision (see `STATUS.md`), not settled. References to `.superpowers/…` are
> gitignored working notes **absent on a fresh clone**.

# Handoff — cem-figma-connect (2026-07-14, session 2, `jack` device)

Continues `plans/HANDOFF-2026-07-14.md` (authored on the `jhp` device). This
session ran on a **second machine** (`/Users/jack`), which is why the toolchain
needed fresh setup **and** why the publish is blocked here — see "Blocked".

**Full suite: 445/445.** All changes below are LOCAL (uncommitted on `main`)
unless a commit lands them.

## What this session did

1. **Brought the pipeline up on the `jack` device.** Installed `bun 1.3.14`
   (homebrew) for the relay; `playwright install chromium`; relay + plugin
   bridge live; `pnpm render:selfcheck` green (button + switch 3/3 stable).

2. **Item 1 — RC1 pixel-proven.** Reconstructed the single-component visual-gate
   **orchestrator** as `src/visual/gate.mjs` (NEW) from the committed, tested
   pieces (`drive`→`capture`→bridge `export_node_as_image`→`diff`→`status`) — the
   prior orchestrator lived only in gitignored `.superpowers` scratch. Ran the
   `m3e-switch` gate: **both states `diffRatio 0.0000`, exact-tier nodes.** RC1's
   boolean-axis fix (`Selected→checked`, present/absent) is now empirically
   pixel-proven — the one open verification item from the prior handoff.
   *Bonus:* these are the first genuine code-vs-Figma matched pairs, so they also
   discharge `diff.mjs`'s header caveat that `maxDiffRatio: 0.02` had only ever
   been proxy-calibrated.

3. **Emit-icon fix (approach A) — DONE, tested, CC-parser-validated.**
   `src/emit/html-label.mjs` `buildSlotBooleanBlock` now resolves a mapped
   INSTANCE_SWAP glyph via `instance.getEnum("Icon", { <figmaName>: 'name="<sym>"[ filled]', … })`
   (deduped by `figmaName` → 123 rows from the 141-row iconTable; **fail-loud on
   a *conflicting* dup**), rendered as a **bare attribute-position** `${glyph}` in
   `<m3e-icon slot="icon" ${glyph}>` (parent owns the slotted tag). A
   `getPropertyValue` fallback remains for profiles with no iconTable.
   - Threaded the iconTable through **both** regeneration paths: `run.mjs`
     (`computeEmitEntries`→`runEmit`→`buildEmitContext`) **and**
     `check.mjs` (`computeInMemoryEmit`) — the second one is easy to miss and is
     what makes `check` drift-clean.
   - `generated/m3-kit/**` regenerated; +3 tests in `test/html-label.test.mjs`
     (approach-A getEnum, dedup, conflicting-dup guard).
   - **Validated read-only by CC itself:** `npx figma connect publish --dry-run
     -f generated/m3-kit/web-components/*.figma.ts generated/m3-kit/elm/*.figma.ts`
     → `All Code Connect files are valid`. So the bare attribute-position
     `${glyph}` — the one live-unknown the prior handoff flagged — **parses.**

4. **Named-slot composition spike — CONCLUDED (see next section).**

5. **Item 4 (full re-extract) — environmentally blocked, non-blocking.** The
   bridge works (`get_document_info` + per-node `export_node_as_image` both fine),
   but `get_local_components` times out even at **5 min** on this 5770-component
   file. Likely Figma dynamic-page loading (the ported plugin doesn't
   `loadAllPagesAsync`) + sheer size. The committed 171-set dump stays
   authoritative; nothing downstream needs a fresh full enumeration.

## Named-slot composition — the verdict (verified against `@figma/code-connect@1.4.9`, not assumed)

The prior device concluded CC can't compose into a *named* slot. **That is
correct**, verified in source:

- Nested children render at a **content position** with no attribute injection:
  the `Slot` intrinsic resolves to `slot(name).connectedInstances.map(i =>
  i.__render__())` (`connect/intrinsics.js:401`); `figma.slot` is a bare alias of
  `figma.instance` (`html/external.js:6`).
- Duplicate attributes throw (`html/parser.js:117`) — no attr-merge.
- Templates may import **only** `figma` (`connect/raw_templates.js:63`) — no
  shared icon-map module.

**So the resolution is: the PARENT owns the slotted tag.** Two cases:

- **Icons** → the parent emits `<m3e-icon slot="…" ${glyph}>` and resolves the
  glyph via inline `getEnum` (approach A, shipped + CC-validated this session).
- **Prop-rich named-slot children** (app-bar leading = an `icon-button` with its
  own props) → `figma.nestedProps(layerName, { … })` (`intrinsics.js:204`) reads
  the nested child's props so the parent can fill its owned tag:
  `figma.connect(AppBar, url, { props: { leading: figma.nestedProps("Leading",
  { icon: figma.instance("Icon") }) }, example: p => html\`<m3e-app-bar>
  <m3e-icon-button slot="leading">${p.leading.icon}</m3e-icon-button></m3e-app-bar>\` })`.

**Fear quelled: Figma CC *can* compose named slots.** The one real consequence:
`nestedProps` is a **declarative-API** intrinsic (`figma.connect({props,
example})`), whereas the current emitter emits the **template style**
(`figma.code` + `instance.getEnum`). **Composites therefore need a new
declarative emit mode.** Tractable; not a wall. (Default-slot composites —
list←list-item, tabs←tab — need no slot attr and can nest as-is.)

## BLOCKED on this device → resume on an org/enterprise account

**Publish + `get_code_connect_map` verify cannot run here.** The `jack` device's
Figma account (`jackhp95@gmail.com`, personal) has **File Read (200)** but the
**Code Connect *Write* scope is rejected (403)** — Code Connect publishing
requires a Figma **Organization/Enterprise** plan (Dev Mode). The prior handoff's
successful publishes (2026-07-10, the 07-11 incident) ran under an entitled
account.

**Resume checklist (entitled device/account):**
1. Pull this branch.
2. Generate a PAT on an **org/enterprise** account with **File content: Read +
   Code Connect: Write**; drop at `~/.figma-cc-token` (consume only as
   `FIGMA_ACCESS_TOKEN=$(cat ~/.figma-cc-token)`; revoke after).
3. `FIGMA_ACCESS_TOKEN=$(cat ~/.figma-cc-token) node src/cli.mjs publish
   --profile m3-kit --file-key UtwpUdPiOZEuxp8Nq1d5yQ` (both labels; button gate
   is `approved`, files pre-validated → should upload).
4. `get_code_connect_map` on `UtwpUdPiOZEuxp8Nq1d5yQ` to confirm the live binding
   and that `getEnum`'s key equals the swap instance's `figmaName` (the last
   runtime unknown; offline step-1 already confirmed the swap targets ARE
   iconTable nodes).

## Changeset (uncommitted on `main`)

Modified: `src/emit/html-label.mjs`, `src/emit/run.mjs`, `src/emit/emitter-api.mjs`,
`src/publish/check.mjs`, `test/html-label.test.mjs`,
`generated/m3-kit/web-components/m3e-button-*.figma.ts` (×5, regenerated).
New: `src/visual/gate.mjs`.

## Atoms-up plan (deltas on `plans/plan/E-breadth-triage.md`)

`E-breadth-triage.md` remains THE landscape (25 matched, RC1–RC6, sequencing).
This session's updates to it:

- **Cross-cutting #1 (emit-side icon) — DONE** (approach A, above). Unblocks every
  publish once an entitled token is available.
- **NEW cross-cutting: declarative emit mode.** Named-slot *composites* (app-bar,
  and any molecule slotting a prop-rich child) need the emitter to emit
  `figma.connect({props: {… figma.nestedProps …}, example})` instead of the
  template style. Scope this before app-bar. Default-slot composites don't need it.
- **Sequencing (unchanged intent):** atoms first — `badge` → `icon-button` (RC2,
  Icon swap → default slot, clean) → chip family → driver/data fixes (fab,
  snackbar, rich-tooltip) → composites (atoms-up, declarative mode for named
  slots) → RC5 harness gaps.
- **Build mechanics (per the user's model):** fan out lesser-powered subagents in
  isolated worktrees, one unit per node in the dependency graph, each gated
  through review before merge to `main`; the gate (`src/visual/gate.mjs
  --tag=<cemTag> --channel=<cem-xxxx>`) is the per-unit verification.

## Gotchas carried forward
- `rm -rf render-cache/results` before `pnpm test` (status/publish-check tests
  read the latest run's jsonl). The gate writes there.
- Run tests via `pnpm test` (scoped glob), not bare `node --test`.
- `src/visual/gate.mjs` is thin glue over tested modules; it hits the live bridge
  for the export side, so it's exercised by a real run, not a unit test.

## Session-2 continuation (after commit 3ce25ef)

### ✅ RESOLVED (commit e4bcd2d): elm-facts extractor now captures every setter
Was: `elm-facts.build.mjs` built `setters` from the `enums` section ONLY,
silently dropping every `Bool`/`String` setter across all components (switch had
only `icons`; checkbox/list-item had none). elm-m3e was correct
(`M3e.Switch.checked : Bool -> Attr`); the extractor was lossy. **Fixed:**
(a) `build.mjs` now also captures the `"attr"`-prefixed pairs from `Facts.elm`'s
`attrRewrites` as setters (verified exposed by the component's own module; `"on*"`
pairs are events, skipped); (b) `elm.mjs` emits a boolean axis (RC1, e.g. switch
`Selected→checked`) as an Elm `Bool` (`M3e.Switch.checked True`), not via
`resolveToken`; (c) `elm-facts.json` regenerated at the pinned elm-m3e `@93d2edc`
(setter additions only — no version bump; note local elm-m3e is on `main`
@`f1c7beb`, a *diverged* line, so re-pinning is a deliberate separate decision).
Verified end-to-end: switch Elm emits `M3e.Switch.checked ${checked}` with
`getEnum {True:"True", False:"False"}`. 445/445. **The Elm side is now
unblocked** — components can be banked on both surfaces. Coverage note: the
`elm.mjs` boolean branch is proven by a real switch emit but not yet by a
committed unit test; banking a boolean-axis component (switch / bottom-sheet /
filter-chip) will cover it.

### Per-component build loop (verified this session)
Take a gate-passing component to publish-ready: gate it
(`node src/visual/gate.mjs --tag=<cemTag> --channel=<cem-xxxx>`), then add it to
`overrides.json` (`{cemTag, status:"confirmed", gate:"approved", note}`) →
`node src/cli.mjs confirm --profile m3-kit` (applies overrides → correspondence.json
via `confirmFromDecisions`; NOT `match`) → `gap` → `emit`. Three tracer tests
HARDCODE the confirmed set and must grow with each confirm:
`test/correspond.test.mjs` (A8 "only button confirmed"), `test/smoke.test.mjs`
(emit file list/count), `test/html-label.test.mjs` (`emitConfirmed` every-cemTag).

### Gate landscape verified on the jack device (RC1 + emit-icon in place)
Gate-PASS, ready to confirm once elm-facts is fixed: `m3e-list-item` 0.006,
`m3e-shape` 0.000, `m3e-switch` 0.000/0.000 (RC1 on+off). `m3e-button` already
confirmed. The other ~20 still need their `E-breadth-triage.md` RC fixes.

### gate.mjs isolation fix (committed with this note)
`gate.mjs` now writes each run under `render-cache/gate/<runId>/` (code/figma/
results isolated) so batch-gating can't cross-contaminate `status()`'s latest-run
read, and the shared `render-cache/results/` the test suite reads is never touched
by a gate run.
