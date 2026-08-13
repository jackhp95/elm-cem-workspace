# nav-bar

**Family:** [Navigation](../concepts/choosing-components.md#navigation) · See also: [app-bar](app-bar.md), [toolbar](toolbar.md), [nav-rail](nav-rail.md), [nav-menu](nav-menu.md), [drawer-container](drawer-container.md), [tabs](tabs.md), [breadcrumb](breadcrumb.md), [toc](toc.md), [paginator](paginator.md), [stepper](stepper.md), [slide-group](slide-group.md)

The `m3e-nav-bar` and `m3e-nav-item` components provide a navigation bar and interactive items for switching between primary destinations in your application. Designed for smaller devices, they support 3-5 interactive items, orientation, selection, and extensive theming via CSS custom properties.

```ts
import "@m3e/web/nav-bar";
```

**Elements:** `<m3e-nav-bar>`, `<m3e-nav-item>`

## Examples

```html
<m3e-nav-bar>
  <m3e-nav-item><m3e-icon slot="icon" name="news"></m3e-icon>News</m3e-nav-item>
  <m3e-nav-item><m3e-icon slot="icon" name="globe"></m3e-icon>Global</m3e-nav-item>
  <m3e-nav-item><m3e-icon slot="icon" name="star"></m3e-icon>For you</m3e-nav-item>
  <m3e-nav-item><m3e-icon slot="icon" name="newsstand"></m3e-icon>Trending</m3e-nav-item>
</m3e-nav-bar>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Bottom navigation bar with selected destination**

```html
<nav>
  <m3e-nav-bar mode="compact">
    <m3e-nav-item selected>
      <m3e-icon slot="icon" name="home"></m3e-icon>
      <m3e-icon slot="selected-icon" name="home" filled></m3e-icon>
      Home
    </m3e-nav-item>
    <m3e-nav-item>
      <m3e-icon slot="icon" name="search"></m3e-icon>
      Explore
    </m3e-nav-item>
    <m3e-nav-item>
      <m3e-icon slot="icon" name="favorite"></m3e-icon>
      <m3e-icon slot="selected-icon" name="favorite" filled></m3e-icon>
      Saved
    </m3e-nav-item>
    <m3e-nav-item>
      <m3e-icon slot="icon" name="person"></m3e-icon>
      Profile
    </m3e-nav-item>
  </m3e-nav-bar>
</nav>
```

**Expanded nav bar linking to app sections**

```html
<nav>
  <m3e-nav-bar mode="expanded">
    <m3e-nav-item href="/inbox" selected>
      <m3e-icon slot="icon" name="inbox"></m3e-icon>
      Inbox
    </m3e-nav-item>
    <m3e-nav-item href="/sent">
      <m3e-icon slot="icon" name="send"></m3e-icon>
      Sent
    </m3e-nav-item>
    <m3e-nav-item href="/drafts">
      <m3e-icon slot="icon" name="drafts"></m3e-icon>
      Drafts
    </m3e-nav-item>
    <m3e-nav-item href="/archive" disabled>
      <m3e-icon slot="icon" name="archive"></m3e-icon>
      Archive
    </m3e-nav-item>
  </m3e-nav-bar>
</nav>
```

## API

### `<m3e-nav-bar>`

A horizontal bar, typically used on smaller devices, that allows a user to switch between 3-5 views.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `"compact" \| "expanded" \| "auto"` | "compact" | The mode in which items in the bar are presented. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `items` _(readonly)_ | `readonly M3eNavItemElement[]` | The items of the bar. |
| `selected` _(readonly)_ | `M3eNavItemElement \| null` | The selected item. |
| `currentMode` | `Exclude<NavBarMode, "auto">` | The current mode applied to the bar. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the items of the bar. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the selected state of an item changes. |
| `beforeinput` |  | Dispatched before the selected state of an item changes. |
| `input` |  | Dispatched when the selected state of an item changes. |

**CSS custom properties** — 5 total across 5 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-nav-bar-height` | Height of the navigation bar. |
| `--m3e-nav-bar-container-color` | Background color of the navigation bar container. |
| `--m3e-nav-bar-vertical-item-width` | Minimum width of vertical nav items. |
| `--m3e-nav-bar-horizontal-nav-item-leading-space` | Leading space for horizontal nav items. |
| `--m3e-nav-bar-horizontal-nav-item-trailing-space` | Trailing space for horizontal nav items. |

### `<m3e-nav-item>`

An item, placed in a navigation bar or rail, used to navigate to destinations in an application.

**Display:** `inline-block` · **Navigable:** carries a native `href` — do not wrap it in an `<a>`.

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | A value indicating whether the element is disabled. |
| `disabled-interactive` | `boolean` | false | A value indicating whether the element is disabled and interactive. |
| `download` | `string \| null` | null | A value indicating whether the `target` of the link button will be downloaded, optionally specifying the new name of the file. |
| `href` | `string` | "" | The URL to which the link button points. |
| `orientation` | `"vertical" \| "horizontal"` | "vertical" | The layout orientation of the item. |
| `rel` | `string` | "" | The relationship between the `target` of the link button and the document. |
| `selected` | `boolean` | false | A value indicating whether the element is selected. |
| `target` | `"_self" \| "_blank" \| "_parent" \| "_top" \| string` | "" | The target of the link button. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `navBar` _(readonly)_ | `M3eNavBarElement \| null` | The navigation bar to which this item belongs. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the item. |
| `icon` | Renders the icon of the item. |
| `selected-icon` | Renders the icon of the item when selected. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` | `Event` | Dispatched before the selected state changes. |
| `input` | `Event` | Dispatched when the selected state changes. |
| `change` | `Event` | Dispatched when the selected state changes. |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 28 total across 28 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-nav-item-label-text-font-size` | Font size for the label text. |
| `--m3e-nav-item-label-text-font-weight` | Font weight for the label text. |
| `--m3e-nav-item-label-text-line-height` | Line height for the label text. |
| `--m3e-nav-item-label-text-tracking` | Letter spacing for the label text. |
| `--m3e-nav-item-shape` | Border radius of the nav item. |
| `--m3e-nav-item-icon-size` | Size of the icon. |
| `--m3e-nav-item-spacing` | Spacing between icon and label. |
| `--m3e-nav-item-inactive-label-text-color` | Color of the label text when inactive. |
| `--m3e-nav-item-inactive-icon-color` | Color of the icon when inactive. |
| `--m3e-nav-item-inactive-hover-state-layer-color` | State layer color on hover when inactive. |
| `--m3e-nav-item-inactive-focus-state-layer-color` | State layer color on focus when inactive. |
| `--m3e-nav-item-inactive-pressed-state-layer-color` | State layer color on press when inactive. |

_…16 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/nav-bar/README.md) (MIT). · Material spec: <https://m3.material.io/components/navigation-bar/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/nav-bar/NavBarElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/nav-bar/NavBarElement.ts)
- [`packages/web/src/nav-bar/NavItemElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/nav-bar/NavItemElement.ts)

**README drift corrected** (3 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
