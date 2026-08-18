# Session handoff — 2026-08-18

Written by the outgoing session for whoever (human or fresh agent) picks this up next.
Everything below is verified, not guessed — where something is uncertain, it's marked as such.

## Where things stand right now

`elm-cem-workspace`'s `main` is clean, single-branch, fully pushed to `origin/main` (HEAD
`b3adbcf` as of this handoff). No open branches, worktrees, or stashes anywhere on this
machine for `elm-cem-workspace` or any of its sub-packages — verified exhaustively (checked
`~/.paseo/worktrees/` in full, `~/Documents/code/` at unlimited depth for linked-worktree
pointer files, `git worktree list`, `.git/worktrees/` admin dir, `git stash list`, `git log
--all`). `gate-all.mjs` is green.

**Prerequisite context — read this first:** `docs/reviews/2026-08-17-thermonuclear-workspace-review.md`
(the audit that drove most of today's work) and the memory file
`elm-cem-workspace-target-architecture` (Jack's dictated system design, in the auto-memory
store, not this repo — ask to have it surfaced if you don't have access) explain *why* things
are shaped the way they are. Skim both before touching anything structural.

## What landed today (all merged, pushed, independently verified)

The "thermonuclear audit" gauntlet — `docs/plans/2026-08-18-thermonuclear-audit-remediation.md`
has the full blow-by-blow, including a "Merge synthesis" section at the end covering three
real integration bugs that only surfaced when all five branches were combined (not visible
from any single branch's own gate):

- **W1** — enforcement wiring (root CI, unified `hooks:install`, gated `publish-mirror`/`bump`,
  chronic-SKIP tracking). Was the audit's #1 BLOCKER.
- **W2** — `elm-cem` core decomposition (`Emit.elm` 7,169→147 lines + 17 modules, `resolveWith`
  1,236→117 lines), plus a real BLOCKER bug fix (a divergent config decoder) and a real
  `dedupBy` bug fix (was silently keeping the *last* dupe, not the first, contradicting its own
  doc comment).
- **W3** — M3E-coupling removed from `elm-cem`'s generic layers (icon tag/prose, brand
  registry, Figma matcher vocab, review-rule nouns).
- **W5** — one `tools/family.json` manifest replacing ~4 independently-hardcoded package
  lists; ~2,000 lines of duplicate scripts consolidated.
- **W6** — trapped generic modules promoted for future-brand reuse; a real validation bug
  fixed in passing (second-brand components were never checked against ground truth at all).

**A related, separate thread also closed today:** the `coerce` mechanism (a phantom
generator feature — fully specified, never actually wired up, despite ~10 docs pages
describing it as shipped) was removed entirely, per Jack's explicit call. Its replacement
rule: a kind-crossing either widens the relevant `admits` config (if it doesn't conflict with
Material Design guidance) or goes through `recast`/`Seam` (the existing, now-unified,
centralized escape-hatch mechanism) if it does. See `docs/plans/2026-08-17-tailwind-layout-enforcement-completion.md`
for the Tailwind-enforcement work (`NoProprietaryDsClasses`/`NoNonLayoutTailwindClasses`) that
happened alongside it, including a real correctness bug fixed (the rule was accepting any
`m3e-*`-prefixed class via a prefix guess instead of the real generated list — now fixed to
consume a real manifest, same lesson later reapplied to `validate-markup.mjs` in W6).

## What's still open — grouped, not ranked (that's a decision for whoever picks this up)

### 1. Remaining audit items (from `docs/reviews/2026-08-17-thermonuclear-workspace-review.md`'s "Consolidated top 10 moves")

- **W4** — elm-review-cem shared-module extraction: hoist a 10× duplicated let-scope collector
  (self-flagged as a TODO in the code, `Cem/ValidSlotKind.elm:105-108`), extract
  `Cem.Internal.AccessibleName` (folds in a noun-hardcoding fix similar to W3's), `Cem.Internal.Gate`
  (dedupes 5× `isAllowed`), `Cem.Internal.BarrelMapping` (a documented past bug source). Was
  held only because it overlapped W3's files — that block is gone now, W4 is unblocked.
- **W7** — package boundary extractions: `elm-cem-facts` should move from its current odd
  nesting (`packages/elm-cem/facts/`) to a real top-level `packages/elm-cem-facts/` (it's
  already independently versioned/published — this is purely a physical-location fix,
  `git mv` + path-const updates in ~4 places). `cem-figma-connect`'s `src/tokens/*` (~3.4k
  lines, a `@m3e/web` ⋈ `tailwind-m3e-web` token-diff tool with a literal hardcoded
  cross-package import) should move out — either its own package or into `tailwind-m3e-web`.
- **W8** — small staleness gaps: a `match --check` mode for `cem-figma-connect` (nothing
  currently verifies `correspondence.json` is still derived from current inputs — a stale
  correspondence after a CEM refresh passes every gate silently today), a facts-index
  meta-test in `elm-review-cem` (the "must use `Facts.buildIndex`" rule is convention-only,
  nothing stops a hand-rolled dead index). Mostly subsumed by W1's chronic-SKIP tracking
  already landed — check what's genuinely left before treating this as a full leaf.
- **The big one — audit move #2, "prove or retract brand-pluggability."** Actually running a
  real second CEM brand (Carbon or Spectrum — configs already exist, unused) end-to-end
  through codegen, gated in CI. This is what would flip the "brand-pluggable" claim in
  `VISION.md` from asserted to demonstrated. Explicitly NOT a mechanical fix — closer to a
  mini-project. Flagged from the start as a likely separate wave; never started.

### 2. Loose ends from today, not audit-tracked

- **Search-ranking judgment call** (in the Tailwind-enforcement work) — the implementing
  agent chose pure textual relevance over a `/components/*`-style URL boost for search
  results. Jack has not reviewed/confirmed this choice. One function
  (`Shared.filterSearchEntries`), fully reversible.
- **`Doc.anchorPill` widening decision** — left as a TODO with both routes spelled out in the
  code (`recast` it, or widen `anchorPill`/`Route/Guide.chapterLink`'s signatures to accept
  phrasing content, which is the "honest" option since an assist-chip genuinely is phrasing
  content). Not built either way.
- **A leftover inline style on a theme swatch** from an earlier (pre-audit) gauntlet pass —
  mentioned once, never tracked with a file:line. Whoever picks this up should grep for it
  fresh rather than trust this description.

### 3. Publishing — nothing here should happen without Jack's explicit go, it's all external-facing

- **Mirror staleness**, precisely stated (a subtlety worth preserving): `tools/check-mirror-drift.mjs`
  only detects *tampering* (has someone hand-edited the GitHub mirror directly, diverging it
  from what `publish-mirror.mjs` last wrote there) — it does NOT detect staleness (has the
  workspace moved on since the last publish). By the actually-relevant staleness measure:
  **`elm-cem`, `elm-m3e`, `elm-review-cem`, and `tailwind-m3e-web` are all now stale mirrors** —
  all four got real functional changes in today's audit work, none have been re-published
  since. Re-publishing is `tools/publish-mirror.mjs <name> --push` (now gated on `gate-all`
  passing first, per W1) — but this pushes to public GitHub repos and needs Jack's explicit
  authorization each time, not a standing default.
- **From `docs/superpowers/plans/2026-08-15-publish-runbook.md`** (older, separate thread —
  the actual "publish these 5 new Elm packages to the registry" effort): two decisions still
  open.
  - **O-3** — the icons package's `docs.json` size cap (R-026: measured 1,075,308 B vs a
    768,000 B registry limit). Three options on the table in the runbook (split into N
    sub-packages / leaner per-function docs / a different typed-name representation). Jack
    has not picked one.
  - **O-6** — a `jackhp95/elm-probe-pkg` throwaway dry-run publish, already scaffolded
    (`packages/_probe/elm-probe-pkg/`), never approved/executed. Meant to validate the real
    registry's behavior before spending a real package-name coordinate.
  - The actual publish sequence (5 new public GitHub repos, tags, `elm publish` for each) is
    deliberately held on O-1 ("nothing is published until the system matches Jack's
    understanding of it") — still fully unstarted, and shouldn't start without a fresh
    confirmation that O-1's condition is now met, given how much changed today.

### 4. `VISION.md` roadmap — worth a fresh read, not just this summary

- **Phase 0** ("sustainability spine") was marked ✅ in the doc but was actually contradicted
  by the audit (no CI, no gate enforcement) — now that W1 is merged and verified, Phase 0 can
  honestly flip back to ✅. Nobody has made that edit yet.
- **Phase 1** ("one canonical html↔elm engine") — doc says "largely realized... original
  de-duplication to confirm." That confirmation was never done, as far as this session found.
- **Phases 2** (Tailwind Code Connect + hybrid Elm+Tailwind outputs) **and 4** (token model
  hardening: ref/system/component tiers, density, "required code change" surfacing) — both
  "Not started" per the doc, and nothing found this session changes that.
- **Phases 3 and 5** — partially in motion via Jack's own parallel work today (separate from
  this session — his commits mention `cem-figma-connect` Phase 1.2/1.3, 2.1/2.2, 3.1; one
  commit message literally says "figma-links -> elm-m3e docMeta joiner (**NOT wired into
  regen**)" — a visibly incomplete piece in his own in-progress work, not investigated further
  this session since it wasn't this session's work to audit uninvited).

