module MiniM3e exposing
    ( M3eBrand
    , M3eCtx
    , VariantValues
    , asButton
    , button
    , chip
    , dense
    , filled
    , icon
    , modal
    , placeIcon
    , tonal
    , variant
    )

{-| A hand-written stand-in for the GENERATED m3e brand, depending on the IR
ONLY (never on MiniNative) yet interoperating with native content on the one
shared `Element` type. Exercises: brand-private kind/context markers, typed
enum values, named-slot placement and kind-recast as lever compositions.
-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as I
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)


{-| The m3e brand's private kind marker.
-}
type M3eBrand
    = M3eBrand


{-| The m3e brand's private context marker.
-}
type M3eCtx
    = M3eCtx


{-| The union of variant values this mini-brand admits (a general-surface
setter closes over the union; a per-component setter would close tighter).
-}
type alias VariantValues =
    { filled : Supported, tonal : Supported }


{-| Component with a closed attrs row (incl. the shared `class` field and the
interactive `onClick` capability) and a closed slot row admitting shared text
atoms and m3e icons.
-}
button :
    List (Attr { class : Supported, variant : Supported, onClick : Supported } msg)
    -> List (Element { sharedText : Shared, icon : M3eBrand } { childAdm | m3eButton : M3eCtx } msg)
    -> Element { acc | button : M3eBrand } admittedBy msg
button attrs children =
    I.fromNode (I.node "m3e-button" attrs (List.map HtmlIr.Element.toNode children))


{-| Brand-private kind producer.
-}
icon : String -> Element { acc | icon : M3eBrand } admittedBy msg
icon name =
    I.fromNode (I.node "m3e-icon" [] [ I.text name ])


{-| A second brand kind, to exercise `asButton` (recast).
-}
chip : String -> Element { acc | chip : M3eBrand } admittedBy msg
chip label =
    I.fromNode (I.node "m3e-chip" [] [ I.text label ])


{-| Kind-permissive container demanding the m3e `modal` context — the field
name deliberately collides with MiniNative's `modal` context (privacy probe).
-}
modal :
    List (Element childAccepts { childAdm | modal : M3eCtx } msg)
    -> Element { acc | modal : M3eBrand } admittedBy msg
modal children =
    I.fromNode (I.node "m3e-dialog" [] (List.map HtmlIr.Element.toNode children))


{-| Typed enum setter: closed value row (the union), open capability row.
-}
variant : Value VariantValues -> Attr { c | variant : Supported } msg
variant v =
    I.attribute "variant" (HtmlIr.Value.toString v)


{-| Enum token, open tag row.
-}
filled : Value { v | filled : Supported }
filled =
    I.token "filled"


{-| Enum token, open tag row.
-}
tonal : Value { v | tonal : Supported }
tonal =
    I.token "tonal"


{-| A token from a DIFFERENT enum — must be rejected by `variant`.
-}
dense : Value { v | dense : Supported }
dense =
    I.token "dense"


{-| Named-slot placement as a LEVER COMPOSITION
(`fromNode << addAttribute slot << toNode`): input constrained to the slot's
kind for guidance, output row FREE so it composes into the container's single
child list.
-}
placeIcon : Element { acc | icon : M3eBrand } admittedBy msg -> Element free freeAdmittedBy msg
placeIcon el =
    I.fromNode (I.addAttribute (I.attribute "slot" "icon") (HtmlIr.Element.toNode el))


{-| A hand-rolled `recast` as a LEVER COMPOSITION (`fromNode << toNode`) — the
one loud re-brand concept, proving it needs nothing beyond the IR's own verbs.
-}
asButton : Element { acc | chip : M3eBrand } admittedBy msg -> Element { acc2 | button : M3eBrand } admittedBy2 msg
asButton el =
    I.fromNode (HtmlIr.Element.toNode el)
