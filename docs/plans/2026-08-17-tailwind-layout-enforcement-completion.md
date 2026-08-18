# Tailwind layout-only enforcement — completion

Branch `layout-only-styling`. Living plan doc; the task table is the source of truth
for what is in flight.

## Context

`NoProprietaryDsClasses` (`packages/elm-m3e/review/src/NoProprietaryDsClasses.elm`,
726 lines, 70 tests) already enforces layout-only Tailwind across the docs app,
which currently reports **zero violations** with no suppression file. Three gaps
remain, from the status report that preceded this plan.

## Task table

```
[x] L-A  centralization mechanism for Tailwind violations  — 8478c63 — done, verified
[x] L-B  m3e-* allow-list correctness (real manifest)      — 1464985 — done, verified
[x] L-D  T7 search-ranking fix, gate to green              — 3067852 — done, verified
[x] ---  regen derived review-config sample (L-A fallout)  — 02eb33e — done, verified
[x] L-V1 independent verify (Verify role)                   — see report below — done, L-A needs a small fix-up
```

## Done-gate evidence

Authoritative run: `node tools/gate-all.mjs > /tmp/gate8.log 2>&1` at `02eb33e`,
from a tree with no inherited servers (ports killed first), exit code captured
directly rather than through a pipe.

```
GATE_EXIT=0
GATE-ALL GREEN
PASS: 260   FAIL: 0   SKIP: 16
browser suite: 236 passed (2.7m)
```

The 16 SKIPs are all snapshot-dependent gates (`copy-fidelity-*`, `ab-elm-cem`,
`ab-elm-m3e-split`, `m3e-okf` drift) that skip-with-reason in a clone without
provisioned snapshots — pre-existing on this branch and unrelated to this work.

Per-leaf evidence:

| Leaf | Acceptance test | Result |
| --- | --- | --- |
| L-A | violation outside the seam caught, identical usage inside not flagged | 76/76 rule tests, 6 new fence cases |
| L-B | fake `m3e-*` caught, 2347 real ones pass, docs app still zero | 83/83 rule tests; `elm-review` "I found no errors!"; drift check negative-tested |
| L-D | `search.spec.ts` 36 / 150 / 215 pass | 8/8 search specs pass (was 5/8) |

## Process note — the miss worth recording

The first full-gate run after all three leaves came back RED on
`check:drift`: `docs/samples/review/src/CodegenReviewConfig.elm` is DERIVED from
the review config L-A edited, and I had verified L-A with elm-review, elm-format
and the rule's unit tests — everything local to the code I touched — but not the
generators that derive from it. Editing a file something else is extracted from
needs `check:drift`, not just the checks local to that file. Second instance of
this exact shape on this branch (the first was `Guide/Samples.elm` after
`Seams.elm` changed).

## L-A — decision record: ONE destination, named `Seam`

**The question:** reuse the Elm-component side's existing seam destination, or give
Tailwind its own parallel one?

**What I found first, which reframes the question:** there is no file to reuse.

- `find packages -name "Seam.elm"` → **nothing**.
- `NoSeamOutsideAllowedModules` is configured with `seamModules = [ "Recast" ]`, and
  `Recast.elm` **does not exist either** — recasts were driven to 0 in `c3fd2cf`, so
  nothing was ever centralized there.
- `ReviewConfig`'s prose claims the docs app centralizes crossings in "designated
  adapters (`Layout`, `Kit`, `Native`, `Doc`, `Shared`)". `Layout`, `Kit` and
  `Native` **do not exist**, and are not even in that rule's allow-list. Only
  `Doc.elm` and `Shared.elm` are real.

So both candidate destinations are *names in config*, not files. The real choice is
which name to standardize on.

**Decision: one shared destination, named `Seam`.** Reasons:

1. It is Jack's stated convention ("seam is the name of the centralized file unless
   otherwise specified").
2. Both kinds of escape have the same *shape and review purpose*: a small, named
   producer that contains a design-system escape so the escape is greppable and
   reviewable in one place. An `Element`-returning producer that internally recasts
   and one that internally applies a styling class are the same artifact to a
   reviewer.
3. Naming the Tailwind destination anything else would create a SECOND name while
   the first is still aspirational — the exact fragmentation this leaf exists to
   prevent.
4. `Recast` is the wrong name for the shared concept anyway: a Tailwind escape is
   not a recast. Renaming an empty, never-instantiated config name costs nothing.

