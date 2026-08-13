# Progress-indicator banking via per-set example attributes — Design + Plan

**Status:** approved-to-proceed (Jack 2026-07-19, "proceed" at current tier). Design-bearing but a bounded extension of the representative-example mechanism. Autonomy mandate applies: correctness → completeness → coverage.

**Goal:** Bank `m3e-circular-progress-indicator` + `m3e-linear-progress-indicator` (each 2 figma sets: determinate/indeterminate) by giving each SET a correct, render-faithful-where-possible representative example. Grows banked **28 → 30** (+4 emitted files).

---

## Findings (empirical recon, 2026-07-19)

1. **Linear is already sound.** Its correspondence has matcher-derived `fixedAttrs: {mode:"determinate"}` / `{mode:"indeterminate"}` (the CEM `mode` enum's values matched the qualifiers). The 2 sets already emit DISTINCT examples + clean filenames (`-determinate`/`-indeterminate`). It only lacks a representative `value` so the determinate example renders a visible bar instead of an empty track.

2. **Circular is NOT sound.** Both sets have `fixedAttrs: {}` (empty). The CEM distinguishes state with an `indeterminate` BOOLEAN (not a `mode` enum), and the contains-matcher's qualifier resolver only binds ENUM values, not boolean-named qualifiers (`qualifier.mjs:65–74`). So both sets would emit IDENTICAL `<m3e-circular-progress-indicator>` — the determinate and indeterminate Figma sets get the same code. **This is the soundness bug we must fix** (same class as the avatar false-pass: two distinct Figma things collapsing to one code binding).

3. **Indeterminate variants can't render faithfully offline.** They animate; the harness disables motion for determinism (`reducedMotion:reduce`, `animations:disabled`), so they freeze — circular to an ambiguous partial arc, linear to just the empty track. The DETERMINATE variants render faithfully with a `value` (verified: 60% arc, 60% bar). Since confirming a cemTag emits ALL its sets (card→2 files proves this), banking these components banks the indeterminate sets too. That is acceptable: the indeterminate BINDING is provably correct (`indeterminate` / `mode="indeterminate"` are the exact CEM attrs for that state), and the render limitation is a harness constraint (motion disabled), not a binding defect — the same situation as tooltip/menu being hidden-by-default (banked via force-render). Provenance stays honest via distinct notes.

4. **Filename coupling forbids the obvious fix.** `setSlugOf` (`html-label.mjs:113–130`) derives each file's name from its `fixedAttrs` VALUES. So putting a representative `value="70"` in fixedAttrs yields `…-70.figma.ts`, and circular's boolean would yield `…-true.figma.ts`. Representative/state attrs must therefore travel in a channel that feeds the EXAMPLE MARKUP but NOT the filename.

---

## Design — a per-set `set-attrs.json`, merged at EMIT time

A new profile config `profiles/m3-kit/set-attrs.json`, keyed `cemTag → setName → { attr: value }`, holding static attributes to inject into that set's emitted example root element. Emit-time (mirrors `examples.json` threading exactly), NOT match-time, for two reasons: (a) it must not feed `setSlugOf` (filenames stay clean — linear keeps `-determinate`/`-indeterminate` from its `mode` fixedAttr; circular falls back to its setName slug, distinct + consistent with the existing menu-item/nav-item precedent); (b) `correspondence.json` stays byte-stable under re-match (the A8 tracer holds trivially — `match` is untouched), and the 28 existing banks stay byte-identical (no set-attrs entries).

```json
{
  "m3e-circular-progress-indicator": {
    "Circular-determinate progress indicator":   { "value": "70" },
    "Circular-indeterminate progress indicator": { "indeterminate": "true" }
  },
  "m3e-linear-progress-indicator": {
    "Linear-determinate progress indicator":     { "value": "70" }
  }
}
```

- **circular determinate** → `<m3e-circular-progress-indicator value="70">` (faithful 70% arc).
- **circular indeterminate** → `<m3e-circular-progress-indicator indeterminate="true">` (correct binding; distinct from determinate → **soundness fixed**; render frozen, noted).
- **linear determinate** → `<m3e-linear-progress-indicator mode="determinate" value="70">` (faithful bar; `mode` from the existing fixedAttr, `value` from set-attrs).
- **linear indeterminate** → `<m3e-linear-progress-indicator mode="indeterminate">` (already correct; no set-attrs needed).

**Auditability:** the distinction for circular lives in the committed, explicit `set-attrs.json` + the DISTINCT emitted files. The design doc records why the boolean-qualifier gap is handled here rather than in the matcher (filename coupling + blast radius).

**Fail-loud (no silent-drop trap):** emit MUST error if a `set-attrs.json` entry names a `setName` that isn't one of the cemTag's figmaSets — otherwise a typo silently drops `indeterminate` and circular collapses back to unsound. A wrong `setName` is a build failure, not a no-op.

### Architecture / units
- **`profiles/m3-kit/set-attrs.json`** (new) — the per-set static attrs.
- **`src/emit/example-content.mjs`** (extend) — add `validateSetAttrs(setAttrs, cem)`: every cemTag is a real CEM tag; every attr is a real CEM attribute of that tag. (setName correctness is enforced fail-loud at emit.)
- **`src/correspond/merge.mjs`** `loadProfile` — load `set-attrs.json` (missing → `{}`), return on the profile (sibling to `examples`).
- **`src/emit/run.mjs` + `src/emit/emitter-api.mjs`** — thread `setAttrs` into the emit context (mirror `examples`).
- **`src/emit/html-label.mjs`** `emitEntry` — after building `attrParts` from `fixedAttrs`+axes, merge `ctx.setAttrs?.[cemTag]?.[figmaSet.setName]` into the root attrs (deterministic order; error if the setName is unknown to the entry; error/skip on a key already present in fixedAttrs). Does NOT touch `setSlugOf`.
- **`profiles/m3-kit/emitters/elm.mjs`** — mirror the same root-attr merge.

---

## Verification + banking (by-example, AF-07)

1. Build the mechanism (TDD). `match` → confirm byte-stable (`git diff correspondence.json` empty; 28 banks byte-identical).
2. Add circular + linear to `overrides.json` (`gate:"example-verified"`), `confirm → gap → emit` → 4 files.
3. **AF-07 re-render the ACTUAL emitted example markup for all 4** (via `render-batch.mjs`; linear wrapped in a width div): determinate arc/bar faithful at 70%; indeterminate frozen-but-structurally-a-progress-indicator. Eyeball each.
4. Bank both cemTags. Notes: determinate = "render-faithful representative value"; indeterminate = "binding correct (indeterminate/mode=indeterminate); offline render is a frozen animation frame (harness disables motion) — not pixel-verifiable, structurally verified".
5. Update the 4 tracer tests (28→30 confirmed; +4 emit files; manifest keys). Full `pnpm test` green (AF-03 flake reruns isolated).

---

## Tasks (TDD, subagent-driven)

- **T1 — config + loader + validate.** `set-attrs.json`; `validateSetAttrs` in example-content.mjs (unit tests: good config passes; bad tag / bad attr throws); `loadProfile` loads it (test: present→parsed, absent→`{}`).
- **T2 — html-label merge.** Thread `setAttrs` through run.mjs→emitter-api→ctx; in `emitEntry`, merge per-set attrs into root attrParts; error on unknown setName; NEVER touch setSlugOf. Tests: a set-attrs entry injects `value="70"` into the right file's example and NOT the filename; a component with no entry is byte-identical; unknown setName throws.
- **T3 — elm merge.** Mirror in elm.mjs; test the elm example carries the attr.
- **T4 — bank.** overrides + confirm/emit + AF-07 (controller renders) + tracer tests + full suite + commit. 28→30.

**Regression (hard):** the 28 confirmed banks emit BYTE-IDENTICAL (none have set-attrs entries); `correspondence.json` byte-stable under re-match; full `pnpm test` green.

## Scope / out
- **In:** set-attrs config + validate + both emitters' root-attr merge + bank circular/linear.
- **Out:** the matcher boolean-qualifier gap (deferred — fixing it in the matcher pollutes filenames + has blast radius; `set-attrs.json` handles the need locally). A filename `slug` override (accept setName-fallback for circular; consistent with menu-item precedent). Live/motion capture of the indeterminate animation. Slider + the other live-blocked components.
