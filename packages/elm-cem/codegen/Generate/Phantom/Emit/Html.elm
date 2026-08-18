module Generate.Phantom.Emit.Html exposing (..)


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
import Generate.Phantom.Emit.SubstrateReExports exposing (..)


-- HTML (LOOSE PRODUCER) MODULE
--
-- R2 inversion: the loose, elm/html-like producer layer. One open-rowed
-- constructor per rich element, each OWNING `Ir.node "<tag>"`. This is the
-- foundation the `<Lib>-html` split package exposes; every rich
-- `<Lib>.<Component>` imports its producer here and re-exposes it under a
-- tightened signature. Depends only on the IR substrate — imports NO component
-- module, so it compiles standalone. Native/home-shaped brands already own
-- their `Ir.node` in the home modules (which ARE the loose layer), so this
-- module is emitted only for the rich per-component (`own`) shape.


-- HTML MODULE


htmlModule : Brand -> List Elm.File
htmlModule brand =
    let
        lib =
            brand.lib

        own =
            brand.comps |> List.filter (\c -> homeOf c == Nothing)

        producer comp =
            [ ""
            , ""
            , doc
                ("The loose `"
                    ++ comp.tag
                    ++ "` producer — open attribute/child rows, elm/html call\nshape. `"
                    ++ lib
                    ++ "."
                    ++ comp.name
                    ++ "` tightens it (closed rows, slot admittance, narrowed values)."
                )
            , comp.resolvedCtor ++ " :"
            , "    List (Attr attrs msg)"
            , "    -> List (Element children childAdmittedBy msg)"
            , "    -> Element produced admittedBy msg"
            , comp.resolvedCtor ++ " attrs children ="
            , "    Ir.fromNode (Ir.node \"" ++ comp.tag ++ "\" attrs (List.map HtmlIr.Element.toNode children))"
            ]
    in
    if List.isEmpty own then
        []

    else
        [ file [ lib, "Html" ]
            (String.join "\n"
                (List.concat
                    [ [ "module " ++ lib ++ ".Html exposing"
                      , exposeBlock
                            [ own |> List.map .resolvedCtor
                            , substrateReExportNames
                            ]
                      , ""
                      , "{-| The loose, elm/html-like producer layer: one open-rowed constructor"
                      , "per element, each owning `Ir.node \"<tag>\"`. This is the foundation the"
                      , "`" ++ lib ++ "-html` package exposes; every rich `" ++ lib ++ ".<Component>` imports"
                      , "its producer here and re-exposes it under a tightened signature. Depends"
                      , "only on the IR substrate — no component module is imported."
                      , ""
                      , "The substrate types are re-exported here too, so a consumer of the"
                      , "published package can write type annotations without importing"
                      , "`HtmlIr.*` directly."
                      , ""
                      , docsBlock
                            [ own |> List.map .resolvedCtor
                            , substrateReExportNames
                            ]
                      , ""
                      , "-}"
                      , ""
                      ]
                    , (substrateReExportImports ++ [ "import HtmlIr.Internal as Ir" ]) |> List.sort
                    , own |> List.concatMap producer
                    , substrateReExportDecls
                    , [ "" ]
                    ]
                )
            )
        ]



