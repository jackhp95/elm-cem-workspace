# Spec F — Tangram logo: theme-aware nav-rail toggle + favicon

Date: 2026-08-08
Repo: `elm-m3e`
Status: approved design, not yet planned
Supersedes: `specs/2026-08-05-favicon-material-palette-design.md` (favicon glyph goal
only — see below)
Depends on: Spec E (`specs/2026-08-08-theme-editor-drawer-design.md`) for the shared
favicon-color port

## Problem / goal

Jack wants a tangram-style mark for elm-m3e — two triangles, sketched as:

```html
<svg xmlns="http://www.w3.org/2000/svg" width="566" height="566" fill="none" viewBox="0 0 566 566"><path fill="#d9d9d9" d="m0 0 566 566H0z"/><path fill="#d9d9d9" d="m0 0 566 566H0zM566 0v535L299 267.973z"/></svg>
```

...used in two places:

1. As the favicon.
2. Replacing the current "toggle rail width" icon in the docs nav rail
   (`Shared.elm:1619-1627` — currently a `menu`/`menu_open` Material-icon pair inside
   an `M3e.iconButton [ M3e.IconButton.toggle True ]`), with the small triangle
   recoloring to `inverse-surface` and the big triangle to `inverse-primary` when the
   rail is expanded, to accent the "this closes it" affordance. In RTL, the whole mark
   mirrors horizontally so the visual direction of the affordance still matches the
   actual close direction.

## Non-goals

- Not a generalized `M3e.Logo` library component. This stays docs-app-scoped, in
  `Shared.elm`/`docs/app/`, per Jack's call — not exported from `src/M3e/` for other
  elm-m3e consumers. Revisit later if a second consumer wants it.
- No literal live-CSS-variable favicon. A favicon is fetched by the browser as a
  standalone SVG document — it cannot read the host page's `:root` custom properties.
  This spec does not attempt to make it "live" the way the in-app icon is; see the
  Favicon section for the actual mechanism.
- Does not implement the rest of the superseded Spec D (the OG-PNG / `favicon.ico`
  fixes it also specified) — those are still-true, still-unfixed problems, but this
  spec's scope is the glyph swap. Whoever plans this should decide whether to fold the
  OG-PNG fix in as a cheap add-on (the superseded spec argues it nearly rides along
  for free off the same generator pipeline) or split it out.

## Design

### The SVG, made theme-aware

Two `<path>` elements, fills as CSS custom properties instead of the sketch's flat
`#d9d9d9`:

```html
<svg viewBox="0 0 566 566" fill="none">
  <path fill="var(--md-sys-color-primary)" d="m0 0 566 566H0z"/>
  <path fill="var(--md-sys-color-primary)" d="m0 0 566 566H0zM566 0v535L299 267.973z"/>
</svg>
```

These are the same `--md-sys-color-*` custom properties every other M3e component
already reads off `<m3e-theme>`'s adopted stylesheet — no new plumbing for the in-app
copy, it repaints whenever the theme changes for free.

Embedded as literal inline SVG markup in `Shared.elm` (two `TypedHtml`/`Ir` SVG-node
literals, or via whatever raw-SVG escape hatch the codebase already uses for
one-off marks — check `M3e.Unsafe` usage precedent from Spec C before introducing a
new one). Not routed through `M3e.Icon`'s named-icon registry — that registry is
built for single-color icon-font-style glyphs, not two independently-fillable paths.

### Rail-toggle integration — no new Elm state

The existing toggle mechanism already swaps content by selection state via
`M3e.IconButton.selected`:

```elm
M3e.iconButton
    [ Aria.label "Toggle rail width", M3e.IconButton.toggle True, ... ]
    [ M3e.icon [ M3e.Icon.name "menu" ] []
    , M3e.IconButton.selected (M3e.icon [ M3e.Icon.name "menu_open" ] [])
    , M3e.navRailToggle [ M3e.NavRailToggle.for "nav-rail" ] []
    ]
```

