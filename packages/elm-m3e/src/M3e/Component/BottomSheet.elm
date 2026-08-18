module M3e.Component.BottomSheet exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , detent, detents, handle, handleLabel, hideFriction, hideable, modal, open, overshootLimit, onOpening, onClosing, onCancel, onOpened, onClosed
    , header, child
    )

{-| The `m3e-bottom-sheet` component — strict per-component surface.

A sheet used to show secondary content anchored to the bottom of the screen.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs detent, detents, handle, handleLabel, hideFriction, hideable, modal, open, overshootLimit, onOpening, onClosing, onCancel, onOpened, onClosed
@docs header, child


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.BottomSheetTrigger.component [ M3e.Component.BottomSheetTrigger.for "bottomSheet" ] [ M3e.text "Open bottom sheet" ], action = M3e.Action.none } [] []
    , M3e.Component.BottomSheet.component [ M3e.Attributes.id "bottomSheet" ] [ M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Keep" ], M3e.Component.ListAction.supportingText (M3e.text "Add to a note") ], M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Docs" ], M3e.Component.ListAction.supportingText (M3e.text "Embed in a document") ] ] ]
    ]
```

<!-- elm-cem:example title="Variants" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.BottomSheetTrigger.component [ M3e.Component.BottomSheetTrigger.for "bottomSheet2" ] [ M3e.text "Open modal bottom sheet" ], action = M3e.Action.none } [] []
    , M3e.Component.BottomSheet.component [ M3e.Attributes.id "bottomSheet2", M3e.Component.BottomSheet.modal True ] [ M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Keep" ], M3e.Component.ListAction.supportingText (M3e.text "Add to a note") ], M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Docs" ], M3e.Component.ListAction.supportingText (M3e.text "Embed in a document") ] ] ]
    ]
```

<!-- elm-cem:example title="Drag handles" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.BottomSheetTrigger.component [ M3e.Component.BottomSheetTrigger.for "bottomSheet3" ] [ M3e.text "Open draggable modal bottom sheet" ], action = M3e.Action.none } [] []
    , M3e.Component.BottomSheet.component [ M3e.Attributes.id "bottomSheet3", M3e.Component.BottomSheet.modal True, M3e.Component.BottomSheet.handle True ] [ M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Keep" ], M3e.Component.ListAction.supportingText (M3e.text "Add to a note") ], M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Docs" ], M3e.Component.ListAction.supportingText (M3e.text "Embed in a document") ] ] ]
    ]
```

<!-- elm-cem:example title="Detents" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.BottomSheetTrigger.component [ M3e.Component.BottomSheetTrigger.for "bottomSheet4" ] [ M3e.text "Open draggable modal bottom sheet with detents" ], action = M3e.Action.none } [] []
    , M3e.Component.BottomSheet.component [ M3e.Attributes.id "bottomSheet4", M3e.Component.BottomSheet.modal True, M3e.Component.BottomSheet.handle True, M3e.Component.BottomSheet.detents "fit half full" ] [ M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Keep" ], M3e.Component.ListAction.supportingText (M3e.text "Add to a note") ], M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Docs" ], M3e.Component.ListAction.supportingText (M3e.text "Embed in a document") ] ] ]
    ]
```

<!-- elm-cem:example title="Initial height" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.BottomSheetTrigger.component [ M3e.Component.BottomSheetTrigger.for "bottomSheet7" ] [ M3e.text "Open draggable modal bottom sheet with detents at half" ], action = M3e.Action.none } [] []
    , M3e.Component.BottomSheet.component [ M3e.Attributes.id "bottomSheet7", M3e.Component.BottomSheet.modal True, M3e.Component.BottomSheet.handle True, M3e.Component.BottomSheet.detents "fit half full", M3e.Component.BottomSheet.detent 1 ] [ M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Keep" ], M3e.Component.ListAction.supportingText (M3e.text "Add to a note") ], M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Docs" ], M3e.Component.ListAction.supportingText (M3e.text "Embed in a document") ] ] ]
    ]
