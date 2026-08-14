# Two-Tier Enum Safety

elm-m3e enforces enum-value correctness at **two tiers**, each with a distinct
mechanism. Understanding which tier applies prevents confusion when a value token
appears to "work" on one surface but not another.

## The problem

Enum attributes like `variant` accept different value sets per component: a
`Theme` accepts `"rainbow"` but a `Button` and `SplitButton` do not. A library
that exposes a single shared `variant` setter with one value set would accept
wrong-component tokens silently.

## Tier 1 — Compile-time (strict surfaces)

`M3e.Component.*` and `M3e.Build.*` setters narrow the value type to a
**closed row** specific to that component:

```elm
-- M3e.Component.Theme.variant    : Value Theme.Variant   -> Attr { c | variant : Supported } msg
-- M3e.Component.SplitButton.variant : Value SplitButton.Variant -> Attr { c | variant : Supported } msg

Theme.Variant = { content, expressive, fidelity, fruitSalad, monochrome,
                  neutral, rainbow, tonalSpot, vibrant, … }

SplitButton.Variant = { elevated, filled, outlined, tonal }
```

Passing `M3e.Values.rainbow` — a valid Theme token — to `SplitButton.variant`
produces a **TYPE MISMATCH** at compile time, because the open-rowed token
`Value { v | rainbow : Supported }` does not extend SplitButton's closed
`Variant` row which lacks the `rainbow` field.

The same narrowing holds in the builder surface:

```elm
-- M3e.Build.Button.withVariant : Value Button.Variant -> Builder … -> Builder …
-- Button.Variant = { elevated, filled, outlined, text, tonal }

Button.build { … }
    |> Button.withVariant M3e.Values.rainbow  -- TYPE MISMATCH: rainbow not in Button.Variant
```

**Regression fixtures** for this behavior live in:

- `tests/spike/app/EnumNarrowingOk.elm` — must-compile cases
- `tests/spike/bad/EnumNarrowingSplitButton.elm` — must-fail: rainbow into SplitButton
- `tests/spike/bad/EnumNarrowingBuilder.elm` — must-fail: rainbow into Button builder

Run `npm run check:spike` to verify both tiers are intact after any change.

## Tier 2 — elm-review (loose surface)

`M3e.Attributes.variant` (the shared loose setter) accepts
`Value M3e.Values.Variant` — the **global closed union** of ALL variant tokens
across ALL components. This is intentional: it enables single-import ergonomics
without a per-component switch. The downside is that `MA.variant MV.rainbow`
type-checks even on a `Button`, which does not accept `"rainbow"`.

The backstop here is the `Cem.ValidEnumValue` elm-review rule
(`elm-review-cem/src/Cem/ValidEnumValue.elm`). It consumes the generated
`M3e.Review.Facts.facts` (a `List Cem.Facts.Fact`) which carries, per
component, which tokens each enum setter admits. Any loose-surface setter given
a value the target component does not accept is flagged at CI time.

Run `npm run check:review` to verify the rule is active and green.

## Which surface to use

| Situation | Recommended surface | Enforcement |
|-----------|---------------------|-------------|
| Need the compiler to reject wrong tokens now | `M3e.Component.*` or `M3e.Build.*` setter | Compile-time type error |
| Fine with a single import, elm-review will catch misuse | `M3e.Attributes` setter | `Cem.ValidEnumValue` at CI |
| Portmanteau shorthand (e.g. `A.variantFilled`) | `M3e.Attributes` portmanteau | Same `Cem.ValidEnumValue` backstop |

## Note on generated docstrings

The generated `M3e.Component.*` and `M3e.Values` module docstrings are produced
by `elm-cem` from the CEM manifest. If a docstring on a generated module should
reference the two-tier model, the change must go into the generator (the
relevant template in `elm-cem/codegen/Generate/Phantom/Emit.elm` or its doc
helpers), not into `elm-m3e/src/` directly (which is drift-gated). This guide
is the non-generated canonical home for the two-tier explanation.
