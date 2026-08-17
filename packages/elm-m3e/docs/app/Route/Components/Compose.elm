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

import BackendTask exposing (BackendTask)
import Cem.Compose
import Compose.Attrs as Attrs
import Compose.Codegen as Codegen
import Compose.FromHtml as FromHtml
import Compose.Render as Render
import Dict exposing (Dict)
import Doc
import Doc.Data
import Doc.Usage
import Effect exposing (Effect)
import FatalError exposing (FatalError)
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
import M3e.Component.ListAction
import M3e.Events
import M3e.Kind
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
import TypedHtml.Component.Grouping as Grouping
import TypedHtml.Component.Sectioning as Sectioning
import TypedHtml.Events as TE
import UrlPath exposing (UrlPath)
import View exposing (View)


type alias Model =
    { compose : Cem.Compose.Model
    , collapsed : Set String
    , prefill : Bool
    , componentPicker : Maybe Cem.Compose.Path
    , componentSearch : String
    , slotPicker : Maybe ( Cem.Compose.Path, String )
    , rootExplainerDismissed : Bool
    }


type Msg
    = ComposeMsg Cem.Compose.Msg
    | ToggleCollapse String
    | TogglePrefill
    | ToggleComponentPicker Cem.Compose.Path
    | SetComponentSearch String
    | PickComponent Cem.Compose.Path String
    | ToggleSlotPicker Cem.Compose.Path String
    | AddChildAndClose Cem.Compose.Msg
    | LoadExampleAndClose (List Cem.Compose.Msg)
    | DismissRootExplainer


type alias RouteParams =
    {}


