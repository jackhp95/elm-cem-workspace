module M3e.Component.ButtonGroup exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , Size, size, Variant, variant
    , multi
    , child
    )

{-| The `m3e-button-group` component — strict per-component surface.

Organizes buttons and adds interactions between them.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs Size, size, Variant, variant
@docs multi
@docs child


## Examples


### Examples

<!-- elm-cem:example title="Standard" -->
```elm
M3e.Component.ButtonGroup.component [] [ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_back" ] [], ariaLabel = "Back", action = M3e.Action.none } [] [], M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_forward" ] [], ariaLabel = "Forward", action = M3e.Action.none } [] [], M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.width M3e.Values.wide, M3e.Component.IconButton.variant M3e.Values.filled ] [], M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "picture_in_picture" ] [], ariaLabel = "Picture in picture", action = M3e.Action.none } [] [], M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "more_vert" ] [], ariaLabel = "More options", action = M3e.Action.none } [] [] ]
```

<!-- elm-cem:example title="Standard (2)" -->
```elm
M3e.Component.ButtonGroup.component [] [ M3e.Component.Button.component { content = M3e.text "Start", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "play_arrow" ] []) ], M3e.Component.Button.component { content = M3e.text "Directions", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "directions_car" ] []) ], M3e.Component.Button.component { content = M3e.text "Share", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "share" ] []) ] ]
```

<!-- elm-cem:example title="Standard (3)" -->
```elm
M3e.Component.ButtonGroup.component [] [ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "fast_rewind" ] [], ariaLabel = "Rewind", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.width M3e.Values.wide ] [], M3e.Component.Button.component { content = M3e.text "Play", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.filled ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "play_arrow" ] []) ], M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "fast_forward" ] [], ariaLabel = "Fast forward", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.width M3e.Values.wide ] [] ]
```

<!-- elm-cem:example title="Connected" -->
```elm
M3e.Component.ButtonGroup.component [ M3e.Component.ButtonGroup.variant M3e.Values.connected ] [ M3e.Component.Button.component { content = M3e.text "Start", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [], M3e.Component.Button.component { content = M3e.text "Directions", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [], M3e.Component.Button.component { content = M3e.text "Share", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [] ]
```

<!-- elm-cem:example title="Sizes" -->
```elm
M3e.Component.ButtonGroup.component [ M3e.Component.ButtonGroup.size M3e.Values.large ] [ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_back" ] [], ariaLabel = "Back", action = M3e.Action.none } [ M3e.Component.IconButton.size M3e.Values.large ] [], M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_forward" ] [], ariaLabel = "Forward", action = M3e.Action.none } [ M3e.Component.IconButton.size M3e.Values.large ] [], M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.size M3e.Values.large, M3e.Component.IconButton.width M3e.Values.wide, M3e.Component.IconButton.variant M3e.Values.filled ] [], M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "picture_in_picture" ] [], ariaLabel = "Picture in picture", action = M3e.Action.none } [ M3e.Component.IconButton.size M3e.Values.large ] [], M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "more_vert" ] [], ariaLabel = "More options", action = M3e.Action.none } [ M3e.Component.IconButton.size M3e.Values.large ] [] ]
```

<!-- elm-cem:example title="Sizes (2)" -->
```elm
M3e.Component.ButtonGroup.component [ M3e.Component.ButtonGroup.size M3e.Values.large, M3e.Component.ButtonGroup.variant M3e.Values.connected ] [ M3e.Component.Button.component { content = M3e.text "Start", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.size M3e.Values.large, M3e.Component.Button.toggle True ] [], M3e.Component.Button.component { content = M3e.text "Directions", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.size M3e.Values.large, M3e.Component.Button.toggle True ] [], M3e.Component.Button.component { content = M3e.text "Share", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.size M3e.Values.large, M3e.Component.Button.toggle True ] [] ]
```

<!-- elm-cem:example title="Selection" -->
```elm
M3e.Component.ButtonGroup.component [ M3e.Component.ButtonGroup.multi True ] [ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "format_bold" ] [], ariaLabel = "Bold", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.toggle True ] [], M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "format_italic" ] [], ariaLabel = "Italic", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.toggle True ] [], M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "format_underlined" ] [], ariaLabel = "Underline", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.toggle True ] [] ]
```

<!-- elm-cem:example title="Density" -->
```elm
[ M3e.Component.ButtonGroup.component [ M3e.Attributes.class "density-3" ] [ M3e.Component.Button.component { content = M3e.text "Start", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "play_arrow" ] []) ], M3e.Component.Button.component { content = M3e.text "Directions", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "directions_car" ] []) ], M3e.Component.Button.component { content = M3e.text "Share", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "share" ] []) ] ]
    , TypedHtml.br [] []
    , M3e.Component.ButtonGroup.component [ M3e.Attributes.class "density-2" ] [ M3e.Component.Button.component { content = M3e.text "Start", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "play_arrow" ] []) ], M3e.Component.Button.component { content = M3e.text "Directions", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "directions_car" ] []) ], M3e.Component.Button.component { content = M3e.text "Share", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "share" ] []) ] ]
    , TypedHtml.br [] []
    , M3e.Component.ButtonGroup.component [ M3e.Attributes.class "density-1" ] [ M3e.Component.Button.component { content = M3e.text "Start", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "play_arrow" ] []) ], M3e.Component.Button.component { content = M3e.text "Directions", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "directions_car" ] []) ], M3e.Component.Button.component { content = M3e.text "Share", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "share" ] []) ] ]
    , TypedHtml.br [] []
    , M3e.Component.ButtonGroup.component [ M3e.Attributes.class "density-0" ] [ M3e.Component.Button.component { content = M3e.text "Start", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "play_arrow" ] []) ], M3e.Component.Button.component { content = M3e.text "Directions", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "directions_car" ] []) ], M3e.Component.Button.component { content = M3e.text "Share", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal ] [ M3e.Component.Button.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "share" ] []) ] ]
    ]
```

<!-- elm-cem:example title="Density (2)" -->
```elm
[ M3e.Component.ButtonGroup.component [ M3e.Component.ButtonGroup.variant M3e.Values.connected, M3e.Attributes.class "density-3" ] [ M3e.Component.Button.component { content = M3e.text "Start", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [], M3e.Component.Button.component { content = M3e.text "Directions", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [], M3e.Component.Button.component { content = M3e.text "Share", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [] ]
    , TypedHtml.br [] []
    , M3e.Component.ButtonGroup.component [ M3e.Component.ButtonGroup.variant M3e.Values.connected, M3e.Attributes.class "density-2" ] [ M3e.Component.Button.component { content = M3e.text "Start", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [], M3e.Component.Button.component { content = M3e.text "Directions", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [], M3e.Component.Button.component { content = M3e.text "Share", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [] ]
    , TypedHtml.br [] []
    , M3e.Component.ButtonGroup.component [ M3e.Component.ButtonGroup.variant M3e.Values.connected, M3e.Attributes.class "density-1" ] [ M3e.Component.Button.component { content = M3e.text "Start", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [], M3e.Component.Button.component { content = M3e.text "Directions", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [], M3e.Component.Button.component { content = M3e.text "Share", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [] ]
    , TypedHtml.br [] []
    , M3e.Component.ButtonGroup.component [ M3e.Component.ButtonGroup.variant M3e.Values.connected, M3e.Attributes.class "density-0" ] [ M3e.Component.Button.component { content = M3e.text "Start", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [], M3e.Component.Button.component { content = M3e.text "Directions", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [], M3e.Component.Button.component { content = M3e.text "Share", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.tonal, M3e.Component.Button.toggle True ] [] ]
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
import M3e.Internal.Types.ButtonGroup
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-button-group` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.ButtonGroup.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.ButtonGroup.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.ButtonGroup.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ButtonGroup.ChildAdmittedBy childAdm


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    M3e.Internal.Types.ButtonGroup.Size


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.ButtonGroup.Variant


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.ButtonGroup.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.ButtonGroup.AttrCaps


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
    H.buttonGroup


{-| The size of the group. (default: `"small"`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| The appearance variant of the group. (default: `"standard"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.multi`.
-}
multi : Bool -> Attr { c | multi : Supported } msg
multi =
    A.multi


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
