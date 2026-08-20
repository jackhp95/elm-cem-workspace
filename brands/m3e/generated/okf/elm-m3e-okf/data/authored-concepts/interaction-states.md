Every interactive Material component expresses the same set of visual states through a
**state layer** — a translucent overlay tinted by a color role. The state model is
Material's; the CSS tokens that implement it are m3e.

## The states

Material defines enabled, hover, focus, pressed, dragged, and disabled states
([interaction states](https://m3.material.io/foundations/interaction/states/overview)).
Hover/focus/pressed are drawn as a **state layer** at role-specific opacities
([state layers](https://m3.material.io/foundations/interaction/states/state-layers)); you
should not hand-build these overlays — m3e applies them automatically to its controls
([applying states](https://m3.material.io/foundations/interaction/states/applying-states)). (m3e behavior)

The state layer color and opacity come from `--md-sys-state-*` tokens (e.g.
`--md-sys-state-hover-state-layer-opacity`) tinted by the component's color role. (m3e behavior)

## Disabled vs disabled-interactive

A plain `disabled` control is inert and skipped by the tab order. When you need a
control that still receives focus and shows a tooltip explaining *why* it is
unavailable, prefer `disabled-interactive` — it keeps the control reachable for
assistive technology ([interaction states](https://m3.material.io/foundations/interaction/states/overview)). (m3e behavior)

```html
<m3e-button variant="filled" disabled>Unavailable</m3e-button>

<m3e-button variant="filled" disabled-interactive>
  Not yet
</m3e-button>
```

## Selected state

Toggleable controls carry a distinct **selected** state layered on top of the base
states ([interaction states](https://m3.material.io/foundations/interaction/states/overview)).
In m3e, toggle controls expose a `selected` attribute and, where relevant, a slot
for the selected glyph — on `m3e-icon-button` that slot is `selected` (button and
nav/tree items name it `selected-icon`). (m3e behavior)

```html
<m3e-icon-button toggle selected aria-label="Bookmark" variant="tonal">
  <m3e-icon name="bookmark_border"></m3e-icon>
  <m3e-icon slot="selected" name="bookmark"></m3e-icon>
</m3e-icon-button>
```

## Reduced motion

State transitions honor the user's motion preference — components respond to
`prefers-reduced-motion` and simplify or drop the animation
([interaction states](https://m3.material.io/foundations/interaction/states/overview)). (m3e behavior)

---
_See also: [Accessibility](accessibility.md) · [Motion](motion.md) · [Design tokens](design-tokens.md)._
