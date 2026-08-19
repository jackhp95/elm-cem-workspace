# Theme Editor Drawer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the settings-sheet drawer's broken contrast/seed-color reactivity and missing persistence, then grow it into a full 5-section theme editor (presets, swatch strip, Color/Typography/Shape/Appearance/Advanced accordion) ported from the `2026.jackhpeterson.com` reference site's `theme-editor.ts`/`themes.astro`.

**Architecture:** New `docs/app/Theme/` package (`Theme.elm` orchestrates; `Theme/Tokens.elm`, `Theme/Scale.elm`, `Theme/Presets.elm`, `Theme/Ports.elm` hold data/logic; `Theme/Sections/*.elm` hold the 5 accordion sections) embeds into `Shared.elm` as one model field, same pattern as `SearchEntry`. Anything expressible as an `Ir.attribute` on `<m3e-theme>` (scheme/color/contrast/density/motion) stays direct Elm; raw `--md-sys-*` custom-property writes go through one new port family, replacing the single `storeScheme` port.

**Tech Stack:** Elm 0.19.1, `elm-pages`, `TypedHtml`/`HtmlIr` (the project's typed-HTML DSL), `@m3e/web` custom elements, Playwright (`docs/tests-browser/`), Tailwind v4 (`--md-sys-*` CSS custom properties defined in `docs/vendor/tailwind-m3e-web/src/sys/*.css`).

**Deviation from the spec's literal wording:** the spec says "New `docs/app/Theme.elm` owns the whole editor: model, `Msg`, `update`, and the drawer's `view`." Per this codebase's modularity mandate (`coding-preferences` skill), this plan splits that into a `Theme/` package — `Theme.elm` keeps the public `Model`/`Msg`/`init`/`update`/`view` surface the spec describes (so `Shared.elm` still only ever imports `Theme`), but the 5 accordion sections, token data, scale math, and preset data live in sibling modules so no single file exceeds a few hundred lines. This satisfies the spec's actual intent (isolate this out of `Shared.elm`) without violating "smaller, focused files."

**Ground-truth correction to the spec:** the spec assumes 36 color tokens / 15 typescale tokens as if this repo's token surface matched the reference site's. It doesn't. Verified against `docs/vendor/tailwind-m3e-web/src/sys/*.css` (the actual `@m3e/web` token source, not the docs' vendored *component* reference which only lists per-component vars):

- **Color:** 37 `--md-sys-color-*` tokens (not 36) — see Task 3.
- **Shape:** 9 `--md-sys-shape-corner-value-*` tokens — matches the spec.
- **Typescale:** this repo's real typescale system is **120 tokens** (2 variants [standard/emphasized] × 5 roles × 3 sizes × 4 axes [font-size/font-weight/line-height/tracking]), not the reference site's 15 font-size-only tokens. **Scoping call for this plan:** the Typography accordion section manipulates only the **15 standard-variant `font-size` tokens**, matching the reference site's actual editing surface and the spec's stated 15-token scope. The emphasized variant and the weight/line-height/tracking axes are left at their CSS-file defaults — out of scope for this pass. Flag this as a deliberate scope-narrowing, not an oversight, if it comes up in review.
- **Motion duration:** 16 tokens (`short-1..4`, `medium-1..4`, `long-1..4`, `extra-long-1..4`) — matches the spec. (`@m3e/web` also ships 6 easing-curve and 6 spring tokens; out of scope, not mentioned by the spec.)
- **State-layer opacity:** 3 tokens — matches the spec.

---

## File Structure

