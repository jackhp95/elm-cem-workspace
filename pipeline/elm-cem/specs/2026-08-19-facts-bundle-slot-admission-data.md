# Plan: carry slot admission data (`admits`/`multi`/`required`) into the CEM facts bundle

**Spec:** `core/cem-figma-connect/research/2026-08-19-structural-fidelity-ideation.md`, lever **C2**. **Blocking finding this plan resolves:** `core/cem-figma-connect/plans/2026-08-19-example-tree-slot-validation.md`'s Task 1 halted (correctly — verified independently) because the facts bundle `elm-cem` produces (consumed downstream as `brands/m3e/outputs/m3e-api-okf/data/cem-facts.json`, and by `core/cem-figma-connect/src/ingest/cem.mjs`'s `loadCem()`) carries `components[].slots` as `{name, description}` only — zero `admits`/`kinds`/`multi`/`required` fields — even though `elm-cem` already reads exactly that data from `brands/m3e/inputs/cem/config/slots.json` (passed via `--config-from=config/slots.json`, see `tools/lib/regen.mjs`) to generate the compile-time phantom types (`SlotCaps`, `Content`, `ChildAdmittedBy` in `brands/m3e/outputs/elm-m3e/src/M3e/Internal/Types/*.elm`) and the elm-review facts (`brands/m3e/outputs/elm-m3e/src/M3e/Review/Facts.elm`'s `requiredSlots`/`multiSlots`/`slotKinds`). The data is read and used internally; it just never gets written back out into the facts bundle.

## Goal

`elm-cem`'s generated facts bundle (`cem-facts.json`, Face B) gains, for every component's `slots[]` entry, the same `admits: { kinds: string[], multi: boolean, required: boolean }` shape already declared in `slots.json` for that slot — sourced from the exact same input `elm-cem` already parses, not a new or duplicate reader.

## Global Constraints

- **One producer.** `elm-cem` already reads `slots.json`; this plan adds a field to `elm-cem`'s own existing output, it does not add a second consumer of `slots.json` anywhere else in the workspace. `core/cem-figma-connect` and any other downstream package must keep reading this data exclusively via the facts bundle `loadCem()`/equivalent already provides — never via a new direct read of `brands/m3e/inputs/cem/config/slots.json`.
- **Read the actual generator code before writing anything.** `core/elm-cem`'s CLI entrypoint is `core/elm-cem/bin/elm-cem.js`; find the exact module(s) that (a) parse `--config-from=config/slots.json`'s content, (b) build the `SlotCaps`/`Content`/phantom-type generation, and (c) build the facts-bundle JSON's `components[].slots` array (the one currently emitting `{name, description}` — grep the literal string `"description"` near slot-building code, or trace from `brands/m3e/outputs/m3e-api-okf/data/cem-facts.json`'s actual shape backward). Do not guess the file; if grepping doesn't find it quickly, use `core/elm-cem`'s own test suite (`core/elm-cem/tests/`) to find a test that exercises slot-bundle generation and work backward from there.
- **This is a shared, foundational package.** `elm-cem` generates output consumed by every brand (`brands/*/outputs/*`), not just `m3e`. Changing its facts-bundle shape is additive (a new field on an existing object), but must not change any *existing* field's meaning, and must not break any consumer that doesn't yet know about the new field (additive JSON fields are safe for consumers that don't read them, but confirm this by actually running each consumer's own check/test suite, not by assumption).
- `pnpm test`/`pnpm check`-equivalent gates must stay green in **every** package this touches: `core/elm-cem` itself, `brands/m3e/outputs/m3e-api-okf` (regenerates from the bundle), `core/cem-figma-connect` (reads the bundle via `loadCem()`), and the root `tools/gate-all.mjs` (drift-checks the whole family — this is the real end-to-end proof; it's the same gate this repo already uses to catch cross-package facts-bundle drift).
- Do not touch anything in `brands/m3e/inputs/cem/config/slots.json` itself (the input, unchanged) or `brands/m3e/outputs/elm-m3e/src/M3e/Internal/Types/*.elm` (the phantom types, unaffected — this plan only adds a NEW output field, it doesn't change how the types get generated).

## Tasks

### Task 1: Trace the real producer

- Locate the exact module(s) in `core/elm-cem` responsible for (a) parsing `slots.json`'s `admits` data and (b) emitting the facts-bundle's `components[].slots` array.
- Write down (in the report, not committed) the call path from CLI entrypoint to the JSON field, so Task 2's implementer doesn't have to re-derive it.
- Confirm via a quick manual trace (or a debug print, removed before finishing) that `slots.json`'s `admits`/`multi`/`required` data really is in scope/available at the point the facts-bundle slots array gets built — i.e. this is genuinely "the data is already loaded, just not written out" and not "the data was already discarded upstream by the time this function runs." If it's the latter, that's a bigger change than this plan scopes for — stop and report rather than improvising a second load path.

### Task 2: Add `admits` to the facts-bundle slot shape

- Extend the facts-bundle slot-emission code found in Task 1 to include `admits: { kinds, multi, required }` per slot, copied directly from the already-loaded `slots.json` data structure for that component+slot (no new file read).
- Update `core/elm-cem`'s own facts-bundle JSON schema/type (if one exists — check for a schema file or TypeScript/JSDoc type describing the bundle shape) to declare the new field.
- Add/extend a test in `core/elm-cem/tests/` asserting a real component's generated facts-bundle slot entry now carries the correct `admits` data, matching what's declared for that component in the real `slots.json` (use a real example already in the fixture set — e.g. whatever component `FilterChipSet` or `Card` correspond to in elm-cem's own test fixtures, or the closest equivalent; don't invent a new fixture component if an existing one already has a slot with `multi:true` or a restricted `kinds` list to assert against).

### Task 3: Regenerate and verify every downstream consumer

- Regenerate the real facts bundle(s) this affects (check `tools/lib/regen.mjs`/`tools/gate-all.mjs` for the actual regen commands — likely something like the `gen-facts.mjs` scripts found in `brands/m3e/outputs/m3e-api-okf/scripts/gen-facts.mjs` and `core/cem-figma-connect/scripts/gen-facts.mjs`, or a root-level regen driven by `tools/bump.mjs`).
- Run each affected package's own check/test suite fresh: `core/elm-cem`, `brands/m3e/outputs/m3e-api-okf` (`npm run check`), `core/cem-figma-connect` (`pnpm check && pnpm test`).
- Run `node tools/gate-all.mjs` (the root cross-package drift gate) and confirm it's green — this is the proof that the new field didn't silently desync any consumer's committed copy of the bundle.
- If any consumer's committed output changes as a result of the regeneration (e.g. a byte-diff in a checked-in generated file beyond the new field itself), inspect the diff carefully — it should be additive-only (the new `admits` field appearing, nothing else changing). If anything else changes, that's a signal something in Task 2 touched more than intended; investigate before committing.

## Acceptance

- `cem-facts.json`'s `components[].slots[]` entries carry real `admits: {kinds, multi, required}` data, verified against a real component's known slot contract.
- `core/elm-cem`'s own tests, `brands/m3e/outputs/m3e-api-okf`'s `npm run check`, `core/cem-figma-connect`'s `pnpm check`/`pnpm test`, and root `node tools/gate-all.mjs` are all green.
- No new direct reader of `brands/m3e/inputs/cem/config/slots.json` exists anywhere outside `core/elm-cem` itself.
- This unblocks `core/cem-figma-connect/plans/2026-08-19-example-tree-slot-validation.md`'s Task 1, which can now be re-run for real (not part of this plan's scope — a follow-up dispatch once this lands).
