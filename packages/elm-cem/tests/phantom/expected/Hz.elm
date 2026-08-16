module Hz exposing
    ( attrSlot, blocked, duplicate, errorOnly, eventClash, global, placement, hzCapitalText, textElement
    , text
    , slotHint, slotLabel
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId
    )

{-| The general surface: every component constructor in the elm/html call
shape, one import. Signatures reference each component's aliases — reach for
`Hz.<Component>` when you want the strict per-component surface (required
content, builder, narrowed values), and `Hz.Attributes` / `Hz.Events` /
`Hz.Values` for the shared vocabulary.

`toHtml` is the render bridge to `elm/html`.

The `slot<Name>` placers assign a child element to a named slot in any
component that accepts it. Admittance is open (broad row) — wrong-kind
placements are caught by `Cem.ValidSlotKind` (elm-review).

@docs attrSlot, blocked, duplicate, errorOnly, eventClash, global, placement, hzCapitalText, textElement
@docs text
@docs slotHint, slotLabel
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared)
import HtmlIr.Node
import Hz.Component.AttrSlot
import Hz.Component.Blocked
import Hz.Component.Duplicate
import Hz.Component.ErrorOnly
import Hz.Component.EventClash
import Hz.Component.Global
import Hz.Component.Placement
import Hz.Component.Text
import Hz.Component.TextElement


