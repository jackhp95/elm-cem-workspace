module M3e.Component.TextareaAutosize exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , disabled, for, maxRows, minRows
    )

{-| The `m3e-textarea-autosize` component — strict per-component surface.

A non-visual element used to automatically resize a `textarea` to fit its content.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs disabled, for, maxRows, minRows


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.filled ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "field" ] [ M3e.text "Textarea Autosize" ]), TypedHtml.textarea [ TypedHtml.Unsafe.Attributes.customAttribute "id" "field" ] [ M3e.text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat." ] ]
    , M3e.Component.TextareaAutosize.component [ M3e.Component.TextareaAutosize.for "field" ] []
    ]
```

<!-- elm-cem:example title="Min and max rows" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.filled ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "field2" ] [ M3e.text "Textarea Autosize" ]), TypedHtml.textarea [ TypedHtml.Unsafe.Attributes.customAttribute "id" "field2" ] [ M3e.text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat." ] ]
    , M3e.Component.TextareaAutosize.component [ M3e.Component.TextareaAutosize.for "field2", M3e.Component.TextareaAutosize.maxRows 5 ] []
    ]
```

<!-- elm-cem:example title="Disabling" -->
```elm
M3e.Component.TextareaAutosize.component [ M3e.Component.TextareaAutosize.for "field", M3e.Component.TextareaAutosize.disabled True ] []
```

<!-- elm-cem:docmeta category=Text inputs -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.TextareaAutosize
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-textarea-autosize` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.TextareaAutosize.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.TextareaAutosize.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.TextareaAutosize.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.TextareaAutosize.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.TextareaAutosize.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.textareaAutosize


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| See `M3e.Attributes.maxRows`.
-}
maxRows : Float -> Attr { c | maxRows : Supported } msg
maxRows =
    A.maxRows


{-| See `M3e.Attributes.minRows`.
-}
minRows : Float -> Attr { c | minRows : Supported } msg
minRows =
    A.minRows
