# slider

**Family:** [Selection controls](../concepts/choosing-components.md#selection-inputs) · See also: [checkbox](checkbox.md), [radio-group](radio-group.md), [switch](switch.md), [chips](chips.md)

The `m3e-slider` component enables users to select a numeric value from a continuous or discrete range. Designed according to Material 3 principles, it supports labeled value indicators, tick marks, and snapping behavior.

```ts
import "@m3e/web/slider";
```

**Elements:** `<m3e-slider>`, `<m3e-slider-thumb>`

## Examples

```html
<m3e-slider labelled>
  <m3e-slider-thumb value="50"></m3e-slider-thumb>
</m3e-slider>
```

```html
<m3e-slider labelled>
  <m3e-slider-thumb value="25"></m3e-slider-thumb>
  <m3e-slider-thumb value="75"></m3e-slider-thumb>
</m3e-slider>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Discrete labelled volume slider**

```html
<m3e-slider labelled discrete min="0" max="100" step="10" size="medium">
  <m3e-slider-thumb value="40"></m3e-slider-thumb>
</m3e-slider>
```

**Range slider with two thumbs**

```html
<m3e-slider labelled min="0" max="1000" step="50">
  <m3e-slider-thumb name="min-price" value="200"></m3e-slider-thumb>
  <m3e-slider-thumb name="max-price" value="800"></m3e-slider-thumb>
</m3e-slider>
```

## API

### `<m3e-slider>`

Allows for the selection of numeric values from a range.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `discrete` | `boolean` | false | Whether to show tick marks. |
| `labelled` | `boolean` | false | Whether to show value labels when activated. |
| `max` | `number` | 100 | The maximum allowable value. |
| `min` | `number` | 0 | The minimum allowable value. |
| `step` | `number` | 1 | The value at which the thumb will snap. |
| `size` | `"extra-small" \| "small" \| "medium" \| "large" \| "extra-large"` | "extra-small" | The size of the slider. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `displayWith` | `((value: number \| null) => string) \| null` | The function used to format display values. |
| `thumbs` _(readonly)_ | `readonly M3eSliderThumbElement[]` | The thumbs used to select values. |
| `isRange` _(readonly)_ | `boolean` | Whether the slider is a range slider. |
| `thumb` _(readonly)_ | `M3eSliderThumbElement \| null` | The thumb used to select a value. |
| `lowerThumb` _(readonly)_ | `M3eSliderThumbElement \| null` | The thumb used to select the lower value of a range slider. |
| `upperThumb` _(readonly)_ | `M3eSliderThumbElement \| null` | The thumb used to select the upper value of a range slider. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the thumbs of the slider. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` |  | Dispatched before the value of a thumb changes. |
| `input` |  | Dispatched when the value of a thumb changes. |
| `change` |  | Dispatched when the value of a thumb changes. |

**CSS custom properties** — 34 total across 18 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-slider-min-width` | Minimum inline size of the slider host. |
| `--m3e-slider-[size]-height` | Height of the slider when size is small or extra-small. |
| `--m3e-slider-[size]-active-track-shape` | Corner shape of the active track for small sliders. |
| `--m3e-slider-[size]-inactive-active-track-start-shape` | Corner shape of the inactive track start for small sliders. |
| `--m3e-slider-[size]-inactive-track-end-shape` | Corner shape of the inactive track end for small sliders. |
| `--m3e-slider-[size]-track-height` | Height of the track for extra-small sliders. |
| `--m3e-slider-tick-size` | Size of each tick mark. |
| `--m3e-slider-tick-shape` | Corner shape of each tick mark. |
| `--m3e-slider-inactive-track-color` | Background color of the inactive track when enabled. |
| `--m3e-slider-disabled-inactive-track-color` | Base color of the inactive track when disabled. |
| `--m3e-slider-disabled-inactive-track-opacity` | Opacity of the inactive track when disabled. |
| `--m3e-slider-active-track-color` | Background color of the active track when enabled. |

_…6 more families. See source for the full list._

### `<m3e-slider-thumb>`

A thumb used to select a value in a slider.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `name` |  |  | The name that identifies the element when submitting the associated form. |
| `value` | `number \| null` | null | The value of the thumb. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `dirty` _(readonly)_ | `boolean` | Whether the user has modified the value of the element. |
| `pristine` _(readonly)_ | `boolean` | Whether the user has not modified the value of the element. |
| `touched` _(readonly)_ | `boolean` | Whether the user has interacted when the element. |
| `untouched` _(readonly)_ | `boolean` | Whether the user has not interacted when the element. |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `form` _(readonly)_ | `HTMLFormElement \| null` | The `HTMLFormElement` associated with this element. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `value-change` | `Event` |  |
| `beforeinput` |  | Dispatched before the value changes. |
| `input` |  | Dispatched when the value changes. |
| `change` |  | Dispatched when the value changes. |
| `click` |  | Dispatched when the element is clicked. |

**CSS custom properties** — 13 total across 13 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-slider-thumb-width` | Width of the slider thumb. |
| `--m3e-slider-thumb-padding` | Horizontal padding around the thumb. |
| `--m3e-slider-thumb-color` | Active color of the slider thumb when enabled. |
| `--m3e-slider-thumb-pressed-width` | Width of the thumb when pressed. |
| `--m3e-slider-thumb-disabled-color` | Color of the thumb when disabled. |
| `--m3e-slider-thumb-disabled-opacity` | Opacity of the thumb when disabled. |
| `--m3e-slider-label-width` | Width of the floating label above the thumb. |
| `--m3e-slider-label-container-color` | Background color of the label container. |
| `--m3e-slider-label-color` | Text color of the label. |
| `--m3e-slider-label-font-size` | Font size of the label text. |
| `--m3e-slider-label-font-weight` | Font weight of the label text. |
| `--m3e-slider-label-line-height` | Line height of the label text. |

_…1 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/slider/README.md) (MIT). · Material spec: <https://m3.material.io/components/sliders/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/slider/SliderElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/slider/SliderElement.ts)
- [`packages/web/src/slider/SliderThumbElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/slider/SliderThumbElement.ts)
