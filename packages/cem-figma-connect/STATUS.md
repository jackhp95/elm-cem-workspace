# STATUS — current state of cem-figma-connect

This is the single **current-status** pointer. The dated `HANDOFF-*` files (root and
`plans/`) are **historical snapshots** and describe topologies/incidents that no longer
apply — read this file first.

## Where things stand

- **The tool is built and running.** `src/cli.mjs` implements
  `match / review / confirm / gap / extract / emit / publish / unpublish / check / capture`.
  The `m3-kit` profile is wired end-to-end and its Code Connect bindings (224 per label)
  are committed under `generated/m3-kit/{web-components,elm}/`. `package.json` scripts were
  renamed to `gen:*`/`check:*` verb namespaces (2026-08-04) — use `pnpm run gate` (check + test)
  as the one-shot local gate; a pre-push hook now runs it automatically (`git push --no-verify`
  or `SKIP_GATE=1` to bypass deliberately).
- **The implementation lives on `main`.** The stacked, unmerged `plan/a…`→`plan/d…` branch
  topology described in the root `HANDOFF.md` (2026-07-11) is **obsolete** — that work, plus
  the later breadth/visual-gate/token/elm work, has been consolidated onto `main`. Do not
  go looking for those branches.
- **`coverage-remediation` merged 2026-08-12.** Closed the figma-only crescent (BIND: timepicker
  dial/keyboard/period-toggle; APPEND: range slider, secondary tabs ×2, list/scrollable dialog,
  modal date picker, search fullscreen; UPSTREAM: Carousel/XR/bottom-app-bar requests recorded
  in `docs/upstream-requests.md`) and ran a follow-on visual-gate content-parity pass (nav-menu,
  menu, list, form-field, rich-tooltip, chip-set, nav-rail, drawer-container, bottom-sheet, and
  more — see `plans/identical-views-handoff.md` for the method and session history). **Still
  open** (needs a live Figma-bridge review session or an architectural call, not a mechanical
  fix — see `plans/next-agent-handoff.md`): `m3e-card` (two structurally different Figma nodes
  share one binding — needs a per-set example), `m3e-fab-menu` (the node is the open menu **plus**
  a sibling FAB the example format can't add), `m3e-date-input` docked set (wrap it like the modal
  set already is), and `m3e-search-view` fullscreen pixel-match (only if asked — current binding
  is intentionally representative).
- **Active development** has continued through ~2026-08-12 (see the design/plan files dated
  in `plans/`). Most components beyond `m3e-button` have been gated and confirmed; a residual
  worklist remains (previous bullet).

## Get started

1. `README.md` — Prerequisites, Install, Quickstart (the no-Figma path).
2. `docs/USAGE.md` — the full extraction → match → review → gap → emit → visual-gate →
   publish walkthrough.
3. `plans/plan/README.md`, `plans/00-mission-and-decisions.md`, `plans/01-architecture.md`
   — design and rationale.

Sanity check on a fresh clone (no Figma, no token needed):

```bash
pnpm install
pnpm check                                # generated/** matches correspondence.json
node src/cli.mjs emit --profile m3-kit    # deterministic; leaves generated/** unchanged
pnpm test                                 # unit suite (rm -rf render-cache/results first if it flakes)
```

## Open decisions / release blockers (need an owner)

- **Canonical publish `--file-key` is unresolved — now a 3-way disagreement.** The plans
  (`plans/plan/README.md`, `plans/00-mission-and-decisions.md` D2) name `KujuFlfJSwHI6ua1b7RZvL`;
  `profiles/m3-kit/profile.json` (and the 2026-07-14 handoff) use `UtwpUdPiOZEuxp8Nq1d5yQ`; and
  `research/figma-dumps/figma-export.m3-kit-copy.json` (checked in 2026-08-04, an export of a
  Figma-side "(Copy)" of the community kit — likely made to get write access for a future publish)
  carries a third, `iPFL8MH2R1Xphe94j7g809`. Pick one before a real publish and reconcile the
  others. This file deliberately does **not** choose.
- **`extract/` IP review** is a release blocker (the WS-relay + self-hosted-plugin technique
  is a second-generation adaptation of Avetta-authored code). Keep the repo private until
  that review is recorded. See `extract/README.md` → "Release blocker".
- **Figma PAT hygiene:** any token used for `publish` is consumed from `FIGMA_ACCESS_TOKEN`
  and should be revoked after use; earlier tokens referenced in the handoffs are burned.

## Historical handoffs (snapshots — context only, not current instructions)

Newest last. These preserve session context but may reference gitignored working notes
under `.superpowers/` that are **absent on a fresh clone** — ignore any "read
`.superpowers/…`" resume step.

- `HANDOFF.md` (2026-07-11) — the original A→B→C→D implementation + an unauthorized-publish
  incident. Branch topology it describes is obsolete (see above).
- `plans/HANDOFF-2026-07-14.md` — breadth triage (RC1 matcher boolean axes, emit-icon decision).
- `plans/HANDOFF-2026-07-14-jack-device.md` — second device; emit-icon shipped, visual gate
  reconstructed as `src/visual/gate.mjs`, publish blocked on a personal (non-org) account.
