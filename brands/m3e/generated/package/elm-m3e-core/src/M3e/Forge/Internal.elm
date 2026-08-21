module M3e.Forge.Internal exposing
    ( Builder(..)
    , init, withAttribute, withChild, toElement
    )

{-| The builder forge for the `M3e` brand — the ONE place a `Builder`'s
capability rows are minted and its record constructor is exposed. Every
per-component `build`/`withX`/`toElement` composes these levers; the mechanics
are defined here exactly once. Untrusted code that imports this module can forge
any capability claim, exactly like `HtmlIr.Internal` — the
`NoInternalImportOutsideAllowed` fence is load-bearing.

@docs Builder
@docs init, withAttribute, withChild, toElement

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Node exposing (Node)


{-| The shared pipe-builder. `attrCaps`/`slotCaps` are phantom write-once
capability rows; `row` is the host element's closed attribute row; `accepts` is
the element-kind phantom produced on close; `tag` is the custom-element tag
closed over at `init`. Each component aliases this with its own `row` and
`accepts = (Is s)`, and exposes narrowed `withX` setters.
-}
type Builder row attrCaps slotCaps accepts msg
    = Builder
        { tag : String
        , attrs : List (Attr row msg)
        , children : List (Node msg)
        }


{-| Seed a builder with its tag, initial attributes, and initial children.
-}
init : String -> List (Attr row msg) -> List (Node msg) -> Builder row attrCaps slotCaps accepts msg
init tag attrs children =
    Builder { tag = tag, attrs = attrs, children = children }


{-| Prepend one attribute, advancing the attribute-capability row (phantom).
-}
withAttribute : Attr row msg -> Builder row attrCapsIn slotCaps accepts msg -> Builder row attrCapsOut slotCaps accepts msg
withAttribute attr (Builder b) =
    Builder { b | attrs = attr :: b.attrs }


{-| Prepend one child node, advancing the slot-capability row (phantom).
-}
withChild : Node msg -> Builder row attrCaps slotCapsIn accepts msg -> Builder row attrCaps slotCapsOut accepts msg
withChild child (Builder b) =
    Builder { b | children = child :: b.children }


{-| Close the builder into an element — defined ONCE for the brand. Attributes
and children are reversed so they render in the order they were piped on.
-}
toElement : Builder row attrCaps slotCaps accepts msg -> Element accepts admittedBy msg
toElement (Builder b) =
    Ir.fromNode (Ir.node b.tag (List.reverse b.attrs) (List.reverse b.children))
