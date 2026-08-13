# card

**Family:** [Containers & surfaces](../concepts/choosing-components.md#containers) · See also: [content-pane](content-pane.md), [dialog](dialog.md), [bottom-sheet](bottom-sheet.md), [split-pane](split-pane.md), [expansion-panel](expansion-panel.md), [divider](divider.md), [menu](menu.md)

The `m3e-card` component is a flexible, expressive container for presenting a unified subject—text, media, and actions—on a visually distinct surface. It supports multiple appearance variants via the `variant` attribute: `filled` (default, for solid emphasis), `outlined` (for subtle framing with a border), and `elevated` (for depth and motion with shadow elevation). Cards can be made actionable, responding to user interaction when the `actionable` attribute is set, and can be presented inline with surrounding content using the `inline` attribute. It supports both vertical and horizontal layouts through the `orientation` attribute. Content organization is enabled via dedicated slots for `header`, `content`, `actions`, and `footer`, or developers can use the default slot for custom layouts.

```ts
import "@m3e/web/card";
```

## Examples

```html
<m3e-card>
  <div slot="header">Header section</div>
  <div slot="content">Content section</div>
  <div slot="actions">Actions section</div>
  <div slot="footer">Footer section</div>
</m3e-card>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Outlined card with header and content slots**

```html
<m3e-card variant="outlined">
  <m3e-heading slot="header" variant="title" size="small">People</m3e-heading>
  <div slot="content">
    <m3e-chip-set>
      <m3e-chip>Person Name</m3e-chip>
      <m3e-chip>Relative</m3e-chip>
    </m3e-chip-set>
  </div>
</m3e-card>
```

_Source: kinfolk: src/pages/photos/[id].astro_

**Actionable filled card linking to a detail page**

```html
<a href="/entities/1">
  <m3e-card variant="filled" actionable>
    <div slot="content">
      <m3e-icon name="family_history"></m3e-icon>
      <span>Relative</span>
      <m3e-icon name="chevron_right"></m3e-icon>
    </div>
  </m3e-card>
</a>
```

_Source: kinfolk: src/pages/entities/[id].astro_

## Common mistakes

**Media goes in the `header` slot (or the default slot), not a custom wrapper.** The `header` slot renders without padding — it's the natural home for edge-to-edge images or media. The default (unnamed) slot also renders without padding. Do not create a separate "media seam" or clipping wrapper; the card's corner radius clips its own content.

```html
<!-- ✅ Media in the header slot — no extra clipping needed -->
<m3e-card variant="elevated">
  <img slot="header" src="photo.jpg" alt="…" />
  <div slot="content">…</div>
</m3e-card>
```

See also: [re-abstracting design tokens](/anti-patterns/re-abstracting-design-tokens).

## API

### `<m3e-card>`

A content container for text, images (or other media), and actions in the context of a single subject.

**Display:** `block` (block by default; inline-block with the `inline` attribute) · **Navigable:** carries a native `href` — do not wrap it in an `<a>`.

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `actionable` | `boolean` | false | Whether the card is "actionable" and will respond to use interaction. |
| `inline` | `boolean` | false | Whether to present the card inline with surrounding content. |
| `orientation` | `"horizontal" \| "vertical"` | "vertical" | The orientation of the card. |
| `variant` | `"elevated" \| "filled" \| "outlined"` | "filled" | The appearance variant of the card. |
| `href` | `string` | "" | The URL to which the link button points. |
| `target` | `"_self" \| "_blank" \| "_parent" \| "_top" \| string` | "" | The target of the link button. |
| `rel` | `string` | "" | The relationship between the `target` of the link button and the document. |
| `download` | `string \| null` | null | A value indicating whether the `target` of the link button will be downloaded, optionally specifying the new name of the file. |
| `name` |  |  | The name of the element, submitted as a pair with the element's `value` as part of form data, when the element is used to submit a form. |
| `value` |  |  | The value associated with the element's name when it's submitted with form data. |
| `type` | `"button" \| "submit" \| "reset"` | "button" | The type of the element. |
| `disabled-interactive` | `boolean` | false | Whether the element is disabled and interactive. |
| `disabled` | `boolean` | false | Whether the element is disabled. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the card without padding. |
| `header` | Renders the header of the card. |
| `content` | Renders the content of the card with padding. |
| `actions` | Renders the actions of the card. |
| `footer` | Renders the footer of the card. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 73 total across 31 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-card-padding` | Internal spacing for all slotted regions |
| `--m3e-card-shape` | Corner radius of the card container. |
| `--m3e-[variant]-card-text-color` | Foreground color for text content in filled cards. |
| `--m3e-[variant]-card-container-color` | Background color of the filled card container. |
| `--m3e-[variant]-card-container-elevation` | Elevation level for filled card container. |
| `--m3e-[variant]-card-disabled-text-color` | Text color when filled card is disabled. |
| `--m3e-[variant]-card-disabled-text-opacity` | Opacity applied to text when disabled. |
| `--m3e-[variant]-card-disabled-container-color` | Background color when disabled. |
| `--m3e-[variant]-card-disabled-container-elevation` | Elevation level when disabled. |
| `--m3e-[variant]-card-disabled-container-elevation-color` | Shadow color when disabled. |
| `--m3e-[variant]-card-disabled-container-elevation-opacity` | Shadow opacity when disabled. |
| `--m3e-[variant]-card-disabled-container-opacity` | Overall container opacity when disabled. |

_…19 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/card/README.md) (MIT). · Material spec: <https://m3.material.io/components/cards/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/card/CardElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/card/CardElement.ts)

**README drift corrected** (9 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
