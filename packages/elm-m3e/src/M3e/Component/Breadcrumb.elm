module M3e.Component.Breadcrumb exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , wrap
    , separator, child
    )

{-| The `m3e-breadcrumb` component — strict per-component surface.

Displays a hierarchical navigation path and identifies the user's
current location within an application.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs wrap
@docs separator, child


## Examples


### Examples

<!-- elm-cem:example title="Anatomy" -->
```elm
M3e.Component.Breadcrumb.component { content = M3e.Component.BreadcrumbItem.component [] [ M3e.text "Dashboard" ] } [] [ M3e.Component.BreadcrumbItem.component [] [ M3e.text "Reports" ], M3e.Component.BreadcrumbItem.component [] [ M3e.text "Annual" ] ]
```

<!-- elm-cem:example title="Links" -->
```elm
M3e.Component.Breadcrumb.component { content = M3e.Component.BreadcrumbItem.component [ M3e.Component.BreadcrumbItem.href "https://developer.mozilla.org/en-US/docs/Web", M3e.Component.BreadcrumbItem.target "_blank" ] [ M3e.text "Web" ] } [] []
```

<!-- elm-cem:example title="Icons" -->
```elm
M3e.Component.Breadcrumb.component { content = M3e.Component.BreadcrumbItem.component [ M3e.Component.BreadcrumbItem.itemLabel "Dashboard" ] [ M3e.Component.Icon.component [ M3e.Component.Icon.name "dashboard" ] [] ] } [] [ M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "analytics" ] []), M3e.text "Reports" ], M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_month" ] []), M3e.text "Annual" ] ]
```

<!-- elm-cem:example title="Custom separators" -->
```elm
M3e.Component.Breadcrumb.component { content = M3e.Component.BreadcrumbItem.component [] [ M3e.text "Dashboard" ] } [] [ M3e.Component.Breadcrumb.separator (TypedHtml.span [] [ M3e.text "/" ]), M3e.Component.BreadcrumbItem.component [] [ M3e.text "Reports" ], M3e.Component.BreadcrumbItem.component [] [ M3e.text "Annual" ] ]
```

<!-- elm-cem:example title="Wrapping" -->
```elm
M3e.Component.Breadcrumb.component { content = M3e.Component.BreadcrumbItem.component [] [ M3e.text "Lorem ipsum dolor sit amet" ] } [ M3e.Component.Breadcrumb.wrap True ] [ M3e.Component.BreadcrumbItem.component [] [ M3e.text "Consectetur adipiscing elit sed do" ], M3e.Component.BreadcrumbItem.component [] [ M3e.text "Tempor incididunt ut labore et dolore" ], M3e.Component.BreadcrumbItem.component [] [ M3e.text "Magna aliqua ut enim ad minim veniam" ], M3e.Component.BreadcrumbItem.component [] [ M3e.text "Quis nostrud exercitation ullamco laboris nisi ut aliquip" ] ]
```

<!-- elm-cem:example title="Density" -->
```elm
[ M3e.Component.Breadcrumb.component { content = M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "dashboard" ] []), M3e.text "Dashboard" ] } [ M3e.Attributes.class "density-3" ] [ M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "analytics" ] []), M3e.text "Reports" ], M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_month" ] []), M3e.text "Annual" ] ]
    , M3e.Component.Breadcrumb.component { content = M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "dashboard" ] []), M3e.text "Dashboard" ] } [ M3e.Attributes.class "density-2" ] [ M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "analytics" ] []), M3e.text "Reports" ], M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_month" ] []), M3e.text "Annual" ] ]
    , M3e.Component.Breadcrumb.component { content = M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "dashboard" ] []), M3e.text "Dashboard" ] } [ M3e.Attributes.class "density-1" ] [ M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "analytics" ] []), M3e.text "Reports" ], M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_month" ] []), M3e.text "Annual" ] ]
    , M3e.Component.Breadcrumb.component { content = M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "dashboard" ] []), M3e.text "Dashboard" ] } [ M3e.Attributes.class "density-0" ] [ M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "analytics" ] []), M3e.text "Reports" ], M3e.Component.BreadcrumbItem.component [] [ M3e.Component.BreadcrumbItem.icon (M3e.Component.Icon.component [ M3e.Component.Icon.name "calendar_month" ] []), M3e.text "Annual" ] ]
    ]
```

<!-- elm-cem:docmeta category=Navigation -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Breadcrumb
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-breadcrumb` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Breadcrumb.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Breadcrumb.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Breadcrumb.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Breadcrumb.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Breadcrumb.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Breadcrumb.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.Breadcrumb.SlotCaps


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    H.breadcrumb attrs (required_.content :: children)


{-| See `M3e.Attributes.wrap`.
-}
wrap : Bool -> Attr { c | wrap : Supported } msg
wrap =
    A.wrap


{-| Place an element into the named `separator` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
separator : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
separator element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "separator") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
