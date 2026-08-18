module Generate.Phantom.Emit.Action exposing (..)


import Attr
import Cem
import Char
import Dict
import Docs
import Elm
import Generate.Phantom.Model as M exposing (Brand, Comp, EnumSpec, KindField, Marker(..), ResolvedSlot, SlotContent(..))
import Json.Encode as Encode
import Naming

import Generate.Phantom.Emit.Shared exposing (..)


-- ACTION MODULE (behavioural actions — emitted from the _actions roster)


{-| The Elm type an `Action` ctor's payload argument takes, for a rich wrapper
(finding 2.2): `String` for `SingleArgPayload`, its own record type name for
`RecordPayload`.
-}
richPayloadTypeName : M.RichPayload -> String
richPayloadTypeName payload =
    case payload of
        M.SingleArgPayload _ ->
            "String"

        M.RecordPayload r ->
            r.typeName


{-| The bound parameter name a rich wrapper's ctor/case-branch uses for its
payload argument.
-}
richPayloadParamName : M.RichPayload -> String
richPayloadParamName payload =
    case payload of
        M.SingleArgPayload p ->
            p.paramName

        M.RecordPayload r ->
            r.paramName


optionalFieldElmType : M.OptionalFieldKind -> String
optionalFieldElmType kind =
    case kind of
        M.FloatField ->
            "Float"

        M.PresenceField ->
            "Bool"


{-| One optional record field's `Maybe.map (\x -> Ir.attribute "attr" …) paramName.field`
line inside a rich record-payload's `wrapContent` branch.
-}
optionalFieldLine : String -> { field : String, attr : String, kind : M.OptionalFieldKind } -> String
optionalFieldLine paramName o =
    case o.kind of
        M.FloatField ->
            "Maybe.map (\\d -> Ir.attribute \"" ++ o.attr ++ "\" (String.fromFloat d)) " ++ paramName ++ "." ++ o.field

        M.PresenceField ->
            "Maybe.map (\\s -> Ir.attribute \"" ++ o.attr ++ "\" \"\") " ++ paramName ++ "." ++ o.field