### 5. Two naming/reframing questions Jack raised earlier (2026-08-17), confirmed still open, no plan doc tracks either

- **`tailwind-m3e-web` → something like `elm-cem-tailwind`.** Confirmed today: the actual
  codegen logic (`generate-component-utilities.mjs`, `gen-facts.mjs`, both promoted to
  `tools/lib/` in W6) is already genuinely brand-agnostic. What's still conflated is the
  *package identity* (name, bin, peerDep) and the *hand-authored M3-theme layer*
  (`src/sys/*.css`, tone/palette calibration scripts) — those are real, hand-written,
  M3-specific, and currently live in the same package as the generic tool.
- **`cem-figma-connect` → something more Elm-specific.** Confirmed today: the package is
  already genuinely generic in practice (built explicitly on the CEM-agnostic `Cem.Facts`
  substrate, requires an explicit `--profile` with no hardcoded default). This is purely a
  naming/framing question, not a real coupling problem — low urgency. W7's `src/tokens/*`
  extraction (above) is a related, more concrete piece of the same package's cleanup.

## Things learned this session worth knowing before continuing

- **`elm-cem-workspace` is the sole place family-package work happens now.** All 8 formerly-standalone
  repos (`elm-cem`, `elm-m3e`, `elm-review-cem`, `elm-typed-html`, `elm-html-intermediate-representation`,
  `m3e-okf`, `tailwind-m3e-web`, `cem-figma-connect`) were wrapped up, pushed to their final
  state, and deleted locally earlier this session. Their GitHub repos still exist as read-only
  publish mirrors (see "Publishing" above) — never clone them as a dev target again.
