module Mini exposing
    ( button, chip, icon, surface, tab, tabs, toolbar
    , text
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode
    )

{-| The general surface: every component constructor in the elm/html call
shape, one import. Signatures reference each component's aliases — reach for
`Mini.<Component>` when you want the strict per-component surface (required
content, builder, narrowed values), and `Mini.Attributes` / `Mini.Events` /
`Mini.Values` for the shared vocabulary.

`toHtml` is the render bridge to `elm/html`.

@docs button, chip, icon, surface, tab, tabs, toolbar
@docs text
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared)
import HtmlIr.Node
import Mini.Button
import Mini.Chip
import Mini.Icon
import Mini.Kind
import Mini.Surface
import Mini.Tab
import Mini.Tabs
import Mini.Toolbar


{-| See `Mini.Button.view`.
-}
button :
    List (Attr Mini.Button.Attrs msg)
    -> List (Element Mini.Button.Content (Mini.Button.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Button.Is s) admittedBy msg
button =
    Mini.Button.view


{-| See `Mini.Chip.view`.
-}
chip :
    List (Attr Mini.Chip.Attrs msg)
    -> List (Element Mini.Chip.Content (Mini.Chip.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Chip.Is s) admittedBy msg
chip =
    Mini.Chip.view


{-| See `Mini.Icon.view`.
-}
icon :
    List (Attr Mini.Icon.Attrs msg)
    -> List (Element Mini.Icon.Content (Mini.Icon.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Icon.Is s) admittedBy msg
icon =
    Mini.Icon.view


{-| See `Mini.Surface.view`.
-}
surface :
    List (Attr Mini.Surface.Attrs msg)
    -> List (Element childAccepts (Mini.Surface.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Surface.Is s) admittedBy msg
surface =
    Mini.Surface.view


{-| See `Mini.Tab.view`.
-}
tab :
    List (Attr Mini.Tab.Attrs msg)
    -> List (Element Mini.Tab.Content (Mini.Tab.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Tab.Is s) Mini.Tab.AdmittedBy msg
tab =
    Mini.Tab.view


{-| See `Mini.Tabs.view`.
-}
tabs :
    List (Attr Mini.Tabs.Attrs msg)
    -> List (Element Mini.Tabs.Content (Mini.Tabs.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Tabs.Is s) admittedBy msg
tabs =
    Mini.Tabs.view


{-| See `Mini.Toolbar.view`.
-}
toolbar :
    List (Attr Mini.Toolbar.Attrs msg)
    -> List (Element Mini.Kind.Actions (Mini.Toolbar.ChildAdmittedBy childAdm) msg)
    -> Element (Mini.Toolbar.Is s) admittedBy msg
toolbar =
    Mini.Toolbar.view


{-| The shared text atom — admissible into any library's opted-in slot.
-}
text : String -> Element { s | sharedText : Shared } admittedBy msg
text value_ =
    Ir.fromNode (Ir.text value_)


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
