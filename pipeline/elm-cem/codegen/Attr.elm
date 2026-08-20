module Attr exposing
    ( AttrType(..), AttrSpec
    , fromCem, classify, classifyText
    , isEmittable, emittableSpecs, kernelBlocked, kernelBlockedReason
    , AttrForm(..), applyForm, propertyName, docString
    , typeLabel, setterType
    , enumPairs, isTokenEnum
    )

{-| The normalized intermediate representation for component attributes.

CEM attribute data is classified **once** into an `AttrSpec` and both the
per-component and top-level/common emitters consume it. This is the single home
for type classification, so the two output paths can no longer disagree about an
attribute's type (the bug that produced `getSymbol : Float`).

This module is pure and exposed so it can be unit-tested directly.

@docs AttrType, AttrSpec
@docs fromCem, classify, classifyText
@docs isEmittable, emittableSpecs, kernelBlocked, kernelBlockedReason
@docs AttrForm, applyForm, propertyName, docString, typeLabel, setterType
@docs enumPairs, isTokenEnum

-}

import Cem
import Naming
import Util


{-| The classified type of an attribute, which determines how it is emitted.

  - `ABool` — boolean property (`Bool -> Attribute`)
  - `ANumber` — numeric property (`Float -> Attribute`); the CEM spelling is
    `number`, i.e. a TypeScript/IDL `double`.
  - `AInt` — an INTEGER value space; emitted as `Int -> Attribute`. Reached two
    ways:
      - the CEM spelling **`integer`** — a whole-number value space with no
        enumerable set of values (`colspan`, `rowspan`, `span`, `start`,
        `maxlength`, …). TypeScript has no such primitive, so no
        machine-extracted manifest produces it; it exists for the hand-curated
        and spec-derived manifests (`elm-typed-html`, `native-manifest-gen`)
        that DO know the difference. See `isIntegerType` for the bug that
        justifies a second numeric spelling.
      - an integer-literal union (e.g. `1 | 2 | 3`, `100 | 200 | 700`).
        TypeScript numeric-literal aliases like
        `HeadingLevel`/`IconWeight`/`ElevationLevel` (which the string-only alias
        inliner leaves as bare names) land here instead of degrading to `AString`.
  - `AEnum values` — a closed set of string literals whose Elm token name IS the
    emitted string; emitted as a `<Lib>.Values` union row plus a
    `name : Value Row -> Attribute` setter
  - `AEnumMap tokenValues` — a config-forced enum whose emitted string DIFFERS
    from its token name in at least one pair. Each `( token, value )` pair names a
    `Value` token (`token`, which becomes the Elm identifier and the phantom row
    field) that renders to `value` (what `Ir.token` carries, so what reaches the
    DOM). Only ever produced by an `AttrTypeOverride`, never by CEM
    classification — and only by the MAP form of one: `fromOverride` normalizes an
    all-identity override to `AEnum`, so this variant is reserved for the case
    where the distinction is load-bearing (e.g. `always` → `"true"`).
  - `AEnumNum values` — a union of `number` with one or more string literals
    (e.g. `number | "all"`); admits both the literal tokens and a numeric value.
    **It is emitted as a plain `String` setter**, exactly like `AString`: the IR's
    `Value` carries a phantom row of string TOKENS (`HtmlIr.Value`) and has no
    numeric member, so "the literal rows plus a `number` row" is not a type this
    substrate can spell. It is kept as its own variant rather than collapsed into
    `AString` so `typeLabel` can name it and so this degradation is visible in the
    IR rather than inferred from a missing case branch. It is deliberately NOT an
    `isTokenEnum` — see there. The sanctioned way to constrain such an attribute
    today is config, and it is the shape the `weight` / `weightAsNumber` fixture
    exists to pin: keep the base setter a `String` (the only thing that can write
    the keyword) and add a `_variants` `xAsY` companion for the numeric form,
    exactly as `HTMLInputElement` has both `value` and `valueAsNumber`. Narrowing
    the base to `Float` would leave the keyword with no expression at all.
  - `AString` — free-form string attribute (`String -> Attribute`)
  - `ASkip reason` — cannot be passed from Elm (DOM element refs, functions,
    objects); not emitted, only documented under "Omitted Attributes"

-}
type AttrType
    = ABool
    | ANumber
    | AInt
    | AEnum (List String)
    | AEnumNum (List String)
    | AEnumMap (List ( String, String ))
    | AString
    | ASkip String


{-| How a reflected scalar (`ABool`/`ANumber`/`AInt`) setter is emitted at the
bottom layer.

  - `AsAttribute` — set the kebab-named HTML **attribute** (`Html.Attributes.attribute
    htmlName …`). This is the DEFAULT for every observed scalar attribute: it is the
    faithful "`<Lib>.Html` _is_ the HTML" surface, it round-trips as the attribute the
    CEM declared, and it is the fix for issue #33 (hyphenated / `aria-*` attributes
    with no backing property).
  - `AsProperty` — set the backing JS **reactive property** (`Ir.property prop …`).
    The property name is `propertyName`: the CEM's declared `fieldName` when there is
    one, otherwise `htmlName` **verbatim**. Produced by the brand-level controlled
    roster (`_controlled`), for the elements that roster entry's `elements` scope
    covers, or by a per-component override (`attrForm: { "<attr>": "property" }`).

