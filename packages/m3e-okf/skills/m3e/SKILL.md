---
name: m3e
description: >-
  Implements web UIs with the M3E (Material 3 Expressive) web component library —
  @m3e/web, the matraic/m3e <m3e-*> custom elements. Use when the user mentions
  m3e, @m3e/web, "material web components", or names an m3e component (button,
  dialog, list, nav-bar, chips, fab, etc.) and needs to add, wire, or style it, so
  tags, attributes, slots, events, and CSS tokens are correct and not hallucinated
  from generic Material Design knowledge. This skill is technology-specific to
  @m3e/web; for stack-neutral Material 3 design guidance use applying-material-design.
---

# M3E — Material 3 Expressive web components (using @m3e/web)

Correct, verified usage for the **@m3e/web** custom-element library
(`matraic/m3e`). Every component here is a real `<m3e-*>` custom element. This
skill is the **implementation layer** — technology-specific to `@m3e/web`.

## How to use this skill (read only what you need)

1. **Not sure which component?** Read [`concepts/choosing-components.md`](concepts/choosing-components.md) — selection guidance by intent.
2. **Know the component?** Open **`components/<name>.md`** for its verified API —
   tags, attributes (exact types/defaults), slots, events, CSS properties, examples.
3. **Need design guidance — the why/when at the design level** (component-class
   choice, foundations, expressive application, anti-patterns)? Read the
   technology-neutral **M3 Expressive knowledge bundle** starting at its index,
   [`/knowledge/index.md`](/knowledge/index.md), then open only the concept you
   need. Each neutral component page links to its verified `<m3e-*>` card here.
4. Import per component: `import "@m3e/web/<name>";` (ESM, tree-shakeable).
5. Cross-cutting concerns (theming, type, motion, framework setup) live in `concepts/`.
6. Don't guess attribute names/values from generic Material Design — the card is
   the source of truth. If a card lacks something, follow its source link.

> **Fidelity:** cards are generated from the library's build-time Custom
> Elements Manifest (machine truth) + TypeScript source, pinned at
> `v2.7.3`. Where the upstream prose README disagreed with the code, the
> code value is used and the drift is noted on the card.

## Components (55, by family)

### Actions & buttons

Elements users click to perform an action.

| Component | Tag(s) | What it's for |
| --- | --- | --- |
| [button](components/button.md) | `m3e-button` | Semantic, expressive UI primitive users interact with to perform an action. |
| [icon-button](components/icon-button.md) | `m3e-icon-button` | Semantic, expressive UI primitive for triggering actions with a single icon. |
| [fab](components/fab.md) | `m3e-fab` | Prominent, expressive UI component that represents the primary action on a screen. |
| [fab-menu](components/fab-menu.md) | `m3e-fab-menu +2` | Presents a dynamic menu of related actions, elegantly revealed from a floating action button (FAB). |
| [split-button](components/split-button.md) | `m3e-split-button` | Presents a primary action alongside a menu of related actions, uniting two buttons in a single expressive surface. |
| [button-group](components/button-group.md) | `m3e-button-group` | Arranges multiple into a unified, expressive layout, supporting both `standard` and `connected` variants. |
| [segmented-button](components/segmented-button.md) | `m3e-segmented-button +1` | Allows users to select one or more options from a horizontal group. |

### Selection controls

Form controls for choosing values.

| Component | Tag(s) | What it's for |
| --- | --- | --- |
| [checkbox](components/checkbox.md) | `m3e-checkbox` | Enables users to select one or more options from a set. |
| [radio-group](components/radio-group.md) | `m3e-radio-group +1` | Enable single-choice selection within a set of mutually exclusive options. |
| [switch](components/switch.md) | `m3e-switch` | Semantic, accessible toggle control that reflects a binary state. |
| [slider](components/slider.md) | `m3e-slider +1` | Enables users to select a numeric value from a continuous or discrete range. |
| [chips](components/chips.md) | `m3e-chip +7` | The `@m3e/web/chips` module provides expressive, accessible chip components for actions, input, filtering, and suggestions, each supporting two… |

### Text input & forms

Fields for entering and selecting text.

