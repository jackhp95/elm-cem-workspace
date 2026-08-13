# nav-menu

**Family:** [Navigation](../concepts/choosing-components.md#navigation) · See also: [app-bar](app-bar.md), [toolbar](toolbar.md), [nav-bar](nav-bar.md), [nav-rail](nav-rail.md), [drawer-container](drawer-container.md), [tabs](tabs.md), [breadcrumb](breadcrumb.md), [toc](toc.md), [paginator](paginator.md), [stepper](stepper.md), [slide-group](slide-group.md)

The `m3e-nav-menu` component provides a hierarchical, accessible navigation menu. Designed for sidebars, navigation drawers, and complex menu structures, it supports nested expandable items, keyboard navigation, selection, and extensive theming via CSS custom properties.

```ts
import "@m3e/web/nav-menu";
```

**Elements:** `<m3e-nav-menu>`, `<m3e-nav-menu-item>`, `<m3e-nav-menu-item-group>`

## Examples

```html
<m3e-nav-menu>
  <m3e-nav-menu-item-group>
    <m3e-heading slot="label" variant="label" size="large">Mail</m3e-heading>

    <m3e-nav-menu-item>
      <m3e-icon slot="icon" name="mail"></m3e-icon>
      <span slot="label">Inbox</span>
      <span slot="badge">24</span>
    </m3e-nav-menu-item>

    <m3e-nav-menu-item>
      <m3e-icon slot="icon" name="send"></m3e-icon>
      <span slot="label">Outbox</span>
    </m3e-nav-menu-item>

    <m3e-nav-menu-item>
      <m3e-icon slot="icon" name="favorite"></m3e-icon>
      <span slot="label">Favorites</span>
    </m3e-nav-menu-item>

    <m3e-nav-menu-item>
      <m3e-icon slot="icon" name="delete"></m3e-icon>
      <span slot="label">Trash</span>
    </m3e-nav-menu-item>
  </m3e-nav-menu-item-group>
</m3e-nav-menu>
```

```html
<m3e-nav-menu>
  <m3e-nav-menu-item open>
    <m3e-icon slot="icon" name="rocket_launch"></m3e-icon>
    <span slot="label">Getting Started</span>
    <m3e-nav-menu-item>
      <m3e-icon slot="icon" name="widgets"></m3e-icon>
      <span slot="label">Overview</span>
    </m3e-nav-menu-item>
    <m3e-nav-menu-item>
      <m3e-icon slot="icon" name="package_2"></m3e-icon>
      <span slot="label">Installation</span>
    </m3e-nav-menu-item>
  </m3e-nav-menu-item>
  <m3e-nav-menu-item>
    <span slot="label">Actions</span>
    <m3e-nav-menu-item><span slot="label">Button</span></m3e-nav-menu-item>
    <m3e-nav-menu-item><span slot="label">Icon</span></m3e-nav-menu-item>
    <m3e-nav-menu-item><span slot="label">Icon Button</span></m3e-nav-menu-item>
  </m3e-nav-menu-item>
</m3e-nav-menu>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Nested navigation menu with icons, badges, and links**

```html
<m3e-nav-menu>
  <m3e-nav-menu-item selected>
    <m3e-icon slot="icon" name="home"></m3e-icon>
    <a slot="label" href="/">Home</a>
  </m3e-nav-menu-item>
  <m3e-divider></m3e-divider>
  <m3e-nav-menu-item open>
    <m3e-icon slot="icon" name="edit_note"></m3e-icon>
    <span slot="label">Work</span>
    <m3e-nav-menu-item>
      <m3e-icon slot="icon" name="article"></m3e-icon>
      <span slot="label">Articles</span>
      <span slot="badge">12</span>
    </m3e-nav-menu-item>
  </m3e-nav-menu-item>
</m3e-nav-menu>
```

_Source: 2026: src/components/NavFab.astro_

## API

### `<m3e-nav-menu>`

A hierarchical menu, typically used on larger devices, that allows a user to switch between views.

**Display:** `block`

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `selected` _(readonly)_ | `M3eNavMenuItemElement \| null` | The selected item of the menu. |
| `items` _(readonly)_ | `readonly M3eNavMenuItemElement[]` | All the items of the menu. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the items of the menu. |

**CSS custom properties** — 7 total across 7 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-nav-menu-padding-top` | Top padding for the menu. |
| `--m3e-nav-menu-padding-bottom` | Bottom padding for the menu. |
| `--m3e-nav-menu-padding-left` | Left padding for the menu. |
| `--m3e-nav-menu-padding-right` | Right padding for the menu. |
| `--m3e-nav-menu-divider-margin` | Margin for divider elements in the menu. |
| `--m3e-nav-menu-scrollbar-width` | Width of the menu scrollbar. |
| `--m3e-nav-menu-scrollbar-color` | Color of the menu scrollbar. |

### `<m3e-nav-menu-item>`

An expandable item, selectable item within a navigation menu.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `open` | `boolean` | false | Whether the item is expanded. |
| `selected` | `boolean` | false | Whether the item is selected. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `link` _(readonly)_ | `HTMLAnchorElement \| null` | A reference to the nested `HTMLAnchorElement`. |
| `label` _(readonly)_ | `HTMLElement \| null` | A reference to the element used to present the label of the item. |
| `visible` _(readonly)_ | `boolean` | Whether the item is visible. |
| `path` _(readonly)_ | `ReadonlyArray<M3eNavMenuItemElement>` | The full path of the item, starting with the top-most ancestor, including this item. |
| `hasChildItems` _(readonly)_ | `boolean` | Whether the item has child items. |
| `parentItem` _(readonly)_ | `M3eNavMenuItemElement \| null` | The parenting item. |
| `childItems` _(readonly)_ | `readonly M3eNavMenuItemElement[]` | The items that immediately descend from this item. |
| `level` _(readonly)_ | `number` | The one-based level of the item. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the nested child items. |
| `label` | Renders the label of the item. |
| `icon` | Renders the icon of the item. |
| `badge` | Renders the badge of the item. |
| `selected-icon` | Renders the icon of the item when selected. |
| `toggle-icon` | Renders the toggle icon. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `opening` |  | Dispatched when the item begins to open. |
| `opened` |  | Dispatched when the item has opened. |
| `closing` |  | Dispatched when the item begins to close. |
| `closed` |  | Dispatched when the item has closed. |
| `click` |  | Dispatched when the element is clicked. |

**CSS custom properties** — 31 total across 31 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-nav-menu-item-font-size` | Font size for the item label. |
| `--m3e-nav-menu-item-font-weight` | Font weight for the item label. |
| `--m3e-nav-menu-item-line-height` | Line height for the item label. |
| `--m3e-nav-menu-item-tracking` | Letter spacing for the item label. |
| `--m3e-nav-menu-item-padding` | Inline padding for the item. |
| `--m3e-nav-menu-item-height` | Height of the item. |
| `--m3e-nav-menu-item-spacing` | Spacing between icon and label. |
| `--m3e-nav-menu-item-shape` | Border radius of the item and focus ring. |
| `--m3e-nav-menu-item-icon-size` | Size of the icon. |
| `--m3e-nav-menu-item-inset` | Indentation for nested items. |
| `--m3e-nav-menu-item-label-color` | Text color for the item label. |
| `--m3e-nav-menu-item-selected-label-color` | Text color for selected item label. |

_…19 more families. See source for the full list._

### `<m3e-nav-menu-item-group>`

A top-level semantic grouping of items in a navigation menu.

**Display:** `contents`

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the items of the group. |
| `label` | Renders the label of the group. |

**CSS custom properties** — 2 total across 2 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-nav-menu-item-group-label-inset` | Insets the label from the start edge of the group. |
| `--m3e-nav-menu-item-group-label-space` | Vertical spacing around the group's label. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/nav-menu/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/nav-menu/NavMenuElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/nav-menu/NavMenuElement.ts)
- [`packages/web/src/nav-menu/NavMenuItemElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/nav-menu/NavMenuItemElement.ts)
- [`packages/web/src/nav-menu/NavMenuItemGroupElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/nav-menu/NavMenuItemGroupElement.ts)