**Consequently** `NoSeamOutsideAllowedModules`'s `seamModules` is renamed
`Recast` → `Seam`, so exactly one destination name exists across both fences.

**Deliberately NOT done: creating an empty `Seam.elm`.** The docs app has zero
styling violations and zero recasts, so the module would have no members. That is
the same argument used in `c3fd2cf` for not creating an empty `Recast` module — an
empty designated module is worse than none, because it invites use rather than
recording a real need. The *mechanism* is proven by the rule's own `Review.Test`
suite (violation outside the module is caught; identical usage inside is not),
which is exactly where a fence's behaviour should be pinned. The module gets
created by whoever first has a genuine, reviewed need.

**Also fixed here, not perpetuated:** `ReviewConfig`'s false prose about
`Layout`/`Kit`/`Native` being real adapters.

## L-B — decision record: manifest over prefix

The rule accepted any `m3e-*` class via `String.startsWith "m3e-"`, so
`m3e-totally-fake-thing` passed and would render nothing — the exact failure class
the rule was originally written to catch for `ds-`/`t-`. `tailwind-m3e-web` now
emits `generated/utilities.json` alongside `generated/utilities.css` at the same
generation moment, and the rule checks membership against it. Mirrors the
`M3e.Review.Facts` pattern already used by the codegen-aware rules.

## L-D — judgment call flagged for Jack

Search capped at 20 matches in raw index order with no relevance ranking, so
"button" returned 20 guide-prose hits and `/components/button` never surfaced — a
user could not reach a component page by typing its name.

**The ranking I chose** (lowest score wins), which Jack has NOT ruled on:

| Score | Rule | Example for "button" |
| --- | --- | --- |
| 0 | matched text IS the query | `button` |
| 1 | STARTS with the query | `Button < Components < elm-m3e` |
| 2 | a WORD in it starts with the query | `Filled Button`, `Icon button` |
| 3 | contains it anywhere | `M3e.Component.ButtonGroup` |

Ties break toward page-level entries (`heading = Nothing`) over headings inside a
page, then original index for stability.

**Why this shape:** page titles here are reverse breadcrumbs
(`Shared.breadcrumbTitle`), so a page *about* a thing starts with that thing's
name — score 1 surfaces the component page without needing a special-case
"boost reference pages" rule. That is a nicer property than URL- or
section-based boosting: it needs no list of privileged routes and stays correct
as pages are added.

**What Jack might want differently:** a URL-based boost (`/components/*` above
`/guide/*`) would be more aggressive and would also rank a component page above a
guide page that happens to have a better textual match. I chose textual relevance
over route privilege because it degrades more gracefully, but it is a defensible
disagreement. Fully reversible — one function, `Shared.filterSearchEntries`.

Result: all 8 `search.spec.ts` cases pass, including the 3 that were failing
(36, 150, 215).

## L-V1 — independent verification report

Fresh checkout of `layout-only-styling` at tip `02eb33e` (before this report's own
edit). Read-only review — no code changed; every claim below was re-derived, not
re-read from the worker's commit messages.

### L-A — Recast→Seam rename, centralization fence

**Fence mechanism: CONFIRMED.** `isAllowedModule` (`NoProprietaryDsClasses.elm:182`)
does dot-boundary prefix matching, wired through `context.gated`
(`NoProprietaryDsClasses.elm:164-197`) exactly as described. The 6 new fence tests
(`NoProprietaryDsClassesTest.elm:338-409`) genuinely cover what their names claim —
read line-by-line, not just by name. Live-fire double-check: temporarily added
`m3e-totally-not-real-utility` to `docs/app/ErrorPage.elm` outside any seam and ran
`npm run check:review` — it fired (`DeadM3eUtility`, not part of the fence test but
confirms the rule engages on real code); reverted cleanly, `git status` clean after.
`seamModules = [ "Seam" ]` confirmed identical in both the live
`review/src/CodegenReviewConfig.elm:119` and the derived
`docs/samples/review/src/CodegenReviewConfig.elm:119` (drift-checked, see General).

**Rename: INCOMPLETE — CONFIRMED discrepancy, severity: low (prose only, no
functional impact).** The commit message claims "`seamModules` is renamed `Recast`
-> `Seam` across the usage fence, the import fence's allow-list, and the prose" and
"Corrected in place rather than left to mislead the next reader." Grepping the
whole worktree for `Recast` as an identifier turns up two more genuine misses in
files L-A itself touched or should have swept:

