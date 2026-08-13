---
name: building-m3e-uis
description: >-
  Builds Material 3 Expressive UIs in Elm with the elm-m3e (M3e.*) component library —
  the generated typed binding over @m3e/web. Use in projects using elm-m3e when the user
  wants to add or wire an m3e component (button, dialog, list, nav bar, chips, fab, text
  field, card), asks "how do I use elm-m3e", "material elm ui", "which M3e surface should
  I use", hits a blank screen where m3e components render nothing, or fights the phantom
  types. Covers the two-surface decision (general M3e / per-component M3e.<Component>), the
  mandatory @m3e/web JS custom-element registration (the #1 newcomer trap), and the userland
  seam (Kit text/link producers you copy, not import from the package). For layout composition see composing-m3e-layouts; for a11y see
  making-m3e-accessible; for tokens/theming see theming-m3e-apps; for judging a finished
  view see reviewing-m3e-designs.
---

# Building M3e UIs

elm-m3e is a **generated** typed Elm binding over matraic's `@m3e/web` Material 3
Expressive web components. Everything under `src/M3e/` is emitted by `elm-cem` from the
`@m3e/web` Custom Elements Manifest plus `config/slots.json`; you consume it, you never
hand-edit it. The library ships **no JS runtime** — an `M3e.button` is a lazy IR node
that becomes a `<m3e-button>` only at `HtmlIr.Element.toNode`. The Elm IR core
(`HtmlIr.Element`, `HtmlIr.Node`, `HtmlIr.Attribute`, `HtmlIr.Value`, `HtmlIr.Kind`,
`HtmlIr.Internal`) lives in the shared `elm-html-intermediate-representation` package
(`HtmlIr.*` modules); elm-m3e **imports** them as a dependency rather than copying them
(the IR is imported, never injected).

## The #1 trap: register the custom elements

elm-m3e is a **single Elm package** plus its one runtime dependency, the shared IR:

```bash
elm install jackhp95/elm-html-intermediate-representation  # the HtmlIr.* IR core
elm install jackhp95/elm-m3e                                # the whole M3e.* surface
```

The `<m3e-*>` custom elements are inert HTML until the matching JS is registered at app
startup. **If you skip this, every component renders as an empty/unstyled box and nothing
is wrong with your Elm.** Wire it once:

```bash
npm install @m3e/web
```

```js
// index.js — register every <m3e-*> element BEFORE the Elm app mounts
import "@m3e/web";
import { Elm } from "./Main.elm";
Elm.Main.init({ node: document.getElementById("root") });
```

When "components render but look broken / do nothing", check this import first.

## Two surfaces — decision

The API has **two coordinated surfaces** (see `docs/DESIGN.md`). Both are element↔attr
typed and compiler-checked; they return the same `HtmlIr.Element.Element … msg`, so they
nest and interchange freely. Start general; reach for a per-component module when you want
the compiler (not `elm-review`) to enforce required content and placed-child slot-kinds.

| Want | Use | Why |
|------|-----|-----|
| The everyday default | **general surface** — `M3e.button [attrs] [content]`; shared vocabulary in `M3e.Attributes` / `M3e.Events` / `M3e.Values` | one import (`import M3e exposing (..)`), lowercase names, library-wide setters. Start here. |
| **Required** content (label, action) checked by the **compiler** | **per-component** `M3e.<Component>.view { required } [attrs] [content]` | missing-required becomes a *compile* error, not a lint. Only components that have required parts take a `required` record. |
| A pipeline where **duplicate-singular is unwritable** | **per-component** `M3e.<Component>.build { req } \|> M3e.<Component>.setter \|> …` | setting a singular attr twice fails to type-check. Opt-in, per-component. |
| An `arbitrary`-slot child placed via a slot function, checked by the compiler | **per-component** module | the general surface leaves that one check to `elm-review`; the per-component surface makes it a compile error. |

The **only** three things that move to `elm-review` on the general surface —
missing-required content, duplicate-singular slots/attrs, and the slot-kind of a child
placed via a slot function — are all compile errors on the per-component surface.
Everything else (invalid enum token, wrong attr on an element, wrong-kind *direct* child)
is a compile error on **both**.

**Rule of thumb:** build a settings screen or a form → the **general surface** (`M3e`
barrel). A button/dialog/snackbar that *must* carry a label or action, or a guided
cardinality-guaranteed builder → the **per-component** module's `view { required … }` or
`build` pipeline.

## Don't fight the phantom types

The phantom rows make invalid compositions a compile error (`docs/DESIGN.md`). When
the compiler rejects your view, it is telling you the composition is invalid — **fix the
composition, don't reach for `M3e.Unsafe.fromHtml` or `Seam.recast` to silence it:**

- `M3e.Button.variant Value.square` — compile error: `square` isn't in Button's variant
  value row. Pick a real variant (`M3e.Values.filled`, `.outlined`, …).
- `M3e.Card.view …` inside a Button's content list — compile error: `card` isn't an
  accepted child kind of Button. Use the slot the parent actually accepts.
- Slot placers stamp `slot=` and return the right kind, so `M3e.appBarSlotTitle`,
  `M3e.listItemSlotLeading`, `M3e.navItemSlotIcon` fit exactly one place by construction.

Composition is **add-only**: helpers like `M3e.Button.icon` add a `slot=` and never
mutate existing attrs. Set an attr twice and `elm/html` last-wins applies — predictable,
no dedup machinery.

## The seam: atoms and native elements are userland

Plain text is built in — `M3e.text : String -> Element …` ships in the general surface,
so `M3e.text "Save"` needs nothing extra. The **richer** producers (`link`, typography
sizing, native-HTML elements, raw-`Html` crossings) are userland: they live in the **Kit**,
a copyable module set under `docs/kit/` that is **NOT part of the published package** —
consumers copy `Kit`, `Native`, and `Seam` and adapt them (see `docs/kit/README.md`,
`docs/DESIGN.md`):

- **`Kit`** — `text`, `link`, `textLink`, and typography helpers. These return the
  **shared atom kind** (`HtmlIr.Kind.Shared`), so they fit any slot typed `"shared:text"`
  etc. — and `link` requires at least one content child, enforcing link accessibility at
  the type level.
- **`Native`** — native-HTML IR (`div`, `span`, `p`, `a`, `img`, `ul`, `li`, …). The
  native-HTML brand also ships standalone as `TypedHtml.*` (`elm-typed-html`); the Kit's
  `Native` is the copyable adapter.
- **`Seam`** — the single sanctioned, loud, auditable break-glass (`fromHtml`, `recast`)
  built on `HtmlIr.Internal`. You cannot mint an `Element` from raw HTML anywhere else
  except the published `M3e.Unsafe.fromHtml`; that fence is Elm's own module exposure, not
  a lint rule. For stable semantic crossings, prefer `M3e.Coerce.*` (config-blessed
  coercions) over `recast`.

So a real call reads `M3e.button [ M3e.Button.variant Value.filled ] [ M3e.text "Save" ]`
— library component, built-in text.

## Rendering exit

Everything stays IR until the app root. Convert once, at the top of your `view`:

```elm
myScreen
    |> HtmlIr.Element.toNode
    |> HtmlIr.Node.toHtml   -- IR → Node → Html, the only eager point
```

## Reference

- **[reference/layers-and-forms.md](reference/layers-and-forms.md)** — the
  full layer/form comparison table, the mistake→enforcement matrix, and a compilable
  starter (`Browser.sandbox` app with the JS registration note).
- For neutral Material *theory* (why elevation, color roles, expressive rationale) see
  the **m3e knowledge base** (foundations / styles / expressive / components).
- Per-component API facts (which attributes/slots exist) live in the generated
  implementation cards and the component's own `src/M3e/<Name>.elm` doc comments —
  reference them by name; this skill does not restate them.

---
_Validated against elm-m3e 1.0.0, 2026-07._
