module Generate.Phantom.Emit.Unsafe exposing (..)


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


-- UNSAFE MODULE (the ONE loud legacy-Html escape, when `_legacyHtml` is set)


unsafeModule : Brand -> List Elm.File
unsafeModule brand =
    if not brand.legacyHtml then
        []

    else
        [ file [ brand.lib, "Unsafe" ]
            (String.join "\n"
                [ "module " ++ brand.lib ++ ".Unsafe exposing (customElement, fromHtml, fromNode, recast, recastAll)"
                , ""
                , "{-| THE loud legacy-interop escapes: wrap raw `Html` as an `Element`,"
                , "re-assert rows on an erased `Node`, re-kind an existing `Element`, or forge"
                , "an element from a tag name this library has no generated producer for — all"
                , "with FREE phantom rows, so the compiler checks nothing about the result. For"
                , "incremental migration and slot-fit only; every use site is a grep target and"
                , "a lint finding."
                , ""
                , "@docs fromHtml"
                , "@docs fromNode"
                , "@docs recast, recastAll"
                , "@docs customElement"
                , ""
                , "-}"
                , ""
                , "import Html exposing (Html)"
                , "import HtmlIr.Attribute exposing (Attr)"
                , "import HtmlIr.Element exposing (Element)"
                , "import HtmlIr.Internal as Ir"
                , "import HtmlIr.Node exposing (Node)"
                , ""
                , ""
                , doc "Wrap raw `Html` with FREE rows. Loud on purpose."
                , "fromHtml : Html msg -> Element accepts admittedBy msg"
                , "fromHtml h ="
                , "    Ir.fromNode (Ir.fromHtml h)"
                , ""
                , ""
                , doc "Re-assert FREE rows on an erased [`Node`](HtmlIr-Node#Node) — the exact dual of the safe `HtmlIr.Element.toNode`. For the boundary where a typed tree was flattened to the IR and must be lifted back (a framework `View` record, a cache). Loud on purpose: the rows it re-asserts were never checked."
                , "fromNode : Node msg -> Element accepts admittedBy msg"
                , "fromNode ="
                , "    Ir.fromNode"
                , ""
                , ""
                , doc "Re-kind an `Element` to FREE rows so it fits any slot — the blessed form of the hand-forged `Ir.fromNode << HtmlIr.Element.toNode` recast. Loud on purpose."
                , "recast : Element aAccepts aAdmittedBy msg -> Element bAccepts bAdmittedBy msg"
                , "recast element ="
                , "    Ir.fromNode (HtmlIr.Element.toNode element)"
                , ""
                , ""
                , doc "`recast` mapped over a list of elements."
                , "recastAll : List (Element aAccepts aAdmittedBy msg) -> List (Element bAccepts bAdmittedBy msg)"
                , "recastAll ="
                , "    List.map recast"
                , ""
                , ""
                , doc "Forge an element from a raw tag name, with FREE rows — for a CUSTOM ELEMENT this library has no generated producer for (`<model-viewer>`, `<slide-panels>`). Loud on purpose: for a standard HTML tag reach for the native brand's typed constructor instead, and for a component this library already ships, use that."
                , "customElement : String -> List (Attr capability msg) -> List (Element childAccepts childAdmittedBy msg) -> Element accepts admittedBy msg"
                , "customElement tagName attrs children ="
                , "    Ir.fromNode (Ir.node tagName attrs (List.map HtmlIr.Element.toNode children))"
                , ""
                ]
            )
        , file [ brand.lib, "Unsafe", "Attributes" ]
            (String.join "\n"
                [ "module " ++ brand.lib ++ ".Unsafe.Attributes exposing (customAttribute, fromHtmlAttribute, recastAttr, recastAttrAll)"
                , ""
                , "{-| The attribute-side twins of [`" ++ brand.lib ++ ".Unsafe`](" ++ brand.lib ++ "-Unsafe): lift a raw"
                , "`Html.Attribute`, re-kind an existing `Attr`, or set an attribute this library"
                , "has no typed setter for — all with a FREE capability row, so the compiler checks"
                , "nothing about which element the attribute may land on. For incremental migration"
                , "and slot-fit only; every use site is a grep target and a lint finding."
                , ""
                , "@docs fromHtmlAttribute"
                , "@docs recastAttr, recastAttrAll"
                , "@docs customAttribute"
                , ""
                , "-}"
                , ""
                , "import Html"
                , "import Html.Attributes"
                , "import HtmlIr.Attribute exposing (Attr)"
                , "import HtmlIr.Internal as Ir"
                , ""
                , ""
                , doc "Lift a raw `Html.Attribute` into an `Attr` with a FREE capability row. Loud on purpose."
                , "fromHtmlAttribute : Html.Attribute msg -> Attr capability msg"
                , "fromHtmlAttribute ="
                , "    Ir.fromHtmlAttribute"
                , ""
                , ""
                , doc "Re-kind an `Attr` to a FREE capability row so it fits any element — the attribute-side recast. Loud on purpose."
                , "recastAttr : Attr aCapability msg -> Attr bCapability msg"
                , "recastAttr attr ="
                , "    Ir.recast attr"
                , ""
                , ""
                , doc "`recastAttr` mapped over a list of attributes."
                , "recastAttrAll : List (Attr aCapability msg) -> List (Attr bCapability msg)"
                , "recastAttrAll ="
                , "    List.map recastAttr"
                , ""
                , ""
                , doc ("Set an attribute by raw name, with a FREE capability row — the twin of `" ++ brand.lib ++ ".Unsafe.customElement`, for the custom-element attributes this library has no typed setter for (`active-index`, `camera-controls`). Loud on purpose: for an attribute the library DOES model, use its typed setter, which checks the element admits it.")
                , "customAttribute : String -> String -> Attr capability msg"
                , "customAttribute name value ="
                , "    Ir.fromHtmlAttribute (Html.Attributes.attribute name value)"
                , ""
                ]
            )
        ]



