# textarea-autosize

**Family:** [Text input & forms](../concepts/choosing-components.md#text-inputs) · See also: [form-field](form-field.md), [select](select.md), [autocomplete](autocomplete.md), [search](search.md), [option](option.md)

The `m3e-textarea-autosize` component automatically adjusts the height of a linked `textarea` to fit its content, preserving layout integrity and user experience. This non-visual element listens to input changes and applies dynamic resizing, constrained by optional row limits. It supports declarative configuration via attributes and can be disabled when manual control is preferred.

```ts
import "@m3e/web/textarea-autosize";
```

## Examples

```html
<m3e-form-field>
  <label slot="label" for="fld">Textarea Autosize</label>
  <textarea id="fld"></textarea>
  <m3e-textarea-autosize for="fld" max-rows="5"></m3e-textarea-autosize>
</m3e-form-field>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Auto-resizing comment textarea**

```html
<label for="comment">Add a comment</label>
<textarea id="comment" placeholder="Share your thoughts..."></textarea>
<m3e-textarea-autosize for="comment" min-rows="2" max-rows="8"></m3e-textarea-autosize>
```

**Disabled auto-sizing on a fixed message box**

```html
<label for="msg">Message</label>
<textarea id="msg"></textarea>
<m3e-textarea-autosize for="msg" disabled></m3e-textarea-autosize>
```

## API

### `<m3e-textarea-autosize>`

A non-visual element used to automatically resize a `textarea` to fit its content.

**Display:** `none`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether auto-sizing is disabled. |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |
| `max-rows` | `number` | 0 | The maximum amount of rows in the `textarea`. |
| `min-rows` | `number` | 0 | The minimum amount of rows in the `textarea`. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/textarea-autosize/README.md) (MIT). · Material spec: <https://m3.material.io/components/text-fields/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/textarea-autosize/TextareaAutosizeElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/textarea-autosize/TextareaAutosizeElement.ts)
