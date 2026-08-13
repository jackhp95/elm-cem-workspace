module M3e.Unsafe.Attributes exposing (customAttribute, fromHtmlAttribute, recastAttr, recastAttrAll)

{-| The attribute-side twins of [`M3e.Unsafe`](M3e-Unsafe): lift a raw
`Html.Attribute`, re-kind an existing `Attr`, or set an attribute this library
has no typed setter for — all with a FREE capability row, so the compiler checks
nothing about which element the attribute may land on. For incremental migration
and slot-fit only; every use site is a grep target and a lint finding.

@docs fromHtmlAttribute
@docs recastAttr, recastAttrAll
@docs customAttribute

-}

import Html
import Html.Attributes
import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir


{-| Lift a raw `Html.Attribute` into an `Attr` with a FREE capability row. Loud on purpose.
-}
fromHtmlAttribute : Html.Attribute msg -> Attr capability msg
fromHtmlAttribute =
    Ir.fromHtmlAttribute


{-| Re-kind an `Attr` to a FREE capability row so it fits any element — the attribute-side recast. Loud on purpose.
-}
recastAttr : Attr aCapability msg -> Attr bCapability msg
recastAttr attr =
    Ir.recast attr


{-| `recastAttr` mapped over a list of attributes.
-}
recastAttrAll : List (Attr aCapability msg) -> List (Attr bCapability msg)
recastAttrAll =
    List.map recastAttr


{-| Set an attribute by raw name, with a FREE capability row — the twin of `M3e.Unsafe.customElement`, for the custom-element attributes this library has no typed setter for (`active-index`, `camera-controls`). Loud on purpose: for an attribute the library DOES model, use its typed setter, which checks the element admits it.
-}
customAttribute : String -> String -> Attr capability msg
customAttribute name value =
    Ir.fromHtmlAttribute (Html.Attributes.attribute name value)