{-| A rich record-payload wrapper's `type alias <TypeName> = { required : String, opt1 :
Maybe …, … }` declaration lines (empty for a `SingleArgPayload`, which has no type
alias of its own).
-}
richTypeAliasLines : M.RichActionWrapper -> List String
richTypeAliasLines w =
    case w.payload of
        M.SingleArgPayload _ ->
            []

        M.RecordPayload r ->
            [ ""
            , ""
            , doc r.typeDoc
            , "type alias " ++ r.typeName ++ " ="
            , "    { "
                ++ r.required.field
                ++ " : String"
                ++ String.concat (List.map (\o -> ", " ++ o.field ++ " : Maybe " ++ optionalFieldElmType o.kind) r.optional)
                ++ " }"
            ]


{-| A rich wrapper's ctor declaration lines (`opensBottomSheet : BottomSheetSpec
-> …` / `dialogAction : String -> …`).
-}
richProducerLines : M.RichActionWrapper -> List String
richProducerLines w =
    [ ""
    , ""
    , doc w.doc
    , w.ctor ++ " : " ++ richPayloadTypeName w.payload ++ " -> Action { c | " ++ w.cap ++ " : Supported } msg"
    , w.ctor ++ " " ++ richPayloadParamName w.payload ++ " ="
    , "    Action (" ++ w.variant ++ " " ++ richPayloadParamName w.payload ++ ")"
    ]


{-| A rich wrapper's `wrapContent` case branch.
-}
richWrapBranch : ( M.RichActionWrapper, String ) -> List String
richWrapBranch ( w, tag ) =
    let
        paramName =
            richPayloadParamName w.payload
    in
    case w.payload of
        M.SingleArgPayload p ->
            [ "        " ++ w.variant ++ " " ++ paramName ++ " ->"
            , "            Ir.node \"" ++ tag ++ "\" [ Ir.attribute \"" ++ p.attr ++ "\" " ++ paramName ++ " ] [ label ]"
            , ""
            ]

        M.RecordPayload r ->
            [ "        " ++ w.variant ++ " " ++ paramName ++ " ->"
            , "            Ir.node \"" ++ tag ++ "\""
            , "                (Ir.attribute \"" ++ r.required.attr ++ "\" " ++ paramName ++ "." ++ r.required.field
            ]
                ++ (case r.optional of
                        [] ->
                            [ "                )" ]

                        first :: rest ->
                            [ "                    :: List.filterMap identity"
                            , "                        [ " ++ optionalFieldLine paramName first
                            ]
                                ++ List.map (\o -> "                        , " ++ optionalFieldLine paramName o) rest
                                ++ [ "                        ]"
                                   , "                )"
                                   ]
                   )
                ++ [ "                [ label ]"
                   , ""
                   ]


actionModule : Brand -> List Elm.File
actionModule brand =
    case brand.actions of
        Nothing ->
            []

        Just roster ->
            let
                lib =
                    brand.lib

                tagOf compName =
                    brand.comps
                        |> List.filter (\c -> c.name == compName)
                        |> List.head
                        |> Maybe.map .tag

                -- roster entries whose wrapper component exists in the manifest
                forW =
                    roster.forWrappers
                        |> List.filterMap (\w -> tagOf w.comp |> Maybe.map (\tag -> ( w, tag )))

                nullW =
                    roster.nullaryWrappers
                        |> List.filterMap (\w -> tagOf w.comp |> Maybe.map (\tag -> ( w, tag )))

                richW =
                    roster.richWrappers
                        |> List.filterMap (\w -> tagOf w.comp |> Maybe.map (\tag -> ( w, tag )))

                payloadVariants =
                    [ "None", "OnClick msg", "Link LinkSpec", "Remove msg" ]
                        ++ (forW |> List.map (\( w, _ ) -> w.variant ++ " String"))
                        ++ (nullW |> List.map (\( w, _ ) -> w.variant))
                        ++ (richW |> List.map (\( w, _ ) -> w.variant ++ " " ++ richPayloadTypeName w.payload))

                producers =
                    (forW
                        |> List.concatMap
                            (\( w, _ ) ->
                                [ ""
                                , ""
                                , doc w.doc
                                , w.ctor ++ " : String -> Action { c | " ++ w.cap ++ " : Supported } msg"
                                , w.ctor ++ " for_ ="
                                , "    Action (" ++ w.variant ++ " for_)"
                                ]
                            )
                    )
                        ++ (nullW
                                |> List.concatMap
                                    (\( w, _ ) ->
                                        [ ""
                                        , ""
                                        , doc w.doc
                                        , w.ctor ++ " : Action { c | " ++ w.cap ++ " : Supported } msg"
                                        , w.ctor ++ " ="
                                        , "    Action " ++ w.variant
                                        ]
                                    )
                           )
                        ++ (richW |> List.concatMap (\( w, _ ) -> richProducerLines w))

                wrapBranch ( w, tag ) =
                    [ "        " ++ w.variant ++ " for_ ->"
                    , "            Ir.node \"" ++ tag ++ "\" [ Ir.attribute \"for\" for_ ] [ label ]"
                    , ""
                    ]

                nullBranch ( w, tag ) =
                    [ "        " ++ w.variant ++ " ->"
                    , "            Ir.node \"" ++ tag ++ "\" [] [ label ]"
                    , ""
                    ]

                exposeGroups =
                    [ [ "Action", "LinkSpec" ]
                        ++ (richW
                                |> List.filterMap
                                    (\( w, _ ) ->
                                        case w.payload of
                                            M.RecordPayload r ->
                                                Just r.typeName

                                            M.SingleArgPayload _ ->
                                                Nothing
                                    )
                           )
                    , [ "link", "linkWith", "none", "onClick", "remove" ]
                    , ((forW ++ nullW) |> List.map (\( w, _ ) -> w.ctor))
                        ++ (richW |> List.map (\( w, _ ) -> w.ctor))
                        |> List.sort
                    , [ "toAttrs", "wrapContent" ]
                    ]
            in
            [ file [ lib, "Action" ]
                (String.join "\n"
                    (List.concat
                        [ [ "module " ++ lib ++ ".Action exposing"
                          , exposeBlock exposeGroups
                          , ""
                          , "{-| Behavioural actions: exactly one of the supported behaviours, consumed"
                          , "by a component's `component`/`build` required record. Attribute behaviours"
                          , "(`onClick`/`link`/`remove`) become host attributes; wrapper behaviours nest"
                          , "the content in their trigger element."
                          , ""
                          , docsBlock exposeGroups
                          , ""
                          , "-}"
                          , ""
                          , "import HtmlIr.Attribute exposing (Attr)"
                          , "import HtmlIr.Internal as Ir"
                          , "import HtmlIr.Kind exposing (Supported)"
                          , "import HtmlIr.Node exposing (Node)"
                          , "import Json.Decode"
                          , ""
                          , ""
                          , doc "An opaque behavioural value: exactly one of the supported behaviours."
                          , "type Action capability msg"
                          , "    = Action (Payload msg)"
                          , ""
                          , ""
                          , "type Payload msg"
                          , "    = " ++ String.join "\n    | " payloadVariants
                          , ""
                          , ""
                          , doc "The parts of a link action."
                          , "type alias LinkSpec ="
                          , "    { href : String, target : Maybe String, rel : Maybe String, download : Maybe String }"
                          ]
                        , richW |> List.concatMap (\( w, _ ) -> richTypeAliasLines w)
                        , [ ""
                          , ""
                          , doc "No behaviour."
                          , "none : Action capability msg"
                          , "none ="
                          , "    Action None"
                          , ""
                          , ""
                          , doc "A click action: emit `msg` on activation."
                          , "onClick : msg -> Action { c | click : Supported } msg"
                          , "onClick m ="
                          , "    Action (OnClick m)"
                          , ""
                          , ""
                          , doc "A link action pointing at `url`."
                          , "link : String -> Action { c | link : Supported } msg"
                          , "link url ="
                          , "    Action (Link { href = url, target = Nothing, rel = Nothing, download = Nothing })"
                          , ""
                          , ""
                          , doc "A link action from a full `LinkSpec`."
                          , "linkWith : LinkSpec -> Action { c | link : Supported } msg"
                          , "linkWith spec ="
                          , "    Action (Link spec)"
                          , ""
                          , ""
                          , doc "A remove action: emit `msg` when the element requests removal."
                          , "remove : msg -> Action { c | remove : Supported } msg"
                          , "remove m ="
                          , "    Action (Remove m)"
                          ]
                        , producers
                        , [ ""
                          , ""
                          , doc "The host-attribute wiring: attribute behaviours produce attrs; wrappers none."
                          , "toAttrs : Action capability msg -> List (Attr c msg)"
                          , "toAttrs (Action payload) ="
                          , "    case payload of"
                          , "        OnClick m ->"
                          , "            [ Ir.on \"click\" (Json.Decode.succeed m) ]"
                          , ""
                          , "        Remove m ->"
                          , "            [ Ir.on \"remove\" (Json.Decode.succeed m) ]"
                          , ""
                          , "        Link spec ->"
                          , "            Ir.attribute \"href\" spec.href"
                          , "                :: List.filterMap identity"
                          , "                    [ Maybe.map (Ir.attribute \"target\") spec.target"
                          , "                    , Maybe.map (Ir.attribute \"rel\") spec.rel"
                          , "                    , Maybe.map (Ir.attribute \"download\") spec.download"
                          , "                    ]"
                          , ""
                          , "        _ ->"
                          , "            []"
                          , ""
                          , ""
                          , doc "The content wiring: wrapper behaviours nest the label in their trigger element."
                          , "wrapContent : Action capability msg -> Node msg -> Node msg"
                          , "wrapContent (Action payload) label ="
                          , "    case payload of"
                          ]
                        , List.concatMap wrapBranch forW
                        , List.concatMap nullBranch nullW
                        , List.concatMap richWrapBranch richW
                        , [ "        _ ->"
                          , "            label"
                          , ""
                          ]
                        ]
                    )
                )
            ]



