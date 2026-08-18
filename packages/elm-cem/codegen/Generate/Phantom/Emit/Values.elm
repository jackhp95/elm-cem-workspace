module Generate.Phantom.Emit.Values exposing (..)


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


-- VALUES MODULE


valuesModule : Brand -> Elm.File
valuesModule brand =
    let
        -- Dedup tokens on their resolved Elm identifier (tokenIdentResolved), not the raw
        -- string. Two raw tokens that normalize to the same ident (e.g. "AUTO" and
        -- "auto" both → "auto") must collapse to one emission; without this the
        -- guard would correctly detect a duplicate-identifier collision. The first
        -- raw token (alphabetical order after List.sort) wins.
        tokens =
            brand.unions
                |> List.concatMap .tokens
                |> List.sort
                |> List.foldl
                    (\t acc ->
                        let
                            ident =
                                tokenIdentResolved brand t
                        in
                        if List.any (\existing -> tokenIdentResolved brand existing == ident) acc then
                            acc

                        else
                            acc ++ [ t ]
                    )
                    []

        tokenDecl t =
            let
                n =
                    tokenIdentResolved brand t

                v =
                    tokenValueOf brand t
            in
            [ ""
            , ""
            , doc
                ("The `"
                    ++ t
                    ++ "` token."
                    ++ (if v == t then
                            ""

                        else
                            -- The two differ only for a config `attrTypes` MAP override,
                            -- and then the emitted string is the whole reason the map form
                            -- was used. Saying so in the docs is what stops a reader
                            -- concluding `always` writes `always`.
                            " Writes `\"" ++ v ++ "\"`."
                       )
                )
            , n ++ " : Value { v | " ++ n ++ " : Supported }"
            , n ++ " ="
            , "    Ir.token \"" ++ v ++ "\""
            ]

        unionDecl e =
            [ ""
            , ""
            , doc
                ("The union row for `"
                    ++ e.elmName
                    ++ "`"
                    ++ (case e.provenance of
                            Just p ->
                                " (from `" ++ p ++ "`)"

                            Nothing ->
                                ""
                       )
                    ++ "."
                )
            , "type alias " ++ e.aliasName ++ " ="
            , "    " ++ supportedRow (e.tokens |> List.map (tokenIdentResolved brand))
            ]

        -- The union's tokens paired with the string they actually write, deduped
        -- on that WIRE STRING. Two distinct tokens in one union may render the
        -- same string (an `attrTypes` MAP override permits it: `tokenValues`
        -- guards token→one-string, not string→one-token). They evaluate to the
        -- SAME `Ir.token`, so keeping one is lossless — but keeping both would
        -- emit a duplicate `case` branch and a duplicate list entry. Sort first
        -- so the survivor is deterministic.
        unionTokens e =
            e.tokens
                |> List.sort
                |> List.foldl
                    (\t acc ->
                        let
                            wire =
                                tokenValueOf brand t
                        in
                        if List.any (\( _, w ) -> w == wire) acc then
                            acc

                        else
                            acc ++ [ ( tokenIdentResolved brand t, wire ) ]
                    )
                    []

        fromStringDecl e =
            [ ""
            , ""
            , doc
                ("Parse a `"
                    ++ e.elmName
                    ++ "` value from the string it writes to the DOM. The inverse of `toString`."
                )
            , e.elmName ++ "FromString : String -> Maybe (Value " ++ e.aliasName ++ ")"
            , e.elmName ++ "FromString s ="
            , "    case s of"
            ]
                ++ List.concatMap
                    (\( ident, wire ) ->
                        [ "        \"" ++ wire ++ "\" ->"
                        , "            Just " ++ ident
                        , ""
                        ]
                    )
                    (unionTokens e)
                ++ [ "        _ ->"
                   , "            Nothing"
                   ]

        valuesDecl e =
            [ ""
            , ""
            , doc
                ("Every `"
                    ++ e.elmName
                    ++ "` value. Map a UI over this and adding a value to the manifest cannot silently miss it."
                )
            , e.elmName ++ "Values : List (Value " ++ e.aliasName ++ ")"
            , e.elmName ++ "Values ="
            , "    [ " ++ (unionTokens e |> List.map Tuple.first |> String.join ", ") ++ " ]"
            ]

        -- R5: enum portmanteaus — attribute-prefixed value globals for IDE
        -- discovery (type `variant`, see `variantFilled`, `variantOutlined`, …).
        -- Deduped against the union aliases and bare tokens already claimed.
        portmanteaus =
            enumPortmanteaus brand
                ((brand.unions |> List.map .aliasName)
                    ++ (tokens |> List.map (tokenIdentResolved brand))
                    ++ (brand.unions |> List.map (\e -> e.elmName ++ "FromString"))
                    ++ (brand.unions |> List.map (\e -> e.elmName ++ "Values"))
                    ++ [ "toString" ]
                )

        portmanteauDecl p =
            [ ""
            , ""
            , doc
                ("The `"
                    ++ p.token
                    ++ "` value of the `"
                    ++ p.attr
                    ++ "` enum — same open row as `"
                    ++ p.ident
                    ++ "`, prefixed for discovery."
                )
            , p.name ++ " : Value { v | " ++ p.ident ++ " : Supported }"
            , p.name ++ " ="
            , "    Ir.token \"" ++ tokenValueOf brand p.token ++ "\""
            ]
    in
    file [ brand.lib, "Values" ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ brand.lib ++ ".Values exposing"
                  , exposeBlock
                        [ [ "Value" ]
                        , [ "toString" ]
                        , brand.unions |> List.map .aliasName |> List.sort
                        , (brand.unions |> List.map (\e -> e.elmName ++ "FromString"))
                            ++ (brand.unions |> List.map (\e -> e.elmName ++ "Values"))
                            |> List.sort
                        , tokens |> List.map (tokenIdentResolved brand)
                        , portmanteaus |> List.map .name
                        ]
                  , ""
                  , "{-| The enum-value vocabulary: every token minted once (open row), plus the"
                  , "library-wide union row per enum attribute, plus attribute-prefixed"
                  , "portmanteaus (`variantFilled`, `shapeRounded`, …) for IDE discovery."
                  , "General setters close over the union; per-component setters narrow — both"
                  , "are fed by these same tokens."
                  , ""
                  , "`Value` is re-exported here so annotating a token never requires an"
                  , "`HtmlIr.Value` import."
                  , ""
                  , docsBlock
                        [ [ "Value" ]
                        , [ "toString" ]
                        , brand.unions |> List.map .aliasName |> List.sort
                        , (brand.unions |> List.map (\e -> e.elmName ++ "FromString"))
                            ++ (brand.unions |> List.map (\e -> e.elmName ++ "Values"))
                            |> List.sort
                        , tokens |> List.map (tokenIdentResolved brand)
                        , portmanteaus |> List.map .name
                        ]
                  , ""
                  , "-}"
                  , ""
                  , "import HtmlIr.Internal as Ir"
                  , "import HtmlIr.Kind exposing (Supported)"
                  , "import HtmlIr.Value"
                  , ""
                  , ""
                  , doc "The phantom-tagged enum token. Re-exported so callers never import `HtmlIr.Value` directly."
                  , "type alias Value tags ="
                  , "    HtmlIr.Value.Value tags"
                  , ""
                  , ""
                  , doc "The token's underlying string — the safe out-bound direction. Re-exported so callers never import `HtmlIr.Value` directly."
                  , "toString : Value tags -> String"
                  , "toString ="
                  , "    HtmlIr.Value.toString"
                  ]
                , brand.unions |> List.sortBy .aliasName |> List.concatMap unionDecl
                , brand.unions |> List.sortBy .aliasName |> List.concatMap fromStringDecl
                , brand.unions |> List.sortBy .aliasName |> List.concatMap valuesDecl
                , tokens |> List.concatMap tokenDecl
                , portmanteaus |> List.concatMap portmanteauDecl
                , [ "" ]
                ]
            )
        )