| Component | Tag(s) | What it's for |
| --- | --- | --- |
| [form-field](components/form-field.md) | `m3e-form-field` | Semantic, expressive container for form controls that anchors label behavior, subscript messaging, and variant-specific layout. |
| [select](components/select.md) | `m3e-select` | Provides a form control for selecting a value from a set of predefined options. |
| [autocomplete](components/autocomplete.md) | `m3e-autocomplete` | Enhances a text input field with a dynamically positioned menu of filterable suggestions. |
| [search](components/search.md) | `m3e-search-bar +1` | Provide a Material 3 expressive search experience. |
| [textarea-autosize](components/textarea-autosize.md) | `m3e-textarea-autosize` | Automatically adjusts the height of a linked `textarea` to fit its content, preserving layout integrity and user experience. |
| [option](components/option.md) | `m3e-option +2` | The `m3e-option`, `m3e-option-panel`, and `m3e-optgroup` components provide a complete solution for displaying selectable options in menus and lists. |

### Navigation

Moving between destinations and through content.

| Component | Tag(s) | What it's for |
| --- | --- | --- |
| [app-bar](components/app-bar.md) | `m3e-app-bar` | Prominent user interface component that provides consistent access to key actions, navigation, and contextual information at the top of an… |
| [toolbar](components/toolbar.md) | `m3e-toolbar` | Presents contextual actions, navigation, and controls. |
| [nav-bar](components/nav-bar.md) | `m3e-nav-bar +1` | Provide a navigation bar and interactive items for switching between primary destinations in your application. |
| [nav-rail](components/nav-rail.md) | `m3e-nav-rail +1` | Extends `@m3e/nav-bar` to provide a vertical navigation rail and interactive items for switching between primary destinations in your application. |
| [nav-menu](components/nav-menu.md) | `m3e-nav-menu +2` | Provides a hierarchical, accessible navigation menu. |
| [drawer-container](components/drawer-container.md) | `m3e-drawer-container +1` | Provides a responsive layout container for managing one or two sliding drawers alongside main content. |
| [tabs](components/tabs.md) | `m3e-tabs +2` | Provides a structured navigation surface for organizing content into distinct views, where only one view is visible at a time. |
| [breadcrumb](components/breadcrumb.md) | `m3e-breadcrumb +2` | Work together to display a hierarchical navigation trail. |
| [toc](components/toc.md) | `m3e-toc +1` | Provide a hierarchical, interactive table of contents for in-page navigation. |
| [paginator](components/paginator.md) | `m3e-paginator` | Compact, accessible paginator control for navigating paged data sets. |
| [stepper](components/stepper.md) | `m3e-stepper +5` | Orchestrates a structured, wizard-like workflow by dividing content into discrete, navigable steps. |
| [slide-group](components/slide-group.md) | `m3e-slide-group` | Presents directional pagination controls for navigating overflowing content. |

### Containers & surfaces

Surfaces that group or reveal content.

| Component | Tag(s) | What it's for |
| --- | --- | --- |
| [card](components/card.md) | `m3e-card` | Flexible, expressive container for presenting a unified subject—text, media, and actions—on a visually distinct surface. |
| [content-pane](components/content-pane.md) | `m3e-content-pane` | Renders a shaped surface with padding and vertical scrolling for document‑like content. |
| [dialog](components/dialog.md) | `m3e-dialog +2` | Presents important prompts, alerts, and actions in user flows. |
| [bottom-sheet](components/bottom-sheet.md) | `m3e-bottom-sheet +2` | Implements a Material 3 bottom sheet with gesture‑driven resizing, detent snapping, and adaptive motion. |
| [split-pane](components/split-pane.md) | `m3e-split-pane` | Delivers a Material 3-inspired split view with a movable drag handle, enabling responsive layout composition and precise pane resizing. |
| [expansion-panel](components/expansion-panel.md) | `m3e-expansion-panel +2` | The `@m3e/web/expansion-panel` module provides expressive, accessible components for organizing content in collapsible sections and coordinated… |
| [divider](components/divider.md) | `m3e-divider` | Visually separates content within layouts, lists, or containers using a thin, unobtrusive line. |
| [menu](components/menu.md) | `m3e-menu +5` | The `@m3e/web/menu` module provides a cohesive set of components for constructing accessible, anchored menus that align with Material 3 design… |

### Data & collections

Showing structured or hierarchical data.

