# heading

**Family:** [Content & media](../concepts/choosing-components.md#content-media) · See also: [avatar](avatar.md), [icon](icon.md), [shape](shape.md)

The `m3e-heading` component provides expressive, accessible headings for pages and sections, supporting display, headline, title, and label variants in multiple sizes. It applies Material 3 typographic tokens for font size, weight, line height, and letter spacing, ensuring visual hierarchy and clarity.

```ts
import "@m3e/web/heading";
```

## Examples

```html
<m3e-heading variant="display" size="large">Display Large</m3e-heading>
<m3e-heading variant="display" size="medium">Display Medium</m3e-heading>
<m3e-heading variant="display" size="small">Display Small</m3e-heading>
<m3e-heading variant="headline" size="large">Headline Large</m3e-heading>
<m3e-heading variant="headline" size="medium">Headline Medium</m3e-heading>
<m3e-heading variant="headline" size="small">Headline Small</m3e-heading>
<m3e-heading variant="title" size="large">Title Large</m3e-heading>
<m3e-heading variant="title" size="medium">Title Medium</m3e-heading>
<m3e-heading variant="title" size="small">Title Small</m3e-heading>
<m3e-heading variant="label" size="large">Label Large</m3e-heading>
<m3e-heading variant="label" size="medium">Label Medium</m3e-heading>
<m3e-heading variant="label" size="small">Label Small</m3e-heading>
```

```html
<m3e-heading variant="headline" size="large" level="1">Page title</m3e-heading>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Page header hierarchy with semantic levels**

```html
<header>
  <m3e-heading variant="headline" size="large" level="1">Quarterly report</m3e-heading>
  <m3e-heading variant="title" size="medium" level="2">Revenue overview</m3e-heading>
  <p>A summary of performance across all regions for the quarter.</p>
  <m3e-heading variant="label" size="small">Updated 2 hours ago</m3e-heading>
</header>
```

**Emphasized display heading for a hero section**

```html
<section>
  <m3e-heading variant="display" size="large" emphasized level="1">Build faster.</m3e-heading>
  <m3e-heading variant="headline" size="small" level="2">Ship expressive interfaces with Material 3.</m3e-heading>
</section>
```

## API

### `<m3e-heading>`

A heading to a page or section.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `emphasized` | `boolean` | false | Whether the heading uses an emphasized typescale. |
| `level` | `1 \| 2 \| 3 \| 4 \| 5 \| 6 \| undefined` | undefined | The accessibility level of the heading. |
| `size` | `"small" \| "medium" \| "large"` | "medium" | The size of the heading. |
| `variant` | `"display" \| "headline" \| "title" \| "label"` | "display" | The appearance variant of the heading. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the heading. |

**CSS custom properties** — 96 total across 32 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--md-sys-typescale-display-[size]-font-size` | Font size for Display Large text, ideal for hero headlines |
| `--md-sys-typescale-display-[size]-font-weight` | Font weight for Display Large text |
| `--md-sys-typescale-display-[size]-tracking` | Letter spacing for Display Large text |
| `--md-sys-typescale-display-[size]-line-height` | Line height for Display Large text |
| `--md-sys-typescale-headline-[size]-font-size` | Font size for Headline Large text |
| `--md-sys-typescale-headline-[size]-font-weight` | Font weight for Headline Large text |
| `--md-sys-typescale-headline-[size]-tracking` | Letter spacing for Headline Large text |
| `--md-sys-typescale-headline-[size]-line-height` | Line height for Headline Large text |
| `--md-sys-typescale-title-[size]-font-size` | Font size for Title Large text |
| `--md-sys-typescale-title-[size]-font-weight` | Font weight for Title Large text |
| `--md-sys-typescale-title-[size]-tracking` | Letter spacing for Title Large text |
| `--md-sys-typescale-title-[size]-line-height` | Line height for Title Large text |

_…20 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/heading/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/heading/HeadingElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/heading/HeadingElement.ts)
