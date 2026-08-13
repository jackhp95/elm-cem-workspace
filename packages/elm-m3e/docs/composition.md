# Composition guide

How to build real UI out of the `elm-cem` family — `M3e.*`, the
[`TypedHtml.*`](https://github.com/jackhp95/elm-typed-html) native substrate,
and the shared `HtmlIr.*` core — **without dropping to plain `Html`**.

Heterogeneous, cross-brand composition already works. The types were designed
for it; this guide shows the shapes so you reach for them instead of reflexively
escaping to `elm/html`.

Every code block below is trimmed from a single `Main.elm` that compiles against
the published packages.

---

## 1. Heterogeneous children compose directly

A permissive slot accepts a *mix* of kinds. Put a heading, a bare text node, and
a button in one card — it type-checks:

```elm
M3e.card []
    [ M3e.heading [] [ M3e.text "Title" ]
    , M3e.text "body"
    , M3e.button [] [ M3e.text "Go" ]
    ]
```

### The mental model

Each element carries a phantom **`accepts`** row describing what kind it *is*,
and a child list is admitted through the parent's slot. A permissive slot (like
a card's default slot) leaves the child's `accepts` row **open** — an open row
unifies with any concrete kind, so mixed children all fit the same list.

That openness is a feature, not a hole. **Restrictive slots correctly reject
foreign kinds.** A heading's slot is text-only:

```elm
M3e.heading [] [ M3e.text "Just text" ]   -- fine
```

```elm
-- does NOT compile — a heading's text-only slot refuses a button:
M3e.heading [] [ M3e.button [] [ M3e.text "no" ] ]
```

The compiler error there is the safety working, not a limitation. Permissive
where the spec is permissive; strict where the spec is strict.

---

## 2. Layout uses the typed native producers, not `Html.div`

For layout, reach for `TypedHtml.div` / `span` / `section` / … from the
[`jackhp95/elm-typed-html`](https://github.com/jackhp95/elm-typed-html) package.
These are on the **same typed substrate** as `M3e.*`, so they take mixed children
directly — including `M3e.*` elements. There is no need to render each child with
`toHtml` and re-wrap in `Html.div`:

```elm
TypedHtml.div
    [ TypedHtml.Attributes.class "flex" ]
    [ M3e.heading [] [ M3e.text "Title" ]
    , M3e.text "body"
    , M3e.button [] [ M3e.text "Go" ]
    ]
```

`M3e` components and `TypedHtml` native elements are the same kind of value
(`HtmlIr.Element`), so they nest in either direction with no bridge. You only
call `toHtml` **once**, at the very top (see §6).

---

## 3. List form vs. builder form

Every component offers two equivalent shapes.

**List form** — `view [attrs] [children]`, the general surface:

```elm
M3e.card []
    [ M3e.heading [] [ M3e.text "Title" ]
    , M3e.text "body"
    ]
```

**Builder form** — `build |> withChild … |> toElement`, from the per-component
module, for when a pipeline reads better (or you need a named-slot setter that
consumes its capability once):

```elm
M3e.Card.build
    |> M3e.Card.withChild (M3e.heading [] [ M3e.text "Title" ])
    |> M3e.Card.withChild (M3e.text "body")
    |> M3e.Card.toElement
```

### Dropping a pre-built element into the list form

If you already hold a built element and want it in the **default slot** of the
list form, wrap it with the per-component `child`. It is the list-form sibling of
the builder's `withChild`:

```elm
M3e.card []
    [ M3e.text "body"
    , M3e.Card.child preBuilt
    ]
```

where `preBuilt = M3e.button [] [ M3e.text "Go" ]`. `child` narrows its input to
the slot's kinds and hands back a free row so it slots into the child list.

---

## 4. Forms: typed native controls + accessible label/control pairing

`TypedHtml` ships the native form controls with **payload-typed** events — the
handler receives the value directly (like `elm/html`), no decoder needed:
`onInput` / `onChange : (String -> msg)` and `onCheck : (Bool -> msg)`. The `Msg`
constructors are taggers over the payload (`Typed : String -> Msg`,
`Chose : String -> Msg`, `Toggled : Bool -> Msg`):

```elm
TypedHtml.div []
    [ TypedHtml.input
        [ TypedHtml.Attributes.type_ "text"
        , TypedHtml.Attributes.placeholder "Name"
        , TypedHtml.Events.onInput Typed
        ]
        []
    , TypedHtml.input
        [ TypedHtml.Attributes.type_ "checkbox"
        , TypedHtml.Events.onCheck Toggled
        ]
        []
    , TypedHtml.select
        [ TypedHtml.Events.onChange Chose ]
        [ TypedHtml.option [] [ TypedHtml.text "One" ] ]
    ]
```

For a non-standard payload, `onInputWith` / `onChangeWith` / `onCheckWith` take a
`Json.Decode.Decoder msg`.

For the accessible `<label for>` ↔ control association, use the native pattern:
a `label` carrying `for` next to a control carrying the matching `id`. The `for`
must match the control's `id` — keep them in sync so the two cannot drift apart:

```elm
TypedHtml.label [ TypedHtml.Attributes.for "email" ] [ TypedHtml.text "Email" ]
TypedHtml.input
    [ TypedHtml.Attributes.id "email"
    , TypedHtml.Attributes.type_ "email"
    ]
    []
```

The id is caller-supplied by design — Elm is pure, so there is no auto-generated
id. You supply a stable id, set it on the control, and reference the same id in
the label's `for`.

---

## 5. Escapes are for genuine `Html` only

The `Unsafe` module (`M3e.Unsafe` / `TypedHtml.Unsafe`, same API on every brand
barrel) exists for **real** `Html`: caller-supplied content, or a chunk you are
migrating incrementally.

- `fromHtml : Html msg -> Element …` — wrap raw `elm/html` you genuinely have.
- `coerce : Element … -> Element …` — re-kind an element to a free row.
- `coerceAll : List (Element …) -> List (Element …)` — `coerce` over a list.

```elm
TypedHtml.div []
    [ TypedHtml.Unsafe.fromHtml rawHtml          -- genuinely raw Html
    , M3e.text "genuinely typed content needs no escape"
    ]
```

These are loud on purpose: every use site is a grep target. **Do not** reach for
`coerce` to force something that is *already* a typed `Element` into a slot — if
it is already typed, compose it directly (§1, §2). The
[`elm-review-cem`](https://github.com/jackhp95/elm-review-cem) rule
**`NoRedundantElementEscape`** flags exactly that: escaping something the type
system already accepts.

---

## 6. Render exit: `toHtml`

Convert to `elm/html` **once**, at the boundary where your `view` hands off to
the Elm runtime. `toHtml` is on every brand barrel:

```elm
main =
    Html.div []
        [ M3e.toHtml card
        , TypedHtml.toHtml layout
        ]
```

Everything above `toHtml` stays on the typed substrate; you do not thread
`Html.Html` through your view and you do not re-wrap. Compose typed, exit once.

---

## The one-import summary

| You want… | Reach for |
|---|---|
| A Material 3 component | `M3e.card`, `M3e.button`, … (list form) or `M3e.Card.build …` (builder) |
| A native layout/text element | `TypedHtml.div` / `span` / `section` / … |
| Mixed children in one slot | just put them in the list — permissive slots unify |
| A pre-built element in the default slot | `M3e.Card.child element` |
| A typed form control | `TypedHtml.input` / `textarea` / `select` + `TypedHtml.Events` |
| An accessible label↔control pair | `TypedHtml.label [ ...for "x" ]` + control with `...id "x"` |
| To embed genuine raw `Html` | `TypedHtml.Unsafe.fromHtml` (loud, greppable) |
| To render to `elm/html` | `M3e.toHtml` / `TypedHtml.toHtml`, once, at the top |
