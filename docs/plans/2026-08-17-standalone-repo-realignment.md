# Standalone-repo realignment — monorepo canonical, repos become published mirrors

> Gauntlet plan. Owner: elm-cem-workspace main. Resolves the "did we make a clean
> break from the jackhp95/* source repos?" question Jack raised 2026-08-17.

## Problem

VISION.md and GAUNTLET-LEDGER.md (bootstrap, "Source-repo baseline") both declare
the intent: the 9 `jackhp95/*` family repos were flat-copied into
`packages/*` at the 2026-08-12 migration and were meant to go **inert** —
frozen snapshots, HEAD SHA as the A/B reference, all forward development in
the monorepo. That invariant is not holding:

- `elm-typed-html` (standalone repo) has a commit **today**, 2026-08-17T19:09
  ("route TypedHtml.lazy..lazy8 through HtmlIr.Element, not HtmlIr.Node") that
  does not exist anywhere in the workspace's history for
  `packages/elm-typed-html`.
- `tailwind-m3e-web`, `elm-review-cem`, `elm-cem`, `elm-cem-facts` standalone
  repos also show pushes after the 2026-08-12 baseline.
- No local checkout of any standalone repo exists anywhere on this machine
  outside the workspace — so the leak is not "Jack forgot and edited a local
  clone." Most likely: some agent workflow, given a task scoped to
  "elm-typed-html" or similar, clones the bare `jackhp95/<name>` GitHub repo
  directly instead of working inside `packages/<name>` of the workspace.
- Zero tooling exists (`git push` / `remote add` to any `github.com/jackhp95/*`
  target: zero hits across `tools/*.mjs`, `tools/*.sh`) to publish workspace
  state back out. The one migration-era fidelity check
  (`tools/copy-fidelity-*.sh`) compares against `.cache/snapshots/`, which no
  longer exists (removed at M6 deep-clean) — so even the one-way check is
  currently dormant.

Decision (Jack, 2026-08-17): monorepo stays canonical. Standalone repos become
**read-only published mirrors**, not independent development targets. This
matches VISION.md's stated Phase 5 ("Publish + upstream") direction; it does
not require amending VISION.md.

## Done-gate

- [ ] Every `jackhp95/*` family repo has an explicit "mirror, do not commit
      here" marker (README banner + branch protection or equivalent) pointing
      back to `elm-cem-workspace`.
- [ ] All post-2026-08-12-baseline commits sitting only in standalone repos are
      identified, triaged, and either ported into the workspace or explicitly
      recorded as superseded/rejected — none silently lost.
- [ ] A publish path exists: one gated command/CI step pushes workspace
      `packages/<name>` state out to `jackhp95/<name>` (subtree push or
      generated-mirror-commit, matching each repo's existing history shape
      well enough for `git blame`/history to stay usable).
- [ ] A drift gate runs on a schedule (or in CI) that fails loudly if any
      standalone repo's HEAD moves without a matching workspace publish —
      turns "silent leak" into "caught same day."
- [ ] Root cause of the leak identified — which agent workflow/skill/tool
      cloned a standalone repo directly — and closed (routing fix, skill
      note, or CLAUDE.md rule) so it can't recur silently.
- [ ] VISION.md / README.md updated with the explicit mirror policy so future
      agents don't have to reverse-engineer it the way this investigation did.

## Task table (manager state)

```
[x] T1 goal-identify   inline(sonnet)  DONE — root cause identified
[x] T2 triage          3 Agents(worktree) DONE — docs/plans/2026-08-17-T2-triage-report.md
[x] T5 close leak      inline + CLAUDE.md rule DONE — channel quiet since 2026-08-16T19:00
[x] P1 port elm-cem gap        Agent(worktree, sonnet) DONE — commit 7def25a
[x] P2 port elm-review-cem gaps Agent(worktree, sonnet) DONE — commit ccc8eb1
[x] P3 port elm-m3e demo-app   Agent(worktree, opus)   DONE — 4 commits, dc59df4..14fb811
[ ] T3 publish path     queued — decide whether/when to actually push to jackhp95/*
[ ] T4 drift gate       queued  (blocked on T3)
[ ] T6 docs             queued  (small, blocked on T3 so it can name the real command)
```

All three porting worktrees (`worktree-agent-ae7edec1f9d560490`,
`worktree-agent-ab7d89ef2df032037`, `worktree-agent-a6beaf773530d2bfe`) have
committed, verified work sitting locally, unmerged into `main`. Merge these
before T3 — T3's first real publish should reflect a fully-reconciled state.

## T1 findings (done — ran inline, all read-only `gh api`/`git log` lookups, r0)

Re-checked all 9 repos for commits since the 2026-08-12 baseline, not just the
5 sampled during the initial investigation. Real picture is narrower and
deeper than first thought:

- **`m3e-okf`, `tailwind-m3e-web`: 0 post-baseline commits.** Genuinely inert,
  as designed. No action needed.
- **`elm-html-intermediate-representation`, `cem-figma-connect`: 1–2 trivial
  commits** (version-bump, post-merge status refresh) right at the baseline
  boundary. Not real drift.
- **`elm-typed-html`: 1 commit** (`c1c2fd6f`, lazy1..8 signature fix). Diffed
  it against the workspace's current `packages/elm-typed-html/src/TypedHtml.elm`
  — **the workspace already has the equivalent fix** (same
  `Element accepts admittedBy msg` signature via `HtmlIr.Element.lazyN`), just
  written point-free instead of with explicit args, and missing the standalone
  commit's extra doc-comment about `lazy8` not memoizing. This commit is a
  **manual resync FROM the workspace TO the standalone repo**, done by hand,
  imperfectly — not independent work that needs porting back.
- **`elm-cem-facts`: 1 commit**, message says it outright: `"sync: force-sync
  from elm-cem-workspace canonical copy"`. Same pattern — manual, ad hoc,
  one-way, workspace → standalone.
- **`elm-cem` (25 commits), `elm-review-cem` (27 commits), `elm-m3e` (30
  commits): real, substantial, ongoing parallel development**, 2026-08-12
  through 2026-08-16, converging on a **"4-package" shape** (commit messages:
  "reconcile(4pkg)", "4-package elm-m3e over main-line", batch1/2/3 style,
  their own internal "reconcile prior main-line as ancestor" merges — this
  reads as an independent gauntlet-style loop operating directly against
  these three standalone repos as its own project, unaware of the workspace).
  Meanwhile GAUNTLET-LEDGER shows the **workspace's own parallel line landed a
  "5-package split" (D-037, M8.b)**, explicitly built by transforming
  "main's 4-package shape" — i.e. the workspace *knew about* this 4-package
  line at one point and diverged past it, without ever publishing the result
  back out.

**Root cause:** none of the paseo-tracked worktrees for this project (checked
`list_workspaces` — all 4 active worktrees under this project have
`origin = elm-cem-workspace`) point at the standalone repos, and no local
checkout of them exists on this machine. So the parallel elm-cem /
elm-review-cem / elm-m3e work happened through an **untracked channel** — a
separate Claude Code session/workflow (commit author is Jack's own git
identity, so likely Jack-initiated, possibly on another machine) working
directly against those three standalone repos' checkouts, running its own
gauntlet-shaped loop, concurrently with and unaware of the workspace
consolidation. This matches Jack's own framing: separate recent agent
conversations told him these were "completely split" — they were, briefly,
correct about that specific channel, even though the design intent (and the
migration tooling) said otherwise.

**Given Jack's ruling that the monorepo is canonical:** the standalone repos'
4-package line is presumptively superseded by the workspace's 5-package split
— but T2 must still check each of the ~55 commits in `elm-cem` /
`elm-review-cem` / `elm-m3e` for real fixes (not just shape changes) that the
workspace's independent evolution might have missed, before writing the whole
line off.

## Tasks

### T2 — Triage the orphaned commits (work; suggested tier: sonnet/medium)

For each standalone-only commit found in T1, diff it against the
corresponding workspace file(s). Classify each as: (a) already superseded by
larger workspace restructuring — record as superseded, no action; (b) a real
fix workspace is missing — port it in as a workspace commit with a note
citing the origin SHA; (c) unclear — flag for Jack.

### T3 — Build the publish path (work; suggested tier: opus/medium — touches
publish tooling shape, worth the extra care)

Add a `tools/publish-<name>.sh` (or one parameterized script) per family repo
that pushes `packages/<name>`'s current tracked tree to `jackhp95/<name>` as a
new commit on `main`, preserving the repo's own internal layout (already
verified byte-identical at migration time by `copy-fidelity-*`). Dry-run mode
default; require explicit confirmation/flag to actually push, per the global
policy on actions visible to others.

### T4 — Drift gate (work; suggested tier: sonnet/medium)

Extend `tools/check-drift.mjs` (or a new `tools/check-mirror-drift.mjs`) to
compare each standalone repo's live HEAD SHA (via `gh api`) against the SHA
the workspace last published. Wire into `tools/gate-all.mjs` or a scheduled
job. Fails loud, names the repo and the offending SHA.

### T5 — Close the root-cause routing gap (work; suggested tier: matches
whatever surface T1 identifies — likely a skill/CLAUDE.md edit, sonnet/low)

Whatever T1 finds (e.g., an agent defaulting to `gh repo clone jackhp95/X`
instead of `cd packages/X`), fix at the source: skill instructions, a
CLAUDE.md project rule, or a paseo routing default. Add a one-line rule to
`/Users/jack/Documents/code/CLAUDE.md` if the fix is workspace-wide.

### T6 — Docs (work; suggested tier: haiku/low)

Update VISION.md's family table and README.md with an explicit "mirror,
read-only, do not commit here" statement per repo, and a pointer to the
publish command from T3.

### Verify (verify role; suggested tier: opus/medium)

- Re-run the `gh api repos/jackhp95/<name>/commits` check from this
  investigation for all 9 repos — confirm no standalone-only commits remain
  unaccounted for.
- Dry-run the T3 publish path against one low-risk repo (e.g. `m3e-okf`,
  least active) and diff the would-be mirror commit against the current
  workspace tree by hand before ever pushing for real.
- Confirm T4's drift gate actually fails when pointed at a deliberately
  stale fixture.

### Manage (manage role)

Record decisions/deviations in GAUNTLET-LEDGER.md following existing
decision-log conventions (D-0xx numbering, continue the sequence in use).
