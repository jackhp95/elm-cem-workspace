module Generate.Phantom.Emit.SubstrateReExports exposing (..)


import Attr
import Cem
import Char
import Dict
import Docs
import Elm
import Generate.Phantom.Model as M exposing (Brand, Comp, EnumSpec, KindField, Marker(..), ResolvedSlot, SlotContent(..))
import Json.Encode as Encode
import Naming

import Generate.Phantom.Emit.Shared exposing (..)


-- SUBSTRATE RE-EXPORTS
--
-- The substrate types a caller needs to write a type annotation. Every brand
-- surface re-exports them so `HtmlIr.*` never has to appear in userland code.
--
-- Kept as ONE list + ONE declaration block, shared verbatim by the barrel and
-- by the published `<Lib>.Html` producer layer. Before this, the barrel's
-- exposing list held a hardcoded `[ "Element", "Attr", "mapMsg" ]` that had
-- already drifted from what the other emitters shipped: `Value` and
-- `Supported`/`Shared` were used in every generated signature but re-exported
-- nowhere, so annotating a token forced an `HtmlIr.Value` import.


{-| Names re-exported by both the barrel and `<Lib>.Html`.
-}
substrateReExportNames : List String
substrateReExportNames =
    [ "Element"
    , "Attr"
    , "Node"
    , "toHtml"
    , "toNode"
    , "mapMsg"
    , "mapNode"
    , "key"
    , "lazy"
    , "lazy2"
    , "lazy3"
    , "lazy4"
    , "lazy5"
    , "lazy6"
    , "lazy7"
    , "lazy8"
    , "addClass"
    , "attrIf"
    , "when"
    , "testId"
    ]