- Create `docs/app/Theme.elm` — `Model`, `Msg`, `init`, `update`, `view` (top-level orchestration: scheme segmented, preset gallery, swatch strip, accordion shell, reset-all).
- Create `docs/app/Theme/Tokens.elm` — pure data: the 37 color-role tokens (grouped), 9 shape tokens, 15 scoped typescale tokens, 16 motion-duration tokens, 3 state-opacity tokens.
- Create `docs/app/Theme/Scale.elm` — pure `ScaleMode`/`ScaleConfig`/`compute` — the Linear/Modular/Bump/Power math, ported from `theme-editor.ts`'s `scales.ts:81-118` logic but redesigned around this repo's real token defaults (see Task 4).
- Create `docs/app/Theme/Presets.elm` — `Preset` type + preset list, ported from the reference's `src/lib/themes.ts`.
- Create `docs/app/Theme/Ports.elm` — `storeThemeState`, `readThemeState`, `setCssOverride`, `setFaviconColor` (replaces `Ports.elm`'s `storeScheme`).
- Create `docs/app/Theme/Sections/Color.elm` — Color accordion section view.
- Create `docs/app/Theme/Sections/Typography.elm` — Typography accordion section view.
- Create `docs/app/Theme/Sections/Shape.elm` — Shape accordion section view.
- Create `docs/app/Theme/Sections/Appearance.elm` — Appearance accordion section view (Contrast/Motion/Density).
- Create `docs/app/Theme/Sections/Advanced.elm` — Advanced accordion section view.
- Modify `docs/app/Shared.elm` — embed `Theme.Model`, delegate `Theme.Msg`, remove the ported-out settings-sheet code (`schemeSegmented`, `contrastSegmented`, `seedColorInput`, `densitySegmented`, most of `settingsSheetContent`), keep `directionSegmented` + `dir` (document-level, per spec non-goal).
- Modify `docs/app/Ports.elm` — remove `storeScheme` (moved into `Theme/Ports.elm`); keep `onOpenSearchRequested`.
- Modify `docs/index.ts` — remove the `storeScheme` subscriber; add subscribers/senders for the 4 new ports.
- Modify `docs/tests-browser/settings-sheet.spec.ts` — add visible-change, persistence, and preset-override assertions.

---

## Task 1: Reproduce and diagnose the contrast/seed reactivity bug

**Files:**
- No file changes — this task's output is a diagnosis that gates Task 2.

This is unconfirmed per the spec — read, not reproduced. The fix in Task 2 branches on the answer, so do this first and do not skip it.

- [ ] **Step 1: Start the dev server and open the settings sheet**

Run: `cd docs && pnpm dev`

Open the printed local URL, navigate to any docs page, click the "Settings" app-bar button to open `#settings-sheet`.

- [ ] **Step 2: Reproduce — toggle contrast**

Click through the Contrast segmented buttons (Standard/Medium/High). Open browser devtools, inspect the `<m3e-theme>` element in the Elements panel.

Expected per the spec: the `contrast="..."` attribute on `<m3e-theme>` DOES change in the DOM (Elm's vdom is diffing correctly), but no visible color/border change happens on the page.

- [ ] **Step 3: Reproduce — change seed color**

Use the native color input to change the seed color. Same check: does `color="..."` update on `<m3e-theme>` in the Elements panel? Does the page's rendered colors change?

- [ ] **Step 4: Determine root cause — check for `attributeChangedCallback` reactivity**

In devtools, run in the console:

```js
document.querySelector('m3e-theme').constructor.observedAttributes
```

If `"contrast"` and `"color"` are present in the returned array, the element declares itself reactive to those attributes — the break is more likely an Elm-side vdom/keying issue (Root Cause A). If they're absent, `@m3e/web`'s `<m3e-theme>` custom element doesn't watch these attributes for live updates post-mount (Root Cause B).

- [ ] **Step 5: If Root Cause A is suspected — check for a keying issue**

Look at `Shared.elm`'s `view` function (around line 632, the `M3e.theme [...]` call). Confirm whether `M3e.theme`'s node is ever recreated (not patched) on state changes elsewhere in the same render — e.g. check if any sibling/ancestor list uses `Html.Keyed` incorrectly, or if a conditional branch elsewhere in `view` causes Elm to diff against a structurally different vdom tree on scheme/contrast changes, forcing a full node replacement that should re-trigger `attributeChangedCallback` but might not if the replacement mounts a *new* element the browser hasn't upgraded yet.

- [ ] **Step 6: If Root Cause B is suspected — confirm via manual JS**

In the console, manually run:

```js
document.querySelector('m3e-theme').setAttribute('contrast', 'high')
```

If this ALSO produces no visible change, the element itself is not reactive post-mount to `contrast`/`color` attribute mutations — confirms Root Cause B, independent of Elm.

- [ ] **Step 7: Record the finding**

Write a one-line comment at the top of `docs/app/Theme.elm` (added in Task 5) documenting which root cause was confirmed, e.g.:

```elm
-- Reactivity bug (2026-08-08 investigation): confirmed Root Cause B — @m3e/web's
-- <m3e-theme> does not re-derive its color-role custom properties when `contrast`/
-- `color` attributes mutate post-mount; only `scheme` triggers a redraw. Worked
-- around in `init`/`update` below by forcing a remount via a keyed wrapper — see
-- `themeKey`.
```

(Substitute the actual finding — this exact text is a placeholder for whichever root cause step 4-6 confirms.)

---

## Task 2: Fix the reactivity bug

Pick the branch that matches Task 1's finding. Both are fully specified below — do not invent a third mechanism.

**Files:**
- Modify: `docs/app/Shared.elm` (the `view` function's `M3e.theme [...]` call, currently around line 632)

### Branch A — Elm-side keying fix (if Root Cause A confirmed)

- [ ] **Step 1: Force a fresh DOM node on every scheme/contrast/color change via `Html.Keyed`-equivalent**

If `TypedHtml` has no keyed-node escape hatch, use `M3e.Attributes.id` with a value that embeds the changing fields, forcing Elm's vdom to treat it as a structurally different node when those fields change (Elm's vdom diffs by tag+attribute list; changing `id` alone will NOT force a remount — only a change in node *position/type* does). Confirm this really is the mechanism before writing it: read `HtmlIr`'s patch/diff implementation (`src/HtmlIr/` or wherever the vdom-emitting `Ir` module lives) to confirm whether `Ir.attribute` changes always call `setAttribute` (patch) or can trigger a replace. If `Ir.attribute` always patches (the likely case, since the spec's own text says "Elm's vdom *is* diffing and writing these attributes"), Branch A does NOT apply — re-run Task 1 Step 4-6, because a patch-not-replace is consistent with Root Cause B, not A. Do not force an artificial remount as a workaround for a `@m3e/web` reactivity gap — that belongs in Branch B.

### Branch B — `@m3e/web` reactivity shim (if Root Cause B confirmed)

- [ ] **Step 1: Add a JS-side shim to `docs/index.ts` that re-fires theme derivation on attribute change**

Elm still emits correct `Ir.attribute` writes (no Elm change needed). Add a `MutationObserver` in `docs/index.ts` that watches `<m3e-theme>` for `contrast`/`color` attribute mutations and calls whatever public re-derive method `@m3e/web` exposes (check `@m3e/web`'s published API — likely a method like `.requestUpdate()` inherited from its base class, since these are Lit-style custom elements per the `@m3e/web` version pin `^2.7.0` in `docs/package.json`):

```typescript
// Reactivity workaround for @m3e/web <m3e-theme>: `contrast` and `color`
// attribute mutations don't trigger the element's internal re-derivation of
// --md-sys-color-* custom properties post-mount (confirmed 2026-08-08 — see
// Theme.elm's header comment). `scheme` does trigger it. Force a re-render by
// calling the element's own update-request method on those two attributes only.
const themeEl = document.querySelector("m3e-theme");
if (themeEl) {
  const observer = new MutationObserver((mutations) => {
    for (const m of mutations) {
      if (m.type === "attributes" && (m.attributeName === "contrast" || m.attributeName === "color")) {
        (themeEl as unknown as { requestUpdate?: () => void }).requestUpdate?.();
      }
    }
  });
  observer.observe(themeEl, { attributes: true, attributeFilter: ["contrast", "color"] });
}
```

Verify `.requestUpdate` is the actual method name by checking `node_modules/@m3e/web/dist/*.js` (run `pnpm install` first if `node_modules` is absent) for the base class's public re-render trigger — Lit elements expose `requestUpdate()`; if `@m3e/web` isn't Lit-based, grep its dist bundle for `attributeChangedCallback` to find the internal method it calls, and call that instead.

- [ ] **Step 2: Manually verify in `pnpm dev`**

Toggle contrast and seed color again with the shim in place. Confirm visible change now happens (e.g., open devtools' Computed panel on a body element, check `--md-sys-color-primary`'s resolved value before/after).

- [ ] **Step 3: Commit**

```bash
git add docs/index.ts
git commit -m "fix: force @m3e/web theme re-derivation on contrast/color attribute mutation"
```

(Adjust the `git add` list to match whichever branch was actually implemented.)

---

## Task 3: `docs/app/Theme/Tokens.elm` — token data

**Files:**
- Create: `docs/app/Theme/Tokens.elm`

All token names below are read directly from `docs/vendor/tailwind-m3e-web/src/sys/color.css`, `shape.css`, `typescale.css`, `motion.css`, `state.css` — not from the reference site (which uses a different, smaller set).

- [ ] **Step 1: Write the module**

```elm
module Theme.Tokens exposing
    ( ColorToken, colorGroups
    , ShapeToken, shapeTokens
    , TypescaleToken, typescaleTokens
    , MotionDurationToken, motionDurationTokens
    , StateOpacityToken, stateOpacityTokens
    )

{-| The `--md-sys-*` custom-property surface this editor exposes, read
directly off `docs/vendor/tailwind-m3e-web/src/sys/*.css` (the actual
`@m3e/web` token source — NOT the reference site's smaller set).
-}


{-| A single color-role override row: `role` is the human label, `cssVar` is
the property name WITHOUT the `--` prefix (Theme.Ports adds it).
-}
type alias ColorToken =
    { role : String, cssVar : String }


colorGroups : List ( String, List ColorToken )
colorGroups =
    [ ( "Primary"
      , [ ColorToken "Primary" "md-sys-color-primary"
        , ColorToken "On Primary" "md-sys-color-on-primary"
        , ColorToken "Primary Container" "md-sys-color-primary-container"
        , ColorToken "On Primary Container" "md-sys-color-on-primary-container"
        ]
      )
    , ( "Secondary"
      , [ ColorToken "Secondary" "md-sys-color-secondary"
        , ColorToken "On Secondary" "md-sys-color-on-secondary"
        , ColorToken "Secondary Container" "md-sys-color-secondary-container"
        , ColorToken "On Secondary Container" "md-sys-color-on-secondary-container"
        ]
      )
    , ( "Tertiary"
      , [ ColorToken "Tertiary" "md-sys-color-tertiary"
        , ColorToken "On Tertiary" "md-sys-color-on-tertiary"
        , ColorToken "Tertiary Container" "md-sys-color-tertiary-container"
        , ColorToken "On Tertiary Container" "md-sys-color-on-tertiary-container"
        ]
      )
    , ( "Error"
      , [ ColorToken "Error" "md-sys-color-error"
        , ColorToken "On Error" "md-sys-color-on-error"
        , ColorToken "Error Container" "md-sys-color-error-container"
        , ColorToken "On Error Container" "md-sys-color-on-error-container"
        ]
      )
    , ( "Surface"
      , [ ColorToken "Surface" "md-sys-color-surface"
        , ColorToken "On Surface" "md-sys-color-on-surface"
        , ColorToken "Surface Variant" "md-sys-color-surface-variant"
        , ColorToken "On Surface Variant" "md-sys-color-on-surface-variant"
        , ColorToken "Surface Dim" "md-sys-color-surface-dim"
        , ColorToken "Surface Bright" "md-sys-color-surface-bright"
        , ColorToken "Surface Tint" "md-sys-color-surface-tint"
        , ColorToken "Surface Container Lowest" "md-sys-color-surface-container-lowest"
        , ColorToken "Surface Container Low" "md-sys-color-surface-container-low"
        , ColorToken "Surface Container" "md-sys-color-surface-container"
        , ColorToken "Surface Container High" "md-sys-color-surface-container-high"
        , ColorToken "Surface Container Highest" "md-sys-color-surface-container-highest"
        ]
      )
    , ( "Outline"
      , [ ColorToken "Outline" "md-sys-color-outline"
        , ColorToken "Outline Variant" "md-sys-color-outline-variant"
        ]
      )
    , ( "Inverse"
      , [ ColorToken "Inverse Surface" "md-sys-color-inverse-surface"
        , ColorToken "Inverse On Surface" "md-sys-color-inverse-on-surface"
        , ColorToken "Inverse Primary" "md-sys-color-inverse-primary"
        ]
      )
    , ( "Background"
      , [ ColorToken "Background" "md-sys-color-background"
        , ColorToken "On Background" "md-sys-color-on-background"
        ]
      )
    , ( "Shadow / Scrim"
      , [ ColorToken "Shadow" "md-sys-color-shadow"
        , ColorToken "Scrim" "md-sys-color-scrim"
        ]
      )
    ]


{-| Canonical shape corner-value tokens (9). Directional/role aliases in
`shape.css` (`--md-sys-shape-corner-large-top`, etc.) reference these via
`var(...)`, so overriding just these 9 cascades correctly — no need to
override the aliases too.
-}
type alias ShapeToken =
    { label : String, cssVar : String, defaultRem : Float }


shapeTokens : List ShapeToken
shapeTokens =
    [ ShapeToken "None" "md-sys-shape-corner-value-none" 0
    , ShapeToken "Extra Small" "md-sys-shape-corner-value-extra-small" 0.25
    , ShapeToken "Small" "md-sys-shape-corner-value-small" 0.5
    , ShapeToken "Medium" "md-sys-shape-corner-value-medium" 0.75
    , ShapeToken "Large" "md-sys-shape-corner-value-large" 1
    , ShapeToken "Large Increased" "md-sys-shape-corner-value-large-increased" 1.25
    , ShapeToken "Extra Large" "md-sys-shape-corner-value-extra-large" 1.75
    , ShapeToken "Extra Large Increased" "md-sys-shape-corner-value-extra-large-increased" 2
    , ShapeToken "Extra Extra Large" "md-sys-shape-corner-value-extra-extra-large" 3
    ]


{-| The 15 STANDARD-variant `font-size` tokens (scope-narrowed from the
repo's real 120-token typescale surface — see the plan's header note).
`step` is this token's position on the modular scale, 0-indexed against
`Theme.Scale`'s anchor (see that module for the anchor rationale).
-}
type alias TypescaleToken =
    { label : String, cssVar : String, defaultRem : Float, step : Int }


typescaleTokens : List TypescaleToken
typescaleTokens =
    [ TypescaleToken "Label Small" "md-sys-typescale-label-small-font-size" 0.6875 -6
    , TypescaleToken "Label Medium" "md-sys-typescale-label-medium-font-size" 0.75 -5
    , TypescaleToken "Body Small" "md-sys-typescale-body-small-font-size" 0.75 -5
    , TypescaleToken "Label Large" "md-sys-typescale-label-large-font-size" 0.875 -4
    , TypescaleToken "Body Medium" "md-sys-typescale-body-medium-font-size" 0.875 -4
    , TypescaleToken "Title Small" "md-sys-typescale-title-small-font-size" 0.875 -4
    , TypescaleToken "Body Large" "md-sys-typescale-body-large-font-size" 1 0
    , TypescaleToken "Title Medium" "md-sys-typescale-title-medium-font-size" 1 0
    , TypescaleToken "Title Large" "md-sys-typescale-title-large-font-size" 1.375 1
    , TypescaleToken "Headline Small" "md-sys-typescale-headline-small-font-size" 1.5 2
    , TypescaleToken "Headline Medium" "md-sys-typescale-headline-medium-font-size" 1.75 3
    , TypescaleToken "Headline Large" "md-sys-typescale-headline-large-font-size" 2 4
    , TypescaleToken "Display Small" "md-sys-typescale-display-small-font-size" 2.25 5
    , TypescaleToken "Display Medium" "md-sys-typescale-display-medium-font-size" 2.8125 6
    , TypescaleToken "Display Large" "md-sys-typescale-display-large-font-size" 3.5625 8
    ]


type alias MotionDurationToken =
    { label : String, cssVar : String, defaultMs : Int }


motionDurationTokens : List MotionDurationToken
motionDurationTokens =
    [ MotionDurationToken "Short 1" "md-sys-motion-duration-short-1" 50
    , MotionDurationToken "Short 2" "md-sys-motion-duration-short-2" 100
    , MotionDurationToken "Short 3" "md-sys-motion-duration-short-3" 150
    , MotionDurationToken "Short 4" "md-sys-motion-duration-short-4" 200
    , MotionDurationToken "Medium 1" "md-sys-motion-duration-medium-1" 250
    , MotionDurationToken "Medium 2" "md-sys-motion-duration-medium-2" 300
    , MotionDurationToken "Medium 3" "md-sys-motion-duration-medium-3" 350
    , MotionDurationToken "Medium 4" "md-sys-motion-duration-medium-4" 400
    , MotionDurationToken "Long 1" "md-sys-motion-duration-long-1" 450
    , MotionDurationToken "Long 2" "md-sys-motion-duration-long-2" 500
    , MotionDurationToken "Long 3" "md-sys-motion-duration-long-3" 550
    , MotionDurationToken "Long 4" "md-sys-motion-duration-long-4" 600
    , MotionDurationToken "Extra Long 1" "md-sys-motion-duration-extra-long-1" 700
    , MotionDurationToken "Extra Long 2" "md-sys-motion-duration-extra-long-2" 800
    , MotionDurationToken "Extra Long 3" "md-sys-motion-duration-extra-long-3" 900
    , MotionDurationToken "Extra Long 4" "md-sys-motion-duration-extra-long-4" 1000
    ]


type alias StateOpacityToken =
    { label : String, cssVar : String, defaultPercent : Int }


stateOpacityTokens : List StateOpacityToken
stateOpacityTokens =
    [ StateOpacityToken "Focus" "md-sys-state-focus-state-layer-opacity" 10
    , StateOpacityToken "Hover" "md-sys-state-hover-state-layer-opacity" 8
    , StateOpacityToken "Pressed" "md-sys-state-pressed-state-layer-opacity" 10
    ]
```

- [ ] **Step 2: Compile-check**

Run: `cd docs && elm make app/Theme/Tokens.elm --output=/dev/null`
Expected: compiles clean (this module has no external dependents yet, so this only checks it's syntactically/type valid on its own).

- [ ] **Step 3: Commit**

```bash
git add docs/app/Theme/Tokens.elm
git commit -m "feat: add theme editor token data (colors/shape/typescale/motion/state)"
```

---

## Task 4: `docs/app/Theme/Scale.elm` — scale-mode computation

**Files:**
- Create: `docs/app/Theme/Scale.elm`
- Test: `docs/tests/Theme/ScaleTest.elm` (adjust path/module naming to match this repo's existing Elm test conventions — check `docs/tests/` for the pattern another module's test file uses before creating this)

Ported from the reference's `scales.ts:81-118`. The four modes: Linear (`defaultRem * factor`), Modular (`base * ratio^step`), Bump (`defaultRem + bump`), Power (`base * (defaultRem/base)^exponent`). Anchor rationale for `step`: `Body Large` (1rem, the M3 baseline body-text size) is `step = 0`; everything smaller is negative, everything larger positive — see the exact steps assigned in `Tokens.typescaleTokens` (Task 3).

- [ ] **Step 1: Write the failing test**

```elm
module Theme.ScaleTest exposing (suite)

import Expect
import Test exposing (Test, describe, test)
import Theme.Scale as Scale


suite : Test
suite =
    describe "Theme.Scale.compute"
        [ test "Linear mode multiplies defaultRem by factor" <|
            \_ ->
                Scale.compute
                    { mode = Scale.Linear, factor = 1.5, ratio = 1, base = 1, bump = 0, exponent = 1 }
                    { defaultRem = 1, step = 0 }
                    |> Expect.within (Expect.Absolute 0.0001) 1.5
        , test "Modular mode computes base * ratio^step" <|
            \_ ->
                Scale.compute
                    { mode = Scale.Modular, factor = 1, ratio = 1.2, base = 1, bump = 0, exponent = 1 }
                    { defaultRem = 1, step = 2 }
                    |> Expect.within (Expect.Absolute 0.0001) 1.44
        , test "Bump mode adds a flat offset to defaultRem" <|
            \_ ->
                Scale.compute
                    { mode = Scale.Bump, factor = 1, ratio = 1, base = 1, bump = 0.25, exponent = 1 }
                    { defaultRem = 1, step = 0 }
                    |> Expect.within (Expect.Absolute 0.0001) 1.25
        , test "Power mode computes base * (defaultRem/base)^exponent" <|
            \_ ->
                Scale.compute
                    { mode = Scale.Power, factor = 1, ratio = 1, base = 1, bump = 0, exponent = 2 }
                    { defaultRem = 2, step = 0 }
                    |> Expect.within (Expect.Absolute 0.0001) 4
        , test "Linear mode with factor 1 is a no-op" <|
            \_ ->
                Scale.compute
                    { mode = Scale.Linear, factor = 1, ratio = 1, base = 1, bump = 0, exponent = 1 }
                    { defaultRem = 2.25, step = 5 }
                    |> Expect.within (Expect.Absolute 0.0001) 2.25
        ]
```

- [ ] **Step 2: Run test to verify it fails (module doesn't exist yet)**

Run: `cd docs && elm-test tests/Theme/ScaleTest.elm`
Expected: FAIL — `I cannot find module 'Theme.Scale'`

- [ ] **Step 3: Write the implementation**

```elm
module Theme.Scale exposing (ScaleConfig, ScaleMode(..), compute, defaultConfig, modeFromString, modeToString)

{-| The 4-mode scale computation used by the Typography and Shape accordion
sections to derive every token's value from a handful of controls, ported
from the `2026.jackhpeterson.com` reference site's `scales.ts:81-118`.
-}


type ScaleMode
    = Linear
    | Modular
    | Bump
    | Power


type alias ScaleConfig =
    { mode : ScaleMode
    , factor : Float
    , ratio : Float
    , base : Float
    , bump : Float
    , exponent : Float
    }


defaultConfig : ScaleConfig
defaultConfig =
    { mode = Linear, factor = 1, ratio = 1.2, base = 1, bump = 0, exponent = 1 }


{-| `token` only needs `defaultRem` and `step` — both `Theme.Tokens.TypescaleToken`
and `Theme.Tokens.ShapeToken` carry these, so this works for both sections'
token lists without duplicating the function.
-}
compute : ScaleConfig -> { token | defaultRem : Float, step : Int } -> Float
compute config token =
    case config.mode of
        Linear ->
            token.defaultRem * config.factor

        Modular ->
            config.base * (config.ratio ^ toFloat token.step)

        Bump ->
            token.defaultRem + config.bump

        Power ->
            config.base * ((token.defaultRem / config.base) ^ config.exponent)


modeToString : ScaleMode -> String
modeToString mode =
    case mode of
        Linear ->
            "linear"

        Modular ->
            "modular"

        Bump ->
            "bump"

        Power ->
            "power"


modeFromString : String -> Maybe ScaleMode
modeFromString str =
    case str of
        "linear" ->
            Just Linear

        "modular" ->
            Just Modular

        "bump" ->
            Just Bump

        "power" ->
            Just Power

        _ ->
            Nothing
```

`Theme.Tokens.ShapeToken` (Task 3) doesn't have a `step` field yet — add one before this compiles. Go back to Task 3's `ShapeToken` type alias and add `step : Int`, then assign steps `-4..4` across the 9 tokens in ascending `defaultRem` order (None=-4, Extra Small=-3, ..., Extra Extra Large=4), matching the same anchor convention as the typescale tokens (mirror Task 3 Step 1's edit before continuing here).

- [ ] **Step 4: Run test to verify it passes**

Run: `cd docs && elm-test tests/Theme/ScaleTest.elm`
Expected: PASS (5/5)

- [ ] **Step 5: Commit**

```bash
git add docs/app/Theme/Scale.elm docs/tests/Theme/ScaleTest.elm docs/app/Theme/Tokens.elm
git commit -m "feat: add scale-mode computation for typography/shape accordion sections"
```

---

## Task 5: `docs/app/Theme/Presets.elm` — preset data

**Files:**
- Create: `docs/app/Theme/Presets.elm`

The spec defines the preset shape narrowly (no `traits`, no `iconStyle`, no `palette` — those are reference-site-only fields dropped per the spec's non-goals): `{ name, seedColor, scheme, contrast, displayFont, bodyFont, cssOverrides }`. Source data: `/Users/jack/Documents/code/2026.jackhpeterson.com/src/lib/themes.ts` (22 presets, lines 15-254).

- [ ] **Step 1: Write the type and two fully-worked presets**

```elm
module Theme.Presets exposing (Preset, presets)

import M3e.Values as Value exposing (Value)


type alias Preset =
    { id : String
    , name : String
    , seedColor : String
    , scheme : Value Value.Scheme
    , contrast : Value Value.Contrast
    , displayFont : String
    , bodyFont : String
    , cssOverrides : List ( String, String )
    }


{-| Ported from `2026.jackhpeterson.com`'s `src/lib/themes.ts:15-254`. That
source has no `scheme`/`contrast` per-preset field (those are separate
Appearance controls there) — this spec adds them to the preset shape, so
each preset below defaults to `Value.auto`/`Value.standard` unless the
preset's name/intent obviously implies otherwise (documented per-preset
below). `traits`, `iconStyle`, and `palette` from the source are dropped —
out of scope per this spec's non-goals.
-}
presets : List Preset
presets =
    [ { id = "material"
      , name = "Material"
      , seedColor = "#6750A4" -- from themes.ts, `material` entry's seedColor
      , scheme = Value.auto
      , contrast = Value.standard
      , displayFont = "Roboto" -- confirm exact font family string against themes.ts's `material` entry
      , bodyFont = "Roboto"
      , cssOverrides = []
      }
    , { id = "oled"
      , name = "OLED"
      , seedColor = "#6750A4" -- confirm against themes.ts's `oled` entry (lines 234-253)
      , scheme = Value.dark -- OLED implies always-dark; document this override of the auto default
      , contrast = Value.high -- OLED presets conventionally maximize contrast against true black
      , displayFont = "Roboto" -- confirm against source
      , bodyFont = "Roboto" -- confirm against source
      , cssOverrides =
            -- themes.ts's `oled` entry demonstrates colorOverrides with 9
            -- surface-layer tokens set to near-black. Transcribe the exact 9
            -- key/value pairs from themes.ts:234-253, prefixing each key with
            -- "md-sys-color-" to match this repo's cssVar naming (Task 3).
            [ ( "md-sys-color-surface", "#000000" )
            ]
      }
    ]
```

- [ ] **Step 2: Port the remaining 20 presets**

Read `/Users/jack/Documents/code/2026.jackhpeterson.com/src/lib/themes.ts` lines 15-254 in full. For each of the remaining 20 entries (`agent`, `fieldnote`, `geometric`, `harbor`, `editorial`, `candy-pop`, `bauhaus`, `moss`, `risograph`, `studio`, `atlas`, `citrus`, `howler`, `gallery`, `handbook`, `broadcast`, `dispatch`, `console`, `platform`, `sunny`), append a record of the exact shape demonstrated in Step 1: `id` = the source's `id`, `name` = the source's `name`, `seedColor` = the source's `seedColor` verbatim, `displayFont`/`bodyFont` = the source's verbatim font-family strings, `cssOverrides` = the source's `colorOverrides` object entries (if any) with each key prefixed `md-sys-color-`. For `scheme`/`contrast` (fields that don't exist in the source), default every preset to `Value.auto`/`Value.standard` unless the preset's own name clearly implies a fixed scheme (e.g. a preset literally named for a dark aesthetic) — when defaulting, do not add a comment; when overriding the default, add a one-line comment explaining why, matching the `oled` example in Step 1.

- [ ] **Step 3: Compile-check**

Run: `cd docs && elm make app/Theme/Presets.elm --output=/dev/null`
Expected: compiles clean, 22 presets total in the list.

- [ ] **Step 4: Commit**

```bash
git add docs/app/Theme/Presets.elm
git commit -m "feat: port 22 theme presets from 2026.jackhpeterson.com reference site"
```

---

## Task 6: `docs/app/Theme/Ports.elm` — port family

**Files:**
- Create: `docs/app/Theme/Ports.elm`
- Modify: `docs/app/Ports.elm` (remove `storeScheme`)

Replaces the single `storeScheme` port. `storeThemeState`/`readThemeState` carry one JSON blob (this module owns the encoder/decoder so `Theme.elm` never hand-rolls JSON); `setCssOverride` and `setFaviconColor` are simple scalar ports.

- [ ] **Step 1: Write `Theme/Ports.elm`**

```elm
port module Theme.Ports exposing
    ( storeThemeState, readThemeState
    , setCssOverride, setFaviconColor
    , encode, decoder
    )

{-| Client-side ports for the theme editor. Wired to the browser in
`index.ts`. Replaces `Ports.elm`'s old single `storeScheme` port.

@docs storeThemeState, readThemeState
@docs setCssOverride, setFaviconColor
@docs encode, decoder

-}

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


{-| One JSON blob covering every persisted field, written to one namespaced
localStorage key (`index.ts` picks the key name — this module only shapes
the payload). One blob, not the reference site's ~18 individual keys,
because this Elm model is the only consumer and there's no cross-tool
format constraint pushing toward many keys.
-}
port storeThemeState : Encode.Value -> Cmd msg


{-| On boot, `index.ts` reads localStorage and sends the stored blob back in
(or `Encode.null` if absent/private-mode) — `Theme.init` decodes it, falling
back to defaults on decode failure or absence.
-}
port readThemeState : (Decode.Value -> msg) -> Sub msg


{-| One raw `--{property}: {value}` write via `documentElement.style.setProperty`.
Used for every color-role override, every computed typescale/shape token, and
every Advanced-section control — none of these are expressible as an
`Ir.attribute`, per `Shared.elm`'s existing "Elm cannot set a CSS custom
property directly" comment.
-}
port setCssOverride : { property : String, value : String } -> Cmd msg


{-| Rewrites the favicon's fill to the live seed color. Shared with the
tangram-logo spec — see `specs/2026-08-08-tangram-logo-design.md`.
-}
port setFaviconColor : String -> Cmd msg


{-| Encoder for the persisted blob. Keep in sync with `decoder` below and
with `Theme.Model`'s field list (Task 7) — this is the one place both must
agree.
-}
encode :
    { scheme : String
    , seed : String
    , contrast : String
    , density : Float
    , motion : String
    , displayFont : String
    , bodyFont : String
    , typeScaleMode : String
    , typeScaleFactor : Float
    , typeScaleRatio : Float
    , typeScaleBase : Float
    , typeScaleBump : Float
    , typeScaleExponent : Float
    , shapeScaleMode : String
    , shapeScaleFactor : Float
    , shapeScaleRatio : Float
    , shapeScaleBase : Float
    , shapeScaleBump : Float
    , shapeScaleExponent : Float
    , colorOverrides : List ( String, String )
    , cssOverrides : List ( String, String )
    , activePresetId : Maybe String
    }
    -> Encode.Value
encode state =
    Encode.object
        [ ( "scheme", Encode.string state.scheme )
        , ( "seed", Encode.string state.seed )
        , ( "contrast", Encode.string state.contrast )
        , ( "density", Encode.float state.density )
        , ( "motion", Encode.string state.motion )
        , ( "displayFont", Encode.string state.displayFont )
        , ( "bodyFont", Encode.string state.bodyFont )
        , ( "typeScaleMode", Encode.string state.typeScaleMode )
        , ( "typeScaleFactor", Encode.float state.typeScaleFactor )
        , ( "typeScaleRatio", Encode.float state.typeScaleRatio )
        , ( "typeScaleBase", Encode.float state.typeScaleBase )
        , ( "typeScaleBump", Encode.float state.typeScaleBump )
        , ( "typeScaleExponent", Encode.float state.typeScaleExponent )
        , ( "shapeScaleMode", Encode.string state.shapeScaleMode )
        , ( "shapeScaleFactor", Encode.float state.shapeScaleFactor )
        , ( "shapeScaleRatio", Encode.float state.shapeScaleRatio )
        , ( "shapeScaleBase", Encode.float state.shapeScaleBase )
        , ( "shapeScaleBump", Encode.float state.shapeScaleBump )
        , ( "shapeScaleExponent", Encode.float state.shapeScaleExponent )
        , ( "colorOverrides", Encode.object (List.map (\( k, v ) -> ( k, Encode.string v )) state.colorOverrides) )
        , ( "cssOverrides", Encode.object (List.map (\( k, v ) -> ( k, Encode.string v )) state.cssOverrides) )
        , ( "activePresetId"
          , state.activePresetId |> Maybe.map Encode.string |> Maybe.withDefault Encode.null
          )
        ]


decoder :
    Decoder
        { scheme : String
        , seed : String
        , contrast : String
        , density : Float
        , motion : String
        , displayFont : String
        , bodyFont : String
        , typeScaleMode : String
        , typeScaleFactor : Float
        , typeScaleRatio : Float
        , typeScaleBase : Float
        , typeScaleBump : Float
        , typeScaleExponent : Float
        , shapeScaleMode : String
        , shapeScaleFactor : Float
        , shapeScaleRatio : Float
        , shapeScaleBase : Float
        , shapeScaleBump : Float
        , shapeScaleExponent : Float
        , colorOverrides : List ( String, String )
        , cssOverrides : List ( String, String )
        , activePresetId : Maybe String
        }
decoder =
    Decode.map8
        (\scheme seed contrast density motion displayFont bodyFont rest -> rest scheme seed contrast density motion displayFont bodyFont)
        (Decode.field "scheme" Decode.string)
        (Decode.field "seed" Decode.string)
        (Decode.field "contrast" Decode.string)
        (Decode.field "density" Decode.float)
        (Decode.field "motion" Decode.string)
        (Decode.field "displayFont" Decode.string)
        (Decode.field "bodyFont" Decode.string)
        (Decode.map8
            (\typeScaleMode typeScaleFactor typeScaleRatio typeScaleBase typeScaleBump typeScaleExponent shapeScaleMode rest2 ->
                \scheme seed contrast density motion displayFont bodyFont ->
                    rest2
                        scheme
                        seed
                        contrast
                        density
                        motion
                        displayFont
                        bodyFont
                        typeScaleMode
                        typeScaleFactor
                        typeScaleRatio
                        typeScaleBase
                        typeScaleBump
                        typeScaleExponent
                        shapeScaleMode
            )
            (Decode.field "typeScaleMode" Decode.string)
            (Decode.field "typeScaleFactor" Decode.float)
            (Decode.field "typeScaleRatio" Decode.float)
            (Decode.field "typeScaleBase" Decode.float)
            (Decode.field "typeScaleBump" Decode.float)
            (Decode.field "typeScaleExponent" Decode.float)
            (Decode.field "shapeScaleMode" Decode.string)
            (Decode.map6
                (\shapeScaleFactor shapeScaleRatio shapeScaleBase shapeScaleBump shapeScaleExponent colorOverrides ->
                    \scheme seed contrast density motion displayFont bodyFont typeScaleMode typeScaleFactor typeScaleRatio typeScaleBase typeScaleBump typeScaleExponent shapeScaleMode ->
                        { scheme = scheme
                        , seed = seed
                        , contrast = contrast
                        , density = density
                        , motion = motion
                        , displayFont = displayFont
                        , bodyFont = bodyFont
                        , typeScaleMode = typeScaleMode
                        , typeScaleFactor = typeScaleFactor
                        , typeScaleRatio = typeScaleRatio
                        , typeScaleBase = typeScaleBase
                        , typeScaleBump = typeScaleBump
                        , typeScaleExponent = typeScaleExponent
                        , shapeScaleMode = shapeScaleMode
                        , shapeScaleFactor = shapeScaleFactor
                        , shapeScaleRatio = shapeScaleRatio
                        , shapeScaleBase = shapeScaleBase
                        , shapeScaleBump = shapeScaleBump
                        , shapeScaleExponent = shapeScaleExponent
                        , colorOverrides = colorOverrides
                        , cssOverrides = []
                        , activePresetId = Nothing
                        }
                )
                (Decode.field "shapeScaleFactor" Decode.float)
                (Decode.field "shapeScaleRatio" Decode.float)
                (Decode.field "shapeScaleBase" Decode.float)
                (Decode.field "shapeScaleBump" Decode.float)
                (Decode.field "shapeScaleExponent" Decode.float)
                (Decode.field "colorOverrides" (Decode.keyValuePairs Decode.string))
            )
        )
```

The nested `mapN` pyramid above is a known Elm `Json.Decode` workaround for exceeding `map8`'s arity (there's no `map20`) — it is correct but unwieldy. **Before implementing verbatim, check whether this codebase already has a `Json.Decode.Extra`-style `andMap`/pipeline helper** (grep `docs/app/` and `src/` for `NoRedInk/elm-json-decode-pipeline` or an in-repo `andMap`) and use `Decode.succeed record |> andMap ... |> andMap ...` instead if one exists — far more readable than the pyramid above, same result. If no such helper exists, either add `NoRedInk/elm-json-decode-pipeline` as a dependency (`cd docs && elm install NoRedInk/elm-json-decode-pipeline`) and rewrite using it, or keep the pyramid — flag the choice in the commit message either way.

- [ ] **Step 2: Remove `storeScheme` from `Ports.elm`**

Edit `docs/app/Ports.elm`, deleting the `storeScheme` port and its doc comment (scheme persistence now flows through `storeThemeState` as one field of the blob):

```elm
port module Ports exposing (onOpenSearchRequested)

{-| Client-side ports for the docs app. Wired to the browser in `index.ts`.

@docs onOpenSearchRequested

-}


{-| Fired when the user presses Cmd/Ctrl+K anywhere in the app. `index.ts`
registers a real `document.addEventListener("keydown", ...)` and calls
`event.preventDefault()` before sending on this port -- Chrome and Edge bind
that shortcut to focusing the address bar, and `Browser.Events.onKeyDown`
cannot call `preventDefault` (it only decodes event data), so without this
port our shortcut would fire ALONGSIDE the browser's, not instead of it.
-}
port onOpenSearchRequested : (() -> msg) -> Sub msg
```

- [ ] **Step 3: Compile-check both files**

Run: `cd docs && elm make app/Theme/Ports.elm app/Ports.elm --output=/dev/null`
Expected: compiles clean.

- [ ] **Step 4: Commit**

```bash
git add docs/app/Theme/Ports.elm docs/app/Ports.elm
git commit -m "feat: replace storeScheme with the theme editor's port family"
```

---

## Task 7: `docs/app/Theme.elm` — `Model`, `Msg`, `init`, `update`

**Files:**
- Create: `docs/app/Theme.elm`

This is the public surface `Shared.elm` imports. Section views (Tasks 8-12) are added to `Theme.view` once they exist; this task stubs `view` to just the scheme segmented + preset gallery + swatch strip + an empty accordion + reset button, so the module compiles standalone before the sections exist.

- [ ] **Step 1: Write the module**

```elm
module Theme exposing (Model, Msg, init, subscriptions, update, view)

import Dict exposing (Dict)
import HtmlIr.Element exposing (Element)
import M3e
import M3e.Attributes
import M3e.Icon
import M3e.IconButton
import M3e.Kind
import M3e.Values as Value exposing (Value)
import Theme.Ports
import Theme.Presets exposing (Preset)
import Theme.Scale as Scale exposing (ScaleConfig, ScaleMode)
import TypedHtml
import TypedHtml.Attributes
import TypedHtml.Events
import TypedHtml.Grouping
import TypedHtml.Values


type alias Model =
    { scheme : Value Value.Scheme
    , seed : String
    , contrast : Value Value.Contrast
    , density : Float
    , motion : Value Value.Motion
    , displayFont : String
    , bodyFont : String
    , typeScale : ScaleConfig
    , shapeScale : ScaleConfig
    , colorOverrides : Dict String String
    , cssOverrides : Dict String String
    , activePresetId : Maybe String
    }


init : Model
init =
    { scheme = Value.auto
    , seed = "#6750A4"
    , contrast = Value.standard
    , density = 0
    , motion = Value.standard
    , displayFont = "Roboto"
    , bodyFont = "Roboto"
    , typeScale = Scale.defaultConfig
    , shapeScale = Scale.defaultConfig
    , colorOverrides = Dict.empty
    , cssOverrides = Dict.empty
    , activePresetId = Nothing
    }


type Msg
    = SetScheme (Value Value.Scheme)
    | SetSeed String
    | SetContrast (Value Value.Contrast)
    | SetDensity Float
    | SetMotion (Value Value.Motion)
    | SetDisplayFont String
    | SetBodyFont String
    | SetTypeScaleMode ScaleMode
    | SetTypeScaleParam TypeScaleParam Float
    | SetShapeScaleMode ScaleMode
    | SetShapeScaleParam TypeScaleParam Float
    | SetColorOverride String String
    | ResetColorOverride String
    | SetCssOverride String String
    | ResetCssOverride String
    | ApplyPreset Preset
    | ThemeStateLoaded Decode.Value
    | ResetAll


{-| Shared between type-scale and shape-scale param updates — both
`ScaleConfig`s expose the same 5 tunable fields.
-}
type TypeScaleParam
    = Factor
    | Ratio
    | Base
    | Bump
    | Exponent


setScaleParam : TypeScaleParam -> Float -> ScaleConfig -> ScaleConfig
setScaleParam param value_ config =
    case param of
        Factor ->
            { config | factor = value_ }

        Ratio ->
            { config | ratio = value_ }

        Base ->
            { config | base = value_ }

        Bump ->
            { config | bump = value_ }

        Exponent ->
            { config | exponent = value_ }
```

`ThemeStateLoaded Decode.Value` needs `Json.Decode as Decode` imported — add `import Json.Decode as Decode` to the import list above.

- [ ] **Step 2: Write `update`, threading every edit through `storeThemeState` and the relevant live-attribute or `setCssOverride` call**

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetScheme scheme ->
            persist { model | scheme = scheme, activePresetId = Nothing }

        SetSeed seed ->
            persist { model | seed = seed, activePresetId = Nothing }
                |> andSetFavicon seed

        SetContrast contrast ->
            persist { model | contrast = contrast, activePresetId = Nothing }

        SetDensity density ->
            persist { model | density = density }

        SetMotion motion ->
            persist { model | motion = motion }

        SetDisplayFont font ->
            persist { model | displayFont = font, activePresetId = Nothing }

        SetBodyFont font ->
            persist { model | bodyFont = font, activePresetId = Nothing }

        SetTypeScaleMode mode ->
            let
                newModel =
                    { model | typeScale = setScaleMode mode model.typeScale }
            in
            persist newModel |> andPushTypeScale newModel

        SetTypeScaleParam param value_ ->
            let
                newModel =
                    { model | typeScale = setScaleParam param value_ model.typeScale }
            in
            persist newModel |> andPushTypeScale newModel

        SetShapeScaleMode mode ->
            let
                newModel =
                    { model | shapeScale = setScaleMode mode model.shapeScale }
            in
            persist newModel |> andPushShapeScale newModel

        SetShapeScaleParam param value_ ->
            let
                newModel =
                    { model | shapeScale = setScaleParam param value_ model.shapeScale }
            in
            persist newModel |> andPushShapeScale newModel

        SetColorOverride cssVar value_ ->
            persist { model | colorOverrides = Dict.insert cssVar value_ model.colorOverrides }
                |> andThen (Theme.Ports.setCssOverride { property = cssVar, value = value_ })

        ResetColorOverride cssVar ->
            persist { model | colorOverrides = Dict.remove cssVar model.colorOverrides }
                |> andThen (Theme.Ports.setCssOverride { property = cssVar, value = "" })

        SetCssOverride cssVar value_ ->
            persist { model | cssOverrides = Dict.insert cssVar value_ model.cssOverrides }
                |> andThen (Theme.Ports.setCssOverride { property = cssVar, value = value_ })

        ResetCssOverride cssVar ->
            persist { model | cssOverrides = Dict.remove cssVar model.cssOverrides }
                |> andThen (Theme.Ports.setCssOverride { property = cssVar, value = "" })

        ApplyPreset preset ->
            let
                newModel =
                    { model
                        | scheme = preset.scheme
                        , seed = preset.seedColor
                        , contrast = preset.contrast
                        , displayFont = preset.displayFont
                        , bodyFont = preset.bodyFont
                        , colorOverrides = Dict.fromList preset.cssOverrides
                        , cssOverrides = Dict.empty
                        , activePresetId = Just preset.id
                    }
            in
            ( newModel
            , Cmd.batch
                (Theme.Ports.setFaviconColor preset.seedColor
                    :: (preset.cssOverrides
                            |> List.map (\( k, v ) -> Theme.Ports.setCssOverride { property = k, value = v })
                       )
                    ++ [ storeState newModel ]
                )
            )

        ThemeStateLoaded value_ ->
            case Decode.decodeValue Theme.Ports.decoder value_ of
                Ok decoded ->
                    let
                        loaded =
                            fromPersisted decoded
                    in
                    ( loaded, Cmd.batch (andPushTypeScaleCmds loaded ++ andPushShapeScaleCmds loaded) )

                Err _ ->
                    -- Absent or corrupt localStorage blob — keep `init`'s defaults, matching
                    -- the spec's "falling back to defaults on decode failure or absence."
                    ( model, Cmd.none )

        ResetAll ->
            persist init
                |> andThen
                    (Cmd.batch
                        (List.map (\( k, _ ) -> Theme.Ports.setCssOverride { property = k, value = "" })
                            (Dict.toList model.colorOverrides ++ Dict.toList model.cssOverrides)
                        )
                    )
```

`persist`, `andThen`, `andSetFavicon`, `storeState`, `setScaleMode`, `andPushTypeScale`, `andPushShapeScale`, `andPushTypeScaleCmds`, `andPushShapeScaleCmds`, and `fromPersisted` are helpers, not yet defined — write them next.

- [ ] **Step 3: Write the `update` helpers**

```elm
{-| Every edit re-persists the full state — matching the reference site's
un-debounced, no-reload-needed `persist()` pattern (`theme-editor.ts`).
-}
persist : Model -> ( Model, Cmd Msg )
persist model =
    ( model, storeState model )


storeState : Model -> Cmd Msg
storeState model =
    Theme.Ports.storeThemeState
        (Theme.Ports.encode
            { scheme = Value.toString model.scheme
            , seed = model.seed
            , contrast = Value.toString model.contrast
            , density = model.density
            , motion = Value.toString model.motion
            , displayFont = model.displayFont
            , bodyFont = model.bodyFont
            , typeScaleMode = Scale.modeToString model.typeScale.mode
            , typeScaleFactor = model.typeScale.factor
            , typeScaleRatio = model.typeScale.ratio
            , typeScaleBase = model.typeScale.base
            , typeScaleBump = model.typeScale.bump
            , typeScaleExponent = model.typeScale.exponent
            , shapeScaleMode = Scale.modeToString model.shapeScale.mode
            , shapeScaleFactor = model.shapeScale.factor
            , shapeScaleRatio = model.shapeScale.ratio
            , shapeScaleBase = model.shapeScale.base
            , shapeScaleBump = model.shapeScale.bump
            , shapeScaleExponent = model.shapeScale.exponent
            , colorOverrides = Dict.toList model.colorOverrides
            , cssOverrides = Dict.toList model.cssOverrides
            , activePresetId = model.activePresetId
            }
        )


andThen : Cmd Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andThen extraCmd ( model, cmd ) =
    ( model, Cmd.batch [ cmd, extraCmd ] )


andSetFavicon : String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andSetFavicon seed =
    andThen (Theme.Ports.setFaviconColor seed)


setScaleMode : ScaleMode -> ScaleConfig -> ScaleConfig
setScaleMode mode config =
    { config | mode = mode }


{-| Push every computed typescale token as one `setCssOverride` call each —
"Computed sizes are pushed via `setCssOverride`, one call per token" per the
spec's Typography section.
-}
pushTypeScaleCmds : Model -> List (Cmd Msg)
pushTypeScaleCmds model =
    Theme.Tokens.typescaleTokens
        |> List.map
            (\token ->
                Theme.Ports.setCssOverride
                    { property = token.cssVar
                    , value = String.fromFloat (Scale.compute model.typeScale token) ++ "rem"
                    }
            )


pushShapeScaleCmds : Model -> List (Cmd Msg)
pushShapeScaleCmds model =
    Theme.Tokens.shapeTokens
        |> List.map
            (\token ->
                Theme.Ports.setCssOverride
                    { property = token.cssVar
                    , value = String.fromFloat (Scale.compute model.shapeScale token) ++ "rem"
                    }
            )


andPushTypeScale : Model -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andPushTypeScale model ( m, cmd ) =
    ( m, Cmd.batch (cmd :: pushTypeScaleCmds model) )


andPushShapeScale : Model -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andPushShapeScale model ( m, cmd ) =
    ( m, Cmd.batch (cmd :: pushShapeScaleCmds model) )


andPushTypeScaleCmds : Model -> List (Cmd Msg)
andPushTypeScaleCmds =
    pushTypeScaleCmds


andPushShapeScaleCmds : Model -> List (Cmd Msg)
andPushShapeScaleCmds =
    pushShapeScaleCmds


fromPersisted :
    { scheme : String
    , seed : String
    , contrast : String
    , density : Float
    , motion : String
    , displayFont : String
    , bodyFont : String
    , typeScaleMode : String
    , typeScaleFactor : Float
    , typeScaleRatio : Float
    , typeScaleBase : Float
    , typeScaleBump : Float
    , typeScaleExponent : Float
    , shapeScaleMode : String
    , shapeScaleFactor : Float
    , shapeScaleRatio : Float
    , shapeScaleBase : Float
    , shapeScaleBump : Float
    , shapeScaleExponent : Float
    , colorOverrides : List ( String, String )
    , cssOverrides : List ( String, String )
    , activePresetId : Maybe String
    }
    -> Model
fromPersisted decoded =
    { scheme = Value.schemeFromString decoded.scheme |> Maybe.withDefault Value.auto
    , seed = decoded.seed
    , contrast = Value.contrastFromString decoded.contrast |> Maybe.withDefault Value.standard
    , density = decoded.density
    , motion = Value.motionFromString decoded.motion |> Maybe.withDefault Value.standard
    , displayFont = decoded.displayFont
    , bodyFont = decoded.bodyFont
    , typeScale =
        { mode = Scale.modeFromString decoded.typeScaleMode |> Maybe.withDefault Scale.Linear
        , factor = decoded.typeScaleFactor
        , ratio = decoded.typeScaleRatio
        , base = decoded.typeScaleBase
        , bump = decoded.typeScaleBump
        , exponent = decoded.typeScaleExponent
        }
    , shapeScale =
        { mode = Scale.modeFromString decoded.shapeScaleMode |> Maybe.withDefault Scale.Linear
        , factor = decoded.shapeScaleFactor
        , ratio = decoded.shapeScaleRatio
        , base = decoded.shapeScaleBase
        , bump = decoded.shapeScaleBump
        , exponent = decoded.shapeScaleExponent
        }
    , colorOverrides = Dict.fromList decoded.colorOverrides
    , cssOverrides = Dict.fromList decoded.cssOverrides
    , activePresetId = decoded.activePresetId
    }
```

Add `import Theme.Tokens` and `import Json.Decode as Decode` to `Theme.elm`'s import list (used by the helpers above but not yet imported in Step 1).

- [ ] **Step 4: Write `subscriptions`**

```elm
subscriptions : Sub Msg
subscriptions =
    Theme.Ports.readThemeState ThemeStateLoaded
```

- [ ] **Step 5: Write a placeholder `view` (accordion sections added in Tasks 8-12)**

```elm
view :
    { dir : TypedHtml.Values.Value TypedHtml.Values.Dir
    , onSetDirection : TypedHtml.Values.Value TypedHtml.Values.Dir -> msg
    }
    -> Model
    -> (Msg -> msg)
    -> Element (TypedHtml.Grouping.DivIs s) admittedBy msg
view dirCtx model toMsg =
    TypedHtml.div
        [ TypedHtml.Attributes.id "settings-sheet-content"
        , TypedHtml.Attributes.class "flex flex-col gap-2 py-4"
        ]
        [ TypedHtml.map toMsg (seedColorInput model)
        , TypedHtml.map toMsg (schemeSegmented model)
        , TypedHtml.map toMsg (presetGallery model)
        , TypedHtml.map toMsg (swatchStrip model)

        -- Accordion sections wired in Tasks 8-12; each returns
        -- `Element (M3e.ExpansionPanel.Is s) admittedBy Msg`.
        , TypedHtml.map toMsg (M3e.accordion [] [])
        , directionSegmentedFor dirCtx
        , TypedHtml.map toMsg (resetAllButton model)
        ]
```

`TypedHtml.map` needs confirming against this codebase's actual `Element`-to-`Element` msg-mapping function name (`HtmlIr.Element` likely exposes a `map` — grep `src/HtmlIr/Element.elm` for its exact name before using `TypedHtml.map` verbatim; it may be `Element.map` or `El.map` depending on how `Theme.elm` imports it). `schemeSegmented`, `seedColorInput`, `presetGallery`, `swatchStrip`, `directionSegmentedFor`, and `resetAllButton` are written next.

- [ ] **Step 6: Port `schemeSegmented` and `seedColorInput` from `Shared.elm` unchanged**

Copy `Shared.elm`'s `schemeSegmented` (lines 875-882) and `seedColorInput` (lines 894-913) verbatim into `Theme.elm`, renaming their `Msg` constructor references from `SetScheme`/`SetSeed` (Shared's) to this module's own `SetScheme`/`SetSeed` (already matching names — no rename needed, just move the function bodies and retarget `model : Model` to this module's `Theme.Model` instead of `Shared.Model`). The `segmented`/`controlLabel` helper functions those two call also need to move — copy those too (locate their definitions near `schemeSegmented` in `Shared.elm`, likely just above it).

- [ ] **Step 7: Write `presetGallery`**

```elm
presetGallery : Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
presetGallery model =
    TypedHtml.div
        [ TypedHtml.Attributes.class "grid grid-cols-2 gap-2" ]
        (List.map (presetCard model) Theme.Presets.presets)


presetCard : Model -> Preset -> Element (M3e.Kind.Is s) admittedBy Msg
presetCard model preset =
    M3e.button
        [ TypedHtml.Events.onClick (ApplyPreset preset)
        , M3e.Attributes.variant
            (if model.activePresetId == Just preset.id then
                Value.filled

             else
                Value.outlined
            )
        ]
        [ M3e.text preset.name ]
```

Confirm `M3e.button`'s exact `variant` admission row and `Value.filled`/`Value.outlined` are the right tokens by checking `src/M3e/Button.elm` — this mirrors the pattern already used elsewhere in `Shared.elm` for other buttons (e.g. the nav-item active-state styling), so grep `Shared.elm` for an existing `M3e.button [ M3e.Attributes.variant ...]` call to copy the exact working pattern rather than guessing.

- [ ] **Step 8: Write `swatchStrip`**

```elm
{-| The beercss-style "fast tweak" path: a compact strip of curated seed
colors. Only changes `seed` — leaves scheme/contrast/fonts untouched, unlike
`presetCard` above.
-}
swatchStrip : Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
swatchStrip model =
    TypedHtml.div
        [ TypedHtml.Attributes.class "flex flex-wrap gap-1" ]
        (List.map (swatch model) curatedSwatchColors)


{-| ~20 curated hex colors for the quick-picker, chosen for hue spread
across the Material color wheel. Exact hex values are a design/visual call —
Jack should eyeball these against `beercss.com`'s `#themes3` popover (the
spec's explicit reference) during manual review and adjust before shipping;
these are a reasonable starting set, not pixel-matched to beercss.
-}
curatedSwatchColors : List String
curatedSwatchColors =
    [ "#6750A4", "#B3261E", "#7D5260", "#006A6A", "#984061", "#8C4A2F"
    , "#5C6BC0", "#00897B", "#43A047", "#FB8C00", "#D81B60", "#5E35B1"
    , "#3949AB", "#00ACC1", "#7CB342", "#FDD835", "#F4511E", "#6D4C41"
    , "#546E7A", "#8E24AA"
    ]


swatch : Model -> String -> Element (M3e.Kind.Is s) admittedBy Msg
swatch model hex =
    TypedHtml.button
        [ TypedHtml.Events.onClick (SetSeed hex)
        , TypedHtml.Attributes.class "size-8 rounded-full border-2"
        , TypedHtml.Attributes.style "background-color" hex

        -- NOTE: `TypedHtml.Attributes.style` for a plain CSS color (not a
        -- custom property) is fine — the "Elm cannot set a CSS custom
        -- property" constraint (Shared.elm:1601) is about `--var` writes
        -- specifically, not ordinary inline styles. Confirm `TypedHtml`
        -- actually exposes a `style` attribute function before using it
        -- verbatim; if it doesn't (the spec says "`TypedHtml` deliberately
        -- has no raw `style` escape hatch"), use a `bg-[${hex}]` Tailwind
        -- arbitrary-value class instead, same mechanism `densityClass`
        -- already uses in `Shared.elm`.
        , TypedHtml.Attributes.class
            (if model.seed == hex then
                "border-primary"

             else
                "border-transparent"
            )
        ]
        []
```

The spec's own text says `TypedHtml` has no `style` escape hatch — so the `TypedHtml.Attributes.style` call above is almost certainly wrong. Use the Tailwind-arbitrary-class approach instead (matching `densityClass`, `Shared.elm`'s existing pattern for exactly this "Elm can't set inline dynamic values" problem):

```elm
swatch : Model -> String -> Element (M3e.Kind.Is s) admittedBy Msg
swatch model hex =
    TypedHtml.button
        [ TypedHtml.Events.onClick (SetSeed hex)
        , TypedHtml.Attributes.class ("size-8 rounded-full border-2 [background-color:" ++ hex ++ "]")
        , TypedHtml.Attributes.class
            (if model.seed == hex then
                "border-primary"

             else
                "border-transparent"
            )
        ]
        []
```

This uses a Tailwind v4 arbitrary-property class (`[background-color:#6750A4]`), the same escape hatch `densityClass` already relies on — verify Tailwind's arbitrary-value bracket syntax actually accepts a raw hex with a `#` unescaped (some Tailwind versions require escaping `#` as `\#` inside brackets); check `densityClass`'s definition in `Shared.elm` for the exact escaping convention this codebase already uses.

- [ ] **Step 9: Write `directionSegmentedFor` and `resetAllButton`**

```elm
directionSegmentedFor :
    { dir : TypedHtml.Values.Value TypedHtml.Values.Dir
    , onSetDirection : TypedHtml.Values.Value TypedHtml.Values.Dir -> msg
    }
    -> Element (TypedHtml.Grouping.DivIs s) admittedBy msg
directionSegmentedFor ctx =
    -- Kept as a thin wrapper here so `Theme.view`'s top-to-bottom layout
    -- (spec section "View structure", item 5) stays in one place, but `dir`
    -- ownership and the actual segmented-button markup stay in Shared.elm
    -- (copy `directionSegmented`'s body, retargeting `model.dir`/`SetDirection`
    -- to `ctx.dir`/`ctx.onSetDirection`) — this is a document-level concern
    -- per the spec's non-goals, not part of Theme.Model.
    Debug.todo "copy Shared.elm's directionSegmented body here, parameterized over ctx.dir/ctx.onSetDirection"


resetAllButton : Model -> Element (M3e.Kind.Is s) admittedBy Msg
resetAllButton _ =
    M3e.button
        [ TypedHtml.Events.onClick ResetAll ]
        [ M3e.text "Reset all" ]
```

`Debug.todo` is flagged here deliberately, not left silently — replace it in this same step (not a later task) by copying `Shared.elm`'s `directionSegmented` function body (lines 1010-1016) and mechanically substituting every `model.dir` read with `ctx.dir` and every `SetDirection` with `ctx.onSetDirection`. `Debug.todo` calls fail Elm's production build, so this cannot ship — it is written here only as an explicit marker for the copy-paste step, and must be gone before Step 10.

- [ ] **Step 10: Compile-check**

Run: `cd docs && elm make app/Theme.elm --output=/dev/null`
Expected: compiles clean, no `Debug.todo` remaining. Fix whatever import/name mismatches come up against the real `TypedHtml`/`HtmlIr`/`M3e` APIs — the exact function names for `Element` mapping, `M3e.button`'s variant row, and `TypedHtml.button` were flagged as needing confirmation above; resolve them here against the real compiler errors rather than guessing further.

- [ ] **Step 11: Commit**

```bash
git add docs/app/Theme.elm
git commit -m "feat: add Theme.elm — model/update/init for the theme editor"
```

---

## Task 8: `docs/app/Theme/Sections/Color.elm`

**Files:**
- Create: `docs/app/Theme/Sections/Color.elm`

One row per token, grouped by `Theme.Tokens.colorGroups` (Task 3). Each row: current value (from `model.colorOverrides`, falling back to "not overridden" display), a native color `<input>`, and a reset button.

- [ ] **Step 1: Write the module**

```elm
module Theme.Sections.Color exposing (view)

import Dict exposing (Dict)
import HtmlIr.Element exposing (Element)
import M3e
import M3e.Icon
import M3e.IconButton
import Theme exposing (Msg(..))
import Theme.Tokens as Tokens exposing (ColorToken)
import TypedHtml
import TypedHtml.Attributes
import TypedHtml.Events
import TypedHtml.Grouping
import TypedHtml.Sectioning


view : Theme.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
view model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-3" ]
        (List.map (groupView model) Tokens.colorGroups)


groupView : Theme.Model -> ( String, List ColorToken ) -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
groupView model ( groupName, tokens ) =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-1" ]
        (TypedHtml.Sectioning.h3 [] [ M3e.text groupName ]
            :: List.map (tokenRow model) tokens
        )


tokenRow : Theme.Model -> ColorToken -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
tokenRow model token =
    let
        current : Maybe String
        current =
            Dict.get token.cssVar model.colorOverrides
    in
    TypedHtml.div [ TypedHtml.Attributes.class "flex items-center gap-2" ]
        [ TypedHtml.label [] [ M3e.text token.role ]
        , TypedHtml.input
            [ TypedHtml.Attributes.type_ "color"
            , TypedHtml.Attributes.value (Maybe.withDefault "#000000" current)
            , TypedHtml.Events.onInput (SetColorOverride token.cssVar)
            ]
            []
        , M3e.iconButton
            [ TypedHtml.Attributes.disabled (current == Nothing)
            , TypedHtml.Events.onClick (ResetColorOverride token.cssVar)
            ]
            [ M3e.icon [ M3e.Icon.name "restart_alt" ] [] ]
        ]
```

`Theme exposing (Msg(..))` — check `Theme.elm`'s Task 7 module header actually exposes `Msg(..))` (constructors, not just the opaque type) before this compiles; if `Theme.elm` only exposes `Msg` opaquely (the conventional Elm Model/Msg/update encapsulation pattern), this section module cannot construct `SetColorOverride` directly. Given 5 section modules all need to construct `Theme.Msg` values, either (a) expose `Msg(..)` from `Theme.elm` (simplest — acceptable here since these are sibling modules in the same package, not external consumers), or (b) have each section module return its own local `Msg` type and have `Theme.view` map it — adds a translation layer for no real benefit at this scope. Use (a): go back to Task 7 Step 1 and change `module Theme exposing (Model, Msg, init, subscriptions, update, view)` to `module Theme exposing (Model, Msg(..), init, subscriptions, update, view)`.

- [ ] **Step 2: Compile-check**

Run: `cd docs && elm make app/Theme/Sections/Color.elm --output=/dev/null`

- [ ] **Step 3: Commit**

```bash
git add docs/app/Theme.elm docs/app/Theme/Sections/Color.elm
git commit -m "feat: add theme editor Color accordion section"
```

---

## Task 9: `docs/app/Theme/Sections/Typography.elm`

**Files:**
- Create: `docs/app/Theme/Sections/Typography.elm`

Display/body font selects, a Linear/Modular/Bump/Power mode segmented control, per-mode stepper sets, and a live 15-token size preview.

- [ ] **Step 1: Write the module**

```elm
module Theme.Sections.Typography exposing (view)

import M3e
import Theme exposing (Msg(..))
import Theme.Scale as Scale exposing (ScaleMode)
import Theme.Tokens as Tokens
import TypedHtml
import TypedHtml.Attributes
import TypedHtml.Events
import TypedHtml.Grouping


view : Theme.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
view model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-3" ]
        [ fontSelect "Display font" model.displayFont SetDisplayFont
        , fontSelect "Body font" model.bodyFont SetBodyFont
        , modeSegmented model.typeScale.mode SetTypeScaleMode
        , stepperControls model.typeScale
        , preview model
        ]


{-| Reuse a fixed font list rather than free text — matches the reference
site's `<select>`-based font picker. Exact list is a design call; start with
this set (common Google Fonts pairings) and let Jack extend it during
manual review.
-}
availableFonts : List String
availableFonts =
    [ "Roboto", "Roboto Flex", "Roboto Serif", "Roboto Mono", "Inter", "Newsreader", "Space Grotesk", "JetBrains Mono" ]


fontSelect : String -> String -> (String -> Msg) -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
fontSelect labelText current toMsg =
    TypedHtml.div [ TypedHtml.Attributes.class "flex items-center gap-2" ]
        [ TypedHtml.label [] [ M3e.text labelText ]
        , TypedHtml.select
            [ TypedHtml.Events.onInput toMsg ]
            (List.map
                (\font ->
                    TypedHtml.option
                        [ TypedHtml.Attributes.value font, TypedHtml.Attributes.selected (font == current) ]
                        [ M3e.text font ]
                )
                availableFonts
            )
        ]


modeSegmented : ScaleMode -> (ScaleMode -> Msg) -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
modeSegmented current toMsg =
    TypedHtml.div [ TypedHtml.Attributes.class "flex gap-1" ]
        (List.map
            (\mode ->
                TypedHtml.button
                    [ TypedHtml.Events.onClick (toMsg mode)
                    , TypedHtml.Attributes.class
                        (if mode == current then
                            "font-bold"

                         else
                            ""
                        )
                    ]
                    [ M3e.text (Scale.modeToString mode) ]
            )
            [ Scale.Linear, Scale.Modular, Scale.Bump, Scale.Power ]
        )


{-| Only the fields relevant to the active mode are meaningfully editable —
Linear uses `factor`, Modular uses `ratio`+`base`, Bump uses `bump`, Power
uses `exponent`+`base`. Render all steppers unconditionally with the ones
that aren't relevant grayed out (simplest — matches the reference site
showing the full stepper set per mode) rather than conditionally hiding
rows.
-}
stepperControls : Scale.ScaleConfig -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
stepperControls config =
    case config.mode of
        Scale.Linear ->
            numberStepper "Factor" config.factor 0.05 (SetTypeScaleParam Theme.Factor)

        Scale.Modular ->
            TypedHtml.div []
                [ numberStepper "Ratio" config.ratio 0.01 (SetTypeScaleParam Theme.Ratio)
                , numberStepper "Base (rem)" config.base 0.05 (SetTypeScaleParam Theme.Base)
                ]

        Scale.Bump ->
            numberStepper "Bump (rem)" config.bump 0.05 (SetTypeScaleParam Theme.Bump)

        Scale.Power ->
            TypedHtml.div []
                [ numberStepper "Exponent" config.exponent 0.05 (SetTypeScaleParam Theme.Exponent)
                , numberStepper "Base (rem)" config.base 0.05 (SetTypeScaleParam Theme.Base)
                ]


numberStepper : String -> Float -> Float -> (Float -> Msg) -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
numberStepper labelText current step_ toMsg =
    TypedHtml.div [ TypedHtml.Attributes.class "flex items-center gap-1" ]
        [ TypedHtml.label [] [ M3e.text labelText ]
        , TypedHtml.button [ TypedHtml.Events.onClick (toMsg (current - step_)) ] [ M3e.text "−" ]
        , M3e.text (String.fromFloat current)
        , TypedHtml.button [ TypedHtml.Events.onClick (toMsg (current + step_)) ] [ M3e.text "+" ]
        ]


preview : Theme.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
preview model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-1" ]
        (List.map
            (\token ->
                TypedHtml.div
                    [ TypedHtml.Attributes.class ("[font-size:" ++ String.fromFloat (Scale.compute model.typeScale token) ++ "rem]") ]
                    [ M3e.text token.label ]
            )
            Tokens.typescaleTokens
        )
```

`Theme.Factor`/`Theme.Ratio`/`Theme.Base`/`Theme.Bump`/`Theme.Exponent` (the `TypeScaleParam` constructors from Task 7) need the same `Msg(..)`-style exposure fix as Task 8 — go back to `Theme.elm`'s module header and also expose `TypeScaleParam(..)`: `module Theme exposing (Model, Msg(..), TypeScaleParam(..), init, subscriptions, update, view)`.

- [ ] **Step 2: Compile-check**

Run: `cd docs && elm make app/Theme.elm app/Theme/Sections/Typography.elm --output=/dev/null`

- [ ] **Step 3: Commit**

```bash
git add docs/app/Theme.elm docs/app/Theme/Sections/Typography.elm
git commit -m "feat: add theme editor Typography accordion section"
```

---

## Task 10: `docs/app/Theme/Sections/Shape.elm`

**Files:**
- Create: `docs/app/Theme/Sections/Shape.elm`

Identical structure to Typography but for the 9 shape tokens — static preview swatches (XS…Full), no live-updating boxes, per the spec ("matches reference; not asked to improve this").

- [ ] **Step 1: Write the module**

```elm
module Theme.Sections.Shape exposing (view)

import M3e
import Theme exposing (Msg(..))
import Theme.Scale as Scale exposing (ScaleMode)
import Theme.Tokens as Tokens
import TypedHtml
import TypedHtml.Attributes
import TypedHtml.Grouping


view : Theme.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
view model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-3" ]
        [ modeSegmented model.shapeScale.mode SetShapeScaleMode
        , stepperControls model.shapeScale
        , staticPreview
        ]


{-| Reuses `Theme.Sections.Typography`'s `modeSegmented`/`stepperControls`
shape and behavior exactly, just retargeted to `SetShapeScaleMode`/
`SetShapeScaleParam`. Given both sections need byte-identical mode-segmented
and stepper widgets, consider factoring `modeSegmented`/`numberStepper` out
of `Theme.Sections.Typography` into a shared `Theme.Sections.Shared` module
during this task rather than duplicating them — cheap now, saves a
duplicate-drift bug later (DRY, per this repo's coding-preferences).
-}
modeSegmented : ScaleMode -> (ScaleMode -> Msg) -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
modeSegmented =
    -- Move this and `stepperControls`/`numberStepper` into a new
    -- `Theme/Sections/Shared.elm` module in this task, imported by both
    -- `Typography.elm` and `Shape.elm`. Delete the duplicate definitions
    -- from `Typography.elm` (Task 9) once the shared module exists.
    Debug.todo "factor out of Theme.Sections.Typography into Theme.Sections.Shared, per the note above"


stepperControls : Scale.ScaleConfig -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
stepperControls =
    Debug.todo "same factoring as modeSegmented"


{-| Static preview — six swatches labeled XS/S/M/L/XL/Full, matching the
reference site (`themes.astro:314-338`). Uses fixed Tailwind rounded-*
classes, NOT computed from `Theme.Scale`, per the spec's explicit "static
preview swatches ... no live-updating boxes."
-}
staticPreview : Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
staticPreview =
    TypedHtml.div [ TypedHtml.Attributes.class "flex gap-2" ]
        [ swatchBox "rounded-extra-small" "XS"
        , swatchBox "rounded-small" "S"
        , swatchBox "rounded-medium" "M"
        , swatchBox "rounded-large" "L"
        , swatchBox "rounded-extra-large" "XL"
        , swatchBox "rounded-full" "Full"
        ]


swatchBox : String -> String -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
swatchBox roundedClass labelText =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col items-center gap-1" ]
        [ TypedHtml.div [ TypedHtml.Attributes.class ("size-10 bg-primary " ++ roundedClass) ] []
        , M3e.text labelText
        ]
```

Confirm `rounded-extra-small`/`rounded-small`/etc. actually exist as Tailwind utility classes in this repo (they're referenced by the reference site's Astro build, which has its own Tailwind config — this repo's `docs/vendor/tailwind-m3e-web` may name its shape utilities differently). Grep `docs/vendor/tailwind-m3e-web/` for `rounded-` utility definitions before trusting these class names; adjust to whatever this repo's actual shape-radius utility classes are named.

- [ ] **Step 2: Do the `Theme.Sections.Shared` factoring described in Step 1's comment**

Create `docs/app/Theme/Sections/Shared.elm` exposing `modeSegmented` and `stepperControls`/`numberStepper`, generalized over which `ScaleConfig`-parameter `Msg` constructor to fire (pass the constructors in as function arguments, as `Typography.elm`'s Task 9 versions already do via `toMsg` parameters — those are already reusable as written; this step is just moving them to a new file and updating both `Typography.elm` and `Shape.elm` to import from there instead of defining/duplicating locally). Remove the `Debug.todo`s from Step 1's `Shape.elm` once this exists.

- [ ] **Step 3: Compile-check**

Run: `cd docs && elm make app/Theme.elm app/Theme/Sections/Shape.elm app/Theme/Sections/Typography.elm app/Theme/Sections/Shared.elm --output=/dev/null`
Expected: compiles clean, no `Debug.todo` remaining.

- [ ] **Step 4: Commit**

```bash
git add docs/app/Theme/Sections/Shape.elm docs/app/Theme/Sections/Shared.elm docs/app/Theme/Sections/Typography.elm
git commit -m "feat: add theme editor Shape accordion section, factor out shared stepper widgets"
```

---

## Task 11: `docs/app/Theme/Sections/Appearance.elm`

**Files:**
- Create: `docs/app/Theme/Sections/Appearance.elm`

Contrast (ported from `Shared.elm`'s `contrastSegmented`), Motion (new), Density (ported from `Shared.elm`'s `densitySegmented`, unchanged mechanism).

- [ ] **Step 1: Write the module**

```elm
module Theme.Sections.Appearance exposing (view)

import M3e.Values as Value
import Theme exposing (Msg(..))
import TypedHtml
import TypedHtml.Attributes
import TypedHtml.Grouping


view : Theme.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
view model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-3" ]
        [ contrastSegmented model
        , motionSegmented model
        , densitySegmented model
        ]


{-| Copy `Shared.elm`'s `contrastSegmented` body verbatim (currently
`Shared.elm:884-887`), retargeting `model : Shared.Model` to
`model : Theme.Model` (same field name, `contrast`, no rename needed).
-}
contrastSegmented : Theme.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
contrastSegmented model =
    segmented
        (Value.contrastValues
            |> List.sortBy contrastOrder
            |> List.map (\v -> ( capitalize (Value.toString v), model.contrast == v, SetContrast v ))
        )


{-| New — not ported, since `Shared.elm` never had a Motion control. Follows
the exact same pattern as `contrastSegmented` above: `Value.motionValues`
already exists (`src/M3e/Values.elm`, confirmed `[ expressive, standard ]`),
so no new `Value` module work is needed, only this segmented-control call
site.
-}
motionSegmented : Theme.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
motionSegmented model =
    segmented
        (Value.motionValues
            |> List.map (\v -> ( capitalize (Value.toString v), model.motion == v, SetMotion v ))
        )


{-| Copy `Shared.elm`'s `densitySegmented` body verbatim (currently
`Shared.elm:915-921`) — mechanism (Tailwind arbitrary-class on `<m3e-theme>`,
via `densityClass`) is UNCHANGED per the spec; only its location moves.
`densityClass` itself stays wherever `<m3e-theme>` is rendered (`Shared.elm`'s
`view`, since it's applied to the theme host element, not this section's
markup) — this function just fires `SetDensity`, it doesn't compute the class.
-}
densitySegmented : Theme.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
densitySegmented model =
    segmented
        [ ( "0", model.density == 0, SetDensity 0 )
        , ( "-1", model.density == -1, SetDensity -1 )
        , ( "-2", model.density == -2, SetDensity -2 )
        , ( "-3", model.density == -3, SetDensity -3 )
        ]
```

`segmented`, `contrastOrder`, `capitalize` are `Shared.elm` private helpers `contrastSegmented`/`densitySegmented` already depend on — copy them into `Theme.elm` (Task 7) if not already copied there in Task 7 Step 6, and import them here (`import Theme exposing (segmented, contrastOrder, capitalize, ...)`, exposing them from `Theme.elm` alongside `Msg(..)`), or duplicate them locally in this section module if `Theme.elm` keeps them private — prefer exposing from `Theme.elm` since `Color`/`Typography`/`Shape` sections likely want `segmented` too (Typography's `modeSegmented`, Task 9, reimplements similar logic inline rather than reusing `segmented` — revisit during Task 9/10's review pass and reuse `segmented` there instead of the bespoke `modeSegmented`/`swatchStrip`-style button loops, for consistency).

- [ ] **Step 2: Compile-check**

Run: `cd docs && elm make app/Theme.elm app/Theme/Sections/Appearance.elm --output=/dev/null`

- [ ] **Step 3: Commit**

```bash
git add docs/app/Theme.elm docs/app/Theme/Sections/Appearance.elm
git commit -m "feat: add theme editor Appearance accordion section (contrast/motion/density)"
```

---

## Task 12: `docs/app/Theme/Sections/Advanced.elm`

**Files:**
- Create: `docs/app/Theme/Sections/Advanced.elm`

Raw stepper controls for the 16 motion-duration tokens and 3 state-layer-opacity tokens (Task 3's `Tokens.motionDurationTokens`/`Tokens.stateOpacityTokens`), each a direct `setCssOverride` call via `SetCssOverride`.

- [ ] **Step 1: Write the module**

```elm
module Theme.Sections.Advanced exposing (view)

import Dict
import M3e
import Theme exposing (Msg(..))
import Theme.Tokens as Tokens
import TypedHtml
import TypedHtml.Attributes
import TypedHtml.Events
import TypedHtml.Grouping


view : Theme.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
view model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-3" ]
        [ TypedHtml.div [] (List.map (durationRow model) Tokens.motionDurationTokens)
        , TypedHtml.div [] (List.map (opacityRow model) Tokens.stateOpacityTokens)
        ]


durationRow : Theme.Model -> Tokens.MotionDurationToken -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
durationRow model token =
    let
        currentMs : Int
        currentMs =
            Dict.get token.cssVar model.cssOverrides
                |> Maybe.andThen (String.replace "ms" "" >> String.toInt)
                |> Maybe.withDefault token.defaultMs
    in
    TypedHtml.div [ TypedHtml.Attributes.class "flex items-center gap-1" ]
        [ TypedHtml.label [] [ M3e.text token.label ]
        , TypedHtml.button
            [ TypedHtml.Events.onClick (SetCssOverride token.cssVar (String.fromInt (currentMs - 25) ++ "ms")) ]
            [ M3e.text "−" ]
        , M3e.text (String.fromInt currentMs ++ "ms")
        , TypedHtml.button
            [ TypedHtml.Events.onClick (SetCssOverride token.cssVar (String.fromInt (currentMs + 25) ++ "ms")) ]
            [ M3e.text "+" ]
        ]


opacityRow : Theme.Model -> Tokens.StateOpacityToken -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
opacityRow model token =
    let
        currentPercent : Int
        currentPercent =
            Dict.get token.cssVar model.cssOverrides
                |> Maybe.andThen (String.replace "%" "" >> String.toInt)
                |> Maybe.withDefault token.defaultPercent
    in
    TypedHtml.div [ TypedHtml.Attributes.class "flex items-center gap-1" ]
        [ TypedHtml.label [] [ M3e.text token.label ]
        , TypedHtml.button
            [ TypedHtml.Events.onClick (SetCssOverride token.cssVar (String.fromInt (currentPercent - 1) ++ "%")) ]
            [ M3e.text "−" ]
        , M3e.text (String.fromInt currentPercent ++ "%")
        , TypedHtml.button
            [ TypedHtml.Events.onClick (SetCssOverride token.cssVar (String.fromInt (currentPercent + 1) ++ "%")) ]
            [ M3e.text "+" ]
        ]
```

- [ ] **Step 2: Compile-check**

Run: `cd docs && elm make app/Theme.elm app/Theme/Sections/Advanced.elm --output=/dev/null`

- [ ] **Step 3: Commit**

```bash
git add docs/app/Theme/Sections/Advanced.elm
git commit -m "feat: add theme editor Advanced accordion section (motion duration/state opacity)"
```

---

## Task 13: Wire the 5 sections into `Theme.view`'s accordion

**Files:**
- Modify: `docs/app/Theme.elm` (the `view` function stubbed in Task 7 Step 5)

- [ ] **Step 1: Replace the empty `M3e.accordion [] []` stub with the 5 real sections**

```elm
        , M3e.accordion []
            [ M3e.ExpansionPanel.el { header = M3e.expansionHeader [] [ M3e.text "Color" ] }
                []
                [ Theme.Sections.Color.view model ]
            , M3e.ExpansionPanel.el { header = M3e.expansionHeader [] [ M3e.text "Typography" ] }
                []
                [ Theme.Sections.Typography.view model ]
            , M3e.ExpansionPanel.el { header = M3e.expansionHeader [] [ M3e.text "Shape" ] }
                []
                [ Theme.Sections.Shape.view model ]
            , M3e.ExpansionPanel.el { header = M3e.expansionHeader [] [ M3e.text "Appearance" ] }
                []
                [ Theme.Sections.Appearance.view model ]
            , M3e.ExpansionPanel.el { header = M3e.expansionHeader [] [ M3e.text "Advanced" ] }
                []
                [ Theme.Sections.Advanced.view model ]
            ]
```

Add `import Theme.Sections.Color`, `import Theme.Sections.Typography`, `import Theme.Sections.Shape`, `import Theme.Sections.Appearance`, `import Theme.Sections.Advanced`, and `import M3e.ExpansionPanel`, `import M3e.ExpansionHeader` to `Theme.elm`'s import list. Confirm `M3e.ExpansionPanel.el`'s exact required-field name is `header` (confirmed in research: `src/M3e/ExpansionPanel.elm:104`, `{ header : Element ... }`) and that `M3e.expansionHeader`/`M3e.accordion` are the correct top-level constructor names exported from the `M3e` barrel module (check `src/M3e.elm`'s export list if these don't resolve).

Each section's `view` returns `Element (TypedHtml.Grouping.DivIs s) admittedBy Msg`, but `M3e.ExpansionPanel.el`'s children list expects `Element childAccepts (ChildAdmittedBy childAdm) msg` (an *admitted-into-expansion-panel* kind, not a bare div). If this produces a kind-mismatch compile error, wrap each section's return value the way `Shared.elm` already wraps arbitrary content into other library slots elsewhere (grep `Shared.elm`/other `docs/app/` files for an existing `M3e.ExpansionPanel.el` or `M3e.expansionPanel` call site to copy the exact child-wrapping convention — accordion/expansion-panel usage likely already exists somewhere in the docs app's own component-showcase pages under `docs/app/`, e.g. an examples page for `M3e.Accordion` itself).

- [ ] **Step 2: Collapsed-by-default confirmation**

Per the spec, "5 sections, collapsed by default (matches reference site default state)." Check `M3e.ExpansionPanel`'s API (`src/M3e/ExpansionPanel.elm`) for an `expanded`/`open` attribute — if the component defaults to collapsed with no attribute set, no action needed; if it defaults to expanded, add the closed-state attribute explicitly to each of the 5 panels above.

- [ ] **Step 3: Compile-check**

Run: `cd docs && elm make app/Theme.elm --output=/dev/null`
Expected: compiles clean.

- [ ] **Step 4: Commit**

```bash
git add docs/app/Theme.elm
git commit -m "feat: wire the 5 accordion sections into Theme.view"
```

---

## Task 14: Integrate `Theme` into `Shared.elm`

**Files:**
- Modify: `docs/app/Shared.elm`

Embed `Theme.Model` as one field (matching the existing `SearchEntry`/search-state pattern the spec calls out), delegate `Theme.Msg` through `Shared.Msg`, remove the code that moved into `Theme.elm`/`Theme/Sections/*.elm`.

- [ ] **Step 1: Add the `Theme.Model` field to `Shared.Model` and remove the fields it now owns**

Edit the `Model` type alias (currently `Shared.elm:96-108`):

```elm
type alias Model =
    { treeOpen : Bool
    , tocOpen : Bool
    , viewportWidth : Int
    , theme : Theme.Model
    , dir : TypedHtml.Values.Value TypedHtml.Values.Dir
    , searchOpen : Bool
    , searchQuery : String
    , searchIndex : Maybe (Result Http.Error (List SearchEntry))
    }
```

`scheme`, `seed`, `contrast`, `density` are removed from `Shared.Model` — they now live inside `model.theme`. `dir` stays (document-level, per the spec's non-goal). Add `import Theme` to `Shared.elm`'s import list (Task 7 already defined this module).

- [ ] **Step 2: Update `init`**

Edit `init` (currently `Shared.elm:341-360`):

```elm
init flags _ =
    let
        width : Int
        width =
            initialViewportWidth flags
    in
    ( { treeOpen = treePinsOpen width
      , tocOpen = tocPinsOpen width
      , viewportWidth = width
      , theme = Theme.init
      , dir = TypedHtml.Values.ltr
      , searchOpen = False
      , searchQuery = ""
      , searchIndex = Nothing
      }
    , Effect.none
    )
```

The spec's "Persistence & boot sequence" section flags that reading `Theme.Ports.readThemeState`'s subscription result may arrive too late for first paint, and suggests a flags-embedded snapshot as a fallback, "confirmed during implementation." For this task, ship the simple version first (subscription-only — `Theme.init` renders defaults on first paint, then `ThemeStateLoaded` patches in the persisted state once the subscription fires) and manually check during Task 17's verification pass whether a visible flash-of-default-theme happens on reload. If it does, that's a follow-up task (embed the localStorage blob into `index.ts`'s `flags()` function the same way `scheme` already is today — `index.ts:120-134` — and decode it synchronously in `Shared.init` instead of waiting on the subscription); do not build that speculatively before confirming it's actually needed.

- [ ] **Step 3: Update `Shared.Msg` and `update` to delegate to `Theme`**

Find `Shared.elm`'s `Msg` type (search for `SetScheme` to locate it) and replace the 5 theme-related constructors (`SetScheme`, `SetSeed`, `SetContrast`, `SetDensity`, plus whatever wraps search — follow the existing `SearchEntry` delegation pattern exactly) with one wrapper:

```elm
type Msg
    = ThemeMsg Theme.Msg
    | SetDirection (TypedHtml.Values.Value TypedHtml.Values.Dir)
    | -- ... existing non-theme constructors (tree/toc/search/viewport) unchanged
```

Replace the 5 handlers currently at `Shared.elm:554-569` with:

```elm
        ThemeMsg themeMsg ->
            let
                ( newTheme, themeCmd ) =
                    Theme.update themeMsg model.theme
            in
            ( { model | theme = newTheme }, Effect.fromCmd (Cmd.map ThemeMsg themeCmd) )

        SetDirection dir ->
            ( { model | dir = dir }, Effect.none )
```

- [ ] **Step 4: Update `subscriptions`**

Find `Shared.elm`'s `subscriptions` function and add `Sub.map ThemeMsg Theme.subscriptions` to whatever `Sub.batch` list already exists there (alongside the existing `onOpenSearchRequested` subscription).

- [ ] **Step 5: Update `view` to call `Theme.view`**

Replace `settingsSheetContent`'s body (currently `Shared.elm:815-831`) with a call into `Theme.view`:

```elm
settingsSheetContent : Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
settingsSheetContent model =
    Theme.view
        { dir = model.dir, onSetDirection = SetDirection }
        model.theme
        ThemeMsg
```

- [ ] **Step 6: Update the `M3e.theme [...]` call in `view`**

The theme host element (currently `Shared.elm:632-650`) reads `model.scheme`/`model.seed`/`model.contrast`/`model.density` directly — retarget every one of those four to `model.theme.scheme`/`model.theme.seed`/`model.theme.contrast`/`model.theme.density`, and add the new `motion` attribute (confirmed already available, `M3e.Theme.motion`, Task-3-adjacent research):

```elm
        [ M3e.theme
            [ M3e.Theme.color model.theme.seed
            , M3e.Theme.scheme model.theme.scheme
            , M3e.Theme.contrast model.theme.contrast
            , M3e.Theme.density model.theme.density
            , M3e.Theme.motion model.theme.motion
            , TypedHtml.Attributes.dir model.dir
            , TypedHtml.Attributes.class (densityClass model.theme.density)
            ]
```

- [ ] **Step 7: Delete the now-dead code**

Delete `schemeSegmented`, `contrastSegmented`, `seedColorInput`, `densitySegmented` from `Shared.elm` — they moved to `Theme.elm`/`Theme/Sections/Appearance.elm` in Tasks 7/11. **Keep** `directionSegmented` (or whatever it was renamed to when threaded through `directionSegmentedFor` in Task 7 Step 9) since `dir` stays in `Shared.Model`. Keep `segmented`/`controlLabel`/`capitalize`/`contrastOrder` helper functions ONLY if `Shared.elm` still has call sites using them after this deletion (`directionSegmented` likely still calls `segmented`) — otherwise delete those too, since they moved to `Theme.elm` in Task 7 Step 6/11 Step 1.

- [ ] **Step 8: Compile-check the whole docs app**

Run: `cd docs && elm make app/Shared.elm --output=/dev/null`
Expected: compiles clean. This is the first point every module from Tasks 3-13 gets compiled together — fix whatever cross-module mismatches surface (likely candidates: the `Element` kind-admission mismatches flagged as TODO-confirm in Tasks 7/13, and any leftover reference to the deleted `Shared.elm` functions from elsewhere in the app, e.g. if `View.elm` or a route module called `schemeSegmented` directly).

- [ ] **Step 9: Run the full docs build**

Run: `cd docs && pnpm build` (or whatever this repo's actual full-build command is — check `docs/package.json`'s `scripts` if `pnpm build` isn't it)
Expected: succeeds.

- [ ] **Step 10: Commit**

```bash
git add docs/app/Shared.elm
git commit -m "feat: integrate Theme module into Shared.elm, remove ported-out settings-sheet code"
```

---

## Task 15: Wire the 4 ports in `docs/index.ts`

**Files:**
- Modify: `docs/index.ts`

Replace the `storeScheme` subscriber (currently `index.ts:86-92`) with handlers for the 4 new ports. Pick ONE namespaced localStorage key for the whole blob — `"m3e-theme-state"` (replaces the old `"m3e-scheme"` key; that key becomes dead, no migration needed since it's just a cache).

- [ ] **Step 1: Remove the old `storeScheme` subscriber and its `flags()` read**

Delete `index.ts:86-92`'s `app?.ports?.storeScheme?.subscribe(...)` block, and delete the `scheme` variable + `window.localStorage.getItem("m3e-scheme")` read in `flags()` (currently `index.ts:120-134`) along with the `scheme` field in the returned flags object — `Theme.init` no longer needs a flags-embedded scheme, since `readThemeState`'s subscription (Step 2 below) now covers it.

- [ ] **Step 2: Add the 4 new port handlers**

```typescript
const THEME_STORAGE_KEY = "m3e-theme-state";

app?.ports?.storeThemeState?.subscribe((state: unknown) => {
  try {
    window.localStorage.setItem(THEME_STORAGE_KEY, JSON.stringify(state));
  } catch (_) {
    /* localStorage unavailable (private mode / SSR) — ignore */
  }
});

