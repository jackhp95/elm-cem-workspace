module M3e.Component.Tree exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , cascade, multi, onChange
    , child
    )

{-| The `m3e-tree` component — strict per-component surface.

Presents hierarchical data in a tree structure.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs cascade, multi, onChange
@docs child


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
M3e.Component.Tree.component [] [ M3e.Component.TreeItem.component { label = M3e.text "Getting Started" } [ M3e.Component.TreeItem.open True ] [ M3e.Component.TreeItem.component { label = M3e.text "Overview" } [] [], M3e.Component.TreeItem.component { label = M3e.text "Installation" } [] [] ], M3e.Component.TreeItem.component { label = M3e.text "Components" } [] [ M3e.Component.TreeItem.component { label = M3e.text "Button" } [] [], M3e.Component.TreeItem.component { label = M3e.text "Card" } [] [] ] ]
```

<!-- elm-cem:example title="Selection" -->
```elm
M3e.Component.Tree.component [] [ M3e.Component.TreeItem.component { label = M3e.text "Getting Started" } [ M3e.Component.TreeItem.open True ] [ M3e.Component.TreeItem.component { label = M3e.text "Overview" } [ M3e.Component.TreeItem.selected True ] [], M3e.Component.TreeItem.component { label = M3e.text "Installation" } [] [] ], M3e.Component.TreeItem.component { label = M3e.text "Components" } [] [ M3e.Component.TreeItem.component { label = M3e.text "Button" } [] [], M3e.Component.TreeItem.component { label = M3e.text "Card" } [] [] ] ]
```

<!-- elm-cem:example title="Multiple selection" -->
```elm
M3e.Component.Tree.component [ M3e.Component.Tree.multi True ] [ M3e.Component.TreeItem.component { label = M3e.text "Fruits" } [] [ M3e.Component.TreeItem.component { label = M3e.text "Apples" } [] [], M3e.Component.TreeItem.component { label = M3e.text "Oranges" } [] [], M3e.Component.TreeItem.component { label = M3e.text "Bananas" } [] [] ], M3e.Component.TreeItem.component { label = M3e.text "Vegetables" } [] [ M3e.Component.TreeItem.component { label = M3e.text "Carrots" } [] [], M3e.Component.TreeItem.component { label = M3e.text "Broccoli" } [] [], M3e.Component.TreeItem.component { label = M3e.text "Spinach" } [] [] ] ]
```

<!-- elm-cem:example title="Cascade selection" -->
```elm
M3e.Component.Tree.component [ M3e.Component.Tree.multi True, M3e.Component.Tree.cascade True ] [ M3e.Component.TreeItem.component { label = M3e.text "Fruits" } [] [ M3e.Component.TreeItem.component { label = M3e.text "Apples" } [] [], M3e.Component.TreeItem.component { label = M3e.text "Oranges" } [] [], M3e.Component.TreeItem.component { label = M3e.text "Bananas" } [] [] ], M3e.Component.TreeItem.component { label = M3e.text "Vegetables" } [] [ M3e.Component.TreeItem.component { label = M3e.text "Carrots" } [] [], M3e.Component.TreeItem.component { label = M3e.text "Broccoli" } [] [], M3e.Component.TreeItem.component { label = M3e.text "Spinach" } [] [] ] ]
```

<!-- elm-cem:example title="Icons" -->
```elm
M3e.Component.Tree.component [] [ M3e.Component.TreeItem.component { label = M3e.text "Getting Started" } [ M3e.Component.TreeItem.open True ] [ M3e.Component.TreeItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "rocket_launch" ] []), M3e.Component.TreeItem.component { label = M3e.text "Overview" } [] [ M3e.Component.TreeItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "near_me" ] []) ], M3e.Component.TreeItem.component { label = M3e.text "Installation" } [] [ M3e.Component.TreeItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "package_2" ] []) ] ] ]
```

<!-- elm-cem:example title="Toggle icons" -->
```elm
M3e.Component.Tree.component [] [ M3e.Component.TreeItem.component { label = M3e.text "Getting Started" } [ M3e.Component.TreeItem.open True ] [ M3e.Component.TreeItem.toggleIcon (M3e.Component.Icon.component [ M3e.Component.Icon.name "add_box" ] []), M3e.Component.TreeItem.openToggleIcon (M3e.Component.Icon.component [ M3e.Component.Icon.name "indeterminate_check_box" ] []), M3e.Component.TreeItem.component { label = M3e.text "Overview" } [] [], M3e.Component.TreeItem.component { label = M3e.text "Installation" } [] [] ] ]
```

<!-- elm-cem:example title="Density" -->
```elm
M3e.Component.Tree.component [ M3e.Attributes.class "density-3" ] [ M3e.Component.TreeItem.component { label = M3e.text "Getting Started" } [ M3e.Component.TreeItem.open True ] [ M3e.Component.TreeItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "rocket_launch" ] []), M3e.Component.TreeItem.component { label = M3e.text "Overview" } [] [ M3e.Component.TreeItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "near_me" ] []) ], M3e.Component.TreeItem.component { label = M3e.text "Installation" } [] [ M3e.Component.TreeItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "package_2" ] []) ] ] ]
```

<!-- elm-cem:docmeta category=Layout & style -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Tree
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-tree` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Tree.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Tree.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Tree.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Tree.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Tree.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Tree.AttrCaps


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
    H.tree


{-| See `M3e.Attributes.cascade`.
-}
cascade : Bool -> Attr { c | cascade : Supported } msg
cascade =
    A.cascade


{-| See `M3e.Attributes.multi`.
-}
multi : Bool -> Attr { c | multi : Supported } msg
multi =
    A.multi


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
