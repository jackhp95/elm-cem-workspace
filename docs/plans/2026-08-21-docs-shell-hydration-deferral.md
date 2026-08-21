# Spec: defer docs-shell hydration (nav-tree + theme-reel) to lower the per-page floor

**Status:** proposed · **Owner:** docs/elm-pages app (`brands/m3e/generated/docs/elm-m3e-docs`) · **Author:** gate-perf investigation, 2026-08-21 · **Expected tier:** planning → fable/opus xhigh; execution → opus medium

## TL;DR

Every docs page mounts ~914 live `<m3e-*>` custom elements, but only ~257 are the
page's actual content. The other ~657 (72%) are shell chrome that re-hydrates on
**every** navigation — dominated by the **component nav-tree (~274 elements)** and
the **theme-reel (~45 `<m3e-theme>` cards)**, neither of which most page views ever
interact with. This chrome hydration is a ~2.5s floor under every browser test and
a real cost on every user page-load. Deferring hydration of the nav-tree and
theme-reel until the drawer / settings sheet is actually opened is the single
highest-leverage change for both test wall-time and real UX.

## Evidence (measured 2026-08-21, this machine, low load)

- Probe of `/components/button` at desktop 1280×900, fully settled: **914 live
  `<m3e-*>` elements. Only ~257 are page content.** Breakdown of the ~657 chrome:
  - **~274** nav-tree / drawer / rail elements
  - **~45** `<m3e-theme>` reel cards (the theme picker in the drawer)
  - **~338** app-bar / TOC / misc chrome
- Time-to-app-bar on a shell page ≈ **2.5s**; on a `/examples/*` route (which skips
  the docs shell) ≈ **1.0–1.3s**. The ~1.3s delta is entirely shell hydration.
- Full browser suite (238 tests) duration distribution: **0 under 1s, 31 at 1–2s
  (all `/examples/*`, no shell), 128 at 2–3s (single-`goto` shell pages — the mode),
  56 at 3–4s, 23 at ≥4s.** The 2–3s mode band *is* the shell floor, not test bloat.
- `all-components.spec.ts` is **139 tests** (one per component slug in
  `data/reference.json`) × ~2.6s = **~362s = 53% of the entire browser suite** — every
  one paying the shell floor.
- Same root cause as the retired `guide-reference-gate-flake`: `/guide/reference`
  hydrated 6,657 live components and took ~40s cold (see
  `memory: guide-reference-gate-flake`).

## Why this is the lever

No amount of per-test rewriting gets the mass of tests under 2s — a single-navigation
shell-page test cannot beat the ~2.5s hydration floor. Lowering the floor is the only
thing that moves all 128 mid-tier tests, the 139-page sweep, AND real user page-loads
at once. It is a **product change**, not a test change.

## Proposal

Defer hydration of the two largest never-usually-touched chrome regions so they are
not live `<m3e-*>` elements in the initial DOM:

1. **Theme-reel (~45 `<m3e-theme>` cards).** These live in the drawer's settings
   surface but are mounted on initial load regardless. Render the reel's cards only
   when the settings sheet / theme surface is first opened (Elm: gate the reel view
   on the sheet-open state, or mount a lightweight placeholder that swaps to the live
   reel on first open). A user who never opens settings never pays for 45 live theme
   cards; a test that never touches theming never hydrates them.

2. **Component nav-tree (~274 elements).** On desktop the tree is *pinned open* by
   default (`Shared.init` seeds `treeOpen` from `treePinsOpen`), so it is in the
   initial DOM. Options, cheapest first:
   - Render the tree's per-route item list lazily / windowed (only the current
     section's items live; other sections' items materialize on expand). Most routes
     show one flat section, so this alone removes most of the 274.
     nav.spec.ts already documents the tree as "per-route, flat" — the full cross-section
     tree is rarely all-visible.
   - Or: keep the tree markup but make its entries plain anchors, not live `<m3e-*>`
     nav items, until interacted with (progressive enhancement). The rail's 5 items
     stay live; the long per-component list does not need to be 274 custom elements to
     be a navigable list.

## Non-option (why `content-visibility` alone won't do it)

`content-visibility: auto` defers *paint/layout* of offscreen content, but custom
elements still `upgrade` (run `connectedCallback`) on connect regardless of
visibility — so it does not remove the CE-upgrade cost that dominates here. The fix
must keep the elements **out of the initial DOM**, not merely offscreen.

## Blast radius (a cost, per repo policy — not a blocker)

- Touches the docs app shell (`Shared.elm` view + the drawer/settings surfaces),
  which is generated-adjacent hand-authored docs code, not the elm-cem codegen core.
- Tests that specifically assert the tree/reel (nav.spec, nav-rail.spec, theme-reel.spec,
  settings-sheet.spec) will need their open/interaction steps to trigger the now-lazy
  hydration — an expected, mechanical adjustment, and those tests already open the
  drawer/sheet.
- Risk: a lazy-mount race (open → not-yet-hydrated) could reintroduce a flake if the
  open interaction doesn't await hydration. Mitigate with a deterministic
  `waitForFunction` on first-open (the suite already uses this pattern; no fixed
  timeouts).

## Verification plan

1. Re-run the full instrumented gate (`GATE_ALL_CONCURRENCY=1 RUN_FULL_BROWSER=1`)
   and the per-test list reporter; expect the 2–3s mode band to collapse toward the
   ~1.3s `/examples/*` floor and the 139-page sweep to drop proportionally.
2. Confirm the shell/nav/theme tests still pass (they now trigger hydration explicitly).
3. Manually confirm real page-load: `/guide/reference` and a heavy `/components/*`
   page should hydrate far fewer initial elements (DevTools: count live `<m3e-*>` on
   load).

## Expected payoff

If the nav-tree + reel (~319 of 914, 35%) defer, the shell floor should fall from
~2.5s toward the ~1.3s example-route floor — plausibly moving most of the 128 mid-tier
tests and the bulk of the 139-page sweep under 2s, cutting the full/CI browser suite
substantially, and speeding every real docs page-load by the same mechanism. This is
the durable answer to "get every browser test under 2s"; the test-level trims landed
alongside this spec only reduce the *number* of floor-hits, not the floor itself.
