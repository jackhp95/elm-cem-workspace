# Migrating to elm-m3e phantom substrate

This guide covers the breaking changes between the old **markup-core** elm-m3e
and the new **phantom** elm-m3e. It is written against three completed, verified
migrations: feedback-fab, compass-social, and animal-spirits.

Skip to the [quick-reference table](#mapping-table) if you want the at-a-glance
mapping, then follow the [step-by-step](#step-by-step) section to work through
your codebase systematically.

---

## What changed and why

The old elm-m3e was layered on `markup-core` (`Markup.Element`, `Markup.Node`,
`Markup.Kind`). The new elm-m3e replaces that with a published, shared IR:
`jackhp95/elm-html-intermediate-representation` (imported as `HtmlIr.*`) and
its companion `jackhp95/elm-typed-html` (imported as `TypedHtml.*`). Every
generated `M3e.*` module now imports `HtmlIr.*` directly — there is no longer a
markup-core runtime injected into your build.

The `M3e` barrel went from roughly 200 re-exported symbols to **component
constructors + `M3e.text` only**. Attrs, tokens, and events each have their own
module now.

At the type level, `Element` gained a second phantom row. The old shape was:

```elm
Markup.Element accepts msg
```

The new shape is:

```elm
HtmlIr.Element.Element accepts admittedBy msg
```

Every annotation that mentions `Element` needs the extra `admittedBy` variable
threaded through.

---

## Mapping table

| Old | New | Notes |
|-----|-----|-------|
| `import Markup.Element` | `import HtmlIr.Element` | same name `Element` |
| `import Markup.Node` | `import HtmlIr.Node` | |
| `import Markup.Kind` | `import HtmlIr.Kind` | |
| `Markup.Element.toNode` | `HtmlIr.Element.toNode` | |
| `Markup.Node.toHtml` | `HtmlIr.Node.toHtml` | |
| `M3e.Token.*` | `M3e.Values.*` | same token names; see §3 |
| `Value.Supported` | `HtmlIr.Kind.Supported` | |
| `Value.Value` | `HtmlIr.Value.Value` | |
| `M3e.style [("k","v")]` | `M3e.Attributes.styleList [("k","v")]` | name changed |
| `M3e.class "x"` | `M3e.Attributes.class "x"` | |
| `M3e.attrName`, `M3e.attrHref`, … | `M3e.Attributes.name`, `M3e.Attributes.href`, … | drop `attr` prefix, camelCase |
| `M3e.variantFilled` | `M3e.Attributes.variant M3e.Values.filled` | split setter + token |
| `M3e.sizeSmall` | `M3e.Attributes.size M3e.Values.small` | |
| `M3e.modeExpanded` | `M3e.Attributes.mode M3e.Values.expanded` | |
| `M3e.appBarSlotLeading el` | `M3e.AppBar.leading el` | per-component slot fn |
| `M3e.cardSlotHeader el` | `M3e.Card.header el` | |
| `M3e.cardSlotContent el` | `M3e.Card.content el` | |
| `M3e.slotIcon el` | `M3e.Button.icon el` (etc.) | |
| `M3e.onChange : Decoder msg` | `M3e.Events.onChange : msg` | **BREAKING** — see §6 |
| `M3e.onChange decoder` | `M3e.Events.onChangeWith decoder` | |
| `M3e.onClick msg` | `M3e.Events.onClick msg` | |
| `M3e.Native.*` | `TypedHtml.*` | native brand, closed rows |
| `Markup.M3e.text s` | `M3e.text s` | |
| `Seam.html h` | `Seam.fromHtml h` | renamed |
| Old `Seam.text` | `Seam.text` or `M3e.text` | same signature |
| `Markup.*.Internal` | `HtmlIr.Internal` | Seam building only |
| `elm-m3e` + `markup-core` | `elm-m3e/src` + `elm-foundation` | see §1 |

---

## Step-by-step

### Step 1 — Swap the vendor packages

**Old `source-directories` (app elm.json):**
```json
{
  "source-directories": ["src", "../../elm-m3e/src", "../../markup-core/src"]
}
```

**New `source-directories` (app elm.json):**
```json
{
  "source-directories": ["src", "../../elm-m3e/src", "../../elm-foundation/HtmlIr", "../../elm-foundation/TypedHtml"]
}
```

`elm-foundation` is the repo containing `elm-html-intermediate-representation`
and `elm-typed-html`. In the docs app we vendor this as
`docs/vendor/elm-foundation/` and add it as a single source-directory entry
pointing to `vendor/elm-foundation`.

The published package names are:
- `jackhp95/elm-html-intermediate-representation` — exposes `HtmlIr.*`
- `jackhp95/elm-typed-html` — exposes `TypedHtml.*`

Until these are on the Elm package registry, use `source-directories` vendoring.
Do **not** delete the `elm-m3e` source directory — it still holds all of
`M3e.*`.

Keep `elm-review-cem` — the review rules still apply and are the recommended
end-state (§7).

**Lamdera caveat:** `HtmlIr.Internal` imports `VirtualDom`. In a Lamdera
`source-directories` context that import resolves **only if `elm/virtual-dom` is
a direct dependency** — so promote it from `indirect` to `direct` in your
`elm.json` (a one-line change; verified on both animal-spirits and compass-social,
which compile the pristine `HtmlIr.Internal` unchanged). You do **not** need to
avoid `HtmlIr.Internal` or stub its maps — just keep the modules that import it
(`Seam`/`Native`) in a non-vendored app directory (e.g. your `src/`), never inside
the vendored trees. Once `elm-html-intermediate-representation` is published this
is moot (the import lives in the registry copy).

---

### Step 2 — Split the barrel imports

The old `M3e` module re-exported everything. The new `M3e` barrel exposes only:
- component constructors (`M3e.button`, `M3e.card`, …)
- `M3e.text`

Everything else moved:

| What you used from `M3e` | Now in |
|---|---|
| `class`, `id`, `slot`, `style`, `styleList` | `M3e.Attributes` |
| `attr*` (prefixed attribute setters) | `M3e.Attributes` (drop `attr` prefix) |
| `variant*`, `size*`, `mode*` (fused setters) | `M3e.Attributes` + `M3e.Values` token |
| `onChange`, `onClick`, `onInput`, … | `M3e.Events` |
| slot wrappers (`cardSlotHeader`, `slotIcon`, …) | `M3e.<Component>.<slotName>` |
| `aria-label` / accessibility attrs | `TypedHtml.Aria.*` (general a11y axis) |
| `M3e.Native.*` | `TypedHtml.*` |

Mechanical search strategy:

```
rg "M3e\.(attr|variant|size|mode|class|id|style|slot|on[A-Z])" --type elm
```

For each match:
- `M3e.attrFoo` → `M3e.Attributes.foo`
- `M3e.variantFoo` → `M3e.Attributes.variant M3e.Values.foo`
- `M3e.sizeFoo` → `M3e.Attributes.size M3e.Values.foo`
- `M3e.on*` → `M3e.Events.on*` (but read §6 first for `onChange`)
- `M3e.<component>Slot*` → `M3e.<Component>.<slot>`
- `M3e.slotIcon` → `M3e.Button.icon` (or the relevant component)

---

### Step 3 — Token namespace: `M3e.Token` → `M3e.Values`

Old:
```elm
import M3e.Token as Token
M3e.Attributes.variant Token.filled
```

New:
```elm
import M3e.Values as Values
M3e.Attributes.variant Values.filled
```

Token names are identical — only the module name changed. A project-wide
find-and-replace of `M3e.Token.` → `M3e.Values.` and `import M3e.Token` →
`import M3e.Values` is safe.

The type aliases `Value.Supported` and `Value.Value` also moved:

```elm
-- Old
import Value exposing (Supported, Value)

-- New
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
```

---

### Step 4 — Migrate from `Markup.*` to `HtmlIr.*`

#### Type annotations

The old single-phantom shape gains an `admittedBy` row:

```elm
-- Old
type alias Row msg =
    List (Markup.Element.Element { html : Markup.Kind.Brand } msg)

-- New
type alias Row adm_ msg =
    List (HtmlIr.Element.Element { html : M3e.Kind.Brand } adm_ msg)
```

Every `type alias`, function annotation, and `type` that mentions `Element` needs
the extra variable. If you leave it out the compiler reports an unbound type
variable.

#### Render exit

The two-step render idiom is the same shape, just different module names:

```elm
-- Old
Markup.Element.toNode >> Markup.Node.toHtml

-- New
HtmlIr.Element.toNode >> HtmlIr.Node.toHtml
```

Put this crossing in exactly one place — your app shell's `view` function or
equivalent. Route pages and components never call `toNode`/`toHtml` — they hand
`Element` values up to the shell.

#### `M3e.Kind.Brand`

The old `Markup.M3e.Kind.Brand` is now `M3e.Kind.Brand`. If your `Native` or
`Kit` module stamped the html kind explicitly, update:

```elm
-- Old
Element { k | html : Markup.M3e.Kind.Brand } msg

-- New
Element { k | html : M3e.Kind.Brand } adm_ msg
```

---

### Step 5 — Migrate the Seam / Native / Kit adapters

These three modules are the **userland boundary** — the only place
`HtmlIr.Internal` is imported. The recommended path is to copy the reference
implementations from `docs/kit/` in this repo rather than hand-rolling them:

```
docs/kit/Seam.elm    ← the sanctioned IR crossings + text/link/label atoms + the `field` helper
docs/kit/Native.elm  ← ESCAPE-ONLY producers (node/custom/attribute/style/onClick) — NOT a tag vocabulary
docs/kit/Kit.elm     ← typography + app-specific atoms (optional)
```

**Produce plain elements with `TypedHtml.*`, not `Native.*`.** `Native.elm` is
deliberately **escapes-only** — `node` (dynamic/custom-element forge), `custom`,
`attribute`, `style`, `onClick`. For plain HTML tags use the typed producers
(`TypedHtml.div`/`.span`/`.label`/`.input`/…) — they carry **closed,
element-natural attribute rows** (safer than an open-row hand-rolled forge).
Re-forging a plain tag over `HtmlIr.Internal` when `TypedHtml.<tag>` exists is the
redundancy the **`NoRedundantElementForge`** review rule flags; see the
production-axis note for the rationale. `Seam.text`/`link`/`label` are thin atoms
built **on** `TypedHtml`, not on `HtmlIr.Internal`.

**Form fields:** use the one shared **`Seam.field id { labelContent, control }`**
helper — a native `<label for=id>` and the control (`<input id=id>`) as
**siblings in `m3e-form-field`'s default slot** (structural association; the
browser's `for`/`id` match wires them). It supersedes the per-app
`fieldLabel`/`fieldControl` helpers that feedback-fab / compass-social /
animal-spirits each hand-rolled.

Key API changes from the old `markup-core` Seam:

| Old | New |
|-----|-----|
| `Seam.html h` | `Seam.fromHtml h` |
| `Seam.text s` | `Seam.text s` (same) or `M3e.text s` |
| `Markup.*.Internal` imports | `HtmlIr.Internal` |
| (no `recast`) | `Seam.recast` — explicit phantom-row coercion |
| (no `recastAttr`) | `Seam.recastAttr` |
| (no `asAttribute`) | `Seam.asAttribute` — raw `Html.Attribute` into `Attr` |

The `Seam.recast` function is the general loud coercion — use it when a child's
kind row does not unify with a slot but you know it is semantically valid. It is
greppable by design and restricted to the allowed-modules list in the review
config.

`M3e.FormField` wraps whatever you put in its **default slot** and styles it — it
has no `label` slot of its own (the real CEM slots are `prefix`/`prefix-text`/
`suffix`/`suffix-text`/`hint`/`error` plus the default). Associate a label with
its control the standard HTML way: a native `<label for="x">` and the control's
`<input id="x">` as **siblings in the default slot**. The browser's `for`/`id`
match wires them; the form field styles the pair. There is no
`M3e.FormField.label` slot function — the old idWiring that auto-stamped
`for=`/`id=` was removed as redundant with native structural association.

Build the label with your `Native` producers so it stays in the phantom substrate
(no seam crossing), then `Seam.recast` to unify the label's row into the control
list:

```elm
M3e.formField []
    [ Native.label [ Native.attribute "for" "email" ] [ M3e.text "Email" ]
        |> Seam.recast
    , M3e.textField [ M3e.Attributes.id "email" ] []
    ]
```

`Native.label` pins the element to `{ html : Brand }`; that row does not unify
with the form field's default-slot list element, so `Seam.recast` coerces it in
(loud + greppable, restricted to the allowed-modules list — as designed).

---

### Step 6 — `onChange` — the sharp edge

> **This is the most dangerous change.** It compiles cleanly after a naive rename
> and then silently misbehaves at runtime.

**Old** — `M3e.onChange` took a `Decoder msg`:

```elm
M3e.onChange (Json.Decode.at ["target","value"] Json.Decode.string |> Json.Decode.map GotInput)
```

**New** — the split:

```elm
-- Bare message (ignores the event payload entirely)
M3e.Events.onChange GotInput

-- With a decoder (the correct replacement for the old form)
M3e.Events.onChangeWith
    (Json.Decode.at ["target","value"] Json.Decode.string |> Json.Decode.map GotInput)
```

If you replace `M3e.onChange decoder` with `M3e.Events.onChange decoder` the
compiler accepts it (a `Decoder msg` unifies as a `msg` via inference), but the
event handler fires `decoder` as a bare message — the decoder is never run and
your `msg` value will be wrong at runtime.

**Migration rule:** every old `M3e.onChange <expr>` must become
`M3e.Events.onChangeWith <expr>`. Only use `M3e.Events.onChange <msg>` where the
event payload is irrelevant to the message.

The same split applies to other `*With` pairs in `M3e.Events`:
`onInputWith`, `onClickWith`, `onToggleWith`, `onValueChangeWith`, etc.

---

### Step 7 — Adopt the elm-review-cem rules (recommended end state)

The review rules enforce the guarantees the compiler cannot: missing required
content, duplicate singular attrs, and — critically — that `HtmlIr.Internal` is
only imported inside your declared seam modules.

The `jackhp95/elm-review-cem` package ships two composable presets that cover
both jobs. `Cem.all` returns the whole facts-driven CEM discipline (valid enum
values, required slots, singular slots/attrs, required attributes, slot kinds,
component-module preference); `Cem.fences` returns the three boundary rules
(`HtmlIr.Internal` containment, the seam boundary, and no-redundant-forge). Both
take the generated review **facts** — `M3e.Review.Facts.facts` for the brand,
`TypedHtml.Review.Facts.facts` for the native tags.

Add to your `review/src/ReviewConfig.elm`:

```elm
import Cem
import M3e.Review.Facts
import Review.Rule exposing (Rule)
import TypedHtml.Review.Facts


config : List Rule
config =
    -- The full CEM discipline (required content, slot kinds, enum narrowing):
    Cem.all M3e.Review.Facts.facts
        -- The boundary fences (Internal containment, seam gate, no redundant forge):
        ++ Cem.fences
            { brandRoots = [ "M3e" ]
            , seamModules = [ "Seam" ]
            , allowedModules = [ "Seam", "Native", "Kit" ]
            , typedHtmlFacts = TypedHtml.Review.Facts.facts
            }
```

`M3e.Review.Facts` is generated alongside `src/M3e/*` and lives at
`src/M3e/Review/Facts.elm` (exposing `facts`); `TypedHtml.Review.Facts` comes
with the vendored `elm-typed-html` foundation. They feed the `Cem.*` rules with
per-component metadata (required slots, enum sets, slot kinds).

> The individual rules are exposed too (`Cem.validEnumValue`, `Cem.requireSlot`,
> `Cem.validSlotKindWith Cem.Lenient`, `Cem.preferBarrel`, …) if you want to
> hand-assemble a config instead of taking the `Cem.all` preset wholesale.

See `review/src/ReviewConfig.elm` in this repo for a complete working example
(it hand-assembles the rules and swaps in `Cem.preferBarrel`).

---

## Gotchas

### `onChange` silent break (see §6)

`M3e.Events.onChange : msg` — a bare value. The old `M3e.onChange : Decoder msg`
took a decoder. `M3e.Events.onChange myDecoder` compiles and silently never runs
the decoder. Always use `onChangeWith` when you need the event payload.

### `M3e.FormField` has no label slot — use native association

The form field has no `label` slot function; associate a label the standard HTML
way — a native `<label for="x">` sibling to the control's `<input id="x">` in the
default slot (see §5). The old idWiring that auto-stamped `for=`/`id=` was removed
as redundant with native structural association.

### Accessible names come from `TypedHtml.Aria.label`, not a per-brand setter

`aria-label` is a global HTML attribute — set it via the shared a11y axis
`TypedHtml.Aria.label "…"`, not a per-component m3e setter (m3e deliberately does
**not** re-export it; there is no `M3e.Attributes.ariaLabel`). Icon-only `M3e.fab`
and `M3e.iconButton` **require** an accessible name, and the `elm-review-cem`
`Cem.missingRequiredAttribute` rule enforces this — it recognizes only the
`TypedHtml.Aria.*` axis, so satisfy the requirement there.

### Lamdera + vendored `HtmlIr.Internal`

`HtmlIr.Internal` imports `elm/virtual-dom`. Under Lamdera that import resolves in
vendored `source-directories` only when `elm/virtual-dom` is a **direct**
dependency — promote it in `elm.json` (`indirect` → `direct`). Then keep the
modules that import `HtmlIr.Internal` (`Seam`/`Native`) in a non-vendored app
directory. No need to stub or avoid the real IR — animal-spirits and
compass-social both compile the pristine `HtmlIr.Internal` this way. Publishing
the IR packages to the registry makes this moot.

### Ambiguous `Seam.recast` — use it, don't scatter it

`Seam.recast` forges a fresh phantom row with no semantic check. It is intentionally
loud so it is greppable. If you need it in more than one place for the same
crossing, that crossing belongs in a named coercion in `M3e.Coerce` (config-driven)
or a dedicated helper in your `Seam` module — not scattered across view modules.

### `M3e.Attributes.style` vs `M3e.Attributes.styleList`

The old `M3e.style : List (String, String)` was a convenience for inline CSS
pairs. The new module has:

- `M3e.Attributes.style : String -> Attr …` — takes the full inline-style
  **string** (e.g. `"--my-token: red; color: blue"`).
- `M3e.Attributes.styleList : List (String, String) -> Attr …` — the list-of-pairs
  form that matches the old `M3e.style` signature.

If you used `M3e.style [("--token", "value")]` before, replace with
`M3e.Attributes.styleList [("--token", "value")]`.

### `M3e.Native` is retired — use `TypedHtml.*`

The old `M3e.Native` generated facade is gone. The replacement is
`TypedHtml.*` — a sibling branded package with closed, element-natural attribute
rows. Note that the attribute-narrowing strictness differs: the generated
`TypedHtml.Div` would not accept `href`, while the hand-written `Native.div` in
the reference kit uses open capability rows. If you need the strict shape use
`TypedHtml.*` directly; if you want the relaxed open shape, copy the `Native.elm`
from `docs/kit/`.

### Icon names are free strings — use `M3e.Icon.name`, not `M3e.Attributes.name`

Material icon names are arbitrary strings, but the two `name` setters differ:

- `M3e.Icon.name : String -> Attr …` — the per-component setter. **This is the
  one to use for icon names** (it takes a plain `String`), e.g.
  `M3e.icon [ M3e.Icon.name "home" ] []`.
- `M3e.Attributes.name : Value M3e.Values.Name -> Attr …` — the general-surface
  setter closes over the library-wide **enum** union (`M3e.Values.Name`), so it
  will **not** accept a free string — `M3e.Attributes.name "home"` is a
  compile error (`String` vs `Value M3e.Values.Name`).

So set icon names via `M3e.Icon.name "home"` (the idiom the docs app and every
migrated consumer use). `TypedHtml.Attributes.name "home"` is the equivalent raw
string setter on the native axis if you are building a native element.

### `Element` now has two phantom rows — thread `admittedBy` everywhere

The compiler error is typically `unbound type variable` on `adm_` or a
type-mismatch where `Element accepts msg` was expected. Add `admittedBy` (or
`adm_` if unconstrained) as the second type parameter everywhere `Element`
appears in your annotations, `type alias` definitions, and `type` wrappers.
