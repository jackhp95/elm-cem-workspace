module Route.Components.Compose exposing (ActionData, Data, Model, Msg, route)

{-| **Compose** — a headless, type-directed editor for building a valid tree
of custom elements from `M3e.Review.Facts`, backed by `Cem.Compose`.

This route owns no editing logic itself: `Cem.Compose` owns the tree and the
path-addressed edits, `Compose.Attrs` (generated) supplies the attribute
kind/dispatch table, `Compose.Render` folds the tree to the live preview,
and `Compose.Codegen` folds it to the generated-code snippet. This module is
the app-shell boundary — where the phantom `M3e` rows get erased once via
`M3e.Unsafe.fromHtml`, because which component is on screen is only known at
runtime.

The recursive editor (`viewNode`) renders one card per node, each with its
attribute and slot chips and, when open, that node's menu.

-}

import BackendTask
import Cem.Compose
import Compose.Attrs as Attrs
import Compose.Codegen as Codegen
import Compose.Render as Render
import Doc
import Effect exposing (Effect)
import Head
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Badge
import M3e.Component.Card
import M3e.Component.IconButton
import M3e.Component.Menu
import M3e.Component.MenuItem
import M3e.Events
import M3e.Review.Facts
import M3e.Unsafe
import M3e.Values as Value
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes as TA
import TypedHtml.Events as TE
import TypedHtml.Grouping
import UrlPath exposing (UrlPath)
import View exposing (View)


type alias Model =
    { compose : Cem.Compose.Model }


type Msg
    = ComposeMsg Cem.Compose.Msg


type alias RouteParams =
    {}


type alias Data =
    {}


type alias ActionData =
    {}


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single { head = head, data = BackendTask.succeed {} }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


{-| Root component `"list"` is a deliberate starting choice: `list.unnamed`
is a pure-nesting slot with five component options and no text, so the
recursive case is visible immediately.
-}
init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { compose =
            Cem.Compose.init
                { facts = M3e.Review.Facts.facts
                , attrKinds = Attrs.kinds
                , root = "list"
                }
      }
    , Effect.none
    )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ (ComposeMsg composeMsg) model =
    ( { model | compose = Cem.Compose.update composeMsg model.compose }, Effect.none )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ model =
    View.fromElement "Compose"
        (M3e.mapMsg PagesMsg.fromMsg
            (M3e.mapMsg ComposeMsg (Doc.pane [ screen model.compose ]))
        )


{-| A heading, the live preview, the recursive editor, and the generated-code
snippet.
-}
screen : Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
screen compose =
    TypedHtml.div [ TA.class "space-y-4" ]
        [ Doc.pageHeading ("Compose: " ++ Cem.Compose.componentOf compose.root)
        , M3e.Unsafe.fromHtml (Render.renderNode compose.root)
        , viewNode [] compose.root compose
        , Doc.codeBlock Doc.Elm (Codegen.codeFor compose.root)
        ]



-- EDITOR --------------------------------------------------------------------


{-| One `M3e.card` per `Cem.Compose.Node`: a header naming the component (with
the edit-tag control alongside it), its attribute and slot chips, that node's
menu (if open), and a recursive card per child node.
-}
viewNode : Cem.Compose.Path -> Cem.Compose.Node -> Cem.Compose.Model -> Element (M3e.Component.Card.Is s) admittedBy Cem.Compose.Msg
viewNode path node model =
    M3e.card
        [ M3e.Attributes.variant Value.outlined ]
        [ M3e.Component.Card.header
            (TypedHtml.div [ TA.class "flex items-center gap-2" ]
                [ Doc.sectionLabel (Cem.Compose.componentOf node)
                , editTagControl path model
                ]
            )
        , M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex flex-col gap-3" ]
                [ TypedHtml.div [ TA.class "flex flex-wrap gap-2" ]
                    (List.map (attrChipView path model) (Cem.Compose.attrChips path model)
                        ++ List.map (slotChipView path model) (Cem.Compose.slotChips path model)
                    )
                , freeTextMenuFor path model
                , TypedHtml.div [ TA.class "pl-4 flex flex-col gap-3" ]
                    (childCards path node model)
                ]
            )
        ]


