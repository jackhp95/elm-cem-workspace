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
import M3e.Component.Heading
import M3e.Component.IconButton
import M3e.Component.Menu
import M3e.Component.MenuItem
import M3e.Events
import M3e.Review.Facts
import M3e.Unsafe
import M3e.Values as Value
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Set exposing (Set)
import Shared
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes as TA
import TypedHtml.Events as TE
import TypedHtml.Grouping
import UrlPath exposing (UrlPath)
import View exposing (View)


type alias Model =
    { compose : Cem.Compose.Model
    , collapsed : Set String
    , prefill : Bool
    }


type Msg
    = ComposeMsg Cem.Compose.Msg
    | ToggleCollapse String
    | TogglePrefill


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
recursive case is visible immediately. The editor opens with a small starter
tree (`starterEdits`) rather than an empty root, so there is something to edit
straight away.
-}
init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { compose =
            List.foldl Cem.Compose.update
                (Cem.Compose.init
                    { facts = M3e.Review.Facts.facts
                    , attrKinds = Attrs.kinds
                    , root = "list"
                    }
                )
                starterEdits
      , collapsed = Set.empty
      , prefill = True
      }
    , Effect.none
    )


{-| A small starter tree so the editor opens with something to work from rather
than an empty root: two labeled list items — enough to reveal the reorder arrows,
which only appear once a slot holds more than one child. Any of it can be deleted.
-}
starterEdits : List Cem.Compose.Msg
starterEdits =
    [ Cem.Compose.AddChild [] "unnamed" "listItem"
    , Cem.Compose.AddChild [] "unnamed" "listItem"
    , Cem.Compose.AddTextChild [ Cem.Compose.IntoSlot "unnamed" 0 ] "unnamed"
    , Cem.Compose.SetChildContent [ Cem.Compose.IntoSlot "unnamed" 0 ] "unnamed" 0 "First item"
    , Cem.Compose.AddTextChild [ Cem.Compose.IntoSlot "unnamed" 1 ] "unnamed"
    , Cem.Compose.SetChildContent [ Cem.Compose.IntoSlot "unnamed" 1 ] "unnamed" 0 "Second item"
    ]


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        ComposeMsg composeMsg ->
            ( { model | compose = applyCompose model.prefill composeMsg model.compose }, Effect.none )

        ToggleCollapse pid ->
            ( { model
                | collapsed =
                    if Set.member pid model.collapsed then
                        Set.remove pid model.collapsed

                    else
                        Set.insert pid model.collapsed
              }
            , Effect.none
            )

        TogglePrefill ->
            ( { model | prefill = not model.prefill }, Effect.none )


{-| Apply a `Cem.Compose.Msg`, with one consumer-level nicety governed by the
"Prefill examples" toggle: when it is on, a freshly added text child is seeded
with placeholder copy and a freshly added child COMPONENT gets an example text
child in its first text-affording slot, so the preview shows something the
moment it is added; when off, adds land empty. The core stays content-agnostic
(it adds an empty `ChildText`); the placeholder is a demo choice that belongs
here, in the consumer. Every seed is guarded so it never clobbers real content.
-}
applyCompose : Bool -> Cem.Compose.Msg -> Cem.Compose.Model -> Cem.Compose.Model
applyCompose prefill composeMsg compose =
    let
        updated : Cem.Compose.Model
        updated =
            Cem.Compose.update composeMsg compose
    in
    if not prefill then
        updated

    else
        case composeMsg of
            Cem.Compose.AddTextChild path slotName ->
                seedText path slotName updated

            Cem.Compose.AddChild path slotName _ ->
                let
                    newIndex : Int
                    newIndex =
                        slotChildCount path slotName updated - 1
                in
                seedExample (path ++ [ Cem.Compose.IntoSlot slotName newIndex ]) updated

            _ ->
                updated


{-| Seed the just-added empty text child in `slotName` with "lorem ipsum",
if that is in fact what is there (never clobbers real content).
-}
seedText : Cem.Compose.Path -> String -> Cem.Compose.Model -> Cem.Compose.Model
seedText path slotName compose =
    let
        newIndex : Int
        newIndex =
            slotChildCount path slotName compose - 1
    in
    if childAt path slotName newIndex compose == Just (Cem.Compose.ChildText "") then
        Cem.Compose.update (Cem.Compose.SetChildContent path slotName newIndex "lorem ipsum") compose

    else
        compose


