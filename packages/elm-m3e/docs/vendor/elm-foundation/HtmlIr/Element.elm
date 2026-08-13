module HtmlIr.Element exposing
    ( Element
    , toNode, map
    )

{-| The phantom-typed element every library on this substrate shares. An
`Element accepts admittedBy msg` is a piece of renderable content whose two
phantom rows record, respectively, which slot kinds it may occupy
(`accepts`, parent → child) and which parent contexts it is valid inside
(`admittedBy`, child → parent). Because every brand package (native HTML, any
generated design system) produces this **same** type, their content nests
without conversion; the rows are what let the compiler reject a child in a slot
that does not admit it, or an element under a parent it does not allow.

This module is the safe surface: constructing an `Element` — which asserts its
rows — is only possible through a brand's typed constructors or the fenced
forge in [`HtmlIr.Internal`](HtmlIr-Internal) (see its trust-model note).

@docs Element
@docs toNode, map

-}

import HtmlIr.Internal as I
import HtmlIr.Node exposing (Node)


{-| The opaque two-row phantom element. Rows are never inspected at runtime.
-}
type alias Element accepts admittedBy msg =
    I.Element accepts admittedBy msg


{-| Unwrap to the underlying untyped [`Node`](HtmlIr-Node#Node) — the safe
out-bound direction (rows are discarded, never re-asserted). Render it with
[`HtmlIr.Node.toHtml`](HtmlIr-Node#toHtml).
-}
toNode : Element accepts admittedBy msg -> Node msg
toNode =
    I.toNode


{-| Map the message type. Structural: the tree is not rendered, rows and
rearrangeability are preserved.
-}
map : (a -> b) -> Element accepts admittedBy a -> Element accepts admittedBy b
map =
    I.mapElement
