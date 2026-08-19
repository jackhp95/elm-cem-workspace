module Generate.Phantom.Emit.AttrsRow exposing (..)


import Attr
import Cem
import Char
import Dict
import Docs
import Elm
import Generate.Phantom.Model as M exposing (Brand, Comp, EnumSpec, KindField, Marker(..), ResolvedSlot, SlotContent(..))
import Json.Encode as Encode
import Naming
import Util exposing (deduplicateBy)

import Generate.Phantom.Emit.Shared exposing (..)


-- COMPONENT ATTRS ROW


{-| The component's closed capability field list: globals + CEM attrs + event
handlers, sorted.
-}
attrsFields : Brand -> Comp -> List String
attrsFields brand comp =
    (List.map .capName brand.globals
        ++ List.map .capName comp.attrs
        ++ List.map (handlerName brand) comp.events
    )
        |> List.sort


nonEnumAttrs : Comp -> List Attr.AttrSpec
nonEnumAttrs comp =
    comp.attrs |> List.filter (not << isEnumSpec)


{-| `main` follows elm/html's `main_` convention everywhere a declaration name
is minted from it (ctor handled in Model; this covers ARIA role names).
`Naming.safeValue` covers both concerns in one pass: its reserved-name list is
every Elm keyword PLUS `"main"`, so it supersedes `Naming.safeField` (keywords
only) here without a separate hand-rolled `"main"` check.
-}
roleName : String -> String
roleName r =
    Naming.safeValue (Naming.camel r)


{-| An enum token string as a safe Elm identifier / record-field name WITH renames applied.

Applies `_renames._tokens` config overrides FIRST (e.g. "AUTO" -> "autoUpper");
then delegates to `Naming.tokenIdent` which applies the K1 unconditional rule:
a leading-`_` token like `"_top"` maps to `"top_"` (not `"top"`). All other
tokens go through the standard camel -> safeField chain. The raw token payload
passed to `Ir.token` stays unchanged.

-}
tokenIdentResolved : Brand -> String -> String
tokenIdentResolved brand rawToken =
    Dict.get rawToken brand.tokenRenames
        |> Maybe.withDefault (Naming.tokenIdent rawToken)


{-| Legacy: enum token string as a safe Elm identifier, no rename support.
-}
tokenIdent : String -> String
tokenIdent =
    Naming.tokenIdent


{-| The STRING an enum token renders to — what `Ir.token` carries, and therefore what
reaches the DOM attribute.

The identity for every token that came from an `AEnum`, which is all of them unless a
config `attrTypes` MAP override asked for a token whose Elm name differs from its HTML
value (`{"always": "true"}` mints `Values.always = Ir.token "true"`). See
`Brand.tokenValues`, which is where the map is built and where "one token, one string"
is enforced.

This is the exact mirror of `tokenIdentResolved`: that one resolves the IDENTIFIER and
leaves the payload alone, this one resolves the PAYLOAD and leaves the identifier
alone. Both are needed, and confusing them is silent: swapping them would name every
token after the string it emits, collapsing `always`/`never` back onto `true`/`false`.

The `withDefault` is not defensive — an `AEnum` token is a genuine identity pair, and
`Model` records it as such, so the lookup succeeds for every token a `Brand` carries.
It is here so this function is total over any raw string a caller has to hand.

-}
tokenValueOf : Brand -> String -> String
tokenValueOf brand rawToken =
    Dict.get rawToken brand.tokenValues
        |> Maybe.withDefault rawToken


{-| Enum portmanteau globals: for each enum ATTRIBUTE and each of its VALUES a
`<attrName><ValueName>` identifier (camelCase, e.g. `variant` + `Filled` →
`variantFilled`, `shape` + `Rounded` → `shapeRounded`), bound to the SAME open
row `Value { v | <value> : Supported }` as the bare token. Purely additive to
the bare tokens; it exists for IDE discovery — type `variant` and autocomplete
lists every valid variant value.

`taken` is the set of value names already claimed in the module (bare tokens,
union aliases). A portmanteau whose name collides with a taken name — or with an
earlier portmanteau — is dropped, so the bare token always wins and the Values
guard never sees a duplicate. Brand-wide token-ident collisions are already
failed loudly by `guardValuesModule`, so within one attribute every value has a
distinct ident and thus a distinct portmanteau.

-}
enumPortmanteaus :
    Brand
    -> List String
    -> List { name : String, attr : String, token : String, ident : String }
enumPortmanteaus brand taken =
    brand.unions
        |> List.sortBy .elmName
        |> List.concatMap (\u -> u.tokens |> List.sort |> List.map (\t -> ( u.elmName, t )))
        |> List.foldl
            (\( attr, t ) ( seen, acc ) ->
                let
                    ident =
                        tokenIdentResolved brand t

                    name =
                        attr ++ Naming.capitalize ident
                in
                if List.member name seen then
                    ( seen, acc )

                else
                    ( name :: seen
                    , acc ++ [ { name = name, attr = attr, token = t, ident = ident } ]
                    )
            )
            ( taken, [] )
        |> Tuple.second


{-| Enum portmanteau ATTRIBUTES: for each enum ATTRIBUTE and each of its VALUES a
nullary `<attrName><ValuePascal>` identifier in `<Lib>.Attributes`, pre-applying
the token value into the attribute body.

  - `variantRainbow : Attr { c | variant : Supported } msg`
  - `variantRainbow = Ir.attribute "variant" "rainbow"`

Naming matches the existing `MV.variantRainbow` value-alias convention so `MA` and
`MV` identifiers align. One portmanteau per (attr, token) pair; collisions with
already-taken names are dropped (the enum setter wins, bare tokens in `Values` win).

`taken` is the set of names already claimed in `<Lib>.Attributes` (globals,
plain attrs, companions, variants, enum setters).

-}
enumAttrPortmanteaus :
    Brand
    -> List String
    -> List { name : String, capName : String, htmlName : String, tokenValue : String }