{-| Give the freshly added component at `childPath` a small example: a text
child (seeded with placeholder copy) in its first text-affording slot. A
component with no text slot is left as-is.
-}
seedExample : Cem.Compose.Path -> Cem.Compose.Model -> Cem.Compose.Model
seedExample childPath compose =
    case firstTextSlot childPath compose of
        Just slotName ->
            seedText childPath slotName (Cem.Compose.update (Cem.Compose.AddTextChild childPath slotName) compose)

        Nothing ->
            compose


{-| The first slot of the node at `path` that affords a text child, if any.
-}
firstTextSlot : Cem.Compose.Path -> Cem.Compose.Model -> Maybe String
firstTextSlot path compose =
    Cem.Compose.slotChips path compose
        |> List.filter (\chip -> List.member Cem.Compose.OptionText (Cem.Compose.slotMenuOptions path chip.name compose))
        |> List.head
        |> Maybe.map .name


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ model =
    View.fromElement "Compose"
        (M3e.mapMsg PagesMsg.fromMsg (Doc.pane [ screen model ]))


{-| A heading, the panel bar, the live preview, the recursive editor, and the
generated-code snippet. Only the panel bar and the editor emit real messages;
the heading/preview/snippet are static (msg-polymorphic), so they sit in the
same `Msg`-typed tree without wrapping.
-}
screen : Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
screen model =
    TypedHtml.div [ TA.class "space-y-4" ]
        [ Doc.pageHeading ("Compose: " ++ Cem.Compose.componentOf model.compose.root)
        , panelBar model
        , M3e.Unsafe.fromHtml (Render.renderNode model.compose.root)
        , viewNode [] model.compose.root model
        , Doc.codeBlock Doc.Elm (Codegen.codeFor model.compose.root)
        ]


{-| The compose panel bar: a "Prefill examples" switch. When on, adding a text
child or a component seeds example content (see `applyCompose`); when off, adds
land empty so you build from a blank component.
-}
panelBar : Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
panelBar model =
    TypedHtml.div [ TA.class "flex items-center gap-2" ]
        [ M3e.switch
            [ M3e.Attributes.checked model.prefill
            , Aria.label "Prefill examples"
            , M3e.Events.onClick TogglePrefill
            ]
            []
        , TypedHtml.span [ TA.class "text-label-lg text-on-surface-variant" ]
            [ TypedHtml.text "Prefill examples" ]
        ]



-- EDITOR --------------------------------------------------------------------


{-| One nested outlined `M3e.card` per `Cem.Compose.Node` — the component
name itself IS the edit-tag control (a text-variant button opening the
change-component menu), its attribute and slot buttons in two separated
groups (mixing "set an attribute" and "add a child" controls in one row
reads as one affordance when they are two), that node's menu (if open), and
a recursive card per child node.
-}
viewNode : Cem.Compose.Path -> Cem.Compose.Node -> Model -> Element (M3e.Component.Card.Is s) admittedBy Msg
viewNode path node model =
    let
        collapsed : Bool
        collapsed =
            Set.member (pathId path) model.collapsed
    in
    M3e.card
        [ M3e.Attributes.variant Value.outlined ]
        [ TypedHtml.div [ TA.class "flex flex-col gap-3 p-3" ]
            (TypedHtml.div [ TA.class "flex items-center gap-2" ]
                [ collapseChevron path collapsed
                , M3e.mapMsg ComposeMsg (headerRow path node model.compose)
                ]
                :: (if collapsed then
                        []

                    else
                        [ M3e.mapMsg ComposeMsg
                            (TypedHtml.div [ TA.class "flex flex-col gap-3" ]
                                [ attrGroup path model.compose
                                , slotGroup path model.compose
                                , freeTextMenuFor path model.compose
                                ]
                            )
                        , TypedHtml.div [ TA.class "flex flex-col gap-3" ]
                            (childCards path node model)
                        ]
                   )
            )
        ]


