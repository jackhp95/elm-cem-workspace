module Cem exposing
    ( all, allWith
    , Unresolved(..)
    , validEnumValue, requireSlot, singularSlot, singularAttribute
    , missingRequiredAttribute, missingRequiredSingularSlot, preferComponentModules
    , validSlotKind, validSlotKindWith
    , validComposition, validCompositionWith, CompositionConfig, defaultCompositionConfig
    , preferBarrel, preferBarrelWith, preferComponentSetters
    , translateToRecord, translateToBuild
    , redundantElementEscape
    , redundantAttributeEscape
    , requireFormFieldLabel
    , requireFabLabel
    , fences
    , noMergedPipeAndSetter
    , noFamilyMemberDrift
    )

{-| Codegen-aware, namespace-agnostic `elm-review` rules driven by a generated
`List Cem.Facts.Fact`.

A code generator (e.g. `elm-cem`) emits the facts into an unexposed module of
the generated component library; your review config imports that value and hands
it to these rules. Because the facts carry each component's fully-qualified
Standard `module_`, the rules derive the library's root namespace themselves —
nothing here is tied to any particular library. Facts from several libraries can
be concatenated (`M3e.Review.Facts.facts ++ TypedHtml.Review.Facts.facts`); every
rule groups them by namespace, so each library's components are checked.


## The default bundle

`all` runs every non-opt-in rule with lenient defaults; `allWith` lets you pick
the `ValidSlotKind` posture (e.g. `Strict` to flag unresolvable children).

@docs all, allWith
@docs Unresolved


## Individual advisory / correctness rules

Each takes the generated facts and can be enabled on its own (or omitted from
`all`).

@docs validEnumValue, requireSlot, singularSlot, singularAttribute
@docs missingRequiredAttribute, missingRequiredSingularSlot, preferComponentModules
@docs validSlotKind, validSlotKindWith


## Relational composition rule

The ancestor/descendant complement to `validSlotKind`'s direct-slot membership:
interactive-content-descendant at arbitrary depth, `label` single-labeled-control,
ARIA required-context, and the SVG-AAM no-role-on-non-rendered overlay. HARD posture
for the WHATWG content-model families, WARN for the ARIA/SVG-AAM ones.

@docs validComposition, validCompositionWith, CompositionConfig, defaultCompositionConfig


## Opt-in barrel autofix

@docs preferBarrel, preferBarrelWith, preferComponentSetters


## Opt-in Standard→surface translators

Rewrite a per-component Standard `component` call to another surface of the same
component module, with autofix. Opt-in transforms for a docs harness; not part of
`all`.

@docs translateToRecord, translateToBuild


## Opt-in escape-reflex backstop

@docs redundantElementEscape
@docs redundantAttributeEscape


## Opt-in accessible-name backstop

@docs requireFormFieldLabel
@docs requireFabLabel


## The seam/opaque-IR fence preset

@docs fences


## K5/#58 pipe/setter merge guard

@docs noMergedPipeAndSetter


## Family/component drift guard

@docs noFamilyMemberDrift

-}

import Cem.Facts exposing (Fact)
import Cem.MissingRequiredAttribute
import Cem.MissingRequiredSingularSlot
import Cem.PreferBarrel
import Cem.PreferComponentModules
import Cem.PreferComponentSetters
import Cem.RequireFabLabel
import Cem.RequireFormFieldLabel
import Cem.RequireSlot
import Cem.SingularAttribute
import Cem.SingularSlot
import Cem.TranslateToBuild
import Cem.TranslateToRecord
import Cem.ValidComposition
import Cem.ValidEnumValue
import Cem.ValidSlotKind
import NoFamilyMemberDrift
import NoInternalImportOutsideAllowed
import NoMergedPipeAndSetter
import NoRedundantAttributeEscape
import NoRedundantElementEscape
import NoRedundantElementForge
import NoSeamOutsideAllowedModules
import NoUnsafeImportOutsideAllowed
import Review.Rule exposing (Rule)
import Set exposing (Set)


{-| The default facts-driven rule set: every non-opt-in rule, wired with the
generated facts. Concatenate your own project-specific rules onto the result
(e.g. `++ Cem.fences {...}` for the boundary preset).

Excludes the opt-in barrel autofixes (`preferBarrel`, `preferComponentSetters`),
which are enabled à la carte.

-}
all : List Fact -> List Rule
all =
    allWith { validSlotKind = Lenient }