enumAttrPortmanteaus brand taken =
    brand.unions
        |> List.filter (\u -> not (isGlobalName brand u.elmName))
        |> List.sortBy .elmName
        |> List.concatMap
            (\u ->
                let
                    htmlName =
                        brand.sharedAttrs
                            |> List.filter (\a -> a.elmName == u.elmName)
                            |> List.head
                            |> Maybe.map .htmlName
                            |> Maybe.withDefault u.elmName
                in
                u.tokens
                    |> List.sort
                    |> List.map
                        (\t ->
                            { name = u.elmName ++ Naming.capitalize (tokenIdentResolved brand t)
                            , capName = u.elmName
                            , htmlName = htmlName
                            , tokenValue = tokenValueOf brand t
                            }
                        )
            )
        |> List.foldl
            (\p ( seen, acc ) ->
                if List.member p.name seen then
                    ( seen, acc )

                else
                    ( p.name :: seen, acc ++ [ p ] )
            )
            ( taken, [] )
        |> Tuple.second


{-| Design-C loose slot placers for the general `M3e` surface.

Computes the DISTINCT set of slot names across all `brand` comps (excluding the
`"unnamed"` default slot), deduplicated by their Elm identifier
(`"slot" ++ Naming.capitalize (Naming.camel name)`).

When two DIFFERENT HTML slot strings map to the SAME identifier (a camel
collision), the pair is returned in the second element so the caller can FAIL
generation loudly via the guard machinery. Identical slot names on different
components collapse to ONE placer (the intended behaviour — breadth loss is
accepted per Jack's decision).

-}
looseSlotPlacers :
    Brand
    -> { placers : List { ident : String, htmlName : String }, collisions : List { ident : String, htmlNames : List String } }
looseSlotPlacers brand =
    let
        -- Collect (ident, htmlSlotName) pairs across all comps, excluding "unnamed".
        rawPairs =
            brand.comps
                |> List.concatMap
                    (\c ->
                        c.slots
                            |> List.filterMap
                                (\s ->
                                    if s.name == "unnamed" then
                                        Nothing

                                    else
                                        Just
                                            { ident = "slot" ++ Naming.capitalize (Naming.camel s.name)
                                            , htmlName = s.name
                                            }
                                )
                    )

        -- Group by ident; collect all distinct htmlNames for each ident.
        grouped =
            rawPairs
                |> List.sortBy .ident
                |> List.foldl
                    (\pair acc ->
                        case List.filter (\( k, _ ) -> k == pair.ident) acc of
                            [] ->
                                acc ++ [ ( pair.ident, [ pair.htmlName ] ) ]

                            _ ->
                                acc
                                    |> List.map
                                        (\( k, vs ) ->
                                            if k == pair.ident then
                                                ( k
                                                , if List.member pair.htmlName vs then
                                                    vs

                                                  else
                                                    vs ++ [ pair.htmlName ]
                                                )

                                            else
                                                ( k, vs )
                                        )
                    )
                    []
    in
    grouped
        |> List.foldl
            (\( ident, htmlNames ) { placers, collisions } ->
                case htmlNames of
                    [ single ] ->
                        { placers = placers ++ [ { ident = ident, htmlName = single } ]
                        , collisions = collisions
                        }

                    many ->
                        -- Two different HTML slot strings camel-collapsed to the same
                        -- identifier — FAIL loudly.
                        { placers = placers
                        , collisions = collisions ++ [ { ident = ident, htmlNames = many } ]
                        }
            )
            { placers = [], collisions = [] }


{-| Payload Elm type + Json.Decode primitive for a typed event override.
`date` decodes the ISO string (parse app-side).
-}
overrideTypes : String -> ( String, String )
overrideTypes ty =
    case ty of
        "int" ->
            ( "Int", "Json.Decode.int" )

        "float" ->
            ( "Float", "Json.Decode.float" )

        "number" ->
            ( "Float", "Json.Decode.float" )

        "bool" ->
            ( "Bool", "Json.Decode.bool" )

        _ ->
            ( "String", "Json.Decode.string" )


{-| Is this member's own classification an enum?

Delegates to `Attr.isTokenEnum` rather than matching `Attr.AEnum` here. Every filter
in this module that has to keep an enum out of the plain-setter path goes through
this one predicate for the same reason `Attr.setterType` is the one definition of
"same type": a local `case … of AEnum _ ->` at each site is how `AEnumMap` came to be
matched at ZERO of them and emitted as a bare `String` setter.

-}
isEnumSpec : Attr.AttrSpec -> Bool
isEnumSpec a =
    Attr.isTokenEnum a.type_


{-| The brand-wide union spec for an attr name, when it is an enum anywhere.
-}
unionFor : Brand -> String -> Maybe EnumSpec
unionFor brand elmName =
    brand.unions |> List.filter (\e -> e.elmName == elmName) |> List.head


{-| Every global the brand declares, both row shapes.

The DEFAULT reading of `_globals`. Only two consumers want `brand.globals` alone,
and both are the closed-row question itself: `attrsFields` (which _is_ the closed
`Attrs` alias) and `attrPipes` (whose `with<Field>` pipes consume a capability
field an open global never has). Everything else — namespace collision checks,
union minting, the exposing list, `Review.Facts` — is asking "is this a global?",
to which an open global's answer is yes.

Getting this backwards is quiet rather than loud, which is why it is one function:
an open enum global reaching `enumAttrs` is a SECOND declaration of a name the
globals block already emitted, and a name missing from `globalNames` is a setter
that compiles but is never exposed.

-}
allGlobals : Brand -> List Attr.AttrSpec
allGlobals brand =
    brand.globals ++ brand.openGlobals


{-| Is this identifier one of the brand's `_globals`?

Globals share the `<Lib>.Attributes` namespace with the shared vocabulary and (for
an ENUM global) the `brand.unions` roster, so every place that walks `unions` to
emit or count a setter has to ask whether the globals block already owns it.

Both row shapes, because `brand.unions` is where an enum global's `<Lib>.Values`
row is minted REGARDLESS of row shape (`Model.globalEnums`). So an open enum
global is in `unions` too, and a check that missed it would let `enumAttrs` emit
a duplicate setter under the same name — in the same module, from the same list.

-}
isGlobalName : Brand -> String -> Bool
isGlobalName brand elmName =
    allGlobals brand |> List.any (\g -> g.elmName == elmName)


{-| Does the brand have at least one ENUM global?

Such a global's setter is annotated `Value <Lib>.Values.<Row>`, so `<Lib>.Values`
and `HtmlIr.Value` become mandatory imports in `<Lib>.Attributes` and in every
per-component module (which gets a `with<Global>` pipe for it) — even when the
brand has no enum ATTRIBUTE anywhere and would otherwise import neither.

-}
hasEnumGlobal : Brand -> Bool
hasEnumGlobal brand =
    allGlobals brand |> List.any (\g -> unionFor brand g.elmName /= Nothing)


{-| The canonical spec for an attr name (first in brand.sharedAttrs).
-}
canonicalFor : Brand -> String -> Maybe Attr.AttrSpec
canonicalFor brand elmName =
    brand.sharedAttrs |> List.filter (\a -> a.elmName == elmName) |> List.head


{-| Does this member's scalar type disagree with the brand-canonical setter?
(The capability ROW is type-free — `value : Supported` — so a locally-typed
setter is sound; only DELEGATION would be ill-typed.)
-}
conflictsWithCanonical : Brand -> Attr.AttrSpec -> Bool
conflictsWithCanonical brand a =
    case canonicalFor brand a.elmName of
        Just c ->
            setterInputType c /= setterInputType a

        Nothing ->
            False


{-| Does this member's setter DIVERGE from the brand-canonical one in any way that
makes `<attr> = A.<attr>` the wrong body — not just an ill-typed one?

Two ways it can, and delegation is wrong for both:

  - the SETTER TYPE differs (`conflictsWithCanonical`) — delegation would not compile;
  - the attribute-vs-PROPERTY FORM differs — delegation compiles and is SILENTLY
    WRONG. This is the case `_controlled`'s element scope creates: `value` is the live
    DOM property of an `<input>` and a reflected content attribute of a `<button>`,
    and the shared canonical takes the PROPERTY form (see `Model.sharedAttrs`), so
    `TypedHtml.Button.value` delegating to it would quietly stop serializing to
    server-rendered markup — a property write on a node that has no live/default split
    to justify one, past a type checker that has nothing to object to. It fell the
    other way once, and then `TypedHtml.Input.value` delegating to a content-attribute
    canonical handed the controlled input a `defaultValue` write — issue #41,
    reintroduced through the re-export layer. Either direction needs a local setter;
    that is why this predicate is about DIVERGENCE and not about which form won.

This is deliberately a SUPERSET of `conflictsWithCanonical` rather than a widening of
it: that function answers "would delegation be ill-typed", which is what
`guardHomeAttrTypes` and `Model`'s conflict notes are about, and it is named for that.
Every DELEGATION site asks this one instead. (The comments at those sites already
claimed form was covered, back when only the type actually was.)

A third divergence — the same `elmName` carrying a different DOM NAME on two
components, via a CEM `fieldName` on one and not the other — is knowingly NOT tested
here. It is silently wrong for exactly the same reason, but no brand in this repo's
fixtures or downstreams exhibits it, and folding it in would move emitted bytes for a
case nobody has yet hit. Add it with its own fixture, not as a drive-by.

-}
divergesFromCanonical : Brand -> Attr.AttrSpec -> Bool
divergesFromCanonical brand a =
    -- Literally `conflictsWithCanonical` plus the form clause, and it CALLS it rather
    -- than restating `setterInputType c /= setterInputType a`. A second copy of "same
    -- type" is precisely the `datetime` bug — three code paths that disagreed about
    -- what a type conflict is.
    conflictsWithCanonical brand a
        || (case canonicalFor brand a.elmName of
                Just c ->
                    c.attrForm /= a.attrForm

                Nothing ->
                    False
           )


{-| The `Json.Encode.*` call that lifts a scalar setter's `value_` into the JSON
value a DOM property expects, chosen by the attribute's classified type.
-}
propEncoder : Attr.AttrType -> String
propEncoder t =
    case t of
        Attr.ABool ->
            "Json.Encode.bool value_"

        Attr.ANumber ->
            "Json.Encode.float value_"

        Attr.AInt ->
            "Json.Encode.int value_"

        _ ->
            "Json.Encode.string value_"


{-| Does a scalar setter emit as a DOM **property** (`Ir.property`) rather than a
content attribute?

Exactly one thing decides this: the spec's `attrForm`, which `Generate.Phantom.Model`
sets from the brand's `_controlled` roster and the per-component `attrForm` override.
This function used to be `List.member a.htmlName [ "value", "checked", "selected" ]` —
a second, hardcoded mechanism that shadowed the config one (`Attr.applyForm`, which
nothing called). One decision, one home.

Every other scalar — including a reflected scalar the CEM links to a backing property
via `fieldName` — emits as an **attribute**: setting the attribute reflects to the
property AND serializes to SSR, so a separate property write is redundant (and left
the value invisible to server-rendered markup — issue #41).

-}
emitsAsProperty : Attr.AttrSpec -> Bool
emitsAsProperty a =
    a.attrForm == Attr.AsProperty


{-| Does a module emitting LOCAL setters for `specs` need `import Json.Encode`?

Two things in a local setter body reach for it: a `Value <Row>` enum setter for an
attribute that also has a brand union, and a `Ir.property` write (`propEncoder`). A
module whose members all DELEGATE needs neither, because the encoding happens in
`<Lib>.Attributes`.

The property clause is `divergesFromCanonical` AND `emitsAsProperty`, not just the
first. Divergence is what makes the setter LOCAL; the FORM is what decides whether its
body mentions `Json.Encode` at all. The looser condition was harmless only as long as
divergence implied the property form, and it stopped implying it when the shared
canonical became the property form (`Model.sharedAttrs`): the elements that diverge from
it now are the content-attribute ones — `<button>`, `<data>`, `<option>` each keep a
local `Ir.attribute "value"` — so every one of their home modules got an import nothing
in the file used.

Shared by the per-component and per-home emitters rather than restated at each: the two
carried this condition spelled out twice, identically, and that is how a generated
import ends up present in one surface and absent in the other.

-}
needsJsonEncodeImport : Brand -> List Attr.AttrSpec -> Bool
needsJsonEncodeImport brand specs =
    specs
        |> List.any
            (\a ->
                (unionFor brand a.elmName /= Nothing && not (isEnumSpec a))
                    || (divergesFromCanonical brand a && emitsAsProperty a)
            )


{-| The brand's `_controlled` entry for a spec, if the roster covers it.
-}
controlledFor : Brand -> Attr.AttrSpec -> Maybe M.Controlled
controlledFor brand a =
    brand.controlled |> List.filter (\c -> c.htmlName == a.htmlName) |> List.head


{-| The RESYNC caveat, appended to a controlled property's docs when the roster says
it cannot resync (`"resyncs": false`).

`elm/virtual-dom`'s controlled-input machinery is hardcoded to two NAMES.
`_VirtualDom_diffFacts` re-emits a fact whose value is unchanged only for `value` and
`checked`, and `_VirtualDom_applyFacts` writes-when-the-DOM-differs only for those
two. `organizeFacts` stores PROP facts as raw JS values, so for every other name
`true === true` short-circuits the diff and the setter is skipped forever.

Consequence, and the reason this text is mandatory rather than nice-to-have: the
property form fixes INERTNESS (the content attribute only ever set the DEFAULT state)
but NOT resync. Once the user changes the selection, or unmutes with the native
controls, re-rendering the same model value cannot push the DOM back.

-}
resyncCaveat : M.Controlled -> String
resyncCaveat c =
    let
        listen =
            case c.resyncWith of
                Just ev ->
                    "a `" ++ ev ++ "` handler"

                Nothing ->
                    "a handler for the element's own change event"
    in
    "\n\nCAVEAT — this setter cannot RESYNC. `elm/virtual-dom` only re-forces an"
        ++ " unchanged controlled property for the names `value` and `checked`; `"
        ++ c.htmlName
        ++ "` is compared by identity, so re-rendering the same model value after the user"
        ++ " has changed it through the element's own UI will NOT push it back to the DOM."
        ++ " Keep the model in sync with "
        ++ listen
        ++ "."


{-| The elements whose `<attr>` takes the PROPERTY form, paired with the qualified
setter that reaches it. Empty when nothing in the brand does.

Used to point a caller reading a CONTENT-ATTRIBUTE setter at the live one. That
signpost is load-bearing rather than decorative: an element-scoped `_controlled` entry
leaves the out-of-scope elements on the content-attribute form in their own modules
(`TypedHtml.Button.value`, `TypedHtml.Select.value`), and nothing else in the emitted
output would say that `TypedHtml.Input.value` is the one that keeps tracking after the
user types (issue #41).

It does NOT describe the shared `<Lib>.Attributes` setter, which takes the PROPERTY
form when the brand's forms are split (see `Model.sharedAttrs`) and so is already the
live one.

-}
propertyFormOwners : Brand -> Attr.AttrSpec -> List ( String, String )
propertyFormOwners brand a =
    brand.comps
        |> List.filterMap
            (\comp ->
                if comp.attrs |> List.any (\x -> x.elmName == a.elmName && emitsAsProperty x) then
                    Just
                        ( "<" ++ comp.tag ++ ">"
                        , brand.lib ++ "." ++ (memberRef brand comp).module_ ++ "." ++ a.elmName
                        )

                else
                    Nothing
            )
        |> deduplicateBy Tuple.second
        |> List.sortBy Tuple.second


{-| The doc string for a controlled property's setter: the CEM description plus the
live-vs-default note, plus the resync caveat when the roster denies resync.

Keyed on the emitted FORM, not on roster membership: an attribute a component opted
back out of (`attrForm: { "<attr>": "attribute" }`), or one on an element outside the
roster entry's `elements` scope, writes the content attribute — so promising the caller
a live property would be a lie.

The attribute-form arm is not silent, though. When the SAME name is the live property
somewhere else in the brand, it names the elements and the setters that reach it: the
whole hazard of a split form is that both setters compile everywhere the capability row
admits them, so the only place the distinction can live is the docs.

-}
controlledDoc : Brand -> Attr.AttrSpec -> String
controlledDoc brand a =
    case
        if emitsAsProperty a then
            controlledFor brand a

        else
            Nothing
    of
        Nothing ->
            case ( controlledFor brand a, propertyFormOwners brand a ) of
                ( Just _, (_ :: _) as owners ) ->
                    Attr.docString a
                        ++ ("\n\nWrites the `" ++ a.htmlName ++ "` CONTENT attribute — correct for every")
                        ++ (" element whose `" ++ a.htmlName ++ "` REFLECTS, and the only form that")
                        ++ " serializes to server-rendered markup."
                        ++ (" It is NOT the live state on "
                                ++ (owners |> List.map Tuple.first |> String.join ", ")
                                ++ ", where the content attribute sets only the element's DEFAULT/initial `"
                                ++ a.htmlName
                                ++ "` and stops taking effect once the user has changed it; use "
                                ++ (owners |> List.map (\( _, ref ) -> "`" ++ ref ++ "`") |> String.join " / ")
                                ++ " for that."
                           )

                _ ->
                    Attr.docString a

        Just c ->
            Attr.docString a
                ++ ("\n\nSets the LIVE DOM property `" ++ Attr.propertyName a ++ "`, not the content attribute.")
                ++ (case c.companion of
                        Just companion ->
                            " The content attribute — the element's INITIAL state, and the only"
                                ++ " form that serializes to server-rendered markup — is `"
                                ++ companion
                                ++ "`."

                        Nothing ->
                            " This element has no backing content attribute for it."
                   )
                ++ (if c.resyncs then
                        ""

                    else
                        resyncCaveat c
                   )


{-| The `default*` companion for one controlled attribute of one brand: the CONTENT
attribute half of HTML's own live/default IDL split (`value` / `defaultValue`,
`checked` / `defaultChecked`, `selected` / `defaultSelected`, `muted` / `defaultMuted`).

It deliberately SHARES the base attribute's capability field (`defaultValue` claims
`{ c | value : Supported }`). Minting `defaultValue : Supported` instead would add a
field to every `Attrs` row in the library for no safety gain: an element that admits
`value` admits its default, and an element that does not admit `value` already rejects
`defaultValue` through the shared row.

-}
companionDecl : Brand -> M.Controlled -> String -> Attr.AttrSpec -> List String
companionDecl brand c companion a =
    let
        docText =
            "Set the `"
                ++ a.htmlName
                ++ "` CONTENT attribute — the element's DEFAULT/initial `"
                ++ a.htmlName
                ++ "`, mirroring HTML's own `"
                ++ companion
                ++ "` IDL attribute."
                ++ " Unlike `"
                ++ a.elmName
                ++ "` (which writes the live DOM property) this one SERIALIZES: it is what"
                ++ " server-rendered markup and `outerHTML` show, and it is what a form reset"
                ++ " restores to."
                ++ (if c.resyncs then
                        ""

                    else
                        " Pair it with `"
                            ++ a.elmName
                            ++ "` for the live state; see that setter's resync caveat."
                   )

        body =
            case a.type_ of
                Attr.ABool ->
                    -- A boolean CONTENT attribute is present/absent: any value at all
                    -- is the true state, so `False` must contribute NO fact (`Ir.none`),
                    -- never `Ir.attribute "muted" "false"`.
                    [ companion ++ " value_ ="
                    , "    if value_ then"
                    , "        Ir.attribute \"" ++ a.htmlName ++ "\" \"\""
                    , ""
                    , "    else"
                    , "        Ir.none"
                    ]

                Attr.ANumber ->
                    [ companion ++ " value_ ="
                    , "    Ir.attribute \"" ++ a.htmlName ++ "\" (String.fromFloat value_)"
                    ]

                Attr.AInt ->
                    [ companion ++ " value_ ="
                    , "    Ir.attribute \"" ++ a.htmlName ++ "\" (String.fromInt value_)"
                    ]

                _ ->
                    [ companion ++ " ="
                    , "    Ir.attribute \"" ++ a.htmlName ++ "\""
                    ]
    in
    [ ""
    , ""
    , doc docText
    , companion ++ " : " ++ setterInputType a ++ " -> Attr { c | " ++ a.capName ++ " : Supported } msg"
    ]
        ++ body


{-| Every `default*` companion earned by a list of specs: the roster entry, its
companion name, and the base spec it mirrors.

`suppressed` names the controlled attributes whose companion must NOT be emitted here
— the per-element `propertyOnly` list, for an element whose live property has no
backing content attribute. `<output>`'s `defaultValue` is a property with no content
attribute at all, and `<textarea>`'s default value is its CHILD TEXT (there is no
`value` content attribute on `<textarea>`), so for those the honest output is nothing
rather than an `Ir.attribute "value"` the browser ignores.

A spec that is in the roster but did NOT take the property form is skipped: either a
per-component `attrForm: { "<attr>": "attribute" }` opt-out or an element outside the
entry's `elements` scope means the plain setter already writes the content attribute,
so a `default*` beside it would be a second setter for the same fact. This is also
what stops the misleading companions the name-only roster used to mint: HTML gives
`HTMLOptionElement` and `HTMLButtonElement` no `defaultValue` IDL attribute at all, so
once `value` is scoped to `<input>` the `defaultValue` beside `<option>`'s `value`
disappears with it — and `<option>`'s own setter keeps writing the content attribute
that element actually wants, under the name HTML gives it.

Enum-typed controlled attributes are skipped: their setter is the `Value <Row>` one,
which this shape does not cover.

-}
companionsFor : Brand -> List String -> List Attr.AttrSpec -> List ( M.Controlled, String, Attr.AttrSpec )
companionsFor brand suppressed specs =
    specs
        |> List.filter emitsAsProperty
        |> List.filterMap
            (\a ->
                case ( controlledFor brand a, isEnumSpec a || unionFor brand a.elmName /= Nothing ) of
                    ( Just c, False ) ->
                        c.companion
                            |> Maybe.andThen
                                (\companion ->
                                    if List.member a.htmlName suppressed then
                                        Nothing

                                    else
                                        Just ( c, companion, a )
                                )

                    _ ->
                        Nothing
            )
        |> List.sortBy (\( _, companion, _ ) -> companion)


