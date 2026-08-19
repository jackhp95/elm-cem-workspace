module DomOutputTest exposing (suite)

{-| DOM-output shape tests (plan §3.2): render representative top-layer `M3e.*`
compositions through the single eager exit (`M3e.toHtml`) and assert the shape of the emitted `Html`. Where the IR
package's own runtime suites (`MergeTest`, `IrCoreTest`, `NodeSlotTest` — they
live in `elm-html-intermediate-representation/tests/`, next to the code they pin)
probe the hand-written IR-core reductions in isolation, this suite pins the
_public_ contract a screen author sees: the right `<m3e-*>` custom-element tag,
slot stamping on slotted children, attribute/token emission, and — the class of
bug a dom-diff ordering regression would introduce — that children keep their
authored order with no reordering, dropping, or deduplication (IR faithfulness).

These assertions run against the barrel API exactly as the examples and the
`building-m3e-uis` skill teach it (`M3e.text` for slotted text), so a regen that
quietly changed a tag name, dropped a slot stamp, or reordered children would fail
here rather than only in the Playwright runtime harness.

Ported to the phantom substrate: the two-step `HtmlIr.Element.toNode` then
`HtmlIr.Node.toHtml` render path collapsed into `M3e.toHtml`; attribute setters
moved to `M3e.Values` (variant tokens) and the per-component modules
(`M3e.Component.Icon.name`, `M3e.Component.Button.icon`, `M3e.Component.ListItem.leading`); `aria-label` has no
typed setter, so it crosses the library's lint-fenced escape
`M3e.Unsafe.Attributes.fromHtmlAttribute` (formerly the userland `Seam.asAttribute`,
now deleted along with the rest of `docs/kit/Seam.elm`). Slotted text was the
userland `Kit.text` seam when this suite was written; the unseam migration made it
a library value (`M3e.text`, same signature), so the calls below moved onto the
barrel.

-}

import Expect
import Html.Attributes as HtmlAttr
import M3e
import M3e.Action as Action
import M3e.Component.Button
import M3e.Component.Icon
import M3e.Component.ListItem
import M3e.Unsafe.Attributes
import M3e.Values as Value
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


{-| The one render path a screen uses: `Element` -> `Html` (the IR `Node` step is
internal to `M3e.toHtml`), then into a query. This is the only eager point,
mirroring a `view` root. Rendered as the query root so the top-level `<m3e-*>`
tag is directly assertable.
-}
toQuery : M3e.Element accepts admittedBy msg -> Query.Single msg
toQuery el =
    M3e.toHtml el
        |> Query.fromHtml