```

<!-- elm-cem:example title="Initial height (2)" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.BottomSheetTrigger.component [ M3e.Component.BottomSheetTrigger.for "bottomSheet8", M3e.Component.BottomSheetTrigger.detent 1 ] [ M3e.text "Open draggable modal bottom sheet with detents at half via trigger" ], action = M3e.Action.none } [] []
    , M3e.Component.BottomSheet.component [ M3e.Attributes.id "bottomSheet8", M3e.Component.BottomSheet.modal True, M3e.Component.BottomSheet.handle True, M3e.Component.BottomSheet.detents "fit half full" ] [ M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Keep" ], M3e.Component.ListAction.supportingText (M3e.text "Add to a note") ], M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Docs" ], M3e.Component.ListAction.supportingText (M3e.text "Embed in a document") ] ] ]
    ]
```

<!-- elm-cem:example title="Collapsed height" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.BottomSheetTrigger.component [ M3e.Component.BottomSheetTrigger.for "bottomSheet9" ] [ M3e.text "Open draggable modal bottom sheet with detents at collapsed with custom peek" ], action = M3e.Action.none } [] []
    , M3e.Component.BottomSheet.component [ M3e.Attributes.id "bottomSheet9", M3e.Component.BottomSheet.modal True, M3e.Component.BottomSheet.handle True, M3e.Component.BottomSheet.detents "collapsed fit half full", TypedHtml.Unsafe.Attributes.customAttribute "style" "--m3e-bottom-sheet-peek-height: 36px" ] [ M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Keep" ], M3e.Component.ListAction.supportingText (M3e.text "Add to a note") ], M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Docs" ], M3e.Component.ListAction.supportingText (M3e.text "Embed in a document") ] ] ]
    ]
```

<!-- elm-cem:example title="Hideability" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.BottomSheetTrigger.component [ M3e.Component.BottomSheetTrigger.for "bottomSheet5" ] [ M3e.text "Open hideable modal bottom sheet" ], action = M3e.Action.none } [] []
    , M3e.Component.BottomSheet.component [ M3e.Attributes.id "bottomSheet5", M3e.Component.BottomSheet.modal True, M3e.Component.BottomSheet.handle True, M3e.Component.BottomSheet.hideable True ] [ M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Keep" ], M3e.Component.ListAction.supportingText (M3e.text "Add to a note") ], M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Docs" ], M3e.Component.ListAction.supportingText (M3e.text "Embed in a document") ] ] ]
    ]
```

<!-- elm-cem:example title="Hideability (2)" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.BottomSheetTrigger.component [ M3e.Component.BottomSheetTrigger.for "bottomSheet6" ] [ M3e.text "Open hideable modal bottom sheet with detents" ], action = M3e.Action.none } [] []
    , M3e.Component.BottomSheet.component [ M3e.Attributes.id "bottomSheet6", M3e.Component.BottomSheet.modal True, M3e.Component.BottomSheet.handle True, M3e.Component.BottomSheet.hideable True, M3e.Component.BottomSheet.detents "fit half full" ] [ M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Keep" ], M3e.Component.ListAction.supportingText (M3e.text "Add to a note") ], M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Docs" ], M3e.Component.ListAction.supportingText (M3e.text "Embed in a document") ] ] ]
    ]
