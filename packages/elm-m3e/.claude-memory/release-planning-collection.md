---
name: release-planning-collection
description: Full execution blueprint for releasing elm-m3e/elm-cem/elm-review-cem/m3e-okf lives in ~/Documents/code/planning/ (created 2026-07-11)
metadata: 
  node_type: memory
  type: project
  originSessionId: 5aa5cd04-beda-405d-be7c-2c592ad88f2e
---

The release execution blueprint for the four repos is at
`/Users/jack/Documents/code/planning/` (15 docs; start at README.md →
release/release-checklist.md). It supersedes the stale 2026-07-03 audit reports in
[[release-playbook]] but defers to the playbook for mechanics (cited as PB-NN).

Key facts baked into it (verified 2026-07-11):
- elm-m3e, elm-cem, elm-review-cem are **already PUBLIC** on GitHub; m3e-docs still
  private. Nothing tagged or published anywhere.
- Decision D1: private archive + fresh single-commit public history, **must execute
  before any elm/npm publish** (tags/provenance pin SHAs and close the window forever).
- Publish order: elm-cem (npm) → elm-review-cem → elm-m3e; m3e-okf parallel track.
- D3: rename elm-cem `runtime/M3e/` → `runtime/Acme/` + zero-diff regen gate.
- D6: m3.material.io prose has NO open license → paraphrase+cite only; provenance
  audit blocks m3e-okf public flip.
- "OKF" = Google Cloud **Open Knowledge Format** v0.1 (June 2026), not "Framework":
  github.com/GoogleCloudPlatform/knowledge-catalog/okf/SPEC.md.
- m3e-docs local main was 17 commits behind origin; sync is Phase 0.

**EXECUTION STATUS (2026-07-11, session 5aa5cd04):** Executed autonomously start→release.
DONE: Stage A prep; Stage B all 4 repos (incl. elm-cem M5 generator fixes — plan MISSED that
`elm publish`'s docs build failed on 3 real defects; fixed generally + D3 Acme rename zero-diff);
Stage C m3e-okf 5a/5b/5c (75-page OKF bundle) + **renamed m3e-docs→m3e-okf + flipped PUBLIC**;
Stage D 18 skills; Stage E history migration — **all 4 repos now single-init public history**
(m3e-okf 8ba8fe5, elm-review-cem 34e7c09, elm-cem 96b8d44, elm-m3e 245e719), full history in
private frozen `*-archive` repos, all CI green. Execution logs: `planning/execution/`
(worklog.md, frictions-log.md F-01..F-12), migration in `planning/release/migration-log.md`.
NOT DONE (needs Jack): **Stage F = the actual publishes** — npm trusted-publishing setup + `npm
publish elm-cem@1.0.0`, `elm publish` elm-review-cem + elm-m3e (paused per Jack; permanent).
Runbook: `planning/execution/release-runbook.md`. Also deferred: elm-m3e §2 teaching docs + §3
tests (post-publish). npm name `elm-cem` confirmed free.

**Why:** planning was a one-shot deep investigation (6 parallel agents); redoing it
would be expensive and the decision log (D1–D7) is marked do-not-relitigate.
**How to apply:** the repos are now release-prepped + history-rewritten; do NOT re-run Stage A–E.
For the remaining publishes follow `planning/execution/release-runbook.md`. Rollback for any repo
is its private `<repo>-archive`. When work touches these repos, read the matching
planning/repositories/*.md; after publishes complete, archive planning/ per its ai-artifact self-note.
