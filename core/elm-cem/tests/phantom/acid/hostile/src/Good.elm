module Good exposing (blockedRowIsExactly, page, view)

{-| Tests that both members of each K1-K7 disambiguated pair compile and are
distinct, proving the policy works:
- K1: top_ and top (both token setters)
- K4: onError/onErrorWith and onHzError/onHzErrorWith (both event handler pairs)
- K5: withHint (attr setter) and withHintSlot (slot builder)
- K7: text (atom) and hzCapitalText (element ctor, name="Text" → K7 revert to full-tag camel)
     textElement (ctor from name="TextElement", no collision, stays textElement)

…and the POSITIVE half of the kernel-blocked guard: `hz-blocked` declares five
attributes elm/virtual-dom cannot express plus one it can, and the one it can
still works, with the row pinned to exactly that (see `blockedRowIsExactly`).
The bad/Blocked*.elm probes cover the negative half.
-}

import Html exposing (Html)
import HtmlIr.Element
import HtmlIr.Kind
import HtmlIr.Node
import Hz
import Hz.Build.AttrSlot
import Hz.Build.Blocked
import Hz.Component.AttrSlot
import Hz.Component.Blocked
import Hz.Component.EventClash
import Hz.Component.Placement
import Hz.Events
import Hz.Kind
import Hz.Values
import Json.Decode


type Msg
    = NoOp


-- K1: both top_ and top tokens work (compile-time narrowing)
placement1 : HtmlIr.Element.Element { s | placement : Hz.Kind.Brand } admittedBy Msg
placement1 =
    Hz.placement [ Hz.Component.Placement.position Hz.Values.top_ ] []


placement2 : HtmlIr.Element.Element { s | placement : Hz.Kind.Brand } admittedBy Msg
placement2 =
    Hz.placement [ Hz.Component.Placement.position Hz.Values.top ] []


-- K4: both onError and onHzError exist and can be used together
eventClash1 : HtmlIr.Element.Element { s | eventClash : Hz.Kind.Brand } admittedBy Msg
eventClash1 =
    Hz.eventClash
        [ Hz.Component.EventClash.onError NoOp
        , Hz.Component.EventClash.onHzError NoOp
        , Hz.Events.onErrorWith (Json.Decode.succeed NoOp)
        , Hz.Events.onHzErrorWith (Json.Decode.succeed NoOp)
        ]
        []


-- K5: both attr withHint (Bool -> Attr) and slot builder withHintSlot
-- (Element -> Builder -> Builder) exist and are distinct
attrSlot1 : HtmlIr.Element.Element { s | attrSlot : Hz.Kind.Brand } admittedBy Msg
attrSlot1 =
    Hz.attrSlot [ Hz.Component.AttrSlot.withHint True ] []


-- withHintSlot is a slot builder, not an attribute
attrSlot2 : HtmlIr.Element.Element { s | attrSlot : Hz.Kind.Brand } admittedBy Msg
attrSlot2 =
    Hz.Build.AttrSlot.build
        |> Hz.Build.AttrSlot.toElement


-- K7: text atom and hzCapitalText element ctor are distinct
-- (name="Text" → ctor="text" collides with atom → K7 reverts to Naming.camel tag = hzCapitalText)
textAtom : HtmlIr.Element.Element { s | sharedText : HtmlIr.Kind.Shared } admittedBy Msg
textAtom =
    Hz.text "raw text"


-- K7 resolved ctor: Hz.Component.Text is the module for the "Text" element
hzCapitalTextEl : HtmlIr.Element.Element { s | text : Hz.Kind.Brand } admittedBy Msg
hzCapitalTextEl =
    Hz.hzCapitalText [] []


-- textElement stays textElement (name="TextElement" → no collision with atom)
textElementEl : HtmlIr.Element.Element { s | textElement : Hz.Kind.Brand } admittedBy Msg
textElementEl =
    Hz.textElement [] []


-- KERNEL-BLOCKED: the guard is SELECTIVE. `hz-blocked` declares `formaction`,
-- `onbeforetoggle`, `once`, `is` and `innerhtml` (all unexpressible through
-- elm/virtual-dom) alongside a plain `label`, and dropping the five must not cost
-- the element the sixth — nor its globals, nor its builder pipes.
blockedEl : HtmlIr.Element.Element { s | blocked : Hz.Kind.Brand } admittedBy Msg
blockedEl =
    Hz.blocked [ Hz.Component.Blocked.label "still here" ] []


blockedPipe : HtmlIr.Element.Element { s | blocked : Hz.Kind.Brand } admittedBy Msg
blockedPipe =
    Hz.Build.Blocked.build
        |> Hz.Build.Blocked.withLabel "still here"
        |> Hz.Build.Blocked.withClass "c"
        |> Hz.Build.Blocked.toElement


{-| The `Attrs` row of `hz-blocked`, spelled out — an EXACTNESS assertion, not a
subset one. Elm unifies two closed records only when their fields match exactly,
so this identity function stops compiling the moment the kernel-blocked guard
regresses and re-admits `formaction` / `onbeforetoggle` / `once` / `is` /
`innerhtml` to the row.

Which is the claim worth pinning. A missing SETTER is caught by
`bad/BlockedFormactionSetter.elm`, but a capability field left behind in the row
would be invisible from Elm and would let any hand-rolled open producer write the
attribute onto the element (see `bad/BlockedFormactionRow.elm`).

-}
type alias ExpectedBlockedAttrs =
    { class : HtmlIr.Kind.Supported
    , id : HtmlIr.Kind.Supported
    , label : HtmlIr.Kind.Supported
    , slot : HtmlIr.Kind.Supported
    , style : HtmlIr.Kind.Supported
    }


blockedRowIsExactly : Hz.Component.Blocked.Attrs -> ExpectedBlockedAttrs
blockedRowIsExactly row =
    row


page : HtmlIr.Element.Element { s | attrSlot : Hz.Kind.Brand } admittedBy Msg
page =
    Hz.attrSlot [] [ attrSlot1, attrSlot2, textElementEl, hzCapitalTextEl, textAtom, blockedEl, blockedPipe ]


view : Html Msg
view =
    HtmlIr.Node.toHtml (HtmlIr.Element.toNode page)
