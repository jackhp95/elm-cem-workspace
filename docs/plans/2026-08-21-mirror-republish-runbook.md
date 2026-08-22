# Runbook: republishing `jackhp95/elm-m3e` (mirror-lag closeout)

Status: investigation complete, **no publish action taken**. This is a
recommendation/runbook for Jack to execute (or approve an agent executing)
when ready. Task 2 of 6 independent follow-ups from the 2026-08-21/22
reconciliation work.

## 1. Why this exists

`jackhp95/elm-m3e` is the standalone read-only mirror of the workspace's
`brands/m3e/generated/package/elm-m3e` monolith package (the
monorepo-canonical / standalone-repos-are-read-only-mirrors model from
`docs/plans/2026-08-17-standalone-repo-realignment.md`). It is now **three
rounds of rename/reshape behind** the workspace:

1. **Explosion Task 2 (2026-08-20):** `elm-m3e-icons/` and
   `elm-m3e-families/` (later `elm-m3e-components/`) promoted from nested
   subdirectories of the `elm-m3e` package to committed sibling packages
   under `brands/m3e/generated/package/`.
2. **Namespace rename (reconciliation Task 7, 2026-08-21):** element-tier
   modules renamed `M3e.Component.*` → `M3e.Element.*`
   (`src/M3e/Component/*` → `src/M3e/Element/*`), and family modules renamed
   `M3e.Family.*` → `M3e.Component.*`.
3. **DAG rework (2026-08-22):** `Build` materialization moved out of the
   monolith's flat `src/M3e/Build/*` into a separate `elm-m3e-build`
   family-generated sibling package (linear `Build → Components → Elements →
   Core` DAG).

`docs/plans/2026-08-20-reconciliation-plan.md` Task 10.6 explicitly defers
this as a post-reconciliation follow-on ("the residual OQ-3 (mirror
republish) follow-on (now more overdue — the namespace rename shifts the
mirror further from the published snapshot)").

## 2. Current drift state (re-verified 2026-08-21)

### 2a. No drift *from outside* the tooling

`node tools/check-mirror-drift.mjs` (read-only — confirmed from source: its
only network call is `execFileAsync("gh", ["api",
"repos/jackhp95/${name}/commits/main", "--jq", ".sha"])`, a GET, no mutating
calls anywhere in the file) was re-run and shows:

```
OK    elm-cem — matches last publish (2eb4601b)
OK    elm-m3e — matches last publish (1ef3246a)
OK    elm-cem-facts — matches last publish (592c00fd)
OK    elm-review-cem — matches last publish (b25fc293)
OK    elm-typed-html — matches last publish (5a9f4612)
OK    elm-html-intermediate-representation — matches last publish (b771a38d)
OK    elm-cem-compose — matches last publish (b6cf6187)
```

`elm-m3e`'s live GitHub `main` is exactly what `tools/publish-mirror-state.json`
recorded: mirror commit `1ef3246afa1345418acb69f3330251ec0abca201`, published
`2026-08-19T05:38:20.766Z` from workspace sha `45bb6b3079ae4c48cdbd61a449d47825e14c6f08`
(`chore(elm-m3e/docs): resync dist with stable rebuild output before mirror
publish`). Nobody has force-pushed to the mirror directly since then — the
drift is entirely legitimate, tooling-mediated lag, not an out-of-band fork.

### 2b. Drift *from* the workspace (the real gap)

`tools/family.json`'s `elm-m3e` entry documents every gap in detail. Quoted
verbatim (current line numbers as of this investigation — re-grep if they've
moved):

**`authorizedAbsentPrefixes` (family.json line 54) and its note (line 55):**

