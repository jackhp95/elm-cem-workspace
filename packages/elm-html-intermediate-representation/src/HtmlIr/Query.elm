module HtmlIr.Query exposing (tagOf, keysOf, childrenOf, classesOf)

{-| Read-only structural accessors over an opaque [`Node`](HtmlIr-Node#Node) —
the test-facing surface (design decision D5). `Node` stays opaque, so a brand's
`elm-test` suite cannot pattern-match it; these accessors let a suite assert IR
structure (tag name, child diff keys, children, class names) without exposing
the representation and without `elm-html-test`'s opaque-`Html` workarounds.

    import HtmlIr.Element as Element
    import HtmlIr.Query as Query

    Query.keysOf (Element.toNode (viewChips model)) == [ "1", "2" ]

Every accessor is total and pure; none mints a phantom row.

@docs tagOf, keysOf, childrenOf, classesOf

-}

import HtmlIr.Internal as I
import HtmlIr.Node exposing (Node)


{-| The tag name of a tag node (`Tag`/`KeyedTag`); `Nothing` for a text leaf,
raw escape, or bare keyed marker.
-}
tagOf : Node msg -> Maybe String
tagOf =
    I.tagOf


{-| The diff keys of a node's children, in order — non-empty only for the keyed
shape that `HtmlIr.Node.node` auto-upgrades to when a child carries a key.
-}
keysOf : Node msg -> List String
keysOf =
    I.keysOf


{-| The children of a node, in order, with any diff keys stripped.
-}
childrenOf : Node msg -> List (Node msg)
childrenOf =
    I.childrenOf


{-| The `class` names on a node, in authoring order (the structural facts,
pre-merge).
-}
classesOf : Node msg -> List String
classesOf =
    I.classesOf
