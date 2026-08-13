module TypedHtml.A exposing
    ( a
    , Attrs, ChildAdmittedBy, Roles
    , download, href, hreflang, ping, referrerpolicy, rel, target
    )

{-| The `A` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs a
@docs Attrs, ChildAdmittedBy, Roles
@docs download, href, hreflang, ping, referrerpolicy, rel, target

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedHtml.Attributes
import TypedHtml.Kind exposing (Ctx, Role)


{-| `a`'s closed attribute-capability row.
-}
type alias Attrs =
    { accesskey : Supported
    , autocapitalize : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , contenteditable : Supported
    , download : Supported
    , draggable : Supported
    , enterkeyhint : Supported
    , href : Supported
    , hreflang : Supported
    , id : Supported
    , inert : Supported
    , inputmode : Supported
    , itemid : Supported
    , itemprop : Supported
    , itemref : Supported
    , itemscope : Supported
    , itemtype : Supported
    , nonce : Supported
    , onClick : Supported
    , ping : Supported
    , popover : Supported
    , referrerpolicy : Supported
    , rel : Supported
    , role : Roles
    , slot : Supported
    , spellcheck : Supported
    , style : Supported
    , target : Supported
    , translate : Supported
    , writingsuggestions : Supported
    }


{-| The context demand `a` injects into its children.
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | a : Ctx }


{-| The ARIA roles `a` admits (see `TypedHtml.Aria`).
-}
type alias Roles =
    { button : Role
    , checkbox : Role
    , link : Role
    , menuitem : Role
    , menuitemcheckbox : Role
    , menuitemradio : Role
    , none : Role
    , option : Role
    , presentation : Role
    , radio : Role
    , switch : Role
    , tab : Role
    , treeitem : Role
    }


{-| The `a` element. Transparent content model: its produced kind row IS its
children's accepts row — it inherits its context's content model.
-}
a :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element childAccepts admittedBy msg
a attrs children =
    Ir.fromNode (Ir.node "a" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedHtml.Attributes.download`.
-}
download : String -> Attr { c | download : Supported } msg
download =
    TypedHtml.Attributes.download


{-| See `TypedHtml.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    TypedHtml.Attributes.href


{-| See `TypedHtml.Attributes.hreflang`.
-}
hreflang : String -> Attr { c | hreflang : Supported } msg
hreflang =
    TypedHtml.Attributes.hreflang


{-| See `TypedHtml.Attributes.ping`.
-}
ping : String -> Attr { c | ping : Supported } msg
ping =
    TypedHtml.Attributes.ping


{-| Referrer policy for fetches initiated by the element
-}
referrerpolicy : String -> Attr { c | referrerpolicy : Supported } msg
referrerpolicy value_ =
    Ir.attribute "referrerpolicy" value_


{-| See `TypedHtml.Attributes.rel`.
-}
rel : String -> Attr { c | rel : Supported } msg
rel =
    TypedHtml.Attributes.rel


{-| See `TypedHtml.Attributes.target`.
-}
target : String -> Attr { c | target : Supported } msg
target =
    TypedHtml.Attributes.target
