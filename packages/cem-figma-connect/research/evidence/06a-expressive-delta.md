# 06a — Is the "Material 3 Design Kit (Community)" baseline M3 or M3 Expressive? Delta vs @m3e/web

Date: 2026-07-10
Inputs:
- Figma dump: `/Users/jhp/code/avetta/akg-synapse/scripts/research/cache/figma-components.json` (5,770 nodes)
- Inventory: `/Users/jhp/code/avetta/akg-synapse/scripts/research/cache/m3-kit-component-inventory.md` (171 sets, 245 standalones)
- CEM: `/Users/jhp/code/jackhp95/elm-cem-m3e/node_modules/@m3e/web/dist/custom-elements.json` (123 tag declarations, **121 unique tags** — `m3e-menu-item` and `m3e-stepper-previous` are each declared twice)
- .d.ts enums: `/Users/jhp/code/jackhp95/elm-m3e/docs/node_modules/.pnpm/@m3e+web@2.5.14_@floating-ui+utils@0.2.11_lit@3.3.3_tslib@2.8.1/node_modules/@m3e/web/dist/src/` (note: actual pnpm dir is `@m3e+web@2.5.14_@floating-ui+utils@0.2.11_lit@3.3.3_tslib@2.8.1`, not the bare `@m3e+web@2.5.14` given in the task)

## VERDICT: the kit is M3 EXPRESSIVE, not baseline M3

Three independent lines of evidence:

1. **Button variant axes** include `Size` (XSmall–XLarge), `Type` (Round/Square shape), and `Width` — none of which exist in baseline M3 buttons (Style + State only).
2. **The kit's own `Button` set description** says it outright:
   > "Five size recommendations: extra small, small, medium, large, extra large / Two shape options: round and square"
3. **Expressive-era components are all present**: Button group, Split button, FAB menu, Loading indicator, Toolbar (plus XR variants, which only exist in the Expressive-era kit revisions).

---

## Task 1 — Button probe (Buttons page, 5,770-node dump)

Command:
```sh
jq -r '.[]|select(.page=="Buttons" and .type=="COMPONENT" and (.name|contains("=")))|.name' figma-components.json \
  | tr ',' '\n' | sed 's/^ *//' | awk -F= '{print $1" == "$2}' | sort | uniq -c | sort -rn
```

### Variant axes found on the Buttons page

| Axis | Values | Baseline M3? | Expressive? |
|---|---|---|---|
| `Type` | Round, Square (1,260 each) | no | **yes — shape axis** |
| `Size` | XSmall, Small, Medium, Large, XLarge (+legacy `Default`) | no (baseline has one size) | **yes — 5-size scale** |
| `Width` | Narrow, Default, Wide (600 each) | no | **yes — FAB/button-group width** |
| `Selected` | True/False | toggle buttons only | yes (toggle attr) |
| `State` | Enabled/Hovered/Focused/Pressed/Disabled (+10× typo `Presssed`) | yes | yes |
| `Color` | Filled/Tonal/Outlined/Elevated (+FAB Primary/Secondary/Tertiary[ container]) | yes (Style) | yes |
| `Configuration` | Label only / Label & icon / Icon only | yes | yes |
| `Segments`, `Density` | 2–5 / 0..-3 | segmented button (M3 baseline component) | kept |
| `Leading state`/`Trailing state` | Enabled/Hovered/… | — | split button halves |

Axis signatures (property-name combos) confirm the shape: the dominant button family is
`Type, Size, Width, Selected, State` (1,200 variants) and `Type, Size, Width, State` (600) —
i.e. shape x size x width x toggle x state. Baseline M3's `Style+State`-only signature is absent.

### @m3e/web counterpart (.d.ts)

| File | Values |
|---|---|
| `button/ButtonVariant.d.ts` | `"elevated" \| "filled" \| "tonal" \| "outlined" \| "text"` |
| `button/ButtonSize.d.ts` | `"extra-small" \| "small" \| "medium" \| "large" \| "extra-large"` |
| `button/ButtonShape.d.ts` | `"rounded" \| "square"` |