`AsProperty` used to be honoured ONLY when the CEM declared a `fieldName`, silently
degrading to `AsAttribute` otherwise. The rule existed because the ORIGINAL fallback
was a GUESS: camel-case the HTML name. That is issue #33 — `Ir.property "ariaLabel"`
/ `"insetStart"` sets a property the element never observes, so every hyphenated and
`aria-*` setter became a silent no-op. The fix was to stop guessing, and the
fieldName-only rule was how "stop guessing" got expressed.

But it made `attrForm: "property"` a NO-OP for any manifest without `fieldName`
entries — which is every hand-curated native manifest (`elm-typed-html`'s has zero) —
and that is why a SECOND, hardcoded controlled-property list grew inside the phantom
emitter. Falling back to `htmlName` **verbatim** (never camel-cased) reconciles the
two: it is not a guess, it is the identity, and it is exactly right for the case that
motivates the flag at all — `value` / `checked` / `selected` / `muted`, whose IDL
property name IS their content-attribute name.

Verbatim also keeps #33 impossible to reintroduce: a kebab name stays kebab, so no
camel-cased phantom property is ever written. A kebab name has no same-named IDL
property, so asking for `AsProperty` on one is a config error rather than a silent
no-op — `Generate.Phantom.Model` rejects it loudly.

Verbatim is necessary but not sufficient: the property EXISTS under that name, and its
IDL TYPE still has to accept what the setter writes. `value` is `DOMString` on
`<option>`, `long` on `<li>` and **`double`** on `<progress>`/`<meter>`, and Web IDL
answers `progress.value = "abc"` with a **TypeError** — thrown during patch, so it
takes the render loop with it. That is why `_controlled` entries carry an element
SCOPE (`M.Controlled.elements`) and why `AsAttribute` remains the default for
everything else: a content-attribute write coerces nothing and can only be stale.

The scope keeps the setter in the ELEMENT's own module honest. It is not enough on its
own, because `<Lib>.Attributes` publishes ONE body per name and the tie is broken
toward `AsProperty` (see `Generate.Phantom.Model.sharedAttrs`), so a scoped-out element
that keeps sharing the row still admits a property write. An element whose IDL type
COERCES therefore has to leave the row: give it its own setter name and capability row
with `_renames`, and its own type with `attrTypes`, so applying the shared setter to it
is a compile error rather than a runtime TypeError. `<progress>`/`<meter>`/`<li>` in
`elm-typed-html` are exactly that; see `AttrSpec.capName`.

-}
type AttrForm
    = AsAttribute
    | AsProperty


{-| The DOM property name an `AsProperty` setter writes.

`fieldName` when the CEM declared one (a Lit reactive property is `insetStart`,
never the kebab `inset-start`), else `htmlName` verbatim. NEVER a camel-cased
derivation of `htmlName` — see `AttrForm` and issue #33.

-}
propertyName : AttrSpec -> String
propertyName spec =
    Maybe.withDefault spec.htmlName spec.reactiveProp


{-| A normalized attribute ready for emission.
-}
type alias AttrSpec =
    { htmlName : String
    , elmName : String
    , reactiveProp : Maybe String
    , type_ : AttrType
    , attrForm : AttrForm
    , description : Maybe String
    , default : Maybe String

    -- The phantom CAPABILITY field this setter stamps — the row it claims, which
    -- is what decides which elements ADMIT it. Equal to `elmName` for every
    -- CEM-derived attribute.
    --
    -- It diverges DOWNWARD for the two config-declared setter families that
    -- deliberately share a base attribute's row rather than mint their own, so no
    -- element's `Attrs` record grows a field: the `_controlled` `default*`
    -- companions (`defaultValue` claims `value`) and the `_variants` ergonomic
    -- forms (`stepAsNumber` claims `step`). Both are emitted from the base spec,
    -- so they read `capName` off it rather than carrying their own.
    --
    -- It diverges UPWARD — away from every other element declaring the same HTML
    -- name — when config `_renames` gives one element's attribute a different setter
    -- name (`Generate.Phantom.Model.buildComp` moves `elmName` and `capName`
    -- together, so a rename is always a fresh row). That is the mechanism for an
    -- element whose value SPACE differs from its namesakes': `<progress value>` and
    -- `<meter value>` are IDL `double` and `<li value>` is `long`, so the loose
    -- `<Lib>.Attributes.value` — a `String` written as a DOM property — is a Web IDL
    -- TypeError on the first two and a silent `0` on the third. Renamed, those three
    -- claim `valueNumeric`/`valueOrdinal` instead, their `Attrs` rows lack `value`
    -- entirely, and the bad call is a COMPILE error. See `AttrForm`.
    --
    -- It does NOT encode cross-component type conflicts by itself. A suffix-the-loser
    -- scheme (`value` → `valueFloat`) that did it AUTOMATICALLY was once planned here
    -- and never wired up; see `Generate.SharedAttrs` for what replaced it and why. The
    -- rename above is the same divergence made a deliberate config decision instead —
    -- an author states which element is the odd one out and what to call it, rather
    -- than the generator guessing and silently dropping a type.
    , capName : String
    }