{-| The leading collapse toggle for a node's card — a chevron icon button that
adds/removes this node's `pathId` from the collapsed set, hiding or showing its
body (attributes, slots, and child rows). The tag name and its controls stay
visible when collapsed.
-}
collapseChevron : Cem.Compose.Path -> Bool -> Element (M3e.Component.IconButton.Is s) admittedBy Msg
collapseChevron path collapsed =
    M3e.iconButton
        [ Aria.label
            (if collapsed then
                "Expand"

             else
                "Collapse"
            )
        , M3e.Events.onClick (ToggleCollapse (pathId path))
        ]
        [ M3e.icon
            [ TA.name
                (if collapsed then
                    "chevron_right"

                 else
                    "expand_more"
                )
            ]
            []
        ]


{-| The header of a node's card: the tag name as an `M3e.heading`, then — at the
trailing end — the edit-tag icon button, the up/down reorder row, and delete.
The reorder + delete controls derive the node's sibling position from the last
`PathStep` of its own path; the root (empty path) has no siblings, so it shows
only its tag and edit control.
-}
headerRow : Cem.Compose.Path -> Cem.Compose.Node -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
headerRow path node model =
    case nodePosition path of
        Nothing ->
            TypedHtml.div [ TA.class "flex items-center gap-2 flex-1" ]
                [ TypedHtml.div [ TA.class "flex-1" ] [ tagHeading node ]
                , editControl path model
                ]

        Just ( parentPath, slotName, index ) ->
            TypedHtml.div [ TA.class "flex items-center gap-2 flex-1" ]
                [ TypedHtml.div [ TA.class "flex-1" ] [ tagHeading node ]
                , editControl path model
                , reorderControls parentPath slotName index model
                , removeButton (Cem.Compose.RemoveChild parentPath slotName index)
                ]


{-| The node's tag name as a small title `M3e.heading` — a plain label now that
editing lives in its own `editControl` icon button (the tag used to double as the
change-component button).
-}
tagHeading : Cem.Compose.Node -> Element (M3e.Component.Heading.Is s) admittedBy Cem.Compose.Msg
tagHeading node =
    M3e.heading
        [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium ]
        [ M3e.text (Cem.Compose.componentOf node) ]


{-| A node's position among its siblings, read off the last step of its own
path: `Just ( parentPath, slotName, index )`, or `Nothing` for the root.
-}
nodePosition : Cem.Compose.Path -> Maybe ( Cem.Compose.Path, String, Int )
nodePosition path =
    case List.reverse path of
        (Cem.Compose.IntoSlot slotName index) :: revParent ->
            Just ( List.reverse revParent, slotName, index )

        [] ->
            Nothing


{-| Leading up/down reorder buttons for a child at `index` within `slotName`
of the node at `parentPath`. Reordering is meaningless for a lone child, so
nothing renders when the slot holds one or zero; otherwise each arrow is
disabled at the end it cannot move toward (the core `MoveChild` also clamps,
so a stray click is a harmless no-op). This replaces the item-2/6 drag handle
with a keyboard-accessible, browser-testable equivalent.
-}
reorderControls : Cem.Compose.Path -> String -> Int -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
reorderControls parentPath slotName index model =
    let
        count : Int
        count =
            slotChildCount parentPath slotName model
    in
    if count <= 1 then
        TypedHtml.div [] []

    else
        TypedHtml.div [ TA.class "flex flex-row" ]
            [ reorderButton "Move up" "arrow_upward" (index <= 0) (Cem.Compose.MoveChild parentPath slotName index (index - 1))
            , reorderButton "Move down" "arrow_downward" (index >= count - 1) (Cem.Compose.MoveChild parentPath slotName index (index + 1))
            ]


reorderButton : String -> String -> Bool -> Cem.Compose.Msg -> Element (M3e.Component.IconButton.Is s) admittedBy Cem.Compose.Msg
reorderButton label glyph isDisabled msg =
    M3e.iconButton
        [ Aria.label label
        , M3e.Attributes.disabled isDisabled
        , M3e.Events.onClick msg
        ]
        [ M3e.icon [ TA.name glyph ] [] ]


{-| How many children the node at `parentPath` holds in `slotName`.
-}
slotChildCount : Cem.Compose.Path -> String -> Cem.Compose.Model -> Int
slotChildCount parentPath slotName model =
    slotChildrenAt parentPath slotName model
        |> List.length