**Mapping:** kit `Size` XSmall..XLarge = m3e `size` extra-small..extra-large (exact 1:1);
kit `Type` Round/Square = m3e `shape` rounded/square (exact); kit `Color` = m3e `variant`
(kit's flat sets add "text" as `Button - text`). Kit `Width` has no m3e button attribute
(m3e handles width via CSS). `m3e-button` also carries `toggle`/`selected` = kit `Selected` axis.
Both sides are the same Expressive-generation button API.

## Task 2 — Expressive component rollcall (dump: set names + pages)

Command:
```sh
jq -r '.[]|select(.type=="COMPONENT_SET")|"\(.page)\t\(.name)"' figma-components.json \
  | grep -iE 'button group|split|fab menu|loading|toolbar|indicator' | sort -u
```

| Expressive component | In kit? | Evidence (page / set) |
|---|---|---|
| Button group | **PRESENT** | Buttons / `Standard button group`, `Connected button group` (+5 `Building Blocks/Button group/Connected segments/*` sets) |
| Split button | **PRESENT** | Buttons / `Split button` (Leading state/Trailing state axes) |
| FAB menu | **PRESENT** | Buttons / `FAB menu` (+6 `.Building Blocks/FAB Menu/*` sets) |
| Loading indicator | **PRESENT** | Loading & progress / `Loading indicator` (distinct from the 4 progress-indicator sets) |
| Toolbar | **PRESENT** | Toolbars page / `Toolbar` (+ Standard/Vibrant building blocks, `XR/XR Toolbar`) |

All five Expressive-era components are present. 5/5.

## Task 3 — Full component delta (name-level)

Kit universe: 171 COMPONENT_SETs = **97 top-level (public)** + **32 dot-prefixed `.Building Blocks/*` + `.Shape`** + **34 non-dot `Building Blocks/*`** + rest under `XR/*` (14 XR sets total, some counted in the above buckets) + misc nested (`Menu item/…`, `Primary tabs/…` count as top-level here).
Icons: **141 standalone COMPONENTs on the "Icons" page** (Material Symbols snake_case names: `wifi`, `alarm`, `do_not_disturb_on`, …) — counted separately, matched as a family to `m3e-icon`.
Dividers: 7 standalone COMPONENTs (no sets) on the Dividers page — matched to `m3e-divider`.

Commands:
```sh
jq -r '.[]|select(.type=="COMPONENT_SET")|"\(.page)\t\(.name)"' figma-components.json | sort -u > kit-sets.tsv
jq -r '.modules[].declarations[]?|select(.tagName!=null)|.tagName' custom-elements.json | sort -u > cem-unique.txt   # 121
comm -23 cem-unique.txt matched.txt > cem-only.txt   # 68
```

### (a) CEM elements WITH a plausible kit counterpart — 53 of 121

| m3e element | Kit counterpart (page / set) |
|---|---|
| m3e-app-bar | App bars / App bar |
| m3e-assist-chip | Chips / Assistive chip |
| m3e-avatar | Avatars / Generic avatar |
| m3e-badge | Badges / Badges |
| m3e-bottom-sheet | Sheets / Bottom sheet |
| m3e-button | Buttons / Button (+ - elevated/outline/text/tonal, Toggle button ×4 via `toggle` attr) |
| m3e-button-group | Buttons / Standard button group, Connected button group |
| m3e-button-segment | Buttons / Building Blocks/Button group/Connected segments/* (BB) |
| m3e-calendar | Date & time pickers / .Building Blocks/Local M3 calendar cell (BB, loose) |
| m3e-card | Cards / Horizontal card, Stacked card (+ .Building Blocks/Card states/*) |
| m3e-checkbox | Checkboxes / Checkboxes |
| m3e-chip, m3e-chip-set | Chips / Chip groups |
| m3e-circular-progress-indicator | Loading & progress / Circular-determinate + -indeterminate progress indicator |
| m3e-datepicker | Date & time pickers / Modal date picker, Input date picker, Docked input date picker |
| m3e-dialog | Dialogs / Basic dialog (+ List dialog, Scrollable list dialog as compositions) |
| m3e-divider | Dividers page (7 standalone components, Horizontal/Vertical) |
| m3e-expandable-list-item | Lists / List item - Accordion |
| m3e-fab | Buttons / FAB (+ Extended FAB via `extended` attr) |
| m3e-fab-menu | Buttons / FAB menu |
| m3e-filter-chip(-set) | Chips / Filter chip |
| m3e-form-field | Text fields / Text field (functional match; m3e has no `m3e-text-field` — native input wrapped in form-field) |
| m3e-icon | Icons page (141 Material Symbols components) |
| m3e-icon-button | Buttons / Icon button ×4 (+ togglable ×4 via `toggle` attr) |
| m3e-input-chip(-set) | Chips / Input chip |
| m3e-linear-progress-indicator | Loading & progress / Linear-determinate + -indeterminate progress indicator |
| m3e-list, m3e-list-item | Lists / List, List item (+ density variants) |
| m3e-loading-indicator | Loading & progress / Loading indicator |
| m3e-menu, m3e-menu-item | Menu / Menu, Menu (baseline), Menu item/Standard, Menu item/Vibrant |
| m3e-nav-bar | Navigation / Navigation Bar: Horizontal items, Vertical items |
| m3e-nav-item | Navigation / Building Blocks / Nav item (BB) |
| m3e-nav-rail | Navigation / Navigation Rail, Navigation Rail: Expanded |
| m3e-radio, m3e-radio-group | Radio button / Radio buttons |
| m3e-rich-tooltip | Tooltips / Rich Tooltip (standalone COMPONENT, not a set) |
| m3e-search-bar | Search / Search bar |
| m3e-search-view | Search / Search docked layout, Search full-screen layout (+ baselines) |
| m3e-segmented-button | Buttons / Segmented button (+ 3 BB segment sets) |
| m3e-shape | Shape / Shape Set (+ Styles / .Shape) |
| m3e-slider, m3e-slider-thumb | Sliders / Standard, Centered, Range slider (+ .BB Handle/tracks) |
| m3e-snackbar | Snackbar / Snackbar |
| m3e-split-button | Buttons / Split button |
| m3e-suggestion-chip | Chips / Suggestion chip |
| m3e-switch | Switch / Switch |
| m3e-tab, m3e-tabs | Tabs / Tabs, Primary tabs/*, Secondary tabs/* |
| m3e-toolbar | Toolbars / Toolbar |
| m3e-tooltip | Tooltips / Plain Tooltip |

### (b) CEM-only elements (no kit counterpart) — 68 of 121

Grouped (full flat list in `cem-only.txt`):

- **Real component gaps in the kit** (~20): `m3e-accordion`, `m3e-expansion-panel`/`-header`, `m3e-autocomplete`, `m3e-select`, `m3e-option`/`m3e-optgroup`/`m3e-option-panel`, `m3e-breadcrumb`(+item, +item-button), `m3e-paginator`, `m3e-stepper`(+step, +step-panel, +previous, +reset), `m3e-tree`(+item), `m3e-toc`(+item), `m3e-skeleton`, `m3e-nav-menu`(+item, +group), `m3e-selection-list`/`m3e-action-list`/`m3e-list-option`/`m3e-list-action`, `m3e-heading`, `m3e-slide`/`m3e-slide-group` (note: slide-group ~ kit Carousel, name-level miss)
- **Structural/behavioral helpers** (~25): `m3e-bottom-sheet-action`/`-trigger`, `m3e-dialog-action`/`-trigger`, `m3e-menu-trigger`, `m3e-menu-item-checkbox`/`-radio`/`-group`, `m3e-fab-menu-trigger`, `m3e-datepicker-toggle`, `m3e-nav-rail-toggle`, `m3e-drawer-container`/`m3e-drawer-toggle` (≈ kit Side Sheet, name-level miss), `m3e-collapsible`, `m3e-content-pane`, `m3e-split-pane`, `m3e-floating-panel`, `m3e-scroll-container`, `m3e-tab-panel`, `m3e-list-item-button`, `m3e-rich-tooltip-action`, `m3e-month-view`/`m3e-year-view`/`m3e-multi-year-view` (datepicker internals ≈ kit `.Building Blocks/Year` etc.)
- **Rendering/infra primitives** (~13): `m3e-ripple`, `m3e-state-layer`, `m3e-focus-ring`, `m3e-focus-trap`, `m3e-elevation`, `m3e-pseudo-checkbox`, `m3e-pseudo-radio`, `m3e-theme`, `m3e-theme-icon`, `m3e-text-highlight`, `m3e-text-overflow`, `m3e-textarea-autosize` — design-kit-invisible by nature

### (c) Kit sets with no CEM counterpart

True gaps (no m3e element exists at any name):

| Kit set (page) | Note |
|---|---|
| Carousel; Carousel - Full screen (Carousel) | closest m3e primitive: `m3e-slide-group`/`m3e-slide` (not a Carousel) |
| Dial picker; Keyboard picker (Date & time pickers) | **time pickers — @m3e/web has no time picker at all** |
| Side Sheet (Sheets) | functional analog `m3e-drawer-container`, no side-sheet element |
| Bottom app bar (App bars) | `m3e-app-bar` has no bottom variant element |
| List Item - Swipe (Lists) | no swipe-action element |
| Keyboard (Utilities) | on-screen keyboard mock; not a component-library concern |
| Examples/Layout grid (Examples) | doc artifact, not a component |
| XR/XR App Bar, XR/XR Toolbar, XR/Building Blocks/* (14 XR sets) | XR platform variants; web lib has none |

Name-level-only misses that are covered by m3e attributes/composition (not real gaps):
`Button - elevated/outline/text/tonal` + `Toggle button ×4` (= `variant`/`toggle` attrs), `Icon button ×8` (idem), `Extended FAB` (`extended` attr on `m3e-fab`), `Text field` (`m3e-form-field`), density/baseline variants of List/Menu, `Search … (baseline)` sets, `Navigation Bar/Rail` orientation variants, `Shape Set`/`.Shape`.

Building-block families (reported separately per instructions):
- **32 dot-prefixed** `.Building Blocks/*` (+`.Shape`, `.Tonal palettes` standalone): private internals — FAB Menu FAB/Segment, App bar content, Card states, date/time picker internals (Hour, hour-line, Period Selector, Local M3 calendar cell…), Progress indicator wave segments, Snackbar action/close, Slider tracks/handle. m3e's analogs are mostly internal shadow DOM, so no counterparts expected.
- **34 non-dot** `Building Blocks/*`: Button group Connected segments (= `m3e-button-segment`), Segmented button segments, Nav items (= `m3e-nav-item`), Menu list items, List leading/trailing/content, Sheets content, Toolbar Standard/Vibrant icon-buttons. About half have real m3e counterparts (`m3e-button-segment`, `m3e-nav-item`, `m3e-menu-item`, `m3e-list-item` slots).

## Task 4 — m3e-icon API (from CEM + IconElement.d.ts)

**Mechanism: `name` ATTRIBUTE (Material Symbols name), rendered via the Material Symbols variable font. NOT slotted ligature text — the element has NO slots.**

```html
<m3e-icon name="home"></m3e-icon>
<!-- requires the Material Symbols font, e.g.: -->
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0..1,0" rel="stylesheet"/>
```

- Description (CEM): "A small symbol used to easily identify an action or category." IconElement.d.ts elaborates: "makes it easier to use Material Symbols… The Material Symbols font is the easiest way to incorporate Material Symbols."
- Attributes: `name` (string, the Material Symbols icon name), `variant` (`"outlined" | "rounded" | "sharp"`, default outlined), `filled` (boolean), `weight` (100–700, default 400), `grade` (IconGrade, default "medium"), `optical-size` (20–48, default 24)
- Slots: **none** (`"slots": []` in CEM)
- Alternative path: `registerIcon(name, variant, {outlined, filled})` registers SVG data in an internal IconRegistry, so `name` can also resolve to a registered SVG instead of the font ligature.
- Neat alignment: the kit's Icons page components are named with the exact same snake_case Material Symbols names (`wifi`, `alarm`, `do_not_disturb_on`) that go in `m3e-icon[name]`.

**m3e-button icon slots** (CEM): default slot = label; `icon` = "Renders an icon before the button's label."; `trailing-icon` = after label; `selected` / `selected-icon` = toggled-state label/icon. So button icons are SLOTTED ELEMENTS (typically an `<m3e-icon name="…">`), not attributes.

## Data-quality notes
- Buttons page has a variant-value typo: `State=Presssed` (10 nodes).
- Kit set-name typos: `Accordion buttton`, `Xlarge` vs `XSmall` casing.
- CEM duplicate declarations: `m3e-menu-item`, `m3e-stepper-previous` (123 lines, 121 unique).

## Files
- `cem-unique.txt` (121 tags), `matched.txt` (53), `cem-only.txt` (68), `kit-sets.tsv` (171 sets) — all in this directory.
