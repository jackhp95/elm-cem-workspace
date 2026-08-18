module Generate.Phantom.Emit.Events exposing (..)


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


-- EVENTS MODULE


eventsModule : Brand -> Elm.File
eventsModule brand =
    let
        setters =
            distinctSetterEvents brand
                |> List.concatMap
                    (\ev ->
                        let
                            n =
                                handlerName brand ev
                        in
                        case ev.payload of
                            Just payload ->
                                -- Annotated: bake the standard decoder into a
                                -- payload-typed `(payload -> msg)` setter, and keep
                                -- the `…With` custom-decoder form alongside it.
                                let
                                    ( elmTy, dec ) =
                                        payloadTypeAndDecoder payload
                                in
                                [ ""
                                , ""
                                , doc ("The `" ++ ev.name ++ "` event, decoding the standard `" ++ elmTy ++ "` payload.")
                                , n ++ " : (" ++ elmTy ++ " -> msg) -> Attr { c | " ++ n ++ " : Supported } msg"
                                , n ++ " tagger ="
                                , "    Ir.on \"" ++ ev.name ++ "\" (Json.Decode.map tagger (" ++ dec ++ "))"
                                , ""
                                , ""
                                , doc ("The `" ++ ev.name ++ "` event with a custom payload decoder.")
                                , n ++ "With : Json.Decode.Decoder msg -> Attr { c | " ++ n ++ " : Supported } msg"
                                , n ++ "With ="
                                , "    Ir.on \"" ++ ev.name ++ "\""
                                ]

                            Nothing ->
                                [ ""
                                , ""
                                , doc ("The `" ++ ev.name ++ "` event.")
                                , n ++ " : msg -> Attr { c | " ++ n ++ " : Supported } msg"
                                , n ++ " msg ="
                                , "    Ir.on \"" ++ ev.name ++ "\" (Json.Decode.succeed msg)"
                                , ""
                                , ""
                                , doc ("The `" ++ ev.name ++ "` event with a custom payload decoder.")
                                , n ++ "With : Json.Decode.Decoder msg -> Attr { c | " ++ n ++ " : Supported } msg"
                                , n ++ "With ="
                                , "    Ir.on \"" ++ ev.name ++ "\""
                                ]
                    )
    in
    file [ brand.lib, "Events" ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ brand.lib ++ ".Events exposing"
                  , exposeBlock
                        [ distinctSetterEvents brand |> List.concatMap (\e -> [ handlerName brand e, handlerName brand e ++ "With" ]) |> List.sort
                        , [ "delegate" ]
                        ]
                  , ""
                  , "{-| Events as capabilities: each setter is an open producer admitted only by"
                  , "elements whose closed `Attrs` row lists the event — `onClick` on a"
                  , "non-interactive element is a compile error."
                  , ""
                  , "`delegate` is the ONE loud escape for bubbling: it forgets an event's"
                  , "capability so it can be placed on a container and rely on DOM bubbling from an"
                  , "interactive descendant. Pair it with a real interactive child and a keyboard"
                  , "path (lint-checked)."
                  , ""
                  , docsBlock
                        [ distinctSetterEvents brand |> List.concatMap (\e -> [ handlerName brand e, handlerName brand e ++ "With" ]) |> List.sort
                        , [ "delegate" ]
                        ]
                  , ""
                  , "-}"
                  , ""
                  , "import HtmlIr.Attribute exposing (Attr)"
                  , "import HtmlIr.Internal as Ir"
                  , "import HtmlIr.Kind exposing (Supported)"
                  , "import Json.Decode"
                  ]
                , setters
                , [ ""
                  , ""
                  , doc "Forget an event's capability row (the bubbling escape)."
                  , "delegate : Attr capability msg -> Attr anyCapability msg"
                  , "delegate attr ="
                  , "    Ir.recast attr"
                  , ""
                  ]
                ]
            )
        )