{-| How the `ValidSlotKind` rule treats a slot child whose kind can't be
resolved statically — `Lenient` (silent) or `Strict` (warn). Re-exported here so
a review config can name the posture without importing `Cem.ValidSlotKind`.

A child's kind is resolvable only when written as an inline `<root>.*` component
literal; `Strict` therefore warns on EVERY other child — `let`-bound values,
parameters, `List.map` output, and children returned by helpers (`viewRow row`)
— so treat it as a strict opt-in rather than a drop-in default.

-}
type Unresolved
    = Lenient
    | Strict


toRulePosture : Unresolved -> Cem.ValidSlotKind.Unresolved
toRulePosture posture =
    case posture of
        Lenient ->
            Cem.ValidSlotKind.Lenient

        Strict ->
            Cem.ValidSlotKind.Strict


{-| Like `all`, but with the `ValidSlotKind` posture chosen explicitly. Pass
`{ validSlotKind = Strict }` to make unresolvable slot children a warning.
-}
allWith : { validSlotKind : Unresolved } -> List Fact -> List Rule
allWith opts facts =
    [ validEnumValue facts
    , requireSlot facts
    , singularSlot facts
    , singularAttribute facts
    , missingRequiredAttribute facts
    , missingRequiredSingularSlot facts
    , preferComponentModules facts
    , validSlotKindWith opts.validSlotKind facts
    ]


{-| Flag a loose enum setter given a value token the target component rejects.
-}
validEnumValue : List Fact -> Rule
validEnumValue =
    Cem.ValidEnumValue.rule


{-| Flag a constructor whose content list omits a required-multi slot.
-}
requireSlot : List Fact -> Rule
requireSlot =
    Cem.RequireSlot.rule


{-| Flag a singular content slot filled more than once.
-}
singularSlot : List Fact -> Rule
singularSlot =
    Cem.SingularSlot.rule


{-| Flag an attribute setter used more than once on one call.
-}
singularAttribute : List Fact -> Rule
singularAttribute =
    Cem.SingularAttribute.rule


{-| Flag component calls missing a required HTML attribute.
-}
missingRequiredAttribute : List Fact -> Rule
missingRequiredAttribute =
    Cem.MissingRequiredAttribute.rule


{-| Flag Standard calls whose content list omits a required-singular slot.
-}
missingRequiredSingularSlot : List Fact -> Rule
missingRequiredSingularSlot =
    Cem.MissingRequiredSingularSlot.rule


{-| Prefer per-component setters over barrel shorthands, with autofix.
-}
preferComponentModules : List Fact -> Rule
preferComponentModules =
    Cem.PreferComponentModules.rule


{-| Flag a slot child whose kind the enclosing component's slot rejects (lenient
about statically-unresolvable children).
-}
validSlotKind : List Fact -> Rule
validSlotKind =
    Cem.ValidSlotKind.rule


{-| Like `validSlotKind`, but with an explicit `Unresolved` posture (`Strict`
warns on children whose kind can't be resolved statically).
-}
validSlotKindWith : Unresolved -> List Fact -> Rule
validSlotKindWith posture =
    Cem.ValidSlotKind.ruleWith (toRulePosture posture)


{-| The relational-composition rule's config (interactive/label/required-context/
SVG-AAM tables + per-family HARD/WARN posture). Re-exported so a review config can
extend `defaultCompositionConfig` without importing `Cem.ValidComposition`.
-}
type alias CompositionConfig =
    Cem.ValidComposition.Config


{-| The WHATWG + WAI-ARIA + SVG-AAM composition tables with the resolved posture
(interactive/label HARD, required-context/svg-aam WARN). A brand extends this with
its own component nouns.
-}
defaultCompositionConfig : CompositionConfig
defaultCompositionConfig =
    Cem.ValidComposition.defaultConfig


{-| Flag relational composition violations: an interactive-content descendant of a
`button`/`a`/`summary` at any depth, a `label` with a nested label or more than one
labelable control (both HARD, WHATWG); an ARIA required-context child with no
required-container ancestor, and a role/aria-roledescription on a non-rendered SVG
element (both WARN). Uses the default (WHATWG/ARIA/SVG-AAM) tables.
-}
validComposition : List Fact -> Rule
validComposition =
    Cem.ValidComposition.rule


