module Generate.Phantom.Model exposing
    ( Brand, Comp, Controlled, EnumSpec, KindField, Marker(..), ResolvedSlot, SetAlias, SlotContent(..)
    , Variant, VariantInput(..)
    , decodePhantomFlag, decodeEmitFactsBundleFlag, resolve
    , knownSharedRole, sharedRoleOf, sharedRoleOfField, unknownSharedRoleError, unknownSharedFieldError
    )

{-| The phantom pipeline's brand model: decode the new config primitives
(`kind` / `admits` / `parents` / `_sets` / `_atoms` / `_globals`)
from `_config`, resolve them against the CEM components, and VALIDATE loudly
(unknown kind refs, unknown set refs, the R1 shared-admittedBy discipline).

The emitter (`Generate.Phantom.Emit`) is a pure projection of the `Brand`
value produced here.

@docs Brand, Comp, Controlled, EnumSpec, KindField, Marker, ResolvedSlot, SetAlias, SlotContent
@docs Variant, VariantInput
@docs decodePhantomFlag, resolve

The closed cross-library atom vocabulary, shared with the emitter so the same rule
is enforced at resolution (in config vocabulary) and at emission (in row-field
vocabulary):

@docs knownSharedRole, sharedRoleOf, sharedRoleOfField, unknownSharedRoleError, unknownSharedFieldError

-}

import Attr
import Cem
import Dict exposing (Dict)
import Json.Decode as D
import Naming


{-| Kind-row field markers: the library's private `Brand` or the IR's
cross-library `Shared`.
-}
type Marker
    = MBrand
    | MShared


{-| The CANONICAL cross-library atom vocabulary — every legal `shared:<role>`.

A `Shared`-marked field is the one thing in this system that unifies ACROSS
package boundaries, which means its spelling is a contract between brands that
never see each other's source. Nothing enforced that contract before: `shared:`
was an open namespace, so `shared:phrasng` in one brand's config minted a field
no other brand would ever name, and the result was a private-by-accident kind
wearing cross-library clothes — exactly the `"html"` defect (RC5), which cost a
release cycle to notice.

  - `text` / `icon` / `link` — CONTENT atoms. A leaf a brand contributes and any
    opted-in slot admits.
  - `flow` / `phrasing` — HTML CONTENT CATEGORIES, per WHATWG. A producer names
    its NARROWEST category (`span` → phrasing, `div` → flow); a slot names EVERY
    category it admits (a flow slot names both, since phrasing ⊆ flow). This is
    what lets a native element enter a design-system slot that means "arbitrary
    HTML goes here" without an escape hatch.

Adding a role here is a deliberate act: it widens the vocabulary every brand
shares. Keep it sorted.

-}
sharedAtomVocabulary : List String
sharedAtomVocabulary =
    [ "flow", "icon", "link", "phrasing", "text" ]


{-| The `shared:<role>` config spelling a `Shared` field name came from —
the inverse of the `"shared" ++ Naming.pascal role` construction. Used to
report an unknown role in the vocabulary the config author actually wrote.
-}
sharedRoleOfField : String -> String
sharedRoleOfField field =
    Naming.decapitalize (String.dropLeft 6 field)


{-| Is this `shared:<role>` reference in the canonical vocabulary?
-}
knownSharedRole : String -> Bool
knownSharedRole role =
    List.member role sharedAtomVocabulary


{-| The role a config kind SPELLING names, if it names a shared atom at all.

`"shared:"` is the whole grammar that separates a cross-library atom from a
brand-private kind. Every reader of that prefix goes through here — slot `kinds`,
a component's `kind`, and the emitter's guard — because each site that
re-derived it with `String.startsWith` by hand was a site that could be, and
was, forgotten when a rule was tightened without touching every reader.

-}
sharedRoleOf : String -> Maybe String
sharedRoleOf spelling =
    if String.startsWith "shared:" spelling then
        Just (String.dropLeft 7 spelling)

    else
        Nothing


{-| The row field a shared role denotes: `icon` → `sharedIcon : Shared`.
-}
sharedKindField : String -> KindField
sharedKindField role =
    { field = "shared" ++ Naming.pascal role, marker = MShared }


{-| One "unknown shared atom" error, phrased in config vocabulary.
-}
unknownSharedRoleError : String -> String -> String
unknownSharedRoleError where_ role =
    where_
        ++ ": unknown shared atom 'shared:"
        ++ role
        ++ "' — the cross-library vocabulary is "
        ++ (sharedAtomVocabulary |> List.map (\r -> "shared:" ++ r) |> String.join ", ")
        ++ ". A `Shared` field only unifies across packages when every brand spells it"
        ++ " the same way, so an unlisted role is a private kind wearing a shared name."


{-| The same complaint, phrased in EMISSION vocabulary — the row field about to be
written rather than the config key that asked for it.

Two messages for one rule because they are read by different people at different
moments. `unknownSharedRoleError` fires during resolution, at a config key the
author just typed. This one fires at the byte-writing boundary, where the only
thing left is a field name; it is a backstop for a field that reached emission by
some route resolution does not walk, so it must be legible without the config in
front of you.

-}
unknownSharedFieldError : String -> String -> String
unknownSharedFieldError where_ field =
    where_
        ++ ": the row field '"
        ++ field
        ++ "' is marked `Shared`, but '"
        ++ sharedRoleOfField field
        ++ "' is not in the cross-library vocabulary — the legal fields are "
        ++ (sharedAtomVocabulary
                |> List.map (\r -> "shared" ++ Naming.pascal r ++ " (shared:" ++ r ++ ")")
                |> String.join ", "
           )
        ++ ". A `Shared` field only unifies across packages when every brand spells it"
        ++ " the same way, so an unlisted spelling is a private kind wearing a shared name."


{-| One field of a kind row (`button : Brand` / `sharedText : Shared`).
-}
type alias KindField =
    { field : String
    , marker : Marker
    }


{-| A named kind set from `_sets`, emitted as an alias in `<Lib>.Kind`.
-}
type alias SetAlias =
    { name : String
    , pascal : String
    , fields : List KindField
    }


{-| What one slot admits.
-}
type SlotContent
    = Permissive
    | SetContent SetAlias
    | Fields (List KindField)


{-| A resolved slot.
-}
type alias ResolvedSlot =
    { name : String
    , content : SlotContent
    , multi : Bool
    , required : Bool
    }


{-| One enum attribute: the per-component (or union) alias name + tokens.
`provenance` is the upstream TypeScript alias name, kept for docs.
-}
type alias EnumSpec =
    { elmName : String
    , aliasName : String
    , tokens : List String
    , provenance : Maybe String
    }


{-| One entry of the brand's CONTROLLED roster (`_controlled`): an attribute whose
LIVE state is a DOM property, not the content attribute.

This roster is the single source of truth for "which attributes emit as
`Ir.property`". It replaces a hardcoded `[ "value", "checked", "selected" ]` list
inside the emitter, which duplicated — and silently outranked — the `attrForm`
config override (see `Attr.AttrForm`).

  - `htmlName` — the content-attribute name, which for every member of this roster
    is also the IDL property name (`Attr.propertyName`).
  - `companion` — the `default*` setter emitted alongside, which writes the CONTENT
    attribute. `Nothing` means the element/brand has no backing content attribute,
    so no companion is honest (`<output>`'s `defaultValue` is a property with no
    content attribute at all; `<textarea>`'s default value is its CHILD TEXT).
  - `resyncs` — does `elm/virtual-dom`'s controlled-input machinery re-force this
    property when the model value has not changed? TRUE for exactly `value` and
    `checked`: `_VirtualDom_diffFacts` re-emits an unchanged fact, and
    `_VirtualDom_applyFacts` writes when the DOM differs, for those two NAMES ONLY.
    Everything else is compared with `===` against the previously-organized (raw JS)
    value, so an unchanged `True` is skipped forever — the property form fixes
    INERTNESS but not RESYNC. `False` makes the emitter document that.
  - `resyncWith` — the DOM event a caller should listen to in order to keep the model
    in sync by hand (`change` for `selected`, `volumechange` for `muted`). Named in
    the generated docs when `resyncs` is `False`.
  - `elements` — the ELEMENT SCOPE: which elements' `<attr>` is actually controlled.
    `Nothing` means every element declaring it (the roster's original, name-only
    behaviour, kept as the default so a brand that gains no `elements` key emits
    byte-identical output). `Just names` restricts the property form to those
    elements — matched against a component's TAG (`"input"`) or its declaration name
    (`"Input"`), the same either-name latitude `Attr.applyForm` allows — and leaves
    the attribute a plain content attribute everywhere else.

Why the scope is not optional in practice: a name-only roster is a claim about
`HTMLElement`, and `value` is not one attribute. In `elm-typed-html`'s manifest SEVEN
elements declare a `value` content attribute (`button`, `data`, `input`, `li`,
`meter`, `option`, `progress`) and their IDL types differ — `DOMString` on
`button`/`data`/`option`, `long` on `li`, and **`double`** on `meter`/`progress`.
Web IDL rejects a non-finite `double` with a **TypeError**, so `Ir.property "value"
(Json.Encode.string "abc")` on a `<progress>` THROWS inside `_VirtualDom_applyFacts`
— during patch, where an exception takes down the whole Elm render loop, not just
that node. Only `input` needs the property form at all (its live value diverges from
the content attribute once the dirty-value flag is set); the other six REFLECT, so
the content attribute is both correct and SSR-visible. Scoping is therefore the fix
for a crash, not a tidying-up.

The scope also removes a cosmetic lie the name-only roster produced: a `default*`
companion on every element in the roster, including the ones HTML gives no
`defaultValue` IDL attribute (`HTMLOptionElement`, `HTMLButtonElement`, …). Once the
element is out of scope its plain setter already writes the content attribute, so
`companionsFor` drops the companion for the same reason it drops one for an
`attrForm` opt-out: two setters for one fact.

-}
type alias Controlled =
    { htmlName : String
    , companion : Maybe String
    , resyncs : Bool
    , resyncWith : Maybe String
    , elements : Maybe (List String)
    }


{-| One entry of the brand's VARIANT roster (`_variants`): an extra, ergonomically
typed setter for an attribute whose spec-correct type is a string.

HTML's own convention, which this follows: `HTMLInputElement` has `value`,
`valueAsNumber` and `valueAsDate`. The BASE setter keeps the type the spec demands —
`step : String`, because `step="any"` is a legal keyword no `Float` can express, and
`coords : String`, because `coords="0,0,82,126"` is a comma-separated LIST — and the
variant adds the convenient one beside it.

A variant claims the BASE attribute's capability row (`stepAsNumber` claims
`step : Supported`), exactly like a `_controlled` `default*` companion, so no element's
`Attrs` record grows a field: an element that admits `step` admits every way of
writing it, and one that does not already rejects them all.

  - `base` — the base attribute's SETTER name, which is the camel-cased HTML name
    unless `_renames` moved it. It MUST be declared by some component in the brand
    under that name; a typo would otherwise emit nothing at all, silently.

    The setter name and not the DOM name, because the row follows the setter. When one
    HTML name is declared by several elements under DIFFERENT setter names — a
    `<progress>` whose `value` is `_renames`d to `valueNumeric` because its IDL type is
    `double` and the shared `value` vocabulary would crash it — a variant of `value`
    belongs on the elements that still call it `value`, and nowhere else. Keying on the
    DOM name put it on all of them and left "which row does it claim" to a `List.head`
    over the matches; see `Emit.variantsFor`.

  - `name` — the emitted setter name (`stepAsNumber`). Shares the
    `<Lib>.Attributes` namespace, so it is collision-checked there.
  - `input` — the Elm type it takes and how that renders into the attribute string.

-}
type alias Variant =
    { base : String
    , name : String
    , input : VariantInput
    }


{-| The Elm input type a `_variants` setter takes, and therefore how it renders to the
attribute string. Deliberately a CLOSED set: each constructor is one renderer in
`Emit.variantRender`, and config that asks for anything else fails loud rather than
degrading to a string setter (the `_globals` lesson — an unrecognized `type` that
quietly became `String -> Attr` is what inverted `hidden "false"`).

  - `VFloat` — `Float`, via `String.fromFloat` (`stepAsNumber`, `valueAsNumber`).
  - `VInt` — `Int`, via `String.fromInt`.
  - `VInts sep` — `List Int`, joined with `sep` (`coordsAsInts`, separator `","`).

-}
type VariantInput
    = VFloat
    | VInt
    | VInts String


