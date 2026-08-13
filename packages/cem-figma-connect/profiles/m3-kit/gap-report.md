# Gap report — m3-kit

D6: this report LOGS gaps for human review — it never auto-authors a correspondence entry from a guess. See plans/BRIEF.md §7.4 (the completeness inversion) and research/evidence/06a-expressive-delta.md for the name-level estimate this reconciles against.

## Counts

- CEM tags total: 130
- Matched (distinct CEM tags): 36 (24 exact, 1 fuzzy, 11 contains)
- code-only: 94
- figma-only: 221
- valid-but-undrawn combinations: 12 (20 matched component(s) have no axis/fusion data to evaluate — see the section below)
- unmapped axes: 61

**Reconciliation vs 06a:** research/evidence/06a-expressive-delta.md's human, name-level read of this same fixture estimated 53 matched / 68 code-only. The auto-matcher measured here binds only 36 distinct CEM tags (24 exact + 1 fuzzy + 11 contains), so code-only measures 94, not 68. This is BY DESIGN, not a defect: the doc-URL fuzzy signal is inert on this fixture (0 shared m3.material.io URLs on either side), `FUZZY_ACCEPT_THRESHOLD` (0.50) is deliberately conservative, and abbreviation/semantic-only matches (e.g. "Standard button group"/"Connected button group" vs `m3e-button-group`) are deliberately NOT forced through (D6) — the gap between 06a's optimistic estimate and the measured code-only count IS the human-review surface this report exists to produce.

## code-only

CEM tags with NO Figma counterpart at exact/fuzzy tier — computed as all CEM tags MINUS the distinct tags the matcher bound.

