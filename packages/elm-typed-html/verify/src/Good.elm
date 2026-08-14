module Good exposing (categories, controls, escapes, page, view)

{-| The /tmp/htmlia good-case ports, on the GENERATED TypedHtml: composition
families (Table / Select+Form / Media) with zero inner annotations, transparent
<a>, ARIA hybrid good halves, and the render boundary.
-}

import Html
import HtmlIr.Element
import HtmlIr.Node
import TypedHtml as H
import TypedHtml.Aria as Aria
import TypedHtml.Attributes as At
import TypedHtml.Component.Button as Button
import TypedHtml.Events as Ev
import TypedHtml.Component.Grouping
import TypedHtml.Component.Input as Input
import TypedHtml.Component.Select as Select
import TypedHtml.Component.Text as Text
import TypedHtml.Unsafe as Unsafe
import TypedHtml.Values as V


type Msg
    = Never_
    | GotText String
    | GotChecked Bool


page : HtmlIr.Element.Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
page =
    H.div [ At.class "page", Aria.role Aria.navigation, Aria.label "Main" ]
        [ -- AfterTable: co-located table family, no inner annotations
          H.table []
            [ H.caption [] [ H.text "Quarterly" ]
            , H.thead [] [ H.tr [] [ H.th [] [ H.text "Q" ], H.th [ At.colspan 2 ] [ H.text "Revenue" ] ] ]
            , H.tbody [] [ H.tr [] [ H.td [] [ H.text "Q1" ], H.td [] [ H.text "100" ] ] ]
            ]

        -- AfterSelectFormMedia: select > (option | optgroup > option)
        --
        -- `<option value>` is a plain CONTENT attribute: `HTMLOptionElement.value`
        -- reflects it, HTML gives the element no `defaultValue` counterpart, and it is
        -- the form that serializes. Only `<input>` is in `_controlled`'s `value` scope.
        , H.select [] [ H.option [ At.value "1" ] [ H.text "One" ], H.optgroup [] [ H.option [] [ H.text "Two" ] ] ]

        -- form > fieldset > (legend + label + select)
        , H.form []
            [ H.fieldset []
                [ H.legend [] [ H.text "Choices" ]
                , H.label [ At.for "sel" ] [ H.text "Pick" ]
                , H.select [ At.id "sel" ] [ H.option [] [ H.text "A" ] ]
                ]
            ]

        -- media: video > (source + track + fallback), picture > pictureSource
        , H.video [] [ H.source [ At.src "v.mp4" ] [], H.track [ At.src "v.vtt" ] [], H.text "fallback" ]
        , H.picture [] [ H.pictureSource [ At.srcset "a.png" ] [] ]

        -- transparent <a> with block content, in flow context
        , H.a [ At.href "/more" ] [ H.p [] [ H.text "Read more" ] ]

        -- AriaCheckedOk: value-typed tristate on any element
        , H.span [ Aria.checked Aria.mixed ] [ H.text "tri" ]

        -- AriaHiddenOk: aria-hidden is enum-valued (true/false/undefined per
        -- WHATWG/ARIA), and reuses the true/false/undefined tokens the other
        -- states already mint rather than forging new ones.
        , H.span [ Aria.hidden Aria.true ] [ H.text "ghost" ]

        -- The three attributes the manifest had typed `number`, and the `_variants`
        -- setters that make the ergonomic form available without narrowing the base.
        --
        -- Each base MUST stay a String: `step="any"` is a keyword no Float expresses,
        -- `coords` is a comma-separated LIST, and `<time datetime>` is a date/time
        -- string. `datetime` is the one that shipped broken — <time>'s spurious
        -- `number` outranked <ins>/<del>'s `string` in the shared vocabulary and the
        -- string side was dropped silently, so BOTH forms below were unwritable.
        , H.time [ At.datetime "2024-01-01T12:00" ] [ H.text "noon" ]
        , H.ins [ At.datetime "2024-01-01" ] [ H.text "added" ]
        , H.del [ At.datetime "2024-01-02" ] [ H.text "removed" ]
        , H.input [ At.type_ "number", At.step "any", At.valueAsNumber 2.5 ] []
        , H.input [ At.type_ "range", At.stepAsNumber 0.5 ] []
        , H.map []
            [ H.area [ At.coords "0,0,82,126", At.shape V.rect ] []
            , H.area [ At.coordsAsInts [ 0, 0, 82, 126 ] ] []
            ]

        -- `value` is FOUR value spaces under one HTML name, and the numeric three do
        -- not share the `value` capability ROW with the string one. `<meter>` and
        -- `<progress>` admit `valueNumeric : Float` and `<li>` admits
        -- `valueOrdinal : Int`; none of the three has a `value` field in its `Attrs`
        -- record at all, which is what bad/ValueOnProgress and bad/ValueOnLi pin.
        --
        -- That divergence is a crash made unrepresentable, not a tidying-up.
        -- `HTMLMeterElement.value` and `HTMLProgressElement.value` are RESTRICTED IDL
        -- `double`, `TypedHtml.Attributes.value` writes the DOM property (correct for
        -- `<input>`, which is what it is overwhelmingly used for), and Web IDL answers
        -- `progress.value = "60%"` with a TypeError — thrown inside virtual-dom's
        -- `applyFacts`, i.e. mid-patch, where it aborts the patch and takes the render
        -- loop with it. Measured: the exception escapes the animation-frame callback,
        -- Elm re-schedules, and it re-throws ~60 times a second on an idle page.
        -- Scoping the property form to `<input>` avoided that; leaving the row is what
        -- makes it uncallable.
        --
        -- Both diverged setters write the CONTENT attribute, which is what these
        -- elements want anyway — their IDL `value` reflects — and their Elm types make
        -- the serialized string well-formed by construction: `String.fromFloat` cannot
        -- produce a non-finite double, and `String.fromInt` cannot produce a
        -- non-integer ordinal.
        , H.meter [ At.valueNumeric 0.6, At.max "1" ] [ H.text "60%" ]
        , H.progress [ At.valueNumeric 0.6, At.max "1" ] [ H.text "60%" ]
        , H.ul [] [ H.li [ At.valueOrdinal 3 ] [ H.text "third" ] ]

        -- The home modules re-export them under the same names, so the strict surface
        -- agrees with the loose one. `TypedHtml.Text` exposes BOTH `value : String`
        -- (for `<data>`, a reflected DOMString) and `valueNumeric : Float` (for
        -- `<meter>`/`<progress>`) — one module, two names, two rows. That is exactly
        -- what a shared name could not have expressed: elm-cem's `guardHomeAttrTypes`
        -- refuses one module exposing one name at two types, which is why the setter
        -- NAME had to diverge and not just the capability.
        , H.meter [ Text.valueNumeric 0.6 ] [ H.text "60%" ]
        , H.data [ Text.value "42" ] [ H.text "forty-two" ]
        , H.ul [] [ H.li [ TypedHtml.Grouping.valueOrdinal 2 ] [ H.text "second" ] ]

        -- The other side of the split: `<input>` IS controlled, so `At.value` writes
        -- its live DOM property, `At.defaultValue` writes the content attribute HTML
        -- calls `defaultValue` (the serializing half, and what a form reset restores
        -- to), and `At.valueAsNumber` writes the same property with the same JS type.
        -- All three claim the one `value` row, so no `Attrs` record grew a field.
        , Input.input [ Input.value "live", At.type_ "text" ] []
        , Input.input [ Input.defaultValue "initial", At.type_ "text" ] []
        , Input.input [ Input.valueAsNumber 42, At.type_ "number" ] []
        , Input.input [ At.value "live", At.defaultValue "initial", At.type_ "text" ] []

        -- …and the three elements that KEEP the `value` row do so because their IDL
        -- attribute is a reflected `DOMString`: a string property write is harmless
        -- there, and their own modules still hand them the content-attribute form,
        -- which is the one that serializes.
        , H.button [ Button.value "submitted" ] [ H.text "Go" ]
        , H.select [] [ H.option [ Select.value "1" ] [ H.text "One" ] ]

        -- B4 type family: `type` on button / input / script, admitted by each
        -- element's capability row (a bad element rejects it — see bad/TypeOnDiv).
        , H.button [ At.type_ "button", At.tabindex 0 ] [ H.text "Go" ]
        , H.input [ At.type_ "checkbox", At.checked True, At.hidden V.hidden ] []
        , H.script [ At.type_ "module", At.dir V.ltr ] [ H.text "" ]

        -- B4 globals: the previously-missing WHATWG global attributes, on any element.
        -- TYPED, not free strings: the enumerated ones take a `Value <Row>` token, the
        -- presence booleans a `Bool`, `tabindex` an `Int`. As free strings these all
        -- compiled while meaning the wrong thing — `hidden "false"` HID the element,
        -- `inert "false"` made it inert, and `dir "rlt"` silently did nothing.
        , H.p
            [ At.contenteditable V.true
            , At.lang "en"
            , At.title "hi"
            , At.spellcheck V.false
            , At.translate V.no
            , At.draggable V.draggableTrue
            , At.inputmode V.numeric
            , At.autocapitalize V.sentences
            , At.autocorrect V.on
            , At.enterkeyhint V.send
            , At.popover V.manual
            , At.writingsuggestions V.writingsuggestionsFalse
            , At.itemscope True
            ]
            [ H.text "editable" ]

        -- `-1` is the whole reason `tabindex` is an `Int` and not a natural: it makes
        -- the element script-focusable but skips it in sequential navigation.
        , H.span [ At.tabindex -1, At.autofocus False, At.inert True, At.hidden V.untilFound ] [ H.text "skipped" ]

        -- ── The eleven spec-INTEGER attributes, all `Int -> Attr` ──────────────
        --
        -- These were `Float -> Attr` for a whole release line, because the manifest
        -- typed them `number` and `Attr.classifyText` had no `integer` spelling to
        -- resolve to `AInt`. `String.fromFloat` can then write four strings HTML's
        -- integer parsers REJECT — "2.5", "NaN", "Infinity", "1e+21" — and a rejected
        -- attribute value is not an ignored one: the parser substitutes the
        -- attribute's DEFAULT. So `colspan="2.5"` rendered as ONE column and the table
        -- silently lost the other. `elm/html` types all eleven `Int`.
        --
        -- bad/ColspanFloat and bad/WidthNotFinite pin the two shapes that must now
        -- fail. What `Int` does NOT pin is RANGE — see those files for why "the
        -- integers >= 1" is not a type Elm can spell, and why that residue is the
        -- milder failure (HTML accepts an out-of-range integer and clamps it to the
        -- spec default; it discards a malformed one).
        , H.table []
            [ H.colgroup [] [ H.col [ At.span 2 ] [] ]
            , H.tbody []
                [ H.tr []
                    [ -- `rowspan="0"` is LEGAL and means "span to the end of the row
                      -- group" — which is why `rowspan` is "Valid non-negative
                      -- integer" and NOT its sibling `colspan`'s "greater than zero".
                      H.td [ At.rowspan 0, At.colspan 3 ] [ H.text "wide" ]
                    ]
                ]
            ]
        , H.textarea [ At.rows 4, At.cols 40, At.maxlength 100, At.minlength 2 ] []
        , H.select [ At.size 4 ] [ H.option [] [ H.text "A" ] ]
        , H.input [ At.type_ "text", At.size 20, At.maxlength 100, At.minlength 2 ] []

        -- `<input type=image>` is the one input with intrinsic dimensions.
        , H.input [ At.type_ "image", At.src "go.png", At.width 32, At.height 32 ] []

        -- `start` is "Valid INTEGER", not non-negative: `<ol start="-3">` counts up
        -- from -3. So even a hypothetical natural-number type would be wrong here —
        -- the same reason `tabindex` and `<li value>` (`valueOrdinal`) are `Int`.
        , H.ol [ At.start -3 ] [ H.li [] [ H.text "minus three" ] ]

        -- `width`/`height` on all six embedded-content elements plus <video>.
        , H.img [ At.src "a.png", At.alt "a", At.width 640, At.height 480 ] []
        , H.canvas [ At.width 300, At.height 150 ] []
        , H.video [ At.width 640, At.height 360 ] []
        , H.iframe [ At.src "/f", At.width 800, At.height 600 ] []
        , H.embed [ At.src "e.swf", At.width 100, At.height 100 ] []
        , H.object [ At.width 100, At.height 100 ] []
        , H.picture [] [ H.pictureSource [ At.srcset "a.png", At.width 640, At.height 480 ] [] ]

        -- The counterweight, and the reason the fix is a second SPELLING rather than
        -- "numbers are integers now": `<meter>`'s limits really are "Valid
        -- floating-point number", so they stay `number` → `Float -> Attr`. A blanket
        -- retype would have made `high 0.8` unwritable. check-whatwg's
        -- MUST_STAY_NUMBER refuses that direction too.
        , H.meter [ At.low 0.2, At.high 0.8, At.optimum 0.9, At.valueNumeric 0.6 ] [ H.text "60%" ]
        ]


