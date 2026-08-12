module MiniNative exposing
    ( NativeCtx
    , NativeKind
    , class
    , delegate
    , div
    , keyedList
    , legendish
    , onClick
    , option
    , select
    , text
    )

{-| A hand-written stand-in for the GENERATED native brand (`TypedHtml`),
exercising exactly the shapes the generator will emit on the IR: per-brand
markers, producer-open/consumer-closed two-row constructors, capability-rowed
setters, and the `delegate` escape as a lever composition. Forges via
`HtmlIr.Internal` — legitimately, as generated code inside the lint fence.
-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as I
import HtmlIr.Kind exposing (Shared, Supported)
import Json.Decode


{-| The native brand's private kind marker.
-}
type NativeKind
    = NativeKind


{-| The native brand's private context marker.
-}
type NativeCtx
    = NativeCtx


{-| Shared text atom: open accepts (`sharedText : Shared`), open admittedBy
(valid anywhere) — crosses into any brand's opted-in slot.
-}
text : String -> Element { s | sharedText : Shared } admittedBy msg
text s =
    I.fromNode (I.text s)


{-| Permissive structural container: kind-permissive on children
(`childAccepts` free), injects its own context demand into each child's
admittedBy, leaves its OWN admittedBy polymorphic.
-}
div :
    List (Attr { class : Supported } msg)
    -> List (Element childAccepts { childAdm | div : NativeCtx } msg)
    -> Element { acc | div : NativeKind } admittedBy msg
div attrs children =
    I.fromNode (I.node "div" attrs (List.map HtmlIr.Element.toNode children))


{-| Restricted container: children closed to option kind.
-}
select :
    List (Attr { class : Supported } msg)
    -> List (Element { option : NativeKind } { childAdm | select : NativeCtx } msg)
    -> Element { acc | select : NativeKind } admittedBy msg
select attrs children =
    I.fromNode (I.node "select" attrs (List.map HtmlIr.Element.toNode children))


{-| Restricted-parent element: closed admittedBy — only valid under
select/optgroup. The bidirectional acid-test carrier.
-}
option :
    List (Attr { class : Supported } msg)
    -> List (Element { sharedText : Shared } { childAdm | option : NativeCtx } msg)
    -> Element { acc | option : NativeKind } { select : NativeCtx, optgroup : NativeCtx } msg
option attrs children =
    I.fromNode (I.node "option" attrs (List.map HtmlIr.Element.toNode children))


{-| Cross-brand context-privacy probe: a native element declaring itself valid
only in the native `modal` context. The FIELD NAME collides with MiniM3e's
`modal` context on purpose — the marker types must keep them apart.
-}
legendish : String -> Element { acc | legendish : NativeKind } { modal : NativeCtx } msg
legendish s =
    I.fromNode (I.node "legend" [] [ I.text s ])


{-| Keyed container over the `keyedNode` lever — typed children with diff
keys, kind-permissive like div.
-}
keyedList :
    List ( String, Element childAccepts { childAdm | keyedList : NativeCtx } msg )
    -> Element { acc | keyedList : NativeKind } admittedBy msg
keyedList entries =
    I.fromNode (I.keyedNode "ul" [] (List.map (Tuple.mapSecond HtmlIr.Element.toNode) entries))


{-| Global attribute — shared capability field, admitted by any brand's
element that lists `class`.
-}
class : String -> Attr { c | class : Supported } msg
class v =
    I.attribute "class" v


{-| Interactive-only event: elements admit it by listing `onClick`.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick m =
    I.on "click" (Json.Decode.succeed m)


{-| The loud bubbling escape — capability-forget via the dedicated `recast`
lever, exactly how the generated brand will implement it.

The old composition (`fromHtmlAttribute << toHtmlAttribute`) laundered the
attribute through `Html.Attribute`, which cannot represent an absent or
multi-fact `Attr`. `recast` is structural, so nothing is lost.

-}
delegate : Attr capability msg -> Attr anyCapability msg
delegate a =
    I.recast a
