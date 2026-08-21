module M3e.Element.NavMenu exposing
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
M3e.Element.NavMenu.component [] [ M3e.Element.NavMenuItem.component { label = M3e.text "Getting Started" } [ M3e.Element.NavMenuItem.open True ] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "rocket_launch", TypedHtml.Unsafe.Attributes.customAttribute "aria-hidden" "true" ] []), M3e.Element.NavMenuItem.component { label = M3e.text "Overview" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "widgets", TypedHtml.Unsafe.Attributes.customAttribute "aria-hidden" "true" ] []) ], M3e.Element.NavMenuItem.component { label = M3e.text "Installation" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "package_2", TypedHtml.Unsafe.Attributes.customAttribute "aria-hidden" "true" ] []) ] ], M3e.Element.NavMenuItem.component { label = M3e.text "Actions" } [] [ M3e.Element.NavMenuItem.component { label = M3e.text "Button" } [] [], M3e.Element.NavMenuItem.component { label = M3e.text "Icon" } [] [], M3e.Element.NavMenuItem.component { label = M3e.text "Icon Button" } [] [] ] ]
```

<!-- elm-cem:example title="Grouping top-level items" -->
```elm
M3e.Element.NavMenu.component [] [ M3e.Element.NavMenuItemGroup.component [] [ M3e.Element.NavMenuItemGroup.label (M3e.Element.Heading.component { content = M3e.text "Mail" } [ M3e.Element.Heading.tocIgnore True, M3e.Element.Heading.variant M3e.Values.label, M3e.Element.Heading.size M3e.Values.large ] []), M3e.Element.NavMenuItem.component { label = M3e.text "Inbox" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "mail" ] []), M3e.Element.NavMenuItem.badge (M3e.text "24") ], M3e.Element.NavMenuItem.component { label = M3e.text "Outbox" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "send" ] []) ], M3e.Element.NavMenuItem.component { label = M3e.text "Favorites" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "favorite" ] []) ], M3e.Element.NavMenuItem.component { label = M3e.text "Trash" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "delete" ] []) ] ], M3e.Element.Divider.component [] [], M3e.Element.NavMenuItemGroup.component [] [ M3e.Element.NavMenuItemGroup.label (M3e.Element.Heading.component { content = M3e.text "Personal folders" } [ M3e.Element.Heading.tocIgnore True, M3e.Element.Heading.variant M3e.Values.label, M3e.Element.Heading.size M3e.Values.large ] []), M3e.Element.NavMenuItem.component { label = M3e.text "Family" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "folder" ] []) ], M3e.Element.NavMenuItem.component { label = M3e.text "Wedding" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "folder" ] []) ] ] ]
```

<!-- elm-cem:example title="Disabling" -->
```elm
M3e.Element.NavMenu.component [] [ M3e.Element.NavMenuItem.component { label = M3e.text "Getting Started" } [ M3e.Element.NavMenuItem.open True, M3e.Element.NavMenuItem.disabled True ] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "rocket_launch", TypedHtml.Unsafe.Attributes.customAttribute "aria-hidden" "true" ] []), M3e.Element.NavMenuItem.component { label = M3e.text "Overview" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "widgets", TypedHtml.Unsafe.Attributes.customAttribute "aria-hidden" "true" ] []) ], M3e.Element.NavMenuItem.component { label = M3e.text "Installation" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "package_2", TypedHtml.Unsafe.Attributes.customAttribute "aria-hidden" "true" ] []) ] ], M3e.Element.NavMenuItem.component { label = M3e.text "Actions" } [ M3e.Element.NavMenuItem.open True ] [ M3e.Element.NavMenuItem.component { label = M3e.text "Button" } [ M3e.Element.NavMenuItem.disabled True ] [], M3e.Element.NavMenuItem.component { label = M3e.text "Icon" } [] [], M3e.Element.NavMenuItem.component { label = M3e.text "Icon Button" } [] [] ] ]
```

<!-- elm-cem:example title="Density" -->
```elm
M3e.Element.NavMenu.component [ M3e.Attributes.class "density-3" ] [ M3e.Element.NavMenuItemGroup.component [] [ M3e.Element.NavMenuItemGroup.label (M3e.Element.Heading.component { content = M3e.text "Mail" } [ M3e.Element.Heading.tocIgnore True, M3e.Element.Heading.variant M3e.Values.label, M3e.Element.Heading.size M3e.Values.large ] []), M3e.Element.NavMenuItem.component { label = M3e.text "Inbox" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "mail" ] []), M3e.Element.NavMenuItem.badge (M3e.text "24") ], M3e.Element.NavMenuItem.component { label = M3e.text "Outbox" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "send" ] []) ], M3e.Element.NavMenuItem.component { label = M3e.text "Favorites" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "favorite" ] []) ], M3e.Element.NavMenuItem.component { label = M3e.text "Trash" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "delete" ] []) ] ], M3e.Element.Divider.component [] [], M3e.Element.NavMenuItemGroup.component [] [ M3e.Element.NavMenuItemGroup.label (M3e.Element.Heading.component { content = M3e.text "Personal folders" } [ M3e.Element.Heading.tocIgnore True, M3e.Element.Heading.variant M3e.Values.label, M3e.Element.Heading.size M3e.Values.large ] []), M3e.Element.NavMenuItem.component { label = M3e.text "Family" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "folder" ] []) ], M3e.Element.NavMenuItem.component { label = M3e.text "Wedding" } [] [ M3e.Element.NavMenuItem.icon (M3e.Element.Icon.component [ M3e.Element.Icon.name "folder" ] []) ] ] ]
```

<!-- elm-cem:docmeta category=Navigation; figmaUrl=https://www.figma.com/design/UtwpUdPiOZEuxp8Nq1d5yQ/Material-3-Design-Kit--Community-?node-id=51593-5827; figmaStatus=example-verified -->

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
