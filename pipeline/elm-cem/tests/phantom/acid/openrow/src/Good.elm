module Good exposing (bothRows, openOnEveryElement, page, plainPage, view)

{-| The open-row globals suite.

`oflag` / `odir` are declared `"row": "open"`; `cflag` / `cdir` are the same two
types with no `row` key. Everything here must compile.

-}

import Html exposing (Html)
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Node
import Or
import Or.Attributes
import Or.Element.Widget
import Or.Kind
import Or.Values


{-| An open global composes onto an element that ALSO carries closed globals and
its own CEM attribute — the mixed case.
-}
page : HtmlIr.Element.Element { s | widget : Or.Kind.Brand } admittedBy msg
page =
    Or.widget
        [ Or.Element.Widget.label "hello"
        , Or.Attributes.class "container"
        , Or.Attributes.cflag True
        , Or.Attributes.cdir Or.Values.ltr
        , Or.Attributes.oflag True
        , Or.Attributes.odir Or.Values.rtl
        ]
        []


{-| …and onto an element that declares NO attributes of its own, whose whole
`Attrs` row therefore came from `_globals`. This is the case that fails if an
open global is still being folded into the closed row.
-}
plainPage : HtmlIr.Element.Element { s | plain : Or.Kind.Brand } admittedBy msg
plainPage =
    Or.plain
        [ Or.Attributes.oflag False
        , Or.Attributes.odir Or.Values.auto
        ]
        []


{-| The actual point of an unconstrained row: ONE annotated value is admitted by
both elements, with no row refinement naming either. A closed global cannot be
written this way — its `Attr { c | … : Supported } msg` would have to be
instantiated per element — which is what `bad/ClosedGlobalIsNotOpen.elm` pins.
-}
openOnEveryElement : List (HtmlIr.Attribute.Attr c msg)
openOnEveryElement =
    [ Or.Attributes.oflag True
    , Or.Attributes.odir Or.Values.ltr
    ]


{-| Both rows coexist in one attribute list, so the change did not simply swap
one shape for the other.
-}
bothRows : HtmlIr.Element.Element { s | plain : Or.Kind.Brand } admittedBy msg
bothRows =
    Or.plain (Or.Attributes.cflag True :: openOnEveryElement) []


view : Html msg
view =
    HtmlIr.Node.toHtml (HtmlIr.Element.toNode page)