{-| Build an `AttrSpec` from a raw CEM attribute.

`reactiveProp` is the JS **property** name the element observes, and it is
`Just` **only** when the CEM explicitly links this attribute to a backing
reactive property via `fieldName`. In that case a bool/number setter must set
THAT property (a Lit reactive property is `insetStart`, never the kebab
`inset-start`).

When the CEM gives no `fieldName`, the entry describes a plain HTML **attribute**
and `reactiveProp` is `Nothing` — the setter must use `htmlName` (kebab) with
`Html.Attributes.attribute`. Guessing a camelCase property name here was wrong:
it set a JS property the element never observes, so hyphenated / `aria-*`
boolean/number attributes were silent no-ops (issue #33). We follow what the
manifest declares instead of guessing.

-}
fromCem : Bool -> Cem.Attribute -> AttrSpec
fromCem keepCase attribute =
    let
        -- The Elm-facing name (setter + phantom-capability). Defaults to the
        -- camel-cased HTML name; a config-injected synthetic attribute may override
        -- it (e.g. `m3e-toc-ignore` → `tocIgnore`) so the setter reads well while the
        -- HTML `htmlName` stays faithful.
        --
        -- `keepCase` (true only for a namespaced brand — SVG/MathML) preserves an
        -- already-lowerCamel attribute name (`viewBox`, `refX`, `gradientUnits`) via
        -- `camelKeepCase` instead of flattening it with `camel`. It MUST default off
        -- for every existing brand: an HTML-family manifest can legitimately carry a
        -- camelCase name (`@m3e/web`'s `validationMessages`), and the published
        -- setter for it is the flattened `camel` form — preserving its case there
        -- would be a breaking API change, so case-preservation is opt-in per brand.
        elmName_ =
            case attribute.elmNameOverride of
                Just override ->
                    override

                Nothing ->
                    if keepCase then
                        Naming.camelKeepCase attribute.name

                    else
                        Naming.camel attribute.name
    in
    { htmlName = attribute.name
    , elmName = elmName_
    , reactiveProp = attribute.fieldName

    -- D1: every observed scalar attribute defaults to the kebab HTML ATTRIBUTE
    -- form. Two config-driven passes can flip it to `AsProperty`: the brand-level
    -- controlled roster (`_controlled`) and the per-component `applyForm` override.
    , attrForm = AsAttribute
    , type_ = classify attribute
    , description = attribute.description
    , default = attribute.default

    -- Equal to `elmName` for every CEM-derived attribute; see `AttrSpec.capName`
    -- for the config-declared setters that deliberately point at another row.
    , capName = elmName_
    }


{-| Apply a per-component `attrForm` config override (a map from attribute name →
`"attribute"` | `"property"`) to a spec. The map is keyed by the CEM attribute name
(kebab `htmlName`), matching the `attrTypes` config convention.

Both directions are honoured, because this runs AFTER the brand-level controlled
roster (`_controlled`) has already flipped its members to `AsProperty`:

  - `"property"` → `AsProperty`, opting one attribute of one component into
    `Ir.property` (see `AttrForm` for the property name and why it is not guessed).
  - `"attribute"` → `AsAttribute`, opting one component's attribute back OUT of a
    brand roster it would otherwise be swept into.

No entry leaves the spec exactly as it arrived. An unrecognized value is ignored
rather than silently inverting the form; the config decoder is the place to reject
it.

-}
applyForm : List ( String, String ) -> AttrSpec -> AttrSpec
applyForm overrides spec =
    let
        match =
            overrides
                |> List.filter (\( name, _ ) -> name == spec.htmlName || name == spec.elmName)
                |> List.head
                |> Maybe.map Tuple.second
    in
    case match of
        Just "property" ->
            { spec | attrForm = AsProperty }

        Just "attribute" ->
            { spec | attrForm = AsAttribute }

        _ ->
            spec


{-| A short human-readable label for an `AttrType`. Used in error messages so a
collision report names the conflicting types rather than printing a raw Elm
union constructor.
-}
typeLabel : AttrType -> String
typeLabel t =
    case t of
        ABool ->
            "Bool"

        ANumber ->
            "Float"

        AInt ->
            "Int"

        AEnum _ ->
            "Enum"

        AEnumNum _ ->
            "EnumNum"

        AEnumMap _ ->
            "EnumMap"

        AString ->
            "String"

        ASkip reason ->
            "Skip(" ++ reason ++ ")"


{-| The `( token, emitted value )` pairs of a TOKEN enum, or `Nothing` when this
type is not one.

This is the SINGLE definition of "is this an enum, and what are its tokens" for the
whole phantom pipeline — `Generate.Phantom.Model` builds its `EnumSpec`s and the
brand-wide `tokenValues` map from it, and every filter in `Generate.Phantom.Emit`
that has to keep an enum out of the plain-setter path asks `isTokenEnum`.

It exists because the alternative — a `case … of AEnum _ -> …` written out at each
of those ~15 sites — is exactly how `AEnumMap` came to be a `String` setter with no
union row and no `<Lib>.Values` tokens (see `fromOverride`). A new enum flavour must
be able to reach every consumer by being added HERE, once.

`token` is the Elm identifier and the phantom row FIELD; `value` is what `Ir.token`
carries, i.e. the string that reaches the DOM. For `AEnum` they are the same string
by construction, which is why an all-identity override is normalized to `AEnum`.

`AEnumNum` is deliberately NOT a token enum, and the omission is load-bearing in
both directions. It has no union row to offer (`HtmlIr.Value`'s row is over string
tokens; there is no numeric member — see `AttrType`), and calling it one here would
also filter it OUT of the plain-setter path in `Emit` (`plainAttrs`, `nonEnumAttrs`),
which publishes setters for everything that is not an enum. It would then get no
setter at all: the attribute would vanish from the emitted API while its capability
row field stayed, which is strictly worse than the loose `String` it gets today.

-}
enumPairs : AttrType -> Maybe (List ( String, String ))
enumPairs t =
    case t of
        AEnum tokens ->
            Just (tokens |> List.map (\v -> ( v, v )))

        AEnumMap pairs ->
            Just pairs

        _ ->
            Nothing


{-| Does this type mint `<Lib>.Values` tokens and a union row? See `enumPairs`,
which is the definition; this is the predicate spelling of it.
-}
isTokenEnum : AttrType -> Bool
isTokenEnum t =
    enumPairs t /= Nothing


{-| The Elm INPUT type a scalar setter takes, as it is spelled in the emitted
signature. Everything that is not a distinct scalar reaches the DOM as a string:
enums of every flavour take a `Value <Row>` whose payload is a string, and their
per-token safety lives in `<Lib>.Values`, not in the setter's argument type.

This is the equality used to decide whether two same-named attributes CONFLICT
(`Emit.conflictsWithCanonical`, `Emit.guardHomeAttrTypes`, `Model`'s conflict notes).
It deliberately lives here, beside `AttrType`, rather than being spelled out at each
of those call sites: the `datetime` regression was three code paths disagreeing about
what "same type" means, and a second definition is how that comes back.

Every enum flavour spelling `String` is therefore a DELIBERATE coarsening, not an
oversight, and `AEnumMap` must keep spelling it too now that it emits a real union.
The signature an enum setter actually gets is `Value <Row>`, minted by
`Emit.enumSetterDecl` from the brand's `EnumSpec` — never from here. Spelling a union
type here would make `guardHomeAttrTypes` fail the run for two elements of one home
module whose enums merely differ in TOKENS, which is the normal case and is already
handled: `Brand.unions` merges the token sets into one row for the shared setter, and
each component narrows to its own subset locally.

-}
setterType : AttrType -> String
setterType t =
    case t of
        ABool ->
            "Bool"

        ANumber ->
            "Float"

        AInt ->
            "Int"

        _ ->
            "String"


{-| The documentation string for a setter: the CEM description (or a fallback),
plus the CEM default value when present.
-}
docString : AttrSpec -> String
docString spec =
    let
        base =
            spec.description
                |> Maybe.withDefault ("Set the `" ++ spec.htmlName ++ "` attribute.")

        defaultHint =
            case spec.default |> Maybe.map String.trim of
                Just d ->
                    if String.isEmpty d || d == "undefined" then
                        ""

                    else
                        " (default: `" ++ d ++ "`)"

                Nothing ->
                    ""
    in
    base ++ defaultHint


{-| Whether a spec produces a real binding (everything except `ASkip`).
-}
isEmittable : AttrSpec -> Bool
isEmittable spec =
    case spec.type_ of
        ASkip _ ->
            False

        _ ->
            True


{-| Why `elm/virtual-dom` cannot express this attribute at all, if it cannot.
`Nothing` means there IS a working path from Elm.

Full rationale + kernel-source evidence for each case (moved out of this doc
comment — finding 4, Theme 4 of the 2026-08-17 thermonuclear review; this
block alone was ~125 of `Attr.elm`'s lines of load-bearing prose):
`docs/kernel-blocked-attrs.md`.

Short version: this is a DIFFERENT kind of "not emittable" from `ASkip`.
`ASkip` is about the VALUE (a DOM element reference or callback has no Elm
spelling). This is about the NAME: the value is an ordinary string and the
setter compiles and runs, but `elm/virtual-dom`'s kernel silently rewrites
the name on the way to the DOM (or the DOM ignores it), so the setter does
not do what it says. Blocked today: any content attribute matching
`/^(on|formAction$)/i`, `formaction` as a property, `innerHTML`/`outerHTML`
as property keys, and `is` in either form — see the doc file for the exact
kernel functions responsible for each. **Do not "restore the missing
setter"** — none of these is defeatable from Elm; the escape hatch is a port
or a custom element.

Every blocked attribute is OMITTED from every emitted surface (never
advertised) rather than failing the run — the manifest is correct HTML, it is
`elm/virtual-dom` that cannot express it, so there is no config edit that
would fix a "failure" — and the omission is REPORTED on the info channel
(same channel the K2/K3 collapse notes use) so it is never silent.

-}
kernelBlockedReason : AttrSpec -> Maybe String
kernelBlockedReason spec =
    let
        -- The name that actually reaches the DOM, which is the only name the
        -- kernel guards see. An `AsAttribute` setter writes `htmlName` through
        -- `VirtualDom.attribute`; an `AsProperty` setter writes `propertyName`
        -- through `VirtualDom.property`. The two paths run DIFFERENT kernel
        -- guards, so the form is load-bearing here and this cannot be a test on
        -- the name alone.
        domName =
            case spec.attrForm of
                AsAttribute ->
                    spec.htmlName

                AsProperty ->
                    propertyName spec

        lower =
            String.toLower domName
    in
    if lower == "is" then
        Just
            ("`is` is inert: a customized built-in element must be opted in at creation time via "
                ++ "`document.createElement(tag, { is })`, and `_VirtualDom_render` calls "
                ++ "`_VirtualDom_doc.createElement(vNode.__tag)` with no options argument, so the element "
                ++ "already exists as its plain built-in self before any fact is applied. There is no `is` "
                ++ "IDL attribute either, so the property form is an inert expando"
            )

    else
        case spec.attrForm of
            AsAttribute ->
                -- `_VirtualDom_RE_on_formAction = /^(on|formAction$)/i`, applied to
                -- every `VirtualDom.attribute` / `attributeNS` key by
                -- `_VirtualDom_noOnOrFormAction`, which returns `'data-' + key` on a
                -- match. Spelled out rather than reached for as a regex because Elm
                -- has none: `^on` is `String.startsWith` and `^formAction$` under the
                -- `i` flag is an equality on the lowercased name.
                if String.startsWith "on" lower || lower == "formaction" then
                    Just
                        ("`_VirtualDom_noOnOrFormAction` rewrites every `VirtualDom.attribute` key matching "
                            ++ "`/^(on|formAction$)/i` to `data-` ++ key, so this would render as `data-"
                            ++ domName
                            ++ "` and never as `"
                            ++ domName
                            ++ "`"
                            ++ (if lower == "formaction" then
                                    ". The property form is closed too — `_VirtualDom_noInnerHtmlOrFormAction` "
                                        ++ "rewrites the exact key `formAction`, and the lowercase key is an inert "
                                        ++ "expando no element observes — so there is no working path from Elm"

                                else
                                    ""
                               )
                        )

                else
                    Nothing

            AsProperty ->
                -- `_VirtualDom_noInnerHtmlOrFormAction` rewrites the exact keys
                -- `innerHTML` / `outerHTML` / `formAction`. Matched case-insensitively
                -- here because a near-miss spelling escapes the kernel only to become
                -- an expando the element never observes: same outcome, one guard.
                --
                -- Deliberately NOT the `on` guard. `VirtualDom.property` does not run
                -- `noOnOrFormAction`, so an `on`-prefixed PROPERTY key is passed
                -- through untouched, and blocking it here would invent a failure the
                -- kernel does not have — while over-reaching onto every innocent name
                -- the prefix catches (`once`, `online`).
                if List.member lower [ "innerhtml", "outerhtml", "formaction" ] then
                    Just
                        ("`_VirtualDom_noInnerHtmlOrFormAction` rewrites the `VirtualDom.property` keys "
                            ++ "`innerHTML` / `outerHTML` / `formAction` to `data-` ++ key; a differently-cased "
                            ++ "spelling escapes that test only to become an inert JS expando, since the element's "
                            ++ "own property name is the exact one. Either way `"
                            ++ domName
                            ++ "` never reaches the DOM"
                        )

                else
                    Nothing


{-| Whether `elm/virtual-dom` rewrites or ignores this attribute's DOM name, so
that no setter for it could ever work. See `kernelBlockedReason` for each case,
the kernel code that causes it, and why a blocked attribute is OMITTED (with a
report) rather than failing the run.
-}
kernelBlocked : AttrSpec -> Bool
kernelBlocked spec =
    kernelBlockedReason spec /= Nothing


{-| The single source of truth for "which of a declaration's attributes become
real Elm bindings". Every emit path (per-component setters, the shared vocab, the
review facts, the shape emitters, the barrel) classifies a component's attributes
through exactly this chain, so the "emittable attribute" policy has one home
rather than the copy-pasted filter chain it grew into:

  - `deduplicateBy .name` — collapse repeated attribute declarations (nearer wins).
  - drop `_`-prefixed names — internal/reserved manifest attributes.
  - keep only HTML-natural names (`kebab-case` or all-lowercase) — this rejects
    camelCase JS-only reflected props that are not settable as attributes.
  - `fromCem` — classify each into an `AttrSpec` (the one classification point).
  - drop `ASkip` specs via `isEmittable` — types that cannot be passed from Elm.
  - drop `kernelBlocked` specs — names `elm/virtual-dom` rewrites or ignores, so
    that a setter for them renders something else or nothing.

Callers that need capability stamping or a suppressed-attr filter apply those on
top of this result; this function owns only the shared emittability policy.

The phantom pipeline reaches the same policy through
`Generate.Phantom.Model.buildComp`, which needs the individual steps interleaved
with config passes (renames, `_controlled`, `attrForm`) and needs to REPORT each
`kernelBlocked` omission on the info channel rather than drop it silently. The
`kernelBlocked` filter runs there AFTER those passes, because the blocked-name
test depends on `attrForm` — the attribute and property paths run different kernel
guards.

-}
emittableSpecs : Cem.Declaration -> List AttrSpec
emittableSpecs component =
    component.attributes
        |> Util.deduplicateBy .name
        |> List.filter (\a -> not (String.startsWith "_" a.name))
        |> List.filter (\a -> String.contains "-" a.name || String.all Char.isLower a.name)
        -- `keepCase` is moot here: the filter above already excludes every
        -- camelCase name (neither hyphenated nor all-lowercase), so this path only
        -- ever sees names `camel` and `camelKeepCase` treat identically.
        |> List.map (fromCem False)
        |> List.filter isEmittable
        |> List.filter (not << kernelBlocked)


{-| Classify a CEM attribute's `type.text` into an `AttrType`.

A config-supplied `typeOverride` wins over the CEM text: it is the declarative
escape hatch for attributes the manifest types wrongly or leaves under-specified.
When absent (the manifest-agnostic default) classification falls back to the CEM
`type.text` exactly as before.

-}
classify : Cem.Attribute -> AttrType
classify attribute =
    case attribute.typeOverride of
        Just override ->
            fromOverride override

        Nothing ->
            case attribute.type_ of
                Nothing ->
                    AString

                Just typeInfo ->
                    classifyText typeInfo.text


{-| Turn a config `AttrTypeOverride` into the forced `AttrType`. An unrecognized
scalar kind falls back to `AString` rather than failing the whole build (the config
decoder validates the allowed kinds up front, so this is only a defensive default).


## Why an all-identity enum override normalizes to `AEnum`

An `AEnumMap` whose every pair has `token == value` IS an `AEnum` — the two carry
exactly the same information — and the simple-list override form
(`"attrTypes": { "disable-pagination": ["true", "false", "auto"] }`) can only ever
produce that shape. So it is spelled `AEnum`, and the map form keeps `AEnumMap`
only when at least one pair actually differs.

This USED to return `AEnumMap` unconditionally, with a comment claiming "the
simple-list and token→value map forms share one emission path". That path was real
once — the retired 5-form pipeline in `Generate.elm` matched `AEnumMap` and emitted
a `Value` setter for it — and it went away with that pipeline. The phantom emitters
that replaced it only ever learned `AEnum`, so `AEnumMap` fell through every `case`
to the `_ ->` default: `Generate.Phantom.Model` minted no `EnumSpec`, hence no
union row and no tokens, and `Generate.Phantom.Emit` emitted a plain
`String -> Attr` setter. An author who deliberately constrained an attribute to
three values got no constraint whatsoever, silently, and `<Lib>.Values` had no row
to show for it. A downstream brand's `disable-pagination`, narrowed to three values in
config, shipped that way for a whole release line.

Normalizing here fixes the whole simple-list form at the ONE point that mints the
variant, rather than at the dozen `case` sites that consume it. It also makes the
K2 global collapse work on such an attribute: `Generate.Phantom.Model` collapses a
CEM attr into a same-named `_globals` entry only when the two types are `==`, both
sides sort their token lists, and an enum global is an `AEnum` — so a list override
matching a global's tokens used to fail K2 loudly with "Enum vs EnumMap" instead of
collapsing.

`AEnumMap` is still handled all the way through the phantom pipeline (see
`isTokenEnum` and `Generate.Phantom.Model.resolveWith`'s `tokenValues`), because
the differing form is the whole point of the map spelling. Normalization is a
simplification of the IR, not the fix for the missing cases.

-}
fromOverride : Cem.AttrTypeOverride -> AttrType
fromOverride override =
    case override of
        Cem.OverrideScalar kind ->
            case kind of
                "int" ->
                    AInt

                "float" ->
                    ANumber

                "bool" ->
                    ABool

                _ ->
                    AString

        Cem.OverrideEnum tokenValues ->
            if List.all (\( token, value ) -> token == value) tokenValues then
                -- Sorted, like `enumValues` and `Model.globalDecoder`, so an override
                -- compares `==` to the same value-set reached any other way. K2's
                -- global collapse is a plain `==` on `AttrType` and leans on that.
                AEnum (tokenValues |> List.map Tuple.first |> List.sort)

            else
                AEnumMap tokenValues


classifyText : String -> AttrType
classifyText rawText =
    let
        -- Keep only literals whose content is actually expressible as an
        -- attribute value; a single non-expressible literal (e.g. a stray
        -- `'(e) => void'`) is dropped on its own rather than collapsing the
        -- whole enum to `ASkip` (issue #22).
        values =
            enumValues rawText
                |> List.filter (\v -> not (isSkippableType v))

        core =
            stripNullable rawText

        -- Both numeric spellings count. A `'auto' | integer` union has a member no
        -- `Value <Row>` can spell for exactly the same reason `number | 'all'` does
        -- (the row is over string TOKENS — see `AttrType.AEnumNum`), so treating only
        -- `number` as numeric here would classify it `AEnum [ "auto" ]` and silently
        -- pretend the integer half does not exist.
        hasNumberMember =
            rawText
                |> String.split "|"
                |> List.map String.trim
                |> List.any isNumericType
    in
    if not (List.isEmpty values) then
        if hasNumberMember then
            AEnumNum values

        else
            AEnum values

    else if isStringArrayType core then
        AString

    else if isSkippableType core then
        ASkip rawText

    else if isBooleanType core then
        ABool

    else if isIntLiteralUnion core then
        AInt

    else if isIntegerType core then
        AInt

    else if isNumberType core then
        ANumber

    else
        AString


{-| Extract the string-literal values from a TypeScript union type string.

Only **quoted** members are kept — a quoted member is a genuine string literal,
so its contents are taken verbatim (spaces and other punctuation included, e.g.
`'end center'`). Unquoted members (`undefined`, `null`, bare type names like
`SomeType`, function/generic/array syntax) are not literals and are dropped.

Returns a sorted, de-duplicated list so equal value-sets compare equal
regardless of source order. Empty when no member is a quoted literal — including
the common non-enum cases (`string`, `boolean | undefined`, bare type names).

A single quoted literal (whether or not it is part of a `|` union) yields a
one-element list; `classifyText` treats that as a one-value `AEnum` (issue #17),
so an attribute constrained to exactly one value stays typed.

(Previously this filtered on a marker list that included a space, which silently
dropped legitimate multi-word literals like `'end center'` — issue #16 — while
also letting unquoted type names slip through as fake enum values, and required
`|` so a lone literal degraded to `String`.)

-}
enumValues : String -> List String
enumValues rawText =
    rawText
        |> String.split "|"
        |> List.filterMap quotedLiteral
        |> List.sort
        |> Util.deduplicateBy identity


{-| If a raw union member is a single-quoted or double-quoted string literal,
return its unquoted contents; otherwise `Nothing`. The contents are taken as-is
(spaces preserved) since a quoted literal is definitionally a value, not a type.
-}
quotedLiteral : String -> Maybe String
quotedLiteral raw =
    let
        trimmed =
            String.trim raw

        unwrap q =
            if String.length trimmed >= 2 && String.startsWith q trimmed && String.endsWith q trimmed then
                Just (String.slice 1 -1 trimmed)

            else
                Nothing
    in
    case unwrap "\"" of
        Just inner ->
            Just inner

        Nothing ->
            unwrap "'"


{-| Remove `| undefined` / `| null` members so a nullable scalar like
`boolean | undefined` still classifies as its underlying type.
-}
stripNullable : String -> String
stripNullable rawText =
    rawText
        |> String.split "|"
        |> List.map String.trim
        |> List.filter (\part -> not (List.member (String.toLower part) [ "undefined", "null" ]))
        |> String.join " | "
        |> String.trim


{-| A union whose every member is an integer literal (`1 | 2 | 3`,
`100 | 200 | 700`). TypeScript numeric-literal aliases (`HeadingLevel`,
`IconWeight`, `ElevationLevel`) resolve to these; the string-literal alias
inliner leaves them as bare names, so without this they degrade to `AString`.
A lone `number` is NOT matched here (it stays `ANumber`/`Float`).
-}
isIntLiteralUnion : String -> Bool
isIntLiteralUnion core =
    let
        members =
            core
                |> String.split "|"
                |> List.map String.trim
                |> List.filter (\p -> not (String.isEmpty p))
    in
    not (List.isEmpty members)
        && List.all (\p -> String.toInt p /= Nothing) members


isBooleanType : String -> Bool
isBooleanType core =
    String.toLower (String.trim core) == "boolean"


isNumberType : String -> Bool
isNumberType core =
    String.toLower (String.trim core) == "number"


{-| The CEM `type.text` spelling for an INTEGER value space: the literal word
`integer`. `number` stays a `Float`; this is the second numeric spelling, and it
is `AInt`.

## Why a second spelling had to exist

`AInt` was previously reachable ONLY from an integer-LITERAL union (`1 | 2 | 3`),
so an attribute whose value space is "some integer, unbounded" had no spelling at
all and every such attribute was typed `number` — `Float -> Attr`, serialized with
`String.fromFloat`. That function's range includes four shapes HTML's integer
parsers REJECT outright:

    String.fromFloat (0 / 0)  == "NaN"
    String.fromFloat (1 / 0)  == "Infinity"
    String.fromFloat 1.0e21   == "1e+21"
    String.fromFloat 2.5      == "2.5"

A rejected value is not an inert one: the HTML parser falls back to the
attribute's default, so `colspan="2.5"` renders as `colspan=1` and the table
silently loses a column. In `elm-typed-html` that was ELEVEN attributes over 31
element/attribute pairs (`colspan`, `rowspan`, `rows`, `cols`, `size`, `span`,
`start`, `maxlength`, `minlength`, `width`, `height`) — every one of which
`elm/html` types `Int`.

## Why this is a spelling and not 31 config overrides

The `attrTypes` escape hatch could have forced each of them to `int`
per-element. It was rejected: `native-manifest-gen` already DERIVES the
distinction from the WHATWG attribute index (its `classifyValue` returns a
distinct `int` kind, and "Valid non-negative integer" is precisely the
distinction), and `typeText` then collapsed `int` and `float` to one `'number'`
because no downstream spelling existed to collapse INTO. Adding the spelling
lets the generator carry the fact it already knew, instead of having every brand
re-state 31 facts by hand and drift from the spec when the spec moves.

## What `Int` does and does not buy

It buys the four malformed shapes above. `NaN` and `Infinity` become unreachable
outright — Elm's `//` and `remainderBy` are defined to return `0` on a zero
divisor rather than a non-finite value — and `"2.5"` becomes a type error. One
honest residue: an Elm `Int` is a JS double at runtime, so an OVERFLOWING integer
expression (`2 ^ 70`) exceeds 2^53 and `String.fromInt`, which is `n + ""`, then
prints exponent notation. That is a degenerate route no realistic `colspan` takes,
where `Float` reaches all four from ordinary arithmetic.

What it does NOT buy is RANGE. Six of the eleven are "valid non-negative integer
greater than zero" per WHATWG, and `Int` still admits `0` and `-3`. That is
deliberate and terminal, not a staged fix: Elm has no refinement, literal or
dependent types, so there is no type whose inhabitants are the integers ≥ 1 while
`colspan 2` still typechecks as a bare literal. An opaque `Positive` with
`fromInt : Int -> Maybe Positive` moves the check to RUNTIME (and forces every
call site through a `Maybe`, which callers discharge with `withDefault`, which is
the guard evaporating); a `one`/`succ` constructor encoding is compile-time but
unusable past about three. Out-of-range-but-well-formed is also the strictly
milder failure: HTML's integer parsers accept the value and clamp it to the
spec's stated default, where a REJECTED value discards it entirely.

-}
isIntegerType : String -> Bool
isIntegerType core =
    String.toLower (String.trim core) == "integer"


{-| Either numeric spelling. Used by `classifyText`'s `AEnumNum` detection, which
must treat `integer` and `number` alike — see there.
-}
isNumericType : String -> Bool
isNumericType core =
    isNumberType core || isIntegerType core


{-| A `string[]` attribute (e.g. BottomSheet/SplitPane `detents`) is authored in
HTML as a **space-delimited token string** and reflects to the attribute, so it
IS expressible from Elm as a plain `String`. It must be recognised BEFORE
`isSkippableType` (which rejects any `[]`), otherwise the attribute is dropped
and hand-authored HTML like `detents="fit half full"` cannot round-trip.

Only a bare string array is carved out here — arrays of objects/elements, tuples,
and generics stay `ASkip`. Emitting `String` (rather than a bespoke `List String`
setter) keeps this to the existing `AString` path: the value is the faithful,
round-trip-safe HTML attribute string, matching the D1 `AsAttribute` default.

-}
isStringArrayType : String -> Bool
isStringArrayType core =
    List.member (String.trim core)
        [ "string[]"
        , "readonly string[]"
        , "Array<string>"
        , "ReadonlyArray<string>"
        ]


{-| A type that cannot be expressed as an HTML attribute/property value from Elm:
DOM element references, functions, objects, arrays, generics. These are skipped
and documented rather than emitted as broken bindings.
-}
isSkippableType : String -> Bool
isSkippableType raw =
    let
        trimmed =
            String.trim raw
    in
    isElementType trimmed
        || containsAny [ "=>", "(", ")", "{", "}", "<", ">", "[", "]" ] trimmed


isElementType : String -> Bool
isElementType value =
    List.member value
        [ "Element"
        , "HTMLElement"
        , "VirtualElement"
        , "Node"
        , "ShadowRoot"
        ]


containsAny : List String -> String -> Bool
containsAny needles haystack =
    List.any (\needle -> String.contains needle haystack) needles
