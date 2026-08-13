module M3e.Component.InputChipSet exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy
    , disabled, name, required, validationmessages, vertical, onChange
    , input, child
    )

{-| The `m3e-input-chip-set` component — strict per-component surface.

A container that transforms user input into a cohesive set of interactive chips, supporting entry, editing, and removal of discrete values.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy
@docs disabled, name, required, validationmessages, vertical, onChange
@docs input, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Json.Encode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.InputChipSet
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-input-chip-set` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.InputChipSet.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.InputChipSet.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.InputChipSet.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.InputChipSet.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.inputChipSet


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| The name that identifies the element when submitting the associated form.
-}
name : String -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" value_


{-| See `M3e.Attributes.required`.
-}
required : Bool -> Attr { c | required : Supported } msg
required =
    A.required


{-| See `M3e.Attributes.validationmessages`.
-}
validationmessages : String -> Attr { c | validationmessages : Supported } msg
validationmessages =
    A.validationmessages


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


{-| Place an element into the named `input` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
input : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
input element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "input") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
