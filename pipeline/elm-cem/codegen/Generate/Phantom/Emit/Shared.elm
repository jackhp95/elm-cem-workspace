module Generate.Phantom.Emit.Shared exposing (..)


import Attr
import Cem
import Char
import Dict
import Docs
import Elm
import Generate.Phantom.Model as M exposing (Brand, Comp, EnumSpec, KindField, Marker(..), ResolvedSlot, SlotContent(..))
import Json.Encode as Encode
import Naming


-- SHARED RENDERING


doc : String -> String
doc text =
    "{-| " ++ text ++ "\n-}"


{-| The `Ir.node` constructor head for this brand's element ctors. For an
ordinary (HTML-namespace) brand it is `Ir.node`; for a namespaced brand
(`_namespace` set — SVG/MathML) it is `Ir.nodeNS "<uri>"`, so every generated
element renders through `VirtualDom.nodeNS` / `createElementNS` and actually
paints. The trailing tag argument (a `"literal"` or a runtime `b.tag`) is
appended by the caller, so both forms compose the same way:

    nodeHead brand ++ " \"" ++ comp.tag ++ "\""

Purely additive: with `namespace == Nothing` the output is byte-identical to the
pre-1.1 emitter, so every existing HTML brand regenerates unchanged.

-}
nodeHead : Brand -> String
nodeHead brand =
    case brand.namespace of
        Nothing ->
            "Ir.node"

        Just uri ->
            "Ir.nodeNS \"" ++ uri ++ "\""


