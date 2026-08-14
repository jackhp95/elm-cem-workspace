# Spec — elm-m3e publishable packages (Move 2), anchored on latest remote mains

Status: **APPROVED shape (D-037), execution pending.** Author: Gauntlet manager (`claude-opus-4-8`),
2026-08-14 (rewritten — the first draft inverted the "barrel" intent and built on stale snapshots).
Decision record: ledger **D-037** (supersedes D-031c flat-canonical, D-035 byte-cut, D-036).

## 1. The correction that reframes everything

The workspace was integrated from **stale snapshots** (elm-cem `e0e4f1c`, elm-m3e `0cd7f486`). The
**latest remote mains** (elm-cem `ad5d523`, elm-m3e `e1bde03`) already implement the target:
concern-separated codegen emit (`M3e.Component.<X>` + `M3e.Build.<X>` as separate modules), the
builder forge relocated to core (`M3e.Build.Internal → M3e.Forge.Internal`, which broke the old
components↔builder cycle), the `elm-m3e-icons` package (typed Material Symbols), `M3e.Coerce`
removed, and a working `packages.json` + `split.js` (`exposeInternal`) + `check-split.mjs`.

The human's anchor: **"the current remote main basically has the shapes I want."** So we do NOT
rebuild from the snapshots; we **update the workspace to the latest mains** and adopt their shapes.

## 2. The three API layers (human's definition)

- **html api** = every EXPOSED module NOT under the `Build/` or `Component/` folders: `M3e` (the
  strong general surface — KEPT), `M3e.Html`, `M3e.Attributes`, `M3e.Values`, `M3e.Events`,
  `M3e.Kind`, `M3e.Unsafe`, `M3e.Action`, `M3e.Forge.Internal`. Stronger types than raw elm/html,
  looser than per-component (a shared `value` can't be as narrow as `M3e.Component.Slider.value`).
- **component api** = `M3e/Component/*` — the strictest per-component required-record surface.
- **builder api** = `M3e/Build/*` — the per-component phantom builders.

(Note: "barrel is dead" meant retire the *word* and its throwaway-re-export assumptions. The strong
`M3e` module is a first-class part of the html api and is KEPT — this reverses the first draft.)

## 3. Final package shape (main + one refinement + renames)

= latest main's `packages.json`, with the human's refinement "split `Build/*` into its own package"
and the renames core→html, review-facts→facts:

| Package | exposes | depends on |
|---|---|---|
| `jackhp95/elm-m3e-html` | `M3e.Html`, `M3e.Attributes`, `M3e.Values`, `M3e.Events`, `M3e.Kind`, `M3e.Unsafe(.Attributes)`, `M3e.Action`, `M3e.Forge.Internal` (exposeInternal) | IR |
| `jackhp95/elm-m3e-components` | `M3e` (barrel) + `M3e.Component.*` + `M3e.Internal.Types.*` | html |
| `jackhp95/elm-m3e-builder` | `M3e.Build.*` | components, html |
| `jackhp95/elm-m3e-icons` | `M3e.Icon` | html / IR |
| `jackhp95/elm-m3e-facts` | `M3e.Review.Facts` | `elm-cem-facts` |

**DAG (verified on latest main):** `builder → components → html`, `icons → html`,
`facts → elm-cem-facts` — acyclic (`Component.* → Build.*` = 0; barrel/`Internal.Types.*` never
import `Build.*`; the forge lives in html). **Byte feasibility (proxy, 402 tree):** html ~213 KB
(28%), components ~433 KB (56%), builder ~592 KB (77%) — all under the 768 KB cap and 700 KB soft
gate; facts tiny; icons TBD (measure once the icons package is in-workspace).

`elm-m3e-facts` is m3e's own facts contract; the generic `jackhp95/elm-cem-facts` is archived /
renamed separately (human).

## 4. Execution plan (gauntlet parts; DO NOT PUBLISH)

The hard part is no longer a generator change (done upstream) — it is a **re-integration** of the
newer mains into the monorepo, then repackaging. Each part lands with `gate-all` green + revertible.

1. **Update `packages/elm-cem` to elm-cem `origin/main`.** New codegen/bin/gates. Reconcile the
   workspace's elm-cem gates (neutrality, registry-check, acid). The copy-fidelity snapshot reference
   for elm-cem moves forward to `ad5d523`.
2. **Update `packages/elm-m3e` to elm-m3e `origin/main`.** Concern-separated `src/`, the icons
   package, `packages.json`, `check-split.mjs`, docs changes. **Face A re-baselines** from 143 flat
   files to the concern-separated file set (a recorded change to what the A/B harness pins, not a
   weakening — pristine vs workspace elm-cem, same config, must stay byte-identical). Snapshot
   reference moves to `e1bde03`.
3. **Reconcile the facts bundle + 3 consumers.** The bundle (Face B/C) and cem-figma-connect /
   m3e-okf / tailwind read facts, not Elm modules — verify `check-drift` + provenance stay green
   against the newer producer. Repoint anything that assumed the old shape; migrate no tests away.
4. **Repackage to the 5-package split.** Take main's `packages.json`; split `Build.*` into
   `elm-m3e-builder`; rename core→html, review-facts→facts. Run `elm-cem split` (totality /
   disjointness / DAG-respect) + a per-package standalone-compile + size gate (`elm-cem validate`);
   prove each package compiles standalone and is under cap. `elm-m3e-facts` naming + `elm-cem-facts`
   retirement handled here.
5. **Icons** — verify the in-workspace `elm-m3e-icons` package compiles + measure its `docs.json`;
   fix if over cap. (Only greenfield-ish piece; the API already exists upstream.)

`node tools/gate-all.mjs` green after each part (manager runs it, ~350 s). **Stop and report at the
publish boundary** — no `elm publish`, no tags, no registry push.

## 5. Risks / open items

- **Re-integration blast radius (biggest).** Updating two core packages to newer mains will break
  workspace gates that assumed the old snapshots (Face A count, copy-fidelity SHAs, facts bundle,
  consumer provenance). Part 1–3 exist to absorb this incrementally; measure the blast radius first
  (bring the mains in, run `gate-all`, enumerate breaks) before committing a part.
- **Snapshot-reference model.** The inert read-only snapshots under `/Users/jhp/code/jackhp95/` are
  the copy-fidelity baseline. Moving to newer mains means the baseline reference advances; the
  snapshot dirs themselves stay read-only — copy-fidelity compares the workspace copy against a
  fresh checkout of the new main SHA (via `SNAPSHOT_ROOT` / a pinned ref), not the old snapshot.
- **Icons `docs.json` size** — a large Material Symbols name type could be sizable; measure.
- **`elm-cem-facts` retirement** coordination — elm-review-cem depends on it; renaming ripples.