| CEM tag | Description | Rationale |
| --- | --- | --- |
| `m3e-accordion` | Combines multiple expansion panels in to an accordion. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-action-list` | A list of actions. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-autocomplete` | Enhances a text input with suggested options. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-bottom-sheet-action` | An element, nested within a clickable element, used to close a parenting bottom sheet. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-bottom-sheet-trigger` | An element, nested within a clickable element, used to trigger a bottom sheet. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-breadcrumb` | Displays a hierarchical navigation path and identifies the user's current location within an application. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-breadcrumb-item` | An item in a breadcrumb. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-breadcrumb-item-button` |  | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-button-segment` | A option that can be selected within a segmented button. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-calendar` | A calendar used to select a date. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-chip` | A non-interactive chip used to convey small pieces of information. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-chip-set` | A container used to organize chips into a cohesive unit. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-collapsible` | A container used to expand and collapse content. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-content-pane` | A shaped surface for vertically scrollable content. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-date-input` | A segmented input for entering date and/or time values using a keyboard. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-datepicker` | Presents a date picker on a temporary surface. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-datepicker-toggle` | An element, nested within a clickable element, used to toggle a datepicker. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-dialog-action` | An element, nested within a clickable element, used to close a parenting dialog. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-dialog-trigger` | An element, nested within a clickable element, used to open a dialog. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-divider` | A thin line that separates content in lists or other containers. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-drawer-container` | A container for one or two sliding drawers. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-drawer-toggle` | An element, nested within a clickable element, used to toggle the opened state of a drawer. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-elevation` | Visually depicts elevation using a shadow. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-expandable-list-item` | An item in a list that can be expanded to show more items. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-expansion-header` | A button used to toggle the expanded state of an expansion panel. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-expansion-panel` | An expandable details-summary view. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-fab-menu-item` | An item of a floating action button (FAB) menu. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-fab-menu-trigger` | An element, nested within a clickable element, used to open a floating action button (FAB) menu. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-filter-chip-set` | A container that organizes filter chips into a cohesive group, enabling selection and deselection of values used to refine content or trigger contextual behavior. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-floating-panel` | A lightweight, generic floating surface used to present content above the page. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-focus-ring` | A focus ring used to depict a strong focus indicator. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-focus-trap` | A non-visual element used to trap focus within nested content. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-form-field` | A container for form controls that applies Material Design styling and behavior. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-heading` | A heading to a page or section. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-input-chip-set` | A container that transforms user input into a cohesive set of interactive chips, supporting entry, editing, and removal of discrete values. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-list-action` | An item in a list that performs an action. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-list-item-button` |  | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-list-option` | A selectable option in a list. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-menu-item-checkbox` | An item of a menu which supports a checkable state. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-menu-item-group` | Groups related items (such a radios) in a menu. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-menu-item-radio` | An item of a menu which supports a mutually exclusive checkable state. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-menu-trigger` | An element, nested within a clickable element, used to open a menu. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-month-view` | An internal component used to display a single month in a calendar. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-multi-year-view` | An internal component used to display a year selector in a calendar. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-nav-bar` | A horizontal bar, typically used on smaller devices, that allows a user to switch between 3-5 views. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-nav-menu` | A hierarchical menu, typically used on larger devices, that allows a user to switch between views. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-nav-menu-item` | An expandable item, selectable item within a navigation menu. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-nav-menu-item-group` | A top-level semantic grouping of items in a navigation menu. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-nav-rail` | A vertical bar, typically used on larger devices, that allows a user to switch between views. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-nav-rail-toggle` | An element, nested within a clickable element, used to toggle the expanded state of a navigation rail. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-optgroup` | Groups options under a subheading. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-option` | An option that can be selected. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-option-panel` | Presents a list of options on a temporary surface. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-paginator` | Provides navigation for paged information, typically used with a table. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-pseudo-checkbox` | An element which looks like a checkbox. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-pseudo-radio` | An element which looks like a radio button. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-radio` | A radio button that allows a user to select one option from a set of options. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-radio-group` | A container for a set of radio buttons. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-rich-tooltip-action` | An element, nested within a clickable element, used to dismiss a parenting rich tooltip. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-ripple` | Connects user input to screen reactions using ripples. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-scroll-container` | A vertically oriented content container which presents dividers above and below content when scrolled. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-search-view` | A surface that presents suggestions and results for a search. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-select` | A form control that allows users to select a value from a set of predefined options. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-selection-indicator` | Provides selection, focus, and hover state layer treatment for an interactive element that supports selection. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-selection-list` | A list of selectable options. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-skeleton` | A visual placeholder that mimics the layout of content while it's still loading. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-slide` | A carousel-like container used to horizontally cycle through slotted items. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-slide-group` | Presents pagination controls used to scroll overflowing content. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-slider-thumb` | A thumb used to select a value in a slider. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-split-pane` | A dual-view layout that separates content with a movable drag handle. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-state-layer` | Provides focus and hover state layer treatment for an interactive element. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-step` | A step in a wizard-like workflow. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-step-panel` | A panel presented for a step in a wizard-like workflow. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-stepper` | Provides a wizard-like workflow by dividing content into logical steps. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-stepper-next` | An element, nested within a clickable element, used to move a stepper to the next step. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-stepper-previous` | An element, nested within a clickable element, used to move a stepper to the previous step. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-stepper-reset` | An element, nested within a clickable element, used to reset a stepper to its initial state. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-tab` | An interactive element that, when activated, presents an associated tab panel. | code-only: 'm3e-tab' lost a slug collision to another CEM tag (see the winning candidate's rationale) and has no other Figma counterpart — surfaced here so it is never silently dropped |
| `m3e-tab-panel` | A panel presented for a tab. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-text-highlight` | Highlights text which matches a given search term. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-text-overflow` | An inline container which presents an ellipsis when content overflows. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-textarea-autosize` | A non-visual element used to automatically resize a `textarea` to fit its content. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-theme` | A non-visual element responsible for application-level theming. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-theme-icon` | An icon that visually presents a preview of a theme. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-timepicker` | Presents a time picker on a temporary surface. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-timepicker-dial` | A clock‑face surface for selecting hours and minutes using a movable hand. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-timepicker-input` | A keyboard‑based time surface for choosing hours and minutes. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-timepicker-input-period-toggle` |  | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-timepicker-toggle` | An element, nested within a clickable element, used to toggle a timepicker. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-toc` | A table of contents that provides in-page scroll navigation. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-toc-item` | An item in a table of contents. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-tree` | Presents hierarchical data in a tree structure. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-tree-item` | An expandable item in a tree. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |
| `m3e-year-view` | An internal component used to display a single year in a calendar. | no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only matches are deferred to human review, never auto-forced) |

## figma-only

Figma sets/standalone components the matcher gapped (`cemTag: null`) — a drawn kit entity with no CEM counterpart at any tier.

| Page | Figma name | Kind | Rationale |
| --- | --- | --- | --- |
| App bars | .Building Blocks/App bar/Content/Avatar | set | gap: no CEM tag matched slug 'app-bar-content-avatar' at exact or fuzzy tier |
| App bars | .Building Blocks/App bar/Content/Text Large | set | gap: no CEM tag matched slug 'app-bar-content-text-large' at exact or fuzzy tier |
| App bars | .Building Blocks/App bar/Content/Text Medium | set | gap: no CEM tag matched slug 'app-bar-content-text-medium' at exact or fuzzy tier |
| App bars | .Building Blocks/App bar/Content/Text Small | set | gap: no CEM tag matched slug 'app-bar-content-text-small' at exact or fuzzy tier |
| App bars | .Building Blocks/App bar/Content/Thumbnail | standalone | gap: no CEM tag matched slug 'app-bar-content-thumbnail' at exact or fuzzy tier |
| App bars | .Building Blocks/Flat/Search bar - Modified | set | gap: no CEM tag matched slug 'flat-search-bar-modified' at exact or fuzzy tier |
| App bars | .Building Blocks/On-scroll/Search bar - Modified | set | gap: no CEM tag matched slug 'on-scroll-search-bar-modified' at exact or fuzzy tier |
| App bars | Bottom app bar | set | gap: no CEM tag matched slug 'bottom-app-bar' at exact or fuzzy tier |
| App bars | XR/XR App Bar | set | gap: no CEM tag matched slug 'xr-xr-app-bar' at exact or fuzzy tier |
| Avatars | 3D Avatars / 1 | standalone | gap: no CEM tag matched slug '3d-avatar-1' at exact or fuzzy tier |
| Avatars | 3D Avatars / 10 | standalone | gap: no CEM tag matched slug '3d-avatar-10' at exact or fuzzy tier |
| Avatars | 3D Avatars / 11 | standalone | gap: no CEM tag matched slug '3d-avatar-11' at exact or fuzzy tier |
| Avatars | 3D Avatars / 12 | standalone | gap: no CEM tag matched slug '3d-avatar-12' at exact or fuzzy tier |
| Avatars | 3D Avatars / 13 | standalone | gap: no CEM tag matched slug '3d-avatar-13' at exact or fuzzy tier |
| Avatars | 3D Avatars / 14 | standalone | gap: no CEM tag matched slug '3d-avatar-14' at exact or fuzzy tier |
| Avatars | 3D Avatars / 15 | standalone | gap: no CEM tag matched slug '3d-avatar-15' at exact or fuzzy tier |
| Avatars | 3D Avatars / 16 | standalone | gap: no CEM tag matched slug '3d-avatar-16' at exact or fuzzy tier |
| Avatars | 3D Avatars / 17 | standalone | gap: no CEM tag matched slug '3d-avatar-17' at exact or fuzzy tier |
| Avatars | 3D Avatars / 18 | standalone | gap: no CEM tag matched slug '3d-avatar-18' at exact or fuzzy tier |
| Avatars | 3D Avatars / 19 | standalone | gap: no CEM tag matched slug '3d-avatar-19' at exact or fuzzy tier |
| Avatars | 3D Avatars / 2 | standalone | gap: no CEM tag matched slug '3d-avatar-2' at exact or fuzzy tier |
| Avatars | 3D Avatars / 20 | standalone | gap: no CEM tag matched slug '3d-avatar-20' at exact or fuzzy tier |
| Avatars | 3D Avatars / 21 | standalone | gap: no CEM tag matched slug '3d-avatar-21' at exact or fuzzy tier |
| Avatars | 3D Avatars / 22 | standalone | gap: no CEM tag matched slug '3d-avatar-22' at exact or fuzzy tier |
| Avatars | 3D Avatars / 23 | standalone | gap: no CEM tag matched slug '3d-avatar-23' at exact or fuzzy tier |
| Avatars | 3D Avatars / 24 | standalone | gap: no CEM tag matched slug '3d-avatar-24' at exact or fuzzy tier |
| Avatars | 3D Avatars / 25 | standalone | gap: no CEM tag matched slug '3d-avatar-25' at exact or fuzzy tier |
| Avatars | 3D Avatars / 26 | standalone | gap: no CEM tag matched slug '3d-avatar-26' at exact or fuzzy tier |
| Avatars | 3D Avatars / 27 | standalone | gap: no CEM tag matched slug '3d-avatar-27' at exact or fuzzy tier |
| Avatars | 3D Avatars / 28 | standalone | gap: no CEM tag matched slug '3d-avatar-28' at exact or fuzzy tier |
| Avatars | 3D Avatars / 29 | standalone | gap: no CEM tag matched slug '3d-avatar-29' at exact or fuzzy tier |
| Avatars | 3D Avatars / 3 | standalone | gap: no CEM tag matched slug '3d-avatar-3' at exact or fuzzy tier |
| Avatars | 3D Avatars / 30 | standalone | gap: no CEM tag matched slug '3d-avatar-30' at exact or fuzzy tier |
| Avatars | 3D Avatars / 4 | standalone | gap: no CEM tag matched slug '3d-avatar-4' at exact or fuzzy tier |
| Avatars | 3D Avatars / 5 | standalone | gap: no CEM tag matched slug '3d-avatar-5' at exact or fuzzy tier |
| Avatars | 3D Avatars / 6 | standalone | gap: no CEM tag matched slug '3d-avatar-6' at exact or fuzzy tier |
| Avatars | 3D Avatars / 7 | standalone | gap: no CEM tag matched slug '3d-avatar-7' at exact or fuzzy tier |
| Avatars | 3D Avatars / 8 | standalone | gap: no CEM tag matched slug '3d-avatar-8' at exact or fuzzy tier |
| Avatars | 3D Avatars / 9 | standalone | gap: no CEM tag matched slug '3d-avatar-9' at exact or fuzzy tier |
| Buttons | .Building Blocks/FAB Menu/Primary/FAB | set | gap: no CEM tag matched slug 'fab-menu-primary-fab' at exact or fuzzy tier |
| Buttons | .Building Blocks/FAB Menu/Primary/Segment | set | gap: no CEM tag matched slug 'fab-menu-primary-segment' at exact or fuzzy tier |
| Buttons | .Building Blocks/FAB Menu/Secondary/FAB | set | gap: no CEM tag matched slug 'fab-menu-secondary-fab' at exact or fuzzy tier |
| Buttons | .Building Blocks/FAB Menu/Secondary/Segment | set | gap: no CEM tag matched slug 'fab-menu-secondary-segment' at exact or fuzzy tier |
| Buttons | .Building Blocks/FAB Menu/Tertiary/FAB | set | gap: no CEM tag matched slug 'fab-menu-tertiary-fab' at exact or fuzzy tier |
| Buttons | .Building Blocks/FAB Menu/Tertiary/Segment | set | gap: no CEM tag matched slug 'fab-menu-tertiary-segment' at exact or fuzzy tier |
| Buttons | Building Blocks/Button group/Connected segments/Large | set | gap: no CEM tag matched slug 'button-group-connected-segment-large' at exact or fuzzy tier |
| Buttons | Building Blocks/Button group/Connected segments/Medium | set | gap: no CEM tag matched slug 'button-group-connected-segment-medium' at exact or fuzzy tier |
| Buttons | Building Blocks/Button group/Connected segments/Small | set | gap: no CEM tag matched slug 'button-group-connected-segment-small' at exact or fuzzy tier |
| Buttons | Building Blocks/Button group/Connected segments/XSmall | set | gap: no CEM tag matched slug 'button-group-connected-segment-xsmall' at exact or fuzzy tier |
| Buttons | Building Blocks/Button group/Connected segments/Xlarge | set | gap: no CEM tag matched slug 'button-group-connected-segment-xlarge' at exact or fuzzy tier |
| Buttons | Building Blocks/Segmented button/Button segment (end) | set | gap: no CEM tag matched slug 'segmented-button-button-segment-end' at exact or fuzzy tier |
| Buttons | Building Blocks/Segmented button/Button segment (middle) | set | gap: no CEM tag matched slug 'segmented-button-button-segment-middle' at exact or fuzzy tier |
| Buttons | Building Blocks/Segmented button/Button segment (start) | set | gap: no CEM tag matched slug 'segmented-button-button-segment-start' at exact or fuzzy tier |
| Buttons | Extended FAB | set | gap: no CEM tag matched slug 'extended-fab' at exact or fuzzy tier |
| Buttons | Icon button togglable | fusion | page 'Buttons': fused 4 sibling sets (bare 'Icon button togglable' + 3 '<Base> - <value>') sharing variant axes [Type, Size, Width, Selected, State] \| gap: no CEM tag matched slug 'icon-button-togglable' at exact or fuzzy tier |
| Buttons | Toggle button | fusion | page 'Buttons': fused 4 sibling sets (bare 'Toggle button' + 3 '<Base> - <value>') sharing variant axes [Type, Size, State, Selected] \| gap: no CEM tag matched slug 'toggle-button' at exact or fuzzy tier |
| Cards | .Building Blocks/Card states/Elevated | set | gap: no CEM tag matched slug 'card-state-elevated' at exact or fuzzy tier |
| Cards | .Building Blocks/Card states/Filled | set | gap: no CEM tag matched slug 'card-state-filled' at exact or fuzzy tier |
| Cards | .Building Blocks/Card states/Outlined | set | gap: no CEM tag matched slug 'card-state-outlined' at exact or fuzzy tier |
| Carousel | Building blocks/General item | standalone | gap: no CEM tag matched slug 'building-block-general-item' at exact or fuzzy tier |
| Carousel | Building blocks/Multi-ratio items/16:9 | standalone | gap: no CEM tag matched slug 'building-block-multi-ratio-item-16-9' at exact or fuzzy tier |
| Carousel | Building blocks/Multi-ratio items/1:1 | standalone | gap: no CEM tag matched slug 'building-block-multi-ratio-item-1-1' at exact or fuzzy tier |
| Carousel | Building blocks/Multi-ratio items/3:4 | standalone | gap: no CEM tag matched slug 'building-block-multi-ratio-item-3-4' at exact or fuzzy tier |
| Carousel | Building blocks/Multi-ratio items/4:3 | standalone | gap: no CEM tag matched slug 'building-block-multi-ratio-item-4-3' at exact or fuzzy tier |
| Carousel | Building blocks/Multi-ratio items/9:16 | standalone | gap: no CEM tag matched slug 'building-block-multi-ratio-item-9-16' at exact or fuzzy tier |
| Carousel | Carousel | fusion | page 'Carousel': fused 2 sibling sets (bare 'Carousel' + 1 '<Base> - <value>') sharing variant axes [Context, Layout] \| gap: no CEM tag matched slug 'carousel' at exact or fuzzy tier |
| Chips | .Building Blocks/Colourful logo | standalone | gap: no CEM tag matched slug 'colourful-logo' at exact or fuzzy tier |
| Chips | .Building Blocks/Favicon | standalone | gap: no CEM tag matched slug 'favicon' at exact or fuzzy tier |
| Chips | Chip groups | set | gap: no CEM tag matched slug 'chip-group' at exact or fuzzy tier |
| Date & time pickers | .Building Blocks/Clock face - 12 hour | standalone | gap: no CEM tag matched slug 'clock-face-12-hour' at exact or fuzzy tier |
| Date & time pickers | .Building Blocks/Clock face - 24 hour | standalone | gap: no CEM tag matched slug 'clock-face-24-hour' at exact or fuzzy tier |
| Date & time pickers | .Building Blocks/Direct Input (keyboard) input | set | gap: no CEM tag matched slug 'direct-input-keyboard-input' at exact or fuzzy tier |
| Date & time pickers | .Building Blocks/Hour | set | gap: no CEM tag matched slug 'hour' at exact or fuzzy tier |
| Date & time pickers | .Building Blocks/Input | set | gap: no CEM tag matched slug 'input' at exact or fuzzy tier |
| Date & time pickers | .Building Blocks/Local M3 calendar cell | set | gap: no CEM tag matched slug 'local-m3-calendar-cell' at exact or fuzzy tier |
| Date & time pickers | .Building Blocks/Menu button | set | gap: no CEM tag matched slug 'menu-button' at exact or fuzzy tier |
| Date & time pickers | .Building Blocks/Period Selector | fusion | page 'Date & time pickers': fused 2 sibling sets (bare '.Building Blocks/Period Selector' + 1 '<Base> - <value>') sharing variant axes [AM/PM, State] \| gap: no CEM tag matched slug 'period-selector' at exact or fuzzy tier |
| Date & time pickers | .Building Blocks/Year | set | gap: no CEM tag matched slug 'year' at exact or fuzzy tier |
| Date & time pickers | .Building Blocks/hour-line | set | gap: no CEM tag matched slug 'hour-line' at exact or fuzzy tier |
| Date & time pickers | Dial picker | set | gap: no CEM tag matched slug 'dial-picker' at exact or fuzzy tier |
| Date & time pickers | Docked input date picker [desktop] | set | gap: no CEM tag matched slug 'docked-input-date-picker-desktop' at exact or fuzzy tier |
| Date & time pickers | Input date picker | set | gap: no CEM tag matched slug 'input-date-picker' at exact or fuzzy tier |
| Date & time pickers | Keyboard picker | set | gap: no CEM tag matched slug 'keyboard-picker' at exact or fuzzy tier |
| Date & time pickers | Modal date picker | set | gap: no CEM tag matched slug 'modal-date-picker' at exact or fuzzy tier |
| Dialogs | List dialog | set | gap: no CEM tag matched slug 'list-dialog' at exact or fuzzy tier |
| Dialogs | Scrollable list dialog | set | gap: no CEM tag matched slug 'scrollable-list-dialog' at exact or fuzzy tier |
| Dialogs | XR/XR Dialog | set | gap: no CEM tag matched slug 'xr-xr-dialog' at exact or fuzzy tier |
| Dividers | Horizontal/Divider with subhead | standalone | gap: no CEM tag matched slug 'horizontal-divider-with-subhead' at exact or fuzzy tier |
| Dividers | Horizontal/Full-width | standalone | gap: no CEM tag matched slug 'horizontal-full-width' at exact or fuzzy tier |
| Dividers | Horizontal/Inset | standalone | gap: no CEM tag matched slug 'horizontal-inset' at exact or fuzzy tier |
| Dividers | Horizontal/Middle-inset | standalone | gap: no CEM tag matched slug 'horizontal-middle-inset' at exact or fuzzy tier |
| Dividers | Vertical/Full-width | standalone | gap: no CEM tag matched slug 'vertical-full-width' at exact or fuzzy tier |
| Dividers | Vertical/Inset | standalone | gap: no CEM tag matched slug 'vertical-inset' at exact or fuzzy tier |
| Dividers | Vertical/Middle-inset | standalone | gap: no CEM tag matched slug 'vertical-middle-inset' at exact or fuzzy tier |
| Examples | Examples/Detailed view-Mobile | standalone | gap: no CEM tag matched slug 'example-detailed-view-mobile' at exact or fuzzy tier |
| Examples | Examples/Detailed view-Web | standalone | gap: no CEM tag matched slug 'example-detailed-view-web' at exact or fuzzy tier |
| Examples | Examples/Gallery-Mobile | standalone | gap: no CEM tag matched slug 'example-gallery-mobile' at exact or fuzzy tier |
| Examples | Examples/Gallery-Web | standalone | gap: no CEM tag matched slug 'example-gallery-web' at exact or fuzzy tier |
| Examples | Examples/Home-Mobile | standalone | gap: no CEM tag matched slug 'example-home-mobile' at exact or fuzzy tier |
| Examples | Examples/Home-Web | standalone | gap: no CEM tag matched slug 'example-home-web' at exact or fuzzy tier |
| Examples | Examples/Layout grid | set | gap: no CEM tag matched slug 'example-layout-grid' at exact or fuzzy tier |
| Examples | Examples/Library-Mobile | standalone | gap: no CEM tag matched slug 'example-library-mobile' at exact or fuzzy tier |
| Examples | Examples/Library-Web | standalone | gap: no CEM tag matched slug 'example-library-web' at exact or fuzzy tier |
| Examples | Examples/Messaging-Mobile | standalone | gap: no CEM tag matched slug 'example-messaging-mobile' at exact or fuzzy tier |
| Examples | Examples/Messaging-Web | standalone | gap: no CEM tag matched slug 'example-messaging-web' at exact or fuzzy tier |
| Examples | Examples/Reviews-Mobile | standalone | gap: no CEM tag matched slug 'example-review-mobile' at exact or fuzzy tier |
| Examples | Examples/Reviews-Web | standalone | gap: no CEM tag matched slug 'example-review-web' at exact or fuzzy tier |
| Examples | Examples/Upcoming-Mobile | standalone | gap: no CEM tag matched slug 'example-upcoming-mobile' at exact or fuzzy tier |
| Examples | Examples/Upcoming-Web | standalone | gap: no CEM tag matched slug 'example-upcoming-web' at exact or fuzzy tier |
| Lists | .Building Blocks/Monogram | standalone | gap: no CEM tag matched slug 'monogram' at exact or fuzzy tier |
| Lists | .Building Blocks/image-Thumbnail | standalone | gap: no CEM tag matched slug 'image-thumbnail' at exact or fuzzy tier |
| Lists | .Building Blocks/video-Thumbnail | standalone | gap: no CEM tag matched slug 'video-thumbnail' at exact or fuzzy tier |
| Lists | Building Blocks/state-layer/1. enabled | standalone | gap: no CEM tag matched slug 'state-layer-1-enabled' at exact or fuzzy tier |
| Lists | Building Blocks/state-layer/2. hovered | standalone | gap: no CEM tag matched slug 'state-layer-2-hovered' at exact or fuzzy tier |
| Lists | Building Blocks/state-layer/3. focused | standalone | gap: no CEM tag matched slug 'state-layer-3-focused' at exact or fuzzy tier |
| Lists | Building Blocks/state-layer/4. pressed | standalone | gap: no CEM tag matched slug 'state-layer-4-pressed' at exact or fuzzy tier |
| Lists | Building Blocks/state-layer/5. dragged | standalone | gap: no CEM tag matched slug 'state-layer-5-dragged' at exact or fuzzy tier |
| Lists | Building blocks/Content | set | gap: no CEM tag matched slug 'building-block-content' at exact or fuzzy tier |
| Lists | Building blocks/Leading element | set | gap: no CEM tag matched slug 'building-block-leading-element' at exact or fuzzy tier |
| Lists | Building blocks/List item/Accordion buttton | set | gap: no CEM tag matched slug 'building-block-list-item-accordion-buttton' at exact or fuzzy tier |
| Lists | Building blocks/Reveal element | set | gap: no CEM tag matched slug 'building-block-reveal-element' at exact or fuzzy tier |
| Lists | Building blocks/Trailing element | set | gap: no CEM tag matched slug 'building-block-trailing-element' at exact or fuzzy tier |
| Lists | List (baseline) | standalone | gap: no CEM tag matched slug 'list-baseline' at exact or fuzzy tier |
| Lists | List Item - Swipe | set | gap: no CEM tag matched slug 'list-item-swipe' at exact or fuzzy tier |
| Lists | List item - Accordion  | set | gap: no CEM tag matched slug 'list-item-accordion' at exact or fuzzy tier |
| Lists | List item/List Item: -2 Density (baseline) | set | gap: no CEM tag matched slug 'list-item-list-item-2-density-baseline' at exact or fuzzy tier |
| Lists | List item/List Item: -4 Density (baseline) | set | gap: no CEM tag matched slug 'list-item-list-item-4-density-baseline' at exact or fuzzy tier |
| Lists | List item/List Item: 0 Density (baseline) | set | gap: no CEM tag matched slug 'list-item-list-item-0-density-baseline' at exact or fuzzy tier |
| Lists | List: -2 Density (baseline) | standalone | gap: no CEM tag matched slug 'list-2-density-baseline' at exact or fuzzy tier |
| Lists | List: -4 Density (baseline) | standalone | gap: no CEM tag matched slug 'list-4-density-baseline' at exact or fuzzy tier |
| Loading & progress | .Building Blocks/Progress indicator/Width 4/Segment - flat | standalone | gap: no CEM tag matched slug 'progress-indicator-width-4-segment-flat' at exact or fuzzy tier |
| Loading & progress | .Building Blocks/Progress indicator/Width 4/Segment - wave | set | gap: no CEM tag matched slug 'progress-indicator-width-4-segment-wave' at exact or fuzzy tier |
| Loading & progress | .Building Blocks/Progress indicator/Width 4/Stop | standalone | gap: no CEM tag matched slug 'progress-indicator-width-4-stop' at exact or fuzzy tier |
| Loading & progress | .Building Blocks/Progress indicator/Width 4/Track | standalone | gap: no CEM tag matched slug 'progress-indicator-width-4-track' at exact or fuzzy tier |
| Loading & progress | .Building Blocks/Progress indicator/Width 8/ Segment - flat | standalone | gap: no CEM tag matched slug 'progress-indicator-width-8-segment-flat' at exact or fuzzy tier |
| Loading & progress | .Building Blocks/Progress indicator/Width 8/Segment - wave | set | gap: no CEM tag matched slug 'progress-indicator-width-8-segment-wave' at exact or fuzzy tier |
| Loading & progress | .Building Blocks/Progress indicator/Width 8/Stop | standalone | gap: no CEM tag matched slug 'progress-indicator-width-8-stop' at exact or fuzzy tier |
| Loading & progress | .Building Blocks/Progress indicator/Width 8/Track | standalone | gap: no CEM tag matched slug 'progress-indicator-width-8-track' at exact or fuzzy tier |
| Menu | .Building Blocks/Content | set | gap: no CEM tag matched slug 'content' at exact or fuzzy tier |
| Menu | .Building Blocks/Label-basic | standalone | gap: no CEM tag matched slug 'label-basic' at exact or fuzzy tier |
| Menu | .Building Blocks/Label-vibrant | standalone | gap: no CEM tag matched slug 'label-vibrant' at exact or fuzzy tier |
| Menu | .Building Blocks/Leading element | set | gap: no CEM tag matched slug 'leading-element' at exact or fuzzy tier |
| Menu | .Building Blocks/Trailing element | set | gap: no CEM tag matched slug 'trailing-element' at exact or fuzzy tier |
| Menu | Building Blocks/Leading element | set | gap: no CEM tag matched slug 'leading-element' at exact or fuzzy tier |
| Menu | Building Blocks/Menu list item | set | gap: no CEM tag matched slug 'menu-list-item' at exact or fuzzy tier |
| Menu | Building Blocks/Menu list item: -2 density | set | gap: no CEM tag matched slug 'menu-list-item-2-density' at exact or fuzzy tier |
| Menu | Building Blocks/Menu list item: -4 density | set | gap: no CEM tag matched slug 'menu-list-item-4-density' at exact or fuzzy tier |
| Menu | Building Blocks/Trailing element | set | gap: no CEM tag matched slug 'trailing-element' at exact or fuzzy tier |
| Menu | Building Blocks/Trailing element-selected | set | gap: no CEM tag matched slug 'trailing-element-selected' at exact or fuzzy tier |
| Menu | Menu (baseline) | set | gap: no CEM tag matched slug 'menu-baseline' at exact or fuzzy tier |
| Menu | Menu - Icon button Example | standalone | gap: no CEM tag matched slug 'menu-icon-button-example' at exact or fuzzy tier |
| Menu | Menu item/Vibrant | set | gap: no CEM tag matched slug 'menu-item-vibrant' at exact or fuzzy tier |
| Menu | Menu with Text field - Example 1 | standalone | gap: no CEM tag matched slug 'menu-with-text-field-example-1' at exact or fuzzy tier |
| Menu | Menu with Text field - Example 2 | standalone | gap: no CEM tag matched slug 'menu-with-text-field-example-2' at exact or fuzzy tier |
| Navigation | .Building Blocks / Headline | standalone | gap: no CEM tag matched slug 'building-block-headline' at exact or fuzzy tier |
| Navigation | Building Blocks / Section header | standalone | gap: no CEM tag matched slug 'building-block-section-header' at exact or fuzzy tier |
| Navigation | Building Blocks/Navigation bars/Horizontal nav item | set | gap: no CEM tag matched slug 'navigation-bar-horizontal-nav-item' at exact or fuzzy tier |
| Navigation | Building Blocks/Navigation bars/Vertical nav item | set | gap: no CEM tag matched slug 'navigation-bar-vertical-nav-item' at exact or fuzzy tier |
| Navigation | Building Blocks/Navigation rail/Horizontal nav item | set | gap: no CEM tag matched slug 'navigation-rail-horizontal-nav-item' at exact or fuzzy tier |
| Navigation | Building Blocks/Navigation rail/Vertical nav item | set | gap: no CEM tag matched slug 'navigation-rail-vertical-nav-item' at exact or fuzzy tier |
| Navigation | Building Blocks/XR/Navigation bar/Nav item | set | gap: no CEM tag matched slug 'xr-navigation-bar-nav-item' at exact or fuzzy tier |
| Navigation | Building Blocks/XR/Navigation rail/Nav item | set | gap: no CEM tag matched slug 'xr-navigation-rail-nav-item' at exact or fuzzy tier |
| Navigation | Navigation Bar: Horizontal items | set | gap: no CEM tag matched slug 'navigation-bar-horizontal-item' at exact or fuzzy tier |
| Navigation | Navigation Bar: Vertical items | set | gap: no CEM tag matched slug 'navigation-bar-vertical-item' at exact or fuzzy tier |
| Navigation | Navigation Drawer | standalone | gap: no CEM tag matched slug 'navigation-drawer' at exact or fuzzy tier |
| Navigation | Navigation Rail | set | gap: no CEM tag matched slug 'navigation-rail' at exact or fuzzy tier |
| Navigation | Navigation Rail: Expanded | set | gap: no CEM tag matched slug 'navigation-rail-expanded' at exact or fuzzy tier |
| Navigation | XR/XR Navigation Rail | set | gap: no CEM tag matched slug 'xr-xr-navigation-rail' at exact or fuzzy tier |
| Navigation | XR/XR Navigation bar | set | gap: no CEM tag matched slug 'xr-xr-navigation-bar' at exact or fuzzy tier |
| Radio button | Radio buttons | set | gap: no CEM tag matched slug 'radio-button' at exact or fuzzy tier |
| Search | Search docked layout | set | gap: no CEM tag matched slug 'search-docked-layout' at exact or fuzzy tier |
| Search | Search docked layout (baseline) | set | gap: no CEM tag matched slug 'search-docked-layout-baseline' at exact or fuzzy tier |
| Search | Search full-screen layout | set | gap: no CEM tag matched slug 'search-full-screen-layout' at exact or fuzzy tier |
| Search | Search full-screen layout (baseline) | set | gap: no CEM tag matched slug 'search-full-screen-layout-baseline' at exact or fuzzy tier |
| Sheets | Building Blocks/Bottom sheets/Content | set | gap: no CEM tag matched slug 'bottom-sheet-content' at exact or fuzzy tier |
| Sheets | Building Blocks/Side sheets/Content | set | gap: no CEM tag matched slug 'side-sheet-content' at exact or fuzzy tier |
| Sheets | Side Sheet | set | gap: no CEM tag matched slug 'side-sheet' at exact or fuzzy tier |
| Sliders | .Building Blocks/Active track | standalone | gap: no CEM tag matched slug 'active-track' at exact or fuzzy tier |
| Sliders | .Building Blocks/Handle | standalone | gap: no CEM tag matched slug 'handle' at exact or fuzzy tier |
| Sliders | .Building Blocks/Inactive track | standalone | gap: no CEM tag matched slug 'inactive-track' at exact or fuzzy tier |
| Sliders | .Building Blocks/Inactive track left | standalone | gap: no CEM tag matched slug 'inactive-track-left' at exact or fuzzy tier |
| Sliders | .Building Blocks/Stops | standalone | gap: no CEM tag matched slug 'stop' at exact or fuzzy tier |
| Sliders | .Building Blocks/Track stop | standalone | gap: no CEM tag matched slug 'track-stop' at exact or fuzzy tier |
| Sliders | .Building Blocks/Value indicator | standalone | gap: no CEM tag matched slug 'value-indicator' at exact or fuzzy tier |
| Sliders | Centered slider | set | gap: no CEM tag matched slug 'centered-slider' at exact or fuzzy tier |
| Sliders | Range slider | set | gap: no CEM tag matched slug 'range-slider' at exact or fuzzy tier |
| Snackbar | .Building Blocks/Snackbar-action | set | gap: no CEM tag matched slug 'snackbar-action' at exact or fuzzy tier |
| Snackbar | .Building Blocks/Snackbar-close-affordance | set | gap: no CEM tag matched slug 'snackbar-close-affordance' at exact or fuzzy tier |
| Styles | .Header | standalone | gap: no CEM tag matched slug 'header' at exact or fuzzy tier |
| Styles | .Schematic group | standalone | gap: no CEM tag matched slug 'schematic-group' at exact or fuzzy tier |
| Styles | .Shape | set | gap: no CEM tag matched slug 'shape' at exact or fuzzy tier |
| Styles | .Tonal palettes | standalone | gap: no CEM tag matched slug 'tonal-palette' at exact or fuzzy tier |
| Tabs | Primary tabs/Icon and label | set | gap: no CEM tag matched slug 'primary-tab-icon-and-label' at exact or fuzzy tier |
| Tabs | Primary tabs/Icon only | set | gap: no CEM tag matched slug 'primary-tab-icon-only' at exact or fuzzy tier |
| Tabs | Primary tabs/Label only | set | gap: no CEM tag matched slug 'primary-tab-label-only' at exact or fuzzy tier |
| Tabs | Secondary tabs/Icon and label | set | gap: no CEM tag matched slug 'secondary-tab-icon-and-label' at exact or fuzzy tier |
| Tabs | Secondary tabs/Label only | set | gap: no CEM tag matched slug 'secondary-tab-label-only' at exact or fuzzy tier |
| Text fields | Text field | set | gap: no CEM tag matched slug 'text-field' at exact or fuzzy tier |
| Toolbars | Building Blocks/Standard/Button toggleable | set | gap: no CEM tag matched slug 'standard-button-toggleable' at exact or fuzzy tier |
| Toolbars | Building Blocks/Standard/Icon button | set | gap: no CEM tag matched slug 'standard-icon-button' at exact or fuzzy tier |
| Toolbars | Building Blocks/Standard/Icon button toggleable | set | gap: no CEM tag matched slug 'standard-icon-button-toggleable' at exact or fuzzy tier |
| Toolbars | Building Blocks/Vibrant/Button toggleable | set | gap: no CEM tag matched slug 'vibrant-button-toggleable' at exact or fuzzy tier |
| Toolbars | Building Blocks/Vibrant/Icon button | set | gap: no CEM tag matched slug 'vibrant-icon-button' at exact or fuzzy tier |
| Toolbars | Building Blocks/Vibrant/Icon button toggleable | set | gap: no CEM tag matched slug 'vibrant-icon-button-toggleable' at exact or fuzzy tier |
| Toolbars | XR/Building Blocks/Surface high/Button toggleable | set | gap: no CEM tag matched slug 'xr-building-block-surface-high-button-toggleable' at exact or fuzzy tier |
| Toolbars | XR/Building Blocks/Surface high/Icon button | set | gap: no CEM tag matched slug 'xr-building-block-surface-high-icon-button' at exact or fuzzy tier |
| Toolbars | XR/Building Blocks/Surface high/Icon button toggleable | set | gap: no CEM tag matched slug 'xr-building-block-surface-high-icon-button-toggleable' at exact or fuzzy tier |
| Toolbars | XR/Building Blocks/Surface/Button toggleable | set | gap: no CEM tag matched slug 'xr-building-block-surface-button-toggleable' at exact or fuzzy tier |
| Toolbars | XR/Building Blocks/Surface/Icon button | set | gap: no CEM tag matched slug 'xr-building-block-surface-icon-button' at exact or fuzzy tier |
| Toolbars | XR/Building Blocks/Surface/Icon button toggleable | set | gap: no CEM tag matched slug 'xr-building-block-surface-icon-button-toggleable' at exact or fuzzy tier |
| Toolbars | XR/Building Blocks/Tertiary container/Button toggleable | set | gap: no CEM tag matched slug 'xr-building-block-tertiary-container-button-toggleable' at exact or fuzzy tier |
| Toolbars | XR/Building Blocks/Tertiary container/Icon button | set | gap: no CEM tag matched slug 'xr-building-block-tertiary-container-icon-button' at exact or fuzzy tier |
| Toolbars | XR/Building Blocks/Tertiary container/Icon button toggleable | set | gap: no CEM tag matched slug 'xr-building-block-tertiary-container-icon-button-toggleable' at exact or fuzzy tier |
| Toolbars | XR/XR Toolbar | set | gap: no CEM tag matched slug 'xr-xr-toolbar' at exact or fuzzy tier |
| Utilities | Building Blocks/navigation | standalone | gap: no CEM tag matched slug 'navigation' at exact or fuzzy tier |
| Utilities | Building Blocks/status-bar | standalone | gap: no CEM tag matched slug 'statu-bar' at exact or fuzzy tier |
| Utilities | Device frame | standalone | gap: no CEM tag matched slug 'device-frame' at exact or fuzzy tier |
| Utilities | Focus indicator | standalone | gap: no CEM tag matched slug 'focu-indicator' at exact or fuzzy tier |
| Utilities | Keyboard | set | gap: no CEM tag matched slug 'keyboard' at exact or fuzzy tier |
| Utilities | Scrim | standalone | gap: no CEM tag matched slug 'scrim' at exact or fuzzy tier |
| Utilities | Shared Building Blocks/Slot-component | standalone | gap: no CEM tag matched slug 'shared-building-block-slot-component' at exact or fuzzy tier |

## valid-but-undrawn

Per MATCHED component: the CEM cartesian value space over the matcher's own mapped axes / fusion attribute, minus the combinations the matcher's captured Figma data confirms were drawn — the completeness inversion (plans/BRIEF.md §7.4).

**Coverage caveat (always applies, not just when data is missing):** coverage is checked PER-AXIS (marginal), not per-joint-combination, because the figma-export carries no variant→owning-set parent link — this cannot detect a combination whose individual axis values are each drawn elsewhere but never drawn TOGETHER. Treat an empty result for a component as "no axis value was individually undrawn," NOT as proof of full combinatorial coverage.

> **Data limitation, not a design gap:** 20 of the 36 matched component(s) (`m3e-app-bar`, `m3e-avatar`, `m3e-bottom-sheet`, `m3e-checkbox`, `m3e-circular-progress-indicator`, `m3e-dialog`, `m3e-fab-menu`, `m3e-icon`, `m3e-input-chip`, `m3e-list`, `m3e-list-item`, `m3e-loading-indicator`, `m3e-menu-item`, `m3e-nav-item`, `m3e-rich-tooltip`, `m3e-search-bar`, `m3e-segmented-button`, `m3e-snackbar`, `m3e-switch`, `m3e-tooltip`) carry zero axis/fusion data on this pre-A3 fixture (only 2 of 171 kit sets' `setProperties` were captured live — the button's bare and elevated sibling sets — and these components have no fusion sibling sets to fall back on either). This section can only reason about the component(s) that DO carry dimension data; A3's live extractor unlocks the rest.

| CEM tag | Combination | Rationale |
| --- | --- | --- |
| `m3e-badge` | size=medium | cartesian over size (sizes: size=3) includes this combination, but no captured Figma axis/fusion data confirms it was drawn |
| `m3e-fab` | size=large, variant=surface | cartesian over size × variant (sizes: size=3, variant=7) includes this combination, but no captured Figma axis/fusion data confirms it was drawn |
| `m3e-fab` | size=medium, variant=surface | cartesian over size × variant (sizes: size=3, variant=7) includes this combination, but no captured Figma axis/fusion data confirms it was drawn |
| `m3e-fab` | size=small, variant=primary | cartesian over size × variant (sizes: size=3, variant=7) includes this combination, but no captured Figma axis/fusion data confirms it was drawn |
| `m3e-fab` | size=small, variant=primary-container | cartesian over size × variant (sizes: size=3, variant=7) includes this combination, but no captured Figma axis/fusion data confirms it was drawn |
| `m3e-fab` | size=small, variant=secondary | cartesian over size × variant (sizes: size=3, variant=7) includes this combination, but no captured Figma axis/fusion data confirms it was drawn |
| `m3e-fab` | size=small, variant=secondary-container | cartesian over size × variant (sizes: size=3, variant=7) includes this combination, but no captured Figma axis/fusion data confirms it was drawn |
| `m3e-fab` | size=small, variant=surface | cartesian over size × variant (sizes: size=3, variant=7) includes this combination, but no captured Figma axis/fusion data confirms it was drawn |
| `m3e-fab` | size=small, variant=tertiary | cartesian over size × variant (sizes: size=3, variant=7) includes this combination, but no captured Figma axis/fusion data confirms it was drawn |
| `m3e-fab` | size=small, variant=tertiary-container | cartesian over size × variant (sizes: size=3, variant=7) includes this combination, but no captured Figma axis/fusion data confirms it was drawn |
| `m3e-linear-progress-indicator` | mode=buffer | cartesian over mode (sizes: mode=4) includes this combination, but no captured Figma axis/fusion data confirms it was drawn |
| `m3e-linear-progress-indicator` | mode=query | cartesian over mode (sizes: mode=4) includes this combination, but no captured Figma axis/fusion data confirms it was drawn |

## unmapped-axes

Figma VARIANT axes on a matched component's set/fusion that the matcher could not bind to any CEM enum attribute — never silently dropped (plans/01-architecture.md §3 item 4).

| CEM tag | Figma axis | Reason |
| --- | --- | --- |
| `m3e-app-bar` | Configuration | no CEM enum attribute shares its value set (options: Small-centered, Small-image, Search, Small, Medium, Large) |
| `m3e-app-bar` | Elevation | no CEM enum attribute shares its value set (options: Flat, On-scroll) |
| `m3e-assist-chip` | Configuration | no CEM enum attribute shares its value set (options: Label only, Label & icon, Label & favicon, Label & brand icon) |
| `m3e-assist-chip` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed, Dragged, Disabled) |
| `m3e-avatar` | Style | no CEM enum attribute shares its value set (options: Check, Monogram, Avatar) |
| `m3e-button` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed, Disabled) |
| `m3e-button-group` | Type | no CEM enum attribute shares its value set (options: Round, Square) |
| `m3e-card` | Layout | no CEM enum attribute shares its value set (options: Slot, Media & text) |
| `m3e-checkbox` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed, Disabled) |
| `m3e-circular-progress-indicator` | Progress | no CEM enum attribute shares its value set (options: 0, 10, 30, 50, 80, 100) |
| `m3e-circular-progress-indicator` | Thickness | no CEM enum attribute shares its value set (options: 4 dp, 8 dp) |
| `m3e-circular-progress-indicator` | Type | no CEM enum attribute shares its value set (options: Flat, Wave) |
| `m3e-dialog` | Icon | no CEM enum attribute shares its value set (options: True, False) |
| `m3e-fab` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed) |
| `m3e-fab-menu` | Color | no CEM enum attribute shares its value set (options: Primary container, Secondary container, Tertiary container) |
| `m3e-fab-menu` | Segments | no CEM enum attribute shares its value set (options: 3) |
| `m3e-filter-chip` | Configuration | no CEM enum attribute shares its value set (options: Label only, Label & leading icon) |
| `m3e-filter-chip` | Show trailing icon | no CEM enum attribute shares its value set (options: False, True) |
| `m3e-filter-chip` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed, Dragged, Disabled) |
| `m3e-icon-button` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed, Disabled) |
| `m3e-input-chip` | Configuration | no CEM enum attribute shares its value set (options: Label only, Label & leading icon, Label & avatar) |
| `m3e-input-chip` | Selected | no CEM enum attribute shares its value set (options: False, True) |
| `m3e-input-chip` | Show closing icon | no CEM enum attribute shares its value set (options: false, true) |
| `m3e-input-chip` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Dragged) |
| `m3e-linear-progress-indicator` | Progress | no CEM enum attribute shares its value set (options: 0, 10, 20, 50, 80, 100) |
| `m3e-linear-progress-indicator` | Thickness | no CEM enum attribute shares its value set (options: 4 dp, 8 dp) |
| `m3e-linear-progress-indicator` | Type | no CEM enum attribute shares its value set (options: Flat, Wave) |
| `m3e-list` | Multi-line | no CEM enum attribute shares its value set (options: False, True) |
| `m3e-list` | Type | no CEM enum attribute shares its value set (options: Standard, Segmented (filled), Expandable, Draggable, Swipable - standard, Swipable - segmented) |
| `m3e-list-item` | Alignment | no CEM enum attribute shares its value set (options: Middle-aligned, Top-aligned) |
| `m3e-list-item` | Selected | no CEM enum attribute shares its value set (options: False, True) |
| `m3e-list-item` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed, Dragged, Disabled) |
| `m3e-loading-indicator` | Show container | no CEM enum attribute shares its value set (options: False, True) |
| `m3e-loading-indicator` | Steps | no CEM enum attribute shares its value set (options: 1, 2, 3, 4, 5, 6, 7) |
| `m3e-menu` | Groups | no CEM enum attribute shares its value set (options: 1, 2, 3) |
| `m3e-menu-item` | Selected | no CEM enum attribute shares its value set (options: False, True) |
| `m3e-menu-item` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed, Disabled, Active) |
| `m3e-nav-item` | Show icon | no CEM enum attribute shares its value set (options: False, True) |
| `m3e-nav-item` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed) |
| `m3e-search-bar` | Show avatar | no CEM enum attribute shares its value set (options: False, True) |
| `m3e-search-bar` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Pressed) |
| `m3e-segmented-button` | Density | no CEM enum attribute shares its value set (options: 0, -1, -2, -3) |
| `m3e-segmented-button` | Segments | no CEM enum attribute shares its value set (options: 2, 3, 4, 5) |
| `m3e-slider` | Orientation | no CEM enum attribute shares its value set (options: Horizontal, Vertical) |
| `m3e-slider` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Pressed, Disabled) |
| `m3e-slider` | Value | no CEM enum attribute shares its value set (options: 0, 50, 100) |
| `m3e-snackbar` | # of lines | no CEM enum attribute shares its value set (options: One line, Two lines) |
| `m3e-snackbar` | Configuration | no CEM enum attribute shares its value set (options: Text only, Text & action, Text & longer action) |
| `m3e-snackbar` | Show close affordance | no CEM enum attribute shares its value set (options: False, True) |
| `m3e-split-button` | Leading state | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed, Disabled) |
| `m3e-split-button` | Trailing state | no CEM enum attribute shares its value set (options: Enabled, Focused, Hovered, Pressed, Disabled, Selected) |
| `m3e-suggestion-chip` | Selected | no CEM enum attribute shares its value set (options: False, True) |
| `m3e-suggestion-chip` | Show icon | no CEM enum attribute shares its value set (options: False, True) |
| `m3e-suggestion-chip` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed, Dragged, Disabled) |
| `m3e-switch` | Icon | no CEM enum attribute shares its value set (options: False, True) |
| `m3e-switch` | State | no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed, Disabled) |
| `m3e-tabs` | Configuration | no CEM enum attribute shares its value set (options: Fixed, Scrollable) |
| `m3e-tabs` | Layout | no CEM enum attribute shares its value set (options: Icon only, Label & icon, Label only) |
| `m3e-toolbar` | Configuration | no CEM enum attribute shares its value set (options: Floating, Docked) |
| `m3e-toolbar` | Orientation | no CEM enum attribute shares its value set (options: Horizontal, Vertical) |
| `m3e-tooltip` | Type | no CEM enum attribute shares its value set (options: Single line, Multi line) |