app?.ports?.setCssOverride?.subscribe(({ property, value }: { property: string; value: string }) => {
  if (value === "") {
    document.documentElement.style.removeProperty(`--${property}`);
  } else {
    document.documentElement.style.setProperty(`--${property}`, value);
  }
});

app?.ports?.setFaviconColor?.subscribe((hex: string) => {
  const link = document.querySelector<HTMLLinkElement>('link[rel="icon"]');
  if (!link) return;
  // Rewrites the served favicon's fill via a data: URI, generated from the
  // same tangram template `docs/scripts/icons-gen/` builds at build time —
  // see specs/2026-08-08-tangram-logo-design.md's Favicon section. Wired up
  // fully by that spec's plan; this port fires regardless, this handler is
  // a no-op placeholder swap until that spec's generator exists.
});
```

Send `readThemeState` on boot, immediately after the app mounts (near the top of `load`, alongside the existing `elm-pages-announcer` aria-live downgrade):

```typescript
try {
  const raw = window.localStorage.getItem(THEME_STORAGE_KEY);
  app?.ports?.readThemeState?.send(raw ? JSON.parse(raw) : null);
} catch (_) {
  app?.ports?.readThemeState?.send(null);
}
```

`Theme.elm`'s `ThemeStateLoaded` handler (Task 7 Step 2) decodes with `Theme.Ports.decoder`, which expects a JSON object matching `encode`'s shape — a `null` payload will fail that decode and fall through to the "keep defaults" branch, which is the desired absent/private-mode/corrupt behavior.

- [ ] **Step 3: Update the TypeScript port type declarations**

Find wherever `index.ts` types `app.ports` (currently around `index.ts:68-79`, the `ElmPagesInit`/`load` function's local type annotation) and replace the `storeScheme`/`onOpenSearchRequested` shape with:

```typescript
const app = (await elmLoaded) as {
  ports?: {
    storeThemeState?: { subscribe: (cb: (v: unknown) => void) => void };
    readThemeState?: { send: (v: unknown) => void };
    setCssOverride?: { subscribe: (cb: (v: { property: string; value: string }) => void) => void };
    setFaviconColor?: { subscribe: (cb: (v: string) => void) => void };
    onOpenSearchRequested?: { send: (v: null) => void };
  };
};
```

- [ ] **Step 4: Manual smoke test**

Run: `cd docs && pnpm dev`, open the settings sheet, change contrast/seed/density/motion, reload the page, confirm the same values are restored (open devtools Application tab, check `localStorage["m3e-theme-state"]` has the expected JSON shape).

- [ ] **Step 5: Commit**

```bash
git add docs/index.ts
git commit -m "feat: wire the theme editor's 4 ports in index.ts, replacing storeScheme"
```

---

## Task 16: Extend `docs/tests-browser/settings-sheet.spec.ts`

**Files:**
- Modify: `docs/tests-browser/settings-sheet.spec.ts`

Currently open/close only (see the file's full contents in the research above). Add the three assertions the spec calls out by name: a visible-style-change test (the one that would have caught the original bug), a reload-persistence test, and a preset-then-override test.

- [ ] **Step 1: Write the visible-change test**

```typescript
test("changing contrast and seed color produce an observable style change", async ({ page }) => {
  await page.goto("/getting-started/welcome");
  await page.getByRole("button", { name: "Settings" }).click();

  const themeHost = page.locator("m3e-theme");
  const before = await themeHost.evaluate((el) =>
    getComputedStyle(el).getPropertyValue("--md-sys-color-primary").trim()
  );

  // High contrast — the exact button label/role depends on Theme.Sections.Appearance's
  // segmented-button markup (Task 11); adjust the selector to match once that's built.
  await page.getByRole("button", { name: "High" }).click();

  await page.waitForFunction(
    (prev) => getComputedStyle(document.querySelector("m3e-theme")!).getPropertyValue("--md-sys-color-primary").trim() !== prev,
    before
  );

  const after = await themeHost.evaluate((el) =>
    getComputedStyle(el).getPropertyValue("--md-sys-color-primary").trim()
  );
  expect(after).not.toBe(before);
});
```

- [ ] **Step 2: Write the reload-persistence test**

```typescript
test("contrast and seed color survive a reload", async ({ page }) => {
  await page.goto("/getting-started/welcome");
  await page.getByRole("button", { name: "Settings" }).click();

  await page.getByRole("button", { name: "High" }).click();
  await page.locator("#seed-color").fill("#00897B");

  await page.reload();
  await page.getByRole("button", { name: "Settings" }).click();

  await expect(page.getByRole("button", { name: "High" })).toHaveAttribute("selected", "");
  await expect(page.locator("#seed-color")).toHaveValue("#00897b");
});
```

Confirm the exact selected-state attribute/markup (`selected`, `aria-pressed`, or a class) that `M3e.SegmentedButton` actually renders — check `src/M3e/SegmentedButton.elm` or an existing Playwright assertion elsewhere in `docs/tests-browser/` that already asserts against a selected segmented button, and match its convention rather than guessing `toHaveAttribute("selected", "")`.

- [ ] **Step 3: Write the preset-then-override test**

```typescript
test("a color-token override survives a scheme toggle but not Reset all", async ({ page }) => {
  await page.goto("/getting-started/welcome");
  await page.getByRole("button", { name: "Settings" }).click();

  // Apply a preset (exact card label depends on Theme.Presets' data, Task 5 —
  // "Material" is the first preset in that list).
  await page.getByRole("button", { name: "Material" }).click();

  // Open the Color accordion section and override one token. Exact locator
  // depends on Theme.Sections.Color's markup (Task 8) — this targets the
  // first color input in that section by proximity to its label.
  await page.getByText("Color").click();
  const primaryInput = page.locator("label", { hasText: "Primary" }).locator("xpath=following-sibling::input[@type='color']").first();
  await primaryInput.fill("#ff0000");

  await page.getByRole("button", { name: "Dark" }).click();
  await expect(primaryInput).toHaveValue("#ff0000");

  await page.getByRole("button", { name: "Reset all" }).click();
  await expect(primaryInput).not.toHaveValue("#ff0000");
});
```

All three selectors above are marked as needing confirmation against real rendered markup — this is expected; they're written against the plan's own Tasks 5/8/11 designs, but Playwright locators are brittle by nature and should be adjusted against the actual DOM once Tasks 5-13 are built, not guessed further here.

- [ ] **Step 4: Run the Playwright suite**

Run: `cd docs && pnpm playwright test settings-sheet.spec.ts`
Expected: all 5 tests pass (2 existing open/close + 3 new). Fix locator mismatches against the real DOM as they surface.

- [ ] **Step 5: Commit**

```bash
git add docs/tests-browser/settings-sheet.spec.ts
git commit -m "test: add visible-change, persistence, and preset-override coverage to settings-sheet"
```

---

## Task 17: Manual verification pass

**Files:**
- No file changes — this is the spec's own "Verification" section, walked by hand.

- [ ] Run `pnpm dev`, confirm `contrastSegmented`/`seedColorInput` changes are visible without reload (already asserted by Task 16 Step 1, but eyeball it too — some visual bugs don't trip a computed-style assertion, e.g. a wrong hue).
- [ ] Confirm `seed`, `contrast`, `density`, `motion`, font choices, and all color/CSS overrides survive a page reload.
- [ ] Click every preset card; confirm each applies its bundled fields atomically and clears prior overrides (no stale override bleeding through from a previously-applied preset).
- [ ] Click several round-swatch-strip entries; confirm only `seed` changes, nothing else.
- [ ] Click every single Advanced-section stepper at least once; confirm each produces a visible change (open devtools' Computed panel, watch the corresponding `--md-sys-motion-duration-*`/`--md-sys-state-*-opacity` value change) — the spec requires "no control silently no-ops."
- [ ] Walk all 5 accordion sections against two different docs pages — one component-heavy (e.g. a page rendering many `M3e.*` components), one text-heavy (e.g. a prose-only markdown page) — watching for font-loading flashes or density-driven layout shift that a computed-style assertion wouldn't catch.
- [ ] Run the full Playwright suite one more time from clean state: `cd docs && pnpm playwright test` (not just `settings-sheet.spec.ts` — confirm nothing else broke, e.g. `contract.spec.ts` if it snapshots any theme-dependent markup).
- [ ] Confirm `docs/tests-browser/settings-sheet.spec.ts` is green.

No commit for this task — it's a checklist, not a code change. If any item fails, open a task/issue rather than silently patching past this plan's scope (unless the fix is small and obviously in-scope, in which case fix it and note the deviation in that commit's message).