{-| Like `validComposition`, but with an explicit `CompositionConfig` (a brand
extends `defaultCompositionConfig` with its own interactive nouns / required-context
role-map / posture).
-}
validCompositionWith : CompositionConfig -> List Fact -> Rule
validCompositionWith =
    Cem.ValidComposition.ruleWith


{-| Rewrite the strict component-module Standard layer to the flat barrel, with
autofix. Opt-in; not part of `all`.
-}
preferBarrel : List Fact -> Rule
preferBarrel =
    Cem.PreferBarrel.rule


{-| Like `preferBarrel`, but with an explicit set of value-token names the barrel
re-exposes flat (enabling the `<root>.Token.<token>` → `<root>.<token>` class).
-}
preferBarrelWith : Set String -> List Fact -> Rule
preferBarrelWith =
    Cem.PreferBarrel.ruleWith


{-| Upgrade a generic barrel slot setter (`<root>.slotLeading`) to the
component-specific barrel setter (`<root>.listItemSlotLeading`) inside a barrel
constructor, for compile-time slot-kind safety. Keeps the single barrel import.
Opt-in; the loose generic form is the teaching form, this is the precise
one. Not part of `all`.
-}
preferComponentSetters : List Fact -> Rule
preferComponentSetters =
    Cem.PreferComponentSetters.rule


