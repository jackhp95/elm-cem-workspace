Shape carries brand and hierarchy through corner rounding. Material 3 defines a corner-
radius scale and, in Expressive, shape **morphing** between states. The scale is
Material's; the `shape` attribute and `m3e-shape` element are m3e.

## The corner-radius scale

Material's shape scale runs from none through extra-small, small, medium, large,
extra-large, to full (pill) ([corner-radius scale](https://m3.material.io/styles/shape/corner-radius-scale)).
Each step is a `--md-sys-shape-corner-*` token; you should size a component's corners
from the scale rather than an arbitrary radius so shapes stay consistent
([shape principles](https://m3.material.io/styles/shape/overview-principles)). (m3e behavior)

## The `shape` attribute

Buttons, icon buttons, and toolbars expose a `shape` attribute
(`rounded` | `square`) — prefer `rounded` for standard actions and reserve `square`
for grouped or utilitarian controls
([shape principles](https://m3.material.io/styles/shape/overview-principles)). (m3e behavior)

```html
<m3e-button variant="filled" shape="rounded">Rounded</m3e-button>
<m3e-button variant="outlined" shape="square">Square</m3e-button>

<m3e-icon-button shape="square" variant="tonal" aria-label="Grid view">
  <m3e-icon name="grid_view"></m3e-icon>
</m3e-icon-button>
```

## Applying a Material shape to arbitrary content

The `m3e-shape` element clips its content to a named Material shape — use it to give a
non-Material surface (an image, a custom block) a spec shape instead of a hand-written
`clip-path` ([shape principles](https://m3.material.io/styles/shape/overview-principles)). (m3e behavior)

```html
<m3e-shape name="4-leaf-clover">
  <m3e-avatar>AB</m3e-avatar>
</m3e-shape>
```

## Shape morphing (Expressive)

In Material 3 Expressive, some controls **morph** their shape between rest, hover, and
pressed states ([shape morph](https://m3.material.io/styles/shape/shape-morph)). m3e drives
this from the shape tokens; you should not animate corner radius yourself — let the
component morph ([shape morph](https://m3.material.io/styles/shape/shape-morph)). (m3e behavior)

---
_See also: [Design tokens](design-tokens.md) · [Elevation](elevation.md) · [Interaction states](interaction-states.md)._
