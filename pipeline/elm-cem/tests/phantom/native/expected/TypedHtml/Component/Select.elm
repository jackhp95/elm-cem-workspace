module TypedHtml.Component.Select exposing
    ( optgroup, option, select
    , OptgroupIs, OptgroupAttrs, OptgroupContent, OptgroupChildAdmittedBy, OptgroupAdmittedBy, OptionIs, OptionAttrs, OptionContent, OptionChildAdmittedBy, OptionAdmittedBy, SelectIs, SelectAttrs, SelectContent, SelectChildAdmittedBy
    , disabled, size, value, defaultValue, valueAsNumber
    )

{-| The `Select` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs optgroup, option, select
@docs OptgroupIs, OptgroupAttrs, OptgroupContent, OptgroupChildAdmittedBy, OptgroupAdmittedBy, OptionIs, OptionAttrs, OptionContent, OptionChildAdmittedBy, OptionAdmittedBy, SelectIs, SelectAttrs, SelectContent, SelectChildAdmittedBy
@docs disabled, size, value, defaultValue, valueAsNumber

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Brand, Ctx)


{-| The kind row `optgroup` produces.
-}
type alias OptgroupIs s =
    { s | optgroup : Brand }


{-| `optgroup`'s closed attribute-capability row.
-}
type alias OptgroupAttrs =
    { autofocus : Supported
    , class : Supported
    , dir : Supported
    , hidden : Supported
    , id : Supported
    , role : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    }


{-| The kinds `optgroup` admits.
-}
type alias OptgroupContent =
    { option : Brand }


{-| The context demand `optgroup` injects into its children.
-}
type alias OptgroupChildAdmittedBy childAdm =
    { childAdm | optgroup : Ctx }


{-| The CLOSED parent contexts `optgroup` is valid inside.
-}
type alias OptgroupAdmittedBy =
    { optgroup : Ctx, select : Ctx }


{-| The `optgroup` element.
-}
optgroup :
    List (Attr OptgroupAttrs msg)
    -> List (Element OptgroupContent (OptgroupChildAdmittedBy childAdm) msg)
    -> Element (OptgroupIs s) OptgroupAdmittedBy msg
optgroup attrs children =
    Ir.fromNode (Ir.node "optgroup" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `option` produces.
-}
type alias OptionIs s =
    { s | option : Brand }


{-| `option`'s closed attribute-capability row.
-}
type alias OptionAttrs =
    { autofocus : Supported
    , class : Supported
    , dir : Supported
    , hidden : Supported
    , id : Supported
    , role : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    , value : Supported
    }


{-| The kinds `option` admits.
-}
type alias OptionContent =
    { sharedText : Shared }


{-| The context demand `option` injects into its children.
-}
type alias OptionChildAdmittedBy childAdm =
    { childAdm | option : Ctx }


{-| The CLOSED parent contexts `option` is valid inside.
-}
type alias OptionAdmittedBy =
    { optgroup : Ctx, select : Ctx }


{-| The `option` element.
-}
option :
    List (Attr OptionAttrs msg)
    -> List (Element OptionContent (OptionChildAdmittedBy childAdm) msg)
    -> Element (OptionIs s) OptionAdmittedBy msg
option attrs children =
    Ir.fromNode (Ir.node "option" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `select` produces.
-}
type alias SelectIs s =
    { s | select : Brand }


{-| `select`'s closed attribute-capability row.
-}
type alias SelectAttrs =
    { autofocus : Supported
    , class : Supported
    , dir : Supported
    , disabled : Supported
    , hidden : Supported
    , id : Supported
    , onChange : Supported
    , role : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    }


{-| The kinds `select` admits.
-}
type alias SelectContent =
    { optgroup : Brand
    , option : Brand
    }


{-| The context demand `select` injects into its children.
-}
type alias SelectChildAdmittedBy childAdm =
    { childAdm | select : Ctx }


{-| The `select` element.
-}
select :
    List (Attr SelectAttrs msg)
    -> List (Element SelectContent (SelectChildAdmittedBy childAdm) msg)
    -> Element (SelectIs s) admittedBy msg
select attrs children =
    Ir.fromNode (Ir.node "select" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedHtml.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    TypedHtml.Attributes.disabled


{-| See `TypedHtml.Attributes.size`.
-}
size : Int -> Attr { c | size : Supported } msg
size =
    TypedHtml.Attributes.size


{-| See `TypedHtml.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    TypedHtml.Attributes.value


{-| See `TypedHtml.Attributes.defaultValue`.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    TypedHtml.Attributes.defaultValue


{-| See `TypedHtml.Attributes.valueAsNumber`.
-}
valueAsNumber : Float -> Attr { c | value : Supported } msg
valueAsNumber =
    TypedHtml.Attributes.valueAsNumber
