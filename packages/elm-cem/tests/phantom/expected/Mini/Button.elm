module Mini.Button exposing
    ( view, el, build, toElement
    , Is, Attrs, Content, IconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps
    , Variant, variant
    , disabled, weight, weightAsNumber, onClick
    , icon, child
    , withChild, withClass, withDir, withDisabled, withIcon, withId, withInert, withOnClick, withSlot, withStyle, withTabindex, withVariant, withWeight
    )

{-| The `mini-button` component — strict per-component surface.

An action chip trigger.

@docs view, el, build, toElement
@docs Is, Attrs, Content, IconSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps
@docs Variant, variant
@docs disabled, weight, weightAsNumber, onClick
@docs icon, child
@docs withChild, withClass, withDir, withDisabled, withIcon, withId, withInert, withOnClick, withSlot, withStyle, withTabindex, withVariant, withWeight

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Attributes as A
import Mini.Build.Internal as B
import Mini.Events as Ev
import Mini.Html as H
import Mini.Kind exposing (Available, Brand, Ctx, Used)
import Mini.Values


{-| The kind row `mini-button` produces (open — composes into any slot naming it).
-}
type alias Is s =
    { s | button : Brand }


{-| The closed attribute-capability row.
-}
type alias Attrs =
    { class : Supported
    , dir : Supported
    , disabled : Supported
    , id : Supported
    , inert : Supported
    , onClick : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    , variant : Supported
    , weight : Supported
    }


{-| The kinds the default slot admits.
-}
type alias Content =
    { sharedIcon : Shared
    , sharedText : Shared
    }


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    { sharedIcon : Shared }


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | button : Ctx }


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    { filled : Supported
    , tonal : Supported
    }


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.button


{-| Required-content (and action) constructor — omissions are unwritable.
-}
el :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
el required_ attrs children =
    view attrs (required_.content :: children)


{-| Visual variant.
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `Mini.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Mini.Attributes.weight`.
-}
weight : String -> Attr { c | weight : Supported } msg
weight =
    A.weight


{-| See `Mini.Attributes.weightAsNumber`.
-}
weightAsNumber : Float -> Attr { c | weight : Supported } msg
weightAsNumber =
    A.weightAsNumber


{-| See `Mini.Events.onClick`.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick =
    Ev.onClick


{-| Place an element into the named `icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
icon : Element IconSlot admittedBy msg -> Element free freeAdmittedBy msg
icon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)


{-| The pipe-builder: capabilities are consumed Available→Used, so writing
a singular attribute or slot twice is unwritable. Aliases the shared builder in
`Build.Internal`, closed over this component's `Attrs` row.
-}
type alias Builder attrCaps slotCaps msg =
    B.Builder Attrs attrCaps slotCaps msg


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    { class : Available
    , dir : Available
    , disabled : Available
    , id : Available
    , inert : Available
    , onClick : Available
    , slot : Available
    , style : Available
    , tabindex : Available
    , variant : Available
    , weight : Available
    }


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    { icon : Available
    }


{-| Seed the pipe-builder.
-}
build :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg
build required_ =
    B.init "mini-button" [] [ El.toNode required_.content ]


{-| Close the pipe-builder (`toElement` is defined once in `Build.Internal`).
-}
toElement : Builder attrCaps slotCaps msg -> Element (Is s) admittedBy msg
toElement =
    B.toElement


{-| Pipe form of `class` — consumes its capability (write-once).
-}
withClass : String -> Builder { a | class : Available } slotCaps msg -> Builder { a | class : Used } slotCaps msg
withClass value_ =
    B.withAttribute (A.class value_)


{-| Pipe form of `dir` — consumes its capability (write-once).
-}
withDir : Value Mini.Values.Dir -> Builder { a | dir : Available } slotCaps msg -> Builder { a | dir : Used } slotCaps msg
withDir value_ =
    B.withAttribute (A.dir value_)


{-| Pipe form of `id` — consumes its capability (write-once).
-}
withId : String -> Builder { a | id : Available } slotCaps msg -> Builder { a | id : Used } slotCaps msg
withId value_ =
    B.withAttribute (A.id value_)


{-| Pipe form of `inert` — consumes its capability (write-once).
-}
withInert : Bool -> Builder { a | inert : Available } slotCaps msg -> Builder { a | inert : Used } slotCaps msg
withInert value_ =
    B.withAttribute (A.inert value_)


{-| Pipe form of `slot` — consumes its capability (write-once).
-}
withSlot : String -> Builder { a | slot : Available } slotCaps msg -> Builder { a | slot : Used } slotCaps msg
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| Pipe form of `style` — consumes its capability (write-once).
-}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg -> Builder { a | style : Used } slotCaps msg
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| Pipe form of `tabindex` — consumes its capability (write-once).
-}
withTabindex : Int -> Builder { a | tabindex : Available } slotCaps msg -> Builder { a | tabindex : Used } slotCaps msg
withTabindex value_ =
    B.withAttribute (A.tabindex value_)


{-| Pipe form of `disabled` — consumes its capability (write-once).
-}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg -> Builder { a | disabled : Used } slotCaps msg
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| Pipe form of `variant` — consumes its capability (write-once).
-}
withVariant : Value Variant -> Builder { a | variant : Available } slotCaps msg -> Builder { a | variant : Used } slotCaps msg
withVariant value_ =
    B.withAttribute (variant value_)


{-| Pipe form of `weight` — consumes its capability (write-once).
-}
withWeight : String -> Builder { a | weight : Available } slotCaps msg -> Builder { a | weight : Used } slotCaps msg
withWeight value_ =
    B.withAttribute (A.weight value_)


{-| Pipe form of `onClick` — consumes its capability (write-once).
-}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg -> Builder { a | onClick : Used } slotCaps msg
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| Pipe form of the `icon` slot — consumes its capability (write-once).
-}
withIcon : Element IconSlot admittedBy msg -> Builder attrCaps { s | icon : Available } msg -> Builder attrCaps { s | icon : Used } msg
withIcon element =
    B.withChild (El.toNode (icon element))


{-| Pipe form of a default-slot child (repeatable).
-}
withChild : Element Content (ChildAdmittedBy childAdm) msg -> Builder attrCaps slotCaps msg -> Builder attrCaps slotCaps msg
withChild element =
    B.withChild (El.toNode element)