handlerName : Brand -> Cem.Event -> String
handlerName brand event =
    case event.setter of
        -- A config `eventPayloads` annotation names the setter/capability
        -- explicitly (e.g. `input`'s `change` event → `onCheck`). This lets the
        -- SAME raw event name resolve to different setters on different elements
        -- (input.change → onCheck, select.change → onChange).
        Just s ->
            s

        Nothing ->
            -- K4: use the pre-resolved handler name from the brand model. On collision
            -- between a lossless native event and a prefix-stripped brand event, the
            -- brand event reverts to its full-prefix form (e.g. onWaError). The
            -- resolution lives in Brand.resolvedEventHandlers (computed in Model.resolve).
            Dict.get event.name brand.resolvedEventHandlers
                |> Maybe.withDefault ("on" ++ Naming.pascal (String.replace brand.eventPrefix "" event.name))


{-| The closed-vocabulary payload decoder: the Elm payload type and the baked
`Json.Decode` expression for each standard native-control decoder.
-}
payloadTypeAndDecoder : Cem.Payload -> ( String, String )
payloadTypeAndDecoder payload =
    case payload of
        Cem.TargetValue ->
            ( "String", "Json.Decode.at [ \"target\", \"value\" ] Json.Decode.string" )

        Cem.TargetChecked ->
            ( "Bool", "Json.Decode.at [ \"target\", \"checked\" ] Json.Decode.bool" )


{-| Distinct event SETTERS across the whole brand, deduped by resolved setter
name (`handlerName`), then ordered by raw event name to preserve the emitted
order for unannotated brands. Unlike `brand.sharedEvents` (deduped by raw event
NAME), this keeps two setters that share one raw event — e.g. `onCheck` and
`onChange` both listening on `change` — which is what payload annotations need.
For brands with no annotations this is byte-identical to `brand.sharedEvents`.
-}
distinctSetterEvents : Brand -> List Cem.Event
distinctSetterEvents brand =
    brand.comps
        |> List.concatMap .events
        -- Prefer the ANNOTATED occurrence when several elements share one setter
        -- name: a single shared Events module gives each setter ONE shape, so an
        -- element that leaves the event bare (e.g. select's `input`) still adopts
        -- the payload-typed setter another element annotated (input's `input`).
        -- Stable sort keeps unannotated brands' order byte-identical.
        |> List.sortBy
            (\ev ->
                if ev.payload == Nothing then
                    1

                else
                    0
            )
        |> dedupeBy (handlerName brand)
        |> List.sortBy .name


dedupeBy : (a -> comparable) -> List a -> List a
dedupeBy key xs =
    xs
        |> List.foldl
            (\x ( seen, acc ) ->
                let
                    k =
                        key x
                in
                if List.member k seen then
                    ( seen, acc )

                else
                    ( k :: seen, x :: acc )
            )
            ( [], [] )
        |> Tuple.second
        |> List.reverse


markerName : Marker -> String
markerName m =
    case m of
        MBrand ->
            "Brand"

        MShared ->
            "Shared"


kindRow : List KindField -> String
kindRow fields =
    "{ "
        ++ (fields |> List.map (\f -> f.field ++ " : " ++ markerName f.marker) |> String.join "\n    , ")
        ++ "\n    }"


{-| Closed row rendered on one line when it has a single field.
-}
kindRowCompact : List KindField -> String
kindRowCompact fields =
    case fields of
        [ f ] ->
            "{ " ++ f.field ++ " : " ++ markerName f.marker ++ " }"

        _ ->
            kindRow fields


supportedRow : List String -> String
supportedRow fields =
    "{ "
        ++ (fields |> List.map (\f -> f ++ " : Supported") |> String.join "\n    , ")
        ++ "\n    }"


capsRecord : String -> List String -> String
capsRecord marker fields =
    case fields of
        [] ->
            "{}"

        _ ->
            "{ "
                ++ (fields |> List.map (\f -> f ++ " : " ++ marker) |> String.join "\n    , ")
                ++ "\n    }"


exposeBlock : List (List String) -> String
exposeBlock groups =
    let
        gs =
            groups |> List.filter (not << List.isEmpty)
    in
    "    ( "
        ++ (gs |> List.map (String.join ", ") |> String.join "\n    , ")
        ++ "\n    )"


docsBlock : List (List String) -> String
docsBlock groups =
    groups
        |> List.filter (not << List.isEmpty)
        |> List.map (\g -> "@docs " ++ String.join ", " g)
        |> String.join "\n"





-- RELOCATED FROM COMPOSER / OTHER SECTIONS (breaks cross-module import cycles;
-- see decomposition report for rationale — each function is verbatim, only its
-- module residence changed)


{-| Route a component: rich per-component module (DS default), or the
home-grouped view-only path (native families; also any component using
`transparent`/`roles`, which only that path renders).
-}
homeOf : Comp -> Maybe String
homeOf comp =
    case comp.home of
        Just h ->
            Just h

        Nothing ->
            if comp.transparent || comp.roles /= Nothing then
                Just comp.name

            else
                Nothing


file : List String -> String -> Elm.File
file modulePath contents =
    { path = String.join "/" modulePath ++ ".elm"
    , contents = contents
    , warnings = []
    }


{-| The Elm input type a scalar attribute's setter takes. A thin projection of
`Attr.setterType` (the ONE definition; see there for why enums spell `String`).
-}
setterInputType : Attr.AttrSpec -> String
setterInputType a =
    Attr.setterType a.type_


{-| Where a component's constructor lives and which alias prefix it uses:
own-module comps → (<Name>, ""); home members → (<Home>, Pascal ctor when the
home has >1 member, "" when it is a single-member home).
-}
memberRef : Brand -> Comp -> { module_ : String, prefix : String }
memberRef brand comp =
    case homeOf comp of
        Nothing ->
            { module_ = comp.name, prefix = "" }

        Just h ->
            let
                groupSize =
                    brand.comps |> List.filter (\c -> homeOf c == Just h) |> List.length
            in
            { module_ = h
            , prefix =
                if groupSize > 1 then
                    Naming.pascal comp.ctor

                else
                    ""
            }


dedup : List comparable -> List comparable
dedup =
    List.foldr
        (\x acc ->
            if List.member x acc then
                acc

            else
                x :: acc
        )
        []
