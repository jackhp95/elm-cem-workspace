module Compose.FromHtml exposing (ExampleChild(..), ExampleNode, parse, toMsgs)

{-| Parse a real example's `html` string (from `data/examples.json`) into the
`Cem.Compose.Msg` sequence that would build the same tree by hand.

Brand-agnostic on purpose: this module knows nothing about `M3e`. The caller
supplies `facts`/`attrKinds` — the same shape `Cem.Compose.init` itself takes
— so this parser works for any manifest, not just `M3e.Review.Facts`.

`Cem.Compose.Node` is opaque (its slot-cardinality invariant is enforced by
`update`, not by construction — see `elm-cem-compose`'s README), so this
module cannot build one directly. It owns its own intermediate tree,
`ExampleNode`, and only ever reaches `Cem.Compose` through its public `Msg`
constructors, via `toMsgs`.

`Compose.Render`'s `tagFor`/`toKebabCase` is the forward map (`"appBar"` →
`"m3e-app-bar"`); `componentFromTag` here is its inverse. Anything this
parser can't account for — an unrecognized element, an attribute in neither
`fact.enums` nor `attrKinds`, a root tag naming no known component — is
silently dropped, not an error: a demo prefill is allowed to be lossy.

-}

import Cem.Compose
import Cem.Facts exposing (Fact)
import Dict exposing (Dict)
import Html.Parser


{-| The tree this module builds from parsed HTML, one level up from
`Cem.Compose.Child`: `ChildElem` wraps another `ExampleNode`, not a
`Cem.Compose.Node` (which nothing outside `Cem.Compose.update` can produce).
-}
type alias ExampleNode =
    { component : String
    , attrs : List ( String, Cem.Compose.AttrValue )
    , children : List ( String, List ExampleChild )
    }


{-| One occupant of a slot — the `ExampleNode`-level mirror of
`Cem.Compose.Child`.
-}
type ExampleChild
    = ChildElem ExampleNode
    | ChildText String
    | ChildIcon String


type alias Context =
    { facts : List Fact
    , attrKinds : Dict String Cem.Compose.AttrKind
    }


{-| Parse one example's `html` into an `ExampleNode`. `Nothing` only when the
root element's tag names no known component — every other unrecognized bit
(a child element with no matching `Fact`, an attribute neither enum nor
`attrKinds`-classified) is dropped in place, not treated as failure.
-}
parse : { facts : List Fact, attrKinds : Dict String Cem.Compose.AttrKind } -> String -> Maybe ExampleNode
parse ctx html =
    case Html.Parser.run html of
        Ok nodes ->
            nodes
                |> List.filterMap asElement
                |> List.head
                |> Maybe.andThen (toExampleNode ctx)

        Err _ ->
            Nothing


asElement : Html.Parser.Node -> Maybe ( String, List Html.Parser.Attribute, List Html.Parser.Node )
asElement node =
    case node of
        Html.Parser.Element tag attrs children ->
            Just ( tag, attrs, children )

        _ ->
            Nothing


toExampleNode : Context -> ( String, List Html.Parser.Attribute, List Html.Parser.Node ) -> Maybe ExampleNode
toExampleNode ctx ( tag, attrs, children ) =
    case componentFromTag ctx.facts tag |> Maybe.andThen (findFact ctx.facts) of
        Nothing ->
            Nothing

        Just fact ->
            Just
                { component = fact.component
                , attrs = List.filterMap (classifyAttr ctx fact) attrs
                , children = groupBySlot (List.filterMap (toPlacedChild ctx) children)
                }


findFact : List Fact -> String -> Maybe Fact
findFact facts component =
    List.head (List.filter (\f -> f.component == component) facts)


{-| `"app-bar"` → `"appBar"` — the inverse of `Compose.Render.toKebabCase`,
then kept only if some `Fact.component` actually matches it.
-}
componentFromTag : List Fact -> String -> Maybe String
componentFromTag facts tag =
    if String.startsWith "m3e-" tag then
        let
            candidate : String
            candidate =
                unKebabCase (String.dropLeft 4 tag)
        in
        if List.any (\f -> f.component == candidate) facts then
            Just candidate

        else
            Nothing

    else
        Nothing


unKebabCase : String -> String
unKebabCase input =
    input
        |> String.toList
        |> unKebabChars
        |> String.fromList


unKebabChars : List Char -> List Char
unKebabChars chars =
    case chars of
        '-' :: c :: rest ->
            Char.toUpper c :: unKebabChars rest

        c :: rest ->
            c :: unKebabChars rest

        [] ->
            []