{-| Every `_variants` ergonomic setter earned by a list of specs: the roster entry
paired with the BASE spec it is emitted from.

Paired with the base spec because that is what carries the DOM name, the emitted
form (attribute vs property) and — critically — the capability row the variant
claims. `stepAsNumber` is `Float -> Attr { c | step : Supported } msg`: the same row
as `step`, so no element's `Attrs` record grows a field. Same reasoning as
`companionsFor`; see `M.Variant`.

`specs` is whatever surface is being emitted (the shared vocabulary's `plainAttrs`, a
module's re-exported specs), so a variant appears exactly where its base does and
never anywhere its base is absent.

-}
variantsFor : Brand -> List Attr.AttrSpec -> List ( M.Variant, Attr.AttrSpec )
variantsFor brand specs =
    brand.variants
        |> List.filterMap
            (\v ->
                -- Matched on the SETTER name, not the DOM name. See `M.Variant.base`:
                -- several elements can declare one HTML name under DIFFERENT setter names
                -- and therefore different capability rows (`_renames` moves `elmName` and
                -- `capName` together), and a variant belongs to exactly one of those rows.
                -- Filtering on `htmlName` matched them all and let `List.head` pick — an
                -- arbitrary row, silently, which is the `datetime` failure shape. `elmName`
                -- is unique on every surface this is called with (all of them dedupe by
                -- it), so there is nothing left to pick.
                specs
                    |> List.filter (\a -> a.elmName == v.base)
                    |> List.head
                    |> Maybe.map (\a -> ( v, a ))
            )


{-| The expression rendering a variant's `value_` into the attribute's string form.
One arm per `M.VariantInput` constructor — the closed set is the point: config cannot
ask for a renderer that does not exist.
-}
variantRender : M.VariantInput -> String
variantRender input =
    case input of
        M.VFloat ->
            "String.fromFloat value_"

        M.VInt ->
            "String.fromInt value_"

        M.VInts sep ->
            "String.join \"" ++ sep ++ "\" (List.map String.fromInt value_)"


{-| The Elm type a variant's setter takes.
-}
variantInputType : M.VariantInput -> String
variantInputType input =
    case input of
        M.VFloat ->
            "Float"

        M.VInt ->
            "Int"

        M.VInts _ ->
            "List Int"


{-| One `_variants` setter, emitted from its base spec.

It writes the SAME fact as the base setter — same DOM name, same attribute-vs-property
form — differing only in the Elm type it accepts and how that renders to a string. In
particular a variant on a CONTROLLED base goes through `Json.Encode.string`, not
`Json.Encode.float`: `elm/virtual-dom` compares property facts by identity against the
previously-organized raw JS value, so alternating a number fact and a string fact under
one property name across renders would make every diff a false positive. Writing the
same JS type as the base setter keeps `value` / `valueAsNumber` interchangeable
mid-render, and keeps virtual-dom's `value`-and-`checked` resync special-case working.

-}
variantDecl : M.Variant -> Attr.AttrSpec -> List String
variantDecl v a =
    let
        rendered =
            variantRender v.input

        body =
            if emitsAsProperty a then
                [ v.name ++ " value_ ="
                , "    Ir.property \"" ++ Attr.propertyName a ++ "\" (Json.Encode.string (" ++ rendered ++ "))"
                ]

            else
                [ v.name ++ " value_ ="
                , "    Ir.attribute \"" ++ a.htmlName ++ "\" (" ++ rendered ++ ")"
                ]

        docText =
            "Set the `"
                ++ a.htmlName
                ++ "` attribute from "
                ++ (case v.input of
                        M.VInts sep ->
                            "a list of integers, joined with `" ++ sep ++ "`"

                        M.VFloat ->
                            "a number"

                        M.VInt ->
                            "an integer"
                   )
                ++ ". An ergonomic alternative to `"
                ++ a.elmName
                ++ "`, which keeps the spec-correct `"
                ++ setterInputType a
                ++ "` type; this one cannot express every legal value, so reach for `"
                ++ a.elmName
                ++ "` when you need one it cannot. Both claim the same capability, mirroring"
                ++ " HTML's own `value` / `valueAsNumber` split."
    in
    [ ""
    , ""
    , doc docText
    , v.name ++ " : " ++ variantInputType v.input ++ " -> Attr { c | " ++ a.capName ++ " : Supported } msg"
    ]
        ++ body


{-| Controlled attributes whose companion is suppressed for the WHOLE brand: those
where every component declaring the attribute also declares it `propertyOnly`.

Suppression is per element, so the shared `<Lib>.Attributes` companion survives as
long as one element still has a backing content attribute for it; the element that
does not simply never re-exports it.

-}
brandSuppressed : Brand -> List String
brandSuppressed brand =
    brand.controlled
        |> List.filterMap
            (\c ->
                let
                    owners =
                        brand.comps
                            |> List.filter (\comp -> comp.attrs |> List.any (\a -> a.htmlName == c.htmlName))
                in
                if not (List.isEmpty owners) && List.all (\comp -> List.member c.htmlName comp.propertyOnly) owners then
                    Just c.htmlName

                else
                    Nothing
            )


{-| An inline expression applying a member-local setter to `value_`
(parenthesized where needed). Used when delegation to the canonical would be
ill-typed (cross-component scalar conflicts).
-}
setterExpr : Attr.AttrSpec -> String
setterExpr a =
    if emitsAsProperty a then
        -- Controlled attribute → DOM property so it updates after user input.
        "Ir.property \"" ++ Attr.propertyName a ++ "\" (" ++ propEncoder a.type_ ++ ")"

    else
        case ( a.type_, a.reactiveProp ) of
            ( Attr.ABool, _ ) ->
                -- Boolean → attribute present/absent (NEVER a JS property nor
                -- `classList []`), so web components observe it and no sibling
                -- `class` is clobbered.
                "(if value_ then\n        Ir.attribute \"" ++ a.htmlName ++ "\" \"\"\n\n     else\n        Ir.none\n    )"

            ( Attr.ANumber, _ ) ->
                -- Non-controlled number → attribute regardless of a `fieldName`
                -- reflection link: the attribute serializes to SSR and reflects
                -- to the backing property (#41).
                "Ir.attribute \"" ++ a.htmlName ++ "\" (String.fromFloat value_)"

            ( Attr.AInt, _ ) ->
                "Ir.attribute \"" ++ a.htmlName ++ "\" (String.fromInt value_)"

            _ ->
                "Ir.attribute \"" ++ a.htmlName ++ "\" value_"


{-| Canonical-typed co-located re-exports: each name delegates to (and is
annotated exactly like) the `<Lib>.Attributes` canonical — union-typed when
the attr is an enum anywhere in the brand. Names colliding with the module's
own declarations are skipped (the canonical in `<Lib>.Attributes` remains).
Returns ( exposedNames, sourceLines, needsValuesImport ).

`attrsRef` is the module reference used to reach the `<Lib>.Attributes`
canonical in the emitting module's import scope — the alias `"A"` in the
per-component modules (R4), or the full `<Lib>.Attributes` in the home modules.

`suppressed` is the union of the emitting module's members' `propertyOnly` lists: a
controlled attribute whose `default*` companion must NOT appear here because on those
elements the live property has no backing content attribute.

-}
reExportBlock : Brand -> String -> List String -> List String -> List Attr.AttrSpec -> ( List String, List String, Bool )
reExportBlock brand attrsRef excludeNames suppressed memberSpecs =
    let
        unionOf elmName =
            brand.unions |> List.filter (\e -> e.elmName == elmName) |> List.head

        canon =
            memberSpecs
                |> List.filter (\a -> not (List.member a.elmName excludeNames))
                |> List.filter (\a -> canonicalFor brand a.elmName /= Nothing)
                |> List.sortBy .elmName

        -- The `default*` companions the module's members earn, filtered by the same
        -- exclusion rules as their base setters: only what the shared vocabulary
        -- actually declares, and never a name the module already uses for something
        -- else.
        companions =
            companionsFor brand suppressed canon
                |> List.filter (\( _, n, _ ) -> not (List.member n excludeNames))

        lines =
            canon
                |> List.concatMap
                    (\a ->
                        if unionOf a.elmName /= Nothing || divergesFromCanonical brand a then
                            -- This member's setter differs from the shared canonical
                            -- in TYPE (delegating would be ill-typed) or in
                            -- attribute-vs-property FORM (delegating would compile and
                            -- write the wrong kind of fact — `<input>`'s live `value`
                            -- property vs `<progress>`'s content attribute). Either
                            -- way: emit a LOCAL setter. The row field is `Supported`
                            -- regardless, so this is sound.
                            [ ""
                            , ""
                            , doc (controlledDoc brand a)
                            , a.elmName ++ " : " ++ setterInputType a ++ " -> Attr { c | " ++ a.capName ++ " : Supported } msg"
                            , a.elmName ++ " value_ ="
                            , "    " ++ setterExpr a
                            ]

                        else
                            let
                                sig =
                                    setterInputType a ++ " -> Attr { c | " ++ a.capName ++ " : Supported } msg"
                            in
                            [ ""
                            , ""
                            , doc ("See `" ++ brand.lib ++ ".Attributes." ++ a.elmName ++ "`.")
                            , a.elmName ++ " : " ++ sig
                            , a.elmName ++ " ="
                            , "    " ++ attrsRef ++ "." ++ a.elmName
                            ]
                    )

        companionLines =
            companions
                |> List.concatMap
                    (\( c, n, a ) ->
                        if divergesFromCanonical brand a then
                            -- Same reason as the base setter above: the canonical
                            -- `default*` is emitted from the DOMINANT member's spec, so
                            -- a member that diverges in type or form gets its own. When
                            -- the divergence is the FORM, the canonical `default*` does
                            -- not exist at all (the canonical plain setter already
                            -- writes the content attribute, so `companionsFor` emits no
                            -- companion beside it) — delegating would not even resolve.
                            companionDecl brand c n a

                        else
                            [ ""
                            , ""
                            , doc ("See `" ++ brand.lib ++ ".Attributes." ++ n ++ "`.")
                            , n ++ " : " ++ setterInputType a ++ " -> Attr { c | " ++ a.capName ++ " : Supported } msg"
                            , n ++ " ="
                            , "    " ++ attrsRef ++ "." ++ n
                            ]
                    )

        -- The `_variants` setters the module's members earn, under the same exclusion
        -- rules as the companions.
        variants =
            variantsFor brand canon
                |> List.filter (\( v, _ ) -> not (List.member v.name excludeNames))

        variantLines =
            variants
                |> List.concatMap
                    (\( v, a ) ->
                        if divergesFromCanonical brand a then
                            -- Same reason as the base setter above: the canonical
                            -- variant is emitted from the canonical's spec, so a
                            -- member diverging in type or in attribute-vs-property form
                            -- gets its own rather than delegating. This is what keeps a
                            -- variant on a SCOPED controlled base honest: where `value`
                            -- is a content attribute, `valueAsNumber` must be
                            -- `Ir.attribute "value" (String.fromFloat …)`; where it is
                            -- the live property, `Json.Encode.string (String.fromFloat
                            -- …)` — see `variantDecl` for why the property form goes
                            -- through `string` and never `float`.
                            variantDecl v a

                        else
                            [ ""
                            , ""
                            , doc ("See `" ++ brand.lib ++ ".Attributes." ++ v.name ++ "`.")
                            , v.name ++ " : " ++ variantInputType v.input ++ " -> Attr { c | " ++ a.capName ++ " : Supported } msg"
                            , v.name ++ " ="
                            , "    " ++ attrsRef ++ "." ++ v.name
                            ]
                    )

        needsValues =
            False
    in
    ( (canon |> List.map .elmName)
        ++ (companions |> List.map (\( _, n, _ ) -> n))
        ++ (variants |> List.map (\( v, _ ) -> v.name))
    , lines ++ companionLines ++ variantLines
    , needsValues
    )



-- SHARED BUILD (R3): the pipe-builder mechanics, defined ONCE per brand.
--
-- `<Lib>.Forge.Internal` is the builder forge — the single place a `Builder`'s
-- capability rows are minted/mutated and where its record constructor is
-- exposed, so per-component modules can seed (`init`), advance
-- (`withAttribute`/`withChild`), and close (`toElement`) builders. It is a
-- NEUTRAL core module (NOT the `<Lib>.Build.*` builder surface), so both the
-- component `Internal.Types` modules and the `<Lib>.Build.*` modules depend on
-- it WITHOUT a cycle across the split-package DAG (core ← components ← builder).
-- Untrusted code importing it can forge any capability claim (an echo of the
-- `HtmlIr.Internal` forge decision); the `NoInternalImportOutsideAllowed` fence
-- holds the line. `<Lib>.Build` is the safe surface: opaque `Builder` + the
-- single `toElement`. Per-component `withX` are thin composed aliases over
-- `withAttribute`/`withChild`, and each component's `Builder` is a type alias
-- over `Internal.Builder` with its own closed attribute `row` (so cross-builder
-- composition stays guarded by the phantom `row`).


buildInternalModule : Brand -> Elm.File
buildInternalModule brand =
    let
        lib =
            brand.lib
    in
    file [ lib, "Forge", "Internal" ]
        (String.join "\n"
            [ "module " ++ lib ++ ".Forge.Internal exposing"
            , "    ( Builder(..)"
            , "    , init, withAttribute, withChild, toElement"
            , "    )"
            , ""
            , "{-| The builder forge for the `" ++ lib ++ "` brand — the ONE place a `Builder`'s"
            , "capability rows are minted and its record constructor is exposed. Every"
            , "per-component `build`/`withX`/`toElement` composes these levers; the mechanics"
            , "are defined here exactly once. Untrusted code that imports this module can forge"
            , "any capability claim, exactly like `HtmlIr.Internal` — the"
            , "`NoInternalImportOutsideAllowed` fence is load-bearing."
            , ""
            , "@docs Builder"
            , "@docs init, withAttribute, withChild, toElement"
            , ""
            , "-}"
            , ""
            , "import HtmlIr.Attribute exposing (Attr)"
            , "import HtmlIr.Element exposing (Element)"
            , "import HtmlIr.Internal as Ir"
            , "import HtmlIr.Node exposing (Node)"
            , ""
            , ""
            , "{-| The shared pipe-builder. `attrCaps`/`slotCaps` are phantom write-once"
            , "capability rows; `row` is the host element's closed attribute row; `accepts` is"
            , "the element-kind phantom produced on close; `tag` is the custom-element tag"
            , "closed over at `init`. Each component aliases this with its own `row` and"
            , "`accepts = (Is s)`, and exposes narrowed `withX` setters."
            , "-}"
            , "type Builder row attrCaps slotCaps accepts msg"
            , "    = Builder"
            , "        { tag : String"
            , "        , attrs : List (Attr row msg)"
            , "        , children : List (Node msg)"
            , "        }"
            , ""
            , ""
            , "{-| Seed a builder with its tag, initial attributes, and initial children."
            , "-}"
            , "init : String -> List (Attr row msg) -> List (Node msg) -> Builder row attrCaps slotCaps accepts msg"
            , "init tag attrs children ="
            , "    Builder { tag = tag, attrs = attrs, children = children }"
            , ""
            , ""
            , "{-| Prepend one attribute, advancing the attribute-capability row (phantom)."
            , "-}"
            , "withAttribute : Attr row msg -> Builder row attrCapsIn slotCaps accepts msg -> Builder row attrCapsOut slotCaps accepts msg"
            , "withAttribute attr (Builder b) ="
            , "    Builder { b | attrs = attr :: b.attrs }"
            , ""
            , ""
            , "{-| Prepend one child node, advancing the slot-capability row (phantom)."
            , "-}"
            , "withChild : Node msg -> Builder row attrCaps slotCapsIn accepts msg -> Builder row attrCaps slotCapsOut accepts msg"
            , "withChild child (Builder b) ="
            , "    Builder { b | children = child :: b.children }"
            , ""
            , ""
            , "{-| Close the builder into an element — defined ONCE for the brand. Attributes"
            , "and children are reversed so they render in the order they were piped on."
            , "-}"
            , "toElement : Builder row attrCaps slotCaps accepts msg -> Element accepts admittedBy msg"
            , "toElement (Builder b) ="
            , "    Ir.fromNode (Ir.node b.tag (List.reverse b.attrs) (List.reverse b.children))"
            , ""
            ]
        )


buildModule : Brand -> List Comp -> Elm.File
buildModule brand comps =
    let
        lib =
            brand.lib

        isAliasNames =
            comps |> List.map (\c -> Naming.pascal c.name ++ "Is")

        isAliases =
            comps
                |> List.concatMap
                    (\c ->
                        let
                            isName =
                                Naming.pascal c.name ++ "Is"

                            aliasFrom =
                                lib ++ ".Build." ++ c.name ++ ".Is"
                        in
                        [ ""
                        , ""
                        , doc ("The `" ++ c.name ++ "` kind phantom — annotate with `List (Element (" ++ isName ++ " s) admittedBy msg)`.")
                        , "type alias " ++ isName ++ " s ="
                        , "    " ++ aliasFrom ++ " s"
                        ]
                    )
    in
    file [ lib, "Build" ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ lib ++ ".Build exposing"
                  , exposeBlock
                        [ [ "Builder", "toElement" ]
                        , isAliasNames
                        ]
                  , ""
                  , "{-| The shared builder surface for the `" ++ lib ++ "` brand: the opaque `Builder`"
                  , "and the single `toElement` that closes any component's builder. Per-component"
                  , "modules provide the seeds (`build`) and the narrowed `withX` setters; they all"
                  , "share this one representation, so `toElement` is defined once (in"
                  , "`" ++ lib ++ ".Forge.Internal`) and re-exported here."
                  , ""
                  , "The `Is` aliases (`ButtonIs`, `CardIs`, …) let you annotate a phantom-kind"
                  , "type without importing the component or its builder module."
                  , ""
                  , "@docs Builder"
                  , "@docs toElement"
                  , "@docs " ++ String.join ", " isAliasNames
                  , ""
                  , "-}"
                  , ""
                  ]
                , [ "import HtmlIr.Element exposing (Element)"
                  , "import " ++ lib ++ ".Forge.Internal as Internal"
                  ]
                    ++ (comps
                            |> List.map (\c -> "import " ++ lib ++ ".Build." ++ c.name)
                            |> List.sort
                       )
                    ++ [ ""
                       , ""
                       , "{-| The shared pipe-builder — see each component's `Builder` alias for its"
                       , "narrowed, brand-typed form."
                       , "-}"
                       , "type alias Builder row attrCaps slotCaps accepts msg ="
                       , "    Internal.Builder row attrCaps slotCaps accepts msg"
                       , ""
                       , ""
                       , "{-| Close any builder into its element."
                       , "-}"
                       , "toElement : Builder row attrCaps slotCaps accepts msg -> Element accepts admittedBy msg"
                       , "toElement ="
                       , "    Internal.toElement"
                       ]
                    ++ isAliases
                    ++ [ "" ]
                ]
            )
        )



