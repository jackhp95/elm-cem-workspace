module Cem.TranslateToRecord exposing (rule)

{-| Opt-in autofix: rewrite a per-component Standard call
`<root>.<Comp>.<slug> attrs children` (slug = whole-word-lowercased component
segment, e.g. `M3e.Component.Button.button`) to the required-record form
`<root>.<Comp>.component { <requiredFields> } attrs children`, hoisting the
required fields out of the children/attrs per `Cem.Facts`.

It is the surface companion of `PreferBarrel` — NOT part of `Cem.all`; it exists
so a docs harness (or a consumer who prefers the record form) can rewrite a
Standard example with `elm-review --fix`.

Applies ONLY to the components that HAVE a `component`/required record (those
whose `facts` list the `Record` facet — 29 in elm-m3e). It is a clean no-op for
every other component.

The record is reconstructed from the facts:

  - one field per `requiredSlots` entry — `unnamed` → `content`, every other slot
    → its camelCase name (`header`, `label`, `input`, `leadingButton`, …) — whose
    value is hoisted out of the children (the default-slot filler, or the child
    whose head is that slot's setter);
  - an `action` field when `fact.usesAction`, hoisted from the first `actionMap`
    setter in the attrs (`onClick` → `<root>.Action.onClick msg`, `href` →
    `<root>.Action.link url`) or defaulted to `<root>.Action.none` when no action
    setter is present. The fix adds `import <root>.Action` when needed.

Everything not hoisted stays verbatim in the `component` call's attrs/children
lists.

The rewrite fires only when the whole call is statically resolvable (literal
attr/child lists, every required slot located); otherwise it stays silent. It is
a single-pass fixpoint — its output uses `component`, never the Standard slug, so
re-running the rule matches nothing.


## Facts gaps (blockers for the docs pipeline / package 2)

  - Components whose required record carries `ariaLabel : String` (`fab`,
    `iconButton` — those with `"aria-label"` in `requiredAttrs`) are skipped: the
    `aria-label` string has no setter on the Standard surface, so the field
    cannot be sourced. Generating their record surface needs either a facts entry
    naming the Standard-surface aria-label source, or authored record examples.
  - The `unnamed`-slot default setter (`child`), the record constructor
    (`component`) and the root-level `Action` module/`none` constructor are
    treated as fixed library conventions (not carried in the facts), matching how
    `PreferBarrel` hardcodes the Standard/aria names.

@docs rule

-}

import Cem.Facts exposing (Fact)
import Cem.Internal.Translate as Translate
import Review.Rule exposing (Rule)


{-| Build the rule from the generated facts (`Cem.Facts`).
-}
rule : List Fact -> Rule
rule =
    Translate.rule Translate.ToRecord
