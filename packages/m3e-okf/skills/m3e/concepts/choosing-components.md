# Choosing components — which m3e component when

Pick the right `<m3e-*>` element by intent. Each component links to its verified API card.

## Actions & buttons
<a id="actions"></a>

Elements users click to perform an action.

**Components:** [button](../components/button.md) · [icon-button](../components/icon-button.md) · [fab](../components/fab.md) · [fab-menu](../components/fab-menu.md) · [split-button](../components/split-button.md) · [button-group](../components/button-group.md) · [segmented-button](../components/segmented-button.md)

Use **button** for standard labeled actions. Drop to **icon-button** when space is tight and the icon is unambiguous. **fab** is the single most important screen action (one per screen); **fab-menu** expands a FAB into related actions. **split-button** pairs a default action with a dropdown of alternates. **button-group** visually unifies several related buttons; **segmented-button** is for picking among 2–5 mutually-exclusive options (closer to a control than an action — for on/off prefer **switch**, for many options prefer **select** or **chips**).

## Selection controls
<a id="selection-inputs"></a>

Form controls for choosing values.

**Components:** [checkbox](../components/checkbox.md) · [radio-group](../components/radio-group.md) · [switch](../components/switch.md) · [slider](../components/slider.md) · [chips](../components/chips.md)

**checkbox** = select zero-or-more from a list. **switch** = a single immediate on/off toggle (applies instantly, no Save). **slider** = a number within a range. **chips** = compact, often dynamic choices: filter-chips for multi-select filtering, input-chips for tokenized entry, suggestion/assist chips for prompts.

_One-of-many — the key fork:_ use **radio-group** when all options should stay **visible** at once and there are only a few (2–5); use **[select](../components/select.md)** (a closed dropdown menu) when the list is **long or should stay collapsed** until opened. Phrases like "closed list", "dropdown", or "pick from a menu" → select. "Choose one" with a handful of always-visible options → radio-group. For an inline horizontal one-of-many that reads as a control, **[segmented-button](../components/segmented-button.md)** is a third option.

## Text input & forms
<a id="text-inputs"></a>

Fields for entering and selecting text.

**Components:** [form-field](../components/form-field.md) · [select](../components/select.md) · [autocomplete](../components/autocomplete.md) · [search](../components/search.md) · [textarea-autosize](../components/textarea-autosize.md) · [option](../components/option.md)

Wrap text inputs in **form-field** for labels, supporting text, and validation styling. **select** = pick one value from a **closed dropdown menu** (the one-of-many control when options stay collapsed; compare with radio-group under Selection controls). **autocomplete** = a text field where the user types and filters live suggestions. **search** = a dedicated search bar/view pattern. **textarea-autosize** grows a multiline field with its content. **option** supplies the items inside select/autocomplete listboxes.

## Navigation
<a id="navigation"></a>

Moving between destinations and through content.

**Components:** [app-bar](../components/app-bar.md) · [toolbar](../components/toolbar.md) · [nav-bar](../components/nav-bar.md) · [nav-rail](../components/nav-rail.md) · [nav-menu](../components/nav-menu.md) · [drawer-container](../components/drawer-container.md) · [tabs](../components/tabs.md) · [breadcrumb](../components/breadcrumb.md) · [toc](../components/toc.md) · [paginator](../components/paginator.md) · [stepper](../components/stepper.md) · [slide-group](../components/slide-group.md)

Top-level destinations: **nav-bar** (bottom, compact/mobile), **nav-rail** (side, medium widths), **drawer-container** (expanded side drawer, large screens) — these are the responsive trio. **nav-menu** is a hierarchical nav tree. Within a page: **tabs** switch peer views; **breadcrumb** shows hierarchy depth; **toc** links to in-page sections; **stepper** walks an ordered multi-step flow; **paginator** moves through pages of data; **slide-group** is directional content paging. **app-bar** is the top header surface; **toolbar** holds contextual actions.

## Containers & surfaces
<a id="containers"></a>

Surfaces that group or reveal content.

**Components:** [card](../components/card.md) · [content-pane](../components/content-pane.md) · [dialog](../components/dialog.md) · [bottom-sheet](../components/bottom-sheet.md) · [split-pane](../components/split-pane.md) · [expansion-panel](../components/expansion-panel.md) · [divider](../components/divider.md) · [menu](../components/menu.md)

**card** groups related content/actions about one subject. **content-pane** is a plain shaped padded surface. For transient focus: **dialog** (modal prompt/decision, blocks the page), **bottom-sheet** (sheet from the bottom, mobile-friendly, supports detents), **menu** (a small contextual list of actions/commands anchored to a trigger). **expansion-panel** shows/hides sections in place. **split-pane** is a resizable two-pane layout. **divider** is a thin rule between items.

## Data & collections
<a id="data-display"></a>

Showing structured or hierarchical data.

**Components:** [list](../components/list.md) · [tree](../components/tree.md) · [calendar](../components/calendar.md) · [datepicker](../components/datepicker.md) · [date-input](../components/date-input.md) · [timepicker](../components/timepicker.md)

**list** renders rows of items (optionally selectable/expandable/actionable). **tree** renders nested hierarchy. **calendar** is an inline month/year date surface; **datepicker** is the text-field + popup calendar for forms; **date-input** is the segmented date/time text field (date-only, time-only, or combined) that a datepicker/timepicker wraps; **timepicker** is the field + dial/input popup for choosing a time of day.

## Feedback & status
<a id="feedback"></a>

Communicating status, progress, and messages.

**Components:** [badge](../components/badge.md) · [snackbar](../components/snackbar.md) · [tooltip](../components/tooltip.md) · [loading-indicator](../components/loading-indicator.md) · [progress-indicator](../components/progress-indicator.md) · [skeleton](../components/skeleton.md)

**snackbar** = brief, dismissible message about a completed action (global service). **tooltip** = on-hover/focus context for a control. **badge** = a small count/dot on an icon or item. For waiting: **progress-indicator** (linear/circular, determinate or indeterminate), **loading-indicator** (expressive attention-grabbing spinner), **skeleton** (placeholder surface while content loads).

## Content & media
<a id="content-media"></a>

Identity, iconography, and shape primitives.

**Components:** [avatar](../components/avatar.md) · [icon](../components/icon.md) · [heading](../components/heading.md) · [shape](../components/shape.md)

**icon** renders Material Symbols. **avatar** shows a person/entity image or initials. **heading** gives expressive, accessible Material type-scale headings. **shape** applies Material's abstract shape system to arbitrary content.

## System
<a id="system"></a>

Non-visual configuration elements.

**Components:** [theme](../components/theme.md)

**theme** is a non-visual element that applies dynamic color/theming tokens to its subtree. See the Color & theming concept page.

---
_Selection guidance synthesized from m3e component descriptions and Material Design 3 principles; component APIs are verified against the CEM (see each card)._
