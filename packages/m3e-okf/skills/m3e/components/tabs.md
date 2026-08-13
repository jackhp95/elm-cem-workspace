# tabs

**Family:** [Navigation](../concepts/choosing-components.md#navigation) · See also: [app-bar](app-bar.md), [toolbar](toolbar.md), [nav-bar](nav-bar.md), [nav-rail](nav-rail.md), [nav-menu](nav-menu.md), [drawer-container](drawer-container.md), [breadcrumb](breadcrumb.md), [toc](toc.md), [paginator](paginator.md), [stepper](stepper.md), [slide-group](slide-group.md)

The `m3e-tabs` component provides a structured navigation surface for organizing content into distinct views, where only one view is visible at a time. It supports scrollable tab headers with optional pagination, accessible labeling for navigation controls, and configurable header positioning to suit various layout contexts. Two visual variants are available: `primary`, which emphasizes active indicators and shape styling for prominent navigation, and `secondary`, which offers a more subtle presentation with reduced indicator thickness. Stretch behavior allows tabs to expand and align rhythmically within their container, consistent with Material 3 guidance.

```ts
import "@m3e/web/tabs";
```

**Elements:** `<m3e-tab>`, `<m3e-tab-panel>`, `<m3e-tabs>`

## Examples

```html
<m3e-tabs>
  <m3e-tab selected for="videos"><m3e-icon slot="icon" name="videocam"></m3e-icon>Video</m3e-tab>
  <m3e-tab for="photos"><m3e-icon slot="icon" name="photo"></m3e-icon>Photos</m3e-tab>
  <m3e-tab for="audio"><m3e-icon slot="icon" name="music_note"></m3e-icon>Audio</m3e-tab>
  <m3e-tab-panel id="videos">Videos</m3e-tab-panel>
  <m3e-tab-panel id="photos">Photos</m3e-tab-panel>
  <m3e-tab-panel id="audio">Audio</m3e-tab-panel>
</m3e-tabs>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Tabs with icons and panels**

```html
<m3e-tabs>
  <m3e-tab selected for="tab-photos"><m3e-icon slot="icon" name="photo_library"></m3e-icon>Photos</m3e-tab>
  <m3e-tab for="tab-facts"><m3e-icon slot="icon" name="psychology"></m3e-icon>Facts</m3e-tab>
  <m3e-tab-panel id="tab-photos">
    <p>Photo grid goes here.</p>
  </m3e-tab-panel>
  <m3e-tab-panel id="tab-facts">
    <p>Facts go here.</p>
  </m3e-tab-panel>
</m3e-tabs>
```

_Source: kinfolk: src/pages/entities/[id].astro_

## API

### `<m3e-tab>`

An interactive element that, when activated, presents an associated tab panel.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |
| `selected` | `boolean` | false | Whether the element is selected. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the tab. |
| `icon` | Renders an icon before the tab's label. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` | `Event` | Dispatched before the selected state changes. |
| `input` | `Event` | Dispatched when the selected state changes. |
| `change` | `Event` | Dispatched when the selected state changes. |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 19 total across 19 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-tab-font-size` | Font size for tab label. |
| `--m3e-tab-font-weight` | Font weight for tab label. |
| `--m3e-tab-line-height` | Line height for tab label. |
| `--m3e-tab-tracking` | Letter spacing for tab label. |
| `--m3e-tab-padding-start` | Padding on the inline start of the tab. |
| `--m3e-tab-padding-end` | Padding on the inline end of the tab. |
| `--m3e-tab-focus-ring-shape` | Border radius for the focus ring. |
| `--m3e-tab-selected-color` | Text color for selected tab. |
| `--m3e-tab-selected-container-hover-color` | Hover state-layer color for selected tab. |
| `--m3e-tab-selected-container-focus-color` | Focus state-layer color for selected tab. |
| `--m3e-tab-selected-ripple-color` | Ripple color for selected tab. |
| `--m3e-tab-unselected-color` | Text color for unselected tab. |

_…7 more families. See source for the full list._

### `<m3e-tab-panel>`

A panel presented for a tab.

**Display:** `block`

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the panel. |

### `<m3e-tabs>`

Organizes content into separate views where only one view can be visible at a time.

**Display:** `flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disable-pagination` |  |  | Whether scroll buttons are disabled. |
| `header-position` | `"before" \| "after"` | "before" | The position of the tab headers. |
| `next-page-label` | `string` | "Next page" | The accessible label given to the button used to move to the next page. |
| `previous-page-label` | `string` | "Previous page" | The accessible label given to the button used to move to the previous page. |
| `stretch` | `boolean` | false | Whether tabs are stretched to fill the header. |
| `variant` | `"primary" \| "secondary"` | "secondary" | The appearance variant of the tabs. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `disablePagination` | `boolean \| "auto"` | Whether scroll buttons are disabled. |
| `tabs` _(readonly)_ | `readonly M3eTabElement[]` | The tabs. |
| `selectedTab` _(readonly)_ | `M3eTabElement \| null` | The selected tab. |
| `selectedIndex` | `number` | The zero-based index of the selected tab. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the tabs. |
| `panel` | Renders the panels of the tabs. |
| `next-icon` | Renders the icon to present for the next button used to paginate. |
| `prev-icon` | Renders the icon to present for the previous button used to paginate. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the selected tab changes. |
| `beforeinput` |  | Dispatched before the selected state of a tab changes. |
| `input` |  | Dispatched when the selected state of a tab changes. |

**CSS custom properties** — 7 total across 7 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-tabs-paginator-button-icon-size` | Overrides the icon size for paginator buttons. |
| `--m3e-tabs-active-indicator-color` | Color of the active tab indicator. |
| `--m3e-tabs-primary-before-active-indicator-shape` | Border radius for active indicator when header is before and variant is primary. |
| `--m3e-tabs-primary-after-active-indicator-shape` | Border radius for active indicator when header is after and variant is primary. |
| `--m3e-tabs-primary-active-indicator-inset` | Inset for primary variant's active indicator. |
| `--m3e-tabs-primary-active-indicator-thickness` | Thickness for primary variant's active indicator. |
| `--m3e-tabs-secondary-active-indicator-thickness` | Thickness for secondary variant's active indicator. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/tabs/README.md) (MIT). · Material spec: <https://m3.material.io/components/tabs/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/tabs/TabElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/tabs/TabElement.ts)
- [`packages/web/src/tabs/TabPanelElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/tabs/TabPanelElement.ts)
- [`packages/web/src/tabs/TabsElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/tabs/TabsElement.ts)