{-| The edit-tag affordance: change this node's component in place.
`Cem.Compose.componentOptions` is already type-directed — a nested node only
offers what its parent slot accepts, and the current component is already
excluded — so an empty list means there is genuinely nothing valid to change
to, and no control is rendered at all. Same `button` + `menuTrigger` +
always-present `menu` shape as the slot/attr chips (`M3e.filterChip` still
cannot host a trigger). The root's option list is every known component, so
its menu is height-capped and scrolls rather than overflowing the page.
-}
editTagControl : Cem.Compose.Path -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
editTagControl path model =
    case Cem.Compose.componentOptions path model of
        [] ->
            TypedHtml.div [] []

        _ ->
            TypedHtml.div []
                [ M3e.button
                    [ M3e.Attributes.variant Value.text
                    , M3e.Attributes.shape Value.rounded
                    , Aria.label "Change component"
                    ]
                    [ M3e.menuTrigger [ M3e.Attributes.for (componentMenuId path) ]
                        [ M3e.icon [] [ M3e.text "edit" ] ]
                    ]
                , componentMenuElement path model
                ]


{-| The always-present menu the edit-tag control's `menuTrigger` points at by
id — one item per `componentOptions` entry, each firing `SetComponent`.
Capped in height so the root's (potentially long) list scrolls instead of
overflowing the page.
-}
componentMenuElement : Cem.Compose.Path -> Cem.Compose.Model -> Element (M3e.Component.Menu.Is s) admittedBy Cem.Compose.Msg
componentMenuElement path model =
    M3e.menu
        [ M3e.Attributes.id (componentMenuId path)
        , M3e.Attributes.class "max-h-64 overflow-y-auto"
        ]
        (Cem.Compose.componentOptions path model
            |> List.map (\name -> menuItemView name (Cem.Compose.SetComponent path name))
        )


componentMenuId : Cem.Compose.Path -> String
componentMenuId path =
    "compose-component-menu-" ++ pathId path


{-| `m3e-chip-set`'s `Content` admits only bare `chip`/`filterChip` elements,
not a `menuTrigger`-wrapped one, so chips that open a real menu (every slot
chip, and enum/bool attr chips) are laid out in a plain flex-wrap `div`
instead — `menuTrigger` needs to wrap (or be wrapped by) its trigger, which a
closed-content chip set does not admit.

A discrete-choice attribute (`EnumChip`/`BoolAttr`) is wrapped in
`M3e.menuTrigger`, referencing an always-present, id-addressed `M3e.menu` by
`for` — the widget owns showing/hiding its own popover; `Cem.Compose.openMenu`
is not what drives visibility here, only which attribute a click targets.
A free-text attribute (`String`/`Float`/`Int`) keeps the plain
`OpenMenu`-driven chip, whose inline text field is Elm-rendered content in
normal flow (`freeTextMenuFor`), not a popover — so it needs no menu-trigger
pairing at all.

-}
attrChipView : Cem.Compose.Path -> Cem.Compose.Model -> Cem.Compose.AttrChipInfo -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
attrChipView path model info =
    case info.kind of
        Cem.Compose.EnumChip _ ->
            discreteAttrChip path model info

        Cem.Compose.PlainChip Cem.Compose.BoolAttr ->
            discreteAttrChip path model info

        Cem.Compose.PlainChip _ ->
            TypedHtml.div [ TA.class "inline-flex" ]
                (M3e.filterChip
                    [ M3e.Attributes.id (attrChipHostId path info.name)
                    , M3e.Attributes.selected info.isSet
                    , M3e.Events.onClick (Cem.Compose.OpenMenu path (Cem.Compose.AttrMenu info.name))
                    ]
                    [ M3e.text info.name ]
                    :: attrValueBadge path info
                )