1. `packages/elm-m3e/review/src/ReviewConfig.elm:530` — "`ZERO, which is why there
   is no \`Recast\` module to centralise into`" — this is the exact same destination
   concept L-A renamed elsewhere in this same file (the `toHtmlGate`/"recast fence"
   docstring, ~30 lines below the paragraph L-A did fix at line ~376). Still says
   `Recast`.
2. `packages/elm-m3e/review/src/ReviewConfig.elm:404-411` (the `onBarrelPreferredCode`
   comment) and `packages/elm-m3e/docs/DESIGN.md:89` both still claim
   `Layout`/`Kit`/`Native` are real, on-allow-list adapters — for a *different* rule
   this time (`NoInternalImportOutsideAllowed`). Checked the actual code
   (`CodegenReviewConfig.elm:162`): `NoInternalImportOutsideAllowed.rule [ "M3e",
   "TypedHtml", "HtmlIr" ]` — no `Native`/`Layout`/`Kit`. `DESIGN.md:89` explicitly
   cites this exact rule and file and gets the allow-list wrong. This is the *same*
   false-prose bug L-A's commit message says it fixed ("False twice over —
   `Layout`, `Kit` and `Native` do not exist as modules AND were never on that
   rule's allow-list") — fixed in one place, not this second one.

(Noted, not counted as a discrepancy: `Recast` also appears throughout
`packages/elm-review-cem/src/ExtractToSeam.elm` and its test — a separate,
pre-existing codemod rule in a different package, using `Recast` as its own
illustrative example name for a generic destination-module parameter. Untouched by
any of L-A/L-B/L-D's commits and out of scope; not a leftover of this rename.)

Net: the fence *works* and is correctly tested. The rename is real for the
mechanism that matters (the actual `seamModules` config) but the prose sweep
missed two more spots making the identical claim this leaf exists to kill. Fix is
mechanical — swap `Recast`→`Seam` at `ReviewConfig.elm:530`, and correct
`Layout`/`Kit`/`Native` at `ReviewConfig.elm:404-411` and `DESIGN.md:89` to state
the real `[ "M3e", "TypedHtml", "HtmlIr" ]` allow-list.

### L-B — real utility manifest, DeadM3eUtility fix

**CONFIRMED, no discrepancies found.**

- `check:m3e-utility-names` is a real `check:*` script (`package.json:46`) and
  `"check": "run-p \"check:*\""` (`package.json:25`) — genuinely globbed in, not
  orphaned. Independently confirmed it's reachable from the root gate: `gate-all.mjs`
  auto-discovers every workspace package's `check`/`test` script
  (`tools/gate-all.mjs:236-249`) and runs `pnpm --filter elm-m3e run check`, which
  fans out to `check:m3e-utility-names` among the rest.
- Read `classify` (`NoProprietaryDsClasses.elm:410-446`) directly: real
  `m3e-*` utilities go through `isM3eTokenUtility` (manifest membership, not
  prefix), and anything else spelled `m3e-*` falls into an explicit
  `DeadM3eUtility` branch *before* reaching the permissive unknown-token default —
  the exact bug class described (permissive tail swallowing the check) is
  structurally closed off, not just avoided by test luck.
- Live-fire: ran `node review/scripts/gen-m3e-utility-names.mjs --check` fresh → OK.
  Ran `npm --prefix docs run check:review` fresh on unmodified code → "I found no
  errors!" (zero violations, confirms no new false positives from the manifest
  switch). Then edited `docs/app/ErrorPage.elm` to add
  `m3e-totally-not-real-utility` to a real `class` call and re-ran — it was caught
  live, with the `DeadM3eUtility` message text exactly as documented. Reverted;
  `git status` clean afterward.
- `generate-component-utilities.mjs` (`tailwind-m3e-web/bin/`) confirmed:
  `emitUtilities` and `emitUtilityManifest` are both called from the same `main()`
  against the same `flatUnique` map built once from `cem-facts.json` — the manifest
  is genuinely derived from the same source as `utilities.css`, not a second,
  independently-maintained list.
- `elm-test` in `packages/elm-m3e/review`: 83/83 passed, fresh run, matches claim.

### L-D — search ranking

**CONFIRMED, ranking logic sound; one edge case worth flagging (not a bug).**

- Read `filterSearchEntries` (`docs/app/Shared.elm:1087-1152`) directly: scoring is
  0/1/2/3 as documented, `List.take 20` does sit before the final
  `List.map Tuple.second` unwrap (after the sort), matching the perf claim.
