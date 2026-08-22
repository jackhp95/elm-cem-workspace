# Handoff: reconcile 3 gauntlet-executed plan branches into main

**Purpose:** compact handoff for a fresh execution pass. Everything needed to finish is here; do not
assume prior conversation context survives — re-verify every claim below against the live repo before
acting on it, same discipline every subagent this session was held to.

**Goal (Jack's words):** "I only want main by the time we're done." Merge all real work into `main`,
push, then delete every other branch/worktree. End state: exactly one branch, `main`.

---

## 0. Where things stand right now

`main` is at `8094b504` (the m3e/html package-explosion reconciliation, already merged+pushed earlier
today — that work is DONE and not part of this handoff's scope).

Three sibling branches, each a fully-executed gauntlet plan, each verified green **on its own branch**,
none merged to `main` yet, none pushed:

| branch | worktree | tip commit | own gate-all |
|---|---|---|---|
| `docs/svg-api-audit-plan` | `/Users/jack/.paseo/worktrees/3ov4grvm/plan-svg-audit` | `f2ae0e93` | 57/58 GREEN |
| `docs/dag-rework-plan` | `/Users/jack/.paseo/worktrees/3ov4grvm/plan-dag-rework` | `e2170518` | 61/63, 2 known-reserved reds |
| `docs/families-a11y-composition-plan` | `/Users/jack/.paseo/worktrees/3ov4grvm/plan-families-a11y` | `94766b2a` | 55/57, 1 known cross-branch red |

Commit lists (oldest→newest), for reference — do not re-derive, but do `git log` to confirm these are
still accurate before merging:

```
svg-api-audit-plan:      f6f3bf29 a536d905 444c7d42 583474f7 953e82fb 82e840fd f2ae0e93
dag-rework-plan:         e89659d4 704ea440 26ad8893 13235819 6c41f9dc 0aea849e 3df737ea
                         45f28d31 96916b29 e74c932f e2170518
families-a11y-...-plan:  dcc651b6 149e64bc 7721dd6c 40b4d478 2a1b332d 6213de8b 718d44d1
                         fdcc659b b30d11d8 7c3e0184 94766b2a
```

## 1. What each branch actually did (one line each — read the branch's own commits for detail, don't
re-derive from memory)

- **svg-api-audit-plan**: audited `elm-typed-svg` against the real W3C SVG-2 spec (69 elements,
  live-verified — the plan doc's own claim of 74 was wrong). Landed all fix-now items: 6→30 typed
  enums, `foreignObject`/`view`/`metadata`, and the **full 26-element filter family** (nothing
  deferred). Shipped a permanent `check-svg-spec-coverage.mjs` gate, mutation-tested both directions.
  SMIL animation and `xlink:` stay explicitly out-of-scope (documented exceptions, not gaps).

- **dag-rework-plan**: fixed the real bug found in `2026-08-21-dag-rework-plan.md` — m3e's `Build` and
  `Components` tiers were parallel siblings on `Elements`, not chained. Re-architected to the linear
  `IR → Core → Elements → Components → Build`. Jack's resolved decision: **both**
  `M3e.Build.<Element>` and `M3e.Build.<Family>` are permanently exported — the per-element names are
  thin re-exports over the one real Components-driven implementation (not a deprecation shim). As a
  necessary side effect, **shoelace was split from a monolith into 5 real sibling packages**
  (`elm-shoelace-{core,elements,components,build,facts}`) because the DAG rework's new degenerate
  façades pushed its `docs.json` over the 700KB cap — this was escalated to its own dedicated task,
  not folded in as an afterthought. Face-A generator bundle re-baselined at the end (this branch's own
  bundle only reflects THIS branch's emitter changes, not the other two branches').

- **families-a11y-composition-plan**: gave `html`, `shoelace`, `svg` real composition validity for the
  first time (previously: `shoelace` had `slotKinds=[]` for all 58 elements; `html` had a live bug
  where its own `phrasing` set admitted a `button` inside a `button`). Added a new `!@set`/`!kind`
  admits-subtraction config primitive (shared-emitter change #1) and, after discovering the
  subtraction collaterally broke benign nesting like `button > span` (both shared a collapsed
  `shared:phrasing` field), split that into a distinct `shared:interactive` atom (shared-emitter
  change #2). Authored real `admits` data for all three brands (html: WHATWG content model; shoelace:
  an ARIA role-map, `roles.json`, deriving admittance from the ARIA required-owned/required-context
  tables; svg: the SVG-audit's own `spec-index.json` as source of truth). Shipped a new generic
  `Cem.ValidComposition` elm-review rule (arbitrary-depth interactive nesting + label rules = **hard
  fail**; ARIA required-context + SVG-AAM role overlay = **warn** — Jack's resolved posture decision).
  Face-A bundle re-baselined at the end (same caveat as above — only reflects this branch's changes).

## 2. The real cross-branch overlaps (verified via `git diff --name-only main <branch>`, not guessed)

This is the part that matters most for the reconciliation — a blind 3-way `git merge` will hit these:

1. **`tools/gate-all.mjs` + `tools/gate-all-expected-steps.json`** — touched by **dag-rework** (added
   `check-package-dag` step) AND **svg-audit** (added `check-svg-spec-coverage` step, tool-test count
   12→13). `families` does NOT touch these (its rule rides inside existing check/test steps — verified
   in that branch's own Task 7 report). **2-way conflict, must combine both additions.**

2. **`brands/svg/inputs/config.json`** (+ 3 generated svg files: `TypedSvg.elm`, `Structure.elm`,
   `Review/Facts.elm`) — touched by BOTH **svg-audit** (new enums/elements/filters) AND **families**
   (admits data on containers). **2-way conflict on the same file** — different keys/sections in
   principle, verify the merge is actually clean rather than assuming it.

3. **`brands/shoelace/**` generated output** — **dag-rework** did a real structural split (monolith →
   `elm-shoelace-{core,elements,components,build,facts}`); **families** added `admits`/`roles.json`
   data and regenerated against the OLD MONOLITH shape (that branch never received the split — it was
   split on a different worktree/branch, deliberately not re-applied there per that task's own explicit
   decision to avoid this exact conflict). **This is a structural conflict, not a textual one** — do
   NOT try to git-merge the generated directories. The `admits`/`roles.json`/CEM-input changes
   (`brands/shoelace/inputs/**`) are the valuable, mergeable content; the generated `brands/shoelace/
   generated/**` output must be DISCARDED and regenerated fresh from the combined inputs, split-shaped,
   after the input-level merge is done (same "regenerate, never lift" principle as this morning's Side
   A/Side B reconciliation).

4. **Face-A bundle** (`tools/snapshots/elm-cem-generator.bundle` + `tools/snapshot-refs.json`) —
   touched by **dag-rework** AND **families** (each re-baselined from their OWN tip, so neither's
   bundle is correct once combined). **svg-audit does NOT touch this** (no shared-emitter change on
   that branch). Do not attempt to merge the binary bundle — re-baseline ONCE, at the very end, after
   all three branches' emitter changes are combined and everything else is green.

5. **`pipeline/elm-cem/codegen/Generate/Phantom/`** — verified **NO file-level overlap** between
   dag-rework (touched `Emit.elm`, `Component.elm`, `General.elm`, new `BuildPackage.elm`) and families
   (touched only `Model.elm`). svg-audit touches none of these files (confirmed in its own final
   report: "no shared-emitter change was required"). This is good news — the actual emitter logic
   changes should merge cleanly without semantic conflict, only the two overlap classes above need
   real reconciliation work.

## 3. Recommended reconciliation strategy

Mirrors this morning's Side A/Side B reconciliation principle: **merge config/source, regenerate
output, never textually merge generated code.**

1. **Baseline check.** Confirm `main` is still at `8094b504`, `git fetch`, confirm nothing new landed
   there since this handoff was written.

2. **Pick a merge order that front-loads the least-entangled branch.** Recommended:
   `svg-api-audit-plan` → `dag-rework-plan` → `families-a11y-composition-plan`. Rationale: svg-audit
   only really conflicts with families (not dag-rework) on `brands/svg/inputs/config.json`; landing it
   first means when families merges last, it's the one branch resolving both of its real conflict
   points (svg config AND shoelace structure) in one pass, rather than spreading conflict-resolution
   across multiple merge steps out of order.

3. **For each merge:**
   - `git merge --no-ff <branch>` (or rebase if you prefer linear history — either is fine, no one has
     pushed any of these branches, so history rewriting is safe).
   - Resolve real conflicts per the map in §2 — for generated-file conflicts, take neither side
     wholesale; discard and regenerate after the merge.
   - After each merge, regenerate every brand the merge touched (`pnpm run gen` equivalent per
     package, or the workspace-level `gen` script if one exists) and run that brand's own `check`
     before moving to the next branch — catch drift early, don't let it compound across 3 merges.

4. **After all three are merged:**
   - Regenerate `brands/shoelace/**` fresh from the combined inputs (admits data + the 5-way split
     config) — confirm the split-shaped output now carries the families branch's admits data too.
   - Regenerate `brands/svg/**` fresh from the combined inputs (spec-audit's enums/elements/filters +
     families' admits) — confirm both sets of changes are present in the final generated tree.
   - Regenerate `tools/gate-all-expected-steps.json` fresh (`node tools/gate-all.mjs --list-steps-only`
     redirected to the file, per this session's own established pattern) so it carries BOTH new gate
     steps (`check-package-dag` + `check-svg-spec-coverage`).
   - Re-baseline the Face-A bundle ONCE from the fully-combined emitter (per
     `generator-change-d046-rebaseline` — `git archive HEAD:pipeline/elm-cem` → bundle → re-pin
     `snapshot-refs.json`, the exact mechanic every branch's own Task 8 already used — read any of
     their commits for the precise commands).
   - Identity guard before every commit: `git config user.name`/`user.email` must be `JackHP95`/
     `git@jackhpeterson.com`.

5. **Full `GATE_ALL_CONCURRENCY=1 node tools/gate-all.mjs`.** Expect it to land fully green or with
   only pre-existing, well-understood chronic items (the okf `.cache/m3e` skip; possibly the mirror
   `copy-fidelity elm-m3e` red from the DAG rework's Build-module renames, which is a publish/mirror
   concern, not a code regression — verify this is still the only non-chronic red before declaring
   victory, don't assume it from this doc).

6. **Merge to `main`, push, then prune.** Fast-forward or merge-commit `main` to the reconciled tip
   (whichever the actual merge history supports), push. Then delete ALL of:
   - `docs/dag-rework-plan`, `docs/svg-api-audit-plan`, `docs/families-a11y-composition-plan` (branches
     + their worktrees: `plan-dag-rework`, `plan-svg-audit`, `plan-families-a11y`).
   - Any other stray branch/worktree found via `git branch --list` / `git worktree list` at that point
     — re-check fresh, don't trust this doc's branch list if time has passed and something else was
     created.
   - **End state: `git branch --list` shows only `main`. `git worktree list` shows only the primary
     checkout.**

## 4. Real findings worth carrying forward (not blockers, but don't lose them)

- **HTML architecture gap, already fixed**: the `shared:phrasing`/`shared:interactive` field split
  (families branch, commit `718d44d1`) — if for some reason this commit doesn't make it into the
  merge cleanly, re-check `button > span` still compiles; that was the regression it fixed.
- **Shoelace docs.json is tight even after the 5-way split** (~64% per tier at time of split). If
  future admits/composition data grows further, re-measure before assuming headroom.
- **Two elm-cem-figma-connect flakes and one m3e-icons regen-drift were found (and mostly fixed) during
  this whole session's gate-all runs** — a scheduler-order race in `gate-all`'s parallel dispatch for
  `elm-cem-figma-connect` was observed by THREE separate agents independently (always passes in
  isolation). Worth a dedicated gate-all determinism fix at some point — not blocking this
  reconciliation.
- **html's 5-tier future (Components + Builders) is now unblocked** by the DAG rework's
  brand-agnostic `BuildPackage.elm` (shoelace already rides it) but not delivered — recorded as its
  own follow-up (DAG plan's Task 9 hand-off note, FU-1).
- **`jackhp95/elm-m3e` mirror republish (OQ-3, from this morning's reconciliation) is now further
  behind** — the DAG rework renamed/added Build modules; the published mirror still has the old shape.
  Still unscheduled, still not a blocker.

## 5. Everything else you need is in the repo, not this doc

Full plan docs (read the actual branch's commits, not just this summary, for real implementation
detail): `docs/plans/2026-08-21-dag-rework-plan.md`, `docs/plans/2026-08-21-svg-api-spec-audit-plan.md`,
`docs/plans/2026-08-21-families-a11y-composition-plan.md` (each also has its own task-closeout
evidence docs committed alongside — check `docs/plans/2026-08-21-*-task*-*.md` for the detailed
per-task evidence trail if something needs deeper verification during conflict resolution).

Global policy (identity guard, worktree discipline, verify-don't-trust, friction logging) is unchanged
from the rest of this session — this handoff doesn't override any of it, it's a content summary, not
a new ruleset.
