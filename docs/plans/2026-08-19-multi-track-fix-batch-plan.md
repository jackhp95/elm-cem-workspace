# 2026-08-19 — Multi-track fix batch (gauntlet plan)

Manager: top-level session. Status legend: `queued → dispatched → in-verify → done | retried_up | trashed`.

Ground truth gathered this session (see conversation) — do not re-investigate:
- `el`→`component` rename fully merged on `main`; local == `origin/main`; committed `dist/` is what Netlify serves. No stale "el" found anywhere in-workspace. If Jack was looking at the standalone `jackhp95/elm-m3e` mirror, that's out of scope here (read-only mirror, separate sync concern) — not chased further unless Jack supplies the URL.
- `elm-m3e-family` and `elm-m3e-icons` are both already built and merged on `main`. No build work needed for those packages themselves.
- `packages/m3e-okf` is an empty stub — the real OKF pattern lives at `brands/m3e/outputs/m3e-api-okf/` (disclosure-hook scripts, non-blocking staleness reporting) and `brands/m3e/inputs/material-okf/knowledge/`. Use these as the actual precedent, not assumption.
- Jack corrected an investigation claim: Components nav is **not** actually visually grouped by category in the UI today — it's a flat list too (categorization exists in data, not rendering). So Track C.3 scope is: **flat list stays, insert visual divider elements between existing logical groups** — no nesting, no tab merge/split.

## Status (2026-08-19, post-execution)

All three tracks executed and self-verified in isolated worktrees, clean status, ready for Jack's merge review:
- Track A: `.claude/worktrees/agent-ae099ba76362fbf0d`, branch `worktree-agent-ae099ba76362fbf0d` — gate-all 361.5s → ~276s (~24% cut), verified cache doesn't false-green. Missed ≤250s stretch target (concurrency capped for stability, documented tradeoff).
- Track B: `.claude/worktrees/agent-adf03debc8e3b774c`, branch `worktree-agent-adf03debc8e3b774c` — Family tab + `NoFamilyMemberDrift` review rule, both verified green. Note: real family source is `brands/m3e/inputs/cem/config/slots.json`'s `_families`, not `family-configs/m3e.json`/`tools/family.json` as this plan assumed (friction logged).
- Track C: `.claude/worktrees/agent-a8e48485eed5250b1`, branch `worktree-agent-a8e48485eed5250b1` — all 3 UI fixes verified with before/after screenshots.

Manager spot-checked: all 3 branches clean, commit history matches worker claims. Full diff review + merge decision is Jack's per the review-gate policy — not auto-merged.

## Track A — gate-all perf (worktree `wt-gate-scheduler`)

Existing unimplemented plan: `docs/superpowers/specs/2026-08-18-gate-all-parallelization-design.md` + `docs/superpowers/plans/2026-08-18-gate-all-parallelization-plan.md`. Do NOT redesign from scratch.

- [ ] A1 — Work — sonnet/medium — queued — refine the existing design doc: fold in the `check-staleness.mjs` non-blocking-report discipline (report, never silently skip a gate) explicitly into the `build:site` content-hash cache section if not already framed that way. Small doc edit, not a rewrite.
- [ ] A2 — Work — sonnet/medium — queued — implement `tools/lib/gate-scheduler.mjs` per the plan's Phase 1 (bounded worker pool, tag-based `exclusiveWith` conflicts, run `test:browser` concurrently with the ~130s of independent steps). Respect the 4 documented hazards (shared `docs/dist`, port 1239, shared `ELM_HOME`, shared `.gate-out/probe.js`).
- [ ] A3 — Work — sonnet/medium — queued — Phase 2: profile `mobile-shell.spec.ts` and `shell-breakpoints.spec.ts` (26s/25s outliers) for real cause; add content-hash cache for `build:site`; retune Playwright `workers` cap (currently 3).
- [ ] A4 — Work — sonnet/medium — queued — Phase 3: widen pool to all ~130s of independent steps running concurrently.
- [ ] A5 — Work — sonnet/medium — queued — Phase 4: memoize facts-bundle regen (currently called 7+ times/run), parallelize `gh api` calls in check-mirror-drift.
- [ ] A-verify — Verify — sonnet/medium — queued — fresh-worktree timed run of `node tools/gate-all.mjs`, captured wall-clock before/after (baseline 361.5s), confirm exit code 0, confirm no false-green from a cache hit (mutate one input, confirm re-run triggers).

## Track B — family docs tab + elm-review rule (worktree `wt-family-tab`)

- [ ] B1 — Work — sonnet/medium — queued — add "Family" nav tab: new `sections` entry in `brands/m3e/outputs/elm-m3e/docs/app/Shared.elm` (~line 1685) + new route reading `elm-m3e-families` generated modules (pattern off existing `data/reference.json`/`examples.json` route).
- [ ] B2 — Work — sonnet/medium — queued — new elm-review rule `core/elm-review-cem/src/ComponentBelongsToFamily.elm` (or similar name), modeled on `NoMissingComponentApiNames.elm`, consuming `tools/family.json`, wired into `Cem.elm`'s rule list.
- [ ] B-verify — Verify — sonnet/medium — queued — captured Playwright screenshot of new Family tab at 411×761; captured `elm-review` run showing the new rule firing on a deliberately-broken fixture and passing clean on `main`.

## Track C — docs UI fixes (worktree `wt-docs-ui`)

- [ ] C1 — Work — sonnet/medium — queued — search overlay click-outside-to-close. Investigate whether switching `m3e-search-view` to `popover="auto"` breaks any existing manual-control behavior before committing to that path; fallback is an Elm-side outside-click subscription dispatching `CloseSearch`.
- [ ] C2 — Work — sonnet/medium — queued — `Roundtrip.elm:372-411` `cellRow`: replace the two bare sibling spans with structured markup (real divider/chip) between `deviationText` and `escapeText` so they don't visually run together. No renaming — "functionalseam" isn't a real token, purely a spacing bug.
- [ ] C3 — Work — sonnet/medium — queued — Guide nav (`Shared.elm` `navSections` ~1348-1404): keep the flat list and existing groups, insert visual divider elements between the existing logical groups. No nesting, no merging Start/Styles into Guide.
- [ ] C-verify — Verify — sonnet/medium — queued — captured Playwright before/after screenshots at 411×761 for all three (search overlay outside-click, Cells summary card, Guide nav dividers).

## Cross-cutting

- Every work leaf: worktree, friction-log clause, done-gate (criteria met + captured evidence from clean worktree + git/PR state confirmed).
- Verify agents run on a different provider/fresh context than their paired worker.
- Manager stays alive for all three tracks (parallel dispatch, blocking wait for completions), fans out sequencing itself — no mid-flight check-ins with Jack except genuine scope changes.