{-| A resolved component.

`resolvedCtor` is the Elm barrel constructor name after K7 resolution: normally
equal to `ctor`, but when the ctor would collide with an `_atoms` name in the
barrel module, it reverts to the full-tag camel form (`fluent-text` → `fluentText`).

-}
type alias Comp =
    { name : String
    , ctor : String
    , resolvedCtor : String
    , tag : String
    , produces : KindField
    , attrs : List Attr.AttrSpec
    , enums : List EnumSpec
    , events : List Cem.Event
    , slots : List ResolvedSlot
    , admittedBy : Maybe (List String)
    , description : String
    , home : Maybe String
    , transparent : Bool
    , roles : Maybe (List String)
    , actionCaps : Maybe (List String)
    , eventOverrides : List EventOverride
    , requiredAttrs : List String
    , actionMap : List ( String, String )

    -- Controlled attributes (`_controlled`) whose `default*` companion this element
    -- must NOT get, because on THIS element the live property has no backing content
    -- attribute (config `propertyOnly`). The property setter is still emitted.
    , propertyOnly : List String

    -- Attributes this element DECLARES but which `elm/virtual-dom` cannot express,
    -- so no setter is emitted and the `Attrs` row has no field for them
    -- (`Attr.kernelBlockedReason`). Kept rather than thrown away because the
    -- emitted `<Lib>.Attributes` docs name them: a `<button>` with no `formaction`
    -- setter is the kind of gap a reader "fixes" by adding one back, and the note
    -- is what stops that.
    , blockedAttrs : List Attr.AttrSpec

    -- Config-supplied doc content (`examples`/`docMeta` config keys), rendered
    -- into the module doc comment by `Docs.examplesSection`/`Docs.docMetaMarker`
    -- in `Emit.elm`. Opt-in per component; absent ⇒ `[]`, so most components
    -- emit no `## Examples` section at all.
    , examples : List RawExample
    , docMeta : List ( String, String )
    }


{-| The whole resolved brand.

`resolvedEventHandlers` maps each shared event's raw name to its resolved Elm
handler name after K4 collision resolution. When the prefix-stripped form of a
brand event collides with a lossless native-event handler, the brand event
reverts its prefix-strip (`onWaError` instead of `onError`). The native event
keeps the plain name. Both members of the `on<X>`/`on<X>With` pair rename
together.

`collapseNotes` carries one deterministic stderr line per K2/K3 collapse
(e.g. `"collapsed CEM attr 'id' on w-textfield into global"`), followed by one line
per cross-component attribute TYPE CONFLICT (which type the shared canonical took,
and which components therefore keep a locally-typed setter). Order is
stable: K3 notes sorted by component then attr name; K2 notes sorted
component then attr name; conflict notes sorted by attr name. The generator surfaces
these through the existing `info` channel so they appear on stdout without touching
emitted file bytes.

It also carries one line per KERNEL-BLOCKED attribute omitted from the emitted
surface — an attribute whose DOM name `elm/virtual-dom` rewrites or ignores, so
that no setter for it could work (`Attr.kernelBlockedReason`). That case is
reported rather than fatal because the manifest is right and the kernel is what
cannot express it, so there is no config edit that would clear a failure; see
`Attr.kernelBlockedReason` for the full argument.

-}
type alias Brand =
    { lib : String
    , eventPrefix : String
    , comps : List Comp
    , sets : List SetAlias
    , unions : List EnumSpec
    , sharedAttrs : List Attr.AttrSpec
    , sharedEvents : List Cem.Event
    , resolvedEventHandlers : Dict String String
    , atoms : List String
    , globals : List Attr.AttrSpec

    -- The `"row": "open"` globals, held APART from `globals` rather than flagged
    -- inside it, because the split is exactly the closed-row question and two
    -- consumers must answer it differently from all the others.
    --
    -- `Emit.attrsFields` (the closed `Attrs` alias) and `Emit.attrPipes` (the
    -- `with<Field>` builder pipes) read `globals` ALONE — an open global has no
    -- row membership to declare or to consume. EVERY other consumer reads both
    -- (`Emit.allGlobals`): an open global still occupies the `<Lib>.Attributes`
    -- namespace, still mints its `<Lib>.Values` union and tokens, still needs
    -- exposing, and is still a global in `Review.Facts`. Reading `globals` alone
    -- in any of those emits a setter that is duplicated, unexposed, or annotated
    -- against a type that was never minted.
    , openGlobals : List Attr.AttrSpec
    , controlled : List Controlled
    , variants : List Variant
    , aria : Maybe AriaConfig
    , actions : Maybe ActionsRoster
    , legacyHtml : Bool
    , collapseNotes : List String
    , tokenRenames : Dict String String

    -- Every enum token in the brand, mapped to the STRING it renders to
    -- (`Ir.token "<value>"`). Identity for every token that came from an `AEnum`,
    -- which is all of them unless a config `attrTypes` MAP override asked for a
    -- token whose Elm name differs from its HTML value (`{"always": "true"}`).
    --
    -- This is the sibling of `tokenRenames`, transposed: that one changes a token's
    -- IDENTIFIER and keeps its payload; this one changes its PAYLOAD and keeps its
    -- identifier. Keeping it brand-wide (rather than threading pairs through
    -- `EnumSpec.tokens`) is what makes "one token, one string" checkable — see
    -- `tokenValueErrors` in `resolveWith`, which fails the run when two attributes
    -- ask one token name to render two different strings.
    , tokenValues : Dict String String
    , elementRenames : Dict String String

    -- Every ( DOM name, reason ) the brand declared and this generator REFUSED to
    -- emit a setter for, because `elm/virtual-dom` rewrites or ignores the name
    -- (`Attr.kernelBlockedReason`). Sorted by name and deduplicated, pooled from
    -- both sources: the `_globals` roster and every component's own attributes.
    --
    -- It exists so the omission is documented where a user of the library will
    -- look — `Emit.attributesModule` turns it into a paragraph of the emitted
    -- `<Lib>.Attributes` module docs, naming the kernel function responsible. The
    -- info-channel notes tell whoever RAN the generator; this tells whoever reads
    -- the docs six months later and wonders where `formaction` went.
    , kernelBlocked : List ( String, String )
    }



-- RAW CONFIG DECODE


type RawKindRef
    = RAny
    | RShared String
    | RSet String
    | RBrand String


type alias RawSlot =
    { name : String, kinds : List RawKindRef, multi : Bool, required : Bool }


type alias RawComp =
    { kind : Maybe String
    , admits : List RawSlot
    , parents : Maybe (List String)
    , home : Maybe String
    , transparent : Bool
    , roles : Maybe (List String)
    , requiredAction : Maybe (List String)
    , eventOverrides : List EventOverride
    , eventPayloads : List EventPayload
    , requiredAttrs : List String
    , actionMap : List ( String, String )
    , attrForm : List ( String, String )
    , propertyOnly : List String
    , examples : List RawExample
    , docMeta : List ( String, String )
    }


