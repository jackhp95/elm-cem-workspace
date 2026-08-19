# Design decisions

This is a living record of *why* elm-review-cem is shaped the way it is — the
handful of choices that a newcomer would otherwise have to reverse-engineer from
the rule taxonomy. It is deliberately not a stack of frozen ADR ceremony: one
short heading per decision, prose, honest about the trade-off, revised in place
when the design moves rather than appended to. A few decisions carried an
"ADR-N" number in their originating plan; those are noted parenthetically so you
can cross-reference the sibling elm-cem history, but the number is a pointer, not
a contract. If a plan reference is unrecoverable it says so rather than inventing
rationale.

- [Facts contract as the elm-cem seam](#facts-contract-as-the-elm-cem-seam)
- [Namespace-agnostic rules](#namespace-agnostic-rules)
- [Layers/forms vocabulary](#layersforms-vocabulary-plan-b)
- [Standard as the top form](#standard-as-the-top-form-wave-4)
- [Translators are mutually exclusive](#translators-are-mutually-exclusive)
- [Slot-kind validity checking](#slot-kind-validity-checking-adr-15)
- [Facts-index canonicality](#facts-index-canonicality)
- [The barrel autofix pair and its round-trip idempotence](#the-barrel-autofix-pair-and-its-round-trip-idempotence)
- [Barrel rewrites must be type-preserving and facet-agnostic](#barrel-rewrites-must-be-type-preserving-and-facet-agnostic)
- [Seam-discipline rules live here](#seam-discipline-rules-live-here-plan-d-f5)

## Facts contract as the elm-cem seam

Every rule in this package is driven by a list of `Cem.Facts.Fact` values rather
than by any hardcoded knowledge of a specific component library. A `Fact` carries
the per-component data elm-review can't otherwise recover — required slots and
attributes, multi-vs-singular slot arity, which facets the component emits
at, enum values, the raw HTML/slot names, and slot-kind constraints. elm-cem is
the producer of this contract (it generates the facts alongside the library);
elm-review-cem is the consumer. Keeping the seam narrow and data-shaped is what
lets the two repos evolve independently: a new capability usually means *adding a
field to the `Fact` record* and threading it through, and every hand-built test
fixture gets the new field defaulted (this is why commits like the `slotKinds`
and `groupConstructors` additions touch "all 21 Fact fixtures"). The rules hold
no opinion about seam or kit content — that opinion lives entirely in the
generated manifest.

## Namespace-agnostic rules

The rules were extracted from the elm-m3e review sources and made
namespace-agnostic in the same move: no rule hardcodes `M3e`. Each rule derives
the library's root namespace from the `module_` field of each fact it's given, so
the same package works for any elm-cem-generated library, not just M3e. This is
the reason the whole thing is a reusable package at all rather than app-local
rules — the price is that everything must be expressed in terms of the facts
contract instead of literal module names.

## Layers/forms vocabulary (Plan B)

The facets of a generated library were renamed to a "layers/forms"
vocabulary in lockstep with elm-cem (Plan B). The `Facts.Facet` constructors
became `Raw` (raw-HTML bottom module), `Html` (Html-typed middle), and the top
forms; the translator rules and error messages were rewritten to match
(`TranslateTo{Html→Raw, Cem→Html}`, and the old `PreferSpecific{Slot,BarrelSlot}`
became `PreferComponentModules` / `PreferComponentSetters`). The point was to give
users and error messages one consistent way to talk about where a call site sits
in the stack, instead of the earlier mix of "portmanteau / surface / specific"
terms that didn't compose into a mental model. Note the lowercase adjectival
"loose" (as in a loose enum setter or the escape-hatch top layer) is a *different*
sense and was intentionally left alone during this rename.

## Standard as the top form (Wave 4)

The permissive top form was renamed from `Loose` to `Standard`, again tracking an
elm-cem change (Wave 4). The `Facts.Facet` constructor `Loose` became
`Standard`, and `Cem.TranslateToLoose` became `Cem.TranslateToStandard` (module,
function, facade, tests, README). "Standard" better names what that form *is* —
the double-list default facet most user code should live at — whereas "Loose"
described only its permissiveness. This is a breaking rename (`feat!`) precisely
because the facet name is part of the public facts contract and the exposed
rule set.

## Translators are mutually exclusive

> **SUPERSEDED (issue #2, pre-1.0):** the five `translateTo*` rules were removed
> before the 1.0 freeze — they rewrote toward the `Html`/`Raw` layers no generated
> brand still emits, and they were the only code that hardcoded a `Seam.*` residue
> target (now purely config-driven via `NoSeamOutsideAllowedModules` /
> `ExtractToSeam`). The section below is retained as history.

There are five `translateTo*` rules, one per form (Standard, Record, Build, Html,
Raw), and the design constraint is that you enable **at most one** of them. Each
translator rewrites call sites at every *other* form to its single target, so
turning on two would have them fight over the same code. They are therefore all
opt-in and excluded from `Cem.all` — you pick exactly one when you want to pin a
canonical top form across a codebase, and residue that can't be translated escapes
through `Seam.*`. This is documented directly in the `Cem` facade ("Enable AT MOST
ONE of these") and is what keeps the autofix convergent rather than oscillating.

## Slot-kind validity checking (ADR-15)

ADR-15 is the decision to move the library's composition guarantees *off* the M3e
phantom types and onto facts-driven review rules — once the top layer takes raw
`Element` children instead of `child`/`children` wrappers, the compiler no longer
enforces which kinds of child a slot accepts, so a rule has to. This added a
`slotKinds` field to the `Fact` contract and the configurable `Cem.ValidSlotKind`
rule, which checks that each child placed in a content list is a kind the enclosing
component's slot accepts. Because many children can't be resolved statically (a
`let`-bound value, a `List.map` result, a helper return), the rule has a posture:
`Lenient` (silent, the default in `Cem.all`) or `Strict` (warns on every child it
can't resolve, via `Cem.allWith { validSlotKind = Strict }`). Two refinements are
worth knowing: an empty `slotKinds` entry is the "arbitrary" encoding and is silent
in every posture (there's nothing to check against), and non-component barrel
helpers like `M3e.text`/`M3e.none` resolve as *unresolvable* rather than falsely
tripping a constrained slot. The same ADR-15 shift is why the Record/Build
translators lift required content from raw children — and why that lift is scoped
to only those two targets (see below).

## Facts-index canonicality

`RequireSlot.elm` and `SingularSlot.elm` both derive their per-rule lookup
index directly from `Cem.Internal.Facts.buildIndex` rather than rolling a
private `factKey`-only index of their own. This matters because
`Facts.buildIndex` inserts **two** keys per fact when a component sits under a
barrel-aliasable namespace (e.g. `["M3e", "Component"]`): the canonical
`factKey` (`"M3e.Component\u{0000}button"`) *and* the barrel-alias key
(`"M3e\u{0000}button"`) — see `buildIndex`'s doc comment in `Facts.elm`. A
rule's `siteKey` for a barrel call site (`M3e.button …`) only ever resolves
against the barrel-alias key, so a rule that instead rolls its own index keyed
solely on `factKey` is silently DEAD on the entire barrel call-site surface:
real generated facts always carry the `Component`/`Build` segment, so a barrel
call never matches. This gap shipped and passed review because the
hand-written test fixtures used flat `module_` values (`"M3e.Grid"`,
`"M3e.Button"` with no `.Component.` segment), where `factKey == siteKey` by
coincidence — masking it. The fix, and the convention going forward: any rule
that needs a facts index MUST derive it from `Facts.buildIndex`, never
re-derive its own `factKey`-keyed dictionary, so it inherits the barrel-alias
entries for free and stays correct against real generated facts, not just
flat fixtures.

## The barrel autofix pair and its round-trip idempotence

`Cem.PreferBarrel` and `Cem.PreferComponentModules` (originally
`PreferSpecificSlot`) are an inverse autofix pair: one rewrites per-component call
sites *up* to the generalized barrel (`M3e.Button.icon` → `M3e.slotIcon`), the
other rewrites the barrel form *down* to the component-specific name. Both are
opt-in and not part of `Cem.all`. `RoundTripTest` proves they compose as inverses
on the constructor and variant-group classes, and the elm-m3e corpus harness
confirms the full apply-all-fixes identity over hundreds of barrelised examples
with zero unexpected mismatches. There is one *intentional* asymmetry: barrelising
generalises `M3e.Button.icon` to `M3e.slotIcon`, but specialising re-specialises
to the component-specific *barrel* name `M3e.buttonSlotIcon` — a re-export alias
with identical types, not back to the raw per-component module. So the endpoints
coincide in type even though the intermediate generalized name has a distinct,
narrower phantom; the round trip is type-preserving even though a single
barrelise step is not.

## Barrel rewrites must be type-preserving and facet-agnostic

A cluster of fixes hardened the barrel autofix against emitting code that
type-checks wrong. The governing rule is that a usage-level rewrite may only
flatten a setter to the barrel when the barrel form is genuinely
type-interchangeable — and the barrel's own disambiguation renames (scalar
`disabled` → `attrDisabled`) are precisely the signal that a form *is* different.
So: event setters stay per-component (the barrel re-exposes a decoder-based
handler, not the msg-convenience — a `msg` vs `Decoder msg` mismatch); an enum
attr named `name` is not scalar-rewritten; and a bare `value`/`name` with no
explicit `attrRewrites` entry stays on the per-component facet rather than
guessing, because a usage rule can't see whether it carries a `String` or `Float`
capability (the generator supplies a capability-correct entry for the setters that
*do* have a safe barrel form). Separately, `PreferBarrel` gained the
`import <root>` insertion machinery it was missing, so its output compiles even in
modules that only imported the tight per-component facet. And the
required-capability detectors (`MissingRequiredAttribute`,
`MissingRequiredSingularSlot`) were made facet-agnostic so they agree whether a
component is written in per-component or barrel form for the same logical
component, rather than false-negating on one and false-positing on the other.

## Seam-discipline rules live here (Plan D F5)

Three generic boundary rules — `NoSeamOutsideAllowedModules` (the gate),
`NoInternalImportOutsideAllowed` (the fence), and `ExtractToSeam` (the opt-in
cross-file autofix companion) — were moved into this package from elm-m3e/review
(Plan D, step F5). They keep their top-level module names (no `Cem.` prefix) and
carry no facts: they're configured with explicit module names and are fully
generic. They live here because they're the boundary counterpart to this package's
facts-driven facet rules — the seam rules govern *where* library calls may
appear, the facts rules govern *how* they're written — so it's natural for a
consumer to get both from one package.