```
"authorizedAbsentPrefixes": ["elm-m3e-icons/", "elm-m3e-components/", "elm-m3e-families/", "src/M3e/Component/", "src/M3e/Build/"],
"$authorizedAbsentPrefixesNote": "MIRROR-LAG (explosion Task 2, 2026-08-20): the pinned jackhp95/elm-m3e snapshot still carries elm-m3e-icons/ (and the pre-Task-1 elm-m3e-families/) NESTED under the package, but Task 2 promoted them to committed SIBLINGS under brands/m3e/generated/package/ (elm-m3e-icons/, elm-m3e-components/) — outside elm-m3e's srcDir. So the nested copies are legitimately absent from the workspace tree until the mirror is republished post-reshape (OQ-6). Same wave-1 tailwind/cfc mirror-lag pattern (see the elm-cem-figma-connect $mirrorLagNote). Remove these prefixes once jackhp95/elm-m3e is republished with the new sibling shape. (elm-m3e-components/ + elm-m3e-families/ are belt-and-suspenders: the current snapshot lacks them, but a re-pin between Task 1 and republish could carry either the old -families or the mid-move nested -components name.) NAMESPACE-RENAME MIRROR-LAG (reconciliation Task 7, 2026-08-21): the pinned mirror still emits the element-tier modules under the OLD `src/M3e/Component/*` namespace; Task 7 renamed them to `src/M3e/Element/*` (Component→Element) and family modules `M3e.Family.*`→`M3e.Component.*`. The 130 old `src/M3e/Component/*` files are legitimately absent until the mirror is republished post-rename (OQ-3/OQ-6). Remove `src/M3e/Component/` once jackhp95/elm-m3e is republished with the new namespaces. DAG-REWORK MIRROR-LAG (2026-08-22): Build materialization moved from the monolith's flat `src/M3e/Build/*` into the separate `elm-m3e-build` family-generated sibling package (linear `Build->Components->Elements->Core` DAG). The 131 old `src/M3e/Build/*` files under the monolith are legitimately absent until the mirror is republished post-DAG-rework (OQ-3/OQ-6). Remove `src/M3e/Build/` once jackhp95/elm-m3e is republished with the new package shape."
```

**`authorizedExtraPrefixes` (family.json line 90) and its note (line 91):**

```
"authorizedExtraPrefixes": ["elm-m3e-components/", "src/M3e/Element/"],
"$authorizedExtraPrefixesNote": "NAMESPACE-RENAME MIRROR-LAG (reconciliation Task 7, 2026-08-21): the workspace now emits the element-tier modules under the NEW `src/M3e/Element/*` namespace (Component→Element), but the pinned jackhp95/elm-m3e mirror snapshot still has them under the old `src/M3e/Component/*` path. The 130 new `src/M3e/Element/*` files are legitimately extra until the mirror is republished post-rename (OQ-3/OQ-6). Pairs with the `src/M3e/Component/` entry in authorizedAbsentPrefixes. Remove `src/M3e/Element/` once jackhp95/elm-m3e is republished with the new namespaces."
```

There is also an exact-match entry (not a prefix) at line 24,
`"src/M3e/Build.elm"`, inside the plain `authorizedAbsent` array (lines
17–25) — the Build barrel module, same DAG-rework cause as `src/M3e/Build/`,
but it has **no dedicated inline note** explaining it (a small documentation
gap; see §4 below for the cleanup recommendation).

### 2c. Concrete dry-run evidence (this investigation)

`node tools/publish-mirror.mjs elm-m3e` (no `--push` — see §3 for why this is
safe) was run for real. It cloned `jackhp95/elm-m3e` fresh into
`.cache/publish-mirror/elm-m3e`, staged the workspace's current tracked
`brands/m3e/generated/package/elm-m3e` tree over it, and reported:

```
=== Dry-run diff: what would be pushed to jackhp95/elm-m3e ===
...
1115 files changed, 10164 insertions(+), 202496 deletions(-)

Dry run only — nothing pushed. Re-run with --push --yes-i-am-sure to
actually commit and push this to jackhp95/elm-m3e's main branch.
(Clone left at .../.cache/publish-mirror/elm-m3e for inspection.)
```
Exit code: `0`.

Breaking that diff down against the three lag causes above (counts taken
directly from the diff, and cross-checked against `git ls-tree -r HEAD` on
the untouched mirror clone before the script overwrote its working tree):

- **Namespace rename:** mirror HEAD has exactly 130 files under
  `src/M3e/Component/`; workspace has exactly 130 under `src/M3e/Element/`.
  Git's rename detection catches 104 of these as `{Component => Element}`
  renames in the diff (e.g. `src/M3e/{Component => Element}/Accordion.elm`);
  the other 26 are similar-but-below-threshold and show as a straight
  add/delete pair.
- **DAG rework:** mirror HEAD has exactly 131 files under `src/M3e/Build`
  (130 in `src/M3e/Build/` + the `src/M3e/Build.elm` barrel) — all shown as
  pure deletions, since the workspace's `elm-m3e` srcDir no longer contains
  any `Build` files at all (moved to the separate `elm-m3e-build` package,
  132 `.elm` files, confirmed via `find
  brands/m3e/generated/package/elm-m3e-build/src -name '*.elm' | wc -l`).
- **Explosion Task 2 lag:** the mirror still nests `elm-m3e-families/` and
  `elm-m3e-icons/` (e.g. `elm-m3e-families/README.md`,
  `elm-m3e-icons/README.md` both show as deletions) — both are now
  independent top-level sibling packages in the workspace
  (`brands/m3e/generated/package/elm-m3e-{icons,components,core,elements,
  build,facts}/`), outside `elm-m3e`'s own `srcDir`, so they correctly do
  not reappear as additions in this package's diff.
- **Docs extraction (repo-shape-v2 wave-1, decision #9):** roughly 585 of
  the diff's lines touch `docs/**` — the docs site was extracted out of the
  `elm-m3e` package into its own sibling package
  (`brands/m3e/generated/docs/elm-m3e-docs`, no independent mirror yet) and
  the mirror still carries the old in-package `docs/` tree wholesale. This is
  already excluded from the **copy-fidelity** comparison
  (`sourceFilterExcludePrefixes: ["docs/"]`, family.json line 15) but is
  *not* excluded from what `publish-mirror.mjs` actually pushes — a real
  publish removes this entire old `docs/` tree from the mirror, matching the
  workspace's current shape (docs already lives elsewhere).
- Also present: a new `PACKAGES-MOVED.md` (86 lines, explains the sibling
  split to anyone landing on the mirror), an updated `README.md` (+11), and
  a `config` symlink/file update (2 lines) — all expected, unremarkable
  churn from the same 2026-08-19 → now window.

## 3. Safety confirmation: why the dry-run was safe to actually execute

Read `tools/publish-mirror.mjs` in full (383 lines) before running anything.
Confirmed from source:

- **Dry-run is the default control path.** `main()` only reaches the
  `commit`/`push`/`ls-remote` calls (lines 336–351) if `push && yes` — i.e.
  both `--push` and `--yes-i-am-sure` are present on argv. Without `--push`,
  the function hits `if (!push) { ...; process.exit(0); }` (lines 319–326)
  and returns before any commit or push line is reached.
- **The gate precondition only runs on a real push.** `assertGateAllPasses()`
  is only called from `if (push && yes) assertGateAllPasses();` (line 234) —
  a plain dry-run does not invoke `gate-all.mjs` at all, so it can't be
  "blocked" or "unblocked" by gate state; it's unconditionally safe to run
  regardless of gate status.
- **The only writes are inside a disposable local cache clone.** All
  `git -C cloneDir` operations (fetch/reset --hard/clean -fdx/add -A/commit)
  target `.cache/publish-mirror/elm-m3e`, a scratch clone under the
  workspace's own `.cache/` (gitignored), never the workspace repo itself.
  The only read against the *live* remote in a dry run is the initial
  `git clone --depth 1` / `git fetch origin main` + `reset --hard
  origin/main` — both non-mutating reads of `jackhp95/elm-m3e`.
- **State file (`tools/publish-mirror-state.json`) is untouched on a
  dry-run.** `recordPublish()` (and thus `commitAndPushStateFile()`, which
  is the only thing in this file that pushes to *this* workspace repo's own
  `origin`) is only called after a successful real push (line 356), never
  on the dry-run path.

Ran it (`node tools/publish-mirror.mjs elm-m3e`, no flags) — exit code 0,
output as quoted in §2c, `git status --porcelain` on the workspace afterward
shows only the new (gitignored) `.cache/` directory, no tracked-file
changes. No network-mutating call was made anywhere in this investigation.

## 4. Step-by-step republish procedure

### 4.0 Preconditions

- [ ] `gh auth status` shows an authenticated session with push access to
      `jackhp95/elm-m3e`.
- [ ] `git config user.name` = `JackHP95`, `git config user.email` =
      `git@jackhpeterson.com` (identity guard — same as any mutating step in
      this workspace).
- [ ] Run from a clean worktree on a branch that is safe to have
      `tools/publish-mirror-state.json` auto-committed+pushed to (see §3's
      note on `commitAndPushStateFile` — it pushes `HEAD:<current-branch>`
      to *this* workspace's own `origin`, not just the mirror). Do this from
      `main` (or a branch about to merge to `main`), not a throwaway agent
      worktree, so that record lands where `check-mirror-drift.mjs` expects
      it on the branch everyone actually reads.

### 4.1 Dry run (repeat this any time, it's free)

```
node tools/publish-mirror.mjs elm-m3e
```

Review the `=== Dry-run diff ===` stat output. Confirm it matches
expectations: the namespace-rename renames, the `src/M3e/Build*` deletions,
the old nested `elm-m3e-families/`/`elm-m3e-icons/` deletions, and the old
in-package `docs/` tree deletions — and nothing unexpected (e.g. an
accidental deletion of a file that should still exist, which would indicate
`cfg.srcDir`'s tracked set is wrong, not that the mirror is behind).

### 4.2 Gate precondition

```
node tools/gate-all.mjs
```

This **must pass** before a real publish (enforced automatically by
`publish-mirror.mjs` itself when `--push --yes-i-am-sure` is passed, unless
`SKIP_GATE=1` is set — not recommended, see the file's own comment on the
2026-08-12→17 mirror-fork incident this precondition was added to prevent).

**Current status (2026-08-21, from `/tmp/baseline-gate-all-2.log`, a full
run completed today in the sibling reconciliation worktree
`/Users/jack/.paseo/worktrees/3ov4grvm/gauntlet-follow-ups`): gate-all is
RED.** Tail:

```
61/64 passed, 1 skipped, 2 failed
...
FAILED ITEMS:
  - elm-cem-figma-connect: check  (exit code 1)
  - elm-cem-figma-connect: test  (exit code 1)

GATE-ALL RED
EXIT:1
```

The 2 failures are both in `elm-cem-figma-connect`, unrelated to `elm-m3e` —
every `elm-m3e*` step in that run passed (`elm-m3e: check`,
`elm-m3e-{build,components,core,elements,facts,icons,okf,tailwind}: check`,
`verify-split (elm-m3e 5-package registry-faithfulness)`,
`ab-elm-m3e-split (split-step byte-identity)`, `copy-fidelity elm-m3e`,
`check-mirror-drift`, `check-package-dag`, `check-m3e-5pkg`, etc. all PASS).
So **the `elm-m3e` publish is itself ready**; the blocker is a fully
independent `elm-cem-figma-connect` red that must be fixed (or a fresh
gate-all re-run must come back green) before a real `--push` can proceed
without `SKIP_GATE=1`.

### 4.3 The real publish — **JACK MUST EXPLICITLY APPROVE THIS STEP**

This pushes to a public, external GitHub repository
(`https://github.com/jackhp95/elm-m3e.git` main branch) and is
hard-to-reverse (force-push/history-rewrite would be needed to undo it, and
anyone who has already cloned or depends on the mirror sees the new state
immediately). **Do not run this without Jack's explicit sign-off, given
per-invocation, immediately before running it — not a standing
pre-approval.**

```
node tools/publish-mirror.mjs elm-m3e --push --yes-i-am-sure
```

On success this: commits the new tree to the local
`.cache/publish-mirror/elm-m3e` clone, pushes it to
`jackhp95/elm-m3e`'s `main`, verifies via `git ls-remote` that GitHub's
live `main` actually matches what was just pushed (fails loudly instead of
recording a false record if not), and then durably commits + pushes an
updated `tools/publish-mirror-state.json` entry to *this* workspace's own
`origin` (same-run, synchronous — see the file's own comment on why: prior
manual "backfilled" records existed because nothing durably recorded state
before this).

### 4.4 Post-publish verification

```
node tools/check-mirror-drift.mjs
```

Expect `OK    elm-m3e — matches last publish (<new short sha>)`.

## 5. `tools/family.json` cleanup — do this AFTER a successful republish

Once `elm-m3e` is republished and `tools/fetch-snapshots.mjs` has re-pinned
`.cache/snapshots/elm-m3e` against the new mirror HEAD (re-run
`node tools/gate-all.mjs` once, or `node tools/fetch-snapshots.mjs`
directly, to force the re-pin), **every** lag-driven allowlist entry for
`elm-m3e` becomes stale simultaneously, because all three lag causes
(explosion Task 2, namespace rename, DAG rework) are cleared by the same
republish:

- **Remove from `authorizedAbsentPrefixes`** (family.json line 54): all
  five entries — `"elm-m3e-icons/"`, `"elm-m3e-components/"`,
  `"elm-m3e-families/"`, `"src/M3e/Component/"`, `"src/M3e/Build/"`. The
  array should become empty (`[]`), or the whole key can be dropped if
  `tools/copy-fidelity.mjs` treats a missing key as "no allowance" (verify
  this behavior in `tools/copy-fidelity.mjs` before dropping the key
  outright — safer to leave `[]` explicit if unsure).
- **Remove from `authorizedExtraPrefixes`** (family.json line 90): both
  entries — `"elm-m3e-components/"`, `"src/M3e/Element/"`. Same
  empty-array-vs-drop-key caveat applies.
- **Delete both `$authorizedAbsentPrefixesNote` (line 55) and
  `$authorizedExtraPrefixesNote` (line 91)** once their corresponding arrays
  are empty — they exist purely to explain non-obvious allowlist entries;
  with nothing left to explain, they become dead prose the next reader has
  to work through for no reason.
- **Also review the exact-match `"src/M3e/Build.elm"` entry** in the plain
  `authorizedAbsent` array (line 24) — it has no dedicated note today (a
  pre-existing documentation gap, not something this investigation
  introduced), but it is clearly the DAG-rework's Build-barrel counterpart
  to `src/M3e/Build/` and should be removed in the same pass. Confirm with
  a post-republish `copy-fidelity elm-m3e` run that removing it doesn't
  reintroduce a false-positive "missing" flag (it shouldn't — the republish
  deletes the mirror's `src/M3e/Build.elm` too, since it's inside `srcDir`
  and was part of the diff in §2c).
- Leave the `$sourceFilterNote` / `sourceFilterExcludePrefixes: ["docs/"]`
  (lines 15–16) **alone** — that exclusion is about `docs/` having
  permanently left the `elm-m3e` package (repo-shape-v2 decision #9), not
  about mirror-publish timing; it stays authorized-absent-by-design even
  after republish, per its own note ("Narrow this back to a
  package-internal `docs/` path only if `docs` ever returns to the elm-m3e
  package").
- After the edit, re-run `node tools/copy-fidelity.mjs elm-m3e` (or the
  relevant `gate-all` step) to confirm it still passes cleanly with the
  now-empty allowlists — a clean pass with `[]` is the actual proof the
  cleanup was correct, not just plausible.

## 6. Recommendation: when to do this

**Recommendation: do it the next time `gate-all` is green, rather than
bundling it with another mirror-affecting change.**

Reasoning:

- The gap is already compounding (three separate causes stacked since
  2026-08-19) and `docs/plans/2026-08-20-reconciliation-plan.md` Task 10.6
  flagged it as "now more overdue." Waiting for a fourth cause to land
  before republishing only makes the eventual diff bigger and the
  family.json cleanup step riskier (more allowlist entries to reconcile at
  once, more chance of missing one).
- The republish itself is fully mechanical and low-risk *given a green
  gate*: `publish-mirror.mjs` already enforces gate-all as a hard
  precondition, verifies the push landed via `ls-remote` before recording
  state, and the dry-run in §2c shows no surprises — the diff is exactly the
  three documented lag causes plus expected small churn (README, new
  PACKAGES-MOVED.md).
- There is no reason to *couple* it to a specific upcoming change: the
  `elm-cem-figma-connect` red currently blocking gate-all (§4.2) is
  unrelated to `elm-m3e` and will presumably be fixed independently as its
  own follow-up; once gate-all goes green for *any* reason, this republish
  should ride that same green window rather than waiting for a
  purpose-built "mirror publish" change.
- Counter-consideration (why not "immediately, ignore the gate"): the gate
  precondition exists specifically because of a prior incident
  (2026-08-12→17 mirror-fork, referenced in the script's own comments) where
  a red/stale tree got published without anyone noticing. Respecting that
  precondition here — rather than reaching for `SKIP_GATE=1` — is the
  correct call even though the `elm-m3e`-specific gates are all green today;
  the whole point of the gate is that a public mirror publish is treated as
  a workspace-wide event, not a per-package one.

## 7. What was and was not done in this investigation

- Read `tools/publish-mirror.mjs` in full (383 lines) and confirmed its
  dry-run path is non-mutating from source before running it.
- Read `tools/check-mirror-drift.mjs` in full (94 lines) and confirmed it
  is read-only (single `gh api .../commits/main` GET) before running it.
- Ran `node tools/check-mirror-drift.mjs` — real output captured in §2a.
- Ran `node tools/publish-mirror.mjs elm-m3e` (no `--push`) — real dry-run
  diff captured in §2c. This cloned `jackhp95/elm-m3e` (read-only clone) into
  `.cache/publish-mirror/elm-m3e` for local inspection; nothing was pushed.
- Read the current `tools/family.json` `elm-m3e` block verbatim (quoted in
  §2b) and cross-checked its claims (130/130/131 file counts, sibling
  package existence) directly against the mirror clone's `git ls-tree` and
  the workspace's tracked tree.
- Read `/tmp/baseline-gate-all-2.log` (a gate-all run completed earlier
  today in the sibling reconciliation worktree) to determine gate-all's
  current pass/fail state (§4.2) rather than re-running the full gate here.
- **Did not** run `node tools/publish-mirror.mjs elm-m3e --push
  --yes-i-am-sure` or any other network-mutating command against
  `jackhp95/elm-m3e`. No external publish action was taken.
- **Did not** edit `tools/family.json` — the cleanup in §5 is a
  post-republish step, out of order to do now (the allowlist entries are
  still accurate today; removing them before republishing would just break
  `copy-fidelity elm-m3e`).
