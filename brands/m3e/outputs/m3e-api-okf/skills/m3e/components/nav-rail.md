# nav-rail

**Family:** [Navigation](../concepts/choosing-components.md#navigation) · See also: [app-bar](app-bar.md), [toolbar](toolbar.md), [nav-bar](nav-bar.md), [nav-menu](nav-menu.md), [drawer-container](drawer-container.md), [tabs](tabs.md), [breadcrumb](breadcrumb.md), [toc](toc.md), [paginator](paginator.md), [stepper](stepper.md), [slide-group](slide-group.md)

The `m3e-nav-rail` component extends `@m3e/nav-bar` to provide a vertical navigation rail and interactive items for switching between primary destinations in your application. Designed for larger devices, the nav rail supports compact and expanded modes, orientation, selection, and extensive theming via CSS custom properties.

```ts
import "@m3e/web/nav-rail";
```

**Elements:** `<m3e-nav-rail>`, `<m3e-nav-rail-toggle>`

## Examples

```html
<m3e-nav-rail id="nav-rail" mode="auto">
  <m3e-icon-button toggle>
    <m3e-icon name="menu"></m3e-icon>
    <m3e-icon slot="selected" name="menu_open"></m3e-icon>
    <m3e-nav-rail-toggle for="nav-rail"></m3e-nav-rail-toggle>
  </m3e-icon-button>
  <m3e-fab size="small">
    <m3e-icon name="edit"></m3e-icon>
    <span slot="label">Extended</span>
  </m3e-fab>
  <m3e-nav-item><m3e-icon slot="icon" name="news"></m3e-icon>News</m3e-nav-item>
  <m3e-nav-item><m3e-icon slot="icon" name="globe"></m3e-icon>Global</m3e-nav-item>
  <m3e-nav-item><m3e-icon slot="icon" name="star"></m3e-icon>For you</m3e-nav-item>
  <m3e-nav-item><m3e-icon slot="icon" name="newsstand"></m3e-icon>Trending</m3e-nav-item>
</m3e-nav-rail>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Collapsible navigation rail with toggle**

```html
<m3e-nav-rail id="main-rail" mode="auto">
  <m3e-button toggle>
    <m3e-icon name="menu"></m3e-icon>
    <m3e-icon slot="selected" name="menu_open"></m3e-icon>
    <m3e-nav-rail-toggle for="main-rail"></m3e-nav-rail-toggle>
  </m3e-button>
  <m3e-nav-item selected>
    <m3e-icon slot="icon" name="dashboard"></m3e-icon>
    Dashboard
  </m3e-nav-item>
  <m3e-nav-item>
    <m3e-icon slot="icon" name="folder"></m3e-icon>
    Projects
  </m3e-nav-item>
  <m3e-nav-item>
    <m3e-icon slot="icon" name="insights"></m3e-icon>
    Reports
  </m3e-nav-item>
  <m3e-nav-item>
    <m3e-icon slot="icon" name="settings"></m3e-icon>
    Settings
  </m3e-nav-item>
</m3e-nav-rail>
```

**Expanded navigation rail with link destinations**

```html
<m3e-nav-rail id="docs-rail" mode="expanded">
  <m3e-nav-item href="/overview" selected>
    <m3e-icon slot="icon" name="home"></m3e-icon>
    <m3e-icon slot="selected-icon" name="home" filled></m3e-icon>
    Overview
  </m3e-nav-item>
  <m3e-nav-item href="/components">
    <m3e-icon slot="icon" name="widgets"></m3e-icon>
    Components
  </m3e-nav-item>
  <m3e-nav-item href="/guides">
    <m3e-icon slot="icon" name="menu_book"></m3e-icon>
    Guides
  </m3e-nav-item>
</m3e-nav-rail>
```

## API

### `<m3e-nav-rail>`

A vertical bar, typically used on larger devices, that allows a user to switch between views.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `"compact" \| "expanded" \| "auto"` | "compact" | The mode in which items in the rail are presented. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `items` _(readonly)_ | `readonly M3eNavItemElement[]` | The items of the bar. |
| `selected` _(readonly)_ | `M3eNavItemElement \| null` | The selected item. |
| `currentMode` | `Exclude<NavBarMode, "auto">` | The current mode applied to the bar. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the items of the bar. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` |  | Dispatched before the selected state of an item changes. |
| `input` |  | Dispatched when the selected state of an item changes. |
| `change` | `Event` | Dispatched when the selected state of an item changes. |

**CSS custom properties** — 17 total across 17 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-nav-rail-top-space` | Top block padding for the nav rail. |
| `--m3e-nav-rail-bottom-space` | Bottom block padding for the nav rail. |
| `--m3e-nav-rail-compact-width` | Width of the nav rail in compact mode. |
| `--m3e-nav-rail-inline-padding` | Inline padding for nav rail. |
| `--m3e-nav-rail-expanded-width` | Width of the nav rail in expanded mode. |
| `--m3e-nav-rail-expanded-item-height` | Height of nav items in expanded mode. |
| `--m3e-nav-rail-button-item-space` | Space below icon buttons and FABs. |
| `--m3e-nav-rail-icon-button-inset` | Inset for icon buttons. |
| `--m3e-nav-rail-expanded-inline-padding` | Deprecated, use `--m3e-nav-rail-inline-padding`. |
| `--m3e-nav-rail-expanded-min-width` | Deprecated, use `--m3e-nav-rail-expanded-width`. |
| `--m3e-nav-rail-expanded-max-width` | Deprecated, use `--m3e-nav-rail-expanded-width`. |
| `--m3e-nav-rail-expanded-icon-button-inset` | Deprecated, use `--m3e-nav-rail-icon-button-inset`. |

_…5 more families. See source for the full list._

### `<m3e-nav-rail-toggle>`

An element, nested within a clickable element, used to toggle the expanded state of a navigation rail.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/nav-rail/README.md) (MIT). · Material spec: <https://m3.material.io/components/navigation-rail/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/nav-rail/NavRailElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/nav-rail/NavRailElement.ts)
- [`packages/web/src/nav-rail/NavRailToggleElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/nav-rail/NavRailToggleElement.ts)

**README drift corrected** (2 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
