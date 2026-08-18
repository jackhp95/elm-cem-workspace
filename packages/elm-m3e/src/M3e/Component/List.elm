module M3e.Component.List exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , Variant, variant
    , child
    )

{-| The `m3e-list` component — strict per-component surface.

A list of items.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs Variant, variant
@docs child


## Examples


### Examples

<!-- elm-cem:example title="Anatomy" -->
```elm
M3e.Component.List.component [] [ M3e.Component.ListItem.component [] [ M3e.Component.ListItem.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "person" ] []), M3e.Component.ListItem.overline (M3e.text "Overline"), M3e.text "Headline", M3e.Component.ListItem.supportingText (M3e.text "Supporting text"), M3e.Component.ListItem.trailing (M3e.text "100+") ] ]
```

<!-- elm-cem:example title="Variants" -->
```elm
M3e.Component.List.component [] [ M3e.Component.ListItem.component [] [ M3e.text "Item 1" ], M3e.Component.ListItem.component [] [ M3e.text "Item 2" ], M3e.Component.ListItem.component [] [ M3e.text "Item 3" ] ]
```

<!-- elm-cem:example title="Variants (2)" -->
```elm
M3e.Component.List.component [ M3e.Component.List.variant M3e.Values.segmented ] [ M3e.Component.ListItem.component [] [ M3e.text "Item 1" ], M3e.Component.ListItem.component [] [ M3e.text "Item 2" ], M3e.Component.ListItem.component [] [ M3e.text "Item 3" ] ]
```

<!-- elm-cem:example title="Multiline items" -->
```elm
M3e.Component.List.component [] [ M3e.Component.ListItem.component [] [ M3e.text "Label text" ], M3e.Component.ListItem.component [] [ M3e.text "Label text", M3e.Component.ListItem.supportingText (M3e.text "Supporting text") ], M3e.Component.ListItem.component [] [ M3e.Component.ListItem.overline (M3e.text "Overline"), M3e.text "Label text", M3e.Component.ListItem.supportingText (M3e.text "Supporting text") ] ]
```

<!-- elm-cem:example title="Media content" -->
```elm
M3e.Component.List.component [] [ M3e.Component.ListItem.component [] [ M3e.Component.ListItem.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Label text", M3e.Component.ListItem.trailing (M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_right" ] []) ], M3e.Component.ListItem.component [] [ M3e.Component.ListItem.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "Label text", M3e.Component.ListItem.supportingText (M3e.text "Supporting text"), M3e.Component.ListItem.trailing (M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_right" ] []) ], M3e.Component.ListItem.component [] [ M3e.Component.ListItem.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.Component.ListItem.overline (M3e.text "Overline"), M3e.text "Label text", M3e.Component.ListItem.supportingText (M3e.text "Supporting text"), M3e.Component.ListItem.trailing (M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_right" ] []) ], M3e.Component.ListItem.component [] [ M3e.text "Label text" ] ]
```

<!-- elm-cem:example title="Media content (2)" -->
```elm
M3e.Component.List.component [] [ M3e.Component.ListItem.component [] [ M3e.Component.ListItem.leading (M3e.Component.Avatar.component [] [ M3e.text "AB" ]), M3e.text "Label text", M3e.Component.ListItem.trailing (M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_right" ] []) ], M3e.Component.ListItem.component [] [ M3e.Component.ListItem.leading (M3e.Component.Avatar.component [] [ M3e.text "AB" ]), M3e.text "Label text", M3e.Component.ListItem.supportingText (M3e.text "Supporting text"), M3e.Component.ListItem.trailing (M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_right" ] []) ], M3e.Component.ListItem.component [] [ M3e.Component.ListItem.leading (M3e.Component.Avatar.component [] [ M3e.text "AB" ]), M3e.Component.ListItem.overline (M3e.text "Overline"), M3e.text "Label text", M3e.Component.ListItem.supportingText (M3e.text "Supporting text"), M3e.Component.ListItem.trailing (M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_right" ] []) ], M3e.Component.ListItem.component [] [ M3e.text "Label text" ] ]
```

<!-- elm-cem:example title="Media content (4)" -->
```elm
M3e.Component.List.component [] [ M3e.Component.ListItem.component [] [ M3e.Component.ListItem.leading (TypedHtml.video [ TypedHtml.Unsafe.Attributes.customAttribute "autoplay" "", TypedHtml.Unsafe.Attributes.customAttribute "loop" "", TypedHtml.Unsafe.Attributes.customAttribute "poster" "https://www.shutterstock.com/shutterstock/videos/1006393/thumb/1.jpg?ip=x480", TypedHtml.Unsafe.Attributes.customAttribute "preload" "auto" ] [ TypedHtml.source [ TypedHtml.Unsafe.Attributes.customAttribute "src" "https://www.shutterstock.com/shutterstock/videos/1006393/preview/stock-footage-business-people-working-in-office.webm", TypedHtml.Unsafe.Attributes.customAttribute "type" "video/webm" ] [], TypedHtml.source [ TypedHtml.Unsafe.Attributes.customAttribute "src" "https://www.shutterstock.com/shutterstock/videos/1006393/preview/stock-footage-business-people-working-in-office.mp4", TypedHtml.Unsafe.Attributes.customAttribute "type" "video/mp4" ] [] ]), M3e.text "Label text", M3e.Component.ListItem.trailing (M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_right" ] []) ], M3e.Component.ListItem.component [] [ M3e.Component.ListItem.leading (TypedHtml.video [ TypedHtml.Unsafe.Attributes.customAttribute "autoplay" "", TypedHtml.Unsafe.Attributes.customAttribute "loop" "", TypedHtml.Unsafe.Attributes.customAttribute "poster" "https://www.shutterstock.com/shutterstock/videos/1006393/thumb/1.jpg?ip=x480", TypedHtml.Unsafe.Attributes.customAttribute "preload" "auto" ] [ TypedHtml.source [ TypedHtml.Unsafe.Attributes.customAttribute "src" "https://www.shutterstock.com/shutterstock/videos/1006393/preview/stock-footage-business-people-working-in-office.webm", TypedHtml.Unsafe.Attributes.customAttribute "type" "video/webm" ] [], TypedHtml.source [ TypedHtml.Unsafe.Attributes.customAttribute "src" "https://www.shutterstock.com/shutterstock/videos/1006393/preview/stock-footage-business-people-working-in-office.mp4", TypedHtml.Unsafe.Attributes.customAttribute "type" "video/mp4" ] [] ]), M3e.text "Label text", M3e.Component.ListItem.supportingText (M3e.text "Supporting text"), M3e.Component.ListItem.trailing (M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_right" ] []) ], M3e.Component.ListItem.component [] [ M3e.Component.ListItem.leading (TypedHtml.video [ TypedHtml.Unsafe.Attributes.customAttribute "autoplay" "", TypedHtml.Unsafe.Attributes.customAttribute "loop" "", TypedHtml.Unsafe.Attributes.customAttribute "poster" "https://www.shutterstock.com/shutterstock/videos/1006393/thumb/1.jpg?ip=x480", TypedHtml.Unsafe.Attributes.customAttribute "preload" "auto" ] [ TypedHtml.source [ TypedHtml.Unsafe.Attributes.customAttribute "src" "https://www.shutterstock.com/shutterstock/videos/1006393/preview/stock-footage-business-people-working-in-office.webm", TypedHtml.Unsafe.Attributes.customAttribute "type" "video/webm" ] [], TypedHtml.source [ TypedHtml.Unsafe.Attributes.customAttribute "src" "https://www.shutterstock.com/shutterstock/videos/1006393/preview/stock-footage-business-people-working-in-office.mp4", TypedHtml.Unsafe.Attributes.customAttribute "type" "video/mp4" ] [] ]), M3e.Component.ListItem.overline (M3e.text "Overline"), M3e.text "Label text", M3e.Component.ListItem.supportingText (M3e.text "Supporting text"), M3e.Component.ListItem.trailing (M3e.Component.Icon.component [ M3e.Component.Icon.name "arrow_right" ] []) ], M3e.Component.ListItem.component [] [ M3e.text "Label text" ] ]
```

<!-- elm-cem:example title="Dividers" -->
```elm
M3e.Component.List.component [] [ M3e.Component.ListItem.component [] [ M3e.text "Item 1" ], M3e.Component.Divider.component [] [], M3e.Component.ListItem.component [] [ M3e.text "Item 2" ], M3e.Component.Divider.component [] [], M3e.Component.ListItem.component [] [ M3e.text "Item 3" ] ]
```

<!-- elm-cem:example title="Dividers (2)" -->
```elm
M3e.Component.List.component [] [ M3e.Component.ListItem.component [] [ M3e.text "Item 1" ], M3e.Component.Divider.component [ M3e.Component.Divider.inset True ] [], M3e.Component.ListItem.component [] [ M3e.text "Item 2" ], M3e.Component.Divider.component [ M3e.Component.Divider.inset True ] [], M3e.Component.ListItem.component [] [ M3e.text "Item 3" ] ]
```

<!-- elm-cem:example title="Action lists" -->
```elm
M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [] [ M3e.text "Action 1" ], M3e.Component.ListAction.component [] [ M3e.text "Action 2" ], M3e.Component.ListAction.component [] [ M3e.text "Action 3" ] ]
```

<!-- elm-cem:example title="Action lists (2)" -->
```elm
M3e.Component.ActionList.component [ M3e.Component.ActionList.variant M3e.Values.segmented ] [ M3e.Component.ListAction.component [] [ M3e.text "Action 1" ], M3e.Component.ListAction.component [] [ M3e.text "Action 2" ], M3e.Component.ListAction.component [] [ M3e.text "Action 3" ] ]
```

<!-- elm-cem:example title="Disabling" -->
```elm
M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [ M3e.Component.ListAction.disabled True ] [ M3e.text "Disabled action 1" ], M3e.Component.ListAction.component [] [ M3e.text "Action 2" ], M3e.Component.ListAction.component [] [ M3e.text "Action 3" ] ]
```

<!-- elm-cem:example title="Disabling (2)" -->
```elm
M3e.Component.ActionList.component [ M3e.Component.ActionList.variant M3e.Values.segmented ] [ M3e.Component.ListAction.component [ M3e.Component.ListAction.disabled True ] [ M3e.text "Disabled action 1" ], M3e.Component.ListAction.component [] [ M3e.text "Action 2" ], M3e.Component.ListAction.component [] [ M3e.text "Action 3" ] ]
```

<!-- elm-cem:example title="Links" -->
```elm
M3e.Component.ActionList.component [] [ M3e.Component.ListAction.component [ M3e.Component.ListAction.href "https://www.google.com", M3e.Component.ListAction.target "_blank" ] [ M3e.text "Google" ] ]
```

<!-- elm-cem:example title="Nested lists" -->
```elm
M3e.Component.ActionList.component [] [ M3e.Component.ExpandableListItem.component [] [ M3e.Component.ExpandableListItem.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item", M3e.Component.ExpandableListItem.items (TypedHtml.div [] [ M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ], M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ], M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ] ]) ], M3e.Component.ExpandableListItem.component [] [ M3e.Component.ExpandableListItem.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item", M3e.Component.ExpandableListItem.items (TypedHtml.div [] [ M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ], M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ], M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ] ]) ], M3e.Component.ExpandableListItem.component [] [ M3e.Component.ExpandableListItem.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item", M3e.Component.ExpandableListItem.items (TypedHtml.div [] [ M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ], M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ], M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ] ]) ] ]
```

<!-- elm-cem:example title="Nested lists (2)" -->
```elm
M3e.Component.ActionList.component [ M3e.Component.ActionList.variant M3e.Values.segmented ] [ M3e.Component.ExpandableListItem.component [] [ M3e.Component.ExpandableListItem.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item", M3e.Component.ExpandableListItem.items (TypedHtml.div [] [ M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ], M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ], M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ] ]) ], M3e.Component.ExpandableListItem.component [] [ M3e.Component.ExpandableListItem.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item", M3e.Component.ExpandableListItem.items (TypedHtml.div [] [ M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ], M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ], M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ] ]) ], M3e.Component.ExpandableListItem.component [] [ M3e.Component.ExpandableListItem.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item", M3e.Component.ExpandableListItem.items (TypedHtml.div [] [ M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ], M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ], M3e.Component.ListAction.component [] [ M3e.Component.ListAction.leading (M3e.Component.Icon.component [ M3e.Component.Icon.name "stars" ] []), M3e.text "List item" ] ]) ] ]
```

<!-- elm-cem:example title="Selection lists" -->
```elm
M3e.Component.SelectionList.component [] [ M3e.Component.ListOption.component [] [ M3e.text "Option 1" ], M3e.Component.ListOption.component [] [ M3e.text "Option 2" ], M3e.Component.ListOption.component [] [ M3e.text "Option 3" ] ]
```

<!-- elm-cem:example title="Selection lists (2)" -->
```elm
M3e.Component.SelectionList.component [ M3e.Component.SelectionList.variant M3e.Values.segmented ] [ M3e.Component.ListOption.component [] [ M3e.text "Option 1" ], M3e.Component.ListOption.component [] [ M3e.text "Option 2" ], M3e.Component.ListOption.component [] [ M3e.text "Option 3" ] ]
```

<!-- elm-cem:example title="Multiple selection" -->
```elm
M3e.Component.SelectionList.component [ M3e.Component.SelectionList.multi True ] [ M3e.Component.ListOption.component [] [ M3e.text "Option 1" ], M3e.Component.ListOption.component [] [ M3e.text "Option 2" ], M3e.Component.ListOption.component [] [ M3e.text "Option 3" ] ]
```

<!-- elm-cem:example title="Multiple selection (2)" -->
```elm
M3e.Component.SelectionList.component [ M3e.Component.SelectionList.variant M3e.Values.segmented, M3e.Component.SelectionList.multi True ] [ M3e.Component.ListOption.component [] [ M3e.text "Option 1" ], M3e.Component.ListOption.component [] [ M3e.text "Option 2" ], M3e.Component.ListOption.component [] [ M3e.text "Option 3" ] ]
```

<!-- elm-cem:example title="Hiding the selection indicator" -->
```elm
M3e.Component.SelectionList.component [ M3e.Component.SelectionList.multi True, M3e.Component.SelectionList.hideSelectionIndicator True ] [ M3e.Component.ListOption.component [ M3e.Component.ListOption.selected True ] [ M3e.text "Option 1", M3e.Component.ListOption.trailing (M3e.Component.Icon.component [ M3e.Component.Icon.name "bookmark" ] []) ], M3e.Component.ListOption.component [] [ M3e.text "Option 2", M3e.Component.ListOption.trailing (M3e.Component.Icon.component [ M3e.Component.Icon.name "bookmark" ] []) ], M3e.Component.ListOption.component [] [ M3e.text "Option 3", M3e.Component.ListOption.trailing (M3e.Component.Icon.component [ M3e.Component.Icon.name "bookmark" ] []) ] ]
```

<!-- elm-cem:example title="Disabling (3)" -->
```elm
M3e.Component.SelectionList.component [ M3e.Component.SelectionList.multi True ] [ M3e.Component.ListOption.component [ M3e.Component.ListOption.disabled True ] [ M3e.text "Option 1" ], M3e.Component.ListOption.component [ M3e.Component.ListOption.selected True, M3e.Component.ListOption.disabled True ] [ M3e.text "Option 2" ], M3e.Component.ListOption.component [] [ M3e.text "Option 3" ] ]
```

<!-- elm-cem:example title="Disabling (4)" -->
```elm
M3e.Component.SelectionList.component [ M3e.Component.SelectionList.variant M3e.Values.segmented, M3e.Component.SelectionList.multi True ] [ M3e.Component.ListOption.component [ M3e.Component.ListOption.disabled True ] [ M3e.text "Option 1" ], M3e.Component.ListOption.component [ M3e.Component.ListOption.selected True, M3e.Component.ListOption.disabled True ] [ M3e.text "Option 2" ], M3e.Component.ListOption.component [] [ M3e.text "Option 3" ] ]
```

<!-- elm-cem:example title="Density" -->
```elm
M3e.Component.SelectionList.component [ M3e.Attributes.class "density-3", M3e.Component.SelectionList.variant M3e.Values.segmented, M3e.Component.SelectionList.multi True ] [ M3e.Component.ListOption.component [] [ M3e.text "Option 1" ], M3e.Component.ListOption.component [] [ M3e.text "Option 2" ], M3e.Component.ListOption.component [] [ M3e.text "Option 3" ] ]
```

<!-- elm-cem:docmeta category=Layout & style -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.List
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-list` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.List.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.List.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.List.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.List.ChildAdmittedBy childAdm


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.List.Variant


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.List.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.List.AttrCaps


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
    H.list


{-| The appearance variant of the list. (default: `"standard"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
