M3E layout follows Material's adaptive model: pick navigation and pane structure by
the **window size class**, not the device. The size classes and canonical layouts are
Material's; the components that realize them (`m3e-nav-bar`, `m3e-nav-rail`,
`m3e-drawer-container`, panes) are m3e.

## Window size classes

Material defines width breakpoints — compact, medium, expanded, large, extra-large
([breakpoints](https://m3.material.io/foundations/layout/breakpoints/overview)). Choose
the layout for the class, then let it adapt
([adaptive design](https://m3.material.io/foundations/layout/layout-overview/adaptive-design)).

## Navigation: bar vs rail vs drawer

The responsive navigation trio maps to size classes
([layout overview](https://m3.material.io/foundations/layout/layout-overview/overview)):

- **Compact** (phones) → use `m3e-nav-bar` (bottom bar)
  ([canonical layouts](https://m3.material.io/foundations/layout/canonical-examples/overview)).
- **Medium** (small tablets) → prefer `m3e-nav-rail` (side rail)
  ([canonical layouts](https://m3.material.io/foundations/layout/canonical-examples/overview)).
- **Expanded and up** → prefer `m3e-drawer-container` (persistent side drawer)
  ([canonical layouts](https://m3.material.io/foundations/layout/canonical-examples/overview)).

`m3e-nav-bar` and `m3e-nav-rail` take a `mode` (`auto` | `compact` | `expanded`); leave
it `auto` to let the component respond to its container. (m3e behavior)

```html
<m3e-nav-bar mode="auto">
  <m3e-nav-item href="/home" selected>
    <m3e-icon slot="icon" name="home"></m3e-icon>
    Home
  </m3e-nav-item>
  <m3e-nav-item href="/library">
    <m3e-icon slot="icon" name="library_books"></m3e-icon>
    Library
  </m3e-nav-item>
</m3e-nav-bar>
```

The drawer container hosts start/end drawers with a `mode`
(`auto` | `over` | `push` | `side`) per side; `over` floats above content on small
screens, `side` docks it on large ones. (m3e behavior)

```html
<m3e-drawer-container start start-mode="side">
  <m3e-content-pane slot="start">
    <m3e-nav-item href="/inbox">Inbox</m3e-nav-item>
  </m3e-content-pane>
  <m3e-content-pane>Main content</m3e-content-pane>
</m3e-drawer-container>
```

## Panes & canonical layouts

Material's canonical layouts (list-detail, supporting pane, feed) are built from panes
([canonical layouts](https://m3.material.io/foundations/layout/canonical-examples/overview)).
In m3e, `m3e-content-pane` is a shaped padded surface and `m3e-split-pane` is a resizable
two-pane region — use `m3e-split-pane` for a list-detail split
([scaffold panes](https://m3.material.io/foundations/layout/scaffold/panes)). (m3e behavior)

```html
<m3e-split-pane orientation="horizontal">
  <m3e-content-pane slot="start">List</m3e-content-pane>
  <m3e-content-pane slot="end">Detail</m3e-content-pane>
</m3e-split-pane>
```

## Spacing

Material's spacing scale drives gaps and margins between layout regions
([spacing](https://m3.material.io/styles/spacing/overview)); m3e surfaces spacing through
its density system — see [Density](density.md).

---
_See also: [Choosing components](choosing-components.md) · [Density](density.md) · [Accessibility](accessibility.md)._
