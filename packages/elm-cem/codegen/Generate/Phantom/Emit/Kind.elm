module Generate.Phantom.Emit.Kind exposing (..)


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


-- KIND MODULE


kindModule : Brand -> Elm.File
kindModule brand =
    let
        roleMarker =
            case brand.aria of
                Just _ ->
                    [ ""
                    , ""
                    , doc "The private ARIA-role marker (never constructed)."
                    , "type Role"
                    , "    = Role_"
                    ]

                Nothing ->
                    []

        markerNames =
            [ "Brand", "Ctx" ]
                ++ (case brand.aria of
                        Just _ ->
                            [ "Role" ]

                        Nothing ->
                            []
                   )

        setDecl s =
            [ ""
            , ""
            , doc ("The `" ++ s.name ++ "` kind set.")
            , "type alias " ++ s.pascal ++ " ="
            , "    " ++ kindRow s.fields
            ]
    in
    file [ brand.lib, "Kind" ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ brand.lib ++ ".Kind exposing"
                  , exposeBlock
                        [ markerNames
                        , [ "Available", "Used" ]
                        , [ "Supported", "Shared" ]
                        , brand.sets |> List.map .pascal
                        ]
                  , ""
                  , "{-| The library's private phantom markers and named kind/context sets."
                  , ""
                  , "`Brand` marks this library's kind-row fields; `Ctx` marks its context-row"
                  , "fields. Both are nominal and private to this library — a foreign library's"
                  , "markers never unify with them, even under the same field name."
                  , "`Available`/`Used` are the pipe-builder's write-once capability markers."
                  , ""
                  , "`Supported` and `Shared` are the CROSS-library markers, re-exported from"
                  , "the IR substrate so callers never import `HtmlIr.Kind` directly. Unlike"
                  , "`Brand`/`Ctx` these are deliberately shared: every brand's `Supported` is"
                  , "the same type, and a `Shared`-marked atom is admissible into any brand's"
                  , "opted-in slot."
                  , ""
                  , docsBlock
                        [ markerNames
                        , [ "Available", "Used" ]
                        , [ "Supported", "Shared" ]
                        , brand.sets |> List.map .pascal
                        ]
                  , ""
                  , "-}"
                  , ""
                  , "import HtmlIr.Kind"
                  , ""
                  , ""
                  , doc "Admission marker for capability and value rows. Re-exported from `HtmlIr.Kind`."
                  , "type alias Supported ="
                  , "    HtmlIr.Kind.Supported"
                  , ""
                  , ""
                  , doc "The cross-library atom marker. Re-exported from `HtmlIr.Kind`."
                  , "type alias Shared ="
                  , "    HtmlIr.Kind.Shared"
                  , ""
                  , ""
                  , doc "The private kind marker (never constructed)."
                  , "type Brand"
                  , "    = Brand_"
                  , ""
                  , ""
                  , doc "The private context marker (never constructed)."
                  , "type Ctx"
                  , "    = Ctx_"
                  ]
                , roleMarker
                , [ ""
                  , ""
                  , doc "Pipe-builder capability: still writable."
                  , "type Available"
                  , "    = Available_"
                  , ""
                  , ""
                  , doc "Pipe-builder capability: consumed."
                  , "type Used"
                  , "    = Used_"
                  ]
                , brand.sets |> List.concatMap setDecl
                , [ "" ]
                ]
            )
        )