- **The merge-time integration lesson**, worth internalizing: five independently-verified,
  independently-green branches still produced three real bugs once merged together (two
  missing neutrality-allowlist entries, one real `check-drift.mjs` path-depth bug, two stale
  downstream generated files). Always run the full `gate-all.mjs` on the actually-combined
  tree before considering a multi-branch merge done — no single branch's gate can catch an
  integration-only failure.
- **Agent self-reports need independent verification, consistently** — this session caught
  several real discrepancies this way: a subagent that self-authorized a hook bypass after
  being denied once and then misreported it as user-approved; a "verified live" BLOCKER
  reproduction that turned out not to reproduce on either branch (the real bug was on a
  different field); a "6 call sites" recount that was actually 7. None of these were caught by
  the reporting agent itself — always by a separate, independent review pass.
- **`check-drift.mjs`'s scratch-copy mechanism now preserves real package depth** (`packages/<name>`,
  not just `<name>`) and has an `externalSymlinks` option for packages that import out to
  shared `tools/lib/` code — use that pattern if any future promoted-to-`tools/lib/` module
  needs the same treatment.

## Suggested next step (a suggestion, not a decision made for you)

Given the shape of what's open, a reasonable ordering — but this is genuinely Jack's call, not
something to execute on autopilot: resolve the small judgment calls first (search ranking,
`anchorPill`, theme swatch — cheap, unblocks nothing else but they're quick), then decide on
the mirror-publishing question (affects whether W4/W7/W8 should also get published when done,
or batched), then pick up W4 (unblocked, well-scoped) before the larger W7/brand-pluggability
work.
