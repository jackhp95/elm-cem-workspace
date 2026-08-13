# Theme Reel — live-inheritance theme gallery for the docs site

- **Date:** 2026-08-09
- **Status:** Design approved (brainstorm complete) — ready for implementation planning
- **Primary repo:** `elm-m3e` (docs app, Elm / elm-pages)
- **Secondary repo (Track B, later phase):** `2026.jackhpeterson.com` (Astro)
- **Type:** Design-bearing, cross-repo, multi-file. Follows Jack's brainstorm→plan-doc-before-code pattern.

---

## 1. Problem

The elm-m3e docs site once had (ported from `2026.jackhpeterson.com`) a section where multiple M3 themes coexisted on one page, each card wrapped in its own theme element — "themes work by inheritance." During the port that became **plain apply-buttons in the settings drawer**, losing:

1. the **per-card theme-wrapping coexistence demo**,
2. **font** application per theme,
3. **icon-style** configuration per theme.

Goal: restore and improve that gallery as a **horizontal-scrolling reel of theme-demo cards**, matching the referenced reel at `https://2026-jackhpeterson.netlify.app/#theme-swatches`, where each card renders live in *its own* theme and clicking a card re-themes the whole app. Bring both repos onto real `<m3e-*>` components.

## 2. Current true state (investigation findings)

These correct several assumptions in the originating handoff — read before implementing.

