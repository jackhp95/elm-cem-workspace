# elm-m3e architecture — verified ground truth (post phantom-substrate migration)

> Derived from the CODE in this worktree (`docs-layers-audit` @ base 69e27ebc),
> not from prose. Every claim cites the file it was verified against. This is the
> reference the guide-page audit was measured against.
> Verified: 2026-07-28.

## 1. What is published vs. what is generated

**Published to the Elm registry — the 9 modules in `elm.json` `exposed-modules`:**
`M3e.Action, M3e.Attributes, M3e.Build, M3e.Coerce, M3e.Events, M3e.Html,
M3e.Kind, M3e.Unsafe, M3e.Values`.
Source: `elm.json` (exposed-modules), `config/slots.json` `"_publishGeneralOnly": true` (line 4).
These are the brand's "primitives + tokens" layer — the shared vocabulary and the
escape hatches. They are small and cap-safe.

**NOT published — the 128 per-component modules + the `M3e` barrel.**
`src/M3e/*.elm` contains 137 `.elm` files; 9 are the primitives above, leaving
**128 component modules** (`M3e.Button`, `M3e.Card`, …). Plus the barrel `src/M3e.elm`
(module `M3e`). These are delivered by `elm-cem eject` (a codegen/copy target), not
published, because a phantom-typed 128-component API blows the registry's ~700 KB
`docs.json` cap.
Source: `elm-cem/docs/distribution-model.md` ("The component surface — eject, not publish").

**The old 5-layer descent is GONE.** There is no `M3e.Raw.*`, no `M3e.Record.*`, and
no per-component `M3e.Html.<Comp>` mid-layer. Verified: `find src -iname '*.elm'`
matching `Raw`/`Record`/`Html` returns ONLY `src/M3e/Html.elm` (a single module).

## 2. The consumer-facing surfaces (this is a HORIZONTAL choice, not a vertical descent)

You author in the typed brand components and choose a **surface** (a call *shape*)
as a matter of ergonomics. All surfaces render the same component.

