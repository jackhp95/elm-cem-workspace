# icon

**Family:** [Content & media](../concepts/choosing-components.md#content-media) · See also: [avatar](avatar.md), [heading](heading.md), [shape](shape.md)

The `m3e-icon` component makes it easy to use Material Symbols in your application. It supports outlined, rounded, and sharp variants, as well as variable font features like fill, weight, grade, and optical size. For more information, see the [Material Symbol Guide](https://developers.google.com/fonts/docs/material_symbols) and [Material Symbol Library](https://fonts.google.com/icons). The Material Symbols font is the easiest way to incorporate Material Symbols into your application. Using the [Fonts CSS API](https://developers.google.com/fonts/docs/css2#forming_api_urls), you can use variable fonts to optimize icon usage within your application. See [Can I Use's Variable Fonts](https://caniuse.com/variable-fonts) to determine whether your user's browser support variable fonts.

```ts
import "@m3e/web/icon";
```

## Examples

```html
<m3e-icon name="home"></m3e-icon>
```

```html
<link
  href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0..1,0"
  rel="stylesheet"
/>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Icon variants, fill and weight showcase**

```html
<nav>
  <m3e-icon name="home" variant="outlined"></m3e-icon>
  <m3e-icon name="favorite" variant="rounded" filled></m3e-icon>
  <m3e-icon name="settings" variant="sharp" weight="600"></m3e-icon>
  <m3e-icon name="star" filled grade="high" optical-size="40"></m3e-icon>
</nav>
```

**Light-weight low-grade status icons**

```html
<span>
  <m3e-icon name="check_circle" filled weight="300" grade="low"></m3e-icon>
  <m3e-icon name="error" variant="rounded" weight="500"></m3e-icon>
  <m3e-icon name="schedule" optical-size="20"></m3e-icon>
</span>
```

## API

### `<m3e-icon>`

A small symbol used to easily identify an action or category.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `filled` | `boolean` | false | Whether the icon is filled. |
| `grade` | `"low" \| "medium" \| "high"` | "medium" | The grade of the icon. |
| `optical-size` | `number` | 24 | A value from 20 to 48 indicating the optical size of the icon. |
| `name` | `string` | "" | The name of the icon. |
| `variant` | `"outlined" \| "rounded" \| "sharp"` | "outlined" | The appearance variant of the icon. |
| `weight` | `100 \| 200 \| 300 \| 400 \| 500 \| 600 \| 700` | 400 | A value from 100 to 700 indicating the weight of the icon. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/icon/README.md) (MIT). · Material spec: <https://m3.material.io/styles/icons/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/icon/IconElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/icon/IconElement.ts)

**README drift corrected** (1 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
