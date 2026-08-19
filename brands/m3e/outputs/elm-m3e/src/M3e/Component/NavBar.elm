module M3e.Component.NavBar exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , Mode, mode
    , onChange, onBeforeinput, onInput
    , child
    )

{-| The `m3e-nav-bar` component — strict per-component surface.

A horizontal bar, typically used on smaller devices, that allows a user to switch between 3-5 views.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs Mode, mode
@docs onChange, onBeforeinput, onInput
@docs child


## Examples


### Examples

<!-- elm-cem:example title="Modes" -->
```elm
[ M3e.Component.NavBar.component [ M3e.Component.NavBar.mode M3e.Values.compact ] [ M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "news" ] []), M3e.text "News" ], M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "globe" ] []), M3e.text "Global" ], M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "star" ] []), M3e.text "For you" ], M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "newsstand" ] []), M3e.text "Trending" ] ]
    , TypedHtml.br [] []
    , M3e.Component.NavBar.component [ {- round-trip: dropped mode="extended" on m3e-nav-bar — CEM value "extended" (key "extended") has no matching Elm enum value in "mode" (available: auto, compact, expanded). Refusing to guess a token name. -} ] [ M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "news" ] []), M3e.text "News" ], M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "globe" ] []), M3e.text "Global" ], M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "star" ] []), M3e.text "For you" ], M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "newsstand" ] []), M3e.text "Trending" ] ]
    ]
```

<!-- elm-cem:example title="Items" -->
```elm
M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "news" ] []), M3e.text "News" ]
```

<!-- elm-cem:example title="Selection" -->
```elm
M3e.Component.NavBar.component [] [ M3e.Component.NavItem.component [ M3e.Component.NavItem.selected True ] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "news" ] []), M3e.text "News" ], M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "globe" ] []), M3e.text "Global" ], M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "star" ] []), M3e.text "For you" ], M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "newsstand" ] []), M3e.text "Trending" ] ]
```

<!-- elm-cem:example title="Disabling" -->
```elm
M3e.Component.NavBar.component [] [ M3e.Component.NavItem.component [ M3e.Component.NavItem.disabled True ] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "news" ] []), M3e.text "News" ], M3e.Component.NavItem.component [ M3e.Component.NavItem.disabledInteractive True ] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "globe" ] []), M3e.text "Global" ], M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "star" ] []), M3e.text "For you" ], M3e.Component.NavItem.component [] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "newsstand" ] []), M3e.text "Trending" ] ]
```

<!-- elm-cem:example title="Links" -->
```elm
M3e.Component.NavBar.component [] [ M3e.Component.NavItem.component [ M3e.Component.NavItem.href "https://www.google.com", M3e.Component.NavItem.target "_blank" ] [ M3e.Component.NavItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "news" ] []), M3e.text "News" ] ]
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
import M3e.Internal.Types.NavBar
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-nav-bar` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.NavBar.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.NavBar.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.NavBar.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.NavBar.ChildAdmittedBy childAdm


{-| The `mode` values valid on this component (compile-tight narrowing).
-}
type alias Mode =
    M3e.Internal.Types.NavBar.Mode


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.NavBar.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.NavBar.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.navBar


{-| The mode in which items in the bar are presented. (default: `"compact"`)
-}
mode : Value Mode -> Attr { c | mode : Supported } msg
mode value_ =
    Ir.attribute "mode" (Val.toString value_)


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
