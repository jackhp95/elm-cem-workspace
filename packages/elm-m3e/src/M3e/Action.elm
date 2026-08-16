module M3e.Action exposing
    ( Action, LinkSpec, BottomSheetSpec
    , link, linkWith, none, onClick, remove
    , bottomSheetAction, dialogAction, opensBottomSheet, opensDialog, opensFabMenu, opensMenu, richTooltipAction, stepperPrevious, stepperReset, togglesDatepicker, togglesDrawer, togglesNavRail, togglesTimepicker
    , toAttrs, wrapContent
    )

{-| Behavioural actions: exactly one of the supported behaviours, consumed
by a component's `component`/`build` required record. Attribute behaviours
(`onClick`/`link`/`remove`) become host attributes; wrapper behaviours nest
the content in their trigger element.

@docs Action, LinkSpec, BottomSheetSpec
@docs link, linkWith, none, onClick, remove
@docs bottomSheetAction, dialogAction, opensBottomSheet, opensDialog, opensFabMenu, opensMenu, richTooltipAction, stepperPrevious, stepperReset, togglesDatepicker, togglesDrawer, togglesNavRail, togglesTimepicker
@docs toAttrs, wrapContent

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Node exposing (Node)
import Json.Decode


{-| An opaque behavioural value: exactly one of the supported behaviours.
-}
type Action capability msg
    = Action (Payload msg)


type Payload msg
    = None
    | OnClick msg
    | Link LinkSpec
    | Remove msg
    | OpensMenu String
    | OpensDialog String
    | OpensFabMenu String
    | TogglesNavRail String
    | TogglesDrawer String
    | TogglesDatepicker String
    | TogglesTimepicker String
    | BottomSheetAction
    | RichTooltipAction
    | StepperReset
    | StepperPrevious
    | OpensBottomSheet BottomSheetSpec
    | DialogAction String


{-| The parts of a link action.
-}
type alias LinkSpec =
    { href : String, target : Maybe String, rel : Maybe String, download : Maybe String }


{-| The parts of a bottom-sheet trigger.
-}
type alias BottomSheetSpec =
    { for : String, detent : Maybe Float, secondary : Maybe Bool }


{-| No behaviour.
-}
none : Action capability msg
none =
    Action None


{-| A click action: emit `msg` on activation.
-}
onClick : msg -> Action { c | click : Supported } msg
onClick m =
    Action (OnClick m)


{-| A link action pointing at `url`.
-}
link : String -> Action { c | link : Supported } msg
link url =
    Action (Link { href = url, target = Nothing, rel = Nothing, download = Nothing })


{-| A link action from a full `LinkSpec`.
-}
linkWith : LinkSpec -> Action { c | link : Supported } msg
linkWith spec =
    Action (Link spec)


{-| A remove action: emit `msg` when the element requests removal.
-}
remove : msg -> Action { c | remove : Supported } msg
remove m =
    Action (Remove m)


{-| Open the menu whose id is `for`
-}
opensMenu : String -> Action { c | menuTrigger : Supported } msg
opensMenu for_ =
    Action (OpensMenu for_)


{-| Open the dialog whose id is `for`
-}
opensDialog : String -> Action { c | dialogTrigger : Supported } msg
opensDialog for_ =
    Action (OpensDialog for_)


{-| Open the fab-menu whose id is `for`
-}
opensFabMenu : String -> Action { c | fabMenuTrigger : Supported } msg
opensFabMenu for_ =
    Action (OpensFabMenu for_)


{-| Toggle the nav-rail whose id is `for`
-}
togglesNavRail : String -> Action { c | navRailToggle : Supported } msg
togglesNavRail for_ =
    Action (TogglesNavRail for_)


{-| Toggle the drawer whose id is `for`
-}
togglesDrawer : String -> Action { c | drawerToggle : Supported } msg
togglesDrawer for_ =
    Action (TogglesDrawer for_)


{-| Toggle the datepicker whose id is `for`
-}
togglesDatepicker : String -> Action { c | datepickerToggle : Supported } msg
togglesDatepicker for_ =
    Action (TogglesDatepicker for_)


{-| Toggle the timepicker whose id is `for`
-}
togglesTimepicker : String -> Action { c | timepickerToggle : Supported } msg
togglesTimepicker for_ =
    Action (TogglesTimepicker for_)


{-| Dismiss the enclosing bottom-sheet
-}
bottomSheetAction : Action { c | bottomSheetAction : Supported } msg
bottomSheetAction =
    Action BottomSheetAction


{-| Dismiss the enclosing rich tooltip
-}
richTooltipAction : Action { c | richTooltipAction : Supported } msg
richTooltipAction =
    Action RichTooltipAction


{-| Reset the enclosing stepper
-}
stepperReset : Action { c | stepperReset : Supported } msg
stepperReset =
    Action StepperReset


{-| Move the enclosing stepper to the previous step
-}
stepperPrevious : Action { c | stepperPrevious : Supported } msg
stepperPrevious =
    Action StepperPrevious


{-| Open the bottom sheet whose id is `for` (full spec via the record).
-}
opensBottomSheet : BottomSheetSpec -> Action { c | bottomSheetTrigger : Supported } msg
opensBottomSheet spec =
    Action (OpensBottomSheet spec)


{-| Close the enclosing dialog with `returnValue`.
-}
dialogAction : String -> Action { c | dialogAction : Supported } msg
dialogAction returnValue =
    Action (DialogAction returnValue)


{-| The host-attribute wiring: attribute behaviours produce attrs; wrappers none.
-}
toAttrs : Action capability msg -> List (Attr c msg)
toAttrs (Action payload) =
    case payload of
        OnClick m ->
            [ Ir.on "click" (Json.Decode.succeed m) ]

        Remove m ->
            [ Ir.on "remove" (Json.Decode.succeed m) ]

        Link spec ->
            Ir.attribute "href" spec.href
                :: List.filterMap identity
                    [ Maybe.map (Ir.attribute "target") spec.target
                    , Maybe.map (Ir.attribute "rel") spec.rel
                    , Maybe.map (Ir.attribute "download") spec.download
                    ]

        _ ->
            []


{-| The content wiring: wrapper behaviours nest the label in their trigger element.
-}
wrapContent : Action capability msg -> Node msg -> Node msg
wrapContent (Action payload) label =
    case payload of
        OpensMenu for_ ->
            Ir.node "m3e-menu-trigger" [ Ir.attribute "for" for_ ] [ label ]

        OpensDialog for_ ->
            Ir.node "m3e-dialog-trigger" [ Ir.attribute "for" for_ ] [ label ]

        OpensFabMenu for_ ->
            Ir.node "m3e-fab-menu-trigger" [ Ir.attribute "for" for_ ] [ label ]

        TogglesNavRail for_ ->
            Ir.node "m3e-nav-rail-toggle" [ Ir.attribute "for" for_ ] [ label ]

        TogglesDrawer for_ ->
            Ir.node "m3e-drawer-toggle" [ Ir.attribute "for" for_ ] [ label ]

        TogglesDatepicker for_ ->
            Ir.node "m3e-datepicker-toggle" [ Ir.attribute "for" for_ ] [ label ]

        TogglesTimepicker for_ ->
            Ir.node "m3e-timepicker-toggle" [ Ir.attribute "for" for_ ] [ label ]

        BottomSheetAction ->
            Ir.node "m3e-bottom-sheet-action" [] [ label ]

        RichTooltipAction ->
            Ir.node "m3e-rich-tooltip-action" [] [ label ]

        StepperReset ->
            Ir.node "m3e-stepper-reset" [] [ label ]

        StepperPrevious ->
            Ir.node "m3e-stepper-previous" [] [ label ]

        OpensBottomSheet spec ->
            Ir.node "m3e-bottom-sheet-trigger"
                (Ir.attribute "for" spec.for
                    :: List.filterMap identity
                        [ Maybe.map (\d -> Ir.attribute "detent" (String.fromFloat d)) spec.detent
                        , Maybe.map (\s -> Ir.attribute "secondary" "") spec.secondary
                        ]
                )
                [ label ]

        DialogAction returnValue ->
            Ir.node "m3e-dialog-action" [ Ir.attribute "return-value" returnValue ] [ label ]

        _ ->
            label