The two named-icon children become the two tangram variants instead:

- Default slot (collapsed/closed state): both triangles `var(--md-sys-color-primary)`
  — the plain brand mark.
- `M3e.IconButton.selected` slot (expanded/open state): small triangle
  `var(--md-sys-color-inverse-surface)`, big triangle
  `var(--md-sys-color-inverse-primary)`.

No new `Msg`, no new model field, no port, no subscription to the nav-rail's own
expand/collapse state — the existing selected-slot swap already tracks that, we're
only changing what fills each slot.

### RTL mirror — CSS-only

Keyed off the `dir` value already flowing into `M3e.Theme`
(`Shared.elm:104,354,569,1012`, `TypedHtml.Values.Value TypedHtml.Values.Dir`, admits
`auto|ltr|rtl`) via a `:dir(rtl)` CSS selector (or a `scaleX(-1)` transform gated on a
logical-property-aware class) applied to the SVG wrapper. No Elm branching on `dir` at
render time — the existing document-level `dir` attribute already drives standard CSS
directionality selectors, this just adds one rule using that same mechanism.

### Favicon

`docs/public/favicon.svg` regenerated as the tangram glyph (both paths, plate/gradient
wrapper kept per Spec D's existing convention: 46×46 rounded rect with a gradient,
`viewBox="0 0 48 48"`, `role="img"`, `aria-label="elm-m3e"` — only the glyph itself
changes). Fill is baked in at build time to the **default theme's** primary color, not
a CSS variable (a standalone SVG document has no access to the host page's `:root`).

Per Jack's answer, this default isn't fully static either: a port
(`setFaviconColor : String -> Cmd msg`, shared with Spec E's port family) fires
whenever the user changes the seed color in the theme-editor drawer, and rewrites the
*served* favicon markup to match — practically, by updating the `<link rel="icon">`
element's `href` to a `data:image/svg+xml,...` URI carrying the new fill, generated in
JS from the same template the build-time generator uses. So: correct-by-default for a
fresh visitor (baked default primary), and correct-live for a visitor who's customized
their theme in-session (port-driven rewrite) — never claiming to be a live CSS
binding, because it structurally can't be one.

### Relationship to Spec D

Spec D (`specs/2026-08-05-favicon-material-palette-design.md`) proposed regenerating
`favicon.svg` from a Material Symbols "palette" glyph through the icon-registry
pipeline (Spec C). This spec **supersedes that glyph goal** — the tangram replaces the
palette glyph entirely, so Spec D's glyph-generation work does not get built. Spec D's
other content — the viewBox-transform-math writeup, the pinned-rasterizer tooling
decision (`@resvg/resvg-js`/`sharp` + `png-to-ico`, not system ImageMagick, for
drift-gating reasons), and the OG-PNG defect it uncovered (14 route modules pointing
at a 32×32 PNG wearing an `.ico` extension as their Open Graph image) — remains valid
and should be re-scoped onto the tangram glyph rather than discarded, at whatever
repo/plan holds this work next.

## Verification

- Nav-rail toggle renders the tangram in both slots; collapsing/expanding visibly
  swaps both triangles' colors with no flash of the old menu/menu_open icons.
- Changing the theme's primary color while the rail is visible repaints the in-app
  icon with no interaction needed (pure CSS custom property inheritance).
- Setting `dir` to `rtl` visibly mirrors the mark; `ltr`/`auto` (default) do not.
- `favicon.svg` is generated, not hand-edited (same drift-gating discipline as Spec
  D specified); default fill matches the shipped default theme's primary.
- Changing seed color in the theme-editor drawer visibly updates the browser tab's
  favicon within the same session, without a reload.
- `Site.elm:30`'s `Head.icon` reference and the OG-PNG's 14 route-module references
  (if folded into this work) still resolve correctly after the glyph swap.
