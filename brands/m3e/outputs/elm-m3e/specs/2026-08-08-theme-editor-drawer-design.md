# Spec E — Settings-sheet theme editor: fix reactivity, port the full editor UX

Date: 2026-08-08
Repo: `elm-m3e`
Status: approved design, not yet planned
Related: `skills/theming-m3e-apps/SKILL.md`, `docs/tests-browser/settings-sheet.spec.ts`

## Problem

The `#settings-sheet` drawer (`docs/app/Shared.elm:815-970`) lets a visitor change
`scheme`, `seed` (source color), `contrast`, `density`, and `dir`. Two are broken or
incomplete today:

- **Contrast and source color changes produce no visible effect.** All four theme
  fields correctly become attributes on `<m3e-theme>` via `M3e.Theme.color` /
  `.scheme` / `.contrast` / `.density` (`src/M3e/Theme.elm:119-151`), which correctly
  emit `Ir.attribute` — so Elm's vdom *is* diffing and writing these attributes. The
  break is downstream: either the `@m3e/web` `<m3e-theme>` custom element isn't
  reacting to `contrast`/`color` attribute mutations post-mount, or Elm's vdom isn't
  re-patching the node for some other reason (e.g. a keying issue). This is
  **unconfirmed** — it was read, not reproduced, and must be reproduced live in
  `pnpm dev` before a fix is designed, because the two root causes take different
  fixes (one is an `@m3e/web` workaround, the other is an Elm rendering bug).

- **Only `scheme` persists.** `Ports.elm` defines exactly one port, `storeScheme`,
  wired at `Shared.elm:554-557`. `seed`, `contrast`, and `density` update the model
  (`Shared.elm:559-566`) with `Effect.none` — no persistence, so they silently reset
  on every reload. This reads as "broken" even where the live attribute *is* working.

Separately, Jack wants the drawer's *capability* to grow substantially, using two
reference UIs as the design target:

- `/themes/` on `2026.jackhpeterson.com` (local repo:
  `/Users/jack/Documents/code/2026.jackhpeterson.com`, source in
  `src/pages/themes.astro` + `src/lib/theme-editor.ts` + `src/lib/themes.ts`) — a
  preset-card gallery plus a 5-section accordion editor (Color / Typography / Shape /
  Appearance / Advanced), applying every change live with no reload, backed by
  localStorage. Notably, this reference **also** wraps `@m3e/web`'s `<m3e-theme>` and
  gets live reactivity out of it for contrast/scheme/color — which is why this spec
  treats elm-m3e's bug as likely Elm-side rather than an `@m3e/web` limitation.
- `beercss.com` (`#themes3`, click the palette icon) — a compact popover with a
  curated 2-row grid of ~20 round color swatches that instantly reskin the whole page
  on click. Jack wants this specific "fast curated swatch strip" interaction folded in
  as a secondary, quicker way to pick a seed color alongside the full preset gallery.

## Non-goals