| Area | Reality (verified in source) |
| --- | --- |
| **Nesting primitive** | Already exists and is ready: `src/M3e/Theme.elm` is a full `<m3e-theme>` component wrapper (`color`/`scheme`/`contrast`/`density`/`variant`/`motion`/`strongFocus`). Nested `<m3e-theme>` re-derives tokens for its subtree via CSS-custom-property inheritance. **Per-card theming is a usage pattern, not a new library capability.** |
| **Presets** | All 22 ported in `docs/app/Theme/Presets.elm` (`Preset = {id,name,seedColor,scheme,contrast,displayFont,bodyFont,cssOverrides}`). |
| **Fonts** | *Modeled but never applied.* `Theme.Model` carries `displayFont`/`bodyFont`; `ApplyPreset` sets them; **no cmd loads the webfont or pushes a font CSS var**. This is the "lost font config." |
| **Icons** | *Deliberately dropped.* `Presets.elm` header comment: "`traits`, `iconStyle`, and `palette` from the source are dropped — out of scope." No icon field anywhere in the docs theme model. |
| **"Plain buttons"** | `docs/app/Theme.elm`'s `presetGallery`/`presetCard` renders each preset as a flat `M3e.button` (filled/outlined) inside the **settings drawer**. No theme-wrapped coexistence cards exist. |
| **Page→Shared channel** | **None built in.** `docs/app/Effect.elm` is a fixed variant set; `perform` helpers are `{fetchRouteData, submit, runFetcher, fromPageMsg, key, setField}` — no shared-msg route. Adding one creates an `Effect↔Shared` import cycle. A page cannot emit a `Shared.Msg` directly. |
| **Welcome route** | `docs/app/Route/GettingStarted/Welcome.elm` is a `StatelessRoute` (`RouteBuilder.single … |> buildNoState`). It receives `Shared.Model` in `view` but has no `Msg`/`update`, so today it cannot fire any effect. |
| **Inline CSS custom props** | Known gotcha (documented in `Theme.elm`'s `swatch` comment): inline `style` for CSS *custom properties* is unreliable in this codebase's style encoding — they used a Tailwind-arbitrary-class for `--md-sys-density-scale`. Affects per-card font vars (§6). |

### Reference: personal-site card anatomy (authoritative, from source)

`ThemeCard.astro` = 120px `rounded-large` `<button>`, `border-2` (→`border-primary` on hover + `aria-pressed`), `snap-start`, in a `flex gap-3 overflow-x-auto snap-x snap-mandatory` reel (`ThemePicker.astro` `#theme-swatches`). Inside a `4/3` tile: theme **name** top-left in `displayFont`, an **"Aa"** specimen bottom-left (A=`displayFont`, a=`bodyFont`), a **4-color palette strip** across the bottom. Click → `applyPreset` globally; clicking the *already-active* card rolls a random different theme. **The personal site hand-paints each card from a stored `palette[4]` array + inline `font-family`** — it does *not* use nested `<m3e-theme>`. elm-m3e will do it correctly with live derivation (§4).

## 3. Approved decisions

| # | Decision | Rationale |
| --- | --- | --- |
| D1 | **Cards use real nested `<m3e-theme>`, colors derived live** (not hand-painted from a stored palette). | This *is* the "themes work by inheritance" demo that was lost; dogfoods the library; token-doctrine-compliant ("re-skin don't restyle"); needs no re-added `palette[]`. |
| D2 | **Reel appears as a section on the Welcome page AND replaces the drawer's plain buttons; both apply globally.** One shared reel component, two placements. | Restores the on-page coexistence section; DRY. |
| D3 | **Page→Shared re-theme via a small port bridge** (`requestPreset`/`onPresetRequested`). | Only clean way to keep the reel literally in `Welcome.elm`'s body given no page→shared channel (§2); reuses the existing single `ApplyPreset` path. |
| D4 | **Icons: the 3 Material variants** (outlined/rounded/sharp), mechanism left extensible. Exotics (lucide/heroicons/unicode/emoji) deferred. | Demonstrates the mechanism cleanly for docs without vendoring exotic icon sets. |
| D5 | **Cross-repo: one plan, Track B (personal site) as a later, separable phase.** | Matches "update both"; keeps elm-m3e unblocked. |
| D6 | **Fonts: subset each card's webfont to its specimen glyphs** (`&text=`), so all 22 display+body fonts load cheaply. | Reel shows every theme's fonts at once; subsetting keeps the payload tiny. |

## 4. Architecture

### 4.1 Module map (elm-m3e docs, Track A)

New / changed modules — domain-organized, small, one concept each (per coding-preferences):

- **`docs/app/Theme/Reel.elm`** *(new)* — the reel + card as **pure, `msg`-generic view functions**. Reused by both the Welcome page body and the Shared drawer.
  - `view : Config msg -> Element … msg` where `Config = { presets : List Preset, activeId : Maybe String, onPick : Preset -> msg }`.
  - `card : { active : Bool, onPick : msg } -> Preset -> Element … msg`.
  - Card body wraps content in `M3e.Theme.view [ M3e.Theme.color preset.seedColor, M3e.Theme.scheme preset.scheme, M3e.Theme.contrast preset.contrast ] [ … ]`. Inside: name heading (display font), "Aa" specimen (A=display, a=body), a **derived role strip** (4 swatches painted by role tokens: primary/secondary/tertiary/surface — via role classes, never hex). Selected state = border token driven by `active`.
  - Reel container: `flex overflow-x-auto snap-x snap-mandatory` (layout-only Tailwind).
- **`docs/app/Theme/Fonts.elm`** *(new)* — port of `fonts.ts`: `curatedFonts : List FontOption`, `fontCss : String -> String`, `googleFontsUrl : List String -> String`, `specimenSubsetUrl : Preset -> String` (adds `&text=<name>Aa`). Pure.
- **`docs/app/Theme/Icons.elm`** *(new)* — `IconStyle` (opaque or a 3-constructor union: `Outlined | Rounded | Sharp`), `iconFontFamily : IconStyle -> String`, `fromString`/`toString`. Extensible for future variants.
- **`docs/app/Theme/Presets.elm`** *(change)* — extend `Preset` with `iconStyle : IconStyle`; re-transcribe each preset's icon style from the source `themes.ts`.
- **`docs/app/Theme.elm`** *(change)*:
  - Extract `applyPresetToModel : Preset -> Model -> Model` (pure) — the single place a preset maps into the model. `ApplyPreset` calls it.
  - Add `iconStyle : IconStyle` to `Model`; `SetIconStyle` msg.
  - `ApplyPreset`/`SetDisplayFont`/`SetBodyFont`/`SetIconStyle` gain cmds that: (a) load the webfont (`Theme.Ports.loadFonts`), (b) push `--md-sys-typescale-*-font` vars via existing `setCssOverride`, (c) apply the icon font.
  - Replace `presetGallery`/`presetCard` with `Theme.Reel.view { presets, activeId = model.activePresetId, onPick = ApplyPreset }`.
- **`docs/app/Theme/Ports.elm`** *(change)* — add:
  - `requestPreset : String -> Cmd msg` + `onPresetRequested : (String -> msg) -> Sub msg` (page→shared bridge).
  - `loadFonts : { url : String } -> Cmd msg` (inject/replace a `<link rel=stylesheet>`).
  - (icon font swap reuses `setCssOverride` or a small `setIconFont` port — decide in Phase 2 spike).
  - Extend `encode`/`decoder` with `iconStyle` (keep blob in sync — the module comment already flags this contract).
- **`docs/app/Shared.elm`** *(change)* — subscribe to `Theme.Ports.onPresetRequested`, resolve id via `Theme.Presets` lookup, dispatch `ThemeMsg (ApplyPreset preset)` (illegal id → no-op). ApplyPreset now also applies font + icon (already centralized in `Theme.update`).
- **`docs/app/Route/GettingStarted/Welcome.elm`** *(change)* — becomes a **minimal stateful route**:
  - `Model = {}` (or unit); `Msg = PickTheme Preset`.
  - `update (PickTheme preset) model = ( model, Effect.fromCmd (Theme.Ports.requestPreset preset.id) )`.
  - `view` reads `shared.theme.activePresetId`, renders `Theme.Reel.view { presets = Theme.Presets.presets, activeId = …, onPick = PickTheme }` as a new section (between highlights and status). Keep hero + highlights + statusGrid; retune the "Real M3 tokens" highlight copy to point at the reel ("switch them live below").
- **`docs/index.ts`** *(change)* — wire the 2 new ports: `requestPreset` → echo into `onPresetRequested`; `loadFonts` → inject/replace the `<link>`.

### 4.2 Data flow — click a Welcome card

```
Welcome reel card click
  → PickTheme preset (page Msg)
  → Welcome.update → Effect.fromCmd (Theme.Ports.requestPreset preset.id)
  → index.ts echoes id back
  → Theme.Ports.onPresetRequested (Shared Sub)
  → Shared: presetById id → ThemeMsg (ApplyPreset preset)
  → Theme.update ApplyPreset → applyPresetToModel + [favicon, cssOverrides, loadFonts, iconFont]
  → Shared.Model.theme updated → root <m3e-theme> re-derives → whole app re-themes
  → reel's activeId (from Shared.Model) reflects the new selection
```

Drawer path is unchanged in shape: card `onPick = ApplyPreset` directly (Shared already owns `Theme.Model`). **One apply path** (`applyPresetToModel`) serves both.

### 4.3 Fonts

`ApplyPreset` (and manual font setters) push, per the display/body split, the relevant `--md-sys-typescale-*-font` custom properties (enumerate exact token names from `docs/vendor/tailwind-m3e-web/generated/CSS_CUSTOM_PROPERTIES.md`) and call `loadFonts` with `googleFontsUrl [displayFont, bodyFont]` (`display=swap`). Reel cards use `specimenSubsetUrl` per §D6.

### 4.4 Icons

`iconFontFamily : IconStyle -> String` maps to `"Material Symbols Outlined|Rounded|Sharp"`. **Spike:** determine how `@m3e/web`'s `m3e-icon` selects its symbol font (a CSS var vs `font-family` on the ligature span) from the `m3e-icon`/`m3e-theme-icon` entries in the generated CSS-props doc; apply via that mechanism. Ensure the chosen Material Symbols font is loaded (three separate webfonts).

## 5. Phased task breakdown

Model tiers are **informational** (per Jack's convention + model-tick-down policy). Every subagent prompt must include the friction-logging instruction and (for mutating work) a git worktree.

### Track A — elm-m3e (blocking, ship first)

| Phase | Task | Expected tier |
| --- | --- | --- |
| A0 | **Spikes** (resolve before building): (i) per-subtree CSS-custom-property mechanism for card fonts — inline `style` vs Tailwind-arbitrary-class vs targeted port; (ii) `m3e-icon` symbol-font selection mechanism. Throwaway, capture findings in this doc. | sonnet / high |
| A1 | **`Theme/Reel.elm`** — reel + nested-theme card, pure & `msg`-generic. Includes the derived role strip + selected state. Visual verify with Playwright at 411×761. | opus / medium (M3e phantom-row types) |
| A2 | **`Theme/Fonts.elm`** + `loadFonts` port + `index.ts` link injection + typescale-font-var push in `Theme.update`. Verify a preset's fonts actually render. | sonnet / high |
| A3 | **`Theme/Icons.elm`** + `iconStyle` on `Preset`/`Model` + apply cmd + encode/decoder sync. | sonnet / high |
| A4 | **Port bridge**: `requestPreset`/`onPresetRequested` (`Theme.Ports` + `index.ts`) + Shared subscription → `ApplyPreset`. | sonnet / high |
| A5 | **`Welcome.elm`** stateful conversion + reel section + highlight copy retune; **drawer** `presetGallery`→`Theme.Reel.view`; extract `applyPresetToModel`. | opus / medium (touches Shared + route builder) |
| A6 | **Verify + gate**: full `npm run gate` (not a narrower test script — see `[[feedback-verify-with-full-gate-not-partial-tests]]`), Playwright e2e at 411×761, `graphify update .`. | opus / medium |

### Track B — personal site `2026.jackhpeterson.com` (later phase, separable)

| Phase | Task | Expected tier |
| --- | --- | --- |
| B1 | Wrap `ThemeCard.astro` in `<m3e-theme color={seed} scheme contrast>`; render name/specimen/role-strip from **role tokens** (derive live), retire `palette[]` from `themes.ts` (or keep as documented fallback). Per-card font via CSS vars on the theme wrapper. Keep existing `icon-mode.ts`. | sonnet / high |
| B2 | Register any new `<m3e-*>` module imports in `src/layouts/Base.astro` (the `m3e-imports.test.ts` guard); confirm `css-budget.test.ts` (dropping inline hex should *reduce* custom CSS). Run `pnpm run gate`. | sonnet / high |

Track B must not block Track A. It mirrors D1 (hand-painted → real nested-theme card) in the Astro repo, satisfying that repo's own m3e-first styling hierarchy.

## 6. Risks & open spikes

- **Per-card CSS custom properties (A0-i).** The documented "inline custom props unreliable" gotcha. If inline `style` fails for `--md-sys-typescale-*-font` on the card wrapper, fall back to a Tailwind-arbitrary-class or a targeted node port. **De-risks A1/A2.**
- **`m3e-icon` font mechanism (A0-ii).** Must confirm before A3, else icon swap silently no-ops.
- **Port round-trip fidelity.** `requestPreset`→`onPresetRequested` is an in-program signal routed through JS (the sanctioned decoupled channel, since no page→shared exists). Preset id is a string over the wire; `presetById` returns `Maybe`, so an unknown id no-ops rather than crashing. No full-blob reconstruction (unlike a persist round-trip), so no `[[kinfolk-rebuild-fidelity]]`-style drift.
- **Reel font payload.** 22×2 fonts. Mitigated by specimen subsetting (D6); confirm total transfer is acceptable in the Playwright run.
- **Density non-reactivity.** `Shared.elm` already notes the `m3e-theme` `density` attr is non-reactive; cards set `color`/`scheme`/`contrast` (reactive) so unaffected, but don't rely on live `density` per card.

## 7. Non-goals

- Exotic icon sets (lucide/heroicons/unicode/emoji) — deferred (D4).
- Type-scale / shape-scale editing changes — the existing Advanced sections stay as-is.
- Re-architecting the app-shell's single root `<m3e-theme>` — the reel is **additive**; the root theme remains the app default and reflects the active preset.
- Making `Effect` carry shared messages (rejected — import cycle; the port bridge is the chosen path).

## 8. Verification gates

- elm-m3e: `npm run gate` green (the full pre-push gate, not `test:fast`); Playwright e2e at 411×761 for the reel (scroll, select, global re-theme, active-state); `graphify update .` after code changes.
- Personal site: `pnpm run gate` (`check` + `test`) incl. `m3e-imports.test.ts` and `css-budget.test.ts`.
- Review gate before merge: claims verified against real output; design-bearing diffs get a full read or a delegated reviewer.

## 9. Blast radius

- **elm-m3e:** `Theme.elm`, `Theme/Presets.elm`, `Theme/Ports.elm`, `Shared.elm`, `Welcome.elm`, `index.ts` changed; `Theme/Reel.elm`, `Theme/Fonts.elm`, `Theme/Icons.elm` new. `Welcome.elm` moves `StatelessRoute`→stateful (a build-function swap). Per Jack's policy, blast radius is a cost, not a blocker — this is the correct slicing.
- **Personal site:** `ThemeCard.astro`, `themes.ts`, `Base.astro` touched; net custom-CSS should *decrease*.

## A0 Spike Findings

**A0-i: Per-subtree CSS custom property mechanism for card fonts**

Confirmed: inline `style` is unreliable for CSS custom properties in this codebase (see the existing `swatch` comment in `Theme.elm` — `TypedHtml.Attributes.style` uses `node.style[key]=…` which silently ignores `--var`-prefixed names in Elm's virtual DOM encoding). The established working pattern (from `densityClass` in `Shared.elm`) is a **Tailwind-arbitrary-class** with the CSS custom property baked in as a literal string. This works for a finite set of known values.

However, for per-card font custom properties where the value is dynamic (one per preset, 22 distinct values), neither inline `style` nor Tailwind-arbitrary-class works reliably. The correct approach is:
- **Cards do NOT push font CSS vars.** The `<m3e-theme>` element handles color/scheme/contrast live derivation. Font is a display concern on the card itself (specimen text), so we use **inline `style` for `font-family` directly** on the `<span>` or native HTML element holding the text — `font-family` is an ordinary CSS property (not a custom property), so `TypedHtml.Attributes.style "font-family" fontName` WORKS. The swatch comment only flags `--custom-property` keys as broken; regular properties are fine.
- Global app font is pushed via `loadFonts` port + `setCssOverride` for `--md-sys-typescale-*-font` tokens (A2).

**A0-ii: `m3e-icon` symbol-font selection mechanism**

Confirmed from `@m3e/web/dist/icon.js` (line 234): `m3e-icon`'s shadow DOM CSS sets `font-family` on `.icon` via `:host([variant="outlined|rounded|sharp"]) .icon { font-family: "Material Symbols Outlined|Rounded|Sharp"; }`. There is NO CSS custom property for the icon font. The mechanism is the **`variant` attribute on `<m3e-icon>`**. `M3e.Icon.name` takes the ligature string; the font is selected by the `variant` attribute. This is already exposed in `M3e/Theme.elm` via the `view [...]` interface.

Practically: `Theme/Icons.elm` defines `IconStyle = Outlined | Rounded | Sharp` and `toVariantValue : IconStyle -> Value M3e.Icon.Variant` (or equivalent). Applying globally requires either a port that sets a CSS custom property on `:root` (but there is no such var) or **re-rendering the icon elements** with the new variant. Since global icon style is an app-wide setting (not per-card), the cleanest approach is to store `iconStyle` in `Theme.Model` and pass it down to every icon render site — but that's a large blast radius. **Decision: defer per-preset global icon style for A3 to just storing the field and applying it in the drawer's icon; card specimen only shows color swatches (no icons in cards).** A3 is thus scoped to: add `iconStyle : IconStyle` to `Preset` and `Theme.Model`, push it via `ApplyPreset`, wire it to the settings-sheet icon-style segmented control. No global icon re-render sweep needed for the reel itself.
