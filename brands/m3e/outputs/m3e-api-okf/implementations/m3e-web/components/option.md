# option

**Family:** [Text input & forms](../concepts/choosing-components.md#text-inputs) · See also: [form-field](form-field.md), [select](select.md), [autocomplete](autocomplete.md), [search](search.md), [textarea-autosize](textarea-autosize.md)

The `m3e-option`, `m3e-option-panel`, and `m3e-optgroup` components provide a complete solution for displaying selectable options in menus and lists. They follow Material Design 3 principles with comprehensive support for single and multiple selection, dynamic positioning, keyboard navigation, and extensive theming via CSS custom properties.

```ts
import "@m3e/web/option";
```

**Elements:** `<m3e-optgroup>`, `<m3e-option>`, `<m3e-option-panel>`

## Examples

```html
<m3e-option-panel>
  <m3e-option value="apple">Apple</m3e-option>
  <m3e-option value="banana">Banana</m3e-option>
  <m3e-optgroup>
    <span slot="label">Citrus</span>
    <m3e-option value="lemon">Lemon</m3e-option>
    <m3e-option value="orange">Orange</m3e-option>
  </m3e-optgroup>
</m3e-option-panel>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Autocomplete option panel with grouped results**

```html
<m3e-option-panel fit-anchor-width>
  <m3e-option value="apple">Apple</m3e-option>
  <m3e-option value="banana">Banana</m3e-option>
  <m3e-optgroup>
    <span slot="label">Citrus</span>
    <m3e-option value="lemon">Lemon</m3e-option>
    <m3e-option value="orange" selected>Orange</m3e-option>
    <m3e-option value="grapefruit" disabled>Grapefruit</m3e-option>
  </m3e-optgroup>
</m3e-option-panel>
```

**Option panel with search-term highlighting**

```html
<m3e-option-panel state="content" scroll-strategy="reposition">
  <m3e-option value="react" term="re" highlight-mode="starts-with">React</m3e-option>
  <m3e-option value="redux" term="re" highlight-mode="starts-with">Redux</m3e-option>
  <m3e-option value="remix" term="re" highlight-mode="starts-with">Remix</m3e-option>
</m3e-option-panel>
```

**Empty option panel loading state**

```html
<m3e-option-panel state="loading" anchor-offset="4">
  <m3e-loading-indicator></m3e-loading-indicator>
  <span>Searching...</span>
</m3e-option-panel>
```

## API

### `<m3e-optgroup>`

Groups options under a subheading.

**Display:** `block`

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the options of the group. |
| `label` | Renders the label of the group. |

**CSS custom properties** — 8 total across 8 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-option-height` | The height of the group label container. |
| `--m3e-option-font-size` | The font size of the group label. |
| `--m3e-option-font-weight` | The font weight of the group label. |
| `--m3e-option-line-height` | The line height of the group label. |
| `--m3e-option-tracking` | The letter spacing of the group label. |
| `--m3e-option-padding-end` | The right padding of the label. |
| `--m3e-option-padding-start` | The left padding of the label. |
| `--m3e-option-color` | The text color of the group label. |

### `<m3e-option>`

An option that can be selected.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `disable-highlight` | `boolean` | false | Whether text highlighting is disabled. |
| `highlight-mode` | `"contains" \| "starts-with" \| "ends-with"` | "contains" | The mode in which to highlight a term. |
| `selected` | `boolean` | false | Whether the element is selected. |
| `term` | `string` | "" | The search term to highlight. |
| `value` |  |  | A string representing the value of the option. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `label` _(readonly)_ |  | The textual label of the option. |
| `isEmpty` _(readonly)_ |  | Whether the option represents an empty option. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the option. |

**CSS custom properties** — 25 total across 25 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-option-container-height` | The height of the option container. |
| `--m3e-option-color` | The text color of the option. |
| `--m3e-option-container-hover-color` | The color for the hover state layer. |
| `--m3e-option-container-focus-color` | The color for the focus state layer. |
| `--m3e-option-ripple-color` | The color of the ripple effect. |
| `--m3e-option-selected-color` | The text color when the option is selected. |
| `--m3e-option-selected-container-color` | The background color when the option is selected. |
| `--m3e-option-selected-container-hover-color` | The hover color for the selected state layer. |
| `--m3e-option-selected-container-focus-color` | The focus color for the selected state layer. |
| `--m3e-option-selected-ripple-color` | The ripple color when the option is selected. |
| `--m3e-option-disabled-color` | The text color when the option is disabled. |
| `--m3e-option-disabled-opacity` | The opacity level applied to the disabled text color. |

_…13 more families. See source for the full list._

### `<m3e-option-panel>`

Presents a list of options on a temporary surface.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `"loading" \| "no-data" \| "content"` | "content" | The state for which to present content. |
| `scroll-strategy` | `"hide" \| "reposition"` | "hide" | The strategy that controls how the panel behaves when its trigger scrolls. |
| `fit-anchor-width` | `boolean` | false | Whether the panel's width should match its anchor's width. |
| `anchor-offset` | `number` | 0 | The logical margin, in pixels, between the panel and its anchor. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `isOpen` _(readonly)_ |  | Whether the panel is open. |
| `trigger` _(readonly)_ | `HTMLElement \| null` | The element that triggered the panel to open. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the contents of the list. |
| `no-data` | Renders content shown when there is no data. |
| `loading` | Renders content shown while the panel is loading. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforetoggle` |  | Dispatched before the toggle state changes. |
| `toggle` |  | Dispatched after the toggle state has changed. |

**CSS custom properties** — 20 total across 20 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-option-panel-container-shape` | Corner radius of the panel container. |
| `--m3e-option-panel-container-min-width` | Minimum width of the panel container. |
| `--m3e-option-panel-container-max-width` | Maximum width of the panel container. |
| `--m3e-option-panel-container-max-height` | Maximum height of the panel container. |
| `--m3e-option-panel-container-padding-block` | Vertical padding inside the panel container. |
| `--m3e-option-panel-container-padding-inline` | Horizontal padding inside the panel container. |
| `--m3e-option-panel-container-color` | Background color of the panel container. |
| `--m3e-option-panel-container-elevation` | Box shadow elevation of the panel container. |
| `--m3e-option-panel-gap` | Vertical spacing between option items. |
| `--m3e-option-panel-divider-spacing` | Vertical spacing around slotted `m3e-divider` elements. |
| `--m3e-option-panel-text-highlight-container-color` | Background color used for text highlight matches. |
| `--m3e-option-panel-text-highlight-color` | Text color used for text highlight matches. |

_…8 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/option/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/option/OptGroupElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/option/OptGroupElement.ts)
- [`packages/web/src/option/OptionElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/option/OptionElement.ts)
- [`packages/web/src/option/OptionPanelElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/option/OptionPanelElement.ts)

**README drift corrected** (5 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
