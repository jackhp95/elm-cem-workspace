# m3-kit codeSyntax stamp/unstamp — runbook (Task D3 / ⚑ HUMAN gate D7)

This directory is **generated** (`node src/tokens/stamp.mjs --profile m3-kit --out
profiles/m3-kit/stamp/`, from `profiles/m3-kit/tokens.json`'s `status: "mapped"` rows —
today 134: 49 `Schemes/*`, 10 `Corner/*`, 75 `Static/*`). Do not hand-edit the `.js` files
— regenerate them; only this README is hand-authored, and the generator never touches it
(verified in `src/tokens/stamp.test.mjs`).

**Nothing in this directory has been run against a real Figma file.** Generating these
scripts is offline (Task D3, this session). Applying any of them is a separate,
per-file ⚑ HUMAN authorization (Task D7, deferred).

## What the mechanism does (evidence #6, demonstrated live 2026-07-10)

`variable.setVariableCodeSyntax("WEB", "var(--md-sys-color-on-surface)")`, run inside a
Figma file via the Plugin API (`use_figma`), makes `get_design_context` immediately start
emitting `var(--md-sys-color-on-surface,#1d1b20)` in generated layout code for that
variable — instead of Figma's own auto-derived slug (e.g. `--schemes\/on-surface`). This
is the entire "Tailwind leg" of the plan: stamp every mapped token-table row once, and
every future `get_design_context` call on that file speaks our `--md-sys-*` vocabulary.
**No custom Figma plugin is needed** — `use_figma` alone is sufficient.

## Files in this directory

| File | Role | Mutates? |
| --- | --- | --- |
| `00-snapshot.js` | Returns current `codeSyntax` for all 134 mapped variables, keyed by name | No (read-only) |
| `01-schemes.js` (40) / `01-schemes-2.js` (9) | Stamps `Schemes/*` | Yes |
| `02-corner.js` (10) | Stamps `Corner/*` | Yes |
| `03-static.js` (40) / `03-static-2.js` (35) | Stamps `Static/*` | Yes |
| `unstamp/<same filename>.js` | Inverse of each stamp script above (`removeVariableCodeSyntax("WEB")`) | Yes |

Chunking rationale: the `figma-use` skill's incremental-workflow rule caps a single
`use_figma` call at roughly 40 writes so errors stay easy to read. Corner (10 rows) fits
in one file; Schemes (49) and Static (75) each spill into one continuation file
(`-2.js`) at the 40-row boundary. File numbering follows the brief's fixed family order
— Schemes=01, Corner=02, Static=03 — not alphabetical (Corner would otherwise sort
before Schemes).

## Portability: by NAME, not by id (evidence #5)

Every script locates variables via `figma.variables.getLocalVariablesAsync()` + a name
match. **None of them contain a hardcoded Figma variable id** (verified in
`stamp.test.mjs` — no generated script matches `VariableID:`). This is required because
duplicating a Figma file **re-mints every variable/component key** (evidence #3 measured
this directly: the Button component set's key changed across a duplicate; only node ids
survived). The exact same script file must run unmodified against:

- the canonical M3 kit copy (fileKey `KujuFlfJSwHI6ua1b7RZvL`),
- the throwaway mutation-playground Copy (fileKey `iPFL8MH2R1Xphe94j7g809`),
- ADS, in Plan F (fileKey `cbhz1J779WAI7gYkjCQwS0`), once that phase starts.

## Idempotency

