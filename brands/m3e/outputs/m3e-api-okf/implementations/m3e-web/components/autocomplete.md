# autocomplete

**Family:** [Text input & forms](../concepts/choosing-components.md#text-inputs) · See also: [form-field](form-field.md), [select](select.md), [search](search.md), [textarea-autosize](textarea-autosize.md), [option](option.md)

The `m3e-autocomplete` component enhances a text input field with a dynamically positioned menu of filterable suggestions. Following Material Design 3 principles, it provides real-time filtering, keyboard navigation, automatic option activation, and text highlighting to guide user selection.

```ts
import "@m3e/web/autocomplete";
```

## Examples

```html
<m3e-form-field>
  <label slot="label" for="fruit">Choose your favorite fruit</label>
  <input id="fruit" />
</m3e-form-field>
<m3e-autocomplete for="fruit">
  <m3e-option>Apples</m3e-option>
  <m3e-option>Oranges</m3e-option>
  <m3e-option>Bananas</m3e-option>
  <m3e-option>Grapes</m3e-option>
</m3e-autocomplete>
```

```html
<m3e-autocomplete for="fruit" auto-activate required>
  <m3e-option>Apples</m3e-option>
  <m3e-option>Oranges</m3e-option>
  <m3e-option>Bananas</m3e-option>
  <m3e-option>Grapes</m3e-option>
</m3e-autocomplete>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Favorite fruit autocomplete with auto-activation**

```html
<label for="fruit">Choose your favorite fruit</label>
<input id="fruit" />
<m3e-autocomplete for="fruit" auto-activate required>
  <m3e-option>Apples</m3e-option>
  <m3e-option>Oranges</m3e-option>
  <m3e-option>Bananas</m3e-option>
  <m3e-option>Grapes</m3e-option>
</m3e-autocomplete>
```

**Starts-with country search with no-data message**

```html
<label for="country">Country</label>
<input id="country" placeholder="Start typing..." />
<m3e-autocomplete for="country" filter="starts-with" no-data-label="No matching countries">
  <m3e-option>Australia</m3e-option>
  <m3e-option>Brazil</m3e-option>
  <m3e-option>Canada</m3e-option>
  <m3e-option>Denmark</m3e-option>
  <span slot="no-data">Try a different spelling</span>
</m3e-autocomplete>
```

## API

### `<m3e-autocomplete>`

Enhances a text input with suggested options.

**Display:** `contents`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `auto-activate` | `boolean` | false | Whether the first option should be automatically activated. |
| `case-sensitive` | `boolean` | false | Whether filtering is case sensitive. |
| `filter` | `"contains" \| "starts-with" \| "ends-with" \| "none" \| ((option: M3eOptionElement, term: string) => boolean)` | "contains" | Mode in which to filter options. |
| `hide-selection-indicator` | `boolean` | false | Whether to hide the selection indicator. |
| `hide-loading` | `boolean` | false | Whether to hide the menu when loading options. |
| `hide-no-data` | `boolean` | false | Whether to hide the menu when there are no options to show. |
| `loading` | `boolean` | false | Whether options are being loaded. |
| `loading-label` | `string` | "Loading..." | The text announced and presented when loading options. |
| `no-data-label` | `string` | "No options" | The text announced and presented when no options are available for the current term. |
| `panel-class` | `string` | "" | Class or list of classes to be applied to the autocomplete's overlay panel. |
| `required` | `boolean` | false | Whether the user is required to make a selection when interacting with the autocomplete. |
| `results-label` | `string \| ((count: number) => string)` | (count) => `${count} options` | The text announced when available options change for the current term. |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `options` _(readonly)_ | `readonly M3eOptionElement[]` | The options that can be selected. |
| `selected` _(readonly)_ | `M3eOptionElement \| null` | The selected option. |
| `value` _(readonly)_ | `string \| null` | The selected (enabled) value. |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the options of the autocomplete. |
| `loading` | Renders content when loading options. |
| `no-data` | Renders content when there are no options to show. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the committed value changes due to selecting an option or clearing the input. |
| `query` | `CustomEvent` | Dispatched when the input is focused or when the user modifies its value. |
| `toggle` | `ToggleEvent` | Dispatched when the options menu opens or closes. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/autocomplete/README.md) (MIT). · Material spec: <https://m3.material.io/components/menus/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/autocomplete/AutocompleteElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/autocomplete/AutocompleteElement.ts)

**README drift corrected** (3 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
