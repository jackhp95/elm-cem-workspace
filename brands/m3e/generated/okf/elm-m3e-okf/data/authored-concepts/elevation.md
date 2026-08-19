Elevation expresses hierarchy and layering. In Material 3 it is drawn with **tonal
color** (a surface tint that grows with height) plus a shadow. The level system is
Material's; m3e realizes it through surface tokens — there is no `elevation` attribute.

## The six levels

Material defines elevation levels 0–5, each a dp height mapped to a tonal-surface and
shadow pairing ([elevation](https://m3.material.io/styles/elevation/overview)). Higher is
closer to the user; you should raise a surface only to signal that it floats above its
neighbors ([applying elevation](https://m3.material.io/styles/elevation/applying-elevation)).

| Level | Typical surface |
| --- | --- |
| 0 | background, filled buttons at rest |
| 1 | cards, resting FAB, elevated buttons |
| 2 | resting search bar |
| 3 | menus, dialogs, resting nav drawer |
| 4–5 | transient/pressed peaks |

## How m3e sets it

m3e components carry their level through `--md-sys-elevation-*` and per-component
surface tokens rather than an attribute — so you change elevation by choosing the right
component/variant, not by setting a number
([elevation tokens](https://m3.material.io/styles/elevation/tokens)). (m3e behavior)

The clearest lever is a component's **variant**: an `elevated` card or button sits at a
resting level, a `filled` one is flat at level 0
([applying elevation](https://m3.material.io/styles/elevation/applying-elevation)). (m3e behavior)

```html
<m3e-card variant="elevated">
  <span slot="header">Floats above the page</span>
  Elevated surfaces use tonal color plus a shadow.
</m3e-card>

<m3e-card variant="filled">
  <span slot="header">Flat</span>
  Filled surfaces sit at level 0 — no shadow.
</m3e-card>
```

Avoid faking elevation with a custom `box-shadow`; it will not carry the tonal tint and
will drift from the token scale ([elevation](https://m3.material.io/styles/elevation/overview)). (m3e behavior)

---
_See also: [Design tokens](design-tokens.md) · [Shape](shape.md) · [Color & theming](color.md)._
