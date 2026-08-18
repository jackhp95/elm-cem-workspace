# T2 triage report — orphaned standalone-repo commits (elm-cem / elm-m3e / elm-review-cem)

> T2 leaf of `docs/plans/2026-08-17-standalone-repo-realignment.md`. Compiled
> by the manager from three worker reports (delivered via chat, not a
> committed file, because a harness bug tore down their shared worktree
> mid-run — see `~/.claude/frictions/agent/20260818T012400Z-nested-worktree-teardown-race.md`).
> Confidence: high for spot-checked items, "presumptive" for a handful of
> pre-anchor mechanical commits noted inline below — a couple of items
> (marked) should be re-verified with working `gh api` access before acting.

## Headline result

The fork is much narrower than the raw commit counts (25/30/27) suggested.
**Core codegen (`elm-cem`) and lint rules (`elm-review-cem`) are almost fully
reconciled already** — the workspace's independent 5-package-split evolution
happened to converge on nearly the same fixes. The real divergence is
concentrated almost entirely in **`elm-m3e`'s demo/docs website app**
(`packages/elm-m3e/docs/app/*`), which is dev-only tooling, not the published
`M3e.*` Elm API.

| Repo | superseded | real gap | unclear | total |
|---|---|---|---|---|
| `elm-cem` | 44 | 1 | 0 | 45 |
| `elm-review-cem` | 33 | 1 | 5 | 39 |
| `elm-m3e` | 53 | 27 | 15 | 95 |

## elm-cem — 1 real gap

- **`f74f90a22`** — `examples`/`docMeta` config fields are decoded
  (`codegen/Generate/Config.elm` L317-318, L332-333; `Generate/Types.elm`
  `Config` L256-257) but never threaded through: `Generate/Phantom/Model.elm`'s
  `Comp`/`RawComp` records have no such field, `buildComp` never sets one, and
  `Emit.elm` (7151 lines, fully read) never references `.examples`/`.docMeta`
  in doc-comment generation. **Porting:** add the fields to
  `RawComp`/`Comp` in `Model.elm`, decode in `buildComp`, consume in
  `Emit.elm`'s doc-comment helper (near `doc`, `Emit.elm:1234`).

## elm-review-cem — 1 real gap, 3 stale-reference non-issues, 2 doc gaps

- **`a89918667`** (real gap) — `.neutrality-allowlist` has no entries for
  `src/Cem/Internal/Facts.elm`'s `barrelNamespaceParts`/`barrelRootParts` doc
  comments (which contain M3e example strings). **Unverified** whether
  `check:neutrality` actually flags this (worker's Bash died before it could
  run the check) — run `npm run check:neutrality` in `packages/elm-review-cem`
  first; only add the allowlist lines if it actually fails.
- **`3cf7a2470`** (doc gap) — `RequireSlot.elm`/`SingularSlot.elm` code
  comments cite a "Facts-index canonicality" section in `docs/decisions.md`
  that doesn't exist there. Either add the section or fix the dangling
  cross-references.
- **`120610965`, `9b1ce5cca`, `f3aefda6a`** (non-issues) — reference
  `check:index` / `check:facts-sync` npm scripts that no longer exist in the
  workspace `package.json` at all (dropped when `Cem.Facts` sourcing moved to
  the standalone `elm-cem-facts` package at Phase-0 M1.d). Nothing to port;
  optionally scrub the stale comment references.
- Notable: the worker found **no ledger entry anywhere** documenting that
  `elm-review-cem` was ever reconciled/rebased (D-037 through D-042 only name
  `elm-cem`/`elm-m3e`/IR/`elm-typed-html`; R-024 flags `elm-review-cem` as a
  *future* candidate that's never recorded as executed) — yet the workspace
  copy is at byte-for-byte parity (including doc comments) with the
  standalone repo's very last commit. Some silent/mechanical sync happened
  here that the ledger doesn't name. Worth asking whoever/whatever did it,
  since the same mechanism might be reusable for T3.

## elm-m3e — 27 real gaps, all in the demo/docs app

Everything under `packages/elm-m3e/src/` (the published `M3e.*` API), the
codegen-facing pieces, and the `elm-m3e-families`/`elm-m3e-icons` packages
are **(a) superseded** — the naming rename (`view`→`<name>`, `el`→`component`)
and package-shape work landed independently in the workspace. The real gaps
are all in `packages/elm-m3e/docs/app/*` (the Elm demo/docs website, not a
published artifact):

1. **Theme-reel always-visible badge** (`7612b7efa`) — `Theme/Reel.elm`'s
   `cardBody` still conditionally shows `selectedBadge`; needs replacing with
   an always-mounted `cardBadge : Bool -> Element ...`.
2. **Usage tab-sync via ports** (`e5e4c6023` + 4 more) — `Doc/Usage.elm` still
   uses a per-example `Dict Int Surface`; needs a page-wide `activeSurface`
   state + `storeSurface`/`readSurface` port pair in `Theme/Ports.elm`,
   cascading into `Route/Components/All.elm`.
3. **Theme-drawer redesign** (11 commits) — biggest item. Net-new
   `CssVariables.elm` accordion panel (doesn't exist at all yet), reworked
   `Color.elm` (chip cluster instead of native `<input type=color>`),
   `Shape.elm` (new editable-field widget instead of shared stepper), plus
   `Appearance.elm`/`Advanced.elm`/`Shared.elm` changes.
4. **API-reference layered tabs** (8 commits) — `Route/Components/Name_.elm`
   needs a Layers tab UI (M3e/Components/Builder/Raw CEM manifest); touches
   `Route/Guide/Reference.elm`, `docs/scripts/extract-reference.mjs`,
   `Doc/Data.elm` (new `Layers` record).

15 commits landed "unclear" — mostly elm-review custom rules
(`NoMergedPipeAndSetter`, `NoMissingComponentApiNames` wiring) the worker
couldn't confirm either way without a directory listing, plus a couple of
small tail commits lost to a `WebFetch` 10MB cap. Low-stakes; re-check only
if the demo-app porting work gets prioritized.

## Recommendation

- Port the 2 small real gaps in `elm-cem`/`elm-review-cem` — cheap, low-risk,
  closes the only substantive drift in the parts of the family that actually
  ship.
- The 27 `elm-m3e` demo-app gaps are real but non-urgent (dev-only site, not
  a published package) — Jack's call whether to port now or backlog.
- Proceed with T3 (publish path) once the small gaps are ported, so the first
  real publish reflects a fully-reconciled `elm-cem`/`elm-review-cem`.
