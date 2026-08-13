# fab-menu

**Family:** [Actions & buttons](../concepts/choosing-components.md#actions) · See also: [button](button.md), [icon-button](icon-button.md), [fab](fab.md), [split-button](split-button.md), [button-group](button-group.md), [segmented-button](segmented-button.md)

The `m3e-fab-menu` component presents a dynamic menu of related actions, elegantly revealed from a floating action button (FAB). Designed using expressive, adaptive surfaces, it enables seamless access to contextual actions in modern, visually rich interfaces.

```ts
import "@m3e/web/fab-menu";
```

**Elements:** `<m3e-fab-menu>`, `<m3e-fab-menu-item>`, `<m3e-fab-menu-trigger>`

## Examples

```html
<m3e-fab variant="primary" size="large">
  <m3e-fab-menu-trigger for="fabmenu">
    <m3e-icon name="edit"></m3e-icon>
  </m3e-fab-menu-trigger>
</m3e-fab>
<m3e-fab-menu id="fabmenu" variant="secondary">
  <m3e-fab-menu-item>First</m3e-fab-menu-item>
  <m3e-fab-menu-item>Second</m3e-fab-menu-item>
  <m3e-fab-menu-item>Third</m3e-fab-menu-item>
  <m3e-fab-menu-item>Forth</m3e-fab-menu-item>
  <m3e-fab-menu-item>Fifth</m3e-fab-menu-item>
  <m3e-fab-menu-item>Sixth</m3e-fab-menu-item>
</m3e-fab-menu>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Primary FAB revealing a secondary action menu**

```html
<m3e-button variant="filled" size="large">
  <m3e-fab-menu-trigger for="compose-menu"></m3e-fab-menu-trigger>
  <m3e-icon slot="icon" name="edit"></m3e-icon>
  Compose
</m3e-button>
<m3e-fab-menu id="compose-menu" variant="secondary">
  <m3e-fab-menu-item>
    <m3e-icon slot="icon" name="mail"></m3e-icon>
    New email
  </m3e-fab-menu-item>
  <m3e-fab-menu-item>
    <m3e-icon slot="icon" name="event"></m3e-icon>
    New event
  </m3e-fab-menu-item>
  <m3e-fab-menu-item>
    <m3e-icon slot="icon" name="group"></m3e-icon>
    New group
  </m3e-fab-menu-item>
</m3e-fab-menu>
```

**Tertiary FAB menu with link and disabled items**

```html
<m3e-button variant="tonal" size="large">
  <m3e-fab-menu-trigger for="share-menu"></m3e-fab-menu-trigger>
  <m3e-icon slot="icon" name="share"></m3e-icon>
</m3e-button>
<m3e-fab-menu id="share-menu" variant="tertiary">
  <m3e-fab-menu-item href="https://example.com/link" target="_blank">
    <m3e-icon slot="icon" name="link"></m3e-icon>
    Copy link
  </m3e-fab-menu-item>
  <m3e-fab-menu-item>
    <m3e-icon slot="icon" name="download"></m3e-icon>
    Export PDF
  </m3e-fab-menu-item>
  <m3e-fab-menu-item disabled>
    <m3e-icon slot="icon" name="print"></m3e-icon>
    Print
  </m3e-fab-menu-item>
</m3e-fab-menu>
```

## API

### `<m3e-fab-menu>`

A menu, opened from a floating action button (FAB), used to display multiple related actions.

**Display:** `none`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `variant` | `"primary" \| "secondary" \| "tertiary"` | "primary" | The appearance variant of the menu. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `isOpen` _(readonly)_ |  | Whether the menu is open. |
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

**CSS custom properties** — 17 total across 17 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-fab-menu-spacing` | Vertical gap between menu items. |
| `--m3e-fab-menu-max-width` | Maximum width of the menu. |
| `--m3e-primary-fab-color` | Foreground color for primary variant items. |
| `--m3e-primary-fab-container-color` | Container color for primary variant items. |
| `--m3e-primary-fab-hover-color` | Hover background color for primary variant items. |
| `--m3e-primary-fab-focus-color` | Focus background color for primary variant items. |
| `--m3e-primary-fab-ripple-color` | Ripple color for primary variant items. |
| `--m3e-secondary-fab-color` | Foreground color for secondary variant items. |
| `--m3e-secondary-fab-container-color` | Container color for secondary variant items. |
| `--m3e-secondary-fab-hover-color` | Hover background color for secondary variant items. |
| `--m3e-secondary-fab-focus-color` | Focus background color for secondary variant items. |
| `--m3e-secondary-fab-ripple-color` | Ripple color for secondary variant items. |

_…5 more families. See source for the full list._

### `<m3e-fab-menu-item>`

An item of a floating action button (FAB) menu.

**Display:** `inline-block` · **Navigable:** carries a native `href` — do not wrap it in an `<a>`.

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `download` | `string \| null` | null | A value indicating whether the `target` of the link button will be downloaded, optionally specifying the new name of the file. |
| `href` | `string` | "" | The URL to which the link button points. |
| `rel` | `string` | "" | The relationship between the `target` of the link button and the document. |
| `target` | `"_self" \| "_blank" \| "_parent" \| "_top" \| string` | "" | The target of the link button. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `menu` _(readonly)_ | `M3eFabMenuElement \| null` | The floating action button (FAB) menu to which this item belongs. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the item. |
| `icon` | Renders an icon before the items's label. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 10 total across 10 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-fab-menu-item-height` | Height of the menu item. |
| `--m3e-fab-menu-item-font-size` | Font size of the menu item label. |
| `--m3e-fab-menu-item-font-weight` | Font weight of the menu item label. |
| `--m3e-fab-menu-item-line-height` | Line height of the menu item label. |
| `--m3e-fab-menu-item-tracking` | Letter spacing of the menu item label. |
| `--m3e-fab-menu-item-shape` | Border radius of the menu item. |
| `--m3e-fab-menu-item-leading-space` | Padding at the start of the menu item. |
| `--m3e-fab-menu-item-trailing-space` | Padding at the end of the menu item. |
| `--m3e-fab-menu-item-spacing` | Gap between icon and label. |
| `--m3e-fab-menu-item-icon-size` | Size of the icon in the menu item. |

### `<m3e-fab-menu-trigger>`

An element, nested within a clickable element, used to open a floating action button (FAB) menu.

**Display:** `none`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `menu` _(readonly)_ | `M3eFabMenuElement \| null` | The menu triggered by the element. |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/fab-menu/README.md) (MIT). · Material spec: <https://m3.material.io/components/fab-menu/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/fab-menu/FabMenuElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/fab-menu/FabMenuElement.ts)
- [`packages/web/src/fab-menu/FabMenuItemElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/fab-menu/FabMenuItemElement.ts)
- [`packages/web/src/fab-menu/FabMenuTriggerElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/fab-menu/FabMenuTriggerElement.ts)

**README drift corrected** (4 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
