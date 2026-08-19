module Route.Family exposing (ActionData, Data, Model, Msg, route)

{-| Landing page for the Family area (`/family`) — every sibling-variant
component group `elm-m3e-families` bundles into one flat `M3e.Family.<F>`
module (e.g. the Chip family's assist/filter/input/suggestion chips into
`M3e.Family.Chip`), so a consumer can `import M3e.Family.Chip` once instead of
five separate `M3e.Component.*` imports.

The grouping itself is DATA (`config/slots.json`'s `_families.families`, the
same config `elm-cem`'s `gen-family-package.js` reads to emit the family
package, and `review/scripts/gen-m3e-family-config.mjs` flattens for
`NoFamilyMemberDrift`'s drift check) — this page mirrors that data rather than
re-deriving it, so it can only go stale the same way the generated modules
themselves would.

-}

import BackendTask
import Doc
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Card
import M3e.Component.Heading
import M3e.Kind
import M3e.Values as Value
import MimeType
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    {}


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = BackendTask.succeed {} }
        |> RouteBuilder.buildNoState { view = view }


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image =
            { url = [ "og-card.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-m3e"
            , dimensions = Just { width = 1200, height = 630 }
            , mimeType = Just (MimeType.Image MimeType.Png)
            }
        , description = "The elm-m3e-families package — sibling-variant components grouped into one flat import per family."
        , locale = Nothing
        , title = "Family · elm-m3e"
        }
        |> Seo.website


{-| One member element of a family — its `M3e.Component.<component>` module
name and the element-named constructor its family module re-exports it as
(e.g. `AssistChip` -> `assist`, so `M3e.Family.Chip.assist` delegates to
`M3e.Component.AssistChip.component`).
-}
type alias Member =
    { component : String, label : String }