{-| `M3e.filterChip` cannot host `menuTrigger` at all (its `Content` admits
only `heading`/`sharedText`), and `M3e.button` is the ONLY host verified to
scope a trigger's click to itself — nesting `menuTrigger` inside a
`filterChip` sibling of other triggers was tried and found to open every
sibling's menu at once (the trigger's click-detection walks up past a
`filterChip` host to a shared ancestor). So the discrete-choice control is a
toggle `button`, not a `filterChip`; `menu` itself is a SIBLING of the
button, not nested inside it (`Button.Content` admits `menuTrigger`, not
`menu`) — exactly the shape in `M3eMenuTriggerElement`'s own doc example.
-}
discreteAttrChip : Cem.Compose.Path -> Cem.Compose.Model -> Cem.Compose.AttrChipInfo -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
discreteAttrChip path model info =
    TypedHtml.div [ TA.class "inline-flex" ]
        (M3e.button
            [ M3e.Attributes.id (attrChipHostId path info.name)
            , M3e.Attributes.selected info.isSet
            , M3e.Attributes.toggle True
            , M3e.Events.onClick (Cem.Compose.OpenMenu path (Cem.Compose.AttrMenu info.name))
            ]
            [ M3e.menuTrigger [ M3e.Attributes.for (attrMenuId path info.name) ]
                [ M3e.text info.name ]
            ]
            :: attrValueBadge path info
            ++ [ discreteAttrMenu path model info ]
        )


{-| The always-present menu a discrete attr chip's `menuTrigger` points at by
id — built directly from `attrMenuOptions`, not gated on `model.openMenu`.
-}
discreteAttrMenu : Cem.Compose.Path -> Cem.Compose.Model -> Cem.Compose.AttrChipInfo -> Element (M3e.Component.Menu.Is s) admittedBy Cem.Compose.Msg
discreteAttrMenu path model info =
    M3e.menu [ M3e.Attributes.id (attrMenuId path info.name) ]
        (case Cem.Compose.attrMenuOptions path info.name model of
            Just (Cem.Compose.EnumTokens tokens _) ->
                tokens
                    |> List.map
                        (\token ->
                            menuItemView token (Cem.Compose.SetAttr path info.name (Cem.Compose.AttrEnum token))
                        )

            Just (Cem.Compose.BoolToggle _) ->
                [ menuItemView "On" (Cem.Compose.SetAttr path info.name (Cem.Compose.AttrBool True))
                , menuItemView "Off" (Cem.Compose.SetAttr path info.name (Cem.Compose.AttrBool False))
                ]

            _ ->
                []
        )


attrMenuId : Cem.Compose.Path -> String -> String
attrMenuId path name =
    "compose-attr-menu-" ++ pathId path ++ "-" ++ name


slotMenuId : Cem.Compose.Path -> String -> String
slotMenuId path slotName =
    "compose-slot-menu-" ++ pathId path ++ "-" ++ slotName


pathId : Cem.Compose.Path -> String
pathId path =
    path
        |> List.map (\(Cem.Compose.IntoSlot slot index) -> slot ++ String.fromInt index)
        |> String.join "_"
        |> (\s ->
                if String.isEmpty s then
                    "root"

                else
                    s
           )


attrChipHostId : Cem.Compose.Path -> String -> String
attrChipHostId path name =
    "compose-attr-chip-" ++ pathId path ++ "-" ++ name


{-| The "set" indicator: a badge carrying the current value, present only
when the attribute is actually set (`isSet`) — an unset attribute gets no
badge at all, since there is nothing to show. The chip's own label is just
the attribute name; this is what used to be crammed into "name: value" text.
-}
attrValueBadge : Cem.Compose.Path -> Cem.Compose.AttrChipInfo -> List (Element (M3e.Component.Badge.Is s) admittedBy Cem.Compose.Msg)
attrValueBadge path info =
    case attrValueText info of
        Just text ->
            [ M3e.badge [ M3e.Attributes.for (attrChipHostId path info.name) ] [ M3e.text text ] ]

        Nothing ->
            []


attrValueText : Cem.Compose.AttrChipInfo -> Maybe String
attrValueText info =
    case info.currentValue of
        Just (Cem.Compose.AttrEnum token) ->
            Just token

        Just (Cem.Compose.AttrString s) ->
            Just s

        Just (Cem.Compose.AttrFloat s) ->
            Just s

        Just (Cem.Compose.AttrInt s) ->
            Just s

        Just (Cem.Compose.AttrBool True) ->
            Just "on"

        Just (Cem.Compose.AttrBool False) ->
            Just "off"

        Nothing ->
            Nothing


