module Generate.Phantom.Emit.Aria exposing (..)


import Attr
import Cem
import Char
import Dict
import Docs
import Elm
import Generate.Phantom.Model as M exposing (Brand, Comp, EnumSpec, KindField, Marker(..), ResolvedSlot, SlotContent(..))
import Json.Encode as Encode
import Naming

import Generate.Phantom.Emit.AttrsRow exposing (..)
import Generate.Phantom.Emit.Shared exposing (..)


-- ARIA MODULE


ariaModule : Brand -> List Elm.File
ariaModule brand =
    case brand.aria of
        Nothing ->
            []

        Just aria ->
            let
                lib =
                    brand.lib

                roleTokens =
                    aria.roles
                        |> List.sort
                        |> List.concatMap
                            (\r ->
                                let
                                    n =
                                        roleName r
                                in
                                [ ""
                                , ""
                                , doc ("The `" ++ r ++ "` role token.")
                                , n ++ " : Value { r | " ++ n ++ " : Role }"
                                , n ++ " ="
                                , "    Ir.token \"" ++ r ++ "\""
                                ]
                            )

                roleTokenNames =
                    aria.roles |> List.map roleName

                -- The ROW FIELD stays the plain name (it must unify with the
                -- state alias rows); only the token FUNCTION is suffixed.
                stateFieldName v =
                    Naming.safeField (Naming.camel v)

                -- A state VALUE that collides with a role token name
                -- (`listbox`/`menu`/`dialog`… are both roles and
                -- aria-haspopup values) gets a `Value` suffix.
                stateTokenName v =
                    let
                        n =
                            Naming.safeField (Naming.camel v)
                    in
                    if List.member n roleTokenNames then
                        n ++ "Value"

                    else
                        n

                stateTokenNames =
                    aria.states
                        |> List.concatMap Tuple.second
                        |> List.sort
                        |> dedup

                stateTokens =
                    stateTokenNames
                        |> List.concatMap
                            (\v ->
                                let
                                    n =
                                        stateTokenName v
                                in
                                [ ""
                                , ""
                                , doc ("The `" ++ v ++ "` state token.")
                                , n ++ " : Value { v | " ++ stateFieldName v ++ " : Supported }"
                                , n ++ " ="
                                , "    Ir.token \"" ++ v ++ "\""
                                ]
                            )

                stateSetters =
                    aria.states
                        |> List.sortBy Tuple.first
                        |> List.concatMap
                            (\( name, values ) ->
                                let
                                    aliasName =
                                        Naming.pascal name
                                in
                                [ ""
                                , ""
                                , doc ("The values `aria-" ++ name ++ "` admits.")
                                , "type alias " ++ aliasName ++ " ="
                                , "    { "
                                    ++ (values |> List.sort |> List.map (\v -> Naming.safeField (Naming.camel v) ++ " : Supported") |> String.join "\n    , ")
                                    ++ "\n    }"
                                , ""
                                , ""
                                , doc ("Value-typed `aria-" ++ name ++ "` (universal: any element admits it).")
                                , Naming.camel name ++ " : Value " ++ aliasName ++ " -> Attr c msg"
                                , Naming.camel name ++ " value_ ="
                                , "    Ir.attribute \"aria-" ++ name ++ "\" (HtmlIr.Value.toString value_)"
                                ]
                            )

                universalSetters =
                    aria.universal
                        |> List.sort
                        |> List.concatMap
                            (\name ->
                                [ ""
                                , ""
                                , doc ("The open `aria-" ++ name ++ "` attribute (universal).")
                                , Naming.camel name ++ " : String -> Attr c msg"
                                , Naming.camel name ++ " ="
                                , "    Ir.attribute \"aria-" ++ name ++ "\""
                                ]
                            )

                exposeGroups =
                    [ [ "role", "roleString" ]
                    , aria.roles |> List.map roleName |> List.sort
                    , (aria.states |> List.map (Tuple.first >> Naming.pascal))
                        ++ (aria.states |> List.map (Tuple.first >> Naming.camel))
                        |> List.sort
                    , stateTokenNames |> List.map stateTokenName
                    , aria.universal |> List.map Naming.camel |> List.sort
                    ]
            in
            [ file [ lib, "Aria" ]
                (String.join "\n"
                    (List.concat
                        [ [ "module " ++ lib ++ ".Aria exposing"
                          , exposeBlock exposeGroups
                          , ""
                          , "{-| The ARIA concern axis — the HYBRID design: `role` is TYPE-GATED per"
                          , "element where it earns its keep (an element's `<El>Roles` alias closes the"
                          , "legal set; a wrong role is a compile error), enumerated aria-* states are"
                          , "value-typed, and the universal aria-* attributes stay open. The role×state"
                          , "dependency is lint territory."
                          , ""
                          , docsBlock exposeGroups
                          , ""
                          , "-}"
                          , ""
                          , "import HtmlIr.Attribute exposing (Attr)"
                          , "import HtmlIr.Internal as Ir"
                          , "import HtmlIr.Kind exposing (Supported)"
                          , "import HtmlIr.Value exposing (Value)"
                          , "import " ++ lib ++ ".Kind exposing (Role)"
                          , ""
                          , ""
                          , doc "Set a TYPED role: the token's row must fit the element's closed role set."
                          , "role : Value tags -> Attr { c | role : tags } msg"
                          , "role value_ ="
                          , "    Ir.attribute \"role\" (HtmlIr.Value.toString value_)"
                          , ""
                          , ""
                          , doc "Set a raw role string on a role-UNGATED element (its row has `role : Supported`)."
                          , "roleString : String -> Attr { c | role : Supported } msg"
                          , "roleString ="
                          , "    Ir.attribute \"role\""
                          ]
                        , roleTokens
                        , stateSetters
                        , stateTokens
                        , universalSetters
                        , [ "" ]
                        ]
                    )
                )
            ]







