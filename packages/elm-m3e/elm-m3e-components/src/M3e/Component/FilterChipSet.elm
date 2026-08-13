module M3e.Component.FilterChipSet exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy
    , disabled, hideSelectionIndicator, multi, name, vertical, onChange, onBeforeinput, onInput
    , child
    )

{-| The `m3e-filter-chip-set` component — strict per-component surface.

A container that organizes filter chips into a cohesive group, enabling selection and
deselection of values used to refine content or trigger contextual behavior.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy
@docs disabled, hideSelectionIndicator, multi, name, vertical, onChange, onBeforeinput, onInput
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Json.Encode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.FilterChipSet
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-filter-chip-set` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.FilterChipSet.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.FilterChipSet.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.FilterChipSet.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.FilterChipSet.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.filterChipSet


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.hideSelectionIndicator`.
-}
hideSelectionIndicator : Bool -> Attr { c | hideSelectionIndicator : Supported } msg
hideSelectionIndicator =
    A.hideSelectionIndicator


{-| See `M3e.Attributes.multi`.
-}
multi : Bool -> Attr { c | multi : Supported } msg
multi =
    A.multi


{-| The name that identifies the element when submitting the associated form.
-}
name : String -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" value_


{-| See `M3e.Attributes.vertical`.
-}
vertical : Bool -> Attr { c | vertical : Supported } msg
vertical =
    A.vertical


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `M3e.Events.onBeforeinput`.
-}
onBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
onBeforeinput =
    Ev.onBeforeinput


{-| See `M3e.Events.onInput`.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput =
    Ev.onInput


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