{-| Just the slot name, prefixed to read as the "add here" affordance it is —
the `filled`/`max` count moved to a badge (`slotCountBadge`).
-}
slotChipLabel : Cem.Compose.SlotChipInfo -> String
slotChipLabel info =
    "+ " ++ info.name


slotChipHostId : Cem.Compose.Path -> String -> String
slotChipHostId path slotName =
    "compose-slot-chip-" ++ pathId path ++ "-" ++ slotName


{-| `filled`/`max`: the plain count when the slot is multi (`max = Nothing`),
`"filled/max"` otherwise — the machine-readable form moved out of the chip's
own label and onto a badge attached to it by id.
-}
slotCountBadge : Cem.Compose.Path -> Cem.Compose.SlotChipInfo -> Element (M3e.Component.Badge.Is s) admittedBy Cem.Compose.Msg
slotCountBadge path info =
    M3e.badge [ M3e.Attributes.for (slotChipHostId path info.name) ]
        [ M3e.text (slotCountText info) ]


slotCountText : Cem.Compose.SlotChipInfo -> String
slotCountText info =
    case info.max of
        Nothing ->
            String.fromInt info.filled

        Just max ->
            String.fromInt info.filled ++ "/" ++ String.fromInt max


{-| When a slot affords exactly one option, the chip fires that message
directly instead of opening a one-item menu — a consumer convenience, not a
core rule (spec §7.2 step 2). Otherwise it's wrapped in `menuTrigger`,
pointing at an always-present menu with one item per `SlotOption` — this must
not collapse to one representative choice (spec §8.7): a slot that affords
text, an icon, AND components offers all of them at once.
-}
slotChipView : Cem.Compose.Path -> Cem.Compose.Model -> Cem.Compose.SlotChipInfo -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
slotChipView path model info =
    case Cem.Compose.slotMenuOptions path info.name model of
        [ only ] ->
            TypedHtml.div [ TA.class "inline-flex" ]
                [ M3e.filterChip
                    [ M3e.Attributes.id (slotChipHostId path info.name)
                    , M3e.Attributes.selected (info.filled > 0)
                    , M3e.Events.onClick (msgForOption path info.name only)
                    ]
                    [ M3e.text (slotChipLabel info) ]
                , slotCountBadge path info
                ]

        _ ->
            TypedHtml.div [ TA.class "inline-flex" ]
                [ M3e.button
                    [ M3e.Attributes.id (slotChipHostId path info.name)
                    , M3e.Attributes.selected (info.filled > 0)
                    , M3e.Attributes.toggle True
                    , M3e.Events.onClick (Cem.Compose.OpenMenu path (Cem.Compose.SlotMenu info.name))
                    ]
                    [ M3e.menuTrigger [ M3e.Attributes.for (slotMenuId path info.name) ]
                        [ M3e.text (slotChipLabel info) ]
                    ]
                , slotCountBadge path info
                , slotMenuElement path model info.name
                ]


msgForOption : Cem.Compose.Path -> String -> Cem.Compose.SlotOption -> Cem.Compose.Msg
msgForOption path slotName option =
    case option of
        Cem.Compose.OptionText ->
            Cem.Compose.AddTextChild path slotName

        Cem.Compose.OptionIcon ->
            Cem.Compose.AddIconChild path slotName

        Cem.Compose.OptionComponent name ->
            Cem.Compose.AddChild path slotName name


{-| The free-text attribute menu for this path, if `model.openMenu` matches
it — the only case still gated on `openMenu`, since a `TextInput`/
`NumberInput` field is plain Elm-rendered content in normal flow, not a
popover, so it needs no `menuTrigger` pairing.
-}
freeTextMenuFor : Cem.Compose.Path -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
freeTextMenuFor path model =
    case model.openMenu of
        Just ( openPath, Cem.Compose.AttrMenu name ) ->
            if openPath == path then
                freeTextAttrView path name model

            else
                TypedHtml.div [] []

        _ ->
            TypedHtml.div [] []