{-| The child at `index` of `slotName` under the node at `parentPath`, if any.
-}
childAt : Cem.Compose.Path -> String -> Int -> Cem.Compose.Model -> Maybe Cem.Compose.Child
childAt parentPath slotName index model =
    slotChildrenAt parentPath slotName model
        |> List.drop index
        |> List.head


slotChildrenAt : Cem.Compose.Path -> String -> Cem.Compose.Model -> List Cem.Compose.Child
slotChildrenAt parentPath slotName model =
    Cem.Compose.nodeAt parentPath model
        |> Maybe.map Cem.Compose.slotsOf
        |> Maybe.withDefault []
        |> List.filter (\( name, _ ) -> name == slotName)
        |> List.concatMap Tuple.second


{-| The Attributes group — every attribute button, under its own label,
never sharing a row with the Slots group below. The buttons wrap in a plain
`flex flex-wrap` row (an `M3e.buttonGroup` was rejected: it overflows rather
than wraps, and it stamps `role="radiogroup"`/`role="radio"` on these
independent toggles, implying a single-select exclusivity they do not have).
Each discrete attribute's always-present menu is a sibling rather than nested
— `menuTrigger`/`menu` are addressed by id, so their DOM position doesn't
matter.
-}
attrGroup : Cem.Compose.Path -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
attrGroup path model =
    case Cem.Compose.attrChips path model of
        [] ->
            TypedHtml.div [] []

        chips ->
            TypedHtml.div [ TA.class "flex flex-col gap-2" ]
                (TypedHtml.div [ TA.class "flex flex-wrap items-center gap-2" ]
                    (groupLabel "Attributes" :: List.map (attrButtonElement path) chips)
                    :: attrMenusFor path model chips
                )


{-| The Slots (add-child) group — every slot button, under its own label,
never sharing a row with the Attributes group above. Same `flex flex-wrap`
row + sibling-menus shape as `attrGroup`; each slot's fill-count badge rides
in its own button's `trailing-icon` slot, so there is no separate badge row.
-}
slotGroup : Cem.Compose.Path -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
slotGroup path model =
    case Cem.Compose.slotChips path model of
        [] ->
            TypedHtml.div [] []

        chips ->
            TypedHtml.div [ TA.class "flex flex-col gap-2" ]
                (TypedHtml.div [ TA.class "flex flex-wrap items-center gap-2" ]
                    (groupLabel "Slots" :: List.map (slotButtonElement path model) chips)
                    :: slotMenusFor path model chips
                )


groupLabel : String -> Element (TypedHtml.Grouping.PIs s) admittedBy msg
groupLabel label =
    TypedHtml.p [ TA.class "text-label-sm text-on-surface-variant uppercase tracking-wide" ] [ TypedHtml.text label ]