{-| A config-supplied usage example (`examples` config key), rendered into the
component module's `## Examples` doc-comment section by `Docs.examplesSection`.
Mirrors `Generate.Types.ExampleRecord` (the legacy front-end's decoded shape)
but is decoded independently here because the phantom pipeline's `RawComp`
decoder is self-contained (see the module doc). `codeRecord` is accepted by
the legacy decoder but has never been consumed by any renderer, so it is not
carried forward here.
-}
type alias RawExample =
    { title : String, code : String, section : Maybe String }


{-| A per-component typed event decoder (config `events`): decode `path`
inside the DOM event as `type_`.
-}
type alias EventOverride =
    { name : String, path : List String, type_ : String }


{-| A per-component standard-payload event annotation (config `eventPayloads`).
Bakes one of the closed-vocabulary native-control decoders into the emitted
handler, turning `on<X> : msg -> Attr …` into `on<X> : (payload -> msg) -> Attr …`.

  - `event` — the DOM event name to listen on (e.g. `"input"`, `"change"`).
  - `setter` — the Elm setter + capability field name (e.g. `onInput`, `onCheck`).
  - `payload` — which closed decoder to bake (`targetValue` / `targetChecked`).

-}
type alias EventPayload =
    { event : String, setter : String, payload : Cem.Payload }


{-| One `_actions` wrapper entry (m3e's behavioural-action roster).
-}
type alias ActionWrapper =
    { ctor : String, cap : String, variant : String, comp : String, doc : String }


{-| The `_actions` roster.
-}
type alias ActionsRoster =
    { forWrappers : List ActionWrapper
    , nullaryWrappers : List ActionWrapper
    , bottomSheetComp : Maybe String
    , dialogActionComp : Maybe String
    }


{-| Brand-wide ARIA data (`_aria`): the role token vocabulary, the enumerated
aria-\* states worth value-typing, and the universal open-String aria-\* attrs.
-}
type alias AriaConfig =
    { roles : List String
    , states : List ( String, List String )
    , universal : List String
    }


type alias RawConfig =
    { phantom : Bool
    , brand : Maybe String
    , sets : Dict String (List String)
    , atoms : List String

    -- Each entry paired with its `row` axis: `True` = open (`Attr c msg`),
    -- `False` = closed. Partitioned into `Brand.openGlobals` / `Brand.globals`
    -- at the one kernelBlocked choke point in `resolveWith`.
    , globals : List ( Bool, Attr.AttrSpec )
    , controlled : List Controlled
    , variants : List Variant
    , exclude : List String
    , aria : Maybe AriaConfig
    , kinds : List String
    , actions : Maybe ActionsRoster
    , legacyHtml : Bool
    , components : Dict String RawComp
    , renames : RawRenames
    }


{-| The `_renames` config override hatch.

Per-component overrides under the component key (e.g. `"wa-input": { "attr:with-hint": "hintFlag" }`);
brand-level overrides under `_events`, `_tokens`, `_elements` keys.

-}
type alias RawRenames =
    { components : Dict String (Dict String String)
    , events : Dict String String
    , tokens : Dict String String
    , elements : Dict String String
    }


{-| Is the phantom pipeline requested? (`_config._phantom == true`)
-}
decodePhantomFlag : D.Value -> Bool
decodePhantomFlag flags =
    D.decodeValue (D.at [ "_config", "_phantom" ] D.bool) flags
        |> Result.withDefault False


{-| Is the M1.c facts-bundle Face C emission requested? (`_config._emitFactsBundle == true`)
Off by default, so `files`' byte output — and therefore the A/B reference bar —
is unaffected by any caller that does not ask for it.
-}
decodeEmitFactsBundleFlag : D.Value -> Bool
decodeEmitFactsBundleFlag flags =
    D.decodeValue (D.at [ "_config", "_emitFactsBundle" ] D.bool) flags
        |> Result.withDefault False


kindRef : String -> RawKindRef
kindRef s =
    case sharedRoleOf s of
        Just role ->
            RShared role

        Nothing ->
            if s == "any" then
                RAny

            else if String.startsWith "@" s then
                RSet (String.dropLeft 1 s)

            else
                RBrand s


rawSlotDecoder : String -> D.Decoder RawSlot
rawSlotDecoder name =
    D.map3 (RawSlot name)
        (D.field "kinds" (D.list (D.map kindRef D.string)))
        (D.maybe (D.field "multi" D.bool) |> D.map (Maybe.withDefault False))
        (D.maybe (D.field "required" D.bool) |> D.map (Maybe.withDefault False))


admitsDecoder : D.Decoder (List RawSlot)
admitsDecoder =
    D.keyValuePairs D.value
        |> D.andThen
            (\pairs ->
                pairs
                    |> List.map
                        (\( slotName, v ) ->
                            case D.decodeValue (rawSlotDecoder slotName) v of
                                Ok s ->
                                    D.succeed s

                                Err e ->
                                    D.fail (slotName ++ ": " ++ D.errorToString e)
                        )
                    |> List.foldr (D.map2 (::)) (D.succeed [])
            )


requiredActionDecoder : D.Decoder (Maybe (List String))
requiredActionDecoder =
    D.maybe (D.at [ "required", "action" ] D.string)
        |> D.map
            (Maybe.map
                (\s ->
                    s
                        |> String.replace "action:" ""
                        |> String.split ","
                        |> List.map String.trim
                        |> List.filter (not << String.isEmpty)
                )
            )


eventOverridesDecoder : D.Decoder (List EventOverride)
eventOverridesDecoder =
    D.keyValuePairs
        (D.oneOf
            [ D.map2 (\path ty -> { path = path, type_ = ty })
                (D.field "path" (D.list D.string))
                (D.oneOf [ D.field "type" D.string, D.succeed "string" ])
            , D.map (\field -> { path = [ "detail", field ], type_ = "string" })
                (D.field "detail" D.string)
            ]
        )
        |> D.map (List.map (\( n, o ) -> { name = n, path = o.path, type_ = o.type_ }))


eventPayloadsDecoder : D.Decoder (List EventPayload)
eventPayloadsDecoder =
    let
        payloadDecoder : D.Decoder Cem.Payload
        payloadDecoder =
            D.string
                |> D.andThen
                    (\s ->
                        case s of
                            "targetValue" ->
                                D.succeed Cem.TargetValue

                            "targetChecked" ->
                                D.succeed Cem.TargetChecked

                            _ ->
                                D.fail ("eventPayloads: unknown payload decoder '" ++ s ++ "' (expected \"targetValue\" or \"targetChecked\")")
                    )
    in
    D.keyValuePairs
        (D.map2 (\setter payload -> { setter = setter, payload = payload })
            (D.field "setter" D.string)
            (D.field "payload" payloadDecoder)
        )
        |> D.map (List.map (\( ev, o ) -> { event = ev, setter = o.setter, payload = o.payload }))


{-| The per-component `attrForm` override map (`{ "<attr>": "attribute" | "property" }`).

An unknown value fails LOUD rather than being ignored: `Attr.applyForm` treats
anything it does not recognise as "leave the spec alone", so a typo like
`"properety"` would otherwise silently keep the default form — precisely the class of
silent no-op this whole override exists to fix (issue #33 / #41).

-}
attrFormDecoder : D.Decoder (List ( String, String ))
attrFormDecoder =
    D.keyValuePairs
        (D.string
            |> D.andThen
                (\s ->
                    if s == "attribute" || s == "property" then
                        D.succeed s

                    else
                        D.fail ("attrForm: unknown form '" ++ s ++ "' (expected \"attribute\" or \"property\")")
                )
        )


{-| The brand-level `_controlled` roster (`_config._controlled`).

    "_controlled": {
      "value":    { "companion": "defaultValue", "elements": ["input"] },
      "selected": { "companion": "defaultSelected", "elements": ["option"], "resyncs": false, "resyncWith": "change" },
      "muted":    { "companion": "defaultMuted", "elements": ["audio", "video"], "resyncs": false, "resyncWith": "volumechange" },
      "open":     {}
    }

`companion` may be omitted (or `false`) for an attribute with no backing content
attribute anywhere in the brand — no `default*` setter is emitted then. `resyncs`
defaults to `true`; see `Controlled` for what it documents and why only `value` and
`checked` may truthfully claim it.

`elements` may be omitted, and then the entry covers every element declaring the
attribute — the roster's original name-only behaviour, kept as the default so an
existing config's emitted bytes do not move. Supply it whenever the attribute's live
state diverges from the content attribute on SOME elements only; see `Controlled` for
the `<progress value="abc">` TypeError that made the name-only form unsafe.

-}
controlledDecoder : D.Decoder (List Controlled)
controlledDecoder =
    let
        companionDecoder =
            D.oneOf
                [ D.map Just D.string
                , D.bool
                    |> D.andThen
                        (\b ->
                            if b then
                                D.fail "_controlled `companion` must be a setter name or `false`"

                            else
                                D.succeed Nothing
                        )
                ]

        -- Presence is checked SEPARATELY from shape, and deliberately not through
        -- `D.oneOf [ D.field "elements" …, D.succeed Nothing ]`. `D.oneOf` swallows the
        -- inner failure and falls through to the default, so a MALFORMED scope
        -- (`"elements": "input"`, say) would decode as "unscoped" — i.e. as the exact
        -- name-only claim over every element that this key exists to stop, silently.
        -- Two steps: is the key there at all, and if so it must decode or the run dies.
        --
        -- Emptiness is NOT checked here: `elements: []` is well-formed JSON that names
        -- no element, and `controlledElementErrors` rejects it at resolve time where the
        -- message can name the attribute.
        elementsField =
            D.maybe (D.field "elements" D.value)
                |> D.andThen
                    (\present ->
                        case present of
                            Nothing ->
                                D.succeed Nothing

                            Just _ ->
                                D.field "elements" (D.list D.string) |> D.map Just
                    )
    in
    D.keyValuePairs
        (D.map4 (\c r rw els -> { companion = c, resyncs = r, resyncWith = rw, elements = els })
            (D.oneOf [ D.field "companion" companionDecoder, D.succeed Nothing ])
            (D.oneOf [ D.field "resyncs" D.bool, D.succeed True ])
            (D.maybe (D.field "resyncWith" D.string))
            elementsField
        )
        |> D.map
            (List.map
                (\( name, o ) ->
                    { htmlName = name
                    , companion = o.companion
                    , resyncs = o.resyncs
                    , resyncWith = o.resyncWith
                    , elements = o.elements |> Maybe.map List.sort
                    }
                )
                >> List.sortBy .htmlName
            )


{-| The `_controlled` roster used when `_config` omits `_controlled` entirely.

These three are what the phantom emitter hardcoded before the roster existed, kept
verbatim as the default so no brand's emitted PROPERTY form changes when it gains no
config. The `default*` companions and the `selected` resync caveat are new output.

`resyncs` is `True` for `value`/`checked` and `False` for `selected` because
`elm/virtual-dom`'s controlled-input special-casing is keyed on those two NAMES; see
`Controlled`.

`elements` is `Nothing` on all three — i.e. UNSCOPED — for the same
byte-compatibility reason, and that is a known sharp edge rather than a
recommendation: a brand whose manifest declares `value` on an element with a numeric
IDL `value` (a `<progress>`, a `<meter>`) and takes this default gets the
`Ir.property "value" (Json.Encode.string …)` form there, which Web IDL rejects with a
TypeError for any non-numeric string. Such a brand must scope the entry — see
`Controlled`. The default cannot do it for them: it has no way to know which of a
manifest's elements reflect and which diverge.

-}
defaultControlled : List Controlled
defaultControlled =
    [ { htmlName = "checked", companion = Just "defaultChecked", resyncs = True, resyncWith = Nothing, elements = Nothing }
    , { htmlName = "selected", companion = Just "defaultSelected", resyncs = False, resyncWith = Just "change", elements = Nothing }
    , { htmlName = "value", companion = Just "defaultValue", resyncs = True, resyncWith = Nothing, elements = Nothing }
    ]


{-| Does this roster entry's ELEMENT SCOPE cover an element with this tag and
declaration name?

`Nothing` (no `elements` key) covers everything — the roster's name-only default.
Otherwise a scope name matches the element's TAG (`"input"`) or its declaration name
(`"Input"`); accepting either is the same latitude `Attr.applyForm` gives its keys,
and it means a config author never has to remember which identifier a given manifest
happens to spell things with. A typo matches NEITHER and is rejected up front
(`controlledElementErrors`) rather than silently scoping the entry to nothing.

The two wrappers below exist because the scope is consulted twice, on either side of
`Comp` construction: `controlsElement` while classifying a raw `Cem.Declaration`'s
attributes, `scopeCovers` when validating `propertyOnly` against resolved `Comp`s.
Both route through here so they cannot drift.

-}
scopeNames : Controlled -> String -> String -> Bool
scopeNames c tag name =
    case c.elements of
        Nothing ->
            True

        Just names ->
            List.member tag names || List.member name names


{-| `scopeNames` for a raw CEM declaration, during attribute classification.
-}
controlsElement : Controlled -> Cem.Declaration -> Bool
controlsElement c d =
    scopeNames c (tagOf d) d.name


{-| `scopeNames` for a resolved component, during config validation.
-}
scopeCovers : Controlled -> Comp -> Bool
scopeCovers c comp =
    scopeNames c comp.tag comp.name


{-| A declaration's tag name, exactly as `Comp.tag` derives it.
-}
tagOf : Cem.Declaration -> String
tagOf d =
    Maybe.withDefault (String.toLower d.name) d.tagName


{-| The brand-level `_variants` roster (`_config._variants`), keyed by the BASE
attribute's SETTER name (the camel-cased HTML name unless `_renames` moved it — see
`Variant.base`):

    "_variants": {
      "step":   [ { "name": "stepAsNumber",  "type": "float" } ],
      "coords": [ { "name": "coordsAsInts",  "type": "ints", "separator": "," } ],
      "value":  [ { "name": "valueAsNumber", "type": "float" } ]
    }

`separator` applies to `"ints"` only and defaults to `","` (the separator every
comma-separated HTML list attribute uses). An unknown `type` fails LOUD: silently
degrading to `String -> Attr` would produce a setter with the base's own type under a
name that promises otherwise.

See `Variant` for why a variant shares the base attribute's capability row.

-}
variantsDecoder : D.Decoder (List Variant)
variantsDecoder =
    let
        inputDecoder =
            D.map2
                (\kind sep ->
                    case kind of
                        "float" ->
                            Ok VFloat

                        "int" ->
                            Ok VInt

                        "ints" ->
                            Ok (VInts (Maybe.withDefault "," sep))

                        other ->
                            Err
                                ("_variants `type` must be one of float|int|ints, got: \""
                                    ++ other
                                    ++ "\""
                                )
                )
                (D.field "type" D.string)
                (D.maybe (D.field "separator" D.string))
                |> D.andThen
                    (\r ->
                        case r of
                            Ok v ->
                                D.succeed v

                            Err e ->
                                D.fail e
                    )
    in
    D.keyValuePairs (D.list (D.map2 Tuple.pair (D.field "name" D.string) inputDecoder))
        |> D.map
            (List.concatMap
                (\( base, entries ) ->
                    entries |> List.map (\( name, input ) -> { base = base, name = name, input = input })
                )
                -- Sorted by emitted NAME so the `<Lib>.Attributes` exposing list and the
                -- per-module re-exports are order-stable regardless of JSON key order.
                >> List.sortBy .name
            )


pairListDecoder : D.Decoder (List ( String, String ))
pairListDecoder =
    D.list
        (D.list D.string
            |> D.andThen
                (\xs ->
                    case xs of
                        [ a, b ] ->
                            D.succeed ( a, b )

                        _ ->
                            D.fail "expected [from, to] pair"
                )
        )


rawCompDecoder : D.Decoder RawComp
rawCompDecoder =
    D.succeed RawComp
        |> andMap (D.maybe (D.field "kind" D.string))
        |> andMap (D.oneOf [ D.field "admits" admitsDecoder, D.succeed [] ])
        |> andMap
            (D.maybe
                (D.field "parents"
                    (D.oneOf
                        [ D.list D.string
                        , D.map List.singleton D.string
                        ]
                    )
                )
            )
        |> andMap (D.maybe (D.field "home" D.string))
        |> andMap (D.oneOf [ D.field "transparent" D.bool, D.succeed False ])
        |> andMap (D.maybe (D.field "roles" (D.list D.string)))
        |> andMap requiredActionDecoder
        |> andMap (D.oneOf [ D.field "events" eventOverridesDecoder, D.succeed [] ])
        |> andMap (D.oneOf [ D.field "eventPayloads" eventPayloadsDecoder, D.succeed [] ])
        |> andMap (D.oneOf [ D.field "requiredAttrs" (D.list D.string), D.succeed [] ])
        |> andMap (D.oneOf [ D.field "actionMap" pairListDecoder, D.succeed [] ])
        |> andMap (D.oneOf [ D.field "attrForm" attrFormDecoder, D.succeed [] ])
        |> andMap (D.oneOf [ D.field "propertyOnly" (D.list D.string), D.succeed [] ])
        |> andMap (D.oneOf [ D.field "examples" (D.list rawExampleDecoder), D.succeed [] ])
        |> andMap (D.oneOf [ D.field "docMeta" (D.keyValuePairs D.string), D.succeed [] ])


{-| One config-supplied usage example. `title`/`code` default to `""` (never
fail-loud — an author who forgets one gets an empty-but-valid string, not a
config-decode error); `section` is optional (unsectioned examples group under
the renderer's "Examples" default).
-}
rawExampleDecoder : D.Decoder RawExample
rawExampleDecoder =
    D.map3 (\t c s -> { title = t, code = c, section = s })
        (D.oneOf [ D.field "title" D.string, D.succeed "" ])
        (D.oneOf [ D.field "code" D.string, D.succeed "" ])
        (D.maybe (D.field "section" D.string))


andMap : D.Decoder a -> D.Decoder (a -> b) -> D.Decoder b
andMap =
    D.map2 (|>)


actionWrapperDecoder : D.Decoder ActionWrapper
actionWrapperDecoder =
    D.map5 ActionWrapper
        (D.field "ctor" D.string)
        (D.field "cap" D.string)
        (D.field "variant" D.string)
        (D.field "comp" D.string)
        (D.oneOf [ D.field "doc" D.string, D.succeed "" ])


actionsRosterDecoder : D.Decoder ActionsRoster
actionsRosterDecoder =
    D.map4 ActionsRoster
        (D.oneOf [ D.field "forWrappers" (D.list actionWrapperDecoder), D.succeed [] ])
        (D.oneOf [ D.field "nullaryWrappers" (D.list actionWrapperDecoder), D.succeed [] ])
        (D.maybe (D.field "bottomSheetComp" D.string))
        (D.maybe (D.field "dialogActionComp" D.string))


ariaDecoder : D.Decoder AriaConfig
ariaDecoder =
    D.map3 AriaConfig
        (D.oneOf [ D.field "roles" (D.list D.string), D.succeed [] ])
        (D.oneOf [ D.field "states" (D.keyValuePairs (D.list D.string)), D.succeed [] ])
        (D.oneOf [ D.field "universal" (D.list D.string), D.succeed [] ])


{-| One `_globals` roster entry — a document-wide attribute EVERY element admits
— normalized into the same `Attr.AttrSpec` a CEM attribute becomes, so globals
go through the ONE classification point instead of a parallel switch in the
emitter (the `getSymbol : Float` lesson; see `Attr`).

Two JSON shapes, both accepted. The bare string is the historical form and MUST
keep working:

    "_globals": [
      "accesskey",
      { "name": "autofocus", "type": "bool" },
      { "name": "tabindex", "type": "int" },
      { "name": "dir", "type": [ "ltr", "rtl", "auto" ] }
    ]

`type` reuses the per-component `attrTypes` override vocabulary
(`"bool"` / `"int"` / `"float"` / `"string"`, or a token list for an enum) so a
config author learns one spelling. It is optional and defaults to `"string"` —
which is exactly what the bare-string form means.

`row` is the OTHER axis, and the returned `Bool` is it: `"closed"` (the default,
and what every entry meant before the key existed) emits
`Attr { c | <name> : Supported } msg` and joins every element's closed `Attrs`
alias; `"open"` emits `Attr c msg` and joins NO element's alias.

    { "name": "dir", "type": [ "ltr", "rtl", "auto" ], "row": "open" }

Open is right when an attribute's validity never depends on the element, which
is the line `TypedHtml.Aria` already draws between `label : String -> Attr c msg`
and `role : Value tags -> Attr { c | role : tags } msg`. A `role`'s legality
genuinely varies by element; a `dir`/`lang`/`title`'s does not. Closed remains
the default precisely because it is the safe answer: it can only ever reject a
call an open row would have accepted, never the reverse.

The payoff is single-sourcing. An open setter needs no row membership to compose,
so ONE brand declaring `"row": "open"` (`elm-typed-html`, the shared foundation)
makes the setter usable on every other brand's elements by ordinary structural
unification — no per-brand config edit, and no duplicate per-brand enum type.

Untyped WAS the bug: with every global emitted as `String -> Attr`,
`hidden "false"` HID the element (every value except `until-found` is the hidden
state) and `inert "false"` made it inert. Presence booleans (`autofocus`,
`inert`, `itemscope`) need `Bool`; `hidden` needs an ENUM rather than a `Bool`
because `hidden="until-found"` is load-bearing for find-in-page; and
`draggable` / `contenteditable` / `spellcheck` / `writingsuggestions` need enums
because their literal `"false"` means something different from absence.

An enum global becomes an `AEnum` (token == emitted value). No global needs a token
whose Elm name differs from its HTML value, so the list form is the only one offered
here — and it is now the same variant an `attrTypes` list override produces
(`Attr.fromOverride` normalizes an all-identity enum override to `AEnum`), which is
what lets K2 collapse a CEM attribute typed by config into a same-named global. A
`type` that is neither a known scalar nor a token list fails LOUD rather than
degrading to `String` behind the author's back.

This comment used to justify the choice with "the phantom union/token machinery
speaks `AEnum` only". That was TRUE, and it was a bug rather than a constraint: the
machinery matched `AEnum` at ~15 sites and `AEnumMap` at none, so every map-form
override degraded to a plain `String` setter. It speaks both now — see
`Attr.enumPairs` and `Brand.tokenValues`.

-}
globalDecoder : D.Decoder ( Bool, Attr.AttrSpec )
globalDecoder =
    let
        typeDecoder =
            D.oneOf
                [ D.string
                    |> D.andThen
                        (\s ->
                            case s of
                                "bool" ->
                                    D.succeed Attr.ABool

                                "int" ->
                                    D.succeed Attr.AInt

                                "float" ->
                                    D.succeed Attr.ANumber

                                "string" ->
                                    D.succeed Attr.AString

                                _ ->
                                    D.fail
                                        ("_globals `type` must be one of bool|int|float|string, or a token list for an enum, got: \""
                                            ++ s
                                            ++ "\""
                                        )
                        )

                -- Sorted here so an `AEnum` global compares equal to the same
                -- value-set classified off a CEM `type.text` (`Attr.enumValues`
                -- sorts), which is what the K2 collapse below leans on.
                , D.list D.string |> D.map (List.sort >> Attr.AEnum)
                ]

        -- A PRESENT-but-malformed `type` must fail, so this cannot be an
        -- `oneOf [ field "type" …, succeed AString ]` — that shape swallows the
        -- decode error and silently emits `String -> Attr`, the very degradation
        -- this whole change exists to remove.
        -- A PRESENT-but-unrecognized `row` fails for the same reason a malformed
        -- `type` does: the two legal spellings differ by exactly one setter
        -- signature, so a typo (`"opened"`, `"Open"`) that fell back to the
        -- default would silently emit the closed row the author was trying to
        -- escape — the degradation this decoder keeps having to refuse.
        rowDecoder =
            D.maybe (D.field "row" D.string)
                |> D.andThen
                    (\raw ->
                        case raw of
                            Nothing ->
                                D.succeed False

                            Just "closed" ->
                                D.succeed False

                            Just "open" ->
                                D.succeed True

                            Just other ->
                                D.fail
                                    ("_globals `row` must be \"open\" or \"closed\", got: \""
                                        ++ other
                                        ++ "\""
                                    )
                    )

        objectForm =
            D.map3 (\name type_ rowOpen -> ( rowOpen, globalSpec name type_ ))
                (D.field "name" D.string)
                (D.maybe (D.field "type" D.value)
                    |> D.andThen
                        (\raw ->
                            case raw of
                                Nothing ->
                                    D.succeed Attr.AString

                                Just v ->
                                    case D.decodeValue typeDecoder v of
                                        Ok t ->
                                            D.succeed t

                                        Err e ->
                                            D.fail (D.errorToString e)
                        )
                )
                rowDecoder
    in
    D.value
        |> D.andThen
            (\raw ->
                case D.decodeValue D.string raw of
                    Ok name ->
                        -- The bare-string form predates BOTH optional keys, so it
                        -- means what it always meant: a closed free string.
                        D.succeed ( False, globalSpec name Attr.AString )

                    Err _ ->
                        objectForm
            )


{-| Normalize one `_globals` entry into an `Attr.AttrSpec`.

A global is 1:1 with its DOM attribute (`htmlName == elmName == capName`) and is
always a CONTENT attribute (`reactiveProp = Nothing`, `attrForm = AsAttribute`):
it is written into markup, never onto a JS reactive property. `description` stays
`Nothing` so the emitter keeps ownership of the global's prose
(`Emit.globalDoc`, which says "global" and carries the bespoke `class`/`style`
merge notes).

-}
globalSpec : String -> Attr.AttrType -> Attr.AttrSpec
globalSpec name type_ =
    { htmlName = name
    , elmName = name
    , reactiveProp = Nothing
    , type_ = type_
    , attrForm = Attr.AsAttribute
    , description = Nothing
    , default = Nothing
    , capName = name
    }


{-| The `_globals` roster used when `_config` omits `_globals` entirely: the four
attributes every phantom brand has always had, all free strings.
-}
defaultGlobals : List Attr.AttrSpec
defaultGlobals =
    [ "class", "id", "slot", "style" ]
        |> List.map (\name -> globalSpec name Attr.AString)


renamesDecoder : D.Decoder RawRenames
renamesDecoder =
    D.map4 RawRenames
        (D.oneOf
            [ D.keyValuePairs (D.keyValuePairs D.string)
                |> D.map
                    (List.filter (\( k, _ ) -> not (String.startsWith "_" k))
                        >> List.map (\( k, v ) -> ( k, Dict.fromList v ))
                        >> Dict.fromList
                    )
            , D.succeed Dict.empty
            ]
        )
        (D.oneOf [ D.field "_events" (D.keyValuePairs D.string) |> D.map Dict.fromList, D.succeed Dict.empty ])
        (D.oneOf [ D.field "_tokens" (D.keyValuePairs D.string) |> D.map Dict.fromList, D.succeed Dict.empty ])
        (D.oneOf [ D.field "_elements" (D.keyValuePairs D.string) |> D.map Dict.fromList, D.succeed Dict.empty ])


rawConfigDecoder : D.Decoder RawConfig
rawConfigDecoder =
    D.field "_config"
        (D.keyValuePairs D.value
            |> D.andThen
                (\pairs ->
                    let
                        get key dec default =
                            case List.filter (\( k, _ ) -> k == key) pairs of
                                ( _, v ) :: _ ->
                                    case D.decodeValue dec v of
                                        Ok x ->
                                            D.succeed x

                                        Err e ->
                                            D.fail (key ++ ": " ++ D.errorToString e)

                                [] ->
                                    D.succeed default

                        componentPairs =
                            pairs |> List.filter (\( k, _ ) -> not (String.startsWith "_" k))

                        comps =
                            componentPairs
                                |> List.map
                                    (\( k, v ) ->
                                        case D.decodeValue rawCompDecoder v of
                                            Ok c ->
                                                D.succeed ( k, c )

                                            Err e ->
                                                D.fail (k ++ ": " ++ D.errorToString e)
                                    )
                                |> List.foldr (D.map2 (::)) (D.succeed [])
                    in
                    D.map7
                        (\phantom brandName sets atoms globals exclude aria ->
                            \kinds actions legacyHtml cs renames controlled ->
                                \variants ->
                                    { phantom = phantom
                                    , brand = brandName
                                    , sets = Dict.fromList sets
                                    , atoms = atoms
                                    , globals = globals
                                    , controlled = controlled
                                    , variants = variants
                                    , exclude = exclude
                                    , aria = aria
                                    , kinds = kinds
                                    , actions = actions
                                    , legacyHtml = legacyHtml
                                    , components = Dict.fromList cs
                                    , renames = renames
                                    }
                        )
                        (get "_phantom" D.bool False)
                        (get "_brand" (D.map Just D.string) Nothing)
                        (get "_sets" (D.keyValuePairs (D.list D.string)) [])
                        (get "_atoms" (D.keyValuePairs D.value |> D.map (List.map Tuple.first)) [])
                        -- `defaultGlobals` stays a plain roster: the bare four are
                        -- closed, and adapting here keeps that fact stated once.
                        (get "_globals" (D.list globalDecoder) (List.map (Tuple.pair False) defaultGlobals))
                        (get "_exclude" (D.list D.string) [])
                        (get "_aria" (D.map Just ariaDecoder) Nothing)
                        |> D.andThen
                            (\f ->
                                D.map6 f
                                    (get "_kinds" (D.list D.string) [])
                                    (get "_actions" (D.map Just actionsRosterDecoder) Nothing)
                                    (get "_legacyHtml" D.bool False)
                                    comps
                                    (get "_renames" renamesDecoder { components = Dict.empty, events = Dict.empty, tokens = Dict.empty, elements = Dict.empty })
                                    (get "_controlled" controlledDecoder defaultControlled)
                            )
                        -- A third stage: `D.map8`/`D.map6` are the widest maps Elm's
                        -- Json.Decode ships, and the raw config now has 14 fields.
                        |> D.andThen (\f -> D.map f (get "_variants" variantsDecoder []))
                )
        )



-- RESOLUTION + VALIDATION


{-| Resolve config + CEM components into the brand model, or a list of loud
config errors.
-}
resolve : String -> String -> D.Value -> List Cem.Declaration -> Result (List String) Brand
resolve lib eventPrefix flags declarations =
    case D.decodeValue rawConfigDecoder flags of
        Err e ->
            Err [ "phantom config decode failed: " ++ D.errorToString e ]

        Ok raw ->
            resolveWith lib eventPrefix raw declarations


resolveWith : String -> String -> RawConfig -> List Cem.Declaration -> Result (List String) Brand
resolveWith detectedLib eventPrefix raw declarations =
    let
        -- `_brand` is authoritative when present; the manifest-derived name is
        -- only a fallback (its tag-prefix heuristic misfires on native tags).
        lib =
            Maybe.withDefault detectedLib raw.brand

        -- The `_globals` roster minus the entries `elm/virtual-dom` cannot express.
        -- `is` is the live case: it is a WHATWG global and `elm-typed-html` declares
        -- it, but `_VirtualDom_render` calls `createElement(tag)` with no options
        -- argument, so a customized built-in is never upgraded and the attribute is
        -- inert once the element exists. See `Attr.kernelBlockedReason`.
        --
        -- Filtered HERE, once, rather than in `globalDecoder`: the decoder has no
        -- info channel to report the omission on, and a config author who wrote a
        -- correct roster deserves to be told which entry vanished and why. The
        -- roster STAYS correct in config — it faithfully describes HTML, and
        -- `elm-typed-html`'s `check-whatwg` gate reads config to assert all 29
        -- globals are curated, then separately asserts the kernel-blocked ones are
        -- genuinely absent from the emitted surface.
        --
        -- Every downstream use of the roster reads these, not `raw.globals`: the K2
        -- collapse, the enum-global union rows, the brand's token/value pairs and
        -- `Brand.globals` / `Brand.openGlobals` (whence the global setters, the
        -- builder pipes and every element's `Attrs` row). A blocked global left in
        -- any one of those would reappear as a dead setter on EVERY element.
        --
        -- The filter runs BEFORE the partition, so a kernel-blocked name is dropped
        -- whatever its `row`: `is` is a WHATWG global that `elm-typed-html` declares
        -- and `elm/virtual-dom` cannot write, and marking it `"row": "open"` must not
        -- become a way around that. Open changes a setter's TYPE; it cannot conjure a
        -- setter the kernel has no way to honour.
        ( openGlobals, globals ) =
            raw.globals
                |> List.filter (\( _, g ) -> not (Attr.kernelBlocked g))
                |> List.partition Tuple.first
                |> Tuple.mapBoth (List.map Tuple.second) (List.map Tuple.second)

        -- Both halves, for the consumers that do not care about row shape. Only the
        -- closed `Attrs` alias and the `with<Field>` pipes read `globals` alone; see
        -- `Brand.openGlobals`.
        allGlobals =
            globals ++ openGlobals

        globalBlockedNotes =
            raw.globals
                |> List.map Tuple.second
                |> List.filter Attr.kernelBlocked
                |> List.sortBy .htmlName
                |> List.filterMap
                    (\g ->
                        Attr.kernelBlockedReason g
                            |> Maybe.map
                                (\reason ->
                                    "elm-cem: omitted GLOBAL attr '"
                                        ++ g.htmlName
                                        ++ "' — elm/virtual-dom cannot express it: "
                                        ++ reason
                                        ++ ". No setter is emitted on any element; do not restore one."
                                )
                    )

        comps0 =
            declarations
                |> List.filter (\d -> d.customElement == Just True && not (List.member d.name raw.exclude))

        ctorOf name =
            -- CEM declaration names are PascalCase; the constructor is its
            -- decapitalization ("PictureSource" → "pictureSource"). NOT
            -- Naming.camel, which only splits on symbols and would lowercase
            -- the whole word ("picturesource"). `main` follows elm/html's
            -- `main_` convention (a top-level `main` trips app builds).
            case Naming.decapitalize name of
                "main" ->
                    "main_"

                other ->
                    other

        ctorIndex : Dict String Cem.Declaration
        ctorIndex =
            comps0 |> List.map (\d -> ( ctorOf d.name, d )) |> Dict.fromList

        producesOf name cfg =
            case Maybe.andThen .kind cfg |> Maybe.andThen sharedRoleOf of
                Just role ->
                    sharedKindField role

                Nothing ->
                    { field = ctorOf name, marker = MBrand }

        kindFieldOfRef : String -> RawKindRef -> Result String (List KindField)
        kindFieldOfRef where_ ref =
            case ref of
                RAny ->
                    Err (where_ ++ ": 'any' cannot be mixed with other kinds")

                RShared role ->
                    Ok [ sharedKindField role ]

                RSet setName ->
                    case Dict.get setName raw.sets of
                        Just members ->
                            members
                                |> List.map
                                    (\mRaw ->
                                        let
                                            m =
                                                if mRaw == "main" then
                                                    "main_"

                                                else
                                                    mRaw
                                        in
                                        case Dict.get m ctorIndex of
                                            Just d ->
                                                Ok (producesOf d.name (Dict.get d.name raw.components))

                                            Nothing ->
                                                Err (where_ ++ ": set '@" ++ setName ++ "' member '" ++ m ++ "' is not a component")
                                    )
                                |> combine

                        Nothing ->
                            Err (where_ ++ ": unknown set '@" ++ setName ++ "'")

                RBrand ctorRaw ->
                    let
                        ctor =
                            if ctorRaw == "main" then
                                "main_"

                            else
                                ctorRaw
                    in
                    case Dict.get ctor ctorIndex of
                        Just d ->
                            Ok [ producesOf d.name (Dict.get d.name raw.components) ]

                        Nothing ->
                            if List.member ctor raw.kinds then
                                -- An auxiliary brand kind declared in
                                -- `_kinds`: produced by non-component
                                -- constructors (action wrappers, escapes).
                                Ok [ { field = ctor, marker = MBrand } ]

                            else
                                Err (where_ ++ ": unknown kind '" ++ ctor ++ "' (no such component or _kinds entry)")

        resolveSlot : String -> RawSlot -> Result (List String) ResolvedSlot
        resolveSlot compName s =
            let
                where_ =
                    compName ++ "." ++ s.name
            in
            case s.kinds of
                [ RAny ] ->
                    Ok { name = s.name, content = Permissive, multi = s.multi, required = s.required }

                [ RSet setName ] ->
                    case Dict.get setName raw.sets of
                        Just _ ->
                            kindFieldOfRef where_ (RSet setName)
                                |> Result.map
                                    (\fields ->
                                        { name = s.name
                                        , content = SetContent { name = setName, pascal = Naming.pascal setName, fields = sortFields fields }
                                        , multi = s.multi
                                        , required = s.required
                                        }
                                    )
                                |> Result.mapError List.singleton

                        Nothing ->
                            Err [ where_ ++ ": unknown set '@" ++ setName ++ "'" ]

                refs ->
                    refs
                        |> List.map (kindFieldOfRef where_)
                        |> combine
                        |> Result.map (List.concat >> sortFields)
                        |> Result.map (\fields -> { name = s.name, content = Fields fields, multi = s.multi, required = s.required })
                        |> Result.mapError List.singleton

        resolveParents : String -> List String -> Result (List String) (List String)
        resolveParents compName ps =
            ps
                |> List.concatMap
                    (\p ->
                        if String.startsWith "@" p then
                            Dict.get (String.dropLeft 1 p) raw.sets |> Maybe.withDefault [ p ]

                        else
                            [ p ]
                    )
                |> List.map
                    (\pRaw ->
                        let
                            p =
                                if pRaw == "main" then
                                    "main_"

                                else
                                    pRaw
                        in
                        if Dict.member p ctorIndex then
                            Ok p

                        else
                            Err (compName ++ ".parents: unknown component '" ++ p ++ "'")
                    )
                |> combine
                |> Result.mapError List.singleton
                |> Result.map List.sort

        buildComp : Cem.Declaration -> Result (List String) ( Comp, List String )
        buildComp d =
            let
                cfg =
                    Dict.get d.name raw.components

                -- Classify raw attrs once, sanitize keyword names.
                -- Then apply per-component attr renames from _renames config.
                compRenames =
                    Dict.get d.name raw.renames.components |> Maybe.withDefault Dict.empty

                classifiedAttrs =
                    d.attributes
                        |> List.filter (\a -> not (String.startsWith "_" a.name))
                        |> List.map Attr.fromCem
                        |> List.map (\a -> { a | elmName = Naming.safeField a.elmName, capName = Naming.safeField a.capName })
                        |> List.map
                            (\a ->
                                -- Apply rename from _renames config (e.g. "attr:with-hint" -> "hintFlag")
                                case Dict.get ("attr:" ++ a.htmlName) compRenames of
                                    Just newName ->
                                        { a | elmName = newName, capName = newName }

                                    Nothing ->
                                        a
                            )

                -- The ATTRIBUTE-vs-PROPERTY form, decided in one place from config.
                --
                -- First the brand-level controlled roster (`_controlled`) sweeps its
                -- members to `AsProperty` — but only on the elements the entry's
                -- `elements` scope covers; then the per-component `attrForm` override
                -- gets the last word, so one element can opt out of (or into) the
                -- property form. Before this, the roster was a hardcoded list inside
                -- the EMITTER and `Attr.applyForm` was dead code that nothing called —
                -- two mechanisms for one decision, of which only the hidden one worked.
                --
                -- The scope is what keeps the sweep from being a claim about
                -- `HTMLElement`. `value` is declared by seven elements in the native
                -- manifest at three different IDL types, and `Ir.property "value"` on
                -- the `double`-typed ones (`<progress>`, `<meter>`) THROWS a Web IDL
                -- TypeError for any non-numeric string — inside `applyFacts`, i.e.
                -- during patch, where it takes down the render loop. See
                -- `Controlled.elements`.
                formedAttrs =
                    classifiedAttrs
                        |> List.map
                            (\a ->
                                if List.any (\c -> c.htmlName == a.htmlName && controlsElement c d) raw.controlled then
                                    { a | attrForm = Attr.AsProperty }

                                else
                                    a
                            )
                        |> List.map (Attr.applyForm (cfg |> Maybe.map .attrForm |> Maybe.withDefault []))

                -- KERNEL-BLOCKED attrs leave here, and they leave AFTER the form
                -- passes above, because the test depends on the form: an `AsAttribute`
                -- setter goes through `VirtualDom.attribute`'s
                -- `_VirtualDom_noOnOrFormAction` and an `AsProperty` one through
                -- `VirtualDom.property`'s `_VirtualDom_noInnerHtmlOrFormAction`, and
                -- the two guards block different names. See `Attr.kernelBlockedReason`
                -- for every case and the kernel source behind it.
                --
                -- Dropping them HERE — before K3/K2, before `sharedAttrs`, before the
                -- capability rows — is what makes the omission total. A blocked name
                -- that survived this point would reappear in the shared canonical, the
                -- per-element re-export, the builder pipe, the `Attrs` row and the
                -- `Review/Facts` roster, each of which reads from `Comp.attrs`.
                --
                -- Omitted, not fatal: the manifest is CORRECT (`formaction` and `is`
                -- are real HTML) and it is `elm/virtual-dom` that cannot express them,
                -- so no manifest or config edit could ever clear the error. But not
                -- silent either — one info-channel note per omission, below.
                blocked =
                    formedAttrs |> List.filter Attr.kernelBlocked

                blockedNotes =
                    blocked
                        |> List.sortBy .htmlName
                        |> List.filterMap
                            (\a ->
                                Attr.kernelBlockedReason a
                                    |> Maybe.map
                                        (\reason ->
                                            "elm-cem: omitted attr '"
                                                ++ a.htmlName
                                                ++ "' on "
                                                ++ d.name
                                                ++ " — elm/virtual-dom cannot express it: "
                                                ++ reason
                                                ++ ". No setter is emitted; do not restore one."
                                        )
                            )

                keptAttrs =
                    formedAttrs |> List.filter (not << Attr.kernelBlocked)

                -- K3: collapse identical duplicate attr specs (same elmName + same
                -- normalized spec). Differing specs under one name → fail-loud.
                -- Returns Ok (deduped attrs, collapse notes) or Err (errors).
                k3Result =
                    keptAttrs
                        |> List.sortBy .elmName
                        |> List.foldl
                            (\a acc ->
                                case acc of
                                    Err errs ->
                                        Err errs

                                    Ok ( seen, notes ) ->
                                        case List.filter (\x -> x.elmName == a.elmName) seen of
                                            [] ->
                                                Ok ( seen ++ [ a ], notes )

                                            [ existing ] ->
                                                -- Identical specs (same htmlName, type_, attrForm): collapse with note.
                                                -- Differing specs → fail-loud.
                                                if existing.htmlName == a.htmlName && existing.type_ == a.type_ && existing.attrForm == a.attrForm then
                                                    -- K3: identical duplicate spec; collapse + emit deterministic note.
                                                    Ok
                                                        ( seen
                                                        , notes
                                                            ++ [ "elm-cem: collapsed duplicate CEM attr '"
                                                                    ++ a.htmlName
                                                                    ++ "' on "
                                                                    ++ d.name
                                                                    ++ " (K3: identical duplicate spec)"
                                                               ]
                                                        )

                                                else
                                                    Err
                                                        [ "K3: component "
                                                            ++ d.name
                                                            ++ " declares attr '"
                                                            ++ a.elmName
                                                            ++ "' twice with differing specs (htmlNames: '"
                                                            ++ existing.htmlName
                                                            ++ "' vs '"
                                                            ++ a.htmlName
                                                            ++ "'). Use `_renames` to resolve."
                                                        ]

                                            _ ->
                                                -- Shouldn't happen since we build `seen` one-by-one.
                                                Ok ( seen, notes )
                            )
                            (Ok ( [], [] ))

                -- K2: collapse CEM attrs whose elmName ∈ brand globals into the single
                -- global projection. Only when the CEM attr's classified type MATCHES the
                -- global's declared type; a mismatch → fail-loud (that's not a true dup —
                -- the CEM attr carries different semantics, and collapsing it would swap
                -- the caller's setter for one of another type).
                --
                -- The comparison used to be `type_ == AString`, because every global was
                -- implicitly a free string. Now that `_globals` carries types, the test is
                -- the faithful generalization: `dir : Value Dir` on the brand collapses a
                -- CEM `dir` classified to the same value-set, and nothing else. Plain `==`
                -- suffices because both sides sort their enum token lists (`globalDecoder`
                -- and `Attr.enumValues`).
                -- Returns Ok (kept attrs, extra notes) or Err (errors).
                k2Result ( deduped, k3Notes ) =
                    deduped
                        |> List.foldl
                            (\a acc ->
                                case acc of
                                    Err errs ->
                                        Err errs

                                    Ok ( kept, notes ) ->
                                        -- `allGlobals`: an OPEN global colliding with a
                                        -- component's own same-named attribute is the
                                        -- identical hazard, and row shape has no bearing
                                        -- on it. Reading `globals` alone here would let a
                                        -- component's conflicting `dir` past the guard the
                                        -- moment `dir` went open.
                                        case allGlobals |> List.filter (\g -> g.elmName == a.elmName) |> List.head of
                                            Just global ->
                                                if global.type_ == a.type_ then
                                                    -- K2: collapse into global projection (drop from per-component list)
                                                    -- + emit deterministic note.
                                                    Ok
                                                        ( kept
                                                        , notes
                                                            ++ [ "elm-cem: collapsed CEM attr '"
                                                                    ++ a.htmlName
                                                                    ++ "' on "
                                                                    ++ d.name
                                                                    ++ " into global (K2)"
                                                               ]
                                                        )

                                                else
                                                    Err
                                                        [ "K2: CEM attr '"
                                                            ++ a.htmlName
                                                            ++ "' on "
                                                            ++ d.name
                                                            ++ " has elmName '"
                                                            ++ a.elmName
                                                            ++ "' which matches a global, but its type ("
                                                            ++ Attr.typeLabel a.type_
                                                            ++ ") is not the global's ("
                                                            ++ Attr.typeLabel global.type_
                                                            ++ "). Retype the global in `_globals`, or use `_renames` to resolve."
                                                        ]

                                            Nothing ->
                                                Ok ( kept ++ [ a ], notes )
                            )
                            (Ok ( [], k3Notes ))

                attrsResult =
                    k3Result
                        |> Result.andThen k2Result
                        -- The blocked-attr report rides the same note list as the K2/K3
                        -- collapse notes, so it reaches stdout through the one existing
                        -- info channel (`Brand.collapseNotes` → `Generate.generatePhantom`).
                        |> Result.map (\( kept, notes ) -> ( kept, notes ++ blockedNotes ))

                provenanceOf elmName =
                    d.attributes
                        |> List.filter (\raw_ -> Attr.fromCem raw_ |> .elmName |> (==) elmName)
                        |> List.head
                        |> Maybe.andThen .type_
                        |> Maybe.andThen .aliasName

                slotsR =
                    cfg
                        |> Maybe.map .admits
                        |> Maybe.withDefault []
                        |> List.sortBy
                            (\s ->
                                if s.name == "unnamed" then
                                    ( 0, "" )

                                else
                                    ( 1, s.name )
                            )
                        |> List.map (resolveSlot d.name)
                        |> combineAll

                parentsR =
                    case Maybe.andThen .parents cfg of
                        Just ps ->
                            resolveParents d.name ps |> Result.map Just

                        Nothing ->
                            Ok Nothing
            in
            Result.map3
                (\( attrs, compNotes ) slots parents ->
                    let
                        -- `Attr.enumPairs` rather than a local `case … of AEnum tokens`:
                        -- an `AEnumMap` (a config `attrTypes` override whose token names
                        -- differ from the strings they emit) is just as much a union
                        -- attribute, and matching only `AEnum` here is precisely how a
                        -- downstream brand's config-constrained `disable-pagination` ended
                        -- up a `String` setter with no `<Lib>.Values` row at all. The TOKEN
                        -- half of each pair is what a row carries; the VALUE half is
                        -- resolved once, brand-wide, into `Brand.tokenValues`.
                        enums =
                            attrs
                                |> List.filterMap
                                    (\a ->
                                        Attr.enumPairs a.type_
                                            |> Maybe.map
                                                (\pairs ->
                                                    { elmName = a.elmName
                                                    , aliasName = Naming.pascal a.elmName
                                                    , tokens = pairs |> List.map Tuple.first |> List.sort
                                                    , provenance = provenanceOf a.elmName
                                                    }
                                                )
                                    )
                    in
                    ( { name = d.name
                      , ctor = ctorOf d.name

                      -- resolvedCtor is set to ctor here; K7 collision resolution
                      -- (barrel atom vs element ctor) is applied in resolveWith
                      -- after all comps are built and atoms are known.
                      , resolvedCtor = ctorOf d.name
                      , tag = tagOf d
                      , produces = producesOf d.name cfg
                      , attrs = attrs
                      , enums = enums
                      , events =
                            let
                                payloads =
                                    cfg |> Maybe.map .eventPayloads |> Maybe.withDefault []
                            in
                            d.events
                                |> List.map
                                    (\ev ->
                                        case payloads |> List.filter (\p -> p.event == ev.name) |> List.head of
                                            Just p ->
                                                { ev | setter = Just p.setter, payload = Just p.payload }

                                            Nothing ->
                                                ev
                                    )
                      , slots = slots
                      , admittedBy = parents
                      , description = Maybe.withDefault "" d.description
                      , home = Maybe.andThen .home cfg
                      , transparent = cfg |> Maybe.map .transparent |> Maybe.withDefault False
                      , roles = Maybe.andThen .roles cfg
                      , actionCaps = Maybe.andThen .requiredAction cfg
                      , eventOverrides = cfg |> Maybe.map .eventOverrides |> Maybe.withDefault []
                      , requiredAttrs = cfg |> Maybe.map .requiredAttrs |> Maybe.withDefault []
                      , actionMap = cfg |> Maybe.map .actionMap |> Maybe.withDefault []
                      , propertyOnly = cfg |> Maybe.map .propertyOnly |> Maybe.withDefault [] |> List.sort
                      , blockedAttrs = blocked |> List.sortBy .htmlName
                      , examples = cfg |> Maybe.map .examples |> Maybe.withDefault []
                      , docMeta = cfg |> Maybe.map .docMeta |> Maybe.withDefault []
                      }
                    , compNotes
                    )
                )
                attrsResult
                slotsR
                parentsR

        compsR =
            comps0
                |> List.map buildComp
                |> combineAll
                |> Result.map
                    (\pairs ->
                        let
                            sorted =
                                pairs |> List.sortBy (Tuple.first >> .name)
                        in
                        ( sorted |> List.map Tuple.first
                        , sorted |> List.concatMap Tuple.second
                        )
                    )
    in
    compsR
        |> Result.andThen
            (\( comps, buildNotes ) ->
                let
                    r1Errors =
                        comps |> List.concatMap (checkR1 comps)

                    -- Enum GLOBALS join the brand's union roster, so `<Lib>.Values` stays
                    -- the ONE home for every enum row + token (a global's row alias and
                    -- its tokens are minted, pooled, and collision-checked exactly like a
                    -- component enum's) and `<Lib>.Attributes` reads the global setter's
                    -- row alias from here rather than re-deriving it.
                    -- `allGlobals`, emphatically: this is where an enum global's
                    -- `<Lib>.Values` row and tokens are minted. An OPEN enum global's
                    -- setter is still annotated `Value <Lib>.Values.<Row>`, so reading
                    -- `globals` alone here would emit a module annotated against a type
                    -- that was never generated.
                    globalEnums =
                        allGlobals
                            |> List.filterMap
                                (\g ->
                                    Attr.enumPairs g.type_
                                        |> Maybe.map
                                            (\pairs ->
                                                { elmName = g.elmName
                                                , aliasName = Naming.pascal g.elmName
                                                , tokens = pairs |> List.map Tuple.first |> List.sort
                                                , provenance = Nothing
                                                }
                                            )
                                )

                    unions =
                        (comps |> List.concatMap .enums)
                            ++ globalEnums
                            |> List.foldl
                                (\e acc ->
                                    Dict.update e.elmName
                                        (\existing ->
                                            case existing of
                                                Just x ->
                                                    Just
                                                        { tokens = List.sort (List.foldl consUnique x.tokens e.tokens)
                                                        , provenance = orMaybe x.provenance e.provenance
                                                        }

                                                Nothing ->
                                                    Just { tokens = List.sort e.tokens, provenance = e.provenance }
                                        )
                                        acc
                                )
                                Dict.empty
                            |> Dict.toList
                            |> List.map
                                (\( elmName, u ) ->
                                    { elmName = elmName
                                    , aliasName = Naming.pascal elmName
                                    , tokens = u.tokens
                                    , provenance = u.provenance
                                    }
                                )

                    -- Every ( token, emitted string ) pair the brand declares anywhere,
                    -- from both enum sources: per-component attributes and enum globals.
                    -- Identity pairs are INCLUDED deliberately — they are what makes the
                    -- conflict below detectable. A plain `AEnum` token `auto` is the pair
                    -- ( "auto", "auto" ), so an `attrTypes` map elsewhere asking for
                    -- ( "auto", "automatic" ) is caught rather than silently retargeting
                    -- the token every other attribute already shares.
                    tokenValuePairs =
                        ((comps |> List.concatMap .attrs) ++ allGlobals)
                            |> List.filterMap (.type_ >> Attr.enumPairs)
                            |> List.concat
                            |> List.sort

                    -- `<Lib>.Values` mints ONE value per token identifier, so a token that
                    -- two attributes want to render differently is UNREPRESENTABLE, exactly
                    -- like the ident collision `Emit.guardValuesModule` already fails on.
                    -- Letting `Dict.insert` pick a winner would corrupt the other attribute
                    -- silently — `Values.always` would write one attribute's string into
                    -- the other's DOM attribute, past a type checker that sees one legal
                    -- `Value` row and has nothing to object to.
                    ( tokenValues, tokenValueErrors ) =
                        tokenValuePairs
                            |> List.foldl
                                (\( token, value ) ( acc, errs ) ->
                                    case Dict.get token acc of
                                        Just existing ->
                                            if existing == value then
                                                ( acc, errs )

                                            else
                                                ( acc
                                                , errs
                                                    ++ [ "COLLISION in module "
                                                            ++ lib
                                                            ++ ".Values (token payload): token '"
                                                            ++ token
                                                            ++ "' is asked to render two different strings — \""
                                                            ++ existing
                                                            ++ "\" and \""
                                                            ++ value
                                                            ++ "\". One token identifier mints one `Ir.token`, so"
                                                            ++ " whichever won would silently write the wrong string for the other"
                                                            ++ " attribute. Give one of them a distinct TOKEN NAME in its"
                                                            ++ " `attrTypes` map (the key is the Elm name, the value is the HTML"
                                                            ++ " string, so they need not match).\nattrTypes snippet:\n"
                                                            ++ "{ \"<attr>\": { \""
                                                            ++ token
                                                            ++ "Alt\": \""
                                                            ++ value
                                                            ++ "\" } }"
                                                       ]
                                                )

                                        Nothing ->
                                            ( Dict.insert token value acc, errs )
                                )
                                ( Dict.empty, [] )

                    -- The shared vocabulary: ONE canonical spec per attribute name.
                    --
                    -- `dedupBy` picks a single spec per `elmName`, so when two components
                    -- classify one attribute to different SCALAR types (`value : String`
                    -- on m3e-textfield, `value : Float` on m3e-slider) exactly one type
                    -- reaches `<Lib>.Attributes`. That is intentional — a module cannot
                    -- expose one name at two types — and it is SOUND because the losing
                    -- components keep a locally-typed setter in their own module
                    -- (`Emit.conflictsWithCanonical`). What was missing is that the choice
                    -- was completely silent: the elm-typed-html `datetime` regression
                    -- (`<time>`'s Float outranked `<ins>`/`<del>`'s String) left no trace
                    -- in any output. `conflictNotes` below puts the choice on the info
                    -- channel; `Emit.guardHomeAttrTypes` makes the unrepresentable case
                    -- (both types in ONE module) a hard error.
                    -- …and one further normalization `dedupBy` cannot do on its own: the
                    -- attribute-vs-PROPERTY FORM. Once `_controlled` gained an element
                    -- scope, one name can legitimately be a DOM property on one element
                    -- and a content attribute on another (`value` is the live property of
                    -- an `<input>` and a reflected content attribute of a `<progress>`),
                    -- and `dedupBy` would then publish whichever element the manifest
                    -- happened to list first.
                    --
                    -- The tie is broken toward `AsProperty`, deliberately and not by
                    -- majority. `<Lib>.Attributes` is the LOOSE surface — every setter is
                    -- an open producer admitted by every element whose row carries the
                    -- field — so the one body it can publish has to be right for every
                    -- element STILL ON THAT ROW. The property form is; the attribute form
                    -- is not:
                    --
                    --   * The property form's only failure mode is Web IDL COERCION, and
                    --     that is a property of the ELEMENT, not of this decision:
                    --     `progress.value = "abc"` is a TypeError only because
                    --     `HTMLProgressElement.value` is a restricted `double`. An element
                    --     whose IDL type coerces must therefore not share the row AT ALL —
                    --     it declares its value under its own capability row and its own
                    --     setter name (`_renames` + `attrTypes`, so the type is honest
                    --     too). That is what makes the crash UNREPRESENTABLE rather than
                    --     merely avoided: `<Lib>.Attributes.value` applied to a
                    --     `<progress>` is a row mismatch the compiler rejects, not a
                    --     TypeError thrown mid-patch. Every element left on a property-form
                    --     row reflects (`HTMLButtonElement`/`HTMLDataElement`/
                    --     `HTMLOptionElement.value` are `[CEReactions] attribute DOMString
                    --     value`), so the property write reaches the content attribute
                    --     there anyway.
                    --   * The attribute form has no such escape. It is INERT or STALE
                    --     exactly where `_controlled` exists in the first place: once an
                    --     `<input>`'s dirty-value flag is set, `setAttribute("value")` no
                    --     longer moves the live value (issue #41), and there is no
                    --     capability row to move to — the whole point of `value` on an
                    --     `<input>` is that name. Publishing it here pinned
                    --     `<Lib>.Attributes.value model.text` on the most-used form control
                    --     in the library, silently.
                    --
                    -- So: a rare crash on elements that can and must diverge their row, or
                    -- common silent staleness on the one element that cannot. The property
                    -- form, and let the row do the refusing. The attribute half stays
                    -- reachable — and is the only form — through each reflecting element's
                    -- own module, where `Emit.divergesFromCanonical` keeps a local setter,
                    -- plus the `default*` companion this form earns beside the shared
                    -- setter (`Emit.companionsFor`).
                    sharedAttrs =
                        comps
                            |> List.concatMap .attrs
                            |> dedupBy .elmName
                            |> List.map
                                (\canon ->
                                    if canon.attrForm == Attr.AsAttribute && anyPropertyForm comps canon.elmName then
                                        { canon | attrForm = Attr.AsProperty }

                                    else
                                        canon
                                )
                            |> List.sortBy .elmName

                    -- One deterministic note per attribute name whose SETTER TYPE differs
                    -- across components, naming the type the shared canonical took and the
                    -- components that therefore keep a local setter. Keyed on the emitted
                    -- setter type (not `Attr.AttrType`) so enum-vs-enum and
                    -- enum-vs-free-string — both `String` at the setter boundary — are not
                    -- reported as conflicts.
                    conflictNotes =
                        let
                            occurrences =
                                comps
                                    |> List.concatMap
                                        (\c -> c.attrs |> List.map (\a -> ( a.elmName, ( Attr.setterType a.type_, c.name ) )))

                            canonicalLabel name =
                                sharedAttrs
                                    |> List.filter (\a -> a.elmName == name)
                                    |> List.head
                                    |> Maybe.map (.type_ >> Attr.setterType)
                                    |> Maybe.withDefault "?"
                        in
                        sharedAttrs
                            |> List.filterMap
                                (\canon ->
                                    let
                                        forName =
                                            occurrences
                                                |> List.filter (\( n, _ ) -> n == canon.elmName)
                                                |> List.map Tuple.second

                                        distinct =
                                            forName |> List.map Tuple.first |> List.foldl consUnique [] |> List.sort
                                    in
                                    if List.length distinct < 2 then
                                        Nothing

                                    else
                                        Just
                                            ("elm-cem: attr '"
                                                ++ canon.elmName
                                                ++ "' has conflicting setter types across components ("
                                                ++ (forName
                                                        |> List.sortBy Tuple.second
                                                        |> List.map (\( t, c ) -> c ++ " : " ++ t)
                                                        |> String.join ", "
                                                   )
                                                ++ "); the shared "
                                                ++ lib
                                                ++ ".Attributes."
                                                ++ canon.elmName
                                                ++ " is "
                                                ++ canonicalLabel canon.elmName
                                                ++ " and every other component keeps a locally-typed setter."
                                            )
                                )

                    -- The same treatment for the attribute-vs-PROPERTY form. A split form
                    -- is not an error — it is the whole point of `_controlled`'s element
                    -- scope — but it IS a place where one name means two runtime things,
                    -- and the `datetime` lesson is that such a choice must never be
                    -- silent. Names which elements get the content-attribute form and
                    -- states that the shared canonical took the property one.
                    --
                    -- The note is worth reading as a CHECKLIST, because it lists exactly
                    -- the elements to which the shared property-form setter will be
                    -- applied without being the live form they want. Each must be one a
                    -- string property write is harmless on — i.e. a REFLECTING element. An
                    -- element whose IDL type coerces (`double`, `long`) belongs on its own
                    -- capability row and should not appear here at all; see `sharedAttrs`.
                    formNotes =
                        sharedAttrs
                            |> List.filterMap
                                (\canon ->
                                    let
                                        attributeOwners =
                                            comps
                                                |> List.filter
                                                    (\c ->
                                                        c.attrs
                                                            |> List.any (\a -> a.elmName == canon.elmName && a.attrForm == Attr.AsAttribute)
                                                    )
                                                |> List.map .name
                                                |> List.sort
                                    in
                                    if List.isEmpty attributeOwners || canon.attrForm == Attr.AsAttribute then
                                        Nothing

                                    else
                                        Just
                                            ("elm-cem: attr '"
                                                ++ canon.elmName
                                                ++ "' is a content attribute on "
                                                ++ String.join ", " attributeOwners
                                                ++ " and a DOM property elsewhere; the shared "
                                                ++ lib
                                                ++ ".Attributes."
                                                ++ canon.elmName
                                                ++ " is the PROPERTY form (the form that cannot go inert on a controlled"
                                                ++ " element) and each content-attribute element keeps a local setter."
                                                ++ " Every element named here must be one whose IDL attribute of that name"
                                                ++ " REFLECTS; one whose IDL type coerces needs its own setter name and"
                                                ++ " capability row (`_renames` + `attrTypes`)."
                                            )
                                )

                    sharedEvents =
                        comps
                            |> List.concatMap .events
                            |> dedupBy .name
                            |> List.sortBy .name

                    sets =
                        raw.sets
                            |> Dict.toList
                            |> List.map
                                (\( name, members ) ->
                                    members
                                        |> List.map
                                            (\mRaw ->
                                                let
                                                    m =
                                                        if mRaw == "main" then
                                                            "main_"

                                                        else
                                                            mRaw
                                                in
                                                case Dict.get m (comps |> List.map (\c -> ( c.ctor, c )) |> Dict.fromList) of
                                                    Just c ->
                                                        Ok c.produces

                                                    Nothing ->
                                                        Err ("_sets." ++ name ++ ": unknown component '" ++ m ++ "'")
                                            )
                                        |> combine
                                        |> Result.mapError List.singleton
                                        |> Result.map (\fields -> { name = name, pascal = Naming.pascal name, fields = sortFields fields })
                                )
                            |> combineAll

                    roleVocab =
                        raw.aria |> Maybe.map .roles |> Maybe.withDefault []

                    -- `AsProperty` names its DOM property `Attr.propertyName`: the CEM
                    -- `fieldName`, else `htmlName` VERBATIM. Verbatim is the identity,
                    -- never a camel-cased guess (issue #33) — but that also means a
                    -- HYPHENATED name has no same-named IDL property, so `Ir.property
                    -- "aria-label"` would set an inert own-property nobody observes.
                    -- Fail loud instead of emitting a setter that does nothing.
                    controlledFormErrors =
                        comps
                            |> List.concatMap
                                (\c ->
                                    c.attrs
                                        |> List.filterMap
                                            (\a ->
                                                if a.attrForm == Attr.AsProperty && a.reactiveProp == Nothing && String.contains "-" a.htmlName then
                                                    Just
                                                        ("attrForm/_controlled: '"
                                                            ++ a.htmlName
                                                            ++ "' on "
                                                            ++ c.name
                                                            ++ " asks for the PROPERTY form, but a hyphenated name has no same-named DOM property (issue #33). Declare the real IDL name as the CEM `fieldName`, or leave it as an attribute."
                                                        )

                                                else
                                                    Nothing
                                            )
                                )

                    -- A `_controlled` entry's `elements` scope must name elements that
                    -- exist AND that declare the attribute. A typo would otherwise leave
                    -- the entry covering nothing — the plain setter silently reverts to
                    -- the content-attribute form, which for `value` on an `<input>` is
                    -- exactly issue #41 back again, with no diagnostic anywhere. The
                    -- scope's whole job is to be a deliberate, checked statement about
                    -- which elements diverge, so an unverifiable one is refused.
                    -- `elements: []` names no element, so the entry would cover nothing
                    -- while LOOKING deliberate. Omitting the key is how you say "every
                    -- element declaring it"; deleting the entry is how you say "none".
                    emptyScopeErrors =
                        raw.controlled
                            |> List.filterMap
                                (\ct ->
                                    if ct.elements == Just [] then
                                        Just
                                            ("_controlled['"
                                                ++ ct.htmlName
                                                ++ "'].elements is empty, so the entry controls nothing. Omit `elements` to cover every element declaring the attribute, or remove the entry."
                                            )

                                    else
                                        Nothing
                                )

                    unknownScopeErrors =
                        raw.controlled
                            |> List.concatMap
                                (\ct ->
                                    ct.elements
                                        |> Maybe.withDefault []
                                        |> List.filterMap
                                            (\name ->
                                                case comps |> List.filter (\c -> c.tag == name || c.name == name) of
                                                    [] ->
                                                        Just
                                                            ("_controlled['"
                                                                ++ ct.htmlName
                                                                ++ "'].elements: '"
                                                                ++ name
                                                                ++ "' is not an element of this brand (name it by tag or by declaration name)"
                                                            )

                                                    matches ->
                                                        if matches |> List.any (\c -> c.attrs |> List.any (\a -> a.htmlName == ct.htmlName)) then
                                                            Nothing

                                                        else
                                                            Just
                                                                ("_controlled['"
                                                                    ++ ct.htmlName
                                                                    ++ "'].elements: '"
                                                                    ++ name
                                                                    ++ "' does not declare a '"
                                                                    ++ ct.htmlName
                                                                    ++ "' attribute"
                                                                )
                                            )
                                )

                    controlledElementErrors =
                        emptyScopeErrors ++ unknownScopeErrors

                    -- A `propertyOnly` entry must name an attribute this component
                    -- actually declares AND one the brand roster controls ON THIS
                    -- ELEMENT; otherwise it is a typo that silently suppresses nothing.
                    --
                    -- The element-scope arm matters because `propertyOnly` and the scope
                    -- are opposite requests: `propertyOnly` says "keep the live property
                    -- but drop the dishonest `default*`", while an out-of-scope element
                    -- has no live property to keep. Asking for both is a contradiction,
                    -- and the emitted result would look like the `propertyOnly` was
                    -- honoured (no companion) when in fact the scope did all the work.
                    propertyOnlyErrors =
                        comps
                            |> List.concatMap
                                (\c ->
                                    c.propertyOnly
                                        |> List.filterMap
                                            (\name ->
                                                case raw.controlled |> List.filter (\ct -> ct.htmlName == name) of
                                                    [] ->
                                                        Just (c.name ++ ".propertyOnly: '" ++ name ++ "' is not in `_controlled`")

                                                    entries ->
                                                        if not (List.any (\a -> a.htmlName == name) c.attrs) then
                                                            Just (c.name ++ ".propertyOnly: '" ++ name ++ "' is not an attribute of " ++ c.name)

                                                        else if not (List.any (\ct -> scopeCovers ct c) entries) then
                                                            Just
                                                                (c.name
                                                                    ++ ".propertyOnly: '"
                                                                    ++ name
                                                                    ++ "' is outside `_controlled['"
                                                                    ++ name
                                                                    ++ "'].elements`, so there is no live property here to keep — the plain setter already writes the content attribute. Drop the `propertyOnly`, or add "
                                                                    ++ c.tag
                                                                    ++ " to the scope."
                                                                )

                                                        else
                                                            Nothing
                                            )
                                )

                    -- `_variants` validation. A variant is emitted FROM the base
                    -- attribute's shared-vocabulary spec (that is where its capability
                    -- row and its DOM name come from), so a `base` no component declares
                    -- produces no setter at all — silently, which is the failure mode
                    -- this whole change exists to remove. Reject the typo instead.
                    --
                    -- Matched on `elmName`, the SETTER name, not on `htmlName` — same as
                    -- `Emit.variantsFor`, and the two must agree or a base validates here
                    -- and emits nothing there. `elmName` is the right key because a
                    -- variant claims the base's capability ROW, and the row follows the
                    -- setter name: once `_renames` moves one element's `value` to
                    -- `valueNumeric` (a `<progress>` opting out of the shared `value`
                    -- vocabulary because its IDL type is `double`), that element is not a
                    -- place `valueAsNumber` belongs, and matching `htmlName` would both put
                    -- it there and make the choice of which of several rows to claim an
                    -- arbitrary `List.head` — the `datetime` failure shape.
                    variantErrors =
                        raw.variants
                            |> List.filterMap
                                (\v ->
                                    if comps |> List.any (\c -> c.attrs |> List.any (\a -> a.elmName == v.base)) then
                                        Nothing

                                    else
                                        Just
                                            ("_variants: '"
                                                ++ v.name
                                                ++ "' declares base attribute '"
                                                ++ v.base
                                                ++ "', which no component in this brand declares under that SETTER name"
                                                ++ " (it is the camel-cased HTML name unless `_renames` moved it)."
                                            )
                                )

                    roleErrors =
                        comps
                            |> List.concatMap
                                (\c ->
                                    c.roles
                                        |> Maybe.withDefault []
                                        |> List.filterMap
                                            (\r ->
                                                if List.member r roleVocab then
                                                    Nothing

                                                else
                                                    Just (c.name ++ ".roles: '" ++ r ++ "' is not in _aria.roles")
                                            )
                                )

                    -- Every `Shared`-marked field that reaches emission, checked
                    -- against `sharedAtomVocabulary`. Covers all three ways a
                    -- shared role enters: `_atoms`, a component's `kind`, and a
                    -- slot's `kinds`. Set members resolve through `producesOf`,
                    -- so a set's fields are already covered by its members'
                    -- `produces` — no separate walk needed.
                    atomVocabErrors =
                        let
                            checkField where_ kf =
                                case kf.marker of
                                    MShared ->
                                        let
                                            role =
                                                sharedRoleOfField kf.field
                                        in
                                        if knownSharedRole role then
                                            Nothing

                                        else
                                            Just (unknownSharedRoleError where_ role)

                                    MBrand ->
                                        Nothing

                            slotFields s =
                                case s.content of
                                    Permissive ->
                                        []

                                    SetContent set ->
                                        set.fields

                                    Fields fs ->
                                        fs
                        in
                        (raw.atoms
                            |> List.filterMap
                                (\role ->
                                    if knownSharedRole role then
                                        Nothing

                                    else
                                        Just (unknownSharedRoleError "_atoms" role)
                                )
                        )
                            ++ (comps
                                    |> List.concatMap
                                        (\c ->
                                            (checkField (c.name ++ ".kind") c.produces
                                                |> Maybe.map List.singleton
                                                |> Maybe.withDefault []
                                            )
                                                ++ (c.slots
                                                        |> List.concatMap
                                                            (\s ->
                                                                slotFields s
                                                                    |> List.filterMap (checkField (c.name ++ "." ++ s.name))
                                                            )
                                                   )
                                        )
                               )
                            |> dedupBy identity

                    -- K4: Resolve event handler names with collision handling.
                    -- prefix-stripping is the default; when a prefix-stripped brand event
                    -- handler name collides with a lossless native-event name, the brand
                    -- event reverts its prefix-strip. Both on<X>/on<X>With pairs rename
                    -- together.
                    -- Then apply event renames from _renames._events (override config).
                    resolvedHandlers =
                        resolveEventHandlers eventPrefix sharedEvents
                            |> Dict.map
                                (\evName handlerName ->
                                    Dict.get evName raw.renames.events |> Maybe.withDefault handlerName
                                )

                    -- K7: Resolve barrel ctor names. When a comp's ctor collides with an
                    -- atom name in the barrel module, the ctor reverts to the full-tag camel
                    -- form (e.g. fluent-text → fluentText). The atom keeps the plain name.
                    atoms_ =
                        List.sort raw.atoms

                    compsWithK7 =
                        comps
                            |> List.map
                                (\c ->
                                    if List.member c.ctor atoms_ then
                                        { c | resolvedCtor = Naming.camel c.tag }

                                    else
                                        c
                                )

                    -- K7 renames from _renames._elements: apply AFTER K7 collision detection.
                    -- If an element tag is explicitly overridden, use the new name instead
                    -- of the deterministic K7 result.
                    compsWithElementRenames =
                        compsWithK7
                            |> List.map
                                (\c ->
                                    case Dict.get c.tag raw.renames.elements of
                                        Just newName ->
                                            { c | resolvedCtor = newName }

                                        Nothing ->
                                            c
                                )

                    -- The brand-wide roster of ( DOM name, reason ) pairs this run
                    -- refused to emit, pooled from BOTH sources — the `_globals` roster
                    -- and every component's own attributes — then deduplicated by name.
                    -- One `formaction` note is right even though seven elements declare
                    -- it: the reason is a fact about the NAME, not about the element.
                    kernelBlockedRoster =
                        (raw.globals |> List.map Tuple.second |> List.filter Attr.kernelBlocked)
                            ++ (comps |> List.concatMap .blockedAttrs)
                            |> List.filterMap
                                (\a -> Attr.kernelBlockedReason a |> Maybe.map (Tuple.pair a.htmlName))
                            |> List.foldl
                                (\( name, reason ) acc ->
                                    if List.any (\( n, _ ) -> n == name) acc then
                                        acc

                                    else
                                        acc ++ [ ( name, reason ) ]
                                )
                                []
                            |> List.sortBy Tuple.first
                in
                case ( r1Errors ++ roleErrors ++ atomVocabErrors ++ controlledFormErrors ++ controlledElementErrors ++ propertyOnlyErrors ++ variantErrors ++ tokenValueErrors, sets ) of
                    ( [], Ok setAliases ) ->
                        Ok
                            { lib = lib
                            , eventPrefix = eventPrefix
                            , comps = compsWithElementRenames
                            , sets = List.sortBy .name setAliases
                            , unions = unions
                            , sharedAttrs = sharedAttrs
                            , sharedEvents = sharedEvents
                            , resolvedEventHandlers = resolvedHandlers
                            , atoms = atoms_
                            , globals = List.sortBy .elmName globals
                            , openGlobals = List.sortBy .elmName openGlobals
                            , controlled = raw.controlled
                            , variants = raw.variants
                            , aria = raw.aria
                            , actions = raw.actions
                            , legacyHtml = raw.legacyHtml
                            , collapseNotes = buildNotes ++ conflictNotes ++ formNotes ++ globalBlockedNotes
                            , tokenRenames = raw.renames.tokens
                            , tokenValues = tokenValues
                            , elementRenames = raw.renames.elements
                            , kernelBlocked = kernelBlockedRoster
                            }

                    ( errs, Ok _ ) ->
                        Err errs

                    ( errs, Err setErrs ) ->
                        Err (errs ++ setErrs)
            )


{-| R1: within one container slot, every closed-parents member must carry an
IDENTICAL parents set (Elm lists are homogeneous — differing closed admittedBy
rows cannot share a list). Fixes: widen a member's `parents`, or split the
element into two constructor entries (R2).
-}
checkR1 : List Comp -> Comp -> List String
checkR1 comps container =
    let
        byCtor =
            comps |> List.map (\c -> ( c.ctor, c )) |> Dict.fromList

        memberParents : KindField -> Maybe ( String, List String )
        memberParents kf =
            Dict.get kf.field byCtor
                |> Maybe.andThen (\c -> Maybe.map (Tuple.pair c.ctor) c.admittedBy)

        checkSlot slot =
            let
                fields =
                    case slot.content of
                        Fields fs ->
                            fs

                        SetContent s ->
                            s.fields

                        Permissive ->
                            []

                closedMembers =
                    fields |> List.filterMap memberParents

                distinct =
                    closedMembers |> List.map Tuple.second |> dedupBy identity
            in
            if List.length distinct > 1 then
                [ "R1 violation in "
                    ++ container.name
                    ++ "."
                    ++ slot.name
                    ++ ": slot-mates have differing closed parents sets ("
                    ++ (closedMembers |> List.map (\( c, ps ) -> c ++ ":{" ++ String.join "," ps ++ "}") |> String.join " vs ")
                    ++ "). Widen a member's `parents` to the shared set, or split the element into per-context constructors (R2)."
                ]

            else
                []
    in
    container.slots |> List.concatMap checkSlot



{-| Does ANY component in the brand declare `elmName` in the DOM-PROPERTY form?

Used to break the shared-canonical form tie toward `AsProperty` — see `sharedAttrs`
for why the loose surface must take the form that cannot be INERT, and why the
elements a property write would coerce are expected to have left the row entirely
rather than to be accommodated here.

-}
anyPropertyForm : List Comp -> String -> Bool
anyPropertyForm comps elmName =
    comps
        |> List.any
            (\c ->
                c.attrs
                    |> List.any (\a -> a.elmName == elmName && a.attrForm == Attr.AsProperty)
            )



-- EVENT HANDLER RESOLUTION (K4)


{-| Compute a map from raw event name → resolved Elm handler name, applying K4
collision resolution.

The default handler name is `"on" ++ pascal (replace eventPrefix "" evName)`.
When two events map to the same handler name, the one whose normalization is
LOSSY (the brand event that had its prefix stripped) reverts to the full-prefixed
form (`onWaError` instead of `onError`). The lossless native event keeps its
plain name. Both `on<X>` and `on<X>With` are renamed together.

"Lossless" means the raw event name, after prefix-stripping, round-trips back
through camel/pascal unchanged (e.g. `"error"` → `"onError"` with no prefix to
strip). "Lossy" means a prefix was stripped: `"wa-error"` with prefix `"wa-"`
→ `"onError"` (info lost).

-}
resolveEventHandlers : String -> List Cem.Event -> Dict String String
resolveEventHandlers prefix events =
    let
        -- Default handler name (prefix-stripped).
        defaultHandler evName =
            "on" ++ Naming.pascal (String.replace prefix "" evName)

        -- Is the mapping lossless? True when strip is a no-op.
        isLossless evName =
            String.replace prefix "" evName == evName

        -- Full-prefix handler name (no stripping; used as K4 revert).
        fullPrefixHandler evName =
            "on" ++ Naming.pascal evName

        -- Build initial assignments.
        initial =
            events
                |> List.map (\ev -> ( ev.name, defaultHandler ev.name ))

        -- Collect collisions: find pairs that share a handler name.
        -- When a collision exists, the lossless one keeps the plain name;
        -- the lossy one reverts to the full-prefix form.
        resolveCollisions pairs =
            pairs
                |> List.foldl
                    (\( evName, handlerName_ ) acc ->
                        -- Check if any ALREADY-RESOLVED entry uses the same handler name.
                        let
                            collision =
                                Dict.toList acc
                                    |> List.filter (\( _, h ) -> h == handlerName_)
                                    |> List.head
                        in
                        case collision of
                            Nothing ->
                                -- No collision: assign default.
                                Dict.insert evName handlerName_ acc

                            Just ( existingEvName, _ ) ->
                                -- Collision detected.
                                if isLossless evName && not (isLossless existingEvName) then
                                    -- Current is lossless, existing is lossy: existing reverts.
                                    acc
                                        |> Dict.insert existingEvName (fullPrefixHandler existingEvName)
                                        |> Dict.insert evName handlerName_

                                else if isLossless existingEvName && not (isLossless evName) then
                                    -- Existing is lossless, current is lossy: current reverts.
                                    Dict.insert evName (fullPrefixHandler evName) acc

                                else
                                    -- Both lossless or both lossy (unusual): current gets full-prefix.
                                    Dict.insert evName (fullPrefixHandler evName) acc
                    )
                    Dict.empty
    in
    resolveCollisions initial



-- SMALL HELPERS


sortFields : List KindField -> List KindField
sortFields =
    dedupBy .field >> List.sortBy .field


orMaybe : Maybe a -> Maybe a -> Maybe a
orMaybe a b =
    case a of
        Just _ ->
            a

        Nothing ->
            b


consUnique : a -> List a -> List a
consUnique x xs =
    if List.member x xs then
        xs

    else
        x :: xs


dedupBy : (a -> b) -> List a -> List a
dedupBy key =
    List.foldr
        (\x acc ->
            if List.any (\y -> key y == key x) acc then
                acc

            else
                x :: acc
        )
        []


combine : List (Result e a) -> Result e (List a)
combine =
    List.foldr (Result.map2 (::)) (Ok [])


combineAll : List (Result (List e) a) -> Result (List e) (List a)
combineAll rs =
    let
        errs =
            rs
                |> List.concatMap
                    (\r ->
                        case r of
                            Err es ->
                                es

                            Ok _ ->
                                []
                    )
    in
    if List.isEmpty errs then
        rs
            |> List.filterMap Result.toMaybe
            |> Ok

    else
        Err errs
