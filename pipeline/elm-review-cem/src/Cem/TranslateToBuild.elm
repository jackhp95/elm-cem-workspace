module Cem.TranslateToBuild exposing (rule)

{-| Opt-in autofix: rewrite a per-component Standard call
`<root>.<Comp>.<slug> attrs children` (slug = whole-word-lowercased component
segment, e.g. `M3e.Component.Button.button`) to the phantom-typed builder pipeline
`<buildRoot>.<Comp>.build <required?> |> <buildRoot>.<Comp>.withX … |> <buildRoot>.<Comp>.toElement`,
driven by `Cem.Facts`. The Build surface lives in a SEPARATE module — the
component namespace's intermediate segment is swapped for `Build`
(`M3e.Component.Button` → `M3e.Build.Button`). Every component emits a
`build`/`toElement` pair, so this applies to all of them (130 in elm-m3e) —
unlike `TranslateToRecord`.

It is the surface companion of `PreferBarrel` — NOT part of `Cem.all`; it exists
so a docs harness (or a consumer who prefers the pipe form) can rewrite a Standard
example with `elm-review --fix`.

The rewrite:

  - seeds `build` with the required record (identical to the `component` record —
    see `Cem.TranslateToRecord`) when the component HAS one (its `facts` list the
    `Record` facet); otherwise `build` takes no argument;
  - turns every residual attr into a `withX` pipe stage (`variant v` →
    `withVariant v`, `onClick m` → `withOnClick m`, `type_ t` → `withType t`);
  - turns every residual child into a slot pipe stage (a default child →
    `withChild body`, a named-slot setter → its `withX` form);
  - closes with `toElement`.

The rewrite fires only when the whole call is statically resolvable (literal
attr/child lists) AND every residual attr/child resolves to a known
per-component setter; otherwise it stays silent. It is a single-pass fixpoint —
its output uses `build`/`withX`/`toElement`, never the Standard slug, so
re-running the rule matches nothing.


## Facts gaps (blockers for the docs pipeline / package 2)

  - **The `withX` pipe-setter names are NOT carried in the facts.** This rule
    reconstructs them by convention — `with` + capitalised setter name, dropping a
    trailing keyword underscore (`type_` → `withType`), with a `Slot` suffix when a
    slot setter's name collides with an attr setter of the same base (`selected`
    slot → `withSelectedSlot`, since `selected` is also an attr → `withSelected`).
    This convention is inferred from the generated code, not verified against it;
    any component whose generated `withX` naming departs from it (or has a
    collision the facts can't reveal) would be mis-rewritten. For guaranteed-correct
    generation, the facts should carry an explicit attr-setter → `withX` and
    slot-setter → `withX` map. Until then, prefer running this only where the
    convention is known to hold, or validate the output by compiling it.
  - A component requiring `aria-label` (`fab`, `iconButton`) is skipped for the
    same reason as `TranslateToRecord` (the `ariaLabel` field is unsourceable).
  - Any residual attr/child that does not resolve to a per-component setter (e.g. a
    generic `class`/`id` set through another module) makes its `withX` name unknown,
    so the whole call is left untouched.
  - `build`/`toElement`/`withChild` and the `<root>.Action` module/`none`
    constructor are treated as fixed library conventions (not in the facts).

@docs rule

-}

import Cem.Facts exposing (Fact)
import Cem.Internal.Translate as Translate
import Review.Rule exposing (Rule)


{-| Build the rule from the generated facts (`Cem.Facts`).
-}
rule : List Fact -> Rule
rule =
    Translate.rule Translate.ToBuild