freeTextAttrView : Cem.Compose.Path -> String -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
freeTextAttrView path name model =
    case Cem.Compose.attrMenuOptions path name model of
        Just (Cem.Compose.TextInput current) ->
            textInputRow current (\text -> Cem.Compose.SetAttr path name (Cem.Compose.AttrString text))

        Just (Cem.Compose.NumberInput Cem.Compose.FloatNumber current) ->
            textInputRow current (\text -> Cem.Compose.SetAttr path name (Cem.Compose.AttrFloat text))

        Just (Cem.Compose.NumberInput Cem.Compose.IntNumber current) ->
            textInputRow current (\text -> Cem.Compose.SetAttr path name (Cem.Compose.AttrInt text))

        _ ->
            TypedHtml.div [] []


{-| The always-present menu a slot chip's `menuTrigger` points at by id — one
item per `SlotOption`, built directly from `slotMenuOptions`, not gated on
`model.openMenu`.
-}
slotMenuElement : Cem.Compose.Path -> Cem.Compose.Model -> String -> Element (M3e.Component.Menu.Is s) admittedBy Cem.Compose.Msg
slotMenuElement path model slotName =
    M3e.menu [ M3e.Attributes.id (slotMenuId path slotName) ]
        (Cem.Compose.slotMenuOptions path slotName model
            |> List.map
                (\option ->
                    case option of
                        Cem.Compose.OptionText ->
                            menuItemView "Text" (Cem.Compose.AddTextChild path slotName)

                        Cem.Compose.OptionIcon ->
                            menuItemView "Icon" (Cem.Compose.AddIconChild path slotName)

                        Cem.Compose.OptionComponent name ->
                            menuItemView name (Cem.Compose.AddChild path slotName name)
                )
        )


textInputRow : String -> (String -> Cem.Compose.Msg) -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
textInputRow current toMsg =
    TypedHtml.div [ TA.class "pl-4" ]
        [ TypedHtml.input
            [ TA.value current
            , TE.onInput toMsg
            ]
            []
        ]


menuItemView : String -> Cem.Compose.Msg -> Element (M3e.Component.MenuItem.Is s) admittedBy Cem.Compose.Msg
menuItemView label msg =
    M3e.menuItem [ M3e.Events.onClick msg ] [ M3e.text label ]


{-| One row per child across every slot: a recursive card for `ChildNode`, an
inline text field for `ChildText`/`ChildIcon`, and a remove control on every
row regardless of kind.
-}
childCards : Cem.Compose.Path -> Cem.Compose.Node -> Cem.Compose.Model -> List (Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg)
childCards path node model =
    Cem.Compose.slotsOf node
        |> List.concatMap
            (\( slotName, children ) ->
                children
                    |> List.indexedMap
                        (\i child ->
                            TypedHtml.div [ TA.class "flex items-start gap-2" ]
                                [ TypedHtml.div [ TA.class "flex-1" ]
                                    [ childContent path slotName i child model ]
                                , removeButton (Cem.Compose.RemoveChild path slotName i)
                                ]
                        )
            )


childContent : Cem.Compose.Path -> String -> Int -> Cem.Compose.Child -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
childContent path slotName index child model =
    case child of
        Cem.Compose.ChildNode inner ->
            TypedHtml.div [] [ viewNode (path ++ [ Cem.Compose.IntoSlot slotName index ]) inner model ]

        Cem.Compose.ChildText text ->
            textInputRow text (Cem.Compose.SetChildContent path slotName index)

        Cem.Compose.ChildIcon glyph ->
            textInputRow glyph (Cem.Compose.SetChildContent path slotName index)


removeButton : Cem.Compose.Msg -> Element (M3e.Component.IconButton.Is s) admittedBy Cem.Compose.Msg
removeButton msg =
    M3e.iconButton [ Aria.label "Remove", M3e.Events.onClick msg ]
        [ M3e.icon [] [ M3e.text "close" ] ]
