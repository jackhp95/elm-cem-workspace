module M3e.Component.Menu exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , PositionX, positionX, PositionY, positionY, Variant, variant
    , submenu, onBeforetoggle, onToggle
    , child
    )

{-| The `m3e-menu` component — strict per-component surface.

Presents a list of choices on a temporary surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs PositionX, positionX, PositionY, positionY, Variant, variant
@docs submenu, onBeforetoggle, onToggle
@docs child


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu1" ] [ M3e.text "Menu" ], action = M3e.Action.none } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu1" ] [ M3e.Component.MenuItem.component [] [ M3e.text "Item 1" ], M3e.Component.MenuItem.component [] [ M3e.text "Item 2" ] ]
    ]
```

<!-- elm-cem:example title="Variants" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "vmenu1" ] [ M3e.text "Vibrant menu" ], action = M3e.Action.none } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "vmenu1", M3e.Component.Menu.variant M3e.Values.vibrant ] [ M3e.Component.MenuItem.component [] [ M3e.text "Item 1" ], M3e.Component.MenuItem.component [] [ M3e.text "Item 2" ] ]
    ]
```

<!-- elm-cem:example title="Icons" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu8" ] [ M3e.text "Menu items with icons" ], action = M3e.Action.none } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu8" ] [ M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "dialpad" ] []), M3e.text "Redial" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "voicemail" ] []), M3e.text "Check voice mail" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "notifications_off" ] []), M3e.text "Disable alerts" ] ]
    ]
```

<!-- elm-cem:example title="Disabling" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu9" ] [ M3e.text "Menu with disabled items" ], action = M3e.Action.none } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu9" ] [ M3e.Component.MenuItem.component [ M3e.Component.MenuItem.disabled True ] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "dialpad" ] []), M3e.text "Redial" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "voicemail" ] []), M3e.text "Check voice mail" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "notifications_off" ] []), M3e.text "Disable alerts" ] ]
    ]
```

<!-- elm-cem:example title="Checkboxes" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu2" ] [ M3e.text "Menu with checkboxes" ], action = M3e.Action.none } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu2" ] [ M3e.Component.MenuItemCheckbox.component [ M3e.Component.MenuItemCheckbox.checked True ] [ M3e.Component.MenuItemCheckbox.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "format_bold" ] []), M3e.text "Bold" ], M3e.Component.MenuItemCheckbox.component [] [ M3e.Component.MenuItemCheckbox.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "format_italic" ] []), M3e.text "Italic" ], M3e.Component.MenuItemCheckbox.component [] [ M3e.Component.MenuItemCheckbox.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "format_underlined" ] []), M3e.text "Underline" ] ]
    ]
```

<!-- elm-cem:example title="Radios" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu3" ] [ M3e.text "Menu with radios" ], action = M3e.Action.none } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu3" ] [ M3e.Component.MenuItemRadio.component [ M3e.Component.MenuItemRadio.checked True ] [ M3e.text "Ascending" ], M3e.Component.MenuItemRadio.component [] [ M3e.text "Descending" ] ]
    ]
```

<!-- elm-cem:example title="Radios (2)" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu4" ] [ M3e.text "Menu with radio groups" ], action = M3e.Action.none } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu4" ] [ M3e.Component.MenuItemGroup.component [] [ M3e.Component.MenuItemRadio.component [ M3e.Component.MenuItemRadio.checked True ] [ M3e.text "Ascending" ], M3e.Component.MenuItemRadio.component [] [ M3e.text "Descending" ] ], M3e.Component.Divider.component [] [], M3e.Component.MenuItemGroup.component [] [ M3e.Component.MenuItemRadio.component [ M3e.Component.MenuItemRadio.checked True ] [ M3e.text "Alphabetical" ], M3e.Component.MenuItemRadio.component [] [ M3e.text "By Date" ] ] ]
    ]
```

<!-- elm-cem:example title="Submenus" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu5" ] [ M3e.text "Menu with submenus" ], action = M3e.Action.none } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu5" ] [ M3e.Component.MenuItem.component [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu6" ] [ M3e.text "Fruits with A" ] ], M3e.Component.MenuItem.component [] [ M3e.text "Grapes" ], M3e.Component.MenuItem.component [] [ M3e.text "Olive" ], M3e.Component.MenuItem.component [] [ M3e.text "Orange" ] ]
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu6" ] [ M3e.Component.MenuItem.component [] [ M3e.text "Apricot" ], M3e.Component.MenuItem.component [] [ M3e.text "Avocado" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu7" ] [ M3e.text "Apples" ] ] ]
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu7" ] [ M3e.Component.MenuItem.component [] [ M3e.text "Fuji" ], M3e.Component.MenuItem.component [] [ M3e.text "Granny Smith" ], M3e.Component.MenuItem.component [] [ M3e.text "Red Delicious" ] ]
    ]
```

<!-- elm-cem:example title="Density" -->
```elm
[ M3e.Component.Button.component { content = M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu-density-3" ] [ M3e.text "Density -3" ], action = M3e.Action.none } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu-density-3", M3e.Attributes.class "density-3" ] [ M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Item 1" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Item 2" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Item 3" ] ]
    , M3e.Component.Button.component { content = M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu-density-2" ] [ M3e.text "Density -2" ], action = M3e.Action.none } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu-density-2", M3e.Attributes.class "density-2" ] [ M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Item 1" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Item 2" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Item 3" ] ]
    , M3e.Component.Button.component { content = M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu-density-1" ] [ M3e.text "Density -1" ], action = M3e.Action.none } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu-density-1", M3e.Attributes.class "density-1" ] [ M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Item 1" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Item 2" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Item 3" ] ]
    , M3e.Component.Button.component { content = M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu-density-0" ] [ M3e.text "Density 0" ], action = M3e.Action.none } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu-density-0", M3e.Attributes.class "density-0" ] [ M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Item 1" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Item 2" ], M3e.Component.MenuItem.component [] [ M3e.Component.MenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Item 3" ] ]
    ]
```

<!-- elm-cem:docmeta category=Navigation -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Decode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Menu
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-menu` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Menu.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Menu.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Menu.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Menu.ChildAdmittedBy childAdm


{-| The `positionX` values valid on this component (compile-tight narrowing).
-}
type alias PositionX =
    M3e.Internal.Types.Menu.PositionX


{-| The `positionY` values valid on this component (compile-tight narrowing).
-}
type alias PositionY =
    M3e.Internal.Types.Menu.PositionY


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Menu.Variant


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Menu.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Menu.AttrCaps


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
    H.menu


{-| The position of the menu, on the x-axis. (default: `"after"`)
-}
positionX : Value PositionX -> Attr { c | positionX : Supported } msg
positionX value_ =
    Ir.attribute "position-x" (Val.toString value_)


{-| The position of the menu, on the y-axis. (default: `"below"`)
-}
positionY : Value PositionY -> Attr { c | positionY : Supported } msg
positionY value_ =
    Ir.attribute "position-y" (Val.toString value_)


{-| The appearance variant of the menu. (default: `"standard"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.submenu`.
-}
submenu : Bool -> Attr { c | submenu : Supported } msg
submenu =
    A.submenu


{-| See `M3e.Events.onBeforetoggle`.
-}
onBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
onBeforetoggle =
    Ev.onBeforetoggle


{-| Typed `toggle` event: decodes `newState` as String.
-}
onToggle : (String -> msg) -> Attr { c | onToggle : Supported } msg
onToggle toMsg =
    Ir.on "toggle" (Json.Decode.map toMsg (Json.Decode.at [ "newState" ] Json.Decode.string))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
