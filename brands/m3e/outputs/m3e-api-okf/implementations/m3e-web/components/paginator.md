# paginator

**Family:** [Navigation](../concepts/choosing-components.md#navigation) · See also: [app-bar](app-bar.md), [toolbar](toolbar.md), [nav-bar](nav-bar.md), [nav-rail](nav-rail.md), [nav-menu](nav-menu.md), [drawer-container](drawer-container.md), [tabs](tabs.md), [breadcrumb](breadcrumb.md), [toc](toc.md), [stepper](stepper.md), [slide-group](slide-group.md)

The `m3e-paginator` component is a compact, accessible paginator control for navigating paged data sets. It provides semantic first/previous/next/last navigation controls and an optional page-size selector.

```ts
import "@m3e/web/paginator";
```

## Examples

```html
<m3e-paginator show-first-last-buttons length="300"></m3e-paginator>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Table paginator with first/last navigation**

```html
<footer>
  <m3e-paginator length="300" page-size="25" page-index="0" page-sizes="10,25,50,100" show-first-last-buttons></m3e-paginator>
</footer>
```

**Compact paginator with hidden page-size selector**

```html
<m3e-paginator length="48" page-size="10" hide-page-size next-page-label="Next results" previous-page-label="Previous results"></m3e-paginator>
```

**Paginator with custom navigation icons**

```html
<m3e-paginator length="500" page-size="50" page-size-variant="filled" show-first-last-buttons>
  <m3e-icon slot="first-page-icon" name="first_page"></m3e-icon>
  <m3e-icon slot="previous-page-icon" name="chevron_left"></m3e-icon>
  <m3e-icon slot="next-page-icon" name="chevron_right"></m3e-icon>
  <m3e-icon slot="last-page-icon" name="last_page"></m3e-icon>
</m3e-paginator>
```

## API

### `<m3e-paginator>`

Provides navigation for paged information, typically used with a table.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `first-page-label` | `string` | "First page" | The accessible label given to the button used to move to the first page. |
| `hide-page-size` | `boolean` | false | Whether to hide page size selection. |
| `items-per-page-label` | `string` | "Items per page:" | The label for the page size selector. |
| `last-page-label` | `string` | "Last page" | The accessible label given to the button used to move to the last page. |
| `length` | `number` | 0 | The length of the total number of items which are being paginated. |
| `next-page-label` | `string` | "Next page" | The accessible label given to the button used to move to the next page. |
| `page-index` | `number` | 0 | The zero-based page index of the displayed list of items. |
| `page-size` | `number \| "all"` | 50 | The number of items to display in a page. |
| `page-sizes` | `string` | "5,10,25,50,100" | A comma separated list of available page sizes. |
| `page-size-variant` | `"filled" \| "outlined"` | "outlined" | The appearance variant of the page size field. |
| `previous-page-label` | `string` | "Previous page" | The accessible label given to the button used to move to the previous page. |
| `show-first-last-buttons` | `boolean` | false | Whether to show first/last buttons. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `pageCount` _(readonly)_ | `number` | The total number of pages. |
| `hasPreviousPage` _(readonly)_ | `boolean` | Whether a previous page can be displayed. |
| `hasNextPage` _(readonly)_ | `boolean` | Whether a next page can be displayed. |
| `rangeLabelFormatter` | `(pageIndex: number, pageSize: number \| "all", length: number) => string \| undefined` | A function used to format the range label. |

**Slots**

| Slot | Description |
| --- | --- |
| `first-page-icon` | Slot for a custom first-page icon. |
| `previous-page-icon` | Slot for a custom previous-page icon. |
| `next-page-icon` | Slot for a custom next-page icon. |
| `last-page-icon` | Slot for a custom last-page icon. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `page` | `CustomEvent` | Dispatched when a user selects a different page size or navigates to another page. |

**CSS custom properties** — 4 total across 4 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-paginator-font-size` | The font size used for paginator text. |
| `--m3e-paginator-font-weight` | The font weight used for paginator text. |
| `--m3e-paginator-line-height` | The line height used for paginator text. |
| `--m3e-paginator-tracking` | The letter-spacing used for paginator text. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/paginator/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/paginator/PaginatorElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/paginator/PaginatorElement.ts)
