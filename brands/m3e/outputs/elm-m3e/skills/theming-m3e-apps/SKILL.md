---
name: theming-m3e-apps
description: >-
  Themes elm-m3e Material 3 apps in Elm — root theming with the M3e.Theme component,
  color roles and token families, dark/dynamic color, density, and the Tailwind bridge.
  Use in projects using elm-m3e when the user wants to set an app's brand/seed color,
  add a dark mode or light/dark toggle, adjust contrast or density, apply Material color
  roles (primary, surface, on-surface, tertiary…), or asks how m3e styling relates to
  Tailwind. Covers the M3e.Theme root wrapper (color/scheme/contrast/density/strongFocus/
  motion), the "re-skin, don't restyle" principle (design tokens over class overrides,
  enforced by NoProprietaryDsClasses), and the config/ATTRIBUTION.md Tailwind bridge. For
  neutral color/typography/token theory link the m3e knowledge base. For building
  components see building-m3e-uis; for layout see composing-m3e-layouts.
---

# Theming M3e apps

Material 3 theming is **token-driven**: you set a small number of inputs (a seed color, a
scheme, a contrast, a density) and the system derives the full role palette
(primary/secondary/tertiary, their containers, surfaces, outline, error, …). elm-m3e
exposes this through the `M3e.Theme` component. For the neutral *theory* — how dynamic
color derives a palette from one seed, the tonal system, the type scale, what design
tokens are — see the **m3e knowledge base's `styles/color`, `styles/typography`, and
`foundations/design-tokens` pages**. This skill is the Elm practice.

## Root theming with `M3e.Theme`

Wrap the app (or a subtree) in `Theme.view`. It is token-driven — one seed color plus
scheme/contrast/density attributes, no hand-authored palette. The docs app themes at the
root in `docs/app/Shared.elm`:

```elm
import M3e.Theme as Theme

Theme.view
    [ Theme.color model.seed              -- the brand/seed color, e.g. "#4285F4"
    , Theme.scheme (schemeToken model.scheme)   -- M3e.Values.light | M3e.Values.dark
    , Theme.contrast (contrastToken model.contrast) -- standard | medium | high
    , Theme.density model.density          -- 0 (default) down to -3 (compact)
    ]
    [ appBody ]
```

Available `Theme` attributes: `color`, `scheme`, `contrast`, `density`, `strongFocus`
(strengthen the focus ring — an a11y aid, see making-m3e-accessible), and `withMotion`
(`Theme.MotionStandard` for functional transitions, `Theme.MotionExpressive` for
spring-like emphasis — see `docs/app/Route/Styles/Motion.elm` and the knowledge base's
`styles/motion`). Everything nested inside inherits the derived tokens.

## Color roles, not raw colors

Never paint with a hex value in your views. Use the **role** the element plays, exposed
through the Kit's color helpers and the surface roles:

- **Surfaces**: `Kit.Surface.surface`, `surfaceContainer`, … — background roles with the
  right elevation tint. The active-row/selected-card tint in the examples is a surface
  role swap (`surface` → `surfaceContainer`), not a class.
- **Content-on-surface**: `Kit.onSurface`, `Kit.onSurfaceVariant` — foreground roles that
  keep contrast correct against their surface automatically. Emphasis (title vs
  supporting text) uses the *role*, not a darker hex.
- The full role set (primary / on-primary / primary-container / … / tertiary / error /
  outline / scrim / surface-tint) is what a seed color derives; see the swatch grid in
  `M3e.Theme`'s own doc example and the knowledge base's `styles/color` for what each role
  is *for*.

Picking a role by intent (a primary action gets `primary`; a rating chip leans on
`tertiary` to keep `primary` reserved for actions, as the Mail reading pane notes) is a
design judgment — see reviewing-m3e-designs.

## Dark and dynamic color

Dark mode is a **scheme swap**, not a second stylesheet: flip `Theme.scheme` between
`M3e.Values.light` and `M3e.Values.dark` (the docs app holds `scheme` in its `Shared.Model`
and toggles it). Dynamic color is a **seed swap**: change `Theme.color` and the whole role
palette re-derives — no per-role editing. Contrast is orthogonal (`standard`/`medium`/
`high`) for accessibility needs.

## Re-skin, don't restyle

The governing principle: **change the theme inputs (tokens), do not override component
styles with classes.** A brand refresh is a new seed color and maybe a shape/density
tweak — a handful of `Theme` attributes — not a sheet of `!important` overrides on shadow
parts.

This is enforced mechanically. The repo-local `NoProprietaryDsClasses` rule
(`review/src/`) flags `ds-`/`t-` design-system class tokens in `Attr.class` literals, and
the layout/visual boundary (see composing-m3e-layouts) keeps classes to layout only. If
you find yourself writing a class to change a color, corner, or elevation, the right move
is a token: a color role, `Kit.Shape.corner`, or a `Theme` attribute.

## The Tailwind bridge

Utility CSS (Tailwind, in the docs app) is legitimate — for **layout only** (flex, grid,
gap, padding, positioning, responsive visibility). It never sets a visual token. Where the
docs deliberately cross into `Seam` to bridge Tailwind (e.g. surface-as-attribute), that
crossing is confined to blessed adapter modules and audited by
`NoSeamOutsideAllowedModules` in the `CodegenReviewConfig` (see `review/README.md`).

Attribution note: the native HTML element/attribute doc summaries in the native-HTML brand
(`TypedHtml.*` / the userland `docs/kit/Native.elm`) are adapted from MDN under CC BY-SA 2.5
— see [`config/ATTRIBUTION.md`](../../config/ATTRIBUTION.md).
(This is a licensing credit, not a styling mechanism; the "Tailwind bridge" is the
layout-only utility boundary above.)

## Reference

- `docs/app/Shared.elm` — root `Theme.view` wiring with a live scheme/contrast/density
  toggle.
- `M3e.Theme`'s module doc (`src/M3e/Theme.elm`) — the color-role swatch grid and every
  `Theme` attribute demonstrated.
- The m3e knowledge base's `styles/color`, `styles/typography`, `styles/elevation`, and
  `foundations/design-tokens` — the neutral theory this skill applies.

---
_Validated against elm-m3e 1.0.0, 2026-07._