{-| One family — its name (`M3e.Family.<name>`) and every member element,
root included as the first entry when the family has one (e.g. `Chip` itself
is the Chip family's root member, exposed as `chip`).

Mirrors `config/slots.json`'s `_families.families`, flattened the same way
`review/scripts/gen-m3e-family-config.mjs` flattens it for `NoFamilyMemberDrift`
— member order there is root-first too.

-}
type alias Family =
    { family : String, members : List Member }


families : List Family
families =
    [ { family = "Accordion", members = [ Member "Accordion" "accordion", Member "ExpansionPanel" "panel" ] }
    , { family = "BottomSheet", members = [ Member "BottomSheet" "bottomSheet", Member "BottomSheetAction" "action", Member "BottomSheetTrigger" "trigger" ] }
    , { family = "Breadcrumb", members = [ Member "Breadcrumb" "breadcrumb", Member "BreadcrumbItem" "item" ] }
    , { family = "Calendar", members = [ Member "Calendar" "calendar", Member "MonthView" "monthView", Member "YearView" "yearView", Member "MultiYearView" "multiYearView" ] }
    , { family = "Chip", members = [ Member "Chip" "chip", Member "AssistChip" "assist", Member "FilterChip" "filter", Member "InputChip" "input", Member "SuggestionChip" "suggestion", Member "ChipSet" "set", Member "FilterChipSet" "filterSet", Member "InputChipSet" "inputSet" ] }
    , { family = "Datepicker", members = [ Member "Datepicker" "datepicker", Member "DatepickerToggle" "toggle" ] }
    , { family = "Dialog", members = [ Member "Dialog" "dialog", Member "DialogAction" "action", Member "DialogTrigger" "trigger" ] }
    , { family = "DrawerContainer", members = [ Member "DrawerContainer" "drawerContainer", Member "DrawerToggle" "toggle" ] }
    , { family = "FabMenu", members = [ Member "FabMenu" "fabMenu", Member "FabMenuItem" "item", Member "FabMenuTrigger" "trigger" ] }
    , { family = "List", members = [ Member "List" "list", Member "ListItem" "item", Member "ListAction" "action", Member "ListOption" "option" ] }
    , { family = "Menu", members = [ Member "Menu" "menu", Member "MenuItem" "item", Member "MenuItemCheckbox" "itemCheckbox", Member "MenuItemGroup" "itemGroup", Member "MenuItemRadio" "itemRadio", Member "MenuTrigger" "trigger" ] }
    , { family = "NavMenu", members = [ Member "NavMenu" "navMenu", Member "NavMenuItem" "item", Member "NavMenuItemGroup" "itemGroup" ] }
    , { family = "NavRail", members = [ Member "NavRail" "navRail", Member "NavRailToggle" "toggle" ] }
    , { family = "Progress", members = [ Member "CircularProgressIndicator" "circular", Member "LinearProgressIndicator" "linear", Member "LoadingIndicator" "loading" ] }
    , { family = "RichTooltip", members = [ Member "RichTooltip" "richTooltip", Member "RichTooltipAction" "action" ] }
    , { family = "SegmentedButton", members = [ Member "SegmentedButton" "segmentedButton", Member "ButtonSegment" "segment", Member "ButtonGroup" "group" ] }
    , { family = "Stepper", members = [ Member "Stepper" "stepper", Member "Step" "step", Member "StepPanel" "panel", Member "StepperNext" "next", Member "StepperPrevious" "previous", Member "StepperReset" "reset" ] }
    , { family = "Tabs", members = [ Member "Tabs" "tabs", Member "Tab" "tab", Member "TabPanel" "panel" ] }
    , { family = "Timepicker", members = [ Member "Timepicker" "timepicker", Member "TimepickerToggle" "toggle", Member "TimepickerDial" "dial", Member "TimepickerInput" "input", Member "TimepickerInputPeriodToggle" "inputPeriodToggle" ] }
    , { family = "Toc", members = [ Member "Toc" "toc", Member "TocItem" "item" ] }
    , { family = "Tree", members = [ Member "Tree" "tree", Member "TreeItem" "item" ] }
    ]


pageHeading : Element { s | heading : M3e.Kind.Brand } admittedBy msg
pageHeading =
    M3e.heading
        [ M3e.Component.Heading.variant Value.display
        , M3e.Component.Heading.size Value.small
        , M3e.Attributes.level 1
        ]
        [ M3e.text "Family" ]


memberRowText : String -> Member -> String
memberRowText family member =
    "M3e.Family." ++ family ++ "." ++ member.label ++ " — " ++ member.component


familyCard : Family -> Element { s | card : M3e.Kind.Brand } admittedBy msg
familyCard family =
    M3e.card
        [ M3e.Component.Card.variant Value.elevated
        , M3e.Attributes.class "min-w-0"
        ]
        [ M3e.Component.Card.header
            (M3e.heading [ M3e.Component.Heading.variant Value.title ]
                [ M3e.text family.family ]
            )
        , M3e.Component.Card.content
            (TypedHtml.div [ TA.class "space-y-2" ]
                [ TypedHtml.p []
                    [ M3e.text
                        (String.fromInt (List.length family.members)
                            ++ " member"
                            ++ (if List.length family.members == 1 then
                                    ""

                                else
                                    "s"
                               )
                            ++ " · import M3e.Family."
                            ++ family.family
                        )
                    ]
                , TypedHtml.ul [ TA.class "space-y-1 pl-5 break-words" ]
                    (List.map
                        (\member ->
                            TypedHtml.li []
                                [ M3e.text (memberRowText family.family member) ]
                        )
                        family.members
                    )
                ]
            )
        ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Family"
        (Doc.pane
            [ TypedHtml.section [ TA.class "space-y-3" ]
                [ pageHeading
                , TypedHtml.div [ TA.class "max-w-2xl" ]
                    [ TypedHtml.p []
                        [ M3e.text "A family groups sibling-variant components that only ever appear together — assist/filter/input/suggestion chips, a nav-rail and its toggle, a dialog and its trigger — into one flat module, "
                        , TypedHtml.code [] [ M3e.text "M3e.Family.<Name>" ]
                        , M3e.text ", re-exporting every member as an element-named constructor. Importing "
                        , TypedHtml.code [] [ M3e.text "M3e.Family.Chip" ]
                        , M3e.text " reads the same as importing "
                        , TypedHtml.code [] [ M3e.text "M3e.Component.Chip" ]
                        , M3e.text " plus every sibling chip module, one import instead of many — the components and types are identical either way."
                        ]
                    ]
                ]
            , TypedHtml.section [ TA.class "grid gap-4 sm:grid-cols-2" ]
                (List.map familyCard families)
            ]
        )
