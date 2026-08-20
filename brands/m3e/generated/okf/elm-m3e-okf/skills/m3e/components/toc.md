# toc

**Family:** [Navigation](../concepts/choosing-components.md#navigation) · See also: [app-bar](app-bar.md), [toolbar](toolbar.md), [nav-bar](nav-bar.md), [nav-rail](nav-rail.md), [nav-menu](nav-menu.md), [drawer-container](drawer-container.md), [tabs](tabs.md), [breadcrumb](breadcrumb.md), [paginator](paginator.md), [stepper](stepper.md), [slide-group](slide-group.md)

The `m3e-toc` and `m3e-toc-item` components provide a hierarchical, interactive table of contents for in-page navigation. The TOC automatically detects headings or sections in a target element, builds a navigable list, and highlights the active section as the user scrolls. It supports custom header slots, depth limiting, smooth scrolling, and extensive theming via CSS custom properties. > To exclude a heading from the generated table of contents, add the `m3e-toc-ignore` attribute to that heading element.

```ts
import "@m3e/web/toc";
```

**Elements:** `<m3e-toc>`, `<m3e-toc-item>`

## Examples

```html
<m3e-toc for="content" max-depth="3">
  <span slot="overline">Contents</span>
  <span slot="title">Documentation</span>
</m3e-toc>
<div id="content">
  <h2>Introduction</h2>
  <h2>Getting Started</h2>
  <h3>Installation</h3>
  <h3>Usage</h3>
  <h2>API Reference</h2>
</div>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Table of contents with overline slot**

```html
<m3e-toc for="post-content" max-depth="3">
  <span slot="overline">Contents</span>
</m3e-toc>
```

_Source: 2026: src/components/ReadingToolbar.astro_

## API

### `<m3e-toc>`

A table of contents that provides in-page scroll navigation.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |
| `max-depth` | `number` | 2 | The maximum depth of the table of contents. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders content between the header and items. |
| `overline` | Renders the overline of the table of contents. |
| `title` | Renders the title of the table of contents. |

**CSS custom properties** — 19 total across 19 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-toc-width` | Width of the table of contents. |
| `--m3e-toc-container-color` | Background color of the table of contents container. |
| `--m3e-toc-container-padding-inline` | Inline padding of the table of contents container. |
| `--m3e-toc-container-padding-block` | Block padding of the table of contents container. |
| `--m3e-toc-item-shape` | Border radius of TOC items and active indicator. |
| `--m3e-toc-active-indicator-color` | Border color of the active indicator. |
| `--m3e-toc-active-indicator-animation-duration` | Animation duration for the active indicator. |
| `--m3e-toc-item-padding` | Inline padding for TOC items and header. |
| `--m3e-toc-header-space` | Block space below and between header elements. |
| `--m3e-toc-overline-font-size` | Font size for the overline slot. |
| `--m3e-toc-overline-font-weight` | Font weight for the overline slot. |
| `--m3e-toc-overline-line-height` | Line height for the overline slot. |

_…7 more families. See source for the full list._

### `<m3e-toc-item>`

An item in a table of contents.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | A value indicating whether the element is disabled. |
| `selected` | `boolean` | false | Whether the element is selected. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the item. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` |  | Dispatched when the element is clicked. |

**CSS custom properties** — 15 total across 15 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-toc-item-shape` | Border radius of the TOC item. |
| `--m3e-toc-item-padding-block` | Block padding for the TOC item. |
| `--m3e-toc-item-padding` | Inline padding for the TOC item. |
| `--m3e-toc-item-inset` | Indentation per level for the TOC item. |
| `--m3e-toc-active-indicator-animation-duration` | Animation duration for the active indicator. |
| `--m3e-toc-item-font-size` | Font size for unselected items. |
| `--m3e-toc-item-font-weight` | Font weight for unselected items. |
| `--m3e-toc-item-line-height` | Line height for unselected items. |
| `--m3e-toc-item-tracking` | Letter spacing for unselected items. |
| `--m3e-toc-item-color` | Text color for unselected items. |
| `--m3e-toc-item-selected-font-size` | Font size for selected items. |
| `--m3e-toc-item-selected-font-weight` | Font weight for selected items. |

_…3 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/toc/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/toc/TocElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/toc/TocElement.ts)
- [`packages/web/src/toc/TocItemElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/toc/TocItemElement.ts)
