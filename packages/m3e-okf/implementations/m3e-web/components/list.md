# list

**Family:** [Data & collections](../concepts/choosing-components.md#data-display) · See also: [tree](tree.md), [calendar](calendar.md), [datepicker](datepicker.md), [date-input](date-input.md), [timepicker](timepicker.md)

The `@m3e/list` package provides expressive, accessible components for organizing and displaying lists of items. It includes list containers (`m3e-list`, `m3e-action-list`, `m3e-selection-list`), basic list items (`m3e-list-item`), interactive items (`m3e-list-action`, `m3e-list-option`), and hierarchical items (`m3e-expandable-list-item`). All components support rich content, flexible layout, keyboard navigation, and extensive theming via CSS custom properties following Material 3 design principles.

```ts
import "@m3e/web/list";
```

**Elements:** `<m3e-action-list>`, `<m3e-expandable-list-item>`, `<m3e-list>`, `<m3e-list-action>`, `<m3e-list-item>`, `<m3e-list-item-button>`, `<m3e-list-option>`, `<m3e-selection-list>`

## Examples

```html
<m3e-list>
  <m3e-list-item>
    <m3e-icon slot="leading" name="person"></m3e-icon>
    <span slot="overline">Overline</span>
    Headline
    <span slot="supporting-text">Supporting text</span>
    <m3e-icon slot="trailing" name="arrow_right"></m3e-icon>
  </m3e-list-item>
</m3e-list>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Contact list with leading icons and trailing chevrons**

```html
<m3e-list variant="standard">
  <m3e-list-item>
    <m3e-icon slot="leading" name="person"></m3e-icon>
    <span slot="overline">Engineering</span>
    Ada Lovelace
    <span slot="supporting-text">ada@example.com</span>
    <m3e-icon slot="trailing" name="chevron_right"></m3e-icon>
  </m3e-list-item>
  <m3e-list-item>
    <m3e-icon slot="leading" name="person"></m3e-icon>
    <span slot="overline">Design</span>
    Grace Hopper
    <span slot="supporting-text">grace@example.com</span>
    <m3e-icon slot="trailing" name="chevron_right"></m3e-icon>
  </m3e-list-item>
</m3e-list>
```

**Action list of navigable links**

```html
<m3e-action-list variant="segmented">
  <m3e-list-action href="/account">
    <m3e-icon slot="leading" name="manage_accounts"></m3e-icon>
    Account
    <m3e-icon slot="trailing" name="open_in_new"></m3e-icon>
  </m3e-list-action>
  <m3e-list-action href="/billing">
    <m3e-icon slot="leading" name="payments"></m3e-icon>
    Billing
  </m3e-list-action>
  <m3e-list-action disabled>
    <m3e-icon slot="leading" name="lock"></m3e-icon>
    Admin tools
  </m3e-list-action>
</m3e-action-list>
```

**Multi-select selection list with expandable group**

```html
<m3e-selection-list multi name="topics">
  <m3e-list-option value="news" selected>
    <m3e-icon slot="leading" name="feed"></m3e-icon>
    Product news
  </m3e-list-option>
  <m3e-list-option value="offers">
    <m3e-icon slot="leading" name="local_offer"></m3e-icon>
    Special offers
  </m3e-list-option>
  <m3e-expandable-list-item open>
    <m3e-icon slot="leading" name="folder"></m3e-icon>
    Advanced
    <m3e-list-option slot="items" value="beta">
      Beta features
    </m3e-list-option>
    <m3e-list-option slot="items" value="api">
      API updates
    </m3e-list-option>
  </m3e-expandable-list-item>
</m3e-selection-list>
```

## API

### `<m3e-action-list>`

A list of actions.

**Display:** `flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `variant` | `"standard" \| "segmented"` | "standard" | The appearance variant of the list. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `items` _(readonly)_ | `ReadonlyArray<M3eListItemElement>` | The items of the list. |
| `leadingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of leading content. |
| `trailingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of trailing content. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the items of the list. |

**CSS custom properties** — 10 total across 10 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-list-divider-inset-start-size` | Start inset for dividers within the list. |
| `--m3e-list-divider-inset-end-size` | End inset for dividers within the list. |
| `--m3e-segmented-list-segment-gap` | Gap between list items in segmented variant. |
| `--m3e-segmented-list-container-shape` | Border radius of the segmented list container. |
| `--m3e-segmented-list-item-container-color` | Background color of items in segmented variant. |
| `--m3e-segmented-list-item-disabled-container-color` | Background color of disabled items in segmented variant. |
| `--m3e-segmented-list-item-container-shape` | Border radius of items in segmented variant. |
| `--m3e-segmented-list-item-hover-container-shape` | Border radius of items in segmented variant on hover. |
| `--m3e-segmented-list-item-focus-container-shape` | Border radius of items in segmented variant on focus. |
| `--m3e-segmented-list-item-selected-container-shape` | Border radius of items in segmented variant when selected. |

### `<m3e-expandable-list-item>`

An item in a list that can be expanded to show more items.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `open` | `boolean` | false | Whether the item is expanded. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `items` _(readonly)_ | `ReadonlyArray<M3eListItemElement>` | The direct child items of this item. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `leadingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of leading content. |
| `trailingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of trailing content. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the list item. |
| `leading` | Renders the leading content of the list item. |
| `overline` | Renders the overline of the list item. |
| `supporting-text` | Renders the supporting text of the list item. |
| `toggle-icon` | Renders a custom icon for the expand/collapse toggle. |
| `items` | Container for child list items displayed when expanded. |
| `trailing` | This component does not expose the base trailing slot. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `opening` |  | Dispatched when the item begins to open. |
| `opened` |  | Dispatched when the item has opened. |
| `closing` |  | Dispatched when the item begins to close. |
| `closed` |  | Dispatched when the item has closed. |

**CSS custom properties** — 74 total across 74 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-expandable-list-item-toggle-icon-container-width` | Width of the toggle icon container. |
| `--m3e-expandable-list-item-toggle-icon-container-shape` | Border radius of the toggle icon container. |
| `--m3e-expandable-list-item-toggle-icon-size` | Size of the toggle icon. |
| `--m3e-expandable-list-item-expanded-toggle-icon-container-color` | Background color of the toggle icon container when expanded. |
| `--m3e-expandable-list-item-bounce-duration` | Duration of the bounce animation when expanding. |
| `--m3e-expandable-list-item-bounce-factor` | Multiplication factor for the bounce effect. |
| `--m3e-expandable-list-item-expand-duration` | Duration of the expand/collapse animation. |
| `--m3e-list-item-between-space` | Horizontal gap between elements. |
| `--m3e-list-item-padding-inline` | Horizontal padding for the list item. |
| `--m3e-list-item-padding-block` | Vertical padding for the list item. |
| `--m3e-list-item-height` | Minimum height of the list item. |
| `--m3e-list-item-font-size` | Font size for main content. |

_…62 more families. See source for the full list._

### `<m3e-list>`

A list of items.

**Display:** `flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `variant` | `"standard" \| "segmented"` | "standard" | The appearance variant of the list. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `items` _(readonly)_ | `ReadonlyArray<M3eListItemElement>` | The items of the list. |
| `leadingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of leading content. |
| `trailingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of trailing content. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the items of the list. |

**CSS custom properties** — 10 total across 10 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-list-divider-inset-start-size` | Start inset for dividers within the list. |
| `--m3e-list-divider-inset-end-size` | End inset for dividers within the list. |
| `--m3e-segmented-list-segment-gap` | Gap between list items in segmented variant. |
| `--m3e-segmented-list-container-shape` | Border radius of the segmented list container. |
| `--m3e-segmented-list-item-container-color` | Background color of items in segmented variant. |
| `--m3e-segmented-list-item-disabled-container-color` | Background color of disabled items in segmented variant. |
| `--m3e-segmented-list-item-container-shape` | Border radius of items in segmented variant. |
| `--m3e-segmented-list-item-hover-container-shape` | Border radius of items in segmented variant on hover. |
| `--m3e-segmented-list-item-focus-container-shape` | Border radius of items in segmented variant on focus. |
| `--m3e-segmented-list-item-selected-container-shape` | Border radius of items in segmented variant when selected. |

### `<m3e-list-action>`

An item in a list that performs an action.

**Display:** `block` · **Navigable:** carries a native `href` — do not wrap it in an `<a>`.

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
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `leadingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of leading content. |
| `trailingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of trailing content. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the list item. |
| `leading` | Renders the leading content of the list item. |
| `overline` | Renders the overline of the list item. |
| `supporting-text` | Renders the supporting text of the list item. |
| `trailing` | Renders the trailing content of the list item. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` |  | Dispatched when the element is clicked. |

**CSS custom properties** — 66 total across 66 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-list-item-between-space` | Horizontal gap between elements. |
| `--m3e-list-item-padding-inline` | Horizontal padding for the list item. |
| `--m3e-list-item-padding-block` | Vertical padding for the list item. |
| `--m3e-list-item-height` | Minimum height of the list item. |
| `--m3e-list-item-font-size` | Font size for main content. |
| `--m3e-list-item-font-weight` | Font weight for main content. |
| `--m3e-list-item-line-height` | Line height for main content. |
| `--m3e-list-item-tracking` | Letter spacing for main content. |
| `--m3e-list-item-overline-font-size` | Font size for overline slot. |
| `--m3e-list-item-overline-font-weight` | Font weight for overline slot. |
| `--m3e-list-item-overline-line-height` | Line height for overline slot. |
| `--m3e-list-item-overline-tracking` | Letter spacing for overline slot. |

_…54 more families. See source for the full list._

### `<m3e-list-item>`

An item in a list.

**Display:** `block`

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `leadingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of leading content. |
| `trailingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of trailing content. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the list item. |
| `leading` | Renders the leading content of the list item. |
| `overline` | Renders the overline of the list item. |
| `supporting-text` | Renders the supporting text of the list item. |
| `trailing` | Renders the trailing content of the list item. |

**CSS custom properties** — 47 total across 47 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-list-item-between-space` | Horizontal gap between elements. |
| `--m3e-list-item-leading-space` | Horizontal padding for the leading side. |
| `--m3e-list-item-trailing-space` | Horizontal padding for the trailing side. |
| `--m3e-list-item-padding-inline` | Horizontal padding for the list item. |
| `--m3e-list-item-padding-block` | Vertical padding for the list item. |
| `--m3e-list-item-one-line-top-space` | Top padding for one-line items. |
| `--m3e-list-item-one-line-bottom-space` | Bottom padding for one-line items. |
| `--m3e-list-item-two-line-top-space` | Top padding for two-line items. |
| `--m3e-list-item-two-line-bottom-space` | Bottom padding for two-line items. |
| `--m3e-list-item-three-line-top-space` | Top padding for three-line items. |
| `--m3e-list-item-three-line-bottom-space` | Bottom padding for three-line items. |
| `--m3e-list-item-font-size` | Font size for main content. |

_…35 more families. See source for the full list._

### `<m3e-list-item-button>`

**Display:** `block` · **Navigable:** carries a native `href` — do not wrap it in an `<a>`.

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `href` | `string` | "" | The URL to which the link button points. |
| `target` | `"_self" \| "_blank" \| "_parent" \| "_top" \| string` | "" | The target of the link button. |
| `rel` | `string` | "" | The relationship between the `target` of the link button and the document. |
| `download` | `string \| null` | null | A value indicating whether the `target` of the link button will be downloaded, optionally specifying the new name of the file. |
| `disabled` | `boolean` | false | Whether the element is disabled. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `leadingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of leading content. |
| `trailingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of trailing content. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the list item. |
| `leading` | Renders the leading content of the list item. |
| `overline` | Renders the overline of the list item. |
| `supporting-text` | Renders the supporting text of the list item. |
| `trailing` | Renders the trailing content of the list item. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` | `MouseEvent` |  |

**CSS custom properties** — 47 total across 47 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-list-item-between-space` | Horizontal gap between elements. |
| `--m3e-list-item-leading-space` | Horizontal padding for the leading side. |
| `--m3e-list-item-trailing-space` | Horizontal padding for the trailing side. |
| `--m3e-list-item-padding-inline` | Horizontal padding for the list item. |
| `--m3e-list-item-padding-block` | Vertical padding for the list item. |
| `--m3e-list-item-one-line-top-space` | Top padding for one-line items. |
| `--m3e-list-item-one-line-bottom-space` | Bottom padding for one-line items. |
| `--m3e-list-item-two-line-top-space` | Top padding for two-line items. |
| `--m3e-list-item-two-line-bottom-space` | Bottom padding for two-line items. |
| `--m3e-list-item-three-line-top-space` | Top padding for three-line items. |
| `--m3e-list-item-three-line-bottom-space` | Bottom padding for three-line items. |
| `--m3e-list-item-font-size` | Font size for main content. |

_…35 more families. See source for the full list._

### `<m3e-list-option>`

A selectable option in a list.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `selected` | `boolean` | false | Whether the element is selected. |
| `value` |  |  | A string representing the value of the option. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `leadingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of leading content. |
| `trailingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of trailing content. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the list item. |
| `leading` | Renders the leading content of the list item. |
| `overline` | Renders the overline of the list item. |
| `supporting-text` | Renders the supporting text of the list item. |
| `trailing` | Renders the trailing content of the list item. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` | `Event` | Dispatched before the selected state changes. |
| `input` | `Event` | Dispatched when the selected state changes. |
| `change` | `Event` | Dispatched when the selected state changes. |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 81 total across 81 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-list-item-between-space` | Horizontal gap between elements. |
| `--m3e-list-item-padding-inline` | Horizontal padding for the list item. |
| `--m3e-list-item-padding-block` | Vertical padding for the list item. |
| `--m3e-list-item-height` | Minimum height of the list item. |
| `--m3e-list-item-font-size` | Font size for main content. |
| `--m3e-list-item-font-weight` | Font weight for main content. |
| `--m3e-list-item-line-height` | Line height for main content. |
| `--m3e-list-item-tracking` | Letter spacing for main content. |
| `--m3e-list-item-overline-font-size` | Font size for overline slot. |
| `--m3e-list-item-overline-font-weight` | Font weight for overline slot. |
| `--m3e-list-item-overline-line-height` | Line height for overline slot. |
| `--m3e-list-item-overline-tracking` | Letter spacing for overline slot. |

_…69 more families. See source for the full list._

### `<m3e-selection-list>`

A list of selectable options.

**Display:** `flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `hide-selection-indicator` | `boolean` | false | Whether to hide the selection indicator. |
| `multi` | `boolean` | false | Whether multiple items can be selected. |
| `variant` | `"standard" \| "segmented"` | "standard" | The appearance variant of the list. |
| `name` |  |  | The name that identifies the element when submitting the associated form. |
| `disabled` | `boolean` | false | Whether the element is disabled. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `options` _(readonly)_ | `readonly M3eListOptionElement[]` | The options of the list. |
| `selected` _(readonly)_ | `readonly M3eListOptionElement[]` | The selected option(s) of the list. |
| `value` _(readonly)_ | `string \| readonly string[] \| null` | The selected (enabled) value(s) of the set. |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `labels` _(readonly)_ | `NodeListOf<HTMLLabelElement>` | The label elements that the element is associated with. |
| `dirty` _(readonly)_ | `boolean` | Whether the user has modified the value of the element. |
| `pristine` _(readonly)_ | `boolean` | Whether the user has not modified the value of the element. |
| `touched` _(readonly)_ | `boolean` | Whether the user has interacted when the element. |
| `untouched` _(readonly)_ | `boolean` | Whether the user has not interacted when the element. |
| `form` _(readonly)_ | `HTMLFormElement \| null` | The `HTMLFormElement` associated with this element. |
| `items` _(readonly)_ | `ReadonlyArray<M3eListItemElement>` | The items of the list. |
| `leadingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of leading content. |
| `trailingContentType` _(readonly)_ | `"video" \| "image" \| "avatar" \| "icon" \| "text" \| undefined` | The type of trailing content. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the items of the list. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the selected state of an option changes. |
| `beforeinput` |  | Dispatched before the selected state of an option changes. |
| `input` |  | Dispatched when the selected state of an option changes. |

**CSS custom properties** — 10 total across 10 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-list-divider-inset-start-size` | Start inset for dividers within the list. |
| `--m3e-list-divider-inset-end-size` | End inset for dividers within the list. |
| `--m3e-segmented-list-segment-gap` | Gap between list items in segmented variant. |
| `--m3e-segmented-list-container-shape` | Border radius of the segmented list container. |
| `--m3e-segmented-list-item-container-color` | Background color of items in segmented variant. |
| `--m3e-segmented-list-item-disabled-container-color` | Background color of disabled items in segmented variant. |
| `--m3e-segmented-list-item-container-shape` | Border radius of items in segmented variant. |
| `--m3e-segmented-list-item-hover-container-shape` | Border radius of items in segmented variant on hover. |
| `--m3e-segmented-list-item-focus-container-shape` | Border radius of items in segmented variant on focus. |
| `--m3e-segmented-list-item-selected-container-shape` | Border radius of items in segmented variant when selected. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/list/README.md) (MIT). · Material spec: <https://m3.material.io/components/lists/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/list/ActionListElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/list/ActionListElement.ts)
- [`packages/web/src/list/ExpandableListItemElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/list/ExpandableListItemElement.ts)
- [`packages/web/src/list/ListElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/list/ListElement.ts)
- [`packages/web/src/list/ListActionElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/list/ListActionElement.ts)
- [`packages/web/src/list/ListItemElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/list/ListItemElement.ts)
- [`packages/web/src/list/ListItemButtonElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/list/ListItemButtonElement.ts)
- [`packages/web/src/list/ListOptionElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/list/ListOptionElement.ts)
- [`packages/web/src/list/SelectionListElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/list/SelectionListElement.ts)

**README drift corrected** (5 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