{-| The edit-tag control: an icon button that opens the change-component menu.
`Cem.Compose.componentOptions` is type-directed — a nested node only offers what
its parent slot accepts, and the current component is already excluded — so an
empty list means there is nothing valid to change to and no control renders.
An `M3e.iconButton` hosting the `menuTrigger` (its `Content` admits
`menuTrigger`; the always-present `menu` is its sibling, addressed by id). The
root's option list is every known component, so that menu is height-capped and
scrolls rather than overflowing the page.
-}
editControl : Cem.Compose.Path -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
editControl path model =
    case Cem.Compose.componentOptions path model of
        [] ->
            TypedHtml.div [] []

        _ ->
            TypedHtml.div [ TA.class "inline-flex" ]
                [ M3e.iconButton
                    [ Aria.label "Change component" ]
                    [ M3e.menuTrigger [ M3e.Attributes.for (componentMenuId path) ]
                        [ M3e.icon [ TA.name "edit" ] [] ]
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
`EnumChip`/`BoolAttr` — the sibling-of-the-row half of the
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
The button sits in a plain `flex flex-wrap` row, so the menu is a sibling of
that row, built separately by `attrMenusFor` — the `for`/id pairing is
unaffected by DOM position.
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


{-| The slot's fill count as the button's trailing badge — but ONLY when the
slot holds at least one child; an empty slot shows no badge at all (a `0` badge
is noise). Returned as a list so it can be `[]` when empty; `trailingIcon`'s
result type is fully polymorphic, so it slots into the button's content list.
-}
slotCountTrailing : Cem.Compose.SlotChipInfo -> List (Element free freeAdmittedBy Cem.Compose.Msg)
slotCountTrailing info =
    if info.filled > 0 then
        [ M3e.Component.Button.trailingIcon (slotCountBadge info) ]

    else
        []


{-| The plain fill count (just the numerator — no `/max` denominator), in a
neutral badge. `m3e-badge` has no color/variant attribute and defaults to the
error color, so its container/text CSS custom properties are overridden to a
quiet surface pair rather than red.
-}
slotCountBadge : Cem.Compose.SlotChipInfo -> Element (M3e.Component.Badge.Is s) admittedBy Cem.Compose.Msg
slotCountBadge info =
    M3e.badge
        [ M3e.Attributes.style "--m3e-badge-container-color" "var(--md-sys-color-surface-container-highest)"
        , M3e.Attributes.style "--m3e-badge-color" "var(--md-sys-color-on-surface-variant)"
        ]
        [ M3e.text (String.fromInt info.filled) ]


{-| When a slot affords exactly one option, the button fires that message
directly instead of opening a one-item menu — a consumer convenience, not a
core rule (spec §7.2 step 2). Otherwise it's wrapped in `menuTrigger`,
pointing at an always-present menu with one item per `SlotOption` — this must
not collapse to one representative choice (spec §8.7): a slot that affords
text, an icon, AND components offers all of them at once. Every case is an
extra-small `M3e.button`, never a chip, its content a leading `add` icon
(never a literal "+") then the slot name, with the fill-count badge (only when
the slot is non-empty) in the button's own `trailing-icon` slot. Sits in a
plain `flex flex-wrap` row, so
the (when present) menu is built as a sibling by `slotGroup`, not nested here.
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
                ([ M3e.icon [ TA.name "add" ] []
                 , M3e.text info.name
                 ]
                    ++ slotCountTrailing info
                )

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
                (M3e.menuTrigger [ M3e.Attributes.for (slotMenuId path info.name) ]
                    [ M3e.icon [ TA.name "add" ] []
                    , M3e.text info.name
                    ]
                    :: slotCountTrailing info
                )


{-| Every multi-option slot's always-present menu — the sibling-of-the-
row half of the `slotButtonElement` split (a single-option slot fires
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
(whose own header carries its reorder + delete controls), and a
reorder-prefixed labeled `M3e.formField` for `ChildText`/`ChildIcon` whose
built-in `suffix` slot carries the delete control.
-}
childCards : Cem.Compose.Path -> Cem.Compose.Node -> Model -> List (Element (TypedHtml.Grouping.DivIs s) admittedBy Msg)
childCards path node model =
    Cem.Compose.slotsOf node
        |> List.concatMap
            (\( slotName, children ) ->
                children
                    |> List.indexedMap
                        (\i child -> childRow path slotName i child model)
            )


{-| A `ChildNode` recurses into `viewNode` (route `Msg`); a `ChildText`/
`ChildIcon` renders its `Cem.Compose.Msg` field row, lifted to `Msg` with
`M3e.mapMsg ComposeMsg` at this boundary.
-}
childRow : Cem.Compose.Path -> String -> Int -> Cem.Compose.Child -> Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
childRow path slotName index child model =
    case child of
        Cem.Compose.ChildNode inner ->
            TypedHtml.div []
                [ viewNode (path ++ [ Cem.Compose.IntoSlot slotName index ]) inner model ]

        Cem.Compose.ChildText text ->
            M3e.mapMsg ComposeMsg (childFieldRow "Text" text path slotName index model.compose)

        Cem.Compose.ChildIcon glyph ->
            M3e.mapMsg ComposeMsg (childFieldRow "Icon" glyph path slotName index model.compose)


{-| A `ChildText`/`ChildIcon` row: the labeled `M3e.formField` (whose own
`suffix` slot carries the delete), then the up/down reorder row at the trailing
end. The node case renders its reorder + delete inside the card header instead,
so its row is just the card.
-}
childFieldRow : String -> String -> Cem.Compose.Path -> String -> Int -> Cem.Compose.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Cem.Compose.Msg
childFieldRow labelText current path slotName index model =
    TypedHtml.div [ TA.class "flex items-center gap-2" ]
        [ TypedHtml.div [ TA.class "flex-1" ]
            [ childFormField labelText current path slotName index ]
        , reorderControls path slotName index model
        ]


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