{-| #2 event-bearing form controls: the payload-typed setters are admitted by the
input / textarea / select capability rows (a div rejects them — see
bad/OnInputOnDiv). `onInput`/`onChange` hand the consumer the target `String` and
`onCheck` the `Bool` (elm/html's mental model), baked in with no hand-written
decoder. `input` admits `onCheck` (not `onChange`); select/textarea admit
`onChange`. #5 custom-property-safe `styleList` emits one `style=""` string, so a
`--custom-prop` is preserved (elm/html's builder would drop it).
-}
controls : List (HtmlIr.Element.Element {} {} Msg)
controls =
    [ H.input
        [ Ev.onInput GotText
        , Ev.onCheck GotChecked
        , At.styleList [ ( "--brand-gap", "1px" ), ( "color", "red" ) ]
        ]
        []
        |> Unsafe.recast
    , H.textarea [ Ev.onInput GotText, Ev.onChange GotText ] []
        |> Unsafe.recast
    , H.select [ Ev.onInput GotText, Ev.onChange GotText ]
        [ H.option [] [ H.text "A" ] ]
        |> Unsafe.recast
    ]


{-| #3 the blessed recast: `Unsafe.recast` re-kinds a single element to FREE
rows; `Unsafe.recastAll` maps it over a list. Replaces the hand-forged
`Seam.recast` / `List.map Seam.recast`.
-}
escapes : List (HtmlIr.Element.Element {} {} Msg)
escapes =
    Unsafe.recastAll
        [ H.span [] [ H.text "one" ]
        , Unsafe.recast (H.p [] [ H.text "two" ])
        ]


{-| RC5 positives: the shared CONTENT-CATEGORY vocabulary, from the native side.

Each of these used to be admitted by an enumerated 55- or 86-field row that
listed every legal tag by name. They are now admitted by a category — same
answers, a tenth of the fields, and (unlike a tag list) a vocabulary a foreign
brand can also speak.

-}
categories : List (HtmlIr.Element.Element {} {} Msg)
categories =
    Unsafe.recastAll
        -- phrasing ⊆ flow: a flow row names BOTH categories, so both fit.
        [ H.li [] [ H.span [] [ H.text "phrasing in flow" ], H.p [] [ H.text "flow in flow" ] ]

        -- `img` and `area` keep per-tag kinds, so phrasing rows name them explicitly.
        , H.span [] [ H.img [ At.src "x.png" ] [] ]

        -- …which is what keeps `<picture>` exact (see bad/PhrasingInPicture.elm).
        , H.picture [] [ H.pictureSource [ At.srcset "a.png" ] [], H.img [ At.src "x.png" ] [] ]

        -- The narrow rows are untouched: `<ul>` still admits only `<li>`.
        , H.ul [] [ H.li [] [ H.text "item" ] ]

        -- Metadata keeps per-tag identity on both sides of the boundary:
        -- legal in `<head>` AND nameable inside phrasing content.
        , H.head [] [ H.title [] [ H.text "t" ], H.script [] [] ]
        , H.span [] [ H.script [] [], H.template [] [] ]
        ]


view : Html.Html Msg
view =
    HtmlIr.Node.toHtml (HtmlIr.Element.toNode page)