| Component | Tag(s) | What it's for |
| --- | --- | --- |
| [list](components/list.md) | `m3e-list +7` | The `@m3e/list` package provides expressive, accessible components for organizing and displaying lists of items. |
| [tree](components/tree.md) | `m3e-tree +1` | Presents hierarchical data in a structure that users can navigate, with nested levels that open and collapse as needed. |
| [calendar](components/calendar.md) | `m3e-calendar +3` | Provides structured navigation and selection across month, year, and multi-year views. |
| [datepicker](components/datepicker.md) | `m3e-datepicker +1` | Presents a temporary, structured surface for selecting dates across month, year, and multi-year views. |
| [date-input](components/date-input.md) | `m3e-date-input` | # @m3e/web/date-input The `m3e-date-input` component provides a segmented input for editing date and/or time values. |
| [timepicker](components/timepicker.md) | `m3e-timepicker +4` | Presents a temporary surface for selecting time using dial and keyboard modes. |

### Feedback & status

Communicating status, progress, and messages.

| Component | Tag(s) | What it's for |
| --- | --- | --- |
| [badge](components/badge.md) | `m3e-badge` | Compact visual indicator used to label content. |
| [snackbar](components/snackbar.md) | `m3e-snackbar` | The `@m3e/snackbar` package provides the `M3eSnackbar` global service on `window` (`globalThis`) used to present short updates about application… |
| [tooltip](components/tooltip.md) | `m3e-tooltip +2` | The `@m3e/web/tooltip` module provides tooltip and rich‑tooltip components for delivering contextual guidance, from simple hover descriptions to… |
| [loading-indicator](components/loading-indicator.md) | `m3e-loading-indicator` | Uses animation to grab attention, mitigate perceived latency, and indicate that an activity is in progress. |
| [progress-indicator](components/progress-indicator.md) | `m3e-circular-progress-indicator +1` | Provide accessible, animated progress indicators for tracking the completion of tasks or processes. |
| [skeleton](components/skeleton.md) | `m3e-skeleton` | Provides a loading placeholder surface with flexible shape variants and motion-based animations that communicate loading state while preserving… |

### Content & media

Identity, iconography, and shape primitives.

| Component | Tag(s) | What it's for |
| --- | --- | --- |
| [avatar](components/avatar.md) | `m3e-avatar` | Reusable identity primitive that displays visual or textual representation with consistent sizing, shape, and typography. |
| [icon](components/icon.md) | `m3e-icon` | Makes it easy to use Material Symbols in your application. |
| [heading](components/heading.md) | `m3e-heading` | Provides expressive, accessible headings for pages and sections, supporting display, headline, title, and label variants in multiple sizes. |
| [shape](components/shape.md) | `m3e-shape` | Allows you to use abstract shapes thoughtfully to add emphasis and decorative flair, including built-in shape morphing. |

### System

Non-visual configuration elements.

| Component | Tag(s) | What it's for |
| --- | --- | --- |
| [theme](components/theme.md) | `m3e-theme +1` | Non-visual element used to apply dynamic color, expressive motion, density, and strong focus indicators to nested, theme-aware elements. |


## Design guidance (the reference tier)

For the design-level *why* and *when* — independent of `@m3e/web` — this skill's
reference tier is the technology-neutral **M3 Expressive knowledge bundle** at
[`/knowledge/index.md`](/knowledge/index.md): foundations, styles, per-class
component guidance, expressive application, canonical patterns, and anti-patterns.
Route there for design decisions; route to the cards below for exact API.

## Concepts

- [Choosing components](concepts/choosing-components.md) — which component when
- [Forms & validation](concepts/forms.md) — wiring m3e controls into a native `<form>`
- Foundations: [Accessibility](concepts/accessibility.md) · [Layout](concepts/layout.md) · [Interaction states](concepts/interaction-states.md) · [Design tokens](concepts/design-tokens.md) · [Content design](concepts/content-design.md)
- Styles: [Color & theming](concepts/color.md) · [Density](concepts/density.md) · [Elevation](concepts/elevation.md) · [Motion](concepts/motion.md) · [Shape](concepts/shape.md) · [Typography](concepts/typography.md) · [Icons](concepts/icons.md)
- [Getting started](concepts/getting-started.md) · [Installation](concepts/installation.md)
- Frameworks: [React](concepts/frameworks-react.md) · [Vue](concepts/frameworks-vue.md) · [Angular](concepts/frameworks-angular.md)

## Conventions

- All tags are prefixed `m3e-`. Many components export several elements
  (e.g. `chips` → `m3e-chip-set`, `m3e-filter-chip`, …) — see the card.
- Boolean attributes follow the HTML convention (present = true).
- Icons use `m3e-icon` (see the `icon` component card).
- Theming uses Material `--md-sys-*` design tokens — see [Color & theming](concepts/color.md).
