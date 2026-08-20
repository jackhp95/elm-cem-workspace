# breadcrumb

**Family:** [Navigation](../concepts/choosing-components.md#navigation) · See also: [app-bar](app-bar.md), [toolbar](toolbar.md), [nav-bar](nav-bar.md), [nav-rail](nav-rail.md), [nav-menu](nav-menu.md), [drawer-container](drawer-container.md), [tabs](tabs.md), [toc](toc.md), [paginator](paginator.md), [stepper](stepper.md), [slide-group](slide-group.md)

The `m3e-breadcrumb` and `m3e-breadcrumb-item` components work together to display a hierarchical navigation trail. Use `m3e-breadcrumb` as a wrapper and place one or more `m3e-breadcrumb-item` elements inside to represent the navigation path.

```ts
import "@m3e/web/breadcrumb";
```

**Elements:** `<m3e-breadcrumb>`, `<m3e-breadcrumb-item>`, `<m3e-breadcrumb-item-button>`

## Examples

```html
<m3e-breadcrumb>
  <m3e-breadcrumb-item href="/dashboard">Dashboard</m3e-breadcrumb-item>
  <m3e-breadcrumb-item href="/dashboard/reports">Reports</m3e-breadcrumb-item>
  <m3e-breadcrumb-item href="/dashboard/reports/annual">Annual</m3e-breadcrumb-item>
</m3e-breadcrumb>
```

```html
<m3e-breadcrumb>
  <span slot="separator">/</span>
  <m3e-breadcrumb-item href="/dashboard">Dashboard</m3e-breadcrumb-item>
  <m3e-breadcrumb-item href="/dashboard/reports">Reports</m3e-breadcrumb-item>
  <m3e-breadcrumb-item href="/dashboard/reports/annual">Annual</m3e-breadcrumb-item>
</m3e-breadcrumb>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Breadcrumb trail**

```html
<m3e-breadcrumb>
  <m3e-breadcrumb-item href="/">Home</m3e-breadcrumb-item>
  <m3e-breadcrumb-item href="/work">Work</m3e-breadcrumb-item>
  <m3e-breadcrumb-item href="/work/tags">Tags</m3e-breadcrumb-item>
</m3e-breadcrumb>
```

_Source: 2026: src/components/Breadcrumbs.astro_

**Breadcrumb trail with current page**

```html
<m3e-breadcrumb>
  <m3e-breadcrumb-item href="/photos">Photos</m3e-breadcrumb-item>
  <m3e-breadcrumb-item href="/collections">Collections</m3e-breadcrumb-item>
  <m3e-breadcrumb-item current="page">Title</m3e-breadcrumb-item>
</m3e-breadcrumb>
```

_Source: kinfolk: src/layouts/Layout.astro_

## API

### `<m3e-breadcrumb>`

Displays a hierarchical navigation path and identifies the user's

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `wrap` | `boolean` | false | Whether items wrap to a new line. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders breadcrumb items. |
| `separator` | Renders a custom separator between breadcrumb items. |

### `<m3e-breadcrumb-item>`

An item in a breadcrumb.

**Display:** `block` · **Navigable:** carries a native `href` — do not wrap it in an `<a>`.

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `item-label` | `string` | "" | The accessible label given to the item's internal button. |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `current` | `"page" \| "step" \| "location" \| "date" \| "time" \| "true" \| undefined` | undefined | Indicates the current item in the breadcrumb path. |
| `href` | `string` | "" | The URL to which the internal breadcrumb link button points. |
| `target` | `"_self" \| "_blank" \| "_parent" \| "_top" \| string` | "" | The target of the internal breadcrumb link button. |
| `download` | `string \| null` | null | A value indicating whether the internal link target will be downloaded, optionally specifying a file name. |
| `rel` | `string` | "" | The relationship between the internal link target and the document. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the breadcrumb item. |
| `icon` | Renders an icon before the item's label. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` |  | Dispatched when the element is clicked. |

**CSS custom properties** — 21 total across 21 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-breadcrumb-item-shape` | Shape of the internal breadcrumb item button. |
| `--m3e-breadcrumb-item-container-height` | Height of the internal breadcrumb item button container. |
| `--m3e-breadcrumb-item-icon-color` | Color of breadcrumb item icon-only content. |
| `--m3e-breadcrumb-item-icon-padding-inline` | Horizontal padding for icon-only breadcrumb items. |
| `--m3e-breadcrumb-item-icon-hover-state-layer-color` | Hover state layer color for icon-only breadcrumb items. |
| `--m3e-breadcrumb-item-icon-focus-state-layer-color` | Focus state layer color for icon-only breadcrumb items. |
| `--m3e-breadcrumb-item-icon-pressed-state-layer-color` | Pressed state layer color for icon-only breadcrumb items. |
| `--m3e-breadcrumb-item-label-color` | Color of breadcrumb item label content. |
| `--m3e-breadcrumb-item-label-font-size` | Font size of breadcrumb item label content. |
| `--m3e-breadcrumb-item-label-font-weight` | Font weight of breadcrumb item label content. |
| `--m3e-breadcrumb-item-label-line-height` | Line height of breadcrumb item label content. |
| `--m3e-breadcrumb-item-label-tracking` | Letter spacing of breadcrumb item label content. |

_…9 more families. See source for the full list._

### `<m3e-breadcrumb-item-button>`

**Display:** `block` · **Navigable:** carries a native `href` — do not wrap it in an `<a>`.

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `current` | `"page" \| "step" \| "location" \| "date" \| "time" \| "true" \| undefined` | undefined | Indicates the current item in the breadcrumb path. |
| `href` | `string` | "" | The URL to which the link button points. |
| `target` | `"_self" \| "_blank" \| "_parent" \| "_top" \| string` | "" | The target of the link button. |
| `rel` | `string` | "" | The relationship between the `target` of the link button and the document. |
| `download` | `string \| null` | null | A value indicating whether the `target` of the link button will be downloaded, optionally specifying the new name of the file. |
| `disabled` | `boolean` | false | Whether the element is disabled. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` | `MouseEvent` |  |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/breadcrumb/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/breadcrumb/BreadcrumbElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/breadcrumb/BreadcrumbElement.ts)
- [`packages/web/src/breadcrumb/BreadcrumbItemElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/breadcrumb/BreadcrumbItemElement.ts)
- [`packages/web/src/breadcrumb/BreadcrumbItemButtonElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/breadcrumb/BreadcrumbItemButtonElement.ts)
