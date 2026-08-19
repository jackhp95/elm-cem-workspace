Design tokens are named variables for visual decisions — color, type, shape, motion,
elevation — so a value is set once and referenced everywhere. Material defines the token
system; m3e implements it as CSS custom properties you can read and override.

## The token chain: ref → sys → component

Material tokens flow through three tiers
([design tokens](https://m3.material.io/foundations/design-tokens/overview)):

- **Reference** (`--md-ref-*`) — the raw palette/type primitives.
- **System** (`--md-sys-*`) — role-based, semantic tokens: this is the tier you use.
- **Component** (`--m3e-*`) — per-component values wired to system tokens. (m3e behavior)

You should theme against the **system** tier, not reference or component tokens
([how to use tokens](https://m3.material.io/foundations/design-tokens/how-to-use-tokens)) —
system tokens are the stable, role-named contract; component tokens are for fine-tuning
one element ([how to use tokens](https://m3.material.io/foundations/design-tokens/how-to-use-tokens)). (m3e behavior)

## Reading the common system tokens

| Prefix | Covers |
| --- | --- |
| `--md-sys-color-*` | color roles (`primary`, `on-primary`, `surface`, `outline`, …) |
| `--md-sys-typescale-*` | type roles (`body-large`, `label-large`, …) |
| `--md-sys-shape-*` | corner radii |
| `--md-sys-motion-*` | easing + duration |
| `--md-sys-elevation-*` | elevation levels |
| `--md-sys-state-*` | state-layer opacities |

## Setting tokens with the theme component

Prefer the `m3e-theme` component over writing `--md-sys-*` values by hand — it generates
a full, contrast-correct token set from one source color and applies it to its subtree
([how to use tokens](https://m3.material.io/foundations/design-tokens/how-to-use-tokens)). (m3e behavior)

```html
<m3e-theme color="#6750A4" scheme="auto" variant="expressive">
  <m3e-button variant="filled">Themed</m3e-button>
</m3e-theme>
```

For a one-off override, set a component (`--m3e-*`) token in scope rather than editing a
system token globally ([how to use tokens](https://m3.material.io/foundations/design-tokens/how-to-use-tokens)). (m3e behavior)

---
_See also: [Color & theming](color.md) · [Elevation](elevation.md) · [Shape](shape.md) · [Typography](typography.md)._
