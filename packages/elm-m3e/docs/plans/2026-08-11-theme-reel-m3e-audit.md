# Theme Reel + settings-drawer m3e-okf audit

- **Date:** 2026-08-11
- **Author:** Opus 4.8 (gauntlet worker, worktree `theme-reel-m3e-redesign`)
- **Source of truth:** the `m3e` skill (`@m3e/web` cards pinned `a284414`) + vendored `docs/vendor/tailwind-m3e-web/generated/{CSS_CUSTOM_PROPERTIES,utilities}.css` + Elm bindings in `src/M3e/`.
- **Scope:** replace ALL hand-rolled Tailwind chrome in `Theme.Reel` + the `Theme.elm` settings drawer with real `<m3e-*>` components; fix fonts-on-select + per-card-theme bugs. Preserve port/data plumbing.
- **Rule:** Tailwind is allowed ONLY for pure layout (flex / gap / spacing / scroll-snap / sizing). Every visual surface is an m3e component; every component-token override uses a **vendored `m3e-*` utility class** (literal, JIT-safe) rather than a hand-rolled `bg-*`/inline custom property.

---

## 0. Verified m3e facts that overturn the directive's assumptions

| Assumption in the brief | Verified reality (CEM ground truth) | Consequence |
| --- | --- | --- |
| "`m3e-card` with the **`interactive`** attribute" | `m3e-card` has **no `interactive` attribute**. The interactivity attribute is **`actionable`** (boolean). It also carries a native `href` (do NOT wrap in `<a>`), `variant` = `filled\|outlined\|elevated`, `orientation`, `disabled`. | Use `M3e.Card.actionable True`, never `interactive`. |
| "typeface token `--md-ref-typeface-brand`/`-plain` (or `--md-sys-typescale-*-font`)" | **Neither exists** in the vendored `@m3e/web` tokens. `typescale.css` ships only `-font-size` / `-font-weight` / `-line-height` / `-tracking` per role. There is **no font-FAMILY design token** anywhere in `@m3e/web`. m3e components inherit `font-family` from the CSS cascade. | The font fix is NOT "push a typeface token." It is "make the app's base `font-family` read a CSS var, and set that var." See §4. |
| "role strip should be m3e chips/avatars, `bg-primary` is wrong" | Correct. And the vendored `utilities.css` exposes `@utility m3e-avatar-color-*` → sets `--m3e-avatar-color` from a `--color-*` role token. | Paint blank avatars with `class "m3e-avatar-color-primary"` (literal, JIT-safe), inside a nested `<m3e-theme>` so the role resolves to that preset's palette. |

The `Theme.Fonts.elm` module doc-comment (lines 10–13) already *claims* fonts apply via `setCssOverride` of `--md-ref-typeface-brand/-plain` — that claim is **false / aspirational**; those tokens don't exist and no such call site was ever written. This is the font bug (§4).

---

## 1. Surface → m3e component mapping

### 1a. Reel card (`Theme/Reel.elm`) — replaces `<button>` + `<div bg-surface>` + `bg-*` role strip

