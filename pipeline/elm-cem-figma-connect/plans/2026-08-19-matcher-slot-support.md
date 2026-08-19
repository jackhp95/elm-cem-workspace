# Plan: matcher/emitter support for Figma `SLOT` properties

**Spec:** `core/cem-figma-connect/research/2026-08-19-structural-fidelity-ideation.md`, lever **F3** (read half only — the authoring half of F3 is out of scope, see Global Constraints).

## Context

Today's Figma→Elm round-trip loses slot identity on read: `src/ingest/figma-export.schema.json` already enumerates `SLOT` in `setProperties[].type`, annotated *"not mapped by the current matcher/emitter surface."* The capture records slot properties; the matcher ignores them. This showed up concretely in the 2026-08-19 "Feed" round-trip test as **D2 (slot drift)** — though D2 itself was a *write*-direction failure (out of scope here), the same missing read-side capability means that if a Figma file DOES contain real `SlotNode`s / `SLOT`-typed component properties, `cem-figma-connect` cannot today represent "this content belongs in slot X" — it only sees flat `props`/`axes`.

## Goal

Extend the read pipeline so a `SLOT`-typed Figma component property is captured, matched, and emitted as slot-scoped content, alongside the existing `axes`/`props` dimensions in `correspondence.json`.

## Global Constraints

- **Read-direction only.** Do not add any code that creates, edits, or mutates Figma content (no new `use_figma` calls of any kind, no Figma authoring). This plan only teaches the existing ingest → match → emit pipeline to *read* an already-existing `SLOT` property.
- Follow this repo's existing schema/matcher/emitter architecture — a new dimension (`slots`) alongside `axes`/`props` on a correspondence entry, not a parallel system.
- Every change must be covered by tests using the repo's existing fixture style (`test/fixtures/`), not live Figma calls.
- `pnpm check` and `pnpm test` (from `core/cem-figma-connect/`) must stay green throughout and at the end.
- Do not touch `packages/` paths — this repo uses `core/cem-figma-connect` and `brands/m3e/...` post-reorg; verify current paths before editing anything, don't assume the pre-reorg layout from older docs.
- No changes to `profiles/m3-kit/correspondence.json`'s *existing* entries' meaning — additive only (new optional `slots` field).

## Tasks

### Task 1: Schema + fixture — declare the `slots` correspondence dimension

- Extend `src/correspond/schema.json` with an optional `slots` array on a correspondence entry, each item `{ figmaSlotName: string, kind: string, multi: boolean, mappedTo: string | null, unmapped: string | null }` (mirror the existing `unmapped`-with-reason convention used for `axes`/`props` — see `profiles/m3-kit/correspondence.json` for the real shape to match).
- Add or extend a fixture under `test/fixtures/` with at least one `COMPONENT`/`COMPONENT_SET` whose `setProperties` includes a real `SLOT`-typed entry (base it on the actual shape captured by `src/ingest/figma-export.schema.json`'s `SLOT` enum member — read that schema file first).
- Test: schema validates a correspondence entry with a `slots` array; rejects one with an invalid `kind` or missing required sub-field.

### Task 2: Ingest — carry `SLOT` properties through unmodified (if not already)

- Read `src/ingest/figma.mjs` and confirm whether `SLOT`-typed `setProperties` entries already survive ingest into the in-memory figma-export representation, or are silently dropped. Fix if dropped.
- Test against the Task 1 fixture: ingesting the fixture surfaces the `SLOT` property on the loaded export.

### Task 3: Matcher — populate the `slots` dimension

- Extend the matcher (`src/match/`) to populate a correspondence entry's new `slots` field from a component's `SLOT`-typed properties, using the same auto-exact/auto-fuzzy/auto-gap provenance tiers already used for `axes`/`props` (read `src/match/` for the existing tier logic and mirror it — do not invent a new provenance scheme).
- An entry whose Figma component has a `SLOT` property with no CEM-side slot counterpart gets `mappedTo: null, unmapped: "<reason>"` — never silently dropped, matching this repo's "a name that can't be verified is surfaced as a concern, never guessed" doctrine (cited in the ideation doc's § 1.3).
- Test: a fixture with a mappable slot produces a populated `slots` entry with the right provenance tier; a fixture with an unmappable slot produces an `unmapped` entry with a reason.

### Task 4: Emit — surface slot-scoped content in generated bindings

- Extend whichever emitter(s) currently read `axes`/`props` off a correspondence entry (`src/emit/`) to also read `slots`, and emit slot-scoped content using the Code Connect `getSlot()` API pattern (see `figma-code-connect` skill's `getSlot` documentation, already referenced elsewhere in this repo's Code Connect templates) for entries where `slots` is populated and mapped.
- `pnpm run check:facts` / `pnpm check` must show 0 drift against the newly-generated output for the m3-kit profile fixtures.
- Test: a fixture entry with a mapped slot emits a `.figma.ts` template using `getSlot()`; one with an unmapped slot does not attempt slot emission and instead surfaces the existing gap-report mechanism.

## Acceptance

- `pnpm check` and `pnpm test` green in `core/cem-figma-connect/`.
- A correspondence entry can now carry slot information, end-to-end from ingest through to emitted Code Connect output, with the same provenance/unmapped governance as every other dimension.
- No Figma write calls anywhere in the diff.
