module M3e.Component.Dialog exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, CloseIconSlot, HeaderSlot, ChildAdmittedBy
    , alert, closeLabel, disableClose, dismissible, noFocusTrap, open, onOpening, onOpened, onClosing, onClosed, onCancel
    , actions, closeIcon, header, child
    )

{-| The `m3e-dialog` component — strict per-component surface.

A dialog that provides important prompts in a user flow.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, CloseIconSlot, HeaderSlot, ChildAdmittedBy
@docs alert, closeLabel, disableClose, dismissible, noFocusTrap, open, onOpening, onOpened, onClosing, onClosed, onCancel
@docs actions, closeIcon, header, child


## Examples


### Examples

<!-- elm-cem:example title="Anatomy" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.DialogTrigger.component [ M3e.Component.DialogTrigger.for "dlg" ] [ M3e.text "Open Dialog" ], action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.filled ] []
    , M3e.Component.Dialog.component [ M3e.Attributes.id "dlg", M3e.Component.Dialog.dismissible True ] [ M3e.Component.Dialog.header (M3e.text "Lorem ipsum dolor sit amet"), M3e.text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et\n  dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex\n  ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu\n  fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt\n  mollit anim id est laborum.", M3e.Component.Dialog.actions (TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "end" "" ] [ M3e.Component.Button.component { content = M3e.Component.DialogAction.component [ M3e.Component.DialogAction.returnValue "ok" ] [ M3e.text "Close" ], action = M3e.Action.none } [ TypedHtml.Unsafe.Attributes.customAttribute "autofocus" "" ] [] ]) ]
    ]
```

<!-- elm-cem:example title="Opening" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.DialogTrigger.component [ M3e.Component.DialogTrigger.for "dlg" ] [ M3e.text "Open Dialog" ], action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.filled ] []
    , M3e.Component.Dialog.component [ M3e.Attributes.id "dlg", M3e.Component.Dialog.dismissible True ] []
    ]
```

<!-- elm-cem:example title="Actions" -->
```elm
M3e.Component.Button.component { content = M3e.Component.DialogAction.component [ M3e.Component.DialogAction.returnValue "ok" ] [ M3e.text "Close" ], action = M3e.Action.none } [] []
```

<!-- elm-cem:docmeta category=Containment -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Dialog
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-dialog` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Dialog.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Dialog.Attrs


{-| The kinds the `close-icon` slot admits.
-}
type alias CloseIconSlot =
    M3e.Internal.Types.Dialog.CloseIconSlot


{-| The kinds the `header` slot admits.
-}
type alias HeaderSlot =
    M3e.Internal.Types.Dialog.HeaderSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Dialog.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Dialog.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Dialog.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.Dialog.SlotCaps


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.dialog


{-| See `M3e.Attributes.alert`.
-}
alert : Bool -> Attr { c | alert : Supported } msg
alert =
    A.alert


{-| See `M3e.Attributes.closeLabel`.
-}
closeLabel : String -> Attr { c | closeLabel : Supported } msg
closeLabel =
    A.closeLabel


{-| See `M3e.Attributes.disableClose`.
-}
disableClose : Bool -> Attr { c | disableClose : Supported } msg
disableClose =
    A.disableClose


{-| See `M3e.Attributes.dismissible`.
-}
dismissible : Bool -> Attr { c | dismissible : Supported } msg
dismissible =
    A.dismissible


{-| See `M3e.Attributes.noFocusTrap`.
-}
noFocusTrap : Bool -> Attr { c | noFocusTrap : Supported } msg
noFocusTrap =
    A.noFocusTrap


{-| See `M3e.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    A.open


{-| See `M3e.Events.onOpening`.
-}
onOpening : msg -> Attr { c | onOpening : Supported } msg
onOpening =
    Ev.onOpening


{-| See `M3e.Events.onOpened`.
-}
onOpened : msg -> Attr { c | onOpened : Supported } msg
onOpened =
    Ev.onOpened


{-| See `M3e.Events.onClosing`.
-}
onClosing : msg -> Attr { c | onClosing : Supported } msg
onClosing =
    Ev.onClosing


{-| See `M3e.Events.onClosed`.
-}
onClosed : msg -> Attr { c | onClosed : Supported } msg
onClosed =
    Ev.onClosed


{-| See `M3e.Events.onCancel`.
-}
onCancel : msg -> Attr { c | onCancel : Supported } msg
onCancel =
    Ev.onCancel


{-| Place an element into the named `actions` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
actions : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
actions element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "actions") (El.toNode element))


{-| Place an element into the named `close-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
closeIcon : Element CloseIconSlot admittedBy msg -> Element free freeAdmittedBy msg
closeIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "close-icon") (El.toNode element))


{-| Place an element into the named `header` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
header : Element HeaderSlot admittedBy msg -> Element free freeAdmittedBy msg
header element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "header") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
