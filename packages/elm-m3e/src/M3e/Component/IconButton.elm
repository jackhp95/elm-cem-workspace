module M3e.Component.IconButton exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, SelectedSlot, ChildAdmittedBy, ActionCaps
    , Shape, shape, Size, size, Type, type_, Variant, variant, Width, width
    , disabled, disabledInteractive, download, href, name, rel, target, toggle, value, defaultValue, onBeforeinput, onInput, onChange, onClick
    , selected, child
    )

{-| The `m3e-icon-button` component — strict per-component surface.

An icon button users interact with to perform a supplementary action.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, SelectedSlot, ChildAdmittedBy, ActionCaps
@docs Shape, shape, Size, size, Type, type_, Variant, variant, Width, width
@docs disabled, disabledInteractive, download, href, name, rel, target, toggle, value, defaultValue, onBeforeinput, onInput, onChange, onClick
@docs selected, child


## Examples


### Variants

<!-- elm-cem:example title="Variants" -->
```elm
[ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.filled ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "search" ] [], ariaLabel = "Search", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.outlined ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "settings" ] [], ariaLabel = "Settings", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.standard ] []
    ]
```

<!-- elm-cem:example title="Shapes" -->
```elm
[ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.shape M3e.Values.square ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.shape M3e.Values.square ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "search" ] [], ariaLabel = "Search", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.outlined, M3e.Component.IconButton.shape M3e.Values.square ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "settings" ] [], ariaLabel = "Settings", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.standard, M3e.Component.IconButton.shape M3e.Values.square ] []
    ]
```

<!-- elm-cem:example title="Toggle" -->
```elm
[ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.toggle True ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.toggle True ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "search" ] [], ariaLabel = "Search", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.outlined, M3e.Component.IconButton.toggle True ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "settings" ] [], ariaLabel = "Settings", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.standard, M3e.Component.IconButton.toggle True ] []
    ]
```


### Sizes

<!-- elm-cem:example title="Sizes" -->
```elm
[ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.size M3e.Values.extraSmall ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.size M3e.Values.small ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.size M3e.Values.medium ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.size M3e.Values.large ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.size M3e.Values.extraLarge ] []
    ]
```


### Width

<!-- elm-cem:example title="Widths" -->
```elm
[ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.width M3e.Values.narrow ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.width M3e.Values.wide ] []
    ]
```


### Examples

<!-- elm-cem:example title="Toggle (2)" -->
```elm
M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "close" ] [], ariaLabel = "Close", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.toggle True ] [ M3e.Component.IconButton.selected (M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] []) ]
```

<!-- elm-cem:example title="Toggle (3)" -->
```elm
[ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.shape M3e.Values.rounded, M3e.Component.IconButton.toggle True ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.shape M3e.Values.rounded, M3e.Component.IconButton.toggle True ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "search" ] [], ariaLabel = "Search", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.outlined, M3e.Component.IconButton.shape M3e.Values.rounded, M3e.Component.IconButton.toggle True ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "settings" ] [], ariaLabel = "Settings", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.standard, M3e.Component.IconButton.shape M3e.Values.rounded, M3e.Component.IconButton.toggle True ] []
    , TypedHtml.br [] []
    , TypedHtml.br [] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.shape M3e.Values.square, M3e.Component.IconButton.toggle True ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "add" ] [], ariaLabel = "Add", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.shape M3e.Values.square, M3e.Component.IconButton.toggle True ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "search" ] [], ariaLabel = "Search", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.outlined, M3e.Component.IconButton.shape M3e.Values.square, M3e.Component.IconButton.toggle True ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "settings" ] [], ariaLabel = "Settings", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.standard, M3e.Component.IconButton.shape M3e.Values.square, M3e.Component.IconButton.toggle True ] []
    ]
```

<!-- elm-cem:example title="Disabling" -->
```elm
[ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.disabled True ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.disabledInteractive True ] []
    ]
```

<!-- elm-cem:example title="Links" -->
```elm
M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "open_in_new_window" ] [], ariaLabel = "Open in new window", action = M3e.Action.none } [ M3e.Component.IconButton.variant M3e.Values.tonal, M3e.Component.IconButton.href "https://www.google.com", M3e.Component.IconButton.target "_blank" ] []
```

<!-- elm-cem:example title="Density" -->
```elm
[ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Attributes.class "density-3", M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.size M3e.Values.extraSmall ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Attributes.class "density-2", M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.size M3e.Values.extraSmall ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Attributes.class "density-1", M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.size M3e.Values.extraSmall ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Attributes.class "density-0", M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.size M3e.Values.extraSmall ] []
    ]
```

<!-- elm-cem:example title="Density (2)" -->
```elm
[ M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Attributes.class "density-3", M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.size M3e.Values.small ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Attributes.class "density-2", M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.size M3e.Values.small ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Attributes.class "density-1", M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.size M3e.Values.small ] []
    , M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "check" ] [], ariaLabel = "Check", action = M3e.Action.none } [ M3e.Attributes.class "density-0", M3e.Component.IconButton.variant M3e.Values.filled, M3e.Component.IconButton.size M3e.Values.small ] []
    ]
```

<!-- elm-cem:docmeta category=Actions -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Action as Ac
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.IconButton
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-icon-button` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.IconButton.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.IconButton.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.IconButton.Content


{-| The kinds the `selected` slot admits.
-}
type alias SelectedSlot =
    M3e.Internal.Types.IconButton.SelectedSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.IconButton.ChildAdmittedBy childAdm


{-| The `shape` values valid on this component (compile-tight narrowing).
-}
type alias Shape =
    M3e.Internal.Types.IconButton.Shape


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    M3e.Internal.Types.IconButton.Size


{-| The `type_` values valid on this component (compile-tight narrowing).
-}
type alias Type =
    M3e.Internal.Types.IconButton.Type


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.IconButton.Variant


{-| The `width` values valid on this component (compile-tight narrowing).
-}
type alias Width =
    M3e.Internal.Types.IconButton.Width


{-| The behaviours this component's required action admits (see `M3e.Action`).
-}
type alias ActionCaps =
    M3e.Internal.Types.IconButton.ActionCaps


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.IconButton.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.IconButton.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.IconButton.SlotCaps


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { content : Element Content (ChildAdmittedBy childAdm) msg
    , ariaLabel : String
    , action : Ac.Action ActionCaps msg
    }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    let
        actioned =
            Ir.fromNode (Ac.wrapContent required_.action (El.toNode required_.content))
    in
    H.iconButton
        (Ir.attribute "aria-label" required_.ariaLabel :: Ac.toAttrs required_.action ++ attrs)
        (actioned :: children)


{-| The shape of the button. (default: `"rounded"`)
-}
shape : Value Shape -> Attr { c | shape : Supported } msg
shape value_ =
    Ir.attribute "shape" (Val.toString value_)


{-| The size of the button. (default: `"small"`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| The type of the element. (default: `"button"`)
-}
type_ : Value Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (Val.toString value_)


{-| The appearance variant of the button. (default: `"standard"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| The width of the button. (default: `"default"`)
-}
width : Value Width -> Attr { c | width : Supported } msg
width value_ =
    Ir.attribute "width" (Val.toString value_)


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.disabledInteractive`.
-}
disabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
disabledInteractive =
    A.disabledInteractive


{-| See `M3e.Attributes.download`.
-}
download : String -> Attr { c | download : Supported } msg
download =
    A.download


{-| See `M3e.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    A.href


{-| The name of the element, submitted as a pair with the element's `value` as part of form data, when the element is used to submit a form.
-}
name : String -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" value_


{-| See `M3e.Attributes.rel`.
-}
rel : String -> Attr { c | rel : Supported } msg
rel =
    A.rel


{-| See `M3e.Attributes.target`.
-}
target : String -> Attr { c | target : Supported } msg
target =
    A.target


{-| See `M3e.Attributes.toggle`.
-}
toggle : Bool -> Attr { c | toggle : Supported } msg
toggle =
    A.toggle


{-| See `M3e.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    A.value


{-| See `M3e.Attributes.defaultValue`.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    A.defaultValue


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


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `M3e.Events.onClick`.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick =
    Ev.onClick


{-| Place an element into the named `selected` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
selected : Element SelectedSlot admittedBy msg -> Element free freeAdmittedBy msg
selected element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "selected") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
