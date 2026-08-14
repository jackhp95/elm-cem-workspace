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

The recursive editor (`viewNode`) renders one nested outlined `M3e.card` per
node, each with its attribute and slot buttons (in two separated groups) and,
when open, that node's menu.

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
import M3e.Component.Button
import M3e.Component.Card
import M3e.Component.FormField
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


{-| One nested outlined `M3e.card` per `Cem.Compose.Node` — the component
name itself IS the edit-tag control (a text-variant button opening the
change-component menu), its attribute and slot buttons in two separated
groups (mixing "set an attribute" and "add a child" controls in one row
reads as one affordance when they are two), that node's menu (if open), and
a recursive card per child node.
-}
viewNode : Cem.Compose.Path -> Cem.Compose.Node -> Cem.Compose.Model -> Element (M3e.Component.Card.Is s) admittedBy Cem.Compose.Msg
viewNode path node model =
    M3e.card
        [ M3e.Attributes.variant Value.outlined ]
        [ TypedHtml.div [ TA.class "flex flex-col gap-3" ]
            [ nameControl path node model
            , attrGroup path model
            , slotGroup path model
            , freeTextMenuFor path model
            ]
        , TypedHtml.div [ TA.class "pl-4 flex flex-col gap-3" ]
            (childCards path node model)
        ]


{-| The Attributes group — every attribute button, under its own label,
never sharing a row with the Slots group below. The buttons themselves sit
directly in an `M3e.buttonGroup` (whose unnamed slot admits only
`button`/`iconButton`); each discrete attribute's always-present menu is a
sibling of the group rather than nested in it — `menuTrigger`/`menu` are
addressed by id, so their DOM position doesn't matter.
-}
attrGroup : Cem.Compose.Path -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
attrGroup path model =
    case Cem.Compose.attrChips path model of
        [] ->
            TypedHtml.div [] []

        chips ->
            TypedHtml.div [ TA.class "flex flex-col gap-2" ]
                (groupLabel "Attributes"
                    :: M3e.buttonGroup [] (List.map (attrButtonElement path) chips)
                    :: attrMenusFor path model chips
                )


