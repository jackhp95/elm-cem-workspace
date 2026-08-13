# segmented-button

**Family:** [Actions & buttons](../concepts/choosing-components.md#actions) · See also: [button](button.md), [icon-button](icon-button.md), [fab](fab.md), [fab-menu](fab-menu.md), [split-button](split-button.md), [button-group](button-group.md)

The `m3e-segmented-button` and `m3e-button-segment` components allows users to select one or more options from a horizontal group. Each segment behaves like a toggle-able button, supporting icon and label content, selection state, and accessibility roles. Built with Material Design 3 principles, it adapts shape, color, and ripple feedback based on interaction state and input modality. Segments are visually unified but independently interactive.

```ts
import "@m3e/web/segmented-button";
```

**Elements:** `<m3e-button-segment>`, `<m3e-segmented-button>`

## Examples

```html
<m3e-segmented-button>
  <m3e-button-segment checked>8 oz</m3e-button-segment>
  <m3e-button-segment>12 oz</m3e-button-segment>
  <m3e-button-segment>16 oz</m3e-button-segment>
  <m3e-button-segment>20 oz</m3e-button-segment>
</m3e-segmented-button>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Segmented button with icons**

```html
<m3e-segmented-button>
  <m3e-button-segment value="paste" checked>
    <m3e-icon slot="icon" name="content_paste"></m3e-icon>
    Paste
  </m3e-button-segment>
  <m3e-button-segment value="file">
    <m3e-icon slot="icon" name="upload_file"></m3e-icon>
    File
  </m3e-button-segment>
</m3e-segmented-button>
```

_Source: 2026: src/pages/speed-reader.astro_

**Segmented button for value selection**

```html
<m3e-segmented-button>
  <m3e-button-segment value="0.75">0.75x</m3e-button-segment>
  <m3e-button-segment value="1" checked>1x</m3e-button-segment>
  <m3e-button-segment value="1.5">1.5x</m3e-button-segment>
</m3e-segmented-button>
```

_Source: 2026: src/components/ReadingToolbar.astro_

## API

### `<m3e-button-segment>`

A option that can be selected within a segmented button.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `checked` | `boolean` | false | Whether the element is checked. |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `value` | `string` | "on" | A string representing the value of the segment. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `dirty` _(readonly)_ | `boolean` | Whether the user has modified the value of the element. |
| `pristine` _(readonly)_ | `boolean` | Whether the user has not modified the value of the element. |
| `touched` _(readonly)_ | `boolean` | Whether the user has interacted when the element. |
| `untouched` _(readonly)_ | `boolean` | Whether the user has not interacted when the element. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the option. |
| `icon` | Renders an icon before the option's label. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` | `Event` | Dispatched before the checked state changes. |
| `input` | `Event` | Dispatched when the checked state changes. |
| `change` | `Event` | Dispatched when the checked state changes. |
| `click` |  | Dispatched when the element is clicked. |

**CSS custom properties** — 29 total across 29 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-segmented-button-height` | Total height of the segmented button. |
| `--m3e-segmented-button-outline-thickness` | Thickness of the button's border. |
| `--m3e-segmented-button-outline-color` | Color of the button's border. |
| `--m3e-segmented-button-padding-start` | Padding on the leading edge of the button content. |
| `--m3e-segmented-button-padding-end` | Padding on the trailing edge of the button content. |
| `--m3e-segmented-button-spacing` | Horizontal gap between icon and label. |
| `--m3e-segmented-button-font-size` | Font size of the label text. |
| `--m3e-segmented-button-font-weight` | Font weight of the label text. |
| `--m3e-segmented-button-line-height` | Line height of the label text. |
| `--m3e-segmented-button-tracking` | Letter spacing of the label text. |
| `--m3e-segmented-button-with-icon-padding-start` | Leading padding when an icon is present. |
| `--m3e-segmented-button-selected-container-color` | Background color of a selected segment. |

_…17 more families. See source for the full list._

### `<m3e-segmented-button>`

A button that allows a user to select from a limited set of options.

**Display:** `inline-flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `hide-selection-indicator` | `boolean` | false | Whether to hide the selection indicator. |
| `multi` | `boolean` | false | Whether multiple options can be selected. |
| `name` |  |  | The name that identifies the element when submitting the associated form. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `segments` _(readonly)_ | `readonly M3eButtonSegmentElement[]` | The segments of the button. |
| `selected` _(readonly)_ | `readonly M3eButtonSegmentElement[]` | The selected segment(s) of the button. |
| `value` _(readonly)_ | `string \| readonly string[] \| null` | The selected (enabled) value(s) of the button. |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `labels` _(readonly)_ | `NodeListOf<HTMLLabelElement>` | The label elements that the element is associated with. |
| `dirty` _(readonly)_ | `boolean` | Whether the user has modified the value of the element. |
| `pristine` _(readonly)_ | `boolean` | Whether the user has not modified the value of the element. |
| `touched` _(readonly)_ | `boolean` | Whether the user has interacted when the element. |
| `untouched` _(readonly)_ | `boolean` | Whether the user has not interacted when the element. |
| `form` _(readonly)_ | `HTMLFormElement \| null` | The `HTMLFormElement` associated with this element. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the segments of the button. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the checked state of a segment changes. |
| `beforeinput` |  | Dispatched before the checked state of a segment changes. |
| `input` |  | Dispatched when the checked state of a segment changes. |

**CSS custom properties** — 2 total across 2 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-segmented-button-start-shape` | Border radius for the first segment in a segmented button. |
| `--m3e-segmented-button-end-shape` | Border radius for the last segment in a segmented button. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/segmented-button/README.md) (MIT). · Material spec: <https://m3.material.io/components/segmented-buttons/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/segmented-button/ButtonSegmentElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/segmented-button/ButtonSegmentElement.ts)
- [`packages/web/src/segmented-button/SegmentedButtonElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/segmented-button/SegmentedButtonElement.ts)
