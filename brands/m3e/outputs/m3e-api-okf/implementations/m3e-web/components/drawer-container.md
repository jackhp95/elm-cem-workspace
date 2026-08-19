# drawer-container

**Family:** [Navigation](../concepts/choosing-components.md#navigation) · See also: [app-bar](app-bar.md), [toolbar](toolbar.md), [nav-bar](nav-bar.md), [nav-rail](nav-rail.md), [nav-menu](nav-menu.md), [tabs](tabs.md), [breadcrumb](breadcrumb.md), [toc](toc.md), [paginator](paginator.md), [stepper](stepper.md), [slide-group](slide-group.md)

The `m3e-drawer-container` component provides a responsive layout container for managing one or two sliding drawers alongside main content. It supports multiple drawer modes (`over`, `push`, `side`, and `auto`), adapts to breakpoint size, and encodes spatial hierarchy, motion transitions, and accessibility semantics for modal, dismissible, and permanent navigation.

```ts
import "@m3e/web/drawer-container";
```

**Elements:** `<m3e-drawer-container>`, `<m3e-drawer-toggle>`

## Examples

```html
<m3e-drawer-container>
  <nav slot="start">
    <!-- Start drawer content -->
  </nav>
  <main>
    <!-- Main content -->
  </main>
  <aside slot="end">
    <!-- End drawer content -->
  </aside>
</m3e-drawer-container>
```

```html
<m3e-icon-button slot="leading-icon" aria-label="Menu" toggle selected>
  <m3e-drawer-toggle for="startDrawer"></m3e-drawer-toggle>
  <m3e-icon name="menu"></m3e-icon>
  <m3e-icon slot="selected" name="menu_open"></m3e-icon>
</m3e-icon-button>

<m3e-drawer-container start>
  <nav slot="start" id="startDrawer" aria-label="Navigation">
    <!-- Start drawer content -->
  </nav>
  <!-- Container content -->
</m3e-drawer-container>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**App shell with navigation drawer toggle**

```html
<m3e-button variant="text" toggle>
  <m3e-drawer-toggle for="nav"></m3e-drawer-toggle>
  <m3e-icon slot="icon" name="menu"></m3e-icon>
  Menu
</m3e-button>
<m3e-drawer-container start start-mode="over">
  <nav slot="start" id="nav" aria-label="Primary">
    <a href="/home">Home</a>
    <a href="/reports">Reports</a>
    <a href="/settings">Settings</a>
  </nav>
  <main>
    <h1>Dashboard</h1>
    <p>Welcome back. Select an item from the navigation drawer.</p>
  </main>
</m3e-drawer-container>
```

**Dual drawers with side navigation and detail panel**

```html
<m3e-drawer-container start start-mode="side" start-divider end end-mode="over">
  <nav slot="start" aria-label="Sections">
    <a href="/inbox">Inbox</a>
    <a href="/sent">Sent</a>
    <a href="/archive">Archive</a>
  </nav>
  <main>
    <header>
      <h1>Inbox</h1>
    </header>
    <p>Your messages appear here.</p>
  </main>
  <aside slot="end" aria-label="Details">
    <h2>Filters</h2>
    <label>
      <m3e-checkbox checked></m3e-checkbox>
      Unread only
    </label>
  </aside>
</m3e-drawer-container>
```

## API

### `<m3e-drawer-container>`

A container for one or two sliding drawers.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `end` | `boolean` | false | Whether the end drawer is open. |
| `end-mode` | `"over" \| "push" \| "side" \| "auto"` | "side" | The behavior mode of the end drawer. |
| `end-divider` | `boolean` | false | Whether to show a divider between the end drawer and content for `side` mode. |
| `start` | `boolean` | false | Whether the start drawer is open. |
| `start-mode` | `"over" \| "push" \| "side" \| "auto"` | "side" | The behavior mode of the start drawer. |
| `start-divider` | `boolean` | false | Whether to show a divider between the start drawer and content for `side` mode. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the main content. |
| `start` | Renders the start drawer. |
| `end` | Renders the end drawer. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the state of the start or end drawers change. |

**CSS custom properties** — 10 total across 10 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-drawer-container-color` | The background color of the drawer container. |
| `--m3e-drawer-container-elevation` | The elevation level of the drawer container. |
| `--m3e-drawer-container-width` | The width of the drawer container. |
| `--m3e-drawer-container-scrim-opacity` | The opacity of the scrim behind the drawer. |
| `--m3e-modal-drawer-start-shape` | The shape of the drawer's start edge (typically left in LTR). |
| `--m3e-modal-drawer-end-shape` | The shape of the drawer's end edge (typically right in LTR). |
| `--m3e-modal-drawer-container-color` | The background color of the modal drawer container. |
| `--m3e-modal-drawer-elevation` | The elevation level of the modal drawer container. |
| `--m3e-drawer-divider-color` | The color of the divider between drawer sections. |
| `--m3e-drawer-divider-thickness` | The thickness of the divider line. |

### `<m3e-drawer-toggle>`

An element, nested within a clickable element, used to toggle the opened state of a drawer.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/drawer-container/README.md) (MIT). · Material spec: <https://m3.material.io/components/navigation-drawer/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/drawer-container/DrawerContainerElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/drawer-container/DrawerContainerElement.ts)
- [`packages/web/src/drawer-container/DrawerToggleElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/drawer-container/DrawerToggleElement.ts)

**README drift corrected** (1 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
