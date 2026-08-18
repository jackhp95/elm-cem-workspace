module M3e.Component.DrawerContainer exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , EndMode, endMode, StartMode, startMode
    , endDivider, startDivider, onChange
    , end, start, child
    )

{-| The `m3e-drawer-container` component — strict per-component surface.

A container for one or two sliding drawers.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs EndMode, endMode, StartMode, startMode
@docs endDivider, startDivider, onChange
@docs end, start, child


## Examples


### Examples

<!-- elm-cem:example title="Drawers" -->
```elm
M3e.Component.DrawerContainer.component [] [ M3e.Component.DrawerContainer.start (TypedHtml.div [] [ M3e.text "Start drawer" ]), TypedHtml.div [] [ M3e.text "Main content" ], M3e.Component.DrawerContainer.end (TypedHtml.div [] [ M3e.text "End drawer" ]) ]
```

<!-- elm-cem:example title="Sizes" -->
```elm
M3e.Component.DrawerContainer.component [] [ M3e.Component.DrawerContainer.start (TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 200px" ] [ M3e.text "Start drawer" ]), TypedHtml.div [] [ M3e.text "Main content" ] ]
```

<!-- elm-cem:example title="Modes" -->
```elm
M3e.Component.DrawerContainer.component [ M3e.Component.DrawerContainer.startMode M3e.Values.push ] [ M3e.Component.DrawerContainer.start (TypedHtml.div [] [ M3e.text "Start drawer" ]), TypedHtml.div [] [ M3e.text "Main content" ] ]
```

<!-- elm-cem:example title="Modes (2)" -->
```elm
M3e.Component.DrawerContainer.component [ M3e.Component.DrawerContainer.startMode M3e.Values.over ] [ M3e.Component.DrawerContainer.start (TypedHtml.div [] [ M3e.text "Start drawer" ]), TypedHtml.div [] [ M3e.text "Main content" ] ]
```

<!-- elm-cem:example title="Dividers" -->
```elm
M3e.Component.DrawerContainer.component [ M3e.Component.DrawerContainer.endMode M3e.Values.side, M3e.Component.DrawerContainer.endDivider True ] [ TypedHtml.div [] [ M3e.text "Main content" ], M3e.Component.DrawerContainer.end (TypedHtml.div [] [ M3e.text "End drawer" ]) ]
```

<!-- elm-cem:example title="Toggle" -->
```elm
[ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "menu" ] [], ariaLabel = "Menu", action = M3e.Action.none } [ M3e.Component.IconButton.toggle True ] [ M3e.Component.IconButton.selected (M3e.Component.Icon.component [ M3e.Component.Icon.name "menu_open" ] []), M3e.Component.DrawerToggle.component [ M3e.Component.DrawerToggle.for "nav-drawer" ] [] ]
    , M3e.Component.DrawerContainer.component [ M3e.Component.DrawerContainer.startMode M3e.Values.over ] [ M3e.Component.DrawerContainer.start (TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "id" "nav-drawer" ] [ M3e.text "Start drawer" ]), TypedHtml.div [] [ M3e.text "Main content" ] ]
    ]
```

<!-- elm-cem:example title="Accessibility" -->
```elm
M3e.Component.DrawerContainer.component [] [ M3e.Component.DrawerContainer.start (TypedHtml.nav [] []), TypedHtml.main_ [] [], M3e.Component.DrawerContainer.end (TypedHtml.aside [] []) ]
```

<!-- elm-cem:docmeta category=Navigation -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.DrawerContainer
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-drawer-container` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.DrawerContainer.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.DrawerContainer.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.DrawerContainer.ChildAdmittedBy childAdm


{-| The `endMode` values valid on this component (compile-tight narrowing).
-}
type alias EndMode =
    M3e.Internal.Types.DrawerContainer.EndMode


{-| The `startMode` values valid on this component (compile-tight narrowing).
-}
type alias StartMode =
    M3e.Internal.Types.DrawerContainer.StartMode


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.DrawerContainer.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.DrawerContainer.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.DrawerContainer.SlotCaps


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
    H.drawerContainer


{-| The behavior mode of the end drawer. (default: `"side"`)
-}
endMode : Value EndMode -> Attr { c | endMode : Supported } msg
endMode value_ =
    Ir.attribute "end-mode" (Val.toString value_)


{-| The behavior mode of the start drawer. (default: `"side"`)
-}
startMode : Value StartMode -> Attr { c | startMode : Supported } msg
startMode value_ =
    Ir.attribute "start-mode" (Val.toString value_)


{-| See `M3e.Attributes.endDivider`.
-}
endDivider : Bool -> Attr { c | endDivider : Supported } msg
endDivider =
    A.endDivider


{-| See `M3e.Attributes.startDivider`.
-}
startDivider : Bool -> Attr { c | startDivider : Supported } msg
startDivider =
    A.startDivider


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| Place an element into the named `end` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
end : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
end element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "end") (El.toNode element))


{-| Place an element into the named `start` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
start : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
start element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "start") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