| Surface | How to call it | Available on | Verified |
|---|---|---|---|
| **barrel `view`** | `M3e.button attrs children` | all 128 (barrel re-exports each component's `view`) | `src/M3e.elm` line 293 `button = M3e.Button.view` |
| **`view` (standard/list form)** | `M3e.Button.view attrs children` | all 128 | `src/M3e/Button.elm:191` `view = H.button` |
| **`el` (required-record form)** | `M3e.Button.el { content = …, action = … } attrs children` | the **29** components that have a required record | `src/M3e/Button.elm:201`; `grep -lE "^el :" src/M3e/*.elm` → 29 |
| **`build` + `toElement` (builder pipe)** | `M3e.Button.build { content, action } \|> M3e.Button.withVariant … \|> M3e.Button.toElement` | all 128 | `src/M3e/Button.elm:426,437` |

- The barrel `M3e` (`src/M3e.elm`) exposes **every component constructor** (the `view`
  form) + `text` (`src/M3e.elm:1439`) + `toHtml` (`src/M3e.elm:1446`, the bridge to
  `elm/html`). It does **not** expose `el`/`build` — reach for `M3e.<Component>` for those.
- `M3e.<Component>` additionally exposes: narrowed enum setters (`M3e.Button.variant`,
  `src/M3e/Button.elm:241`), per-component slot helpers (`M3e.Button.icon`, `M3e.Dialog.header`,
  `M3e.Dialog.actions`, …), and `withX` builder setters.

## 3. Shared vocabulary vs. per-component setters (the real "loose vs tight" axis)

There is no "layer stack." What used to be framed as descending layers is really two
independent tightness choices:

- **Shared/generic vocabulary** — `M3e.Attributes`, `M3e.Values`, `M3e.Events`.
  Each `M3e.Attributes` setter is an open producer closing over the library-wide
  **union** of enum values; a token valid for *some* component type-checks even on a
  component that doesn't support it — **cross-component misuse is caught by elm-review,
  not the compiler.** Source: `src/M3e/Attributes.elm` module docstring.
- **Per-component setters** — `M3e.<Component>.<attr>` (e.g. `M3e.Button.variant`).
  Compile-tight: only that component's tokens type-check. Source: same docstring
  ("reach for the per-component setters … for compile-tight narrowing").

There is **no** `M3e.slotIcon` / `M3e.buttonIcon` naming (the old "generic vs component
setter" pair). Slot content is filled with per-component slot helpers, e.g.
`M3e.Button.icon (M3e.icon …)` (`docs/.../Strictness.elm` live demo), `M3e.Dialog.header …`.

## 4. `M3e.Html` — the LOOSE producer layer (NOT plain HTML)

`M3e.Html` (`src/M3e/Html.elm`) exposes **one loose, open-rowed producer per m3e
component** (`accordion, button, card, …` — the same 128 element names), in the
elm/html call shape, with fully **open phantom rows** (no slot/attr checking).
Every rich `M3e.<Component>` imports its producer from here and re-exposes it under a
**tightened** signature (`M3e.Button.view = H.button`, `src/M3e/Button.elm:191`).
Source: `src/M3e/Html.elm` module docstring + exposing list.

> ⚠️ Correction to a common misconception: **`M3e.Html` is NOT "plain HTML."** It has
> no `div`/`span`/`p` — its exposing list is entirely `m3e-*` component producers.
> Reach for `M3e.Html.button` to opt OUT of the strict phantom rows while staying in
> the IR (loose composition); it is not the way you emit a `<div>`.

**How a consumer emits plain HTML:** there is no published typed plain-HTML producer in
elm-m3e. Options: wrap `elm/html` via `M3e.Unsafe.fromHtml` (`src/M3e/Unsafe.elm`), or —
per the design doc — depend on the separate `jackhp95/elm-typed-html` package (see §7 caveat).

## 5. Escape hatches — leaving the typed tree

| Module | Kind | Verified |
|---|---|---|
| `M3e.Coerce` | Config-blessed kind crossings. Exposes **only `asButton`** (a Chip admitted where a button is expected). Declared in `config/slots.json` `_coerce`. | `src/M3e/Coerce.elm` |
| `M3e.Unsafe` | The loud legacy-interop escapes: `fromHtml` (wrap raw `Html`, FREE rows), `coerce`, `coerceAll` (re-kind, FREE rows). Every use site is a grep target / lint finding. | `src/M3e/Unsafe.elm` |

## 6. Docs-internal machinery (vendored — NOT what a consumer imports)

The elm-m3e docs SITE (`docs/`) uses vendored helpers that are distinct from the
published consumer surface. Lead with the consumer story; mention these only as
docs-site plumbing.

- `docs/vendor/elm-foundation/` vendors **`TypedHtml.*`** (typed plain-HTML tags:
  `div`, `span`, `label`, `input`, `a`, `Aria.*` …) and **`HtmlIr.*`** (the IR). Source:
  `docs/vendor/elm-foundation/VENDORED_FROM.txt`.
- `docs/kit/Native.elm` — escape-hatch-only IR producers: `node`, `custom` (dynamic/custom
  tag names), `attribute`, `onClick`, `style` (raw injection). Its docstring says "use
  `TypedHtml.*` for plain HTML tags."
- `docs/kit/Seam.elm` — the single sanctioned userland boundary between raw `Html` and the
  phantom IR (`fromHtml`, `asElement`, `asAttribute`, `recast`, `link`, `text`, …), built on
  `HtmlIr.Internal`.
- `docs/kit/Kit.elm` — the docs design-system vocabulary (`Kit.text`, `Kit.link`, typography).
- The IR bridge to a `Node` used at page roots is `HtmlIr.Element.toNode`; the consumer-facing
  bridge to `elm/html` is `M3e.toHtml`.

Note: `HtmlIr` is BOTH a published dependency (`jackhp95/elm-html-intermediate-representation`
in `elm.json` dependencies) AND vendored into `docs/vendor` for the docs site.

## 7. Where the design doc (`distribution-model.md`) is stale / unverifiable

- It lists **5 published packages** including `jackhp95/elm-typed-html` ("typed elm/html,
  brand-agnostic"). In THIS repo, `TypedHtml` exists only as **vendored docs code**
  (`docs/vendor/elm-foundation/`) and is **not** a dependency of elm-m3e (`elm.json`
  deps: elm/core, elm/html, elm/json, elm/virtual-dom, elm-html-intermediate-representation,
  elm-cem-facts). Registry publication of `elm-typed-html` cannot be verified from this repo.
- It says the brand package exposes "~10 general modules"; the actual count is **9**
  (`elm.json`). Minor.
- **RETIRED and correctly marked so:** the **decay ladder** (`bin/decay.js`) and the
  **`swap` command** (`bin/swap.js`). The only direction now is published → vendored (`eject`).

## 8. Vocabulary resolution (for the guide prose)

- **surface / form** — a call *shape* for the same component: `view` (standard/list),
  `el` (required-record), `build`/`toElement` (pipe), plus the barrel `M3e.button`.
  A horizontal ergonomic choice, NOT a safety ranking, NOT a layer to descend.
- **loose vs. tight** — shared `M3e.Attributes.*` vocabulary (union, lint-checked) vs.
  per-component `M3e.<Comp>.*` setters (compile-tight). `M3e.Html.*` is the loose producer.
- **escape** — leaving the typed tree via `M3e.Coerce` / `M3e.Unsafe` (consumer) or the
  docs kit `Native`/`Seam` (docs site).
- **RETIRED terms — must not appear as live API:** `M3e.Raw.*`, `M3e.Record.*`,
  per-component `M3e.Html.<Comp>`, `M3e.Build.<Comp>` (build is `M3e.<Comp>.build`), the
  5-layer "descent," "drop a layer," decay ladder, `swap`.
