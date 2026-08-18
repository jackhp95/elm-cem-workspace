module M3e.Component.NavMenu exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , child
    )

{-| The `m3e-nav-menu` component — strict per-component surface.

A hierarchical menu, typically used on larger devices, that allows a user to switch between views.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs child


## Examples


### Examples

<!-- elm-cem:example title="Multilevel menus" -->
```elm
M3e.Component.NavMenu.component [] [ M3e.Component.NavMenuItem.component { label = M3e.text "Getting Started" } [ M3e.Component.NavMenuItem.open True ] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "rocket_launch", TypedHtml.Unsafe.Attributes.customAttribute "aria-hidden" "true" ] []), M3e.Component.NavMenuItem.component { label = M3e.text "Overview" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "widgets", TypedHtml.Unsafe.Attributes.customAttribute "aria-hidden" "true" ] []) ], M3e.Component.NavMenuItem.component { label = M3e.text "Installation" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "package_2", TypedHtml.Unsafe.Attributes.customAttribute "aria-hidden" "true" ] []) ] ], M3e.Component.NavMenuItem.component { label = M3e.text "Actions" } [] [ M3e.Component.NavMenuItem.component { label = M3e.text "Button" } [] [], M3e.Component.NavMenuItem.component { label = M3e.text "Icon" } [] [], M3e.Component.NavMenuItem.component { label = M3e.text "Icon Button" } [] [] ] ]
```

<!-- elm-cem:example title="Grouping top-level items" -->
```elm
M3e.Component.NavMenu.component [] [ M3e.Component.NavMenuItemGroup.component [] [ M3e.Component.NavMenuItemGroup.label (M3e.Component.Heading.component { content = M3e.text "Mail" } [ M3e.Component.Heading.tocIgnore True, M3e.Component.Heading.variant M3e.Values.label, M3e.Component.Heading.size M3e.Values.large ] []), M3e.Component.NavMenuItem.component { label = M3e.text "Inbox" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "mail" ] []), M3e.Component.NavMenuItem.badge (M3e.text "24") ], M3e.Component.NavMenuItem.component { label = M3e.text "Outbox" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "send" ] []) ], M3e.Component.NavMenuItem.component { label = M3e.text "Favorites" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "favorite" ] []) ], M3e.Component.NavMenuItem.component { label = M3e.text "Trash" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "delete" ] []) ] ], M3e.Component.Divider.component [] [], M3e.Component.NavMenuItemGroup.component [] [ M3e.Component.NavMenuItemGroup.label (M3e.Component.Heading.component { content = M3e.text "Personal folders" } [ M3e.Component.Heading.tocIgnore True, M3e.Component.Heading.variant M3e.Values.label, M3e.Component.Heading.size M3e.Values.large ] []), M3e.Component.NavMenuItem.component { label = M3e.text "Family" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "folder" ] []) ], M3e.Component.NavMenuItem.component { label = M3e.text "Wedding" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "folder" ] []) ] ] ]
```

<!-- elm-cem:example title="Disabling" -->
```elm
M3e.Component.NavMenu.component [] [ M3e.Component.NavMenuItem.component { label = M3e.text "Getting Started" } [ M3e.Component.NavMenuItem.open True, M3e.Component.NavMenuItem.disabled True ] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "rocket_launch", TypedHtml.Unsafe.Attributes.customAttribute "aria-hidden" "true" ] []), M3e.Component.NavMenuItem.component { label = M3e.text "Overview" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "widgets", TypedHtml.Unsafe.Attributes.customAttribute "aria-hidden" "true" ] []) ], M3e.Component.NavMenuItem.component { label = M3e.text "Installation" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "package_2", TypedHtml.Unsafe.Attributes.customAttribute "aria-hidden" "true" ] []) ] ], M3e.Component.NavMenuItem.component { label = M3e.text "Actions" } [ M3e.Component.NavMenuItem.open True ] [ M3e.Component.NavMenuItem.component { label = M3e.text "Button" } [ M3e.Component.NavMenuItem.disabled True ] [], M3e.Component.NavMenuItem.component { label = M3e.text "Icon" } [] [], M3e.Component.NavMenuItem.component { label = M3e.text "Icon Button" } [] [] ] ]
```

<!-- elm-cem:example title="Density" -->
```elm
M3e.Component.NavMenu.component [ M3e.Attributes.class "density-3" ] [ M3e.Component.NavMenuItemGroup.component [] [ M3e.Component.NavMenuItemGroup.label (M3e.Component.Heading.component { content = M3e.text "Mail" } [ M3e.Component.Heading.tocIgnore True, M3e.Component.Heading.variant M3e.Values.label, M3e.Component.Heading.size M3e.Values.large ] []), M3e.Component.NavMenuItem.component { label = M3e.text "Inbox" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "mail" ] []), M3e.Component.NavMenuItem.badge (M3e.text "24") ], M3e.Component.NavMenuItem.component { label = M3e.text "Outbox" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "send" ] []) ], M3e.Component.NavMenuItem.component { label = M3e.text "Favorites" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "favorite" ] []) ], M3e.Component.NavMenuItem.component { label = M3e.text "Trash" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "delete" ] []) ] ], M3e.Component.Divider.component [] [], M3e.Component.NavMenuItemGroup.component [] [ M3e.Component.NavMenuItemGroup.label (M3e.Component.Heading.component { content = M3e.text "Personal folders" } [ M3e.Component.Heading.tocIgnore True, M3e.Component.Heading.variant M3e.Values.label, M3e.Component.Heading.size M3e.Values.large ] []), M3e.Component.NavMenuItem.component { label = M3e.text "Family" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "folder" ] []) ], M3e.Component.NavMenuItem.component { label = M3e.text "Wedding" } [] [ M3e.Component.NavMenuItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "folder" ] []) ] ] ]
```

<!-- elm-cem:docmeta category=Navigation -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.NavMenu
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-nav-menu` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.NavMenu.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.NavMenu.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.NavMenu.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.NavMenu.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.NavMenu.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.NavMenu.AttrCaps


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
    H.navMenu


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