- `tests-browser/search.spec.ts` has exactly 8 tests. Fresh run (ports 1239/3055
  killed first): **8/8 passed**, 30.6s, all green — including the three that were
  previously failing per the plan doc.
- Sanity-checked against terms NOT in the test suite by replicating the ranking
  function against the real `dist/search-index.json` (2722 entries): for "card" and
  "checkbox," the top result is correctly the component's own page (exact
  heading match on its own h1, then the page-level entry) — the common case works
  as intended.
- Edge case found for "list": the top-ranked result is a heading titled exactly
  `"list"` on the unrelated `/components/compose` page (an exact-match score of 0),
  outranking `List < Components < elm-m3e`'s own page-level entry (a starts-with
  score of 1). This is the algorithm doing exactly what's documented — exact match
  legitimately beats starts-with — not a discrepancy between claim and code. Flagging
  it because it's a real, findable case where a user searching a component's exact
  name doesn't get that component's page first. Separate from, but same flavor as,
  the URL-boost judgment call already flagged for Jack in the L-D section above.
  Confirmed that section's own framing holds: this is genuinely "one function,
  fully reversible," not architecturally locked in — `filterSearchEntries` is a
  single, self-contained sort key.

### General

- Full `node tools/gate-all.mjs`, fresh, from this worktree, ports 1239 and 3055
  killed first (the two ports referenced anywhere in the repo's server configs):
  **`GATE-ALL GREEN`**, `25/32 passed, 7 skipped, 0 failed`. All 7 skips are the
  documented snapshot-dependent gates (`ab-elm-cem`, `ab-elm-m3e-split`, 4x
  `copy-fidelity-*`, the M4.b cross-cutting `check-drift`) — absent-snapshot skips
  in this clone, not failures, matching the plan doc's stated reason. Browser suite:
  236 passed (2.7m), matching the plan doc's number exactly.
  **Discrepancy in the recorded evidence itself (severity: low, cosmetic):** the
  plan doc's "Done-gate evidence" section quotes `PASS: 260   FAIL: 0   SKIP: 16`
  as `gate-all.mjs`'s own output. That exact line does not appear anywhere in a
  fresh run of the identical command at the identical commit — `gate-all.mjs`'s
  real summary format is `N/M passed, K skipped, J failed` (confirmed by reading
  `tools/gate-all.mjs`'s own summary code and by this fresh run: `25/32 passed, 7
  skipped, 0 failed`). The qualitative claims that matter (`GATE-ALL GREEN`, 0
  failures, 236 browser passes) all check out; the specific `260`/`16` figures
  don't correspond to this tool's actual output shape and look either
  transcribed from something else or misremembered. Worth a note in the next
  retro given the plan doc's own "process note" is specifically about evidence
  fidelity.
- Derived-artifact sweep, beyond what the worker already caught: `elm-m3e`'s own
  `check:drift` (part of the green `elm-m3e: check` above) reports "30 generated
  artifact(s) match a fresh regen" — this covers `M3eUtilityNames.elm` and the
  `docs/samples/review/src/CodegenReviewConfig.elm` copy, so both L-A's and L-B's
  new/changed derived artifacts are confirmed non-stale by the tooling itself, not
  just by my grep. Grepped the wider workspace for other files referencing
  `seamModules`/`NoProprietaryDsClasses` outside `packages/elm-m3e` — the only other
  hits are in `packages/elm-review-cem`'s own README/skills/tests, which use
  `Recast`/`Layout`/`Kit`/`Native` as *generic, design-system-agnostic example
  names* for a reusable rule template (explicitly disclaimed as such at
  `ReviewConfig-personas.md:5`) — not stale copies of `elm-m3e`'s actual config, and
  untouched by this branch's commits. No other stale derived files found.

### Recommendation

**Merge-ready with minor fixes.** L-B and L-D are solid — verified against live
code, not just against the existing test suite, with no discrepancies. L-A's
mechanism (the fence itself) is solid too, but its own stated goal — kill every
instance of the false `Recast`/`Layout`/`Kit`/`Native` prose — is not fully done;
three more sentences carrying the identical false claim were found in files the
leaf already touched or clearly owns. None of these three are functional (nothing
in code, tests, or the gate reads them), so they don't block merging on their own,
but they should be swept before calling L-A's rename complete, since leaving them
is exactly the kind of drift this leaf exists to prevent.