suite : Test
suite =
    describe "DOM-output shape of representative compositions"
        [ describe "custom-element tag emission"
            [ test "M3e.button renders an <m3e-button>" <|
                \_ ->
                    M3e.button [] [ M3e.text "Save" ]
                        |> toQuery
                        |> Query.has [ Selector.tag "m3e-button" ]
            , test "M3e.iconButton renders an <m3e-icon-button> wrapping an <m3e-icon>" <|
                \_ ->
                    M3e.iconButton [ M3e.Unsafe.Attributes.fromHtmlAttribute (HtmlAttr.attribute "aria-label" "Back") ]
                        [ M3e.icon [ M3e.Component.Icon.name "arrow_back" ] [] ]
                        |> toQuery
                        |> Expect.all
                            [ Query.has [ Selector.tag "m3e-icon-button" ]
                            , Query.findAll [ Selector.tag "m3e-icon" ] >> Query.count (Expect.equal 1)
                            ]
            ]
        , describe "attribute and token emission"
            [ test "a variant token becomes a variant= attribute on the host" <|
                \_ ->
                    M3e.button [ M3e.Component.Button.variant Value.filled ] [ M3e.text "Go" ]
                        |> toQuery
                        |> Query.has
                            [ Selector.tag "m3e-button"
                            , Selector.attribute (HtmlAttr.attribute "variant" "filled")
                            ]
            , test "an aria-label setter becomes an aria-label attribute" <|
                \_ ->
                    M3e.iconButton [ M3e.Unsafe.Attributes.fromHtmlAttribute (HtmlAttr.attribute "aria-label" "Close") ]
                        [ M3e.icon [ M3e.Component.Icon.name "close" ] [] ]
                        |> toQuery
                        |> Query.has
                            [ Selector.attribute (HtmlAttr.attribute "aria-label" "Close") ]
            , test "an icon's name setter becomes a name attribute" <|
                \_ ->
                    M3e.icon [ M3e.Component.Icon.name "menu" ] []
                        |> toQuery
                        |> Query.has [ Selector.attribute (HtmlAttr.attribute "name" "menu") ]
            ]
        , describe "slot stamping on slotted children"
            [ test "M3e.Component.Button.icon stamps slot=icon on the placed icon" <|
                \_ ->
                    M3e.button []
                        [ M3e.Component.Button.icon (M3e.icon [ M3e.Component.Icon.name "add" ] [])
                        , M3e.text "Add"
                        ]
                        |> toQuery
                        |> Query.find [ Selector.tag "m3e-icon" ]
                        |> Query.has [ Selector.attribute (HtmlAttr.attribute "slot" "icon") ]
            , test "M3e.Component.ListItem.leading stamps slot=leading on the placed content" <|
                \_ ->
                    M3e.listItem []
                        [ M3e.Component.ListItem.leading (M3e.icon [ M3e.Component.Icon.name "star" ] [])
                        , M3e.text "Starred"
                        ]
                        |> toQuery
                        |> Query.find [ Selector.attribute (HtmlAttr.attribute "slot" "leading") ]
                        |> Query.has [ Selector.tag "m3e-icon" ]
            ]
        , describe "IR faithfulness — authored order preserved, no dedup"
            [ test "default-slot children keep their authored order" <|
                \_ ->
                    M3e.list []
                        [ M3e.listItem [] [ M3e.text "first" ]
                        , M3e.listItem [] [ M3e.text "second" ]
                        , M3e.listItem [] [ M3e.text "third" ]
                        ]
                        |> toQuery
                        |> Query.findAll [ Selector.tag "m3e-list-item" ]
                        |> Expect.all
                            [ Query.count (Expect.equal 3)
                            , Query.index 0 >> Query.has [ Selector.text "first" ]
                            , Query.index 1 >> Query.has [ Selector.text "second" ]
                            , Query.index 2 >> Query.has [ Selector.text "third" ]
                            ]
            , test "two like leading icons across rows are both emitted (no dedup of like children)" <|
                \_ ->
                    M3e.list []
                        [ M3e.listItem []
                            [ M3e.Component.ListItem.leading (M3e.icon [ M3e.Component.Icon.name "star" ] [])
                            , M3e.text "one"
                            ]
                        , M3e.listItem []
                            [ M3e.Component.ListItem.leading (M3e.icon [ M3e.Component.Icon.name "star" ] [])
                            , M3e.text "two"
                            ]
                        ]
                        |> toQuery
                        |> Query.findAll [ Selector.tag "m3e-icon" ]
                        |> Query.count (Expect.equal 2)
            ]
        , describe "action wrappers nest INSIDE the clickable host (M3e.Action)"
            -- The upstream contract (decompiled `ActionElementBase`): every
            -- `m3e-*-trigger`/`-toggle`/`-action` element is `display:contents`,
            -- attaches its click handler to `this.parentElement`, and toggles/
            -- anchors against `this.parentElement`. So it MUST be emitted as a
            -- CHILD of the clickable host, wrapping the label — never as an outer
            -- wrapper around the host. `M3e.Component.Button.component` does this by placing
            -- `Action.wrapContent action content` among the `m3e-button` children.
            -- These tests pin that nesting direction so a regen or an `Action`
            -- refactor that inverted it (host inside the toggle) fails loudly here
            -- instead of silently mis-anchoring the popup at runtime.
            [ test "togglesDatepicker emits <m3e-datepicker-toggle for> as a child of the host, wrapping the label" <|
                \_ ->
                    M3e.Component.Button.component
                        { content = M3e.text "Pick date"
                        , action = Action.togglesDatepicker "cal1"
                        }
                        []
                        []
                        |> toQuery
                        |> Expect.all
                            [ -- the query root is the clickable host itself
                              Query.has [ Selector.tag "m3e-button" ]
                            , -- the toggle is a DESCENDANT of that host, carrying `for` + the label
                              Query.find [ Selector.tag "m3e-datepicker-toggle" ]
                                >> Query.has
                                    [ Selector.attribute (HtmlAttr.attribute "for" "cal1")
                                    , Selector.text "Pick date"
                                    ]
                            ]
            , test "togglesTimepicker mirrors datepicker — <m3e-timepicker-toggle for> nested in the host (symmetry lock)" <|
                \_ ->
                    -- Also a compile-lock: `togglesTimepicker` only type-checks here
                    -- if `M3e.Button`'s ActionCaps admits `timepickerToggle`, i.e.
                    -- the config mirror landed in the required.action roster too.
                    M3e.Component.Button.component
                        { content = M3e.text "Pick time"
                        , action = Action.togglesTimepicker "clock1"
                        }
                        []
                        []
                        |> toQuery
                        |> Expect.all
                            [ Query.has [ Selector.tag "m3e-button" ]
                            , Query.find [ Selector.tag "m3e-timepicker-toggle" ]
                                >> Query.has
                                    [ Selector.attribute (HtmlAttr.attribute "for" "clock1")
                                    , Selector.text "Pick time"
                                    ]
                            ]
            , test "the toggle is INNER — no clickable host nested inside it (anti-inversion)" <|
                \_ ->
                    M3e.Component.Button.component
                        { content = M3e.text "Pick date"
                        , action = Action.togglesDatepicker "cal1"
                        }
                        []
                        []
                        |> toQuery
                        |> Query.find [ Selector.tag "m3e-datepicker-toggle" ]
                        |> Query.findAll [ Selector.tag "m3e-button" ]
                        |> Query.count (Expect.equal 0)
            , test "an opens-trigger wrapper (opensMenu) nests the same way — the whole family shares the contract" <|
                \_ ->
                    M3e.Component.Button.component
                        { content = M3e.text "Open menu"
                        , action = Action.opensMenu "menu1"
                        }
                        []
                        []
                        |> toQuery
                        |> Expect.all
                            [ Query.has [ Selector.tag "m3e-button" ]
                            , Query.find [ Selector.tag "m3e-menu-trigger" ]
                                >> Query.has
                                    [ Selector.attribute (HtmlAttr.attribute "for" "menu1")
                                    , Selector.text "Open menu"
                                    ]
                            ]
            ]
        ]