| Hand-rolled today | m3e replacement | Attrs / slots / tokens (verified) | Elm binding |
| --- | --- | --- | --- |
| `<button aria-pressed … class="…rounded-2xl border bg-surface">` wrapping a nested theme | **`m3e-theme` › `m3e-card`** — theme OUTSIDE card so the card renders in its own palette. Card is the interactive element. | `M3e.Card.actionable True`; `M3e.Card.variant` (see selection state below); `M3e.Card.onClick (onPick preset)`. Card container color derives from `--md-sys-color-*` **inside** the card's shadow, which **inherits through the shadow boundary** from the nested `<m3e-theme>` (CSS custom properties pierce shadow DOM). | `M3e.card` / `M3e.Card.{actionable,variant,onClick}` ✅ |
| active-state `border-primary border-2` | **card `variant` swap**: inactive `outlined`, active `elevated` (drop-shadow lift = selection affordance) + an `m3e-icon name="check_circle" filled` in a corner. Pure m3e, no border chrome. | `M3e.Card.variant Value.elevated`/`Value.outlined`; `M3e.Icon.name "check_circle"`, `M3e.Icon.filled True`. | ✅ |
| card body `<div class="flex flex-col … bg-surface">` | **`M3e.Card.content` slot** (padded) holding a layout-only flex column. | `M3e.Card.content [ … ]`. | ✅ |
| name `<div style=font-family class="text-on-surface text-xs">` | **`m3e-heading` variant=title size=small** with inline `style "font-family"` = preset display stack. (`font-family` is a regular property — inline style is reliable; only *custom* properties are unreliable in this codebase's encoder.) | `M3e.heading [ M3e.Heading.variant Value.title, M3e.Heading.size Value.small, TA.style "font-family" displayStack ]`. | `M3e.heading` / `M3e.Heading.{variant,size,level}` ✅ |
| "Aa" specimen `<span>`×2 | **two `m3e-heading`s** side by side: `A` = variant=display size=small + display-font; `a` = variant=title + body-font. Layout-only flex row. | inline `style "font-family"` per glyph. | ✅ |
| role strip `<div class="bg-primary">`×4 | **4 blank `m3e-avatar`** painted by role token, inside the card's nested theme. | `M3e.avatar [ TA.class "m3e-avatar-color-primary m3e-avatar-size-… " ] []` — one each for `primary` / `secondary` / `tertiary` / `surface-container-highest`(→ closest utility). Sized/shaped via `m3e-avatar-*` utilities or layout classes. | `M3e.avatar` ✅ (no dedicated color setter — use the vendored `m3e-avatar-color-*` class) |

**Nesting mechanism:** `M3e.card` admits its slots; `M3e.theme` wraps the card. Placing an interactive `m3e-card` where the reel row expects a child, and nesting `m3e-theme › m3e-card`, both stay inside legit slot kinds — but the row/`div` container is layout Tailwind, so `M3e.Unsafe.recast` is still the escape hatch to drop a themed card into the layout `div`'s child list (same as today; `Theme.Reel` is allow-listed for `M3e.Unsafe` in `review/src/CodegenReviewConfig.elm`). Keep the allow-list entry.

### 1b. Drawer — `Theme.elm`

| Hand-rolled today | m3e replacement | Attrs / slots / tokens | Elm binding |
| --- | --- | --- | --- |
| `seedColorInput` = `m3e-form-field` + native `<input type=color>` (kept) | **First color avatar + picker icon** per directive: a blank `m3e-avatar` with an `m3e-icon name="colorize"` overlaid and a visually-hidden native `<input type=color>` on top (the OS picker — there is no m3e color-picker component). Click → `SetSeed`. | `M3e.avatar [ class "m3e-avatar-color-primary" ] [ M3e.icon [ M3e.Icon.name "colorize" ] [] ]` + overlaid `<input type=color>`; wrapped in `<m3e-theme color=model.seed>` so the swatch shows the current seed live. | ✅ (avatar + icon) |
| `swatchStrip` = 20 `<button style=background-color … class="rounded-full border-2">` | **Row of blank `m3e-avatar`**, one per curated color, each wrapped in `<m3e-theme color=hex>` and painted `m3e-avatar-color-primary` so the swatch = that theme's live primary. Click → `SetSeed hex`. Active = `m3e-avatar` size bump / `check` icon. | `M3e.theme [ M3e.Theme.color hex ] [ M3e.avatar [ class "m3e-avatar-color-primary" ] [] ]`. | ✅ |
| `presetGallery`/reel — already `Theme.Reel.view` | unchanged shape (redesigned card via §1a). | — | ✅ |
| Typography section font pickers (currently `Theme.Sections.Typography` — hand-rolled selects, see §1c) | **`m3e-select` › `m3e-option`** for display font and body font. | `M3e.select [ M3e.Select.onChange/onInput … ]` with one `M3e.option [ M3e.Option.value font, M3e.Option.selected (font==current) ] [ M3e.text font ]` per curated font. Read selection from the change event's `target.value`. | `M3e.select` / `M3e.option` ✅ |

### 1c. Font pickers — confirm current location

The display/body font pickers live in `Theme.Sections.Typography` (rendered into the drawer's `sectionsAccordion` via `Shared.settingsSheetContent`). Whichever module currently renders them, they must become `m3e-select`/`m3e-option`. (Confirm during impl; if they're plain `<select>`/segmented, swap to `m3e-select`.)

**Curated font list:** `Theme.Fonts` currently has NO font list (only URL builders). Add `curatedFonts : List String` (port the reference `src/lib/fonts.ts` set) OR derive the union of all preset display+body fonts. Deriving from presets is DRY and guarantees loadability; but the pickers want a broader palette, so port a curated list. Loading a picked font reuses `loadFontCmd`.

---

## 2. Elm bindings — inventory (exist ✅ / gap ⚠️)

| Component | Module | Constructor | Key setters present | Gaps |
| --- | --- | --- | --- | --- |
| Card | `M3e.Card` | `M3e.card` | `actionable`, `variant`(filled/outlined/elevated), `href`, `orientation`, `onClick`; slots `header/content/actions/footer` | none blocking |
| Avatar | `M3e.Avatar` | `M3e.avatar` | (global only) | **no color setter** → use vendored `m3e-avatar-color-*` utility class (not a gap in practice) |
| Heading | `M3e.Heading` | `M3e.heading` | `variant`(display/headline/title/label), `size`, `level`, `emphasized` | none |
| Chip / ChipSet / FilterChip | `M3e.Chip` / `M3e.ChipSet` / `M3e.FilterChip` | `M3e.chip` etc. | chip `variant`, `icon` slot; filterChip `selected` | `FilterChipSet` binding **missing** (not needed here) |
| Select / Option / Optgroup | `M3e.Select` / `M3e.Option` / `M3e.Optgroup` | `M3e.select` etc. | select `multi/name/required`, `onChange/onInput`; option `value/selected` | reading value is event-only (fine) |
| Icon | `M3e.Icon` | `M3e.icon` | `name`, `variant`, `filled`, `weight`, `grade`, `opticalSize` | none |
| Theme | `M3e.Theme` | `M3e.theme` | `color`, `scheme`, `contrast`, `density`, `motion`, `variant`, `strongFocus` | none |
| Unsafe | `M3e.Unsafe` | `recast` / `recastAll` | erases phantom rows to fit any slot | allow-listed for `Theme.Reel` ✅ |

**No blocking missing bindings.** The one nominal gap (avatar color setter) is covered by the vendored `m3e-avatar-color-*` utility, which is the *intended* m3e-okf mechanism. FilterChipSet is missing but unused.

---

## 3. Bug #2 — per-card themes not distinct (root cause + risk)

**Mechanism today:** `M3e.Unsafe.recast (M3e.theme [color,scheme,contrast] [ div bg-surface … ])` inside a `<button>`. The role strip uses `bg-primary` etc. = `var(--md-sys-color-primary)`. Because a nested `<m3e-theme>` re-derives `--md-sys-color-*` for its subtree and the div is plain light DOM inside it, each card's palette *should* already resolve distinctly.

**The real risk is introduced by the redesign, not present today:** does `m3e-card`'s **shadow DOM** block the nested theme's tokens? **No** — CSS custom properties inherit through shadow boundaries by spec; the card reads `--md-sys-color-*` inside its shadow and inherits the nested theme's values. **But this MUST be screenshot-verified**, because `index.ts._applyThemeInlineStyles` copies the *root* theme's `--md-sys-color-*` onto inline styles on `<html>` (specificity 1,0,0,0). Those live at `:root`; a nested `<m3e-theme>` redefines the same properties *closer* in the tree, and custom-property resolution is by tree proximity (nearest defining ancestor wins), not selector specificity — so the nested value should still win for the card subtree. **Verification gate:** baseline screenshot the current reel (are cards already distinct?) and re-screenshot after the m3e-card redesign (do card container + role avatars + heading fonts differ per card?). If the card's shadow surface does NOT pick up the nested palette, fall back to painting the card container via the vendored `m3e-{variant}-card-container-color-*` utility bound to a role token inside the nested theme.

---

## 4. Bug #1 — fonts don't change on select (root cause + fix)

**Root cause (three-part):**
1. `docs/style.css:251` hardcodes `body { font-family: Roboto, "Helvetica Neue", system-ui, …; }`. Nothing reads the model's `displayFont`/`bodyFont`.
2. `Theme.loadFontCmd` (Theme.elm:264) only calls `Theme.Ports.loadFonts url` → injects the Google-Fonts `<link>` (downloads the FILE) but **never sets any `font-family` or CSS var**. So e.g. Fraunces downloads and is never used.
3. There is **no font-FAMILY design token** in `@m3e/web` (verified §0); m3e components inherit `font-family` from the cascade. The `Theme.Fonts` doc-comment's `--md-ref-typeface-*` claim is false.

**Reference mechanism (authoritative for desired behavior)** — `2026.jackhpeterson.com`:
- `theme-editor.ts` sets `document.documentElement.style.setProperty("--theme-font-display", fontCss(displayFont))` and `"--theme-font-body"`.
- `global.css`: `body { font-family: var(--theme-font-body, …) }`, headings/`.display` `{ font-family: var(--theme-font-display, …) }`; also mapped into Tailwind `--font-sans`/`--font-display`.
- i.e. the site defines its OWN font vars + its OWN consuming CSS. No m3e magic.

**Fix (mirror the reference, elm-m3e-native):**
1. **`docs/style.css`** — make the base font read vars, and route headings to the display font:
   - `body { font-family: var(--app-font-body, Roboto, "Helvetica Neue", system-ui, -apple-system, sans-serif); }`
   - `m3e-heading, .doc-prose h1, .doc-prose h2, .doc-prose h3, .doc-prose h4 { font-family: var(--app-font-display, inherit); }` (m3e-heading host inherits into its shadow, which sets no family of its own — verified).
2. **`Theme.elm`** — `ApplyPreset`, `SetDisplayFont`, `SetBodyFont`, and `ThemeStateLoaded` push the two vars via the existing `setCssOverride` port:
   - `Theme.Ports.setCssOverride { property = "app-font-display", value = Theme.Fonts.fontStack displayFont }`
   - `Theme.Ports.setCssOverride { property = "app-font-body", value = Theme.Fonts.fontStack bodyFont }`
   - `setCssOverride` prepends `--`, so `property = "app-font-display"` writes `--app-font-display` onto `document.documentElement` — exactly the reference's mechanism. Add a `fontStack : String -> String` helper in `Theme.Fonts` (`"\"" ++ name ++ "\", system-ui, sans-serif"`).
3. **No index.ts change needed** — `--app-font-*` is not `--md-sys-color-*`, so the `_applyThemeInlineStyles` change-listener and `overriddenColorProperties` set ignore it (no clobber). `loadFonts` still loads the file; the new vars make it actually apply.

**Why this is correct and not a guess:** the reference does exactly this (`--theme-font-*` var + consuming CSS); we verified `@m3e/web` has no font-family token and inherits family from the cascade; `setCssOverride`→`documentElement.style.setProperty("--…")` is already the proven path for every other token in this app.

---

## 5. Reel per-card fonts (already partly working)

Each reel card sets its specimen `font-family` inline from the preset; `Shared.init`→`loadSpecimenFonts` injects the subset `<link>`s (§D6). This is retained in the redesign; the m3e-heading name/specimen carry the same inline `font-family`. Because these are inline `font-family` on real elements (regular property), they render per-card regardless of the global `--app-font-*` var.

---

## 6. Styling-mechanism cheatsheet (m3e-okf sanctioned)

- **Role-colored blank swatch:** `m3e-avatar` + `class "m3e-avatar-color-<role>"` inside a `<m3e-theme>` whose `color` sets the palette. Roles: `primary`, `secondary`, `tertiary`, and a surface role for the 4th strip cell.
- **Card surface in a preset theme:** just nest `m3e-theme › m3e-card`; the card's default container token derives automatically. Only if shadow-inheritance fails, force via `m3e-{variant}-card-container-color-<role>`.
- **Selection state:** card `variant` (outlined→elevated) + `m3e-icon name=check_circle filled`. No borders.
- **Typography:** `m3e-heading variant/size`; per-preset specimen font via inline `style "font-family"`.
- **Global font apply:** `--app-font-display` / `--app-font-body` custom props (via `setCssOverride`) + `body`/`m3e-heading` consumption in `style.css`.
- **Font pickers:** `m3e-select` › `m3e-option`, value read from the `change` event.
- **Layout-only Tailwind:** `flex`, `gap-*`, `overflow-x-auto`, `snap-*`, `shrink-0`, `w-*`, `p-*`, `-mx-*`. Nothing that paints a surface.

---

## 7. Open verification gates (must screenshot at 411×761)

1. Reel shows visibly distinct per-card palettes (avatars) AND per-card fonts (headings). (bug #2)
2. Picking a card changes the whole app's display + body fonts — before/after screenshot. (bug #1)
3. Drawer color options are avatars; source picker = first avatar + colorize icon; font pickers are `m3e-select`.
4. No `bg-primary`/hand-rolled `<button>`/`<div>` chrome remains in the theme UI (layout classes only).
5. `m3e-card` shadow surface picks up the nested theme (if not, apply the §3 fallback).