Every stamp script reads `v.codeSyntax.WEB` before writing and skips a variable whose
value already equals the intended one. Every unstamp script reads the same field and
skips a variable whose value does **not** currently equal what we would have stamped
(never blindly clears a value we didn't set). Re-running any script twice in a row is
always a safe no-op the second time — this is exercised directly in
`stamp.test.mjs` by executing the generated script text against a fake `figma` stub.

Every script returns a structured result object:
- stamp scripts: `{ stamped, skipped, missing, mutatedVariableIds }`
- unstamp scripts: `{ unstamped, skipped, missing, mutatedVariableIds }`
- `00-snapshot.js`: `{ snapshot, missing }`

`missing` (a variable name in the token table that doesn't resolve in this file) is
reported, never thrown — a partial match across the family isn't fatal, but should be
investigated (it likely means the target file's kit version has drifted from the
`research/figma-dumps/kit-variables.json` dump this table was derived from).

## `--dry-run`: preview without touching Figma

```
node src/tokens/stamp.mjs --dry-run --profile m3-kit
```

Prints a `variable -> current -> intended` table for all 134 mapped rows, reading
`current` from the checked-in `research/figma-dumps/kit-variables.json` dump (which
measures 0/304 variables with any `codeSyntax` today — evidence #13). This makes **zero**
Figma calls; it is safe to run any time, by anyone, without authorization.

## ⚑ HUMAN: applying a script to a real file

**Stamping (or unstamping) a file is a per-file authorization.** Do not run any script
in this directory against a real Figma file without the user's explicit go-ahead for
that specific fileKey. Ask which target before running anything.

### Targets (as of this writing)

| Target | fileKey | Status |
| --- | --- | --- |
| Canonical M3 kit (user's drafts duplicate) | `KujuFlfJSwHI6ua1b7RZvL` | Authorized write scope for Code Connect publish (2026-07-10 decision ledger); codeSyntax stamping here has **not yet** been separately authorized — ask first |
| Throwaway mutation-playground Copy | `iPFL8MH2R1Xphe94j7g809` | The intended target for Task D7's acceptance replay — evidence #6 was already demonstrated here once, live, then left in place as a demo |
| ADS (Avetta Design System, org workspace) | `cbhz1J779WAI7gYkjCQwS0` | Plan F (Avetta consumer phase) — out of scope until that phase starts |

### Procedure

1. **Confirm the target fileKey with the user.** Never assume — ask which of the above
   (or a new target) is intended for this run.
2. **Run `00-snapshot.js` first**, via `use_figma`, against the target file. Save the
   returned JSON beside the run log (e.g.
   `research/evidence/<date>-<target>-codesyntax-snapshot.json`) — this is the
   authoritative pre-state an unstamp pass restores from if the target ever had
   non-empty `codeSyntax.WEB` values before this run (the checked-in token table's own
   dump has 0/304, so for a file matching that dump, "restore to `{}`" and "restore to
   the snapshot" are the same operation — but don't assume that holds for every target
   without checking the snapshot first).
3. **Run the stamp scripts in order** (`01-schemes.js`, `01-schemes-2.js`, `02-corner.js`,
   `03-static.js`, `03-static-2.js`), each as its own `use_figma` call. Read each result
   object (`stamped`/`skipped`/`missing`/`mutatedVariableIds`) before proceeding to the
   next script — do not fire all five before checking the first result (per the
   `figma-use` skill's "work incrementally... validate after each step" rule).
4. **Verify** by calling `get_design_context` on a node that references a stamped
   variable. The acceptance replay (Task D7 Step 1) checks node `56576:34730` on the
   throwaway Copy (`iPFL8MH2R1Xphe94j7g809`) and expects `var(--md-sys-color-*, ...)`
   names in the emitted code for every stamped `Schemes/*` role — reproducing evidence
   #6 from these generated artifacts instead of hand-written ad hoc code.
5. **To undo:** run the matching `unstamp/<file>.js` scripts, same order, same
   incremental-validate discipline.

### Exact `use_figma` invocation

Before calling `use_figma`, load the `figma-use` skill (via the Figma MCP resource, if
Claude Code tools appear as deferred: `ToolSearch query="select:use_figma"` first, then
invoke the skill). Its Critical Rule #1 requires `skillNames` on every call:

```
use_figma({
  code: <contents of the .js file, pasted verbatim>,
  skillNames: "resource:figma-use",
})
```

Notes:
- The `.js` file's contents are already the exact plain-JavaScript body `use_figma`
  expects (top-level `await`, `return` at the end, no IIFE wrapper — do not add one).
- `figma.currentPage` resets between `use_figma` calls, but these scripts never depend on
  page context (`getLocalVariablesAsync()` returns every local variable in the file
  regardless of current page) — no `setCurrentPageAsync` call is needed or present.
- Because `use_figma` is atomic (a script that throws makes zero changes), a failed
  script is always safe to inspect and retry — do not immediately retry without reading
  the error first (`figma-use` Rule 14).

## Follow-up (deferred, not this task)

- Task D7: run this procedure for real against the throwaway Copy, check the run log +
  `00-snapshot.js` output into `research/evidence/`, and confirm the acceptance replay.
- A future task may extend this generator to the `State Layers` / `Tracking` / `Add-ons`
  families once Task D6 gives them a non-`unmapped` status (`policy` rows are
  deliberately excluded from stamping today — only `status: "mapped"` rows get a
  confidently-derived `--md-sys-*` name to stamp).
