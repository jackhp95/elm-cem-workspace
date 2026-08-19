---
name: composing-m3e-layouts
description: >-
  Composes adaptive Material 3 app layouts in Elm with elm-m3e — list-detail, feed,
  supporting-pane, and the responsive nav chrome (NavRail on desktop, NavBar on mobile,
  AppBar on top). Use in projects using elm-m3e when the user is laying out a screen or
  app shell, asks how to make an m3e layout responsive/adaptive, which navigation
  component to use at a given window size, how to do two-pane / master-detail with m3e,
  or how to space and set density with tokens instead of ad-hoc CSS. Covers the
  window-size-class nav-component decision (bar vs rail vs drawer), the "layout is
  Tailwind, everything visual is tokens" boundary that the NoProprietaryDsClasses review
  rule enforces, and the real example screens (Mail, Settings, Shop, Travel, Dashboard).
  For picking a layer/form see building-m3e-uis; for theming/tokens see
  theming-m3e-apps; for judging the result see reviewing-m3e-designs.
---

# Composing M3e layouts

elm-m3e components are the structure; you compose them into adaptive screens. The real
example screens under `docs/app/Route/Examples/` (Mail, Settings, Shop, Travel,
Dashboard) are the worked reference — every pattern below is mined from what exists there
today. For the neutral layout *theory* (canonical adaptive patterns, breakpoints,
why supporting-pane over overlay), see the **m3e knowledge base's patterns** section
(`list-detail`, `feed`, `supporting-pane`, `navigation`, `forms`) and `foundations/adaptive-layouts`.

## The layout / visual boundary — the load-bearing rule

Every example screen states the same boundary in its module doc: **Tailwind (or any
utility CSS) is used ONLY for layout** — flex, grid, gap, padding, positioning,
responsive visibility. **Every visual token — color, typography, surface, shape,
density — comes through the components and the Kit.** Do not reach for a class to set a
color or a corner radius; that is what the component variants and `Kit.Surface` /
`Kit.Shape` are for.

The `NoProprietaryDsClasses` review rule (repo-local, `review/src/`) makes this
mechanical: `ds-`/`t-` design-system class tokens in an `Attr.class` literal are flagged.
The lesson generalizes — **re-skin through tokens, don't restyle through classes**
(see theming-m3e-apps).

```elm
-- GOOD: layout via utility classes, surface + shape + color via the Kit/components
Surface.view Surface.surfaceContainer
    [ Shape.corner Shape.large, Layout.class "overflow-hidden flex flex-col" ]
    rows

-- WRONG: a class doing a visual (color/shape) job
Native.div "rounded-3xl bg-primary-container p-4" rows
```

## Nav chrome by window size class

Every example uses the same adaptive pattern: **one `AppBar` on top, a `NavRail` shown
on desktop, a `NavBar` pinned to the bottom on mobile**, driven purely by responsive
visibility classes and the same destination list.

```elm
desktopRail : HtmlIr.Element.Element { s | navRail : M3e.Kind.Brand } adm_ msg
desktopRail =
    M3e.navRail [ Layout.class "hidden md:flex shrink-0" ]
        (List.map navItem destinations)

mobileBar : HtmlIr.Element.Element { s | navBar : M3e.Kind.Brand } adm_ msg
mobileBar =
    M3e.navBar [ Layout.class "md:hidden fixed inset-x-0 bottom-0" ]
        (List.map navItem destinations)
```

Selection by window size class (the m3e knowledge base's `navigation` pattern has the
neutral rationale and the standard breakpoints):

| Window size class | Nav component | In the examples |
|-------------------|---------------|-----------------|
| Compact (phone) | `M3e.NavBar` (bottom), 3–5 destinations | `md:hidden fixed inset-x-0 bottom-0` |
| Medium (tablet) | `M3e.NavRail` (side) | `hidden md:flex` |
| Expanded (desktop) | `M3e.NavRail`, optionally `M3e.modeExpanded` for labels | Mail rail uses `M3e.modeExpanded` |
| Large + persistent nav | `M3e.NavigationDrawer` | (component exists; not in current examples) |

Both nav copies share ONE `navItem` producer and ONE destination list, so they never
drift. Mark the active destination with `M3e.Attributes.selected`.

## Adaptive body patterns (mined from the examples)

- **List-detail / two-pane (Mail).** A reflowing body: on `md:` the list is a fixed
  `md:w-96` column beside a filling reading pane; below `md:` they stack (list first,
  detail beneath). `flex flex-1 flex-col md:flex-row`. Selecting a row repaints the pane
  and paints the active row with a `surfaceContainer` background.
- **Sectioned settings (Settings).** A width-constrained (`max-w-2xl`) scrolling column
  of `Kit.Surface` cards, each an overline heading over `ListItem` rows separated by
  `Divider`s. Only the content column scrolls (`h-screen overflow-hidden` pins the
  chrome).
- **Feed / card grids (Shop, Dashboard).** Card grids and KPI rows; a `FilterChipSet`
  toolbar drives the catalog; a `Fab` floats the primary action.
- **Hero + rails (Travel).** A `SearchBar` hero in a `Surface` panel, `Tabs` driving
  content, and horizontally-scrolling destination rails (`flex gap-4 overflow-x-auto`).

See the m3e knowledge base's `list-detail`, `feed`, and `supporting-pane` pattern pages
for when each applies and how it should adapt across size classes.

## Spacing and density via tokens, not ad-hoc CSS

- **Gaps/padding**: keep them on the layout layer, but consistent — the examples use a
  small vocabulary (`gap-2`, `gap-4`, `gap-6`, `px-4 py-6`). Don't invent per-screen
  spacing.
- **Density**: set globally through the theme, not per-component margins —
  `Theme.density -3 … 0` (see theming-m3e-apps and `M3e.Theme`). Touch targets must stay
  ≥48dp regardless of density (see making-m3e-accessible).
- **Shape/corners**: `Kit.Shape.corner Shape.large`, not a `rounded-*` class.

## The `Element` kind union for mixed lists

When one list holds rows of different component kinds (a `ListItem`, a `Divider`, a raw
`html` block), name a closed record union so they share one type — the Settings example's
`Row` alias is the template:

```elm
type alias Row msg =
    HtmlIr.Element.Element { html : M3e.Kind.Brand, listItem : M3e.Kind.Brand, divider : M3e.Kind.Brand } adm_ msg
```

Each producer returns an *open* row (`{ s | listItem : M3e.Kind.Brand }`), which widens to fill
this closed record. See `docs/app/Route/Examples/Settings.elm` for the full pattern.

> A fuller docs-site layout-examples build-out (a dedicated adaptive-patterns gallery) is
> a separate future task. Author from the existing example screens plus the knowledge
> base's pattern pages until it lands.

---
_Validated against elm-m3e 1.0.0, 2026-07._
