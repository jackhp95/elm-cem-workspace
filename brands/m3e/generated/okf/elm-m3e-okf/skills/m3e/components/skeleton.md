# skeleton

**Family:** [Feedback & status](../concepts/choosing-components.md#feedback) · See also: [badge](badge.md), [snackbar](snackbar.md), [tooltip](tooltip.md), [loading-indicator](loading-indicator.md), [progress-indicator](progress-indicator.md)

The `m3e-skeleton` component provides a loading placeholder surface with flexible shape variants and motion-based animations that communicate loading state while preserving layout stability. It mimics the layout of content while it's still loading, ensuring a smooth user experience during data fetching or rendering delays. The component supports different animation effects (`pulse`, `wave`, `none`) and shape variants (`circular`, `rounded`, `square`, `auto`) to adapt to various content types. When the content is loaded, the skeleton fades out with a smooth transition.

```ts
import "@m3e/web/skeleton";
```

## Examples

```html
<m3e-skeleton>
  <m3e-card></m3e-card>
</m3e-skeleton>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Card loading placeholder with wave animation**

```html
<m3e-skeleton animation="wave" shape="rounded">
  <div>
    <p>Loading content...</p>
  </div>
</m3e-skeleton>
```

**Circular avatar and text placeholders**

```html
<div>
  <m3e-skeleton shape="circular" animation="pulse"></m3e-skeleton>
  <m3e-skeleton shape="rounded" animation="pulse"></m3e-skeleton>
  <m3e-skeleton shape="rounded" animation="pulse"></m3e-skeleton>
</div>
```

**Loaded skeleton revealing content**

```html
<m3e-skeleton loaded shape="auto" animation="none">
  <p>Content has finished loading.</p>
</m3e-skeleton>
```

## API

### `<m3e-skeleton>`

A visual placeholder that mimics the layout of content while it's still loading.

**Display:** `contents`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `animation` | `"pulse" \| "wave" \| "none"` | "wave" | The animation effect of the skeleton. |
| `shape` | `"circular" \| "rounded" \| "square" \| "auto"` | "auto" | The shape of the skeleton. |
| `loaded` | `boolean` | false | Whether the content of the skeleton has been loaded. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content to be mimicked by the skeleton. |

**CSS custom properties** — 9 total across 9 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-skeleton-color` | Base fill color for the skeleton surface. |
| `--m3e-skeleton-tint-color` | Tint fill color for the skeleton surface. |
| `--m3e-skeleton-tint-opacity` | Tint Opacity applied when the skeleton animation is not pulsating. |
| `--m3e-skeleton-accent-color` | Accent color used in wave animation. |
| `--m3e-skeleton-accent-opacity` | Opacity of the accent effect in animations. |
| `--m3e-skeleton-rounded-shape` | Corner radius for the rounded skeleton shape. |
| `--m3e-skeleton-circular-shape` | Corner radius for the circular skeleton shape. |
| `--m3e-skeleton-square-shape` | Corner radius for the square skeleton shape. |
| `--m3e-skeleton-shape` | Corner radius for the skeleton shape. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/skeleton/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/skeleton/SkeletonElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/skeleton/SkeletonElement.ts)

**README drift corrected** (1 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
