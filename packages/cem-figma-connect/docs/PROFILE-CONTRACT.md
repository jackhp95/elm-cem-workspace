# PROFILE-CONTRACT — every file a `profiles/<name>/` directory may contain

Phase 1.3 (`plans/2026-08-17-figma-elm-config-integration-design.md`). `--profile <name>`
(every CLI subcommand, `src/cli.mjs`'s `resolveProfileDir`) resolves a bare name to
`profiles/<name>/`, never a path. This doc is the reference for what may live there, who
reads it, and the one lockstep rule a second profile author needs to know about. It exists
because the file set is currently discovered by **hardcoded filename** in a handful of
places (`loadProfile`, `src/correspond/merge.mjs`) rather than declared anywhere — this doc
is that declaration, in prose, until/unless it's worth a schema.

## Required

| File | Read by | Purpose |
|---|---|---|
| `profile.json` | `loadProfile` (`src/correspond/merge.mjs`) | The profile's own config: `fileKey`/`kitVersionTag` (Figma extraction anchor — see `docs/USAGE.md` "Two different fileKeys, two different roles"), `cem.{package,version,manifestPath}`, `htmlLabel` (built-in emitter config), `elm` (Elm emitter seam config — profile-local emitter's own concern, `loadProfile` does not project it; emitters read `ctx.profile.raw.elm` themselves), `emitters` (which emitter modules run — literal `"html-label"` or a repo-root-relative path to a profile-local ES module). |

## Optional, discovered by filename if present (all backward-compatible: missing → `{}`)

| File | Read by | Purpose |
|---|---|---|
| `examples.json` | `loadProfile` → `ctx.examples` | Per-cemTag representative example content (by-example banking), consumed by emitters when rendering child content. |
| `set-attrs.json` | `loadProfile` → `ctx.setAttrs` | Per-figmaSet static attribute injection. |
| `manual-correspondence.json` | `loadProfile` → matcher-unreachable-binding authoring input (`src/correspond/merge.mjs`) | `figmaSets` replaces UNBOUND entries only (fail-loud otherwise); `appendSets` extends already-bound entries only; validated against the live CEM + Figma export before anything touches disk. |
| `overrides.json` | `runConfirm`/visual-gate verdict recording (`src/correspond/review.mjs`) | The decision ledger: confirm/reject + gate verdicts, one `decisions[]` array keyed by `cemTag`, each applied decision stamps `provenance:"human"`. |
| `facts/` (a directory, not a file) | `loadCem` (`src/ingest/cem.mjs`), the profile-local Elm emitter | The elm-cem facts bundle copy (Face B `cem-facts.json`, Face C `elm-api-facts.json`, plus `icon-names.json`) — see `scripts/gen-facts.mjs`, the bundle's only writer. `pnpm check:facts` (Phase 1.2, `scripts/check-facts.mjs`) gates this copy against `profile.json`'s `cem.{package,version}` and (optionally) `elm.expectedBrand`. |

## Generated, checked in (not hand-edited)

| File | Written by | Purpose |
|---|---|---|
| `correspondence.json` | `match` (`src/cli.mjs` → `src/correspond/merge.mjs`) | The merged correspondence model — auto-match ⊕ `manual-correspondence.json` ⊕ `overrides.json`. Schema: `src/correspond/schema.json`. Human-protected entries (`provenance:"human"` or `status:"confirmed"`) are never overwritten by a re-run; a differing fresh proposal lands in that entry's `proposedUpdate` instead. |
| `gap-report.md` | `gap` (`src/correspond/gap-report.mjs`) | Code-only / Figma-only / undrawn report — never a silent drop. |

## Profile-local emitter modules

Referenced from `profile.json`'s `emitters[]` as a repo-root-relative path (e.g.
`profiles/m3-kit/emitters/elm.mjs`), dynamically `import()`-ed by the emitter registry
(`src/emit/run.mjs`). Must implement the contract in `src/emit/emitter-api.mjs` (`name`,
`label`, `emit(entry, ctx) -> [{path, contents}]`, and MUST be a **pure** function of
`(entry, ctx)` — no fs/network/env/clock/random inside `emit()` itself; static committed
data may be loaded once at module init, analogous to a static JSON import). Purity is what
makes "re-run is byte-stable" checkable at all — see `test/emitter-api.test.mjs`.

## The lockstep rule

`buildEmitContext` (`src/emit/emitter-api.mjs`) is the ONE function that assembles the
`ctx` object handed to every emitter — but it is *called* from two separate places that
must pass it the same argument shape:

- `src/emit/run.mjs` (`runEmit`, the real `emit` subcommand — writes `generated/**`)
- `src/publish/check.mjs` (`runCheck`, the `check` subcommand's drift gate — re-emits
  in-memory and diffs against the committed `generated/**`)

Both already call the same imported `buildEmitContext({ profile, figma, cem, entry,
iconTable, examples, setAttrs })` — the lockstep obligation is that **any new field a
profile or emitter needs added to `ctx`** gets threaded through both call sites (and
`buildEmitContext`'s own signature) in the same change, not just the one you happen to be
editing. `check`'s entire drift guarantee rests on both paths constructing byte-identical
contexts from the same inputs; a field present at one call site and not the other is a
silent drift-detection hole, not a type error — nothing currently enforces this
structurally.

## Adding a second profile (Avetta, Plan F)

A new profile needs, at minimum, `profile.json` + a `correspondence.json` (via `match`).
Everything under "Optional" is opt-in. If the new profile has its own Elm (or other
framework) emitter, it needs its own profile-local emitter module and — per Phase 1.1 —
its own `facts/` copy pointed at by `profile.json` rather than a path hardcoded into the
shared emitter module (see that phase for the current status of that seam).
