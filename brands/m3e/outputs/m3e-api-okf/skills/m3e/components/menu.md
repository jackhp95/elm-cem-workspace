# menu

**Family:** [Containers & surfaces](../concepts/choosing-components.md#containers) · See also: [card](card.md), [content-pane](content-pane.md), [dialog](dialog.md), [bottom-sheet](bottom-sheet.md), [split-pane](split-pane.md), [expansion-panel](expansion-panel.md), [divider](divider.md)

The `@m3e/web/menu` module provides a cohesive set of components for constructing accessible, anchored menus that align with Material 3 design guidance. It supports both single and multi-selection patterns, nested menu hierarchies, and dynamically positioned floating panels. Menus are triggered from interactive elements and present checkable or exclusive choices using item variants. Grouping primitives establish selection boundaries, while nested flows support layered navigation and progressive disclosure.

```ts
import "@m3e/web/menu";
```

**Elements:** `<m3e-menu>`, `<m3e-menu-item>`, `<m3e-menu-item-checkbox>`, `<m3e-menu-item-group>`, `<m3e-menu-item-radio>`, `<m3e-menu-trigger>`

## Examples

```html
<m3e-button>
  <m3e-menu-trigger for="menu1">Basic menu</m3e-menu-trigger>
</m3e-button>
<m3e-menu id="menu1">
  <m3e-menu-item>Apple</m3e-menu-item>
  <m3e-menu-item>Apricot</m3e-menu-item>
  <m3e-menu-item>Avocado</m3e-menu-item>
  <m3e-menu-item>Green Apple</m3e-menu-item>
  <m3e-menu-item>Green Grapes</m3e-menu-item>
  <m3e-menu-item>Olive</m3e-menu-item>
  <m3e-menu-item>Orange</m3e-menu-item>
</m3e-menu>
```

```html
<m3e-button>
  <m3e-menu-trigger for="menu2">Nested menus</m3e-menu-trigger>
</m3e-button>
<m3e-menu id="menu2">
  <m3e-menu-item>
    <m3e-menu-trigger for="menu3">Fruits with A</m3e-menu-trigger>
  </m3e-menu-item>
  <m3e-menu-item>Grapes</m3e-menu-item>
  <m3e-menu-item>Olive</m3e-menu-item>
  <m3e-menu-item>Orange</m3e-menu-item>
</m3e-menu>
<m3e-menu id="menu3">
  <m3e-menu-item>Apricot</m3e-menu-item>
  <m3e-menu-item>Avocado</m3e-menu-item>
  <m3e-menu-item>
    <m3e-menu-trigger for="menu4">Apples</m3e-menu-trigger>
  </m3e-menu-item>
</m3e-menu>
<m3e-menu id="menu4">
  <m3e-menu-item>Fuji</m3e-menu-item>
  <m3e-menu-item>Granny Smith</m3e-menu-item>
  <m3e-menu-item>Red Delicious</m3e-menu-item>
</m3e-menu>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Basic action menu triggered from a button**

```html
<m3e-button variant="outlined">
  <m3e-menu-trigger for="file-menu">File</m3e-menu-trigger>
  <m3e-icon slot="trailing-icon" name="arrow_drop_down"></m3e-icon>
</m3e-button>
<m3e-menu id="file-menu">
  <m3e-menu-item>
    <m3e-icon slot="icon" name="note_add"></m3e-icon>
    New document
  </m3e-menu-item>
  <m3e-menu-item>
    <m3e-icon slot="icon" name="folder_open"></m3e-icon>
    Open
  </m3e-menu-item>
  <m3e-menu-item disabled>
    <m3e-icon slot="icon" name="save"></m3e-icon>
    Save
  </m3e-menu-item>
</m3e-menu>
```

**View menu with checkbox and radio selection groups**

```html
<m3e-button variant="text">
  <m3e-menu-trigger for="view-menu">View</m3e-menu-trigger>
</m3e-button>
<m3e-menu id="view-menu" variant="vibrant">
  <m3e-menu-item-checkbox checked>
    Show sidebar
  </m3e-menu-item-checkbox>
  <m3e-menu-item-checkbox>
    Show status bar
  </m3e-menu-item-checkbox>
  <hr>
  <m3e-menu-item-group>
    <m3e-menu-item-radio checked>Comfortable</m3e-menu-item-radio>
    <m3e-menu-item-radio>Cozy</m3e-menu-item-radio>
    <m3e-menu-item-radio>Compact</m3e-menu-item-radio>
  </m3e-menu-item-group>
</m3e-menu>
```

**Nested submenu for sharing options**

```html
<m3e-button variant="filled">
  <m3e-menu-trigger for="share-menu">Share</m3e-menu-trigger>
</m3e-button>
<m3e-menu id="share-menu">
  <m3e-menu-item>
    <m3e-icon slot="icon" name="link"></m3e-icon>
    Copy link
  </m3e-menu-item>
  <m3e-menu-item>
    <m3e-icon slot="icon" name="group"></m3e-icon>
    <m3e-menu-trigger for="people-menu">Share with people</m3e-menu-trigger>
    <m3e-icon slot="trailing-icon" name="chevron_right"></m3e-icon>
  </m3e-menu-item>
</m3e-menu>
<m3e-menu id="people-menu" submenu position-x="after">
  <m3e-menu-item>Alex Chen</m3e-menu-item>
  <m3e-menu-item>Jordan Lee</m3e-menu-item>
  <m3e-menu-item>Sam Rivera</m3e-menu-item>
</m3e-menu>
```

## API

### `<m3e-menu>`

Presents a list of choices on a temporary surface.

**Display:** `none`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `position-x` | `"before" \| "after"` | "after" | The position of the menu, on the x-axis. |
| `position-y` | `"above" \| "below"` | "below" | The position of the menu, on the y-axis. |
| `variant` | `"standard" \| "vibrant"` | "standard" | The appearance variant of the menu. |
| `submenu` | `boolean` | false | A value indicating whether the menu is a submenu. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `items` _(readonly)_ | `ReadonlyArray<MenuItemElementBase>` | The items of the menu. |
| `isOpen` _(readonly)_ |  | A value indicating whether the menu is open. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the contents of the menu. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforetoggle` |  | Dispatched before the toggle state changes. |
| `toggle` |  | Dispatched after the toggle state has changed. |

**CSS custom properties** — 12 total across 12 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-menu-container-shape` | Controls the corner radius of the menu container. |
| `--m3e-menu-active-container-shape` | Controls the corner radius of the menu container when active. |
| `--m3e-menu-container-min-width` | Minimum width of the menu container. |
| `--m3e-menu-container-max-width` | Maximum width of the menu container. |
| `--m3e-menu-container-max-height` | Maximum height of the menu container. |
| `--m3e-menu-container-padding-block` | Vertical padding inside the menu container. |
| `--m3e-menu-container-padding-inline` | Horizontal padding inside the menu container. |
| `--m3e-menu-container-color` | Background color of the menu container. |
| `--m3e-menu-container-elevation` | Box shadow elevation of the menu container. |
| `--m3e-vibrant-menu-container-color` | Background color of the menu container for vibrant variant. |
| `--m3e-menu-divider-spacing` | Vertical spacing around slotted `m3e-divider` elements. |
| `--m3e-menu-gap` | Gap between content in the menu. |

### `<m3e-menu-item>`

An item of a menu.

**Display:** `none` · **Navigable:** carries a native `href` — do not wrap it in an `<a>`.

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `download` | `string \| null` | null | Whether the `target` of the link button will be downloaded, optionally specifying the new name of the file. |
| `href` | `string` | "" | The URL to which the link button points. |
| `rel` | `string` | "" | The relationship between the `target` of the link button and the document. |
| `target` | `"_self" \| "_blank" \| "_parent" \| "_top" \| string` | "" | The target of the link button. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `submenu` _(readonly)_ | `M3eMenuElement \| null` | The submenu triggered by the item. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `menu` _(readonly)_ | `M3eMenuElement \| null` | The menu to which this item belongs. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the item. |
| `icon` | Renders an icon before the items's label. |
| `trailing-icon` | Renders an icon after the item's label. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 37 total across 37 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-menu-item-container-height` | Height of the menu item container. |
| `--m3e-menu-item-color` | Text color for unselected, enabled menu items. |
| `--m3e-menu-item-container-hover-color` | State layer hover color for unselected items. |
| `--m3e-menu-item-container-focus-color` | State layer focus color for unselected items. |
| `--m3e-menu-item-ripple-color` | Ripple color for unselected items. |
| `--m3e-menu-item-selected-color` | Text color for selected items. |
| `--m3e-menu-item-selected-container-color` | Background color for selected items. |
| `--m3e-menu-item-selected-container-hover-color` | State layer hover color for selected items. |
| `--m3e-menu-item-selected-container-focus-color` | State layer focus color for selected items. |
| `--m3e-menu-item-selected-ripple-color` | Ripple color for selected items. |
| `--m3e-menu-item-active-state-layer-color` | State layer color for expanded items. |
| `--m3e-menu-item-active-state-layer-opacity` | State layer opacity for expanded items. |

_…25 more families. See source for the full list._

### `<m3e-menu-item-checkbox>`

An item of a menu which supports a checkable state.

**Display:** `none`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `checked` | `boolean` | false | Whether the element is checked. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `menu` _(readonly)_ | `M3eMenuElement \| null` | The menu to which this item belongs. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the item. |
| `icon` | Renders an icon before the items's label. |
| `trailing-icon` | Renders an icon after the item's label. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 38 total across 38 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-menu-item-container-height` | Height of the menu item container. |
| `--m3e-menu-item-color` | Text color for unselected, enabled menu items. |
| `--m3e-menu-item-container-hover-color` | State layer hover color for unselected items. |
| `--m3e-menu-item-container-focus-color` | State layer focus color for unselected items. |
| `--m3e-menu-item-ripple-color` | Ripple color for unselected items. |
| `--m3e-menu-item-selected-color` | Text color for selected items. |
| `--m3e-menu-item-selected-container-color` | Background color for selected items. |
| `--m3e-menu-item-selected-container-hover-color` | State layer hover color for selected items. |
| `--m3e-menu-item-selected-container-focus-color` | State layer focus color for selected items. |
| `--m3e-menu-item-selected-ripple-color` | Ripple color for selected items. |
| `--m3e-menu-item-active-state-layer-color` | State layer color for expanded items. |
| `--m3e-menu-item-active-state-layer-opacity` | State layer opacity for expanded items. |

_…26 more families. See source for the full list._

### `<m3e-menu-item-group>`

Groups related items (such a radios) in a menu.

**Display:** `contents`

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the contents of the group. |

### `<m3e-menu-item-radio>`

An item of a menu which supports a mutually exclusive checkable state.

**Display:** `none`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `checked` | `boolean` | false | Whether the element is checked. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `menu` _(readonly)_ | `M3eMenuElement \| null` | The menu to which this item belongs. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the item. |
| `icon` | Renders an icon before the items's label. |
| `trailing-icon` | Renders an icon after the item's label. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 38 total across 38 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-menu-item-container-height` | Height of the menu item container. |
| `--m3e-menu-item-color` | Text color for unselected, enabled menu items. |
| `--m3e-menu-item-container-hover-color` | State layer hover color for unselected items. |
| `--m3e-menu-item-container-focus-color` | State layer focus color for unselected items. |
| `--m3e-menu-item-ripple-color` | Ripple color for unselected items. |
| `--m3e-menu-item-selected-color` | Text color for selected items. |
| `--m3e-menu-item-selected-container-color` | Background color for selected items. |
| `--m3e-menu-item-selected-container-hover-color` | State layer hover color for selected items. |
| `--m3e-menu-item-selected-container-focus-color` | State layer focus color for selected items. |
| `--m3e-menu-item-selected-ripple-color` | Ripple color for selected items. |
| `--m3e-menu-item-active-state-layer-color` | State layer color for expanded items. |
| `--m3e-menu-item-active-state-layer-opacity` | State layer opacity for expanded items. |

_…26 more families. See source for the full list._

### `<m3e-menu-trigger>`

An element, nested within a clickable element, used to open a menu.

**Display:** `none`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `menu` _(readonly)_ | `M3eMenuElement \| null` | The menu triggered by the element. |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the contents of the trigger. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/menu/README.md) (MIT). · Material spec: <https://m3.material.io/components/menus/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/menu/MenuElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/menu/MenuElement.ts)
- [`packages/web/src/menu/MenuItemElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/menu/MenuItemElement.ts)
- [`packages/web/src/menu/MenuItemCheckboxElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/menu/MenuItemCheckboxElement.ts)
- [`packages/web/src/menu/MenuItemGroupElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/menu/MenuItemGroupElement.ts)
- [`packages/web/src/menu/MenuItemRadioElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/menu/MenuItemRadioElement.ts)
- [`packages/web/src/menu/MenuTriggerElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/menu/MenuTriggerElement.ts)

**README drift corrected** (5 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