- No dedicated `/theme-editor` route. The drawer stays a global overlay opened from
  wherever the visitor already is, so changes preview against whatever docs page is
  underneath (confirmed: this is what "so we can SEE specific pages as we make
  modifications" means).
- No `M3e.Logo`-style generalization — this is docs-app scoped, living in
  `docs/app/`, not `src/M3e/`.
- No "traits" (scanlines, CRT curvature, glitch transitions, etc.) — presets carry
  color, scheme, contrast, fonts, and CSS-variable overrides only. elm-m3e is a
  design-system docs site, not a personal blog; gimmick traits don't serve it.
- Motion (`Standard`/`Expressive`) is new scope pulled in from the Appearance
  section — not previously modeled anywhere in `Shared.elm`.

## Design

### Module split

New `docs/app/Theme.elm` owns the whole editor: model, `Msg`, `update`, and the
drawer's `view`. New `docs/app/Theme/Ports.elm` owns the JS boundary (see below).
`Shared.elm` embeds `Theme.Model` as one field and delegates `Theme.Msg` through its
own `Msg` wrapper, the same pattern already used for `SearchEntry`/search state. This
keeps `Shared.elm` from absorbing 5 accordion sections' worth of state and view code on
top of what's already there (tree/TOC/search).

### The CSS-custom-property constraint

`Shared.elm:1601`'s existing comment is load-bearing for this whole spec: *"Elm cannot
set a CSS custom property directly"* — which is why `density` already goes through a
precompiled Tailwind arbitrary-value class rather than an inline style. `TypedHtml`
deliberately has no raw `style` escape hatch. Consequence for this spec:

- Anything expressible as an **`Ir.attribute` on `<m3e-theme>`** (scheme, seed color,
  contrast, density, and the new `motion`) is set directly by Elm, same as today —
  no port needed once the reactivity bug is fixed.
- Anything that is a **raw CSS custom property write** — the 36 individual
  `--md-sys-color-*` role overrides, the 15 `--md-sys-typescale-*-font-size` tokens,
  the 9 `--md-sys-shape-corner-value-*` tokens, and the Advanced section's remaining
  motion-duration/state-layer-opacity tokens — goes through a port to JS, which calls
  `documentElement.style.setProperty(...)`, mirroring exactly what
  `theme-editor.ts:127-203` already does in the reference site. This is not a
  workaround; it is the same mechanism the reference implementation uses for the same
  reason (these values aren't expressible as component attributes).

### Ports (`docs/app/Theme/Ports.elm`)

Replaces the single `storeScheme` port with a small family:

- `storeThemeState : Json.Encode.Value -> Cmd msg` — one JSON blob covering every
  persisted field (scheme, seed, contrast, density, motion, font choices, type-scale
  config, shape-scale config, color-token overrides, css-var overrides), written to
  one namespaced localStorage key. (The reference site uses many individual keys;
  one JSON blob is simpler to keep in sync with the Elm model and is the only
  external consumer, so there's no cross-tool format constraint pushing toward many
  keys.)
- `readThemeState : (Json.Decode.Value -> msg) -> Sub msg` — on boot, JS reads
  localStorage and sends the stored blob back in; Elm decodes it to initialize
  `Theme.Model` (falling back to defaults on decode failure or absence).
- `setCssOverride : { property : String, value : String } -> Cmd msg` — one raw
  custom-property write, called per changed Advanced-section control or color-token
  override. Debounced in JS at ~16ms (one animation frame) if steppers prove chatty
  during testing; not assumed necessary up front.
- `setFaviconColor : String -> Cmd msg` — rewrites the favicon's fill to the live seed
  color; shared with Spec F (the logo epic). See that spec for the mechanism.

`index.ts` gains handlers for these four, replacing its current single `storeScheme`
subscriber.

### View structure

`Theme.view` renders, top to bottom, inside the existing `#settings-sheet-content`
container:

1. **Scheme segmented control** (Light / Auto / Dark) — unchanged from today's
   `schemeSegmented`, moved into `Theme.elm`.
2. **Preset gallery** — a card grid, each card an `Apply <name> theme` button. A
   preset is `{ name, seedColor, scheme, contrast, displayFont, bodyFont, cssOverrides
   }` — no traits, no icon-style override (unlike the reference site). Clicking a
   card replaces the model's editable fields wholesale and clears any per-token
   overrides, mirroring `themes.astro:544-572`'s `persist()` flow.
3. **Round-swatch quick-picker** — a compact strip of curated seed colors (visually
   modeled on beercss's popover), sitting alongside the existing native
   `<input type=color>` + hex readout (`seedColorInput`, `Shared.elm:930-950`,
   ported unchanged). Clicking a swatch only changes `seed`; it does not touch
   `scheme`/`contrast`/fonts, unlike a full preset card. This is the "fast tweak"
   path Jack asked for; the preset gallery is the "wholesale look" path.
4. **Editor accordion**, 5 sections, collapsed by default (matches reference site
   default state):
   - **Color** — per-role token override list (36 tokens, grouped: Primary,
     Secondary, Tertiary, Error, Surface, Outline, Inverse, Other), each a color
     swatch + picker + reset-to-generated button. Writes go through
     `setCssOverride`.
   - **Typography** — display/body font selects, then a scale-mode segmented control
     (Linear / Modular / Bump / Power) with the reference site's per-mode stepper
     sets (factor / ratio+base / bump-offset / exponent) and a live 15-token size
     preview. Computed sizes are pushed via `setCssOverride`, one call per token,
     same as `applyTypeScale` in the reference.
   - **Shape** — identical structure to Typography but for the 9 corner-radius
     tokens; static preview swatches (XS…Full), no live-updating boxes (matches
     reference; not asked to improve this).
   - **Appearance** — Contrast (Standard/Medium/High, `Ir.attribute`, existing
     `contrastSegmented` ported in), Motion (Standard/Expressive — **new**,
     `Ir.attribute` on `<m3e-theme motion="...">`), Density (existing
     `densitySegmented`, unchanged Tailwind-arbitrary-class mechanism).
   - **Advanced** — raw stepper controls for the remaining individual CSS custom
     properties not covered by the Typography/Shape scale modes (motion durations,
     state-layer opacities), each a direct `setCssOverride` call.
5. **Directionality segmented control** (existing `directionSegmented`, unchanged) —
   kept separate from the accordion since it's a document-level concern, not a
   theme-editing one.
6. **Reset all** button — clears `Theme.Model` back to defaults, clears all
   `cssOverrides`/`colorOverrides` (removing the properties, not just zeroing them),
   and re-persists.

### Persistence & boot sequence

On `init`, `Shared.elm` sends `Theme.Ports.readThemeState`'s subscription result (or,
if arriving too late for first paint, reads a flags-embedded snapshot the way `scheme`
already might — confirmed during implementation) into `Theme.init`. Every subsequent
edit calls `storeThemeState` with the full current state, matching the reference
site's un-debounced, no-reload-needed `persist()` pattern.

### Testing

- Extend `docs/tests-browser/settings-sheet.spec.ts` (currently open/close only) with
  assertions that changing contrast and seed color produce an observable style change
  on a real rendered page — e.g. read a computed CSS custom property or a swatch's
  rendered background color before/after, not just that the model updated. This is
  the test that would have caught the original bug and is the concrete "did we
  actually fix it" gate.
- A reload-persistence test: set contrast + seed, reload, assert both restored.
- A preset-then-override test: apply a preset, override one color token, assert the
  override survives a `scheme` toggle but not a "Reset all."
- Manual pass, per Jack's "test" step: visually walk every accordion section against
  at least two different docs pages (a component-heavy page and a text-heavy page) to
  catch anything a computed-style assertion wouldn't (e.g. font-loading flashes,
  layout shift from density changes).

## Verification

- Reproducing the original bug live in `pnpm dev` is the first implementation task,
  and its finding (Elm-side vs. `@m3e/web`-side) gates how the reactivity fix is
  written — this spec does not prescribe the fix mechanism because it isn't known yet.
- `contrastSegmented`/`seedColorInput` changes are visible without reload on a running
  docs page (browser-test-asserted, not just eyeballed).
- `seed`, `contrast`, `density`, `motion`, font choices, and all overrides survive a
  page reload.
- Preset cards apply all their bundled fields atomically and clear prior overrides.
- The round-swatch strip changes only seed color, leaving everything else untouched.
- Every Advanced-section control maps to exactly one CSS custom property and no
  control silently no-ops (each has been clicked at least once during manual test
  pass and produced a visible change).
- `docs/tests-browser/settings-sheet.spec.ts` green, including the new
  visible-change and persistence assertions.
