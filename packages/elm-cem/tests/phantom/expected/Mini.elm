module Mini exposing
    ( button, chip, icon, surface, tab, tabs, toolbar
    , text
    , slotIcon
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId
    )

{-| The general surface: every component constructor in the elm/html call
shape, one import. Signatures reference each component's aliases — reach for
`Mini.<Component>` when you want the strict per-component surface (required
content, builder, narrowed values), and `Mini.Attributes` / `Mini.Events` /
`Mini.Values` for the shared vocabulary.

`toHtml` is the render bridge to `elm/html`.

The `slot<Name>` placers assign a child element to a named slot in any
component that accepts it. Admittance is open (broad row) — wrong-kind
placements are caught by `Cem.ValidSlotKind` (elm-review).

@docs button, chip, icon, surface, tab, tabs, toolbar
@docs text
@docs slotIcon
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared)
import HtmlIr.Node
import Mini.Component.Button
import Mini.Component.Chip
import Mini.Component.Icon
import Mini.Component.Surface
import Mini.Component.Tab
import Mini.Component.Tabs
import Mini.Component.Toolbar
import Mini.Kind


{-| The loose `mini-button` producer — open attribute/child rows, no required record. See `Mini.Component.Button.component` for the required-content form.
-}
button :
    List (Attr Mini.Component.Button.Attrs msg)
    -> List (Element Mini.Component.Button.Content (Mini.Component.Button.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Component.Button.Is s) admittedBy msg
button attrs children =
    Ir.fromNode (Ir.node "mini-button" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Mini.Component.Chip.component`.
-}
chip :
    List (Attr Mini.Component.Chip.Attrs msg)
    -> List (Element Mini.Component.Chip.Content (Mini.Component.Chip.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Component.Chip.Is s) admittedBy msg
chip =
    Mini.Component.Chip.component


{-| See `Mini.Component.Icon.component`.
-}
icon :
    List (Attr Mini.Component.Icon.Attrs msg)
    -> List (Element Mini.Component.Icon.Content (Mini.Component.Icon.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Component.Icon.Is s) admittedBy msg
icon =
    Mini.Component.Icon.component


{-| See `Mini.Component.Surface.component`.
-}
surface :
    List (Attr Mini.Component.Surface.Attrs msg)
    -> List (Element childAccepts (Mini.Component.Surface.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Component.Surface.Is s) admittedBy msg
surface =
    Mini.Component.Surface.component


{-| See `Mini.Component.Tab.component`.
-}
tab :
    List (Attr Mini.Component.Tab.Attrs msg)
    -> List (Element Mini.Component.Tab.Content (Mini.Component.Tab.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Component.Tab.Is s) Mini.Component.Tab.AdmittedBy msg
tab =
    Mini.Component.Tab.component


{-| See `Mini.Component.Tabs.component`.
-}
tabs :
    List (Attr Mini.Component.Tabs.Attrs msg)
    -> List (Element Mini.Component.Tabs.Content (Mini.Component.Tabs.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Component.Tabs.Is s) admittedBy msg
tabs =
    Mini.Component.Tabs.component


{-| See `Mini.Component.Toolbar.component`.
-}
toolbar :
    List (Attr Mini.Component.Toolbar.Attrs msg)
    -> List (Element Mini.Kind.Actions (Mini.Component.Toolbar.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Component.Toolbar.Is s) admittedBy msg
toolbar =
    Mini.Component.Toolbar.component


{-| The shared text atom — admissible into any library's opted-in slot.
-}
text : String -> Element { s | sharedText : Shared } admittedBy msg
text value_ =
    Ir.fromNode (Ir.text value_)


{-| Place a child element into the `"icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "icon") (HtmlIr.Element.toNode el_))


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
