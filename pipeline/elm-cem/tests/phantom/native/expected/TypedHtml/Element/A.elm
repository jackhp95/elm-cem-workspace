module TypedHtml.Element.A exposing
    ( a
    , Attrs, ChildAdmittedBy
    , href
    )

{-| The `A` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs a
@docs Attrs, ChildAdmittedBy
@docs href

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Ctx)


{-| `a`'s closed attribute-capability row.
-}
type alias Attrs =
    { autofocus : Supported
    , class : Supported
    , dir : Supported
    , hidden : Supported
    , href : Supported
    , id : Supported
    , role : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    }


{-| The context demand `a` injects into its children.
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | a : Ctx }


{-| The `a` element. Transparent content model: its produced kind row IS its
children's accepts row — it inherits its context's content model.
-}
a :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
a attrs children =
    Ir.fromNode (Ir.node "a" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedHtml.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    TypedHtml.Attributes.href
