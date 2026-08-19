# switch

**Family:** [Selection controls](../concepts/choosing-components.md#selection-inputs) · See also: [checkbox](checkbox.md), [radio-group](radio-group.md), [slider](slider.md), [chips](chips.md)

The `m3e-switch` component is a semantic, accessible toggle control that reflects a binary state. Designed according to Material Design 3 guidelines, it supports shape transitions, and adaptive color theming across selected, unselected, and disabled states. The component responds to user interaction with smooth motion and expressive feedback. It supports optional icons (`none`, `selected`, or `both`) and integrates with form-associated behavior, emitting `input` and `change` events when toggled.

```ts
import "@m3e/web/switch";
```

## Examples

```html
<label>Switch label&nbsp;<m3e-switch></m3e-switch></label>
```

```html
<label>Switch label&nbsp;<m3e-switch icons="both"></m3e-switch></label>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Labelled switch with icons in both states**

```html
<label>Enable notifications&nbsp;<m3e-switch checked icons="both" name="notifications" value="enabled"></m3e-switch></label>
```

**Disabled switch**

```html
<label>Sync over cellular&nbsp;<m3e-switch disabled icons="selected"></m3e-switch></label>
```

## API

### `<m3e-switch>`

An on/off control that can be toggled by clicking.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `checked` | `boolean` | false | Whether the element is checked. |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `icons` | `"none" \| "selected" \| "both"` | "none" | The icons to present. |
| `name` |  |  | The name that identifies the element when submitting the associated form. |
| `value` | `string` | "on" | A string representing the value of the switch. |
| `validationMessages` | `ValidationMessages` |  | Validation messages mapped to individual error types. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `labels` _(readonly)_ | `NodeListOf<HTMLLabelElement>` | The label elements that the element is associated with. |
| `dirty` _(readonly)_ | `boolean` | Whether the user has modified the value of the element. |
| `pristine` _(readonly)_ | `boolean` | Whether the user has not modified the value of the element. |
| `touched` _(readonly)_ | `boolean` | Whether the user has interacted when the element. |
| `untouched` _(readonly)_ | `boolean` | Whether the user has not interacted when the element. |
| `willValidate` _(readonly)_ | `boolean` | Whether the element is a submittable element that is a candidate for constraint validation. |
| `validity` _(readonly)_ | `ValidityState` | The validity state of the element. |
| `validationMessage` _(readonly)_ | `string` | The error message that would be displayed if the user submits the form, or an empty string if no error message. |
| `[defaultValidationMessages]` _(readonly)_ | `Readonly<ValidationMessages>` | Default validation messages mapped to individual error types. |
| `form` _(readonly)_ | `HTMLFormElement \| null` | The `HTMLFormElement` associated with this element. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` | `Event` | Dispatched before the checked state changes. |
| `input` | `Event` | Dispatched when the checked state changes. |
| `change` | `Event` | Dispatched when the checked state changes. |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 69 total across 69 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-switch-selected-icon-color` | Color of the icon when the switch is selected. |
| `--m3e-switch-selected-icon-size` | Size of the icon in the selected state. |
| `--m3e-switch-unselected-icon-color` | Color of the icon when the switch is unselected. |
| `--m3e-switch-unselected-icon-size` | Size of the icon in the unselected state. |
| `--m3e-switch-track-height` | Height of the switch track. |
| `--m3e-switch-track-width` | Width of the switch track. |
| `--m3e-switch-track-outline-color` | Color of the track's outline. |
| `--m3e-switch-track-outline-width` | Thickness of the track's outline. |
| `--m3e-switch-track-shape` | Corner shape of the track. |
| `--m3e-switch-selected-track-color` | Track color when selected. |
| `--m3e-switch-unselected-track-color` | Track color when unselected. |
| `--m3e-switch-unselected-handle-height` | Height of the handle when unselected. |

_…57 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/switch/README.md) (MIT). · Material spec: <https://m3.material.io/components/switch/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/switch/SwitchElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/switch/SwitchElement.ts)

**README drift corrected** (2 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
