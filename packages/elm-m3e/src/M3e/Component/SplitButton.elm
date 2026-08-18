module M3e.Component.SplitButton exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, LeadingButtonSlot, TrailingButtonSlot, ChildAdmittedBy
    , Size, size, Variant, variant
    , leadingButton, trailingButton
    )

{-| The `m3e-split-button` component — strict per-component surface.

A button used to show an action with a menu of related actions.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, LeadingButtonSlot, TrailingButtonSlot, ChildAdmittedBy
@docs Size, size, Variant, variant
@docs leadingButton, trailingButton


## Examples


### Examples

<!-- elm-cem:example title="Anatomy" -->
```elm
[ M3e.Component.SplitButton.component { leadingButton = M3e.Component.Button.component { content = M3e.text "Edit", action = M3e.Action.none } [] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "edit" ] []) ], trailingButton = M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "keyboard_arrow_down" ] [], ariaLabel = "More options", action = M3e.Action.none } [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu" ] [] ] } [] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu", M3e.Component.Menu.positionX M3e.Values.before ] [ M3e.Component.MenuItem.component [] [ M3e.text "Rename" ], M3e.Component.MenuItem.component [] [ M3e.text "Copy" ], M3e.Component.MenuItem.component [] [ M3e.text "Delete" ] ]
    ]
```

<!-- elm-cem:example title="Variants" -->
```elm
[ M3e.Component.SplitButton.component { leadingButton = M3e.Component.Button.component { content = M3e.text "Edit", action = M3e.Action.none } [] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "edit" ] []) ], trailingButton = M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "keyboard_arrow_down" ] [], ariaLabel = "More options", action = M3e.Action.none } [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu1" ] [] ] } [ M3e.Component.SplitButton.variant M3e.Values.filled ] []
    , M3e.Component.SplitButton.component { leadingButton = M3e.Component.Button.component { content = M3e.text "Edit", action = M3e.Action.none } [] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "edit" ] []) ], trailingButton = M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "keyboard_arrow_down" ] [], ariaLabel = "More options", action = M3e.Action.none } [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu1" ] [] ] } [ M3e.Component.SplitButton.variant M3e.Values.tonal ] []
    , M3e.Component.SplitButton.component { leadingButton = M3e.Component.Button.component { content = M3e.text "Edit", action = M3e.Action.none } [] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "edit" ] []) ], trailingButton = M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "keyboard_arrow_down" ] [], ariaLabel = "More options", action = M3e.Action.none } [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu1" ] [] ] } [ M3e.Component.SplitButton.variant M3e.Values.outlined ] []
    , M3e.Component.SplitButton.component { leadingButton = M3e.Component.Button.component { content = M3e.text "Edit", action = M3e.Action.none } [] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "edit" ] []) ], trailingButton = M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "keyboard_arrow_down" ] [], ariaLabel = "More options", action = M3e.Action.none } [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu1" ] [] ] } [ M3e.Component.SplitButton.variant M3e.Values.elevated ] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu1", M3e.Component.Menu.positionX M3e.Values.before ] [ M3e.Component.MenuItem.component [] [ M3e.text "Rename" ], M3e.Component.MenuItem.component [] [ M3e.text "Copy" ], M3e.Component.MenuItem.component [] [ M3e.text "Delete" ] ]
    ]
```

<!-- elm-cem:example title="Sizes" -->
```elm
[ M3e.Component.SplitButton.component { leadingButton = M3e.Component.Button.component { content = M3e.text "Edit", action = M3e.Action.none } [] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "edit" ] []) ], trailingButton = M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "keyboard_arrow_down" ] [], ariaLabel = "More options", action = M3e.Action.none } [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu2" ] [] ] } [ M3e.Component.SplitButton.size M3e.Values.extraSmall ] []
    , M3e.Component.SplitButton.component { leadingButton = M3e.Component.Button.component { content = M3e.text "Edit", action = M3e.Action.none } [] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "edit" ] []) ], trailingButton = M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "keyboard_arrow_down" ] [], ariaLabel = "More options", action = M3e.Action.none } [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu2" ] [] ] } [ M3e.Component.SplitButton.size M3e.Values.small ] []
    , M3e.Component.SplitButton.component { leadingButton = M3e.Component.Button.component { content = M3e.text "Edit", action = M3e.Action.none } [] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "edit" ] []) ], trailingButton = M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "keyboard_arrow_down" ] [], ariaLabel = "More options", action = M3e.Action.none } [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu2" ] [] ] } [ M3e.Component.SplitButton.size M3e.Values.medium ] []
    , M3e.Component.SplitButton.component { leadingButton = M3e.Component.Button.component { content = M3e.text "Edit", action = M3e.Action.none } [] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "edit" ] []) ], trailingButton = M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "keyboard_arrow_down" ] [], ariaLabel = "More options", action = M3e.Action.none } [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu2" ] [] ] } [ M3e.Component.SplitButton.size M3e.Values.large ] []
    , M3e.Component.SplitButton.component { leadingButton = M3e.Component.Button.component { content = M3e.text "Edit", action = M3e.Action.none } [] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "edit" ] []) ], trailingButton = M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "keyboard_arrow_down" ] [], ariaLabel = "More options", action = M3e.Action.none } [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu2" ] [] ] } [ M3e.Component.SplitButton.size M3e.Values.extraLarge ] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu2", M3e.Component.Menu.positionX M3e.Values.before ] [ M3e.Component.MenuItem.component [] [ M3e.text "Rename" ], M3e.Component.MenuItem.component [] [ M3e.text "Copy" ], M3e.Component.MenuItem.component [] [ M3e.text "Delete" ] ]
    ]
```

<!-- elm-cem:example title="Density" -->
```elm
[ M3e.Component.SplitButton.component { leadingButton = M3e.Component.Button.component { content = M3e.text "Edit", action = M3e.Action.none } [] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "edit" ] []) ], trailingButton = M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "keyboard_arrow_down" ] [], ariaLabel = "More options", action = M3e.Action.none } [] [ M3e.Component.MenuTrigger.component [ M3e.Component.MenuTrigger.for "menu3" ] [] ] } [ M3e.Component.SplitButton.size M3e.Values.extraSmall, M3e.Attributes.class "density-3" ] []
    , M3e.Component.Menu.component [ M3e.Attributes.id "menu3", M3e.Component.Menu.positionX M3e.Values.before, M3e.Attributes.class "density-3" ] [ M3e.Component.MenuItem.component [] [ M3e.text "Rename" ], M3e.Component.MenuItem.component [] [ M3e.text "Copy" ], M3e.Component.MenuItem.component [] [ M3e.text "Delete" ] ]
    ]
```

<!-- elm-cem:docmeta category=Actions -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.SplitButton
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-split-button` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.SplitButton.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.SplitButton.Attrs


{-| The kinds the `leading-button` slot admits.
-}
type alias LeadingButtonSlot =
    M3e.Internal.Types.SplitButton.LeadingButtonSlot


{-| The kinds the `trailing-button` slot admits.
-}
type alias TrailingButtonSlot =
    M3e.Internal.Types.SplitButton.TrailingButtonSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SplitButton.ChildAdmittedBy childAdm


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    M3e.Internal.Types.SplitButton.Size


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.SplitButton.Variant


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.SplitButton.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.SplitButton.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.SplitButton.SlotCaps


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { leadingButton : Element LeadingButtonSlot (ChildAdmittedBy childAdm) msg
    , trailingButton : Element TrailingButtonSlot (ChildAdmittedBy childAdm) msg
    }
    -> List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    H.splitButton attrs (Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "leading-button") (El.toNode required_.leadingButton)) :: Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing-button") (El.toNode required_.trailingButton)) :: children)


{-| The size of the button. (default: `"small"`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| The appearance variant of the button. (default: `"filled"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| Place an element into the named `leading-button` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
leadingButton : Element LeadingButtonSlot admittedBy msg -> Element free freeAdmittedBy msg
leadingButton element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "leading-button") (El.toNode element))


{-| Place an element into the named `trailing-button` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
trailingButton : Element TrailingButtonSlot admittedBy msg -> Element free freeAdmittedBy msg
trailingButton element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing-button") (El.toNode element))