{-| The consumer-level data every node's menus close over: the real
per-component examples from `data/examples.json` (`usage`, keyed by
lowercase slug — the add-child menu's "real example" options), and the
editorial component reference from `data/reference.json` (`reference`, keyed
by lowercase slug — the change-component picker's category/label grouping).
Both loaded the same way `Route.Components.Name_` does via `Doc.Data`.
-}
type alias Data =
    { usage : Dict String (List Doc.Usage.UsageExample)
    , reference : Dict String Doc.Data.Component
    }


type alias ActionData =
    {}


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


data : BackendTask FatalError Data
data =
    BackendTask.map2 Data
        Doc.Data.allUsage
        (Doc.Data.allComponents |> BackendTask.map (List.map (\c -> ( c.slug, c )) >> Dict.fromList))


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
      , componentPicker = Nothing
      , componentSearch = ""
      , slotPicker = Nothing
      , rootExplainerDismissed = False
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

        ToggleComponentPicker path ->
            ( { model
                | componentPicker =
                    if model.componentPicker == Just path then
                        Nothing

                    else
                        Just path
                , componentSearch = ""
                , slotPicker = Nothing
              }
            , Effect.none
            )

        SetComponentSearch text ->
            ( { model | componentSearch = text }, Effect.none )

        PickComponent path name ->
            ( { model
                | compose = applyCompose model.prefill (Cem.Compose.SetComponent path name) model.compose
                , componentPicker = Nothing
                , componentSearch = ""
              }
            , Effect.none
            )

        ToggleSlotPicker path slotName ->
            ( { model
                | slotPicker =
                    if model.slotPicker == Just ( path, slotName ) then
                        Nothing

                    else
                        Just ( path, slotName )
                , componentPicker = Nothing
              }
            , Effect.none
            )

        AddChildAndClose composeMsg ->
            ( { model
                | compose = applyCompose model.prefill composeMsg model.compose
                , slotPicker = Nothing
              }
            , Effect.none
            )

        DismissRootExplainer ->
            ( { model | rootExplainerDismissed = True }, Effect.none )

        LoadExampleAndClose msgs ->
            -- Raw `Cem.Compose.update`, deliberately NOT `applyCompose model.prefill`:
            -- an example already carries its own real content, so running it through
            -- the placeholder-seeding nicety would plant an extra "lorem ipsum" text
            -- child in the freshly-added node's first text slot BEFORE these messages
            -- fill it in — on a multi slot that lands as an unwanted extra sibling AND
            -- shifts every subsequent hard-coded index off by one. Also closes the
            -- add-child panel the example was chosen from.
            ( { model
                | compose = List.foldl Cem.Compose.update model.compose msgs
                , slotPicker = Nothing
              }
            , Effect.none
            )


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
view app _ model =
    View.fromElement "Compose"
        (M3e.mapMsg PagesMsg.fromMsg
            (Doc.pane
                [ screen { usage = app.data.usage, reference = app.data.reference } model ]
            )
        )


{-| A heading, the panel bar, the live preview, the recursive editor, and the
generated-code snippet. Only the panel bar and the editor emit real messages;
the heading/preview/snippet are static (msg-polymorphic), so they sit in the
same `Msg`-typed tree without wrapping. `ctx` (this route's `usage`/
`reference` data) threads down into the editor so its menus can offer "fill
me with a real example" options and the change-component picker can group by
category.
-}
screen : MenuCtx -> Model -> Element (Grouping.DivIs s) admittedBy Msg
screen ctx model =
    TypedHtml.div [ TA.class "space-y-4" ]
        [ Doc.pageHeading ("Compose: " ++ Cem.Compose.componentOf model.compose.root)
        , panelBar model
        , livePreview model.compose.root
        , rootExplainer model.rootExplainerDismissed
        , viewNode ctx [] model.compose.root model
        , Doc.codeBlock Doc.Elm (Codegen.codeFor model.compose.root)
        ]


{-| §3.6: a one-line, dismissible caption above the root card explaining why the
root looks structurally different from its children (no Move/Remove controls) —
a silent rule (§1.8) made explicit without adding permanent chrome. Dismissal is
session-scoped route state (`rootExplainerDismissed`); localStorage persistence
across reloads (the plan's OPTIONAL extra) is intentionally NOT wired here — it
would need a new port + `index.ts` change, i.e. an app-shell edit outside this
rework's "consumer-route-only" surface, so it is left as a small follow-up.
Marked `compose-root-explainer` for the test.
-}
rootExplainer : Bool -> Element (Grouping.DivIs s) admittedBy Msg
rootExplainer dismissed =
    if dismissed then
        TypedHtml.div [] []

    else
        TypedHtml.div
            [ TA.class "compose-root-explainer flex items-center gap-2 rounded-md-corner-medium border border-outline-variant bg-surface-container-lowest px-3 py-2 text-body-sm text-on-surface-variant" ]
            [ M3e.icon [ TA.name "info" ] []
            , TypedHtml.span [ TA.class "flex-1" ]
                [ TypedHtml.text "The root card can’t be reordered or removed; use the sidebar to start over with a different root component." ]
            , M3e.iconButton
                [ Aria.label "Dismiss"
                , M3e.Events.onClick DismissRootExplainer
                ]
                [ M3e.icon [ TA.name "close" ] [] ]
            ]


{-| §3.5: the rendered custom-element tree, wrapped in a labeled output frame so
it reads as "the live preview" rather than incidental page copy. A semantic
`section` named "Live preview" (accessible region) with a visible caption + a
subtle bordered/tinted container; the raw element tree is erased once through
`M3e.Unsafe.fromHtml` inside it (which component is on screen is only known at
runtime). Marked `compose-preview` for the test.
-}
livePreview : Cem.Compose.Node -> Element (Sectioning.SectionIs s) admittedBy Msg
livePreview root =
    TypedHtml.section
        [ TA.class "compose-preview flex flex-col gap-2 rounded-md-corner-medium border border-outline-variant bg-surface-container-lowest p-4"
        , Aria.label "Live preview"
        ]
        [ TypedHtml.p
            [ TA.class "text-label-sm text-on-surface-variant uppercase tracking-wide" ]
            [ TypedHtml.text "Live preview" ]
        , M3e.Unsafe.fromHtml (Render.renderNode root)
        ]


{-| The consumer-level data every node's menus close over: `usage`
(`data/examples.json`, for the add-child menu's "real example" options) and
`reference` (`data/reference.json`, for the change-component picker's
editorial labels/categories). Bundled together since both are threaded down
the exact same recursive path (`screen` → `viewNode` → `headerRow`/
`childCards` → …) to every node in the tree.
-}
type alias MenuCtx =
    { usage : Dict String (List Doc.Usage.UsageExample)
    , reference : Dict String Doc.Data.Component
    }


{-| The compose panel bar: a "Prefill examples" switch. When on, adding a text
child or a component seeds example content (see `applyCompose`); when off, adds
land empty so you build from a blank component.
-}
panelBar : Model -> Element (Grouping.DivIs s) admittedBy Msg
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
viewNode : MenuCtx -> Cem.Compose.Path -> Cem.Compose.Node -> Model -> Element (M3e.Component.Card.Is s) admittedBy Msg
viewNode ctx path node model =
    let
        collapsed : Bool
        collapsed =
            Set.member (pathId path) model.collapsed

        hasAttrs : Bool
        hasAttrs =
            not (List.isEmpty (Cem.Compose.attrChips path model.compose))

        hasSlots : Bool
        hasSlots =
            not (List.isEmpty (Cem.Compose.slotChips path model.compose))
    in
    M3e.card
        [ M3e.Attributes.variant Value.outlined ]
        [ TypedHtml.div [ TA.class "flex flex-col gap-3 p-3" ]
            (TypedHtml.div [ TA.class "flex items-center gap-2" ]
                [ collapseChevron path collapsed
                , headerRow ctx path node model
                ]
                :: (if collapsed then
                        []

                    else
                        [ TypedHtml.div [ TA.class "flex flex-col gap-3" ]
                            (List.concat
                                [ [ M3e.mapMsg ComposeMsg
                                        (TypedHtml.div [ TA.class "flex flex-col gap-3" ]
                                            [ attrGroup path model.compose
                                            , freeTextMenuFor path model.compose
                                            ]
                                        )
                                  ]
                                , if hasAttrs && hasSlots then
                                    [ M3e.divider [ TA.class "compose-attr-slot-divider" ] [] ]

                                  else
                                    []
                                , [ slotGroup ctx path model ]
                                ]
                            )
                        , TypedHtml.div [ TA.class "flex flex-col gap-3" ]
                            (childCards ctx path node model)
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
headerRow : MenuCtx -> Cem.Compose.Path -> Cem.Compose.Node -> Model -> Element (Grouping.DivIs s) admittedBy Msg
headerRow ctx path node model =
    case nodePosition path of
        Nothing ->
            TypedHtml.div [ TA.class "flex items-center gap-2 flex-1" ]
                [ TypedHtml.div [ TA.class "flex-1" ] [ M3e.mapMsg ComposeMsg (tagHeading node) ]
                , editControl ctx path model
                ]

        Just ( parentPath, slotName, index ) ->
            TypedHtml.div [ TA.class "flex items-center gap-2 flex-1" ]
                [ TypedHtml.div [ TA.class "flex-1" ] [ M3e.mapMsg ComposeMsg (tagHeading node) ]
                , editControl ctx path model
                , M3e.mapMsg ComposeMsg (reorderControls parentPath slotName index model.compose)
                , M3e.mapMsg ComposeMsg (removeButton (Cem.Compose.RemoveChild parentPath slotName index))
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
reorderControls : Cem.Compose.Path -> String -> Int -> Cem.Compose.Model -> Element (Grouping.DivIs s) admittedBy Cem.Compose.Msg
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
never sharing a row with the Slots group below. Separated from the Slots group
by a single `M3e.divider` in `viewNode` (IA review §3.2 asked for a real
attributes-vs-slots DISTINCTION; the earlier bordered/tinted sub-card treatment
read as heavy nested chrome, so it was replaced by a plain caption + divider —
simpler, per feedback). Marked `compose-attr-group` so tests can still assert
the two kinds are distinguishable. The buttons wrap in a plain `flex flex-wrap`
row (an `M3e.buttonGroup` was rejected: it overflows rather than wraps, and it
stamps `role="radiogroup"`/`role="radio"` on these independent toggles, implying
a single-select exclusivity they do not have). Each discrete attribute's
always-present menu is a sibling rather than nested — `menuTrigger`/`menu` are
addressed by id, so their DOM position doesn't matter.
-}
attrGroup : Cem.Compose.Path -> Cem.Compose.Model -> Element (Grouping.DivIs s) admittedBy Cem.Compose.Msg
attrGroup path model =
    case Cem.Compose.attrChips path model of
        [] ->
            TypedHtml.div [] []

        chips ->
            TypedHtml.div [ TA.class "compose-attr-group flex flex-col gap-2" ]
                (TypedHtml.div [ TA.class "flex flex-wrap items-center gap-2" ]
                    (groupLabel "text-on-surface-variant" "Attributes" :: List.map (attrButtonElement path) chips)
                    :: attrMenusFor path model chips
                )


{-| The Slots (add-child) group — every slot control, under its own label,
never sharing a row with the Attributes group above. Separated from the
Attributes group by a single `M3e.divider` in `viewNode` (see `attrGroup`) and
marked `compose-slot-group` (IA review §3.2). Each slot's fill-count badge rides
in its own button's `trailing-icon` slot; a multi-option slot's add-child panel
is a sibling of its button inside a `relative` wrapper (`slotControl`), rendered
as an `M3e.card` surface (Material elevation/shape/container color) rather than a
hand-rolled bordered div. It is still not a shared `m3e-menu` — an `m3e-menu`'s
`Content` cannot host the panel's captioned "Nest a component" / "Load an
example" subsections (see `slotAddPanel`) — but its option rows are real
`M3e.listAction` items, so it reads as a Material menu surface.
-}
slotGroup : MenuCtx -> Cem.Compose.Path -> Model -> Element (Grouping.DivIs s) admittedBy Msg
slotGroup ctx path model =
    case Cem.Compose.slotChips path model.compose of
        [] ->
            TypedHtml.div [] []

        chips ->
            TypedHtml.div [ TA.class "compose-slot-group flex flex-wrap items-center gap-2" ]
                (groupLabel "text-on-surface-variant" "Slots" :: List.map (slotControl ctx path model) chips)


{-| A group's caption — the color class ties the caption to its group's
left-border color (primary for Attributes, tertiary for Slots), reinforcing the
§3.2 attributes-vs-slots distinction.
-}
groupLabel : String -> String -> Element (Grouping.PIs s) admittedBy msg
groupLabel colorClass label =
    TypedHtml.p [ TA.class ("text-label-sm uppercase tracking-wide " ++ colorClass) ] [ TypedHtml.text label ]


{-| The edit-tag control: an icon button that toggles the change-component
picker (`componentPicker`) open/closed. `Cem.Compose.componentOptions` is
type-directed — a nested node only offers what its parent slot accepts, and
the current component is already excluded — so an empty list means there is
nothing valid to change to and no control renders.

Per §3.1 of the IA review, this is real component TYPES only — no example
options mixed in (those stayed on the add-child menu, where "fill this new
child with a real example" is the coherent affordance; picking a type here is
a structural decision, not a content one).

-}
editControl : MenuCtx -> Cem.Compose.Path -> Model -> Element (Grouping.DivIs s) admittedBy Msg
editControl ctx path model =
    case Cem.Compose.componentOptions path model.compose of
        [] ->
            TypedHtml.div [] []

        options ->
            TypedHtml.div [ TA.class "relative inline-flex" ]
                (M3e.iconButton
                    [ Aria.label "Change component"
                    , M3e.Events.onClick (ToggleComponentPicker path)
                    ]
                    [ M3e.icon [ TA.name "edit" ] [] ]
                    :: (if model.componentPicker == Just path then
                            [ componentPicker
                                { search = model.componentSearch
                                , onSearch = SetComponentSearch
                                , onPick = PickComponent path
                                , options = options
                                , reference = ctx.reference
                                }
                            ]

                        else
                            []
                       )
                )


{-| A grouped, searchable component-type picker — the change-component
control's popup panel, reusable (constrained to a slot's own afforded set)
by M-IA2b's "nest a component" affordance.

Its surface is an `M3e.card` (variant `elevated`) — real Material elevation,
shape, and container color — and its option rows are `M3e.listAction` items,
so it reads as a proper Material menu surface rather than a hand-rolled
bordered div. It is still NOT an `m3e-menu`: an `m3e-menu`'s `Content` only
admits `menuItem`/`menuItemCheckbox`/`menuItemGroup`/`menuItemRadio`/`divider`
(see `M3e.Internal.Types.Menu`) — none of which can host a search `<input>` or
a plain category caption. So this stays a route-state-toggled panel
(`componentPicker`/`componentSearch`), just built from Material surfaces. On a
compact (`< sm`, e.g. 411px) viewport it docks as a bottom sheet spanning the
viewport width, so a deeply-indented trigger can never push it off an edge; at
`sm` and up it is the anchored dropdown, right-anchored so it opens leftward
from the trailing edit control.

-}
componentPicker :
    { search : String
    , onSearch : String -> Msg
    , onPick : String -> Msg
    , options : List String
    , reference : Dict String Doc.Data.Component
    }
    -> Element (M3e.Component.Card.Is s) admittedBy Msg
componentPicker config =
    let
        query : String
        query =
            String.toLower config.search

        matches : PickerEntry -> Bool
        matches entry =
            String.isEmpty query
                || String.contains query (String.toLower entry.name)
                || String.contains query (String.toLower entry.label)

        entries : List PickerEntry
        entries =
            config.options
                |> List.map (pickerEntry config.reference)
                |> List.filter matches

        categorized : List ( String, List PickerEntry )
        categorized =
            Shared.componentCategories
                |> List.filterMap
                    (\( category, _ ) ->
                        case List.filter (\e -> e.category == Just category) entries of
                            [] ->
                                Nothing

                            es ->
                                Just ( category, es )
                    )

        other : List PickerEntry
        other =
            List.filter (\e -> e.category == Nothing) entries

        sections : List ( String, List PickerEntry )
        sections =
            categorized
                ++ (if List.isEmpty other then
                        []

                    else
                        [ ( "Other", other ) ]
                   )
    in
    M3e.card
        [ M3e.Attributes.variant Value.elevated
        , M3e.Attributes.class "compose-component-picker fixed inset-x-3 bottom-3 top-auto z-20 max-h-96 overflow-y-auto sm:absolute sm:inset-x-auto sm:bottom-auto sm:top-full sm:right-0 sm:mt-1 sm:max-h-80 sm:w-72"
        ]
        [ M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex flex-col gap-2" ]
                (TypedHtml.input
                    [ TA.value config.search
                    , TA.placeholder "Search components"
                    , TE.onInput config.onSearch
                    , TA.class "w-full rounded-md-corner-small border border-outline-variant bg-surface-container-highest px-2 py-1 text-body-md"
                    ]
                    []
                    :: (if List.isEmpty sections then
                            [ TypedHtml.p [ TA.class "text-body-sm text-on-surface-variant px-2" ] [ TypedHtml.text "No matches" ] ]

                        else
                            List.map (pickerSection config.onPick) sections
                       )
                )
            )
        ]


{-| One option in the picker: its raw `componentOptions` name (what
`onPick` fires), its display label, and its canonical nav category (`Nothing`
⇒ the trailing "Other" group).
-}
type alias PickerEntry =
    { name : String
    , label : String
    , category : Maybe String
    }


{-| An option's display label and canonical nav category, from
`data/reference.json` by lowercased slug — but only when BOTH the entry
exists and its category is one of `Shared.componentCategories`' known set. A
component with no reference entry, an empty category, or an unrecognized one
gets `category = Nothing` (the picker's trailing "Other" group) and its own
raw name as the label: `reference.json` falls its OWN `label` back to a raw
qualified module name for these (e.g. `"Component.Accordion"`), which reads
worse as a picker item than the plain `"accordion"` `componentOptions`
already gives us.
-}
pickerEntry : Dict String Doc.Data.Component -> String -> PickerEntry
pickerEntry reference name =
    case Dict.get (String.toLower name) reference of
        Just component ->
            if List.member component.category (List.map Tuple.first Shared.componentCategories) then
                { name = name, label = component.label, category = Just component.category }

            else
                { name = name, label = name, category = Nothing }

        Nothing ->
            { name = name, label = name, category = Nothing }


pickerSection : (String -> Msg) -> ( String, List PickerEntry ) -> Element (Grouping.DivIs s) admittedBy Msg
pickerSection onPick ( category, entries ) =
    TypedHtml.div [ TA.class "flex flex-col gap-1" ]
        [ groupLabel "text-on-surface-variant" category
        , M3e.list [] (List.map (pickerItem onPick) entries)
        ]


{-| One picker/nest option as an `M3e.listAction` row — a real Material list
item (ripple, state layer, left-aligned) whose accessible name is its editorial
label. The host carries `role="listitem"`; its internal action button carries
`role="button"`, so `getByRole("button", { name })` still resolves each row.
-}
pickerItem : (String -> Msg) -> PickerEntry -> Element { s | listAction : M3e.Kind.Brand } admittedBy Msg
pickerItem onPick entry =
    M3e.listAction
        [ M3e.Component.ListAction.onClick (onPick entry.name) ]
        [ M3e.text entry.label ]


{-| The real examples for component `name` (`data/examples.json`, keyed by
lowercase slug) whose `html` both parses and is actually rooted at `name` —
`Compose.FromHtml.parse` already drops anything it can't account for, and a
parsed root of some OTHER component (a copy/paste mismatch in the example
data) is skipped here too, never surfaced as a menu item for `name`.
-}
examplesFor : Dict String (List Doc.Usage.UsageExample) -> String -> List ( Doc.Usage.UsageExample, FromHtml.ExampleNode )
examplesFor usage name =
    Dict.get (String.toLower name) usage
        |> Maybe.withDefault []
        |> List.filterMap
            (\example ->
                FromHtml.parse { facts = M3e.Review.Facts.facts, attrKinds = Attrs.kinds } example.html
                    |> Maybe.andThen
                        (\node ->
                            if node.component == name then
                                Just ( example, node )

                            else
                                Nothing
                        )
            )


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
slotCountTrailing : Cem.Compose.SlotChipInfo -> List (Element free freeAdmittedBy msg)
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
slotCountBadge : Cem.Compose.SlotChipInfo -> Element (M3e.Component.Badge.Is s) admittedBy msg
slotCountBadge info =
    M3e.badge
        [ M3e.Attributes.style "--m3e-badge-container-color" "var(--md-sys-color-surface-container-highest)"
        , M3e.Attributes.style "--m3e-badge-color" "var(--md-sys-color-on-surface-variant)"
        ]
        [ M3e.text (String.fromInt info.filled) ]


{-| One slot's add-child control: an extra-small add `M3e.button`, plus — for
a multi-option slot — its add-child panel (`slotAddPanel`) as a sibling inside
a `relative` wrapper, shown iff `model.slotPicker` names this slot. A slot
affording exactly one option fires that message directly on click, with no
panel (a consumer convenience, not a core rule; spec §7.2 step 2). A
multi-option slot must not collapse to one representative choice (spec §8.7):
its panel offers text, an icon, AND components all at once.

NOT an `m3e-menu`: the panel's captioned "Nest a component" / "Load an
example" subsections cannot live inside an `m3e-menu`'s `Content` (it admits
only `menuItem*`/`divider`, no captions), so — following the change-component
picker precedent (M-IA2a) — the whole affordance is a plain positioned panel,
addressed by route `Model` state (`slotPicker`) rather than the web
component's own popover machinery. That per-`(path, slotName)` addressing also
makes the audit's §1.2 "leaked/stale popover" concern structurally impossible:
each panel is uniquely model-identified, never a shared id.

-}
slotControl : MenuCtx -> Cem.Compose.Path -> Model -> Cem.Compose.SlotChipInfo -> Element (Grouping.DivIs s) admittedBy Msg
slotControl ctx path model info =
    case Cem.Compose.slotMenuOptions path info.name model.compose of
        [ only ] ->
            TypedHtml.div [ TA.class "relative inline-flex" ]
                [ slotButton info (ComposeMsg (msgForOption path info.name only)) ]

        _ ->
            TypedHtml.div [ TA.class "relative inline-flex" ]
                (slotButton info (ToggleSlotPicker path info.name)
                    :: (if model.slotPicker == Just ( path, info.name ) then
                            [ slotAddPanel ctx path info.name model.compose ]

                        else
                            []
                       )
                )


{-| The add-child button itself — the same extra-small `M3e.button` (never a
chip) for both the single-option case (fires the add directly) and the
multi-option case (toggles the panel); only the `onClick` message differs.

An EMPTY slot and a FILLED slot are categorically different chip kinds (IA
review §3.2/§1.5, "stop overloading the `+`"): an empty slot leads with the
`add` icon (its affordance is "add your first child") and carries no badge; a
filled slot drops the `add` icon entirely and shows just its name + fill-count
badge at the heavier `filled` weight (its content, not an add affordance).
Marked `compose-slot-empty`/`compose-slot-filled` so the distinction is
test-assertable.

-}
slotButton : Cem.Compose.SlotChipInfo -> Msg -> Element (M3e.Component.Button.Is s) admittedBy Msg
slotButton info onClick =
    M3e.button
        [ M3e.Attributes.class
            (if info.filled > 0 then
                "compose-slot-filled"

             else
                "compose-slot-empty"
            )
        , M3e.Attributes.size Value.extraSmall
        , M3e.Attributes.variant
            (if info.filled > 0 then
                Value.filled

             else
                Value.elevated
            )
        , M3e.Attributes.selected (info.filled > 0)
        , M3e.Events.onClick onClick
        ]
        ((if info.filled > 0 then
            []

          else
            [ M3e.icon [ TA.name "add" ] [] ]
         )
            ++ M3e.text info.name
            :: slotCountTrailing info
        )


{-| A slot's add-child panel (see `slotControl` for why it is a route-state
panel, not an `m3e-menu`). Its surface is an `M3e.card` (variant `elevated`) and
each group of options is an `M3e.list` of `M3e.listAction` rows, so the whole
affordance reads as a Material menu surface rather than a hand-rolled bordered
div. It leads with the structural primitives the slot affords (`Text`/`Icon`),
then a captioned "Nest a component" group listing the afforded component types
(reusing the change-component picker's editorial labels, M-IA2a), then — only
when real usage examples exist for those components — a captioned "Load an
example" group whose items are QUALIFIED by their source component ("Heading —
Typescale variants and sizes"), so duplicate bare example titles become
distinguishable (audit §1.2). On a compact (`< sm`, e.g. 411px) viewport it
docks as a bottom sheet spanning the viewport width, so a deeply-indented slot
button can never push it off an edge; at `sm` and up it is the anchored
dropdown below its button.
-}
slotAddPanel : MenuCtx -> Cem.Compose.Path -> String -> Cem.Compose.Model -> Element (M3e.Component.Card.Is s) admittedBy Msg
slotAddPanel ctx path slotName compose =
    let
        options : List Cem.Compose.SlotOption
        options =
            Cem.Compose.slotMenuOptions path slotName compose

        componentNames : List String
        componentNames =
            List.filterMap
                (\option ->
                    case option of
                        Cem.Compose.OptionComponent name ->
                            Just name

                        _ ->
                            Nothing
                )
                options

        examples : List ( String, Doc.Usage.UsageExample, FromHtml.ExampleNode )
        examples =
            componentNames
                |> List.concatMap
                    (\name ->
                        examplesFor ctx.usage name
                            |> List.map (\( example, exampleNode ) -> ( name, example, exampleNode ))
                    )
    in
    M3e.card
        [ M3e.Attributes.variant Value.elevated
        , M3e.Attributes.class "compose-slot-panel fixed inset-x-3 bottom-3 top-auto z-20 max-h-96 overflow-y-auto sm:absolute sm:inset-x-auto sm:bottom-auto sm:top-full sm:left-0 sm:mt-1 sm:max-h-80 sm:w-72"
        ]
        [ M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex flex-col gap-2" ]
                (List.concat
                    [ case List.filterMap (primitiveButton path slotName) options of
                        [] ->
                            []

                        prims ->
                            [ M3e.list [] prims ]
                    , if List.isEmpty componentNames then
                        []

                      else
                        [ groupLabel "text-on-surface-variant" "Nest a component"
                        , M3e.list [] (List.map (nestButton ctx path slotName) componentNames)
                        ]
                    , if List.isEmpty examples then
                        []

                      else
                        [ groupLabel "text-on-surface-variant" "Load an example"
                        , M3e.list [] (List.map (exampleButton ctx path slotName compose) examples)
                        ]
                    ]
                )
            )
        ]


{-| The `Text`/`Icon` structural primitives an add-child panel leads with —
one plain button per afforded primitive `SlotOption` (a component option is
handled by `nestButton`, so it is `Nothing` here). Adds directly and closes
the panel.
-}
primitiveButton : Cem.Compose.Path -> String -> Cem.Compose.SlotOption -> Maybe (Element { s | listAction : M3e.Kind.Brand } admittedBy Msg)
primitiveButton path slotName option =
    case option of
        Cem.Compose.OptionText ->
            Just (panelListAction "Text" (AddChildAndClose (Cem.Compose.AddTextChild path slotName)))

        Cem.Compose.OptionIcon ->
            Just (panelListAction "Icon" (AddChildAndClose (Cem.Compose.AddIconChild path slotName)))

        Cem.Compose.OptionComponent _ ->
            Nothing


{-| One "Nest a component" option — the same editorial-labeled `pickerItem` the
change-component picker uses (M-IA2a), but its `onPick` appends the component as
a new child of this slot (and closes the panel) rather than re-typing a node.
-}
nestButton : MenuCtx -> Cem.Compose.Path -> String -> String -> Element { s | listAction : M3e.Kind.Brand } admittedBy Msg
nestButton ctx path slotName name =
    pickerItem
        (\picked -> AddChildAndClose (Cem.Compose.AddChild path slotName picked))
        (pickerEntry ctx.reference name)


{-| One "Load an example" option, QUALIFIED by its source component's editorial
label so duplicate bare titles ("Label Small") become distinguishable ("Heading
— Label Small"). Marked `compose-example-item` (as the old menu item was) so it
stays distinguishable from the plain "Nest a component" options. Fires
`LoadExampleAndClose`: `AddChild path slotName name` (create the new child,
appended at the slot's current fill count), then the parsed example's own
message batch (`FromHtml.toMsgs`) addressed at that new child's resulting path.
-}
exampleButton : MenuCtx -> Cem.Compose.Path -> String -> Cem.Compose.Model -> ( String, Doc.Usage.UsageExample, FromHtml.ExampleNode ) -> Element { s | listAction : M3e.Kind.Brand } admittedBy Msg
exampleButton ctx path slotName compose ( name, example, exampleNode ) =
    let
        filled : Int
        filled =
            slotChildCount path slotName compose
    in
    M3e.listAction
        [ TA.class "compose-example-item"
        , M3e.Component.ListAction.onClick
            (LoadExampleAndClose
                (Cem.Compose.AddChild path slotName name
                    :: FromHtml.toMsgs (path ++ [ Cem.Compose.IntoSlot slotName filled ]) exampleNode
                )
            )
        ]
        [ M3e.text (qualifiedExampleLabel ctx.reference name example.title) ]


{-| A panel option row — the shared shape of `primitiveButton` (and, via
`pickerItem`, the nest/example rows): an `M3e.listAction` Material list item.
-}
panelListAction : String -> Msg -> Element { s | listAction : M3e.Kind.Brand } admittedBy Msg
panelListAction label msg =
    M3e.listAction
        [ M3e.Component.ListAction.onClick msg ]
        [ M3e.text label ]


{-| An example option's display label, prefixed with its source component's
editorial label (`pickerEntry`'s `label`): `"Heading — Typescale variants and
sizes"`. This is the fix for the audit's §1.2 duplicate bare titles.
-}
qualifiedExampleLabel : Dict String Doc.Data.Component -> String -> String -> String
qualifiedExampleLabel reference name title =
    (pickerEntry reference name).label ++ " — " ++ title


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
freeTextMenuFor : Cem.Compose.Path -> Cem.Compose.Model -> Element (Grouping.DivIs s) admittedBy Cem.Compose.Msg
freeTextMenuFor path model =
    case model.openMenu of
        Just ( openPath, Cem.Compose.AttrMenu name ) ->
            if openPath == path then
                freeTextAttrView path name model

            else
                TypedHtml.div [] []

        _ ->
            TypedHtml.div [] []


freeTextAttrView : Cem.Compose.Path -> String -> Cem.Compose.Model -> Element (Grouping.DivIs s) admittedBy Cem.Compose.Msg
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


textInputRow : String -> (String -> Cem.Compose.Msg) -> Element (Grouping.DivIs s) admittedBy Cem.Compose.Msg
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
childCards : MenuCtx -> Cem.Compose.Path -> Cem.Compose.Node -> Model -> List (Element (Grouping.DivIs s) admittedBy Msg)
childCards ctx path node model =
    Cem.Compose.slotsOf node
        |> List.concatMap
            (\( slotName, children ) ->
                children
                    |> List.indexedMap
                        (\i child -> childRow ctx path slotName i child model)
            )


{-| A `ChildNode` recurses into `viewNode` (route `Msg`); a `ChildText`/
`ChildIcon` renders its `Cem.Compose.Msg` field row, lifted to `Msg` with
`M3e.mapMsg ComposeMsg` at this boundary.

§3.4: a `ChildNode`'s recursive card is wrapped in a fixed per-level left indent

  - a thin left connector line (`childIndent`), so nesting depth reads at a glance
    the way the code panel's own indentation already does. The indent is applied
    once per `childRow` and therefore COMPOUNDS with depth automatically — a
    depth-2 card sits inside its depth-1 parent's own indented wrapper — with no
    depth arithmetic. The `compose-depth-N` marker (N = the child node's own path
    length) lets a test assert the indent is objectively present, not just claimed.
    `ChildText`/`ChildIcon` rows are leaves (never recurse), so they are not
    indented — only structural node nesting earns a level.

-}
childRow : MenuCtx -> Cem.Compose.Path -> String -> Int -> Cem.Compose.Child -> Model -> Element (Grouping.DivIs s) admittedBy Msg
childRow ctx path slotName index child model =
    case child of
        Cem.Compose.ChildNode inner ->
            let
                childPath : Cem.Compose.Path
                childPath =
                    path ++ [ Cem.Compose.IntoSlot slotName index ]
            in
            TypedHtml.div
                [ TA.class ("compose-child compose-depth-" ++ String.fromInt (List.length childPath) ++ " pl-6 border-l border-outline-variant") ]
                [ viewNode ctx childPath inner model ]

        Cem.Compose.ChildText text ->
            M3e.mapMsg ComposeMsg (childFieldRow "Text" text path slotName index model.compose)

        Cem.Compose.ChildIcon glyph ->
            M3e.mapMsg ComposeMsg (childFieldRow "Icon" glyph path slotName index model.compose)


{-| A `ChildText`/`ChildIcon` row: the labeled `M3e.formField` (whose own
`suffix` slot carries the delete), then the up/down reorder row at the trailing
end. The node case renders its reorder + delete inside the card header instead,
so its row is just the card.
-}
childFieldRow : String -> String -> Cem.Compose.Path -> String -> Int -> Cem.Compose.Model -> Element (Grouping.DivIs s) admittedBy Cem.Compose.Msg
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