{-| Imports that [`substrateReExportDecls`](#substrateReExportDecls) needs.
Qualified, never `exposing` — the local aliases below shadow the names.
-}
substrateReExportImports : List String
substrateReExportImports =
    [ "import Html"
    , "import HtmlIr.Attribute"
    , "import HtmlIr.Element"
    , "import HtmlIr.Node"
    ]


{-| The declarations behind [`substrateReExportNames`](#substrateReExportNames).
-}
substrateReExportDecls : List String
substrateReExportDecls =
    [ ""
    , ""
    , doc "The typed IR element every constructor here produces. Re-exported so callers never import `HtmlIr.Element` directly."
    , "type alias Element accepts admittedBy msg ="
    , "    HtmlIr.Element.Element accepts admittedBy msg"
    , ""
    , ""
    , doc "A typed attribute. Re-exported so callers never import `HtmlIr.Attribute` directly."
    , "type alias Attr capability msg ="
    , "    HtmlIr.Attribute.Attr capability msg"
    , ""
    , ""
    , doc "The untyped IR node an `Element` wraps — the erased form, carrying no phantom claims. Re-exported for the boundaries that must store renderable content in a monomorphic field (a framework `View` record, a cache); lift it back with `<Lib>.Unsafe.fromNode`."
    , "type alias Node msg ="
    , "    HtmlIr.Node.Node msg"
    , ""
    , ""
    , doc "Render any element from this library to `elm/html`."
    , "toHtml : Element accepts admittedBy msg -> Html.Html msg"
    , "toHtml ="
    , "    HtmlIr.Element.toNode >> HtmlIr.Node.toHtml"
    , ""
    , ""
    , doc "Erase an element to its untyped [`Node`](#Node) — the safe out-bound direction; the phantom rows are discarded, never re-asserted."
    , "toNode : Element accepts admittedBy msg -> Node msg"
    , "toNode ="
    , "    HtmlIr.Element.toNode"
    , ""
    , ""
    , doc "Map the `msg` type of any element from this library (the typed IR's `Html.map`). Structural: the tree is not rendered, rows are preserved."
    , "mapMsg : (a -> b) -> Element accepts admittedBy a -> Element accepts admittedBy b"
    , "mapMsg ="
    , "    HtmlIr.Element.map"
    , ""
    , ""
    , doc "[`mapMsg`](#mapMsg) for an erased [`Node`](#Node)."
    , "mapNode : (a -> b) -> Node a -> Node b"
    , "mapNode ="
    , "    HtmlIr.Node.map"
    , ""
    , ""
    , doc "Attach a diff key to a child so its parent container renders as a keyed node. State and animations survive reorders, insertions, and removals. Phantom rows are preserved — a keyed chip is still a chip."
    , "key : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg"
    , "key ="
    , "    HtmlIr.Element.key"
    , ""
    , ""
    , doc "Memoise a subtree while its input is referentially unchanged. The result keeps its phantom rows and drops into any slot. **The view function must be a stable top-level binding** — an inline lambda allocates a fresh closure each render and silently never memoises."
    , "lazy : (a -> Element accepts admittedBy msg) -> a -> Element accepts admittedBy msg"
    , "lazy ="
    , "    HtmlIr.Element.lazy"
    , ""
    , ""
    , doc "2-argument variant of [`lazy`](#lazy)."
    , "lazy2 : (a -> b -> Element accepts admittedBy msg) -> a -> b -> Element accepts admittedBy msg"
    , "lazy2 ="
    , "    HtmlIr.Element.lazy2"
    , ""
    , ""
    , doc "3-argument variant of [`lazy`](#lazy)."
    , "lazy3 : (a -> b -> c -> Element accepts admittedBy msg) -> a -> b -> c -> Element accepts admittedBy msg"
    , "lazy3 ="
    , "    HtmlIr.Element.lazy3"
    , ""
    , ""
    , doc "4-argument variant of [`lazy`](#lazy)."
    , "lazy4 : (a -> b -> c -> d -> Element accepts admittedBy msg) -> a -> b -> c -> d -> Element accepts admittedBy msg"
    , "lazy4 ="
    , "    HtmlIr.Element.lazy4"
    , ""
    , ""
    , doc "5-argument variant of [`lazy`](#lazy)."
    , "lazy5 : (a -> b -> c -> d -> e -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> Element accepts admittedBy msg"
    , "lazy5 ="
    , "    HtmlIr.Element.lazy5"
    , ""
    , ""
    , doc "6-argument variant of [`lazy`](#lazy). Note type params skip `f` to match the underlying `VirtualDom.lazy6` convention."
    , "lazy6 : (a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg"
    , "lazy6 ="
    , "    HtmlIr.Element.lazy6"
    , ""
    , ""
    , doc "7-argument variant of [`lazy`](#lazy)."
    , "lazy7 : (a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg"
    , "lazy7 ="
    , "    HtmlIr.Element.lazy7"
    , ""
    , ""
    , doc "8-argument variant of [`lazy`](#lazy). **This variant does not memoise** — the Element→Html bridge only has room for seven memoised data arguments, so the eighth forces a fresh closure each render and defeats the reference check. For real memoisation, fold the extra state into one of the first seven arguments and use [`lazy7`](#lazy7)."
    , "lazy8 : (a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg"
    , "lazy8 ="
    , "    HtmlIr.Element.lazy8"
    , ""
    , ""
    , doc "Add a CSS class, participating in the `class` merge. Phantom rows preserved."
    , "addClass : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg"
    , "addClass ="
    , "    HtmlIr.Element.addClass"
    , ""
    , ""
    , doc "Conditionally attach an attribute — applied when the flag is `True`, a no-op when `False`. Phantom rows preserved."
    , "attrIf : Bool -> Attr capability msg -> Element accepts admittedBy msg -> Element accepts admittedBy msg"
    , "attrIf ="
    , "    HtmlIr.Element.attrIf"
    , ""
    , ""
    , doc "Keep an element only when the flag is `True`; `False` collapses it to an empty node that renders nothing. Phantom rows preserved."
    , "when : Bool -> Element accepts admittedBy msg -> Element accepts admittedBy msg"
    , "when ="
    , "    HtmlIr.Element.when"
    , ""
    , ""
    , doc "Stamp a `data-testid` attribute for test hooks. Phantom rows preserved."
    , "testId : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg"
    , "testId ="
    , "    HtmlIr.Element.testId"
    ]



