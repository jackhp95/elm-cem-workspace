# Plan: strengthen example-content slot validation (admitted kinds + multiplicity)

**Spec:** `core/cem-figma-connect/research/2026-08-19-structural-fidelity-ideation.md`, lever **C2**.

## Context

`src/emit/example-content.mjs`'s `validateExamples` already asserts every `tag` in `profiles/m3-kit/examples.json`'s recursive `{tag, slot?, attrs?, text?, children?}` trees is a real CEM element, and every `slot` is a real slot of its parent. It does **not** yet check that a child's *kind* is admitted by that slot, or that a `multi:false` slot isn't given more than one child. The admitted-kinds/multiplicity contract already exists as checked-in data (`brands/m3e/inputs/cem/config/slots.json`) and is already mirrored into the facts bundle consumed elsewhere in this pipeline — this plan wires the *existing* emit-side validator up to that *existing* contract; it does not invent a new one.

## Goal

`validateExamples` rejects an example tree where a slot is given a child kind it doesn't admit, or more children than its declared multiplicity allows — with a clear, actionable error (component + slot + offending kind/count), not a silent pass-through.

## Global Constraints

- **Read the admitted-kinds/multiplicity data from the facts bundle** (`brands/m3e/outputs/m3e-api-okf/data/cem-facts.json` or wherever this repo's "one producer" rule currently routes it — confirm the real path before writing anything; do NOT reach directly into `brands/m3e/inputs/cem/config/slots.json`, which is a different package's codegen *input* and reaching into it would create a second, uncoupled producer of the same fact. If the facts bundle does not yet expose per-slot admitted-kinds/multiplicity, that gap is itself a finding — stop and report it rather than improvising a second data source).
- No Figma calls of any kind — this is a pure Elm/JS data-validation change, entirely on the code side.
- Must not break any of the 224 currently-passing generated bindings — `pnpm check` must show 0 drift/orphan after this change, meaning today's `examples.json` content must already satisfy the strengthened validator (if it doesn't, that's a real finding: fix `examples.json`'s offending entries, don't weaken the validator to accommodate them, unless you can show the existing content is in fact correct and the new check has a bug).
- `pnpm test` must stay green throughout.

## Tasks

### Task 1: Locate and confirm the admitted-kinds/multiplicity source of truth

- Read `src/emit/example-content.mjs` in full (the current validator).
- Read `VISION.md`'s description of `cem-facts.json` (cited in the ideation doc as covering "tags/attrs/enums/slots") and locate the actual committed facts bundle file(s) this repo already loads elsewhere (grep for existing consumers of the facts bundle in `src/` — reuse an existing loader, don't write a new one).
- Confirm the facts bundle actually carries per-slot `admits: { kinds, multi, required }` data equivalent to `slots.json`'s shape. If it does not, STOP this task and produce a short written finding (in the report, not committed) describing the gap — do not proceed to Task 2 by reaching into `slots.json` directly.

### Task 2: Strengthen `validateExamples`

- Add: for each `{tag, slot, children}` node, look up the parent's slot admission for `slot` (or `unnamed` when `slot` is absent) via the facts-bundle loader confirmed in Task 1.
- Check each child's tag resolves to a `kind` admitted by that slot's `kinds` list (an `"any"` kinds list admits everything).
- Check the slot's `multi:false` constraint: at most one child in that slot.
- On violation, throw/report a specific error naming the parent component, the slot name, and either the disallowed kind or the multiplicity violation (mirror this repo's existing error-message style in the same file — read the current "real slot of its parent" error message and match its tone/format).
- Test: a fixture tree with a disallowed child kind in a slot fails validation with the expected message; a fixture tree with two children in a `multi:false` slot fails; a fixture tree that's fully valid (including at least one real, currently-committed example from `examples.json`) passes.

### Task 3: Run the strengthened validator against real committed data

- Run `validateExamples` (via whatever CLI/check entrypoint already invokes it — likely part of `pnpm check`) against the real `profiles/m3-kit/examples.json`.
- If it now fails against real, currently-shipping content: do not weaken the check. Investigate whether the real content has a genuine slot-kind or multiplicity violation. If so, fix the `examples.json` entry (report exactly which entries and why). If the failure instead reveals a bug in the new check's logic (e.g. a slot legitimately admits a kind the facts bundle didn't list), fix the check, not the content — and say so explicitly in the report with the reasoning.
- `pnpm check` must show 0 drift/orphan (224 bindings, matching the existing gate) once this task is done.

## Acceptance

- `pnpm check` and `pnpm test` green in `core/cem-figma-connect/`.
- `validateExamples` demonstrably rejects both a wrong-kind and a wrong-multiplicity example tree in its test suite.
- The real, committed `examples.json` passes the strengthened validator (after any necessary content fixes, each one reported and justified).
- No Figma write calls, no new second producer of the slot-admission facts.
