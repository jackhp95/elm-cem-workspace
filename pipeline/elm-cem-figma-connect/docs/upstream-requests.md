# Upstream `@m3e/web` requests (out of scope for cem-figma-connect)

These are Figma M3-kit components the coverage-remediation pass (`docs/coverage-remediation-plan.md`
§6) identified as **genuine `@m3e/web` gaps**: the kit draws them, but there is **no corresponding
CEM tag**, so cem-figma-connect cannot bind them. They require a component implementation in
`@m3e/web` first; there is no correspondence/emit/gate action in this repo.

Recorded 2026-07-30 against `@m3e/web` 2.7.0 (128 CEM tags) and Figma export
`research/figma-dumps/figma-export.m3-kit.json` (`fileKey UtwpUdPiOZEuxp8Nq1d5yQ`).

---

## U1 — Carousel

**Figma sets:**

| Node ID | Name |
|---|---|
| `53912:27480` | `Carousel` |
| `54577:26060` | `Carousel - Full screen` |

**Gap:** there is no `m3e-carousel`. `m3e-slide` / `m3e-slide-group` are a pagination/scroll
control, not an M3 media carousel — different semantics (a carousel is a laid-out set of media items
with hero / center-aligned / multi-browse / uncontained / full-screen layouts, per the Figma
`Layout` axis).

**Request:** implement an `m3e-carousel` component covering the M3 carousel layouts, then bind it
here via `manual-correspondence.json` (`figmaSets`) as a new component.

---

## U2 — XR / spatial family (16 sets)

`@m3e/web` has **zero** XR/spatial components. This is the single largest genuine gap — a whole
spatial-surface subsystem, not one component.

| Node ID | Name |
|---|---|
| `58108:88092` | `XR/XR App Bar` |
| `58108:87558` | `XR/XR Dialog` |
| `57547:4795` | `XR/XR Navigation bar` |
| `57547:2577` | `XR/XR Navigation Rail` |
| `58823:1688` | `XR/XR Toolbar` |
| `58823:1763` | `XR/Building Blocks/Surface high/Icon button` |
| `58823:1786` | `XR/Building Blocks/Surface high/Icon button toggleable` |
| `58823:1831` | `XR/Building Blocks/Surface high/Button toggleable` |
| `58823:2013` | `XR/Building Blocks/Surface/Icon button` |
| `58823:2036` | `XR/Building Blocks/Surface/Icon button toggleable` |
| `58823:2081` | `XR/Building Blocks/Surface/Button toggleable` |
| `58823:1887` | `XR/Building Blocks/Tertiary container/Icon button` |
| `58823:1910` | `XR/Building Blocks/Tertiary container/Icon button toggleable` |
| `58823:1955` | `XR/Building Blocks/Tertiary container/Button toggleable` |
| `57547:1794` | `Building Blocks/XR/Navigation rail/Nav item` |
| `57547:4010` | `Building Blocks/XR/Navigation bar/Nav item` |

**Request:** track as a single family-level `@m3e/web` feature request (spatial/XR surfaces), not
per-set. Bindable here only once the tags exist.

---

## U3 — Bottom app bar (flagged item F3, plan §8 — user-decided UPSTREAM 2026-07-30)

**Figma set:** `51159:5105` — `Bottom app bar`.

**Gap:** there is no `m3e-bottom-app-bar`. Neither existing tag is a faithful match — `m3e-app-bar`
is a *titled top bar* (`title`/`subtitle`/`size` small|medium|large, `centered`); the bottom app bar
is a title-less bottom action bar of 1–4 icon buttons + an optional FAB (`Show FAB`, `Icons=[1..4]`).
`m3e-toolbar` is structurally the closest but semantically distinct (a contextual action cluster, not
a persistent bottom bar), so it was **not** bound — a wrong binding is worse than none.

**Request:** implement a first-class bottom-app-bar component in `@m3e/web`, then bind it here.

---

## Status

None of U1–U3 is actionable in this repo. Decide with the user whether to file these as GitHub
issues against `@m3e/web` (`elm-m3e` family) or leave them recorded here. No publish/emit impact.
