module M3e.Component.AppBar exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, LeadingSlot, SubtitleSlot, TitleSlot, TrailingSlot, ChildAdmittedBy
    , Size, size
    , centered, for
    , leading, leadingIcon, subtitle, title, trailing, trailingIcon
    )

{-| The `m3e-app-bar` component — strict per-component surface.

A bar, placed a the top of a screen, used to help users navigate through an application.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, LeadingSlot, SubtitleSlot, TitleSlot, TrailingSlot, ChildAdmittedBy
@docs Size, size
@docs centered, for
@docs leading, leadingIcon, subtitle, title, trailing, trailingIcon


## Examples


### Examples

<!-- elm-cem:example title="Anatomy" -->
```elm
M3e.Component.AppBar.component [] [ M3e.Component.AppBar.leading (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_back" ] [], ariaLabel = "Back", action = M3e.Action.none } [] []), M3e.Component.AppBar.title (M3e.text "Top 10 hiking trails"), M3e.Component.AppBar.subtitle (M3e.text "Discover popular trails"), M3e.Component.AppBar.trailing (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "bookmark", M3e.Component.Icon.filled True ] [], ariaLabel = "Bookmark", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal ] []) ]
```

<!-- elm-cem:example title="Sizes" -->
```elm
M3e.Component.AppBar.component [ M3e.Component.AppBar.size M3e.Values.medium ] [ M3e.Component.AppBar.leading (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_back" ] [], ariaLabel = "Back", action = M3e.Action.none } [] []), M3e.Component.AppBar.title (M3e.text "Top 10 hiking trails"), M3e.Component.AppBar.subtitle (M3e.text "Discover popular trails"), M3e.Component.AppBar.trailing (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "bookmark", M3e.Component.Icon.filled True ] [], ariaLabel = "Bookmark", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal ] []) ]
```

<!-- elm-cem:example title="Sizes (2)" -->
```elm
M3e.Component.AppBar.component [ M3e.Component.AppBar.size M3e.Values.large ] [ M3e.Component.AppBar.leading (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_back" ] [], ariaLabel = "Back", action = M3e.Action.none } [] []), M3e.Component.AppBar.title (M3e.text "Top 10 hiking trails"), M3e.Component.AppBar.subtitle (M3e.text "Discover popular trails"), M3e.Component.AppBar.trailing (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "bookmark", M3e.Component.Icon.filled True ] [], ariaLabel = "Bookmark", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal ] []) ]
```

<!-- elm-cem:example title="Centered" -->
```elm
M3e.Component.AppBar.component [ M3e.Component.AppBar.centered True ] [ M3e.Component.AppBar.leading (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_back" ] [], ariaLabel = "Back", action = M3e.Action.none } [] []), M3e.Component.AppBar.title (M3e.text "Top 10 hiking trails"), M3e.Component.AppBar.subtitle (M3e.text "Discover popular trails"), M3e.Component.AppBar.trailing (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "bookmark" ] [], ariaLabel = "Bookmark", action = M3e.Action.none } [] []), M3e.Component.AppBar.trailing (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "help" ] [], ariaLabel = "help", action = M3e.Action.none } [] []) ]
```

<!-- elm-cem:example title="Scroll effects" -->
```elm
TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "id" "scrollContainer" ] [ M3e.Component.AppBar.component [ M3e.Component.AppBar.for "scrollContainer" ] [ M3e.Component.AppBar.leading (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_back" ] [], ariaLabel = "Back", action = M3e.Action.none } [] []), M3e.Component.AppBar.title (M3e.text "Top 10 hiking trails"), M3e.Component.AppBar.subtitle (M3e.text "Discover popular trails"), M3e.Component.AppBar.trailing (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "bookmark", M3e.Component.Icon.filled True ] [], ariaLabel = "Bookmark", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal ] []) ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "scroll-item" ] [ M3e.text "Scroll down to see the elevation effect" ] ]
```

<!-- elm-cem:docmeta category=Navigation -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.AppBar
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-app-bar` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.AppBar.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.AppBar.Attrs


{-| The kinds the `leading` slot admits.
-}
type alias LeadingSlot =
    M3e.Internal.Types.AppBar.LeadingSlot


{-| The kinds the `subtitle` slot admits.
-}
type alias SubtitleSlot =
    M3e.Internal.Types.AppBar.SubtitleSlot


{-| The kinds the `title` slot admits.
-}
type alias TitleSlot =
    M3e.Internal.Types.AppBar.TitleSlot


{-| The kinds the `trailing` slot admits.
-}
type alias TrailingSlot =
    M3e.Internal.Types.AppBar.TrailingSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.AppBar.ChildAdmittedBy childAdm


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    M3e.Internal.Types.AppBar.Size


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.AppBar.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.AppBar.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.AppBar.SlotCaps


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.appBar


{-| The size of the bar. (default: `"small"`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| See `M3e.Attributes.centered`.
-}
centered : Bool -> Attr { c | centered : Supported } msg
centered =
    A.centered


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| Place an element into the named `leading` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
leading : Element LeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
leading element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "leading") (El.toNode element))


{-| Place an element into the named `leading-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
leadingIcon : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
leadingIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "leading-icon") (El.toNode element))


{-| Place an element into the named `subtitle` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
subtitle : Element SubtitleSlot admittedBy msg -> Element free freeAdmittedBy msg
subtitle element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "subtitle") (El.toNode element))


{-| Place an element into the named `title` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
title : Element TitleSlot admittedBy msg -> Element free freeAdmittedBy msg
title element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "title") (El.toNode element))


{-| Place an element into the named `trailing` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
trailing : Element TrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
trailing element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing") (El.toNode element))


{-| Place an element into the named `trailing-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
trailingIcon : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
trailingIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing-icon") (El.toNode element))
