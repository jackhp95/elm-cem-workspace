# app-bar

**Family:** [Navigation](../concepts/choosing-components.md#navigation) · See also: [toolbar](toolbar.md), [nav-bar](nav-bar.md), [nav-rail](nav-rail.md), [nav-menu](nav-menu.md), [drawer-container](drawer-container.md), [tabs](tabs.md), [breadcrumb](breadcrumb.md), [toc](toc.md), [paginator](paginator.md), [stepper](stepper.md), [slide-group](slide-group.md)

The `m3e-app-bar` component is a prominent user interface component that provides consistent access to key actions, navigation, and contextual information at the top of an application screen. Designed according to Material 3 principles, it organizes content with clear hierarchy, supports dynamic color, elevation, alignment, and adapts to scrolling behavior.

```ts
import "@m3e/web/app-bar";
```

## Examples

```html
<m3e-app-bar size="medium">
  <m3e-icon-button slot="leading-icon" aria-label="Back">
    <m3e-icon name="arrow_back"></m3e-icon>
  </m3e-icon-button>
  <span slot="title">Top 10 hiking trails</span>
  <span slot="subtitle">Discover popular trails</span>
  <m3e-icon-button slot="trailing-icon" aria-label="Bookmark" variant="tonal">
    <m3e-icon name="bookmark" filled></m3e-icon>
  </m3e-icon-button>
</m3e-app-bar>
```

```html
<div style="overflow-y: auto; height: 300px" id="scrollContainer">
  <m3e-app-bar for="scrollContainer" style="position: sticky; top: 0">
    <span slot="title">Title</span>
  </m3e-app-bar>
  <div style="height: 400px; display: flex; align-items: center; justify-content: center">I am scrolling content</div>
</div>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Medium app bar with leading and trailing actions**

```html
<m3e-app-bar size="medium">
  <m3e-button slot="leading-icon" variant="text" aria-label="Back">
    <m3e-icon name="arrow_back"></m3e-icon>
  </m3e-button>
  <span slot="title">Top 10 hiking trails</span>
  <span slot="subtitle">Discover popular trails</span>
  <m3e-button slot="trailing-icon" variant="tonal" aria-label="Bookmark">
    <m3e-icon name="bookmark" filled></m3e-icon>
  </m3e-button>
</m3e-app-bar>
```

**Centered large app bar with trailing menu**

```html
<m3e-app-bar size="large" centered>
  <m3e-button slot="leading-icon" variant="text" aria-label="Open navigation">
    <m3e-icon name="menu"></m3e-icon>
  </m3e-button>
  <span slot="title">Inbox</span>
  <span slot="subtitle">24 unread messages</span>
  <m3e-button slot="trailing-icon" variant="text" aria-label="Search">
    <m3e-icon name="search"></m3e-icon>
  </m3e-button>
  <m3e-button slot="trailing-icon" variant="text" aria-label="More options">
    <m3e-icon name="more_vert"></m3e-icon>
  </m3e-button>
</m3e-app-bar>
```

## API

### `<m3e-app-bar>`

A bar, placed a the top of a screen, used to help users navigate through an application.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `centered` | `boolean` | false | Whether the title and subtitle are centered. |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |
| `size` | `"small" \| "medium" \| "large"` | "small" | The size of the bar. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |

**Slots**

| Slot | Description |
| --- | --- |
| `leading` | Renders content positioned at the start of the bar. |
| `subtitle` | Renders the subtitle of the bar. |
| `title` | Renders the title of the bar. |
| `trailing` | Renders one or more action buttons aligned to the end of the bar. |
| `leading-icon` | Deprecated: use the `leading` slot. |
| `trailing-icon` | Deprecated: use the `trailing` slot. |

**CSS custom properties** — 51 total across 23 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-app-bar-container-color` | Background color of the app bar container. |
| `--m3e-app-bar-container-color-on-scroll` | Background color of the app bar container when scrolled. |
| `--m3e-app-bar-container-elevation` | Elevation (shadow) of the app bar container. |
| `--m3e-app-bar-container-elevation-on-scroll` | Elevation (shadow) of the app bar container when scrolled. |
| `--m3e-app-bar-title-text-color` | Color of the app bar title text. |
| `--m3e-app-bar-subtitle-text-color` | Color of the app bar subtitle text. |
| `--m3e-app-bar-padding-left` | Left padding for the app bar container. |
| `--m3e-app-bar-padding-right` | Right padding for the app bar container. |
| `--m3e-app-bar-[size]-container-height` | Height of the small app bar container. |
| `--m3e-app-bar-[size]-title-text-font-size` | Font size for the small app bar title text. |
| `--m3e-app-bar-[size]-title-text-font-weight` | Font weight for the small app bar title text. |
| `--m3e-app-bar-[size]-title-text-line-height` | Line height for the small app bar title text. |

_…11 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/app-bar/README.md) (MIT). · Material spec: <https://m3.material.io/components/app-bars/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/app-bar/AppBarElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/app-bar/AppBarElement.ts)