{-| See `Hz.Component.AttrSlot.component`.
-}
attrSlot :
    List (Attr Hz.Component.AttrSlot.Attrs msg)
    -> List (Element childAccepts (Hz.Component.AttrSlot.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Component.AttrSlot.Is s) admittedBy msg
attrSlot =
    Hz.Component.AttrSlot.component


{-| See `Hz.Component.Blocked.component`.
-}
blocked :
    List (Attr Hz.Component.Blocked.Attrs msg)
    -> List (Element Hz.Component.Blocked.Content (Hz.Component.Blocked.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Component.Blocked.Is s) admittedBy msg
blocked =
    Hz.Component.Blocked.component


{-| See `Hz.Component.Duplicate.component`.
-}
duplicate :
    List (Attr Hz.Component.Duplicate.Attrs msg)
    -> List (Element Hz.Component.Duplicate.Content (Hz.Component.Duplicate.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Component.Duplicate.Is s) admittedBy msg
duplicate =
    Hz.Component.Duplicate.component


{-| See `Hz.Component.ErrorOnly.component`.
-}
errorOnly :
    List (Attr Hz.Component.ErrorOnly.Attrs msg)
    -> List (Element childAccepts (Hz.Component.ErrorOnly.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Component.ErrorOnly.Is s) admittedBy msg
errorOnly =
    Hz.Component.ErrorOnly.component


{-| See `Hz.Component.EventClash.component`.
-}
eventClash :
    List (Attr Hz.Component.EventClash.Attrs msg)
    -> List (Element Hz.Component.EventClash.Content (Hz.Component.EventClash.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Component.EventClash.Is s) admittedBy msg
eventClash =
    Hz.Component.EventClash.component


{-| See `Hz.Component.Global.component`.
-}
global :
    List (Attr Hz.Component.Global.Attrs msg)
    -> List (Element Hz.Component.Global.Content (Hz.Component.Global.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Component.Global.Is s) admittedBy msg
global =
    Hz.Component.Global.component


{-| See `Hz.Component.Placement.component`.
-}
placement :
    List (Attr Hz.Component.Placement.Attrs msg)
    -> List (Element Hz.Component.Placement.Content (Hz.Component.Placement.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Component.Placement.Is s) admittedBy msg
placement =
    Hz.Component.Placement.component


{-| See `Hz.Component.Text.component`.
-}
hzCapitalText :
    List (Attr Hz.Component.Text.Attrs msg)
    -> List (Element Hz.Component.Text.Content (Hz.Component.Text.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Component.Text.Is s) admittedBy msg
hzCapitalText =
    Hz.Component.Text.component


{-| See `Hz.Component.TextElement.component`.
-}
textElement :
    List (Attr Hz.Component.TextElement.Attrs msg)
    -> List (Element Hz.Component.TextElement.Content (Hz.Component.TextElement.ChildAdmittedBy childAdm) msg)
    -> Element (Hz.Component.TextElement.Is s) admittedBy msg
textElement =
    Hz.Component.TextElement.component


{-| The shared text atom — admissible into any library's opted-in slot.
-}
text : String -> Element { s | sharedText : Shared } admittedBy msg
text value_ =
    Ir.fromNode (Ir.text value_)


{-| Place a child element into the `"hint"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotHint : Element accepts admittedBy msg -> Element free freeAdm msg
slotHint el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "hint") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"label"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotLabel : Element accepts admittedBy msg -> Element free freeAdm msg
slotLabel el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "label") (HtmlIr.Element.toNode el_))


{-| The typed IR element every constructor here produces. Re-exported so callers never import `HtmlIr.Element` directly.
-}
type alias Element accepts admittedBy msg =
    HtmlIr.Element.Element accepts admittedBy msg


{-| A typed attribute. Re-exported so callers never import `HtmlIr.Attribute` directly.
-}
type alias Attr capability msg =
    HtmlIr.Attribute.Attr capability msg


{-| The untyped IR node an `Element` wraps — the erased form, carrying no phantom claims. Re-exported for the boundaries that must store renderable content in a monomorphic field (a framework `View` record, a cache); lift it back with `<Lib>.Unsafe.fromNode`.
-}
type alias Node msg =
    HtmlIr.Node.Node msg


{-| Render any element from this library to `elm/html`.
-}
toHtml : Element accepts admittedBy msg -> Html.Html msg
toHtml =
    HtmlIr.Element.toNode >> HtmlIr.Node.toHtml


{-| Erase an element to its untyped [`Node`](#Node) — the safe out-bound direction; the phantom rows are discarded, never re-asserted.
-}
toNode : Element accepts admittedBy msg -> Node msg
toNode =
    HtmlIr.Element.toNode


{-| Map the `msg` type of any element from this library (the typed IR's `Html.map`). Structural: the tree is not rendered, rows are preserved.
-}
mapMsg : (a -> b) -> Element accepts admittedBy a -> Element accepts admittedBy b
mapMsg =
    HtmlIr.Element.map


{-| [`mapMsg`](#mapMsg) for an erased [`Node`](#Node).
-}
mapNode : (a -> b) -> Node a -> Node b
mapNode =
    HtmlIr.Node.map


{-| Attach a diff key to a child so its parent container renders as a keyed node. State and animations survive reorders, insertions, and removals. Phantom rows are preserved — a keyed chip is still a chip.
-}
key : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
key =
    HtmlIr.Element.key


{-| Memoise a subtree while its input is referentially unchanged. The result keeps its phantom rows and drops into any slot. **The view function must be a stable top-level binding** — an inline lambda allocates a fresh closure each render and silently never memoises.
-}
lazy : (a -> Element accepts admittedBy msg) -> a -> Element accepts admittedBy msg
lazy =
    HtmlIr.Element.lazy


{-| 2-argument variant of [`lazy`](#lazy).
-}
lazy2 : (a -> b -> Element accepts admittedBy msg) -> a -> b -> Element accepts admittedBy msg
lazy2 =
    HtmlIr.Element.lazy2


{-| 3-argument variant of [`lazy`](#lazy).
-}
lazy3 : (a -> b -> c -> Element accepts admittedBy msg) -> a -> b -> c -> Element accepts admittedBy msg
lazy3 =
    HtmlIr.Element.lazy3


{-| 4-argument variant of [`lazy`](#lazy).
-}
lazy4 : (a -> b -> c -> d -> Element accepts admittedBy msg) -> a -> b -> c -> d -> Element accepts admittedBy msg
lazy4 =
    HtmlIr.Element.lazy4


{-| 5-argument variant of [`lazy`](#lazy).
-}
lazy5 : (a -> b -> c -> d -> e -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> Element accepts admittedBy msg
lazy5 =
    HtmlIr.Element.lazy5


{-| 6-argument variant of [`lazy`](#lazy). Note type params skip `f` to match the underlying `VirtualDom.lazy6` convention.
-}
lazy6 : (a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg
lazy6 =
    HtmlIr.Element.lazy6


{-| 7-argument variant of [`lazy`](#lazy).
-}
lazy7 : (a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg
lazy7 =
    HtmlIr.Element.lazy7


{-| 8-argument variant of [`lazy`](#lazy). **This variant does not memoise** — the Element→Html bridge only has room for seven memoised data arguments, so the eighth forces a fresh closure each render and defeats the reference check. For real memoisation, fold the extra state into one of the first seven arguments and use [`lazy7`](#lazy7).
-}
lazy8 : (a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg
lazy8 =
    HtmlIr.Element.lazy8


{-| Add a CSS class, participating in the `class` merge. Phantom rows preserved.
-}
addClass : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
addClass =
    HtmlIr.Element.addClass


{-| Conditionally attach an attribute — applied when the flag is `True`, a no-op when `False`. Phantom rows preserved.
-}
attrIf : Bool -> Attr capability msg -> Element accepts admittedBy msg -> Element accepts admittedBy msg
attrIf =
    HtmlIr.Element.attrIf


{-| Keep an element only when the flag is `True`; `False` collapses it to an empty node that renders nothing. Phantom rows preserved.
-}
when : Bool -> Element accepts admittedBy msg -> Element accepts admittedBy msg
when =
    HtmlIr.Element.when


{-| Stamp a `data-testid` attribute for test hooks. Phantom rows preserved.
-}
testId : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
testId =
    HtmlIr.Element.testId
