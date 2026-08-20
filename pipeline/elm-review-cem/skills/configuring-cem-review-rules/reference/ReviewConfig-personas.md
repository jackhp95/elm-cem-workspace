# Annotated ReviewConfig.elm for three personas

Three complete `review/src/ReviewConfig.elm` files, one per consumer persona. All
use a neutral generated library namespace (`Lib`, with adapter layers `Kit` /
`Layout` / `Native`) so nothing here assumes a specific design system. Substitute
your own generated library's namespace and its `Review.Facts` module.

Every config depends on `jackhp95/elm-review-cem` in `review/elm.json` and imports
the generated, unexposed facts module (here `Lib.Review.Facts`) that `elm-cem`
emitted alongside the library.

Contents:
- [Persona 1: strict app](#persona-1-strict-app)
- [Persona 2: barrel-style app (autofix direction)](#persona-2-barrel-style-app-autofix-direction)
- [Persona 3: library with seams](#persona-3-library-with-seams)

## Persona 1: strict app

An app that lives at the standard form and wants the maximum facts-driven
signal, including strict slot-kind checking. No autofix pair.

```elm
module ReviewConfig exposing (config)

import Cem
import Lib.Review.Facts
import Review.Rule exposing (Rule)


config : List Rule
config =
    -- Strict flags unresolvable slot children (let-bound, List.map, helper
    -- returns). Only adopt Strict if this app keeps slot children inline.
    Cem.allWith { validSlotKind = Cem.Strict } Lib.Review.Facts.facts
        -- ++ your own project rules
```

If the strict-slot noise is not wanted, use `Cem.all Lib.Review.Facts.facts`
instead (identical set, `validSlotKind = Lenient`).

## Persona 2: barrel-style app (autofix direction)

If the goal is "barrel style everywhere", enable `preferBarrel` and drop
`preferComponentModules` (which points the opposite way and ships inside
`Cem.all`). Since `all` bundles `preferComponentModules`, list the à-la-carte
rules explicitly instead of `all`. Run `elm-review --fix` once to converge, then
keep `preferBarrel` as the standing direction if you want barrel style enforced:

```elm
config : List Rule
config =
    let
        facts =
            Lib.Review.Facts.facts
    in
    -- Barrelise: preferBarrel up, and DO NOT also run preferComponentModules
    -- (the inverse). Run --fix once, then keep preferBarrel as the standing
    -- direction if you want barrel style enforced going forward.
    [ Cem.preferBarrel facts
    , Cem.validEnumValue facts
    , Cem.requireSlot facts
    , Cem.singularSlot facts
    , Cem.singularAttribute facts
    , Cem.missingRequiredAttribute facts
    , Cem.missingRequiredSingularSlot facts
    , Cem.validSlotKind facts
    ]
```

Note that this hand-rolled list is `Cem.all` minus `preferComponentModules` plus
`preferBarrel` — the two are inverses, so exactly one direction is present.

## Persona 3: library with seams

A library (or a large app with adapter layers) that both runs the facts-driven
set AND enforces the opaque-IR boundary: rendered residue crosses back to raw
`Html` only through one seam module, and interior `*.Internal` modules stay
private. The seam rules keep their top-level names and take **module-name lists,
not facts**.

```elm
module ReviewConfig exposing (config)

import Cem
import ExtractToSeam
import Lib.Review.Facts
import NoInternalImportOutsideAllowed
import NoSeamOutsideAllowedModules
import Review.Rule exposing (Rule)


config : List Rule
config =
    let
        facts =
            Lib.Review.Facts.facts

        -- Modules whose functions are seam escapes (the seam module itself +
        -- any internal stamper layer). Must be non-empty.
        seamModulesList =
            [ "Seam", "Seam.Internal" ]

        -- Modules allowed to CALL seam functions (the adapters + the seam
        -- module itself). Matched on dot boundaries: "Kit" also allows
        -- "Kit.Surface".
        seamHolders =
            [ "Seam", "Kit", "Layout", "Native" ]

        -- Module-name prefixes allowed to import a *.Internal module: the
        -- generated library namespace plus the adapter layers.
        internalImporters =
            [ "Lib", "Seam", "Kit", "Layout", "Native" ]
    in
    Cem.all facts
        ++ [ NoSeamOutsideAllowedModules.rule
                { seamModules = seamModulesList
                , allowedModules = seamHolders
                }
           , NoInternalImportOutsideAllowed.rule internalImporters

           -- Opt-in autofix companion to the gate: lifts each flagged Seam.*
           -- escape into "Seam" and rewrites the call site. Its allowedModules
           -- must match the gate's, so it only rewrites escapes the gate flags.
           , ExtractToSeam.rule
                { seamModule = "Seam"
                , allowedModules = seamHolders
                }
           ]
```

Wiring checks for this persona:
- The seam rules take **strings**, never `facts`. Passing `facts` to them is a
  type error.
- `ExtractToSeam`'s `allowedModules` should equal the gate's `allowedModules` so
  the autofix targets exactly the escapes the gate would flag.
- Allow-list entries are dotted-name prefixes matched on dot boundaries — list
  the roots (`"Kit"`), not every submodule.