```

<!-- elm-cem:example title="Headers" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.BottomSheetTrigger.component [ M3e.Component.BottomSheetTrigger.for "bottomSheet10" ] [ M3e.text "Open hideable modal bottom sheet with detents and header" ], action = M3e.Action.none } [] []
    , M3e.Component.BottomSheet.component [ M3e.Attributes.id "bottomSheet10", M3e.Component.BottomSheet.modal True, M3e.Component.BottomSheet.handle True, M3e.Component.BottomSheet.hideable True, M3e.Component.BottomSheet.detents "collapsed fit half full", TypedHtml.Aria.labelledby "sheetTitle" ] [ M3e.Component.BottomSheet.header (M3e.Component.Heading.component { content = M3e.text "Choose a destination" } [ M3e.Attributes.id "sheetTitle", M3e.Component.Heading.variant M3e.Values.title, M3e.Component.Heading.size M3e.Values.large ] []), M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Keep" ], M3e.Component.ListAction.supportingText (M3e.text "Add to a note") ], M3e.Component.ListAction.component [] [ M3e.Component.BottomSheetAction.component [] [ M3e.text "Google Docs" ], M3e.Component.ListAction.supportingText (M3e.text "Embed in a document") ] ] ]
    ]
```

<!-- elm-cem:example title="Choose a destination" -->
```elm
M3e.Component.BottomSheet.component [ M3e.Attributes.id "bottomSheet", M3e.Component.BottomSheet.modal True, M3e.Component.BottomSheet.handle True, M3e.Component.BottomSheet.hideable True, M3e.Component.BottomSheet.detents "collapsed fit half full" ] [ M3e.Component.BottomSheet.header (M3e.Component.Heading.component { content = M3e.text "Choose a destination" } [ M3e.Attributes.id "sheetTitle", M3e.Component.Heading.variant M3e.Values.title, M3e.Component.Heading.size M3e.Values.large ] []) ]
```

<!-- elm-cem:docmeta category=Containment -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.BottomSheet
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-bottom-sheet` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.BottomSheet.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.BottomSheet.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.BottomSheet.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.BottomSheet.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.BottomSheet.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.BottomSheet.SlotCaps


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
    H.bottomSheet


{-| See `M3e.Attributes.detent`.
-}
detent : Float -> Attr { c | detent : Supported } msg
detent =
    A.detent


{-| See `M3e.Attributes.detents`.
-}
detents : String -> Attr { c | detents : Supported } msg
detents =
    A.detents


{-| See `M3e.Attributes.handle`.
-}
handle : Bool -> Attr { c | handle : Supported } msg
handle =
    A.handle


{-| See `M3e.Attributes.handleLabel`.
-}
handleLabel : String -> Attr { c | handleLabel : Supported } msg
handleLabel =
    A.handleLabel


{-| See `M3e.Attributes.hideFriction`.
-}
hideFriction : Float -> Attr { c | hideFriction : Supported } msg
hideFriction =
    A.hideFriction


{-| See `M3e.Attributes.hideable`.
-}
hideable : Bool -> Attr { c | hideable : Supported } msg
hideable =
    A.hideable


{-| See `M3e.Attributes.modal`.
-}
modal : Bool -> Attr { c | modal : Supported } msg
modal =
    A.modal


{-| See `M3e.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    A.open


{-| See `M3e.Attributes.overshootLimit`.
-}
overshootLimit : Float -> Attr { c | overshootLimit : Supported } msg
overshootLimit =
    A.overshootLimit


{-| See `M3e.Events.onOpening`.
-}
onOpening : msg -> Attr { c | onOpening : Supported } msg
onOpening =
    Ev.onOpening


{-| See `M3e.Events.onClosing`.
-}
onClosing : msg -> Attr { c | onClosing : Supported } msg
onClosing =
    Ev.onClosing


{-| See `M3e.Events.onCancel`.
-}
onCancel : msg -> Attr { c | onCancel : Supported } msg
onCancel =
    Ev.onCancel


{-| See `M3e.Events.onOpened`.
-}
onOpened : msg -> Attr { c | onOpened : Supported } msg
onOpened =
    Ev.onOpened


{-| See `M3e.Events.onClosed`.
-}
onClosed : msg -> Attr { c | onClosed : Supported } msg
onClosed =
    Ev.onClosed


{-| Place an element into the named `header` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
header : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
header element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "header") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