{-| The Slots (add-child) group — every slot button, under its own label,
never sharing a row with the Attributes group above. Same buttonGroup +
sibling-menus shape as `attrGroup`; the per-slot fill-count badges are a
second sibling row (badges aren't `button`/`iconButton` either, so they
can't live inside the group).
-}
slotGroup : Cem.Compose.Path -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
slotGroup path model =
    case Cem.Compose.slotChips path model of
        [] ->
            TypedHtml.div [] []

        chips ->
            TypedHtml.div [ TA.class "flex flex-col gap-2" ]
                (groupLabel "Slots"
                    :: M3e.buttonGroup [] (List.map (slotButtonElement path model) chips)
                    :: TypedHtml.div [ TA.class "flex flex-wrap gap-2" ] (List.map slotCountBadge chips)
                    :: slotMenusFor path model chips
                )


groupLabel : String -> Element (TypedHtml.Grouping.PIs s) admittedBy msg
groupLabel label =
    TypedHtml.p [ TA.class "text-label-sm text-on-surface-variant uppercase tracking-wide" ] [ TypedHtml.text label ]


{-| The component name doubles as the edit-tag control: a text-variant button
whose own label IS the current component name, opening the change-component
menu. `Cem.Compose.componentOptions` is already type-directed — a nested node
only offers what its parent slot accepts, and the current component is
already excluded — so an empty list means there is genuinely nothing valid to
change to, and the name renders as plain text instead. Same `button` +
`menuTrigger` + always-present `menu` shape as the slot/attr buttons
(`M3e.filterChip` cannot host a trigger at all). The root's option list is
every known component, so its menu is height-capped and scrolls rather than
overflowing the page.
-}
nameControl : Cem.Compose.Path -> Cem.Compose.Node -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
nameControl path node model =
    case Cem.Compose.componentOptions path model of
        [] ->
            TypedHtml.div [] [ Doc.sectionLabel (Cem.Compose.componentOf node) ]

        _ ->
            TypedHtml.div [ TA.class "flex items-center gap-2" ]
                [ M3e.button
                    [ M3e.Attributes.variant Value.text ]
                    [ M3e.menuTrigger [ M3e.Attributes.for (componentMenuId path) ]
                        [ M3e.text (Cem.Compose.componentOf node) ]
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


{-| Every attribute control is an extra-small `M3e.button`, never a chip
(chips read as filter/selection state, not as "open this to set a value").
A discrete-choice attribute (`EnumChip`/`BoolAttr`) is wrapped in
`M3e.menuTrigger`, referencing an always-present, id-addressed `M3e.menu` by
`for` — the widget owns showing/hiding its own popover; `Cem.Compose.openMenu`
is not what drives visibility here, only which attribute a click targets.
A free-text attribute (`String`/`Float`/`Int`) keeps the plain
`OpenMenu`-driven button, whose inline text field is Elm-rendered content in
normal flow (`freeTextMenuFor`), not a popover — so it needs no menu-trigger
pairing at all.
-}
attrButtonElement : Cem.Compose.Path -> Cem.Compose.AttrChipInfo -> Element (M3e.Component.Button.Is s) admittedBy Cem.Compose.Msg
attrButtonElement path info =
    case info.kind of
        Cem.Compose.EnumChip _ ->
            discreteAttrButtonElement path info

        Cem.Compose.PlainChip Cem.Compose.BoolAttr ->
            discreteAttrButtonElement path info

        Cem.Compose.PlainChip _ ->
            M3e.button
                [ M3e.Attributes.id (attrButtonHostId path info.name)
                , M3e.Attributes.size Value.extraSmall
                , M3e.Attributes.variant
                    (if info.isSet then
                        Value.filled

                     else
                        Value.elevated
                    )
                , M3e.Attributes.selected info.isSet
                , M3e.Attributes.toggle True
                , M3e.Events.onClick (Cem.Compose.OpenMenu path (Cem.Compose.AttrMenu info.name))
                ]
                [ M3e.text (attrButtonLabel info) ]


{-| Every discrete attribute's always-present menu, one per chip that is
`EnumChip`/`BoolAttr` — the sibling-of-the-buttonGroup half of the
`attrButtonElement` split (plain free-text chips have no menu at all; their
inline field is `freeTextMenuFor`).
-}
attrMenusFor : Cem.Compose.Path -> Cem.Compose.Model -> List Cem.Compose.AttrChipInfo -> List (Element (M3e.Component.Menu.Is s) admittedBy Cem.Compose.Msg)
attrMenusFor path model chips =
    chips
        |> List.filterMap
            (\info ->
                case info.kind of
                    Cem.Compose.EnumChip _ ->
                        Just (discreteAttrMenu path model info)

                    Cem.Compose.PlainChip Cem.Compose.BoolAttr ->
                        Just (discreteAttrMenu path model info)

                    Cem.Compose.PlainChip _ ->
                        Nothing
            )


{-| `M3e.filterChip` cannot host `menuTrigger` at all (its `Content` admits
only `heading`/`sharedText`), and `M3e.button` is the ONLY host verified to
scope a trigger's click to itself — nesting `menuTrigger` inside a
`filterChip` sibling of other triggers was tried and found to open every
sibling's menu at once (the trigger's click-detection walks up past a
`filterChip` host to a shared ancestor). `menu` itself is a SIBLING of the
button, not nested inside it (`Button.Content` admits `menuTrigger`, not
`menu`) — exactly the shape in `M3eMenuTriggerElement`'s own doc example.
Now that the button sits directly in an `M3e.buttonGroup` (whose unnamed
slot admits only `button`/`iconButton`), the menu is a sibling of the GROUP
instead, built separately by `attrMenusFor` — the `for`/id pairing is
unaffected by that move.
-}
discreteAttrButtonElement : Cem.Compose.Path -> Cem.Compose.AttrChipInfo -> Element (M3e.Component.Button.Is s) admittedBy Cem.Compose.Msg
discreteAttrButtonElement path info =
    M3e.button
        [ M3e.Attributes.id (attrButtonHostId path info.name)
        , M3e.Attributes.size Value.extraSmall
        , M3e.Attributes.variant
            (if info.isSet then
                Value.filled

             else
                Value.elevated
            )
        , M3e.Attributes.selected info.isSet
        , M3e.Attributes.toggle True
        , M3e.Events.onClick (Cem.Compose.OpenMenu path (Cem.Compose.AttrMenu info.name))
        ]
        [ M3e.menuTrigger [ M3e.Attributes.for (attrMenuId path info.name) ]
            [ M3e.text (attrButtonLabel info) ]
        ]


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


attrButtonHostId : Cem.Compose.Path -> String -> String
attrButtonHostId path name =
    "compose-attr-button-" ++ pathId path ++ "-" ++ name


{-| The attribute name, plus its current value when set (e.g. `"variant:
filled"`) — no separate badge; the value belongs in the label of the one
control that sets it, not floating decoration on the side (spec: badges are
for counts, not values).
-}
attrButtonLabel : Cem.Compose.AttrChipInfo -> String
attrButtonLabel info =
    case attrValueText info of
        Just value ->
            info.name ++ ": " ++ value

        Nothing ->
            info.name


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


{-| `filled`/`max`: the plain count when the slot is multi (`max = Nothing`),
`"filled/max"` otherwise — an inline badge, its own unnamed slot carrying the
count text, rendered as a plain sibling next to the slot button rather than
anchored to it by `for`/`position` (app precedent: `Guide/Seams.elm`'s
`M3e.badge [] [ M3e.text "3" ]`). Counts are what badges are for; the add
affordance itself lives in the button's label.
-}
slotCountBadge : Cem.Compose.SlotChipInfo -> Element (M3e.Component.Badge.Is s) admittedBy Cem.Compose.Msg
slotCountBadge info =
    M3e.badge [] [ M3e.text (slotCountText info) ]


slotCountText : Cem.Compose.SlotChipInfo -> String
slotCountText info =
    case info.max of
        Nothing ->
            String.fromInt info.filled

        Just max ->
            String.fromInt info.filled ++ "/" ++ String.fromInt max


{-| When a slot affords exactly one option, the button fires that message
directly instead of opening a one-item menu — a consumer convenience, not a
core rule (spec §7.2 step 2). Otherwise it's wrapped in `menuTrigger`,
pointing at an always-present menu with one item per `SlotOption` — this must
not collapse to one representative choice (spec §8.7): a slot that affords
text, an icon, AND components offers all of them at once. Every case is an
extra-small `M3e.button`, never a chip, its content a leading `add` icon
(never a literal "+") then the slot name. Sits directly in an
`M3e.buttonGroup`, so the fill-count badge and (when present) the menu are
built as siblings by `slotGroup`, not nested here.
-}
slotButtonElement : Cem.Compose.Path -> Cem.Compose.Model -> Cem.Compose.SlotChipInfo -> Element (M3e.Component.Button.Is s) admittedBy Cem.Compose.Msg
slotButtonElement path model info =
    case Cem.Compose.slotMenuOptions path info.name model of
        [ only ] ->
            M3e.button
                [ M3e.Attributes.size Value.extraSmall
                , M3e.Attributes.variant
                    (if info.filled > 0 then
                        Value.filled

                     else
                        Value.elevated
                    )
                , M3e.Attributes.selected (info.filled > 0)
                , M3e.Events.onClick (msgForOption path info.name only)
                ]
                [ M3e.icon [ TA.name "add" ] []
                , M3e.text info.name
                ]

        _ ->
            M3e.button
                [ M3e.Attributes.size Value.extraSmall
                , M3e.Attributes.variant
                    (if info.filled > 0 then
                        Value.filled

                     else
                        Value.elevated
                    )
                , M3e.Attributes.selected (info.filled > 0)
                , M3e.Attributes.toggle True
                , M3e.Events.onClick (Cem.Compose.OpenMenu path (Cem.Compose.SlotMenu info.name))
                ]
                [ M3e.menuTrigger [ M3e.Attributes.for (slotMenuId path info.name) ]
                    [ M3e.icon [ TA.name "add" ] []
                    , M3e.text info.name
                    ]
                ]


{-| Every multi-option slot's always-present menu — the sibling-of-the-
buttonGroup half of the `slotButtonElement` split (a single-option slot fires
its message directly and has no menu at all).
-}
slotMenusFor : Cem.Compose.Path -> Cem.Compose.Model -> List Cem.Compose.SlotChipInfo -> List (Element (M3e.Component.Menu.Is s) admittedBy Cem.Compose.Msg)
slotMenusFor path model chips =
    chips
        |> List.filterMap
            (\info ->
                case Cem.Compose.slotMenuOptions path info.name model of
                    [ _ ] ->
                        Nothing

                    _ ->
                        Just (slotMenuElement path model info.name)
            )


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


{-| One row per child across every slot: a recursive card for `ChildNode`
with a separate `removeButton` beside it (reordering is a separate,
out-of-scope discussion, so no leading drag handle), and a labeled
`M3e.formField` for `ChildText`/`ChildIcon` whose built-in `suffix` slot
carries the delete control instead — the field IS the row for those two
kinds, not a row plus a bolted-on sibling.
-}
childCards : Cem.Compose.Path -> Cem.Compose.Node -> Cem.Compose.Model -> List (Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg)
childCards path node model =
    Cem.Compose.slotsOf node
        |> List.concatMap
            (\( slotName, children ) ->
                children
                    |> List.indexedMap
                        (\i child -> childRow path slotName i child model)
            )


childRow : Cem.Compose.Path -> String -> Int -> Cem.Compose.Child -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
childRow path slotName index child model =
    case child of
        Cem.Compose.ChildNode inner ->
            TypedHtml.div [ TA.class "flex items-start gap-2" ]
                [ TypedHtml.div [ TA.class "flex-1" ]
                    [ viewNode (path ++ [ Cem.Compose.IntoSlot slotName index ]) inner model ]
                , removeButton (Cem.Compose.RemoveChild path slotName index)
                ]

        Cem.Compose.ChildText text ->
            TypedHtml.div [] [ childFormField "Text" text path slotName index ]

        Cem.Compose.ChildIcon glyph ->
            TypedHtml.div [] [ childFormField "Icon" glyph path slotName index ]


{-| A labeled text field for a `ChildText`/`ChildIcon` slot child — `label`
names which kind of content this is ("Text"/"Icon"), the plain `<input>`
carries the current value, and `suffix` carries the trailing delete button.
No leading drag handle (reordering is out of scope for this pass).
-}
childFormField : String -> String -> Cem.Compose.Path -> String -> Int -> Element (M3e.Component.FormField.Is s) admittedBy Cem.Compose.Msg
childFormField labelText current path slotName index =
    M3e.formField []
        [ M3e.Component.FormField.label (M3e.text labelText)
        , TypedHtml.input
            [ TA.value current
            , TE.onInput (Cem.Compose.SetChildContent path slotName index)
            ]
            []
        , M3e.Component.FormField.suffix
            (M3e.iconButton
                [ Aria.label "Remove"
                , M3e.Events.onClick (Cem.Compose.RemoveChild path slotName index)
                ]
                [ M3e.icon [ TA.name "close" ] [] ]
            )
        ]


removeButton : Cem.Compose.Msg -> Element (M3e.Component.IconButton.Is s) admittedBy Cem.Compose.Msg
removeButton msg =
    M3e.iconButton [ Aria.label "Remove", M3e.Events.onClick msg ]
        [ M3e.icon [ TA.name "close" ] [] ]