{-| The same rule `Cem.Compose.attrChips` uses to decide whether a name gets
a chip at all: a real enum on this component → `AttrEnum`; else a name both
present in `attrKinds` (the caller's per-attribute type table) is classified
by that kind. `slot` is placement, never a node attr. Anything else —
`aria-label`, an event attribute, a name this manifest doesn't know — is
dropped. A present boolean attribute is always `True`: this parser only ever
reads HTML that `Compose.Attrs.toAttribute` could have produced, which never
serializes a boolean attribute as `False` (it omits it instead).
-}
classifyAttr : Context -> Fact -> Html.Parser.Attribute -> Maybe ( String, Cem.Compose.AttrValue )
classifyAttr ctx fact ( name, value ) =
    if name == "slot" then
        Nothing

    else if List.any (\( enumName, _ ) -> enumName == name) fact.enums then
        Just ( name, Cem.Compose.AttrEnum value )

    else
        case Dict.get name ctx.attrKinds of
            Just Cem.Compose.BoolAttr ->
                Just ( name, Cem.Compose.AttrBool True )

            Just Cem.Compose.StringAttr ->
                Just ( name, Cem.Compose.AttrString value )

            Just Cem.Compose.FloatAttr ->
                Just ( name, Cem.Compose.AttrFloat value )

            Just Cem.Compose.IntAttr ->
                Just ( name, Cem.Compose.AttrInt value )

            Nothing ->
                Nothing


slotOf : List Html.Parser.Attribute -> String
slotOf attrs =
    attrs
        |> List.filter (\( name, _ ) -> name == "slot")
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault "unnamed"


{-| One child, paired with the slot it lands in. `m3e-icon` is special-cased
(its glyph is its `name` attribute, not text content — matching
`Compose.Render`/`Compose.Codegen`); a bare non-whitespace text node is a
`ChildText`; any other element recurses, and is dropped (returning `Nothing`)
if it names no known component. A comment, or whitespace-only text, drops
silently.
-}
toPlacedChild : Context -> Html.Parser.Node -> Maybe ( String, ExampleChild )
toPlacedChild ctx node =
    case node of
        Html.Parser.Comment _ ->
            Nothing

        Html.Parser.Text raw ->
            let
                trimmed : String
                trimmed =
                    String.trim raw
            in
            if String.isEmpty trimmed then
                Nothing

            else
                Just ( "unnamed", ChildText trimmed )

        Html.Parser.Element "m3e-icon" attrs _ ->
            Just
                ( slotOf attrs
                , ChildIcon
                    (attrs
                        |> List.filter (\( name, _ ) -> name == "name")
                        |> List.head
                        |> Maybe.map Tuple.second
                        |> Maybe.withDefault ""
                    )
                )

        Html.Parser.Element tag attrs children ->
            toExampleNode ctx ( tag, attrs, children )
                |> Maybe.map (\inner -> ( slotOf attrs, ChildElem inner ))


{-| Group placed children by slot, in first-seen slot order, preserving each
slot's own child order — an `elm/core`-only substitute for
`List.Extra.gatherEqualsBy`, since a group's _order_ (not just membership)
must survive.
-}
groupBySlot : List ( String, ExampleChild ) -> List ( String, List ExampleChild )
groupBySlot placed =
    let
        step : ( String, ExampleChild ) -> ( List String, Dict String (List ExampleChild) ) -> ( List String, Dict String (List ExampleChild) )
        step ( slot, child ) ( seenOrder, groups ) =
            ( if List.member slot seenOrder then
                seenOrder

              else
                seenOrder ++ [ slot ]
            , Dict.update slot (\existing -> Just (Maybe.withDefault [] existing ++ [ child ])) groups
            )

        ( finalOrder, finalGroups ) =
            List.foldl step ( [], Dict.empty ) placed
    in
    List.filterMap (\slot -> Dict.get slot finalGroups |> Maybe.map (\children -> ( slot, children ))) finalOrder


{-| The message sequence that fills a node ALREADY created (and empty) at
`path` with this `ExampleNode`'s attrs and children — the caller creates the
root itself (`AddChild`/`SetComponent`) before applying these. Every slot's
children are addressed by their position within THIS example's list for that
slot (`0, 1, 2, ...`): on a multi slot that matches append order exactly,
since each `Add*` only ever appends; on every other slot `Cem.Compose.update`
replaces at index 0 regardless, so a well-formed example (never more than one
child in a non-multi slot) lands its one child at `0` all the same.
-}
toMsgs : Cem.Compose.Path -> ExampleNode -> List Cem.Compose.Msg
toMsgs path node =
    List.map (\( name, value ) -> Cem.Compose.SetAttr path name value) node.attrs
        ++ List.concatMap (slotMsgs path) node.children


slotMsgs : Cem.Compose.Path -> ( String, List ExampleChild ) -> List Cem.Compose.Msg
slotMsgs path ( slotName, children ) =
    List.concat (List.indexedMap (childMsgs path slotName) children)


childMsgs : Cem.Compose.Path -> String -> Int -> ExampleChild -> List Cem.Compose.Msg
childMsgs path slotName index child =
    case child of
        ChildText text ->
            [ Cem.Compose.AddTextChild path slotName
            , Cem.Compose.SetChildContent path slotName index text
            ]

        ChildIcon glyph ->
            [ Cem.Compose.AddIconChild path slotName
            , Cem.Compose.SetChildContent path slotName index glyph
            ]

        ChildElem inner ->
            Cem.Compose.AddChild path slotName inner.component
                :: toMsgs (path ++ [ Cem.Compose.IntoSlot slotName index ]) inner
