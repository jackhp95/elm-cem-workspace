module M3e.Component.ExpansionPanel exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, HeaderSlot, ToggleIconSlot, ChildAdmittedBy
    , ToggleDirection, toggleDirection, TogglePosition, togglePosition
    , disabled, hideToggle, open, onOpening, onOpened, onClosing, onClosed
    , actions, header, toggleIcon, child
    )

{-| The `m3e-expansion-panel` component — strict per-component surface.

An expandable details-summary view.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, HeaderSlot, ToggleIconSlot, ChildAdmittedBy
@docs ToggleDirection, toggleDirection, TogglePosition, togglePosition
@docs disabled, hideToggle, open, onOpening, onOpened, onClosing, onClosed
@docs actions, header, toggleIcon, child


## Examples


### Examples

<!-- elm-cem:example title="Standalone panels" -->
```elm
M3e.Component.ExpansionPanel.component { header = TypedHtml.span [] [ M3e.text "Panel header" ] } [] [ M3e.text "Panel contents" ]
```

<!-- elm-cem:example title="Standalone panels (2)" -->
```elm
M3e.Component.ExpansionPanel.component { header = TypedHtml.span [] [ M3e.text "Panel header" ] } [ M3e.Component.ExpansionPanel.open True ] [ M3e.text "Panel contents" ]
```

<!-- elm-cem:example title="Toggles" -->
```elm
M3e.Component.ExpansionPanel.component { header = TypedHtml.span [] [ M3e.text "Panel header" ] } [ M3e.Component.ExpansionPanel.togglePosition M3e.Values.before, M3e.Component.ExpansionPanel.toggleDirection M3e.Values.horizontal ] [ M3e.text "Panel contents" ]
```

<!-- elm-cem:example title="Toggles (2)" -->
```elm
M3e.Component.ExpansionPanel.component { header = TypedHtml.span [] [ M3e.text "Panel header" ] } [ M3e.Component.ExpansionPanel.hideToggle True ] [ M3e.text "Panel contents" ]
```

<!-- elm-cem:example title="Accordion" -->
```elm
M3e.Component.Accordion.component { content = M3e.Component.ExpansionPanel.component { header = TypedHtml.span [] [ M3e.text "Panel 1" ] } [ M3e.Component.ExpansionPanel.open True ] [ M3e.text "I am content for the first panel" ] } [] [ M3e.Component.ExpansionPanel.component { header = TypedHtml.span [] [ M3e.text "Panel 2" ] } [] [ M3e.text "I am content for the second panel" ], M3e.Component.ExpansionPanel.component { header = TypedHtml.span [] [ M3e.text "Panel 3" ] } [] [ M3e.text "I am content for the third panel" ] ]
```

<!-- elm-cem:example title="Accordion (2)" -->
```elm
M3e.Component.Accordion.component { content = M3e.Component.ExpansionPanel.component { header = TypedHtml.span [] [ M3e.text "Panel 1" ] } [ M3e.Component.ExpansionPanel.open True ] [ M3e.text "I am content for the first panel" ] } [ M3e.Component.Accordion.multi True ] [ M3e.Component.ExpansionPanel.component { header = TypedHtml.span [] [ M3e.text "Panel 2" ] } [ M3e.Component.ExpansionPanel.open True ] [ M3e.text "I am content for the second panel" ], M3e.Component.ExpansionPanel.component { header = TypedHtml.span [] [ M3e.text "Panel 3" ] } [ M3e.Component.ExpansionPanel.open True ] [ M3e.text "I am content for the third panel" ] ]
```

<!-- elm-cem:docmeta category=Containment -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.ExpansionPanel
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-expansion-panel` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.ExpansionPanel.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.ExpansionPanel.Attrs


{-| The kinds the `header` slot admits.
-}
type alias HeaderSlot =
    M3e.Internal.Types.ExpansionPanel.HeaderSlot


{-| The kinds the `toggle-icon` slot admits.
-}
type alias ToggleIconSlot =
    M3e.Internal.Types.ExpansionPanel.ToggleIconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ExpansionPanel.ChildAdmittedBy childAdm


{-| The `toggleDirection` values valid on this component (compile-tight narrowing).
-}
type alias ToggleDirection =
    M3e.Internal.Types.ExpansionPanel.ToggleDirection


{-| The `togglePosition` values valid on this component (compile-tight narrowing).
-}
type alias TogglePosition =
    M3e.Internal.Types.ExpansionPanel.TogglePosition


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.ExpansionPanel.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.ExpansionPanel.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.ExpansionPanel.SlotCaps


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { header : Element HeaderSlot (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    H.expansionPanel attrs (Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "header") (El.toNode required_.header)) :: children)


{-| The direction of the expansion toggle. (default: `"vertical"`)
-}
toggleDirection : Value ToggleDirection -> Attr { c | toggleDirection : Supported } msg
toggleDirection value_ =
    Ir.attribute "toggle-direction" (Val.toString value_)


{-| The position of the expansion toggle. (default: `"after"`)
-}
togglePosition : Value TogglePosition -> Attr { c | togglePosition : Supported } msg
togglePosition value_ =
    Ir.attribute "toggle-position" (Val.toString value_)


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.hideToggle`.
-}
hideToggle : Bool -> Attr { c | hideToggle : Supported } msg
hideToggle =
    A.hideToggle


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


{-| Place an element into the named `actions` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
actions : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
actions element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "actions") (El.toNode element))


{-| Place an element into the named `header` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
header : Element HeaderSlot admittedBy msg -> Element free freeAdmittedBy msg
header element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "header") (El.toNode element))


{-| Place an element into the named `toggle-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
toggleIcon : Element ToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
toggleIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "toggle-icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