{-| Rewrite a per-component Standard `<root>.Component.<Comp>.component attrs children` call to
the required-record form `<root>.Component.<Comp>.component { … } attrs children`, hoisting the
required fields out of the attrs/children with autofix. Applies only to the
components that expose a required record (the `component` ctor's leading-record arity); a clean no-op for the rest. Opt-in;
not part of `all`. See `Cem.TranslateToRecord` for the exact contract and its
facts gaps.
-}
translateToRecord : List Fact -> Rule
translateToRecord =
    Cem.TranslateToRecord.rule


{-| Rewrite a per-component Standard `<root>.Component.<Comp>.component attrs children` call to
the phantom-typed builder pipeline
`<root>.<Comp>.build … |> <root>.<Comp>.withX … |> <root>.<Comp>.toElement`, with
autofix. Opt-in; not part of `all`. See `Cem.TranslateToBuild` for the exact
contract and its facts gaps (notably that the `withX` setter names are
reconstructed by convention, not carried in the facts).
-}
translateToBuild : List Fact -> Rule
translateToBuild =
    Cem.TranslateToBuild.rule


{-| Flag the consumer-side "drop to plain Html" reflex: an escape
(`<Lib>.toHtml`, `<Lib>.Unsafe.recast`/`recastAll`/`fromHtml`, or a configured
`Seam.*` escape) wrapping a value a known family producer already returned as a
typed `Element`. Facts-driven and advisory (no autofix).

Opt-in — not in `Cem.all` and not in the `fences` preset. It needs the specific
`seamEscapes` names (which `fences` does not carry) and the family facts, and the
reflex it flags is consumer guidance rather than a boundary invariant, so a
project enables it à la carte:

    config =
        Cem.all M3e.Review.Facts.facts
            ++ [ Cem.redundantElementEscape
                    { seamEscapes = [ "Seam.fromHtml", "Seam.toElement" ] }
                    (M3e.Review.Facts.facts ++ TypedHtml.Review.Facts.facts)
               ]

-}
redundantElementEscape : { seamEscapes : List String } -> List Fact -> Rule
redundantElementEscape =
    NoRedundantElementEscape.rule


{-| Flag the attribute-side twin of the same reflex: a
`<Lib>.Unsafe.Attributes.customAttribute` / `fromHtmlAttribute` escape writing an
attribute (or wiring an event) that the typed layer already has a setter for.

Evidence-driven, and gated on soundness. A setter is only suggested when the
rule has SEEN its declaration in one of the shared setter modules
(`<root>.Attributes`, `<root>.Aria`, `<root>.Events`, derived per namespace),
AND the attribute is element-independent — `aria-*`/`role`, an HTML global
attribute, or an event. An element-specific name (`content`, `src`, `type`, a
brand's `variant`) is never matched, because the rule cannot see which element
the `Attr` lands on and a custom element's attribute namespace is disjoint from
HTML's. Report only, except for the one byte-identical boolean rewrite.

Opt-in for the same reasons as `redundantElementEscape`:

    config =
        Cem.all Lib.Review.Facts.facts
            ++ [ Cem.redundantAttributeEscape
                    { setterModules = []
                    , globalAttributes =
                        Lib.Review.Facts.globalAttributes
                            ++ TypedHtml.Review.Facts.globalAttributes
                    }
                    (Lib.Review.Facts.facts ++ TypedHtml.Review.Facts.facts)
               ]

-}
redundantAttributeEscape : { setterModules : List String, globalAttributes : List String } -> List Fact -> Rule
redundantAttributeEscape =
    NoRedundantAttributeEscape.rule


{-| Flag a form-field (`<root>.FormField`) wrapping a control that has no
discoverable accessible name — no `slot="label"` child (`<root>.FormField.label`),
no `aria-label`/`aria-labelledby`, and no `id` (the `<label for>` proxy).

Opt-in — NOT in `Cem.all`. `config.componentNoun` is YOUR brand's `fact.component`
value for the form-field tag (elm-cem's noun for `m3e-form-field` is `"formField"`)
— this package holds no brand's noun hardcoded, same pattern as `Cem.fences`'s
`brandRoots` or `Cem.redundantElementEscape`'s `seamEscapes`. The rule reasons
only about the Standard/barrel facet's static call structure; it deliberately
stays silent on anything it cannot fully resolve (so false positives are
engineered out at the cost of some false negatives). See
`Cem.RequireFormFieldLabel` for exactly what counts as accessibly named and the
static-analysis limitations.

    config =
        Cem.all M3e.Review.Facts.facts
            ++ [ Cem.requireFormFieldLabel { componentNoun = "formField" } M3e.Review.Facts.facts ]

-}
requireFormFieldLabel : { componentNoun : String } -> List Fact -> Rule
requireFormFieldLabel =
    Cem.RequireFormFieldLabel.rule


{-| Flag a FAB (`<root>.Fab`) that has no discoverable accessible name — no
`slot="label"` child (`<root>.Fab.label`, the extended-FAB label), no
`aria-label`/`aria-labelledby`, and no `id` (the `<label for>` proxy).

Opt-in — NOT in `Cem.all`. The library made `aria-label` optional on Fab at the
type level, so the accessible-name guarantee lives here instead.
`config.componentNoun` is YOUR brand's `fact.component` value for the FAB tag
(elm-cem's noun for `m3e-fab` is `"fab"`) — this package holds no brand's noun
hardcoded, same pattern as `Cem.fences`'s `brandRoots` or
`Cem.redundantElementEscape`'s `seamEscapes`. The rule reasons only about the
Standard/barrel facet's static call structure; it deliberately stays silent on
anything it cannot fully resolve (so false positives are engineered out at the
cost of some false negatives). See `Cem.RequireFabLabel` for exactly what counts
as accessibly named and the static-analysis limitations.

    config =
        Cem.all M3e.Review.Facts.facts
            ++ [ Cem.requireFabLabel { componentNoun = "fab" } M3e.Review.Facts.facts ]

-}
requireFabLabel : { componentNoun : String } -> List Fact -> Rule
requireFabLabel =
    Cem.RequireFabLabel.rule


{-| The canonical **seam / opaque-IR fence** preset — the three boundary rules a
generated-library consumer otherwise hand-rolls in a `CodegenReviewConfig`
module (and drifts on: elm-m3e's MIGRATION.md hand-rolled the allow-list without
`TypedHtml`/`HtmlIr`, which gates their own public modules' interior imports).

It bundles:

  - **`NoInternalImportOutsideAllowed`** (the opaque-IR fence) allowing
    `*.Internal` imports only from your generated `brandRoots`, the always-present
    IR namespaces `TypedHtml`/`HtmlIr` (whose public modules legitimately reach
    their own `Internal` siblings), and your `allowedModules` (the blessed
    `Seam`/`Native`/`Kit`/… adapters).

    Under the 3‑package split (Phase 2a), builder modules (`M3e.<Component>.Build`)
    are legitimate consumers of `M3e.Build.Internal`. The `brandRoots` prefix
    covers them automatically: a brand root of `"M3e"` allows `M3e.Build`,
    `M3e.Button.Build`, `M3e.Card.Build`, etc. to import `M3e.Build.Internal`.

  - **`NoSeamOutsideAllowedModules`** (the seam gate) keeping applied `seamModules`
    escapes inside those same `allowedModules`.

  - **`NoRedundantElementForge`** (the forge-redundancy backstop) fed the
    `typedHtmlFacts` so a blessed adapter can't re-forge a plain covered tag.

  - `brandRoots` — the generated library root namespaces (e.g. `[ "M3e" ]`).
    Under the builder package, this also covers all `M3e.<Component>.Build`
    modules.

  - `seamModules` — the modules whose functions are seam escapes (e.g. `[ "Seam" ]`).

  - `allowedModules` — the adapter modules blessed to hold a crossing (dotted
    prefixes, so `"Kit"` also covers `Kit.Surface`); shared by both boundary rules.

  - `typedHtmlFacts` — the typed-HTML library's generated facts (one entry per
    HTML tag) for `NoRedundantElementForge`.

```elm
config : List Rule
config =
    Cem.all M3e.Review.Facts.facts
        ++ Cem.fences
            { brandRoots = [ "M3e" ]
            , seamModules = [ "Seam" ]
            , allowedModules = [ "Seam", "Native", "Kit", "Layout" ]
            , typedHtmlFacts = TypedHtml.Review.Facts.facts
            }
        ++ [ Cem.noMergedPipeAndSetter { allowedModules = [ "M3e", "Sl", "Wa" ] } ]
```

-}
fences :
    { brandRoots : List String
    , seamModules : List String
    , allowedModules : List String
    , typedHtmlFacts : List Fact
    }
    -> List Rule
fences config =
    [ NoInternalImportOutsideAllowed.rule
        (config.brandRoots ++ [ "TypedHtml", "HtmlIr" ] ++ config.allowedModules)
    , NoUnsafeImportOutsideAllowed.rule
        (config.brandRoots ++ [ "TypedHtml", "HtmlIr" ] ++ config.allowedModules)
    , NoSeamOutsideAllowedModules.rule
        { seamModules = config.seamModules
        , allowedModules = config.allowedModules
        }
    , NoRedundantElementForge.rule config.typedHtmlFacts
    ]


{-| Flag a module whose exposing list merges a pipe (`with<X>`) and a bare setter
(`<x>`) for the same concept into one flat namespace — which would recreate the
K5/#58 collision that the 3‑package split was designed to avoid (pipes in
`M3e.<Component>.Build`, setters in `M3e.<Component>`).

Opt‑in — not in `Cem.all` and not in the `fences` preset. Enable it on a
known‑good project to prevent accidental barrel merges:

    config =
        [ Cem.noMergedPipeAndSetter { allowedModules = [ "M3e", "Sl", "Wa" ] }
        ]

-}
noMergedPipeAndSetter : { allowedModules : List String } -> Rule
noMergedPipeAndSetter config =
    NoMergedPipeAndSetter.rule config


{-| Flag drift between a generated **family module** (`<familyNamespace>.<F>`,
e.g. `M3e.Component.Chip`) and the family CONFIG it was generated from: a
declared member the family module no longer imports ("component missing from
family"), or an import the family module carries that the config no longer
declares as a member ("family referencing a dead/unlisted component").

Opt-in — NOT in `Cem.all`. Like `Cem.requireFormFieldLabel`/`Cem.requireFabLabel`,
this package holds no brand's family config hardcoded; a brand generates its
flattened family list into an Elm module the same way `M3eUtilityNames` is
generated from `utilities.json` (`elm-review` can't read JSON at review time),
and wires it in:

    config =
        Cem.all M3e.Review.Facts.facts
            ++ [ Cem.noFamilyMemberDrift
                    { componentNamespace = [ "M3e", "Element" ]
                    , familyNamespace = [ "M3e", "Component" ]
                    , families = M3e.Review.Families.families
                    }
               ]

See `NoFamilyMemberDrift` for the exact matching rule and its two error
shapes.

-}
noFamilyMemberDrift :
    { componentNamespace : List String
    , familyNamespace : List String
    , families : List NoFamilyMemberDrift.Family
    }
    -> Rule
noFamilyMemberDrift =
    NoFamilyMemberDrift.rule
