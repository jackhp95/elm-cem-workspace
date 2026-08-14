---
name: elm-cem-codegen-overhaul
description: "State of the elm-custom-elements-manifest codegen-quality-overhaul branch — what's done, what gates release"
metadata: 
  node_type: memory
  type: project
  originSessionId: a07e84e3-bddd-49a5-be53-58ca53f06eb0
---

Repo `~/Documents/code/elm-custom-elements-manifest`, branch `codegen-quality-overhaul` (PR #10). A thermo-nuclear code review produced Epic #1 + issues B1–B5/R6–R8.

As of 2026-06-20 all code-quality issues are **closed**: #2 #3 #4 #5 (blockers), and #6 (golden test), #7 (`targetValue` decoder + event docs), #8 (decomposed `Generate.elm` 2186→679 lines), #9 (`schemaVersion` warning). 89 elm tests pass (`npm test` = elm-test-rs). All commits pushed.

**Full regeneration done** 2026-06-20 (commit 29f3e8c): cloned source libs, `cem:all` + `gen:all`, all 9 packages pass `elm make --docs`. carbon (128) + ionic (99) committed for the first time. `exposed-modules` is NOT maintained by the gen pipeline — it was repopulated from disk per package (a manual step to repeat after any regen that changes the module set). Cloned libs are now gitignored; recreate with `npm run libs:clone`.

Remaining epic #1 follow-ups:
- **Spectrum can't regenerate:** upstream restructured into `1st-gen/`/`2nd-gen/`; `cem-configs/spectrum.config.mjs` glob `packages/*/src` matches nothing → empty CEM. Committed `spectrum/src` left as-is (older version, valid). Config needs updating for new layout.
- Calcite docs.json 572KB > 512KB registry limit — needs splitting.
- Ship Deliverable 1 (npm tool) first.

Generator architecture: `codegen/` has `Generate.elm` (orchestration), `Cem.elm` (decoder), and pure exposed-for-testing modules `Attr` (AttrSpec IR), `Naming`, `Emit`, `Docs`, `Util`. Generated output is build artifact — never hand-edit. `bin/elm-cem.js` shells to `elm-codegen run`; the runner prints `info` messages and file `warnings`.

Note: `packages/shoelace/elm.json` has a stray uncommitted exposed-modules reorder (pre-existing, harmless, left for the user to decide). The `.claude/CLAUDE.md` in this repo is mis-filed (it's for an unrelated Avetta project); the real guidance is root `CLAUDE.md`.
