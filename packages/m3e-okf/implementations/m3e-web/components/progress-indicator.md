# progress-indicator

**Family:** [Feedback & status](../concepts/choosing-components.md#feedback) · See also: [badge](badge.md), [snackbar](snackbar.md), [tooltip](tooltip.md), [loading-indicator](loading-indicator.md), [skeleton](skeleton.md)

The `m3e-linear-progress-indicator` and `m3e-circular-progress-indicator` components provide accessible, animated progress indicators for tracking the completion of tasks or processes. Both components support multiple modes and are fully customizable via CSS custom properties.

```ts
import "@m3e/web/progress-indicator";
```

**Elements:** `<m3e-circular-progress-indicator>`, `<m3e-linear-progress-indicator>`

## Examples

```html
<m3e-linear-progress-indicator value="30"></m3e-linear-progress-indicator>
<m3e-circular-progress-indicator value="30"></m3e-circular-progress-indicator>
```

```html
<m3e-linear-progress-indicator mode="indeterminate"></m3e-linear-progress-indicator>
<m3e-circular-progress-indicator indeterminate></m3e-circular-progress-indicator>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Determinate linear and circular progress**

```html
<div>
  <p>Uploading files...</p>
  <m3e-linear-progress-indicator value="65" max="100"></m3e-linear-progress-indicator>
</div>
<div>
  <m3e-circular-progress-indicator value="65" max="100" variant="wavy"></m3e-circular-progress-indicator>
</div>
```

**Indeterminate loading states**

```html
<m3e-linear-progress-indicator mode="indeterminate"></m3e-linear-progress-indicator>
<m3e-circular-progress-indicator indeterminate></m3e-circular-progress-indicator>
```

**Buffered linear progress**

```html
<m3e-linear-progress-indicator mode="buffer" value="40" buffer-value="75" max="100"></m3e-linear-progress-indicator>
```

## API

### `<m3e-circular-progress-indicator>`

A circular indicator of progress and activity.

**Display:** `inline-flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `indeterminate` | `boolean` | false | Whether to show something is happening without conveying progress. |
| `max` | `number` | 100 | The maximum progress value. |
| `value` | `number` | 0 | A fractional value, between 0 and `max`, indicating progress. |
| `variant` | `"flat" \| "wavy"` | "flat" | The appearance of the indicator. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content inside the progress indicator. |

**CSS custom properties** — 7 total across 7 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-circular-flat-progress-indicator-diameter` | Diameter of the `flat` variant. |
| `--m3e-circular-wavy-progress-indicator-diameter` | Diameter of the `wavy` variant. |
| `--m3e-circular-wavy-progress-indicator-amplitude` | Amplitude of the `wavy` variant. |
| `--m3e-circular-wavy-progress-indicator-wavelength` | Wavelength of the `wavy` variant. |
| `--m3e-circular-progress-indicator-thickness` | Thickness of the progress indicator. |
| `--m3e-progress-indicator-track-color` | Track color of the progress indicator (background). |
| `--m3e-progress-indicator-color` | Color of the progress indicator (foreground). |

### `<m3e-linear-progress-indicator>`

A horizontal bar for indicating progress and activity.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer-value` | `number` | 0 | A fractional value, between 0 and `max`, indicating buffer progress. |
| `max` | `number` | 100 | The maximum progress value. |
| `mode` | `"determinate" \| "indeterminate" \| "buffer" \| "query"` | "determinate" | The mode of the progress bar. |
| `value` | `number` | 0 | A fractional value, between 0 and `max`, indicating progress. |
| `variant` | `"flat" \| "wavy"` | "flat" | The appearance of the indicator. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**CSS custom properties** — 7 total across 7 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-linear-progress-indicator-thickness` | Thickness (height) of the progress bar. |
| `--m3e-linear-progress-indicator-shape` | Border radius of the progress bar. |
| `--m3e-progress-indicator-track-color` | Track color of the progress bar (background/buffer). |
| `--m3e-progress-indicator-color` | Color of the progress indicator (foreground). |
| `--m3e-linear-wavy-progress-indicator-amplitude` | Amplitude of the `wavy` variant. |
| `--m3e-linear-wavy-progress-indicator-wavelength` | Wavelength of the `wavy` variant. |
| `--m3e-linear-wavy-indeterminate-progress-indicator-wavelength` | Wavelength of the indeterminate/query `wavy` variant. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/progress-indicator/README.md) (MIT). · Material spec: <https://m3.material.io/components/progress-indicators/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/progress-indicator/CircularProgressIndicatorElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/progress-indicator/CircularProgressIndicatorElement.ts)
- [`packages/web/src/progress-indicator/LinearProgressIndicatorElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/progress-indicator/LinearProgressIndicatorElement.ts)

**README drift corrected** (1 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
