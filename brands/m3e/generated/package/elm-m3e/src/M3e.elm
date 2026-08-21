module M3e exposing
    ( accordion, actionList, appBar, assistChip, autocomplete, avatar, badge, bottomSheet, bottomSheetAction, bottomSheetTrigger, breadcrumb, breadcrumbItem, breadcrumbItemButton, button, buttonGroup, buttonSegment, calendar, card, checkbox, chip, chipSet, circularProgressIndicator, collapsible, contentPane, dateInput, datepicker, datepickerToggle, dialog, dialogAction, dialogTrigger, divider, drawerContainer, drawerToggle, elevation, expandableListItem, expansionHeader, expansionPanel, fab, fabMenu, fabMenuItem, fabMenuTrigger, filterChip, filterChipSet, floatingPanel, focusRing, focusTrap, formField, heading, icon, iconButton, inputChip, inputChipSet, linearProgressIndicator, list, listAction, listItem, listItemButton, listOption, loadingIndicator, menu, menuItem, menuItemCheckbox, menuItemGroup, menuItemRadio, menuTrigger, monthView, multiYearView, navBar, navItem, navMenu, navMenuItem, navMenuItemGroup, navRail, navRailToggle, optgroup, option, optionPanel, paginator, pseudoCheckbox, pseudoRadio, radio, radioGroup, richTooltip, richTooltipAction, ripple, scrollContainer, searchBar, searchView, segmentedButton, select, selectionIndicator, selectionList, shape, skeleton, slide, slideGroup, slider, sliderThumb, snackbar, splitButton, splitPane, stateLayer, step, stepPanel, stepper, stepperNext, stepperPrevious, stepperReset, suggestionChip, switch, tab, tabPanel, tabs, textHighlight, textOverflow, textareaAutosize, theme, themeIcon, timepicker, timepickerDial, timepickerInput, timepickerInputPeriodToggle, timepickerToggle, toc, tocItem, toolbar, tooltip, tree, treeItem, yearView
    , text
    , slotActions, slotArrow, slotAvatar, slotBadge, slotClearIcon, slotCloseIcon, slotClosedLeading, slotClosedTrailing, slotContent, slotDoneIcon, slotEditIcon, slotEnd, slotError, slotErrorIcon, slotFirstPageIcon, slotFooter, slotHeader, slotHint, slotIcon, slotInput, slotItems, slotLabel, slotLastPageIcon, slotLeading, slotLeadingButton, slotLeadingIcon, slotLoading, slotNextIcon, slotNextPageIcon, slotNoData, slotOpenLeading, slotOpenToggleIcon, slotOpenTrailing, slotOverline, slotPanel, slotPrefix, slotPrefixText, slotPrevIcon, slotPreviousPageIcon, slotRemoveIcon, slotSearchIcon, slotSelected, slotSelectedIcon, slotSeparator, slotStart, slotStep, slotSubhead, slotSubtitle, slotSuffix, slotSuffixText, slotSupportingText, slotTitle, slotToggleIcon, slotTrailing, slotTrailingButton, slotTrailingIcon, slotValue
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId
    )

{-| The general surface: every component constructor in the elm/html call
shape, one import. Signatures reference each component's aliases — reach for
`M3e.<Component>` when you want the strict per-component surface (required
content, builder, narrowed values), and `M3e.Attributes` / `M3e.Events` /
`M3e.Values` for the shared vocabulary.

`toHtml` is the render bridge to `elm/html`.

The `slot<Name>` placers assign a child element to a named slot in any
component that accepts it. Admittance is open (broad row) — wrong-kind
placements are caught by `Cem.ValidSlotKind` (elm-review).

@docs accordion, actionList, appBar, assistChip, autocomplete, avatar, badge, bottomSheet, bottomSheetAction, bottomSheetTrigger, breadcrumb, breadcrumbItem, breadcrumbItemButton, button, buttonGroup, buttonSegment, calendar, card, checkbox, chip, chipSet, circularProgressIndicator, collapsible, contentPane, dateInput, datepicker, datepickerToggle, dialog, dialogAction, dialogTrigger, divider, drawerContainer, drawerToggle, elevation, expandableListItem, expansionHeader, expansionPanel, fab, fabMenu, fabMenuItem, fabMenuTrigger, filterChip, filterChipSet, floatingPanel, focusRing, focusTrap, formField, heading, icon, iconButton, inputChip, inputChipSet, linearProgressIndicator, list, listAction, listItem, listItemButton, listOption, loadingIndicator, menu, menuItem, menuItemCheckbox, menuItemGroup, menuItemRadio, menuTrigger, monthView, multiYearView, navBar, navItem, navMenu, navMenuItem, navMenuItemGroup, navRail, navRailToggle, optgroup, option, optionPanel, paginator, pseudoCheckbox, pseudoRadio, radio, radioGroup, richTooltip, richTooltipAction, ripple, scrollContainer, searchBar, searchView, segmentedButton, select, selectionIndicator, selectionList, shape, skeleton, slide, slideGroup, slider, sliderThumb, snackbar, splitButton, splitPane, stateLayer, step, stepPanel, stepper, stepperNext, stepperPrevious, stepperReset, suggestionChip, switch, tab, tabPanel, tabs, textHighlight, textOverflow, textareaAutosize, theme, themeIcon, timepicker, timepickerDial, timepickerInput, timepickerInputPeriodToggle, timepickerToggle, toc, tocItem, toolbar, tooltip, tree, treeItem, yearView
@docs text
@docs slotActions, slotArrow, slotAvatar, slotBadge, slotClearIcon, slotCloseIcon, slotClosedLeading, slotClosedTrailing, slotContent, slotDoneIcon, slotEditIcon, slotEnd, slotError, slotErrorIcon, slotFirstPageIcon, slotFooter, slotHeader, slotHint, slotIcon, slotInput, slotItems, slotLabel, slotLastPageIcon, slotLeading, slotLeadingButton, slotLeadingIcon, slotLoading, slotNextIcon, slotNextPageIcon, slotNoData, slotOpenLeading, slotOpenToggleIcon, slotOpenTrailing, slotOverline, slotPanel, slotPrefix, slotPrefixText, slotPrevIcon, slotPreviousPageIcon, slotRemoveIcon, slotSearchIcon, slotSelected, slotSelectedIcon, slotSeparator, slotStart, slotStep, slotSubhead, slotSubtitle, slotSuffix, slotSuffixText, slotSupportingText, slotTitle, slotToggleIcon, slotTrailing, slotTrailingButton, slotTrailingIcon, slotValue
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared)
import HtmlIr.Node
import M3e.Internal.Types.Accordion
import M3e.Internal.Types.ActionList
import M3e.Internal.Types.AppBar
import M3e.Internal.Types.AssistChip
import M3e.Internal.Types.Autocomplete
import M3e.Internal.Types.Avatar
import M3e.Internal.Types.Badge
import M3e.Internal.Types.BottomSheet
import M3e.Internal.Types.BottomSheetAction
import M3e.Internal.Types.BottomSheetTrigger
import M3e.Internal.Types.Breadcrumb
import M3e.Internal.Types.BreadcrumbItem
import M3e.Internal.Types.BreadcrumbItemButton
import M3e.Internal.Types.Button
import M3e.Internal.Types.ButtonGroup
import M3e.Internal.Types.ButtonSegment
import M3e.Internal.Types.Calendar
import M3e.Internal.Types.Card
import M3e.Internal.Types.Checkbox
import M3e.Internal.Types.Chip
import M3e.Internal.Types.ChipSet
import M3e.Internal.Types.CircularProgressIndicator
import M3e.Internal.Types.Collapsible
import M3e.Internal.Types.ContentPane
import M3e.Internal.Types.DateInput
import M3e.Internal.Types.Datepicker
import M3e.Internal.Types.DatepickerToggle
import M3e.Internal.Types.Dialog
import M3e.Internal.Types.DialogAction
import M3e.Internal.Types.DialogTrigger
import M3e.Internal.Types.Divider
import M3e.Internal.Types.DrawerContainer
import M3e.Internal.Types.DrawerToggle
import M3e.Internal.Types.Elevation
import M3e.Internal.Types.ExpandableListItem
import M3e.Internal.Types.ExpansionHeader
import M3e.Internal.Types.ExpansionPanel
import M3e.Internal.Types.Fab
import M3e.Internal.Types.FabMenu
import M3e.Internal.Types.FabMenuItem
import M3e.Internal.Types.FabMenuTrigger
import M3e.Internal.Types.FilterChip
import M3e.Internal.Types.FilterChipSet
import M3e.Internal.Types.FloatingPanel
import M3e.Internal.Types.FocusRing
import M3e.Internal.Types.FocusTrap
import M3e.Internal.Types.FormField
import M3e.Internal.Types.Heading
import M3e.Internal.Types.Icon
import M3e.Internal.Types.IconButton
import M3e.Internal.Types.InputChip
import M3e.Internal.Types.InputChipSet
import M3e.Internal.Types.LinearProgressIndicator
import M3e.Internal.Types.List
import M3e.Internal.Types.ListAction
import M3e.Internal.Types.ListItem
import M3e.Internal.Types.ListItemButton
import M3e.Internal.Types.ListOption
import M3e.Internal.Types.LoadingIndicator
import M3e.Internal.Types.Menu
import M3e.Internal.Types.MenuItem
import M3e.Internal.Types.MenuItemCheckbox
import M3e.Internal.Types.MenuItemGroup
import M3e.Internal.Types.MenuItemRadio
import M3e.Internal.Types.MenuTrigger
import M3e.Internal.Types.MonthView
import M3e.Internal.Types.MultiYearView
import M3e.Internal.Types.NavBar
import M3e.Internal.Types.NavItem
import M3e.Internal.Types.NavMenu
import M3e.Internal.Types.NavMenuItem
import M3e.Internal.Types.NavMenuItemGroup
import M3e.Internal.Types.NavRail
import M3e.Internal.Types.NavRailToggle
import M3e.Internal.Types.Optgroup
import M3e.Internal.Types.Option
import M3e.Internal.Types.OptionPanel
import M3e.Internal.Types.Paginator
import M3e.Internal.Types.PseudoCheckbox
import M3e.Internal.Types.PseudoRadio
import M3e.Internal.Types.Radio
import M3e.Internal.Types.RadioGroup
import M3e.Internal.Types.RichTooltip
import M3e.Internal.Types.RichTooltipAction
import M3e.Internal.Types.Ripple
import M3e.Internal.Types.ScrollContainer
import M3e.Internal.Types.SearchBar
import M3e.Internal.Types.SearchView
import M3e.Internal.Types.SegmentedButton
import M3e.Internal.Types.Select
import M3e.Internal.Types.SelectionIndicator
import M3e.Internal.Types.SelectionList
import M3e.Internal.Types.Shape
import M3e.Internal.Types.Skeleton
import M3e.Internal.Types.Slide
import M3e.Internal.Types.SlideGroup
import M3e.Internal.Types.Slider
import M3e.Internal.Types.SliderThumb
import M3e.Internal.Types.Snackbar
import M3e.Internal.Types.SplitButton
import M3e.Internal.Types.SplitPane
import M3e.Internal.Types.StateLayer
import M3e.Internal.Types.Step
import M3e.Internal.Types.StepPanel
import M3e.Internal.Types.Stepper
import M3e.Internal.Types.StepperNext
import M3e.Internal.Types.StepperPrevious
import M3e.Internal.Types.StepperReset
import M3e.Internal.Types.SuggestionChip
import M3e.Internal.Types.Switch
import M3e.Internal.Types.Tab
import M3e.Internal.Types.TabPanel
import M3e.Internal.Types.Tabs
import M3e.Internal.Types.TextHighlight
import M3e.Internal.Types.TextOverflow
import M3e.Internal.Types.TextareaAutosize
import M3e.Internal.Types.Theme
import M3e.Internal.Types.ThemeIcon
import M3e.Internal.Types.Timepicker
import M3e.Internal.Types.TimepickerDial
import M3e.Internal.Types.TimepickerInput
import M3e.Internal.Types.TimepickerInputPeriodToggle
import M3e.Internal.Types.TimepickerToggle
import M3e.Internal.Types.Toc
import M3e.Internal.Types.TocItem
import M3e.Internal.Types.Toolbar
import M3e.Internal.Types.Tooltip
import M3e.Internal.Types.Tree
import M3e.Internal.Types.TreeItem
import M3e.Internal.Types.YearView


{-| The loose `m3e-accordion` producer — open attribute/child rows, no required record. See `M3e.Element.Accordion.component` for the required-content form.
-}
accordion :
    List (Attr M3e.Internal.Types.Accordion.Attrs msg)
    -> List (Element M3e.Internal.Types.Accordion.Content (M3e.Internal.Types.Accordion.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Accordion.Is s) admittedBy msg
accordion attrs children =
    Ir.fromNode (Ir.node "m3e-accordion" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ActionList.component`.
-}
actionList :
    List (Attr M3e.Internal.Types.ActionList.Attrs msg)
    -> List (Element M3e.Internal.Types.ActionList.Content (M3e.Internal.Types.ActionList.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ActionList.Is s) admittedBy msg
actionList attrs children =
    Ir.fromNode (Ir.node "m3e-action-list" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.AppBar.component`.
-}
appBar :
    List (Attr M3e.Internal.Types.AppBar.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.AppBar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.AppBar.Is s) admittedBy msg
appBar attrs children =
    Ir.fromNode (Ir.node "m3e-app-bar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-assist-chip` producer — open attribute/child rows, no required record. See `M3e.Element.AssistChip.component` for the required-content form.
-}
assistChip :
    List (Attr M3e.Internal.Types.AssistChip.Attrs msg)
    -> List (Element M3e.Internal.Types.AssistChip.Content (M3e.Internal.Types.AssistChip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.AssistChip.Is s) admittedBy msg
assistChip attrs children =
    Ir.fromNode (Ir.node "m3e-assist-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Autocomplete.component`.
-}
autocomplete :
    List (Attr M3e.Internal.Types.Autocomplete.Attrs msg)
    -> List (Element M3e.Internal.Types.Autocomplete.Content (M3e.Internal.Types.Autocomplete.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Autocomplete.Is s) admittedBy msg
autocomplete attrs children =
    Ir.fromNode (Ir.node "m3e-autocomplete" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Avatar.component`.
-}
avatar :
    List (Attr M3e.Internal.Types.Avatar.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Avatar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Avatar.Is s) admittedBy msg
avatar attrs children =
    Ir.fromNode (Ir.node "m3e-avatar" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Badge.component`.
-}
badge :
    List (Attr M3e.Internal.Types.Badge.Attrs msg)
    -> List (Element M3e.Internal.Types.Badge.Content (M3e.Internal.Types.Badge.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Badge.Is s) admittedBy msg
badge attrs children =
    Ir.fromNode (Ir.node "m3e-badge" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.BottomSheet.component`.
-}
bottomSheet :
    List (Attr M3e.Internal.Types.BottomSheet.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.BottomSheet.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.BottomSheet.Is s) admittedBy msg
bottomSheet attrs children =
    Ir.fromNode (Ir.node "m3e-bottom-sheet" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.BottomSheetAction.component`.
-}
bottomSheetAction :
    List (Attr M3e.Internal.Types.BottomSheetAction.Attrs msg)
    -> List (Element M3e.Internal.Types.BottomSheetAction.Content (M3e.Internal.Types.BottomSheetAction.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.BottomSheetAction.Is s) admittedBy msg
bottomSheetAction attrs children =
    Ir.fromNode (Ir.node "m3e-bottom-sheet-action" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.BottomSheetTrigger.component`.
-}
bottomSheetTrigger :
    List (Attr M3e.Internal.Types.BottomSheetTrigger.Attrs msg)
    -> List (Element M3e.Internal.Types.BottomSheetTrigger.Content (M3e.Internal.Types.BottomSheetTrigger.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.BottomSheetTrigger.Is s) admittedBy msg
bottomSheetTrigger attrs children =
    Ir.fromNode (Ir.node "m3e-bottom-sheet-trigger" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-breadcrumb` producer — open attribute/child rows, no required record. See `M3e.Element.Breadcrumb.component` for the required-content form.
-}
breadcrumb :
    List (Attr M3e.Internal.Types.Breadcrumb.Attrs msg)
    -> List (Element M3e.Internal.Types.Breadcrumb.Content (M3e.Internal.Types.Breadcrumb.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Breadcrumb.Is s) admittedBy msg
breadcrumb attrs children =
    Ir.fromNode (Ir.node "m3e-breadcrumb" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.BreadcrumbItem.component`.
-}
breadcrumbItem :
    List (Attr M3e.Internal.Types.BreadcrumbItem.Attrs msg)
    -> List (Element M3e.Internal.Types.BreadcrumbItem.Content (M3e.Internal.Types.BreadcrumbItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.BreadcrumbItem.Is s) admittedBy msg
breadcrumbItem attrs children =
    Ir.fromNode (Ir.node "m3e-breadcrumb-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.BreadcrumbItemButton.component`.
-}
breadcrumbItemButton :
    List (Attr M3e.Internal.Types.BreadcrumbItemButton.Attrs msg)
    -> List (Element M3e.Internal.Types.BreadcrumbItemButton.Content (M3e.Internal.Types.BreadcrumbItemButton.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.BreadcrumbItemButton.Is s) admittedBy msg
breadcrumbItemButton attrs children =
    Ir.fromNode (Ir.node "m3e-breadcrumb-item-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-button` producer — open attribute/child rows, no required record. See `M3e.Element.Button.component` for the required-content form.
-}
button :
    List (Attr M3e.Internal.Types.Button.Attrs msg)
    -> List (Element M3e.Internal.Types.Button.Content (M3e.Internal.Types.Button.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Button.Is s) admittedBy msg
button attrs children =
    Ir.fromNode (Ir.node "m3e-button" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ButtonGroup.component`.
-}
buttonGroup :
    List (Attr M3e.Internal.Types.ButtonGroup.Attrs msg)
    -> List (Element M3e.Internal.Types.ButtonGroup.Content (M3e.Internal.Types.ButtonGroup.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ButtonGroup.Is s) admittedBy msg
buttonGroup attrs children =
    Ir.fromNode (Ir.node "m3e-button-group" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ButtonSegment.component`.
-}
buttonSegment :
    List (Attr M3e.Internal.Types.ButtonSegment.Attrs msg)
    -> List (Element M3e.Internal.Types.ButtonSegment.Content (M3e.Internal.Types.ButtonSegment.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ButtonSegment.Is s) admittedBy msg
buttonSegment attrs children =
    Ir.fromNode (Ir.node "m3e-button-segment" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Calendar.component`.
-}
calendar :
    List (Attr M3e.Internal.Types.Calendar.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Calendar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Calendar.Is s) admittedBy msg
calendar attrs children =
    Ir.fromNode (Ir.node "m3e-calendar" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Card.component`.
-}
card :
    List (Attr M3e.Internal.Types.Card.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Card.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Card.Is s) admittedBy msg
card attrs children =
    Ir.fromNode (Ir.node "m3e-card" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Checkbox.component`.
-}
checkbox :
    List (Attr M3e.Internal.Types.Checkbox.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Checkbox.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Checkbox.Is s) admittedBy msg
checkbox attrs children =
    Ir.fromNode (Ir.node "m3e-checkbox" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-chip` producer — open attribute/child rows, no required record. See `M3e.Element.Chip.component` for the required-content form.
-}
chip :
    List (Attr M3e.Internal.Types.Chip.Attrs msg)
    -> List (Element M3e.Internal.Types.Chip.Content (M3e.Internal.Types.Chip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Chip.Is s) admittedBy msg
chip attrs children =
    Ir.fromNode (Ir.node "m3e-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ChipSet.component`.
-}
chipSet :
    List (Attr M3e.Internal.Types.ChipSet.Attrs msg)
    -> List (Element M3e.Internal.Types.ChipSet.Content (M3e.Internal.Types.ChipSet.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ChipSet.Is s) admittedBy msg
chipSet attrs children =
    Ir.fromNode (Ir.node "m3e-chip-set" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.CircularProgressIndicator.component`.
-}
circularProgressIndicator :
    List (Attr M3e.Internal.Types.CircularProgressIndicator.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.CircularProgressIndicator.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.CircularProgressIndicator.Is s) admittedBy msg
circularProgressIndicator attrs children =
    Ir.fromNode (Ir.node "m3e-circular-progress-indicator" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Collapsible.component`.
-}
collapsible :
    List (Attr M3e.Internal.Types.Collapsible.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Collapsible.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Collapsible.Is s) admittedBy msg
collapsible attrs children =
    Ir.fromNode (Ir.node "m3e-collapsible" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ContentPane.component`.
-}
contentPane :
    List (Attr M3e.Internal.Types.ContentPane.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.ContentPane.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ContentPane.Is s) admittedBy msg
contentPane attrs children =
    Ir.fromNode (Ir.node "m3e-content-pane" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.DateInput.component`.
-}
dateInput :
    List (Attr M3e.Internal.Types.DateInput.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.DateInput.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.DateInput.Is s) admittedBy msg
dateInput attrs children =
    Ir.fromNode (Ir.node "m3e-date-input" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Datepicker.component`.
-}
datepicker :
    List (Attr M3e.Internal.Types.Datepicker.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Datepicker.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Datepicker.Is s) admittedBy msg
datepicker attrs children =
    Ir.fromNode (Ir.node "m3e-datepicker" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.DatepickerToggle.component`.
-}
datepickerToggle :
    List (Attr M3e.Internal.Types.DatepickerToggle.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.DatepickerToggle.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.DatepickerToggle.Is s) admittedBy msg
datepickerToggle attrs children =
    Ir.fromNode (Ir.node "m3e-datepicker-toggle" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Dialog.component`.
-}
dialog :
    List (Attr M3e.Internal.Types.Dialog.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Dialog.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Dialog.Is s) admittedBy msg
dialog attrs children =
    Ir.fromNode (Ir.node "m3e-dialog" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.DialogAction.component`.
-}
dialogAction :
    List (Attr M3e.Internal.Types.DialogAction.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.DialogAction.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.DialogAction.Is s) admittedBy msg
dialogAction attrs children =
    Ir.fromNode (Ir.node "m3e-dialog-action" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.DialogTrigger.component`.
-}
dialogTrigger :
    List (Attr M3e.Internal.Types.DialogTrigger.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.DialogTrigger.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.DialogTrigger.Is s) admittedBy msg
dialogTrigger attrs children =
    Ir.fromNode (Ir.node "m3e-dialog-trigger" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Divider.component`.
-}
divider :
    List (Attr M3e.Internal.Types.Divider.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Divider.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Divider.Is s) admittedBy msg
divider attrs children =
    Ir.fromNode (Ir.node "m3e-divider" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.DrawerContainer.component`.
-}
drawerContainer :
    List (Attr M3e.Internal.Types.DrawerContainer.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.DrawerContainer.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.DrawerContainer.Is s) admittedBy msg
drawerContainer attrs children =
    Ir.fromNode (Ir.node "m3e-drawer-container" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.DrawerToggle.component`.
-}
drawerToggle :
    List (Attr M3e.Internal.Types.DrawerToggle.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.DrawerToggle.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.DrawerToggle.Is s) admittedBy msg
drawerToggle attrs children =
    Ir.fromNode (Ir.node "m3e-drawer-toggle" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Elevation.component`.
-}
elevation :
    List (Attr M3e.Internal.Types.Elevation.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Elevation.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Elevation.Is s) admittedBy msg
elevation attrs children =
    Ir.fromNode (Ir.node "m3e-elevation" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ExpandableListItem.component`.
-}
expandableListItem :
    List (Attr M3e.Internal.Types.ExpandableListItem.Attrs msg)
    -> List (Element M3e.Internal.Types.ExpandableListItem.Content (M3e.Internal.Types.ExpandableListItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ExpandableListItem.Is s) admittedBy msg
expandableListItem attrs children =
    Ir.fromNode (Ir.node "m3e-expandable-list-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ExpansionHeader.component`.
-}
expansionHeader :
    List (Attr M3e.Internal.Types.ExpansionHeader.Attrs msg)
    -> List (Element M3e.Internal.Types.ExpansionHeader.Content (M3e.Internal.Types.ExpansionHeader.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ExpansionHeader.Is s) admittedBy msg
expansionHeader attrs children =
    Ir.fromNode (Ir.node "m3e-expansion-header" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-expansion-panel` producer — open attribute/child rows, no required record. See `M3e.Element.ExpansionPanel.component` for the required-content form.
-}
expansionPanel :
    List (Attr M3e.Internal.Types.ExpansionPanel.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.ExpansionPanel.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ExpansionPanel.Is s) admittedBy msg
expansionPanel attrs children =
    Ir.fromNode (Ir.node "m3e-expansion-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-fab` producer — open attribute/child rows, no required record. See `M3e.Element.Fab.component` for the required-content form.
-}
fab :
    List (Attr M3e.Internal.Types.Fab.Attrs msg)
    -> List (Element M3e.Internal.Types.Fab.Content (M3e.Internal.Types.Fab.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Fab.Is s) admittedBy msg
fab attrs children =
    Ir.fromNode (Ir.node "m3e-fab" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.FabMenu.component`.
-}
fabMenu :
    List (Attr M3e.Internal.Types.FabMenu.Attrs msg)
    -> List (Element M3e.Internal.Types.FabMenu.Content (M3e.Internal.Types.FabMenu.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.FabMenu.Is s) admittedBy msg
fabMenu attrs children =
    Ir.fromNode (Ir.node "m3e-fab-menu" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.FabMenuItem.component`.
-}
fabMenuItem :
    List (Attr M3e.Internal.Types.FabMenuItem.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.FabMenuItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.FabMenuItem.Is s) admittedBy msg
fabMenuItem attrs children =
    Ir.fromNode (Ir.node "m3e-fab-menu-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.FabMenuTrigger.component`.
-}
fabMenuTrigger :
    List (Attr M3e.Internal.Types.FabMenuTrigger.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.FabMenuTrigger.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.FabMenuTrigger.Is s) admittedBy msg
fabMenuTrigger attrs children =
    Ir.fromNode (Ir.node "m3e-fab-menu-trigger" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-filter-chip` producer — open attribute/child rows, no required record. See `M3e.Element.FilterChip.component` for the required-content form.
-}
filterChip :
    List (Attr M3e.Internal.Types.FilterChip.Attrs msg)
    -> List (Element M3e.Internal.Types.FilterChip.Content (M3e.Internal.Types.FilterChip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.FilterChip.Is s) admittedBy msg
filterChip attrs children =
    Ir.fromNode (Ir.node "m3e-filter-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.FilterChipSet.component`.
-}
filterChipSet :
    List (Attr M3e.Internal.Types.FilterChipSet.Attrs msg)
    -> List (Element M3e.Internal.Types.FilterChipSet.Content (M3e.Internal.Types.FilterChipSet.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.FilterChipSet.Is s) admittedBy msg
filterChipSet attrs children =
    Ir.fromNode (Ir.node "m3e-filter-chip-set" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.FloatingPanel.component`.
-}
floatingPanel :
    List (Attr M3e.Internal.Types.FloatingPanel.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.FloatingPanel.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.FloatingPanel.Is s) admittedBy msg
floatingPanel attrs children =
    Ir.fromNode (Ir.node "m3e-floating-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.FocusRing.component`.
-}
focusRing :
    List (Attr M3e.Internal.Types.FocusRing.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.FocusRing.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.FocusRing.Is s) admittedBy msg
focusRing attrs children =
    Ir.fromNode (Ir.node "m3e-focus-ring" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.FocusTrap.component`.
-}
focusTrap :
    List (Attr M3e.Internal.Types.FocusTrap.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.FocusTrap.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.FocusTrap.Is s) admittedBy msg
focusTrap attrs children =
    Ir.fromNode (Ir.node "m3e-focus-trap" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.FormField.component`.
-}
formField :
    List (Attr M3e.Internal.Types.FormField.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.FormField.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.FormField.Is s) admittedBy msg
formField attrs children =
    Ir.fromNode (Ir.node "m3e-form-field" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-heading` producer — open attribute/child rows, no required record. See `M3e.Element.Heading.component` for the required-content form.
-}
heading :
    List (Attr M3e.Internal.Types.Heading.Attrs msg)
    -> List (Element M3e.Internal.Types.Heading.Content (M3e.Internal.Types.Heading.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Heading.Is s) admittedBy msg
heading attrs children =
    Ir.fromNode (Ir.node "m3e-heading" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Icon.component`.
-}
icon :
    List (Attr M3e.Internal.Types.Icon.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Icon.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Icon.Is s) admittedBy msg
icon attrs children =
    Ir.fromNode (Ir.node "m3e-icon" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-icon-button` producer — open attribute/child rows, no required record. See `M3e.Element.IconButton.component` for the required-content form.
-}
iconButton :
    List (Attr M3e.Internal.Types.IconButton.Attrs msg)
    -> List (Element M3e.Internal.Types.IconButton.Content (M3e.Internal.Types.IconButton.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.IconButton.Is s) admittedBy msg
iconButton attrs children =
    Ir.fromNode (Ir.node "m3e-icon-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-input-chip` producer — open attribute/child rows, no required record. See `M3e.Element.InputChip.component` for the required-content form.
-}
inputChip :
    List (Attr M3e.Internal.Types.InputChip.Attrs msg)
    -> List (Element M3e.Internal.Types.InputChip.Content (M3e.Internal.Types.InputChip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.InputChip.Is s) admittedBy msg
inputChip attrs children =
    Ir.fromNode (Ir.node "m3e-input-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.InputChipSet.component`.
-}
inputChipSet :
    List (Attr M3e.Internal.Types.InputChipSet.Attrs msg)
    -> List (Element M3e.Internal.Types.InputChipSet.Content (M3e.Internal.Types.InputChipSet.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.InputChipSet.Is s) admittedBy msg
inputChipSet attrs children =
    Ir.fromNode (Ir.node "m3e-input-chip-set" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.LinearProgressIndicator.component`.
-}
linearProgressIndicator :
    List (Attr M3e.Internal.Types.LinearProgressIndicator.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.LinearProgressIndicator.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.LinearProgressIndicator.Is s) admittedBy msg
linearProgressIndicator attrs children =
    Ir.fromNode (Ir.node "m3e-linear-progress-indicator" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.List.component`.
-}
list :
    List (Attr M3e.Internal.Types.List.Attrs msg)
    -> List (Element M3e.Internal.Types.List.Content (M3e.Internal.Types.List.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.List.Is s) admittedBy msg
list attrs children =
    Ir.fromNode (Ir.node "m3e-list" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ListAction.component`.
-}
listAction :
    List (Attr M3e.Internal.Types.ListAction.Attrs msg)
    -> List (Element M3e.Internal.Types.ListAction.Content (M3e.Internal.Types.ListAction.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ListAction.Is s) admittedBy msg
listAction attrs children =
    Ir.fromNode (Ir.node "m3e-list-action" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ListItem.component`.
-}
listItem :
    List (Attr M3e.Internal.Types.ListItem.Attrs msg)
    -> List (Element M3e.Internal.Types.ListItem.Content (M3e.Internal.Types.ListItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ListItem.Is s) admittedBy msg
listItem attrs children =
    Ir.fromNode (Ir.node "m3e-list-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ListItemButton.component`.
-}
listItemButton :
    List (Attr M3e.Internal.Types.ListItemButton.Attrs msg)
    -> List (Element M3e.Internal.Types.ListItemButton.Content (M3e.Internal.Types.ListItemButton.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ListItemButton.Is s) admittedBy msg
listItemButton attrs children =
    Ir.fromNode (Ir.node "m3e-list-item-button" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ListOption.component`.
-}
listOption :
    List (Attr M3e.Internal.Types.ListOption.Attrs msg)
    -> List (Element M3e.Internal.Types.ListOption.Content (M3e.Internal.Types.ListOption.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ListOption.Is s) admittedBy msg
listOption attrs children =
    Ir.fromNode (Ir.node "m3e-list-option" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.LoadingIndicator.component`.
-}
loadingIndicator :
    List (Attr M3e.Internal.Types.LoadingIndicator.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.LoadingIndicator.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.LoadingIndicator.Is s) admittedBy msg
loadingIndicator attrs children =
    Ir.fromNode (Ir.node "m3e-loading-indicator" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Menu.component`.
-}
menu :
    List (Attr M3e.Internal.Types.Menu.Attrs msg)
    -> List (Element M3e.Internal.Types.Menu.Content (M3e.Internal.Types.Menu.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Menu.Is s) admittedBy msg
menu attrs children =
    Ir.fromNode (Ir.node "m3e-menu" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.MenuItem.component`.
-}
menuItem :
    List (Attr M3e.Internal.Types.MenuItem.Attrs msg)
    -> List (Element M3e.Internal.Types.MenuItem.Content (M3e.Internal.Types.MenuItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.MenuItem.Is s) admittedBy msg
menuItem attrs children =
    Ir.fromNode (Ir.node "m3e-menu-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.MenuItemCheckbox.component`.
-}
menuItemCheckbox :
    List (Attr M3e.Internal.Types.MenuItemCheckbox.Attrs msg)
    -> List (Element M3e.Internal.Types.MenuItemCheckbox.Content (M3e.Internal.Types.MenuItemCheckbox.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.MenuItemCheckbox.Is s) admittedBy msg
menuItemCheckbox attrs children =
    Ir.fromNode (Ir.node "m3e-menu-item-checkbox" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.MenuItemGroup.component`.
-}
menuItemGroup :
    List (Attr M3e.Internal.Types.MenuItemGroup.Attrs msg)
    -> List (Element M3e.Internal.Types.MenuItemGroup.Content (M3e.Internal.Types.MenuItemGroup.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.MenuItemGroup.Is s) admittedBy msg
menuItemGroup attrs children =
    Ir.fromNode (Ir.node "m3e-menu-item-group" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.MenuItemRadio.component`.
-}
menuItemRadio :
    List (Attr M3e.Internal.Types.MenuItemRadio.Attrs msg)
    -> List (Element M3e.Internal.Types.MenuItemRadio.Content (M3e.Internal.Types.MenuItemRadio.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.MenuItemRadio.Is s) admittedBy msg
menuItemRadio attrs children =
    Ir.fromNode (Ir.node "m3e-menu-item-radio" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.MenuTrigger.component`.
-}
menuTrigger :
    List (Attr M3e.Internal.Types.MenuTrigger.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.MenuTrigger.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.MenuTrigger.Is s) admittedBy msg
menuTrigger attrs children =
    Ir.fromNode (Ir.node "m3e-menu-trigger" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.MonthView.component`.
-}
monthView :
    List (Attr M3e.Internal.Types.MonthView.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.MonthView.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.MonthView.Is s) admittedBy msg
monthView attrs children =
    Ir.fromNode (Ir.node "m3e-month-view" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.MultiYearView.component`.
-}
multiYearView :
    List (Attr M3e.Internal.Types.MultiYearView.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.MultiYearView.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.MultiYearView.Is s) admittedBy msg
multiYearView attrs children =
    Ir.fromNode (Ir.node "m3e-multi-year-view" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.NavBar.component`.
-}
navBar :
    List (Attr M3e.Internal.Types.NavBar.Attrs msg)
    -> List (Element M3e.Internal.Types.NavBar.Content (M3e.Internal.Types.NavBar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.NavBar.Is s) admittedBy msg
navBar attrs children =
    Ir.fromNode (Ir.node "m3e-nav-bar" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.NavItem.component`.
-}
navItem :
    List (Attr M3e.Internal.Types.NavItem.Attrs msg)
    -> List (Element M3e.Internal.Types.NavItem.Content (M3e.Internal.Types.NavItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.NavItem.Is s) admittedBy msg
navItem attrs children =
    Ir.fromNode (Ir.node "m3e-nav-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.NavMenu.component`.
-}
navMenu :
    List (Attr M3e.Internal.Types.NavMenu.Attrs msg)
    -> List (Element M3e.Internal.Types.NavMenu.Content (M3e.Internal.Types.NavMenu.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.NavMenu.Is s) admittedBy msg
navMenu attrs children =
    Ir.fromNode (Ir.node "m3e-nav-menu" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-nav-menu-item` producer — open attribute/child rows, no required record. See `M3e.Element.NavMenuItem.component` for the required-content form.
-}
navMenuItem :
    List (Attr M3e.Internal.Types.NavMenuItem.Attrs msg)
    -> List (Element M3e.Internal.Types.NavMenuItem.Content (M3e.Internal.Types.NavMenuItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.NavMenuItem.Is s) admittedBy msg
navMenuItem attrs children =
    Ir.fromNode (Ir.node "m3e-nav-menu-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.NavMenuItemGroup.component`.
-}
navMenuItemGroup :
    List (Attr M3e.Internal.Types.NavMenuItemGroup.Attrs msg)
    -> List (Element M3e.Internal.Types.NavMenuItemGroup.Content (M3e.Internal.Types.NavMenuItemGroup.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.NavMenuItemGroup.Is s) admittedBy msg
navMenuItemGroup attrs children =
    Ir.fromNode (Ir.node "m3e-nav-menu-item-group" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.NavRail.component`.
-}
navRail :
    List (Attr M3e.Internal.Types.NavRail.Attrs msg)
    -> List (Element M3e.Internal.Types.NavRail.Content (M3e.Internal.Types.NavRail.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.NavRail.Is s) admittedBy msg
navRail attrs children =
    Ir.fromNode (Ir.node "m3e-nav-rail" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.NavRailToggle.component`.
-}
navRailToggle :
    List (Attr M3e.Internal.Types.NavRailToggle.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.NavRailToggle.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.NavRailToggle.Is s) admittedBy msg
navRailToggle attrs children =
    Ir.fromNode (Ir.node "m3e-nav-rail-toggle" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Optgroup.component`.
-}
optgroup :
    List (Attr M3e.Internal.Types.Optgroup.Attrs msg)
    -> List (Element M3e.Internal.Types.Optgroup.Content (M3e.Internal.Types.Optgroup.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Optgroup.Is s) admittedBy msg
optgroup attrs children =
    Ir.fromNode (Ir.node "m3e-optgroup" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-option` producer — open attribute/child rows, no required record. See `M3e.Element.Option.component` for the required-content form.
-}
option :
    List (Attr M3e.Internal.Types.Option.Attrs msg)
    -> List (Element M3e.Internal.Types.Option.Content (M3e.Internal.Types.Option.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Option.Is s) admittedBy msg
option attrs children =
    Ir.fromNode (Ir.node "m3e-option" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.OptionPanel.component`.
-}
optionPanel :
    List (Attr M3e.Internal.Types.OptionPanel.Attrs msg)
    -> List (Element M3e.Internal.Types.OptionPanel.Content (M3e.Internal.Types.OptionPanel.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.OptionPanel.Is s) admittedBy msg
optionPanel attrs children =
    Ir.fromNode (Ir.node "m3e-option-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Paginator.component`.
-}
paginator :
    List (Attr M3e.Internal.Types.Paginator.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Paginator.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Paginator.Is s) admittedBy msg
paginator attrs children =
    Ir.fromNode (Ir.node "m3e-paginator" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.PseudoCheckbox.component`.
-}
pseudoCheckbox :
    List (Attr M3e.Internal.Types.PseudoCheckbox.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.PseudoCheckbox.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.PseudoCheckbox.Is s) admittedBy msg
pseudoCheckbox attrs children =
    Ir.fromNode (Ir.node "m3e-pseudo-checkbox" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.PseudoRadio.component`.
-}
pseudoRadio :
    List (Attr M3e.Internal.Types.PseudoRadio.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.PseudoRadio.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.PseudoRadio.Is s) admittedBy msg
pseudoRadio attrs children =
    Ir.fromNode (Ir.node "m3e-pseudo-radio" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Radio.component`.
-}
radio :
    List (Attr M3e.Internal.Types.Radio.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Radio.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Radio.Is s) admittedBy msg
radio attrs children =
    Ir.fromNode (Ir.node "m3e-radio" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-radio-group` producer — open attribute/child rows, no required record. See `M3e.Element.RadioGroup.component` for the required-content form.
-}
radioGroup :
    List (Attr M3e.Internal.Types.RadioGroup.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.RadioGroup.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.RadioGroup.Is s) admittedBy msg
radioGroup attrs children =
    Ir.fromNode (Ir.node "m3e-radio-group" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-rich-tooltip` producer — open attribute/child rows, no required record. See `M3e.Element.RichTooltip.component` for the required-content form.
-}
richTooltip :
    List (Attr M3e.Internal.Types.RichTooltip.Attrs msg)
    -> List (Element M3e.Internal.Types.RichTooltip.Content (M3e.Internal.Types.RichTooltip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.RichTooltip.Is s) admittedBy msg
richTooltip attrs children =
    Ir.fromNode (Ir.node "m3e-rich-tooltip" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-rich-tooltip-action` producer — open attribute/child rows, no required record. See `M3e.Element.RichTooltipAction.component` for the required-content form.
-}
richTooltipAction :
    List (Attr M3e.Internal.Types.RichTooltipAction.Attrs msg)
    -> List (Element M3e.Internal.Types.RichTooltipAction.Content (M3e.Internal.Types.RichTooltipAction.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.RichTooltipAction.Is s) admittedBy msg
richTooltipAction attrs children =
    Ir.fromNode (Ir.node "m3e-rich-tooltip-action" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Ripple.component`.
-}
ripple :
    List (Attr M3e.Internal.Types.Ripple.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Ripple.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Ripple.Is s) admittedBy msg
ripple attrs children =
    Ir.fromNode (Ir.node "m3e-ripple" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ScrollContainer.component`.
-}
scrollContainer :
    List (Attr M3e.Internal.Types.ScrollContainer.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.ScrollContainer.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ScrollContainer.Is s) admittedBy msg
scrollContainer attrs children =
    Ir.fromNode (Ir.node "m3e-scroll-container" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-search-bar` producer — open attribute/child rows, no required record. See `M3e.Element.SearchBar.component` for the required-content form.
-}
searchBar :
    List (Attr M3e.Internal.Types.SearchBar.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.SearchBar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.SearchBar.Is s) admittedBy msg
searchBar attrs children =
    Ir.fromNode (Ir.node "m3e-search-bar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-search-view` producer — open attribute/child rows, no required record. See `M3e.Element.SearchView.component` for the required-content form.
-}
searchView :
    List (Attr M3e.Internal.Types.SearchView.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.SearchView.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.SearchView.Is s) admittedBy msg
searchView attrs children =
    Ir.fromNode (Ir.node "m3e-search-view" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-segmented-button` producer — open attribute/child rows, no required record. See `M3e.Element.SegmentedButton.component` for the required-content form.
-}
segmentedButton :
    List (Attr M3e.Internal.Types.SegmentedButton.Attrs msg)
    -> List (Element M3e.Internal.Types.SegmentedButton.Content (M3e.Internal.Types.SegmentedButton.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.SegmentedButton.Is s) admittedBy msg
segmentedButton attrs children =
    Ir.fromNode (Ir.node "m3e-segmented-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-select` producer — open attribute/child rows, no required record. See `M3e.Element.Select.component` for the required-content form.
-}
select :
    List (Attr M3e.Internal.Types.Select.Attrs msg)
    -> List (Element M3e.Internal.Types.Select.Content (M3e.Internal.Types.Select.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Select.Is s) admittedBy msg
select attrs children =
    Ir.fromNode (Ir.node "m3e-select" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.SelectionIndicator.component`.
-}
selectionIndicator :
    List (Attr M3e.Internal.Types.SelectionIndicator.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.SelectionIndicator.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.SelectionIndicator.Is s) admittedBy msg
selectionIndicator attrs children =
    Ir.fromNode (Ir.node "m3e-selection-indicator" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.SelectionList.component`.
-}
selectionList :
    List (Attr M3e.Internal.Types.SelectionList.Attrs msg)
    -> List (Element M3e.Internal.Types.SelectionList.Content (M3e.Internal.Types.SelectionList.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.SelectionList.Is s) admittedBy msg
selectionList attrs children =
    Ir.fromNode (Ir.node "m3e-selection-list" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Shape.component`.
-}
shape :
    List (Attr M3e.Internal.Types.Shape.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Shape.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Shape.Is s) admittedBy msg
shape attrs children =
    Ir.fromNode (Ir.node "m3e-shape" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Skeleton.component`.
-}
skeleton :
    List (Attr M3e.Internal.Types.Skeleton.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Skeleton.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Skeleton.Is s) admittedBy msg
skeleton attrs children =
    Ir.fromNode (Ir.node "m3e-skeleton" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Slide.component`.
-}
slide :
    List (Attr M3e.Internal.Types.Slide.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Slide.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Slide.Is s) admittedBy msg
slide attrs children =
    Ir.fromNode (Ir.node "m3e-slide" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.SlideGroup.component`.
-}
slideGroup :
    List (Attr M3e.Internal.Types.SlideGroup.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.SlideGroup.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.SlideGroup.Is s) admittedBy msg
slideGroup attrs children =
    Ir.fromNode (Ir.node "m3e-slide-group" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-slider` producer — open attribute/child rows, no required record. See `M3e.Element.Slider.component` for the required-content form.
-}
slider :
    List (Attr M3e.Internal.Types.Slider.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Slider.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Slider.Is s) admittedBy msg
slider attrs children =
    Ir.fromNode (Ir.node "m3e-slider" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.SliderThumb.component`.
-}
sliderThumb :
    List (Attr M3e.Internal.Types.SliderThumb.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.SliderThumb.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.SliderThumb.Is s) admittedBy msg
sliderThumb attrs children =
    Ir.fromNode (Ir.node "m3e-slider-thumb" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-snackbar` producer — open attribute/child rows, no required record. See `M3e.Element.Snackbar.component` for the required-content form.
-}
snackbar :
    List (Attr M3e.Internal.Types.Snackbar.Attrs msg)
    -> List (Element M3e.Internal.Types.Snackbar.Content (M3e.Internal.Types.Snackbar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Snackbar.Is s) admittedBy msg
snackbar attrs children =
    Ir.fromNode (Ir.node "m3e-snackbar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-split-button` producer — open attribute/child rows, no required record. See `M3e.Element.SplitButton.component` for the required-content form.
-}
splitButton :
    List (Attr M3e.Internal.Types.SplitButton.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.SplitButton.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.SplitButton.Is s) admittedBy msg
splitButton attrs children =
    Ir.fromNode (Ir.node "m3e-split-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-split-pane` producer — open attribute/child rows, no required record. See `M3e.Element.SplitPane.component` for the required-content form.
-}
splitPane :
    List (Attr M3e.Internal.Types.SplitPane.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.SplitPane.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.SplitPane.Is s) admittedBy msg
splitPane attrs children =
    Ir.fromNode (Ir.node "m3e-split-pane" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.StateLayer.component`.
-}
stateLayer :
    List (Attr M3e.Internal.Types.StateLayer.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.StateLayer.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.StateLayer.Is s) admittedBy msg
stateLayer attrs children =
    Ir.fromNode (Ir.node "m3e-state-layer" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-step` producer — open attribute/child rows, no required record. See `M3e.Element.Step.component` for the required-content form.
-}
step :
    List (Attr M3e.Internal.Types.Step.Attrs msg)
    -> List (Element M3e.Internal.Types.Step.Content (M3e.Internal.Types.Step.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Step.Is s) admittedBy msg
step attrs children =
    Ir.fromNode (Ir.node "m3e-step" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.StepPanel.component`.
-}
stepPanel :
    List (Attr M3e.Internal.Types.StepPanel.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.StepPanel.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.StepPanel.Is s) admittedBy msg
stepPanel attrs children =
    Ir.fromNode (Ir.node "m3e-step-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Stepper.component`.
-}
stepper :
    List (Attr M3e.Internal.Types.Stepper.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Stepper.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Stepper.Is s) admittedBy msg
stepper attrs children =
    Ir.fromNode (Ir.node "m3e-stepper" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.StepperNext.component`.
-}
stepperNext :
    List (Attr M3e.Internal.Types.StepperNext.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.StepperNext.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.StepperNext.Is s) admittedBy msg
stepperNext attrs children =
    Ir.fromNode (Ir.node "m3e-stepper-next" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.StepperPrevious.component`.
-}
stepperPrevious :
    List (Attr M3e.Internal.Types.StepperPrevious.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.StepperPrevious.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.StepperPrevious.Is s) admittedBy msg
stepperPrevious attrs children =
    Ir.fromNode (Ir.node "m3e-stepper-previous" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.StepperReset.component`.
-}
stepperReset :
    List (Attr M3e.Internal.Types.StepperReset.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.StepperReset.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.StepperReset.Is s) admittedBy msg
stepperReset attrs children =
    Ir.fromNode (Ir.node "m3e-stepper-reset" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-suggestion-chip` producer — open attribute/child rows, no required record. See `M3e.Element.SuggestionChip.component` for the required-content form.
-}
suggestionChip :
    List (Attr M3e.Internal.Types.SuggestionChip.Attrs msg)
    -> List (Element M3e.Internal.Types.SuggestionChip.Content (M3e.Internal.Types.SuggestionChip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.SuggestionChip.Is s) admittedBy msg
suggestionChip attrs children =
    Ir.fromNode (Ir.node "m3e-suggestion-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Switch.component`.
-}
switch :
    List (Attr M3e.Internal.Types.Switch.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Switch.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Switch.Is s) admittedBy msg
switch attrs children =
    Ir.fromNode (Ir.node "m3e-switch" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Tab.component`.
-}
tab :
    List (Attr M3e.Internal.Types.Tab.Attrs msg)
    -> List (Element M3e.Internal.Types.Tab.Content (M3e.Internal.Types.Tab.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Tab.Is s) admittedBy msg
tab attrs children =
    Ir.fromNode (Ir.node "m3e-tab" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.TabPanel.component`.
-}
tabPanel :
    List (Attr M3e.Internal.Types.TabPanel.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.TabPanel.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.TabPanel.Is s) admittedBy msg
tabPanel attrs children =
    Ir.fromNode (Ir.node "m3e-tab-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Tabs.component`.
-}
tabs :
    List (Attr M3e.Internal.Types.Tabs.Attrs msg)
    -> List (Element M3e.Internal.Types.Tabs.Content (M3e.Internal.Types.Tabs.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Tabs.Is s) admittedBy msg
tabs attrs children =
    Ir.fromNode (Ir.node "m3e-tabs" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.TextHighlight.component`.
-}
textHighlight :
    List (Attr M3e.Internal.Types.TextHighlight.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.TextHighlight.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.TextHighlight.Is s) admittedBy msg
textHighlight attrs children =
    Ir.fromNode (Ir.node "m3e-text-highlight" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.TextOverflow.component`.
-}
textOverflow :
    List (Attr M3e.Internal.Types.TextOverflow.Attrs msg)
    -> List (Element M3e.Internal.Types.TextOverflow.Content (M3e.Internal.Types.TextOverflow.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.TextOverflow.Is s) admittedBy msg
textOverflow attrs children =
    Ir.fromNode (Ir.node "m3e-text-overflow" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.TextareaAutosize.component`.
-}
textareaAutosize :
    List (Attr M3e.Internal.Types.TextareaAutosize.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.TextareaAutosize.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.TextareaAutosize.Is s) admittedBy msg
textareaAutosize attrs children =
    Ir.fromNode (Ir.node "m3e-textarea-autosize" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Theme.component`.
-}
theme :
    List (Attr M3e.Internal.Types.Theme.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Theme.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Theme.Is s) admittedBy msg
theme attrs children =
    Ir.fromNode (Ir.node "m3e-theme" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.ThemeIcon.component`.
-}
themeIcon :
    List (Attr M3e.Internal.Types.ThemeIcon.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.ThemeIcon.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.ThemeIcon.Is s) admittedBy msg
themeIcon attrs children =
    Ir.fromNode (Ir.node "m3e-theme-icon" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Timepicker.component`.
-}
timepicker :
    List (Attr M3e.Internal.Types.Timepicker.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Timepicker.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Timepicker.Is s) admittedBy msg
timepicker attrs children =
    Ir.fromNode (Ir.node "m3e-timepicker" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.TimepickerDial.component`.
-}
timepickerDial :
    List (Attr M3e.Internal.Types.TimepickerDial.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.TimepickerDial.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.TimepickerDial.Is s) admittedBy msg
timepickerDial attrs children =
    Ir.fromNode (Ir.node "m3e-timepicker-dial" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.TimepickerInput.component`.
-}
timepickerInput :
    List (Attr M3e.Internal.Types.TimepickerInput.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.TimepickerInput.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.TimepickerInput.Is s) admittedBy msg
timepickerInput attrs children =
    Ir.fromNode (Ir.node "m3e-timepicker-input" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.TimepickerInputPeriodToggle.component`.
-}
timepickerInputPeriodToggle :
    List (Attr M3e.Internal.Types.TimepickerInputPeriodToggle.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.TimepickerInputPeriodToggle.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.TimepickerInputPeriodToggle.Is s) admittedBy msg
timepickerInputPeriodToggle attrs children =
    Ir.fromNode (Ir.node "m3e-timepicker-input-period-toggle" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.TimepickerToggle.component`.
-}
timepickerToggle :
    List (Attr M3e.Internal.Types.TimepickerToggle.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.TimepickerToggle.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.TimepickerToggle.Is s) admittedBy msg
timepickerToggle attrs children =
    Ir.fromNode (Ir.node "m3e-timepicker-toggle" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Toc.component`.
-}
toc :
    List (Attr M3e.Internal.Types.Toc.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Toc.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Toc.Is s) admittedBy msg
toc attrs children =
    Ir.fromNode (Ir.node "m3e-toc" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-toc-item` producer — open attribute/child rows, no required record. See `M3e.Element.TocItem.component` for the required-content form.
-}
tocItem :
    List (Attr M3e.Internal.Types.TocItem.Attrs msg)
    -> List (Element M3e.Internal.Types.TocItem.Content (M3e.Internal.Types.TocItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.TocItem.Is s) admittedBy msg
tocItem attrs children =
    Ir.fromNode (Ir.node "m3e-toc-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Toolbar.component`.
-}
toolbar :
    List (Attr M3e.Internal.Types.Toolbar.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.Toolbar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Toolbar.Is s) admittedBy msg
toolbar attrs children =
    Ir.fromNode (Ir.node "m3e-toolbar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-tooltip` producer — open attribute/child rows, no required record. See `M3e.Element.Tooltip.component` for the required-content form.
-}
tooltip :
    List (Attr M3e.Internal.Types.Tooltip.Attrs msg)
    -> List (Element M3e.Internal.Types.Tooltip.Content (M3e.Internal.Types.Tooltip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Tooltip.Is s) admittedBy msg
tooltip attrs children =
    Ir.fromNode (Ir.node "m3e-tooltip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.Tree.component`.
-}
tree :
    List (Attr M3e.Internal.Types.Tree.Attrs msg)
    -> List (Element M3e.Internal.Types.Tree.Content (M3e.Internal.Types.Tree.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.Tree.Is s) admittedBy msg
tree attrs children =
    Ir.fromNode (Ir.node "m3e-tree" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-tree-item` producer — open attribute/child rows, no required record. See `M3e.Element.TreeItem.component` for the required-content form.
-}
treeItem :
    List (Attr M3e.Internal.Types.TreeItem.Attrs msg)
    -> List (Element M3e.Internal.Types.TreeItem.Content (M3e.Internal.Types.TreeItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.TreeItem.Is s) admittedBy msg
treeItem attrs children =
    Ir.fromNode (Ir.node "m3e-tree-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Element.YearView.component`.
-}
yearView :
    List (Attr M3e.Internal.Types.YearView.Attrs msg)
    -> List (Element childAccepts (M3e.Internal.Types.YearView.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Internal.Types.YearView.Is s) admittedBy msg
yearView attrs children =
    Ir.fromNode (Ir.node "m3e-year-view" attrs (List.map HtmlIr.Element.toNode children))


{-| The shared text atom — admissible into any library's opted-in slot.
-}
text : String -> Element { s | sharedText : Shared } admittedBy msg
text value_ =
    Ir.fromNode (Ir.text value_)


{-| Place a child element into the `"actions"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotActions : Element accepts admittedBy msg -> Element free freeAdm msg
slotActions el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "actions") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"arrow"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotArrow : Element accepts admittedBy msg -> Element free freeAdm msg
slotArrow el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "arrow") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"avatar"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotAvatar : Element accepts admittedBy msg -> Element free freeAdm msg
slotAvatar el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "avatar") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"badge"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotBadge : Element accepts admittedBy msg -> Element free freeAdm msg
slotBadge el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "badge") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"clear-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotClearIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotClearIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "clear-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"close-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotCloseIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotCloseIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "close-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"closed-leading"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotClosedLeading : Element accepts admittedBy msg -> Element free freeAdm msg
slotClosedLeading el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "closed-leading") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"closed-trailing"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotClosedTrailing : Element accepts admittedBy msg -> Element free freeAdm msg
slotClosedTrailing el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "closed-trailing") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"content"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotContent : Element accepts admittedBy msg -> Element free freeAdm msg
slotContent el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "content") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"done-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotDoneIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotDoneIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "done-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"edit-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotEditIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotEditIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "edit-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"end"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotEnd : Element accepts admittedBy msg -> Element free freeAdm msg
slotEnd el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "end") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"error"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotError : Element accepts admittedBy msg -> Element free freeAdm msg
slotError el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "error") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"error-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotErrorIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotErrorIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "error-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"first-page-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotFirstPageIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotFirstPageIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "first-page-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"footer"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotFooter : Element accepts admittedBy msg -> Element free freeAdm msg
slotFooter el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "footer") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"header"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotHeader : Element accepts admittedBy msg -> Element free freeAdm msg
slotHeader el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "header") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"hint"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotHint : Element accepts admittedBy msg -> Element free freeAdm msg
slotHint el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "hint") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"input"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotInput : Element accepts admittedBy msg -> Element free freeAdm msg
slotInput el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "input") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"items"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotItems : Element accepts admittedBy msg -> Element free freeAdm msg
slotItems el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "items") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"label"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotLabel : Element accepts admittedBy msg -> Element free freeAdm msg
slotLabel el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "label") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"last-page-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotLastPageIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotLastPageIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "last-page-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"leading"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotLeading : Element accepts admittedBy msg -> Element free freeAdm msg
slotLeading el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "leading") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"leading-button"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotLeadingButton : Element accepts admittedBy msg -> Element free freeAdm msg
slotLeadingButton el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "leading-button") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"leading-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotLeadingIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotLeadingIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "leading-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"loading"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotLoading : Element accepts admittedBy msg -> Element free freeAdm msg
slotLoading el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "loading") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"next-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotNextIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotNextIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "next-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"next-page-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotNextPageIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotNextPageIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "next-page-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"no-data"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotNoData : Element accepts admittedBy msg -> Element free freeAdm msg
slotNoData el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "no-data") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"open-leading"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotOpenLeading : Element accepts admittedBy msg -> Element free freeAdm msg
slotOpenLeading el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "open-leading") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"open-toggle-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotOpenToggleIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotOpenToggleIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "open-toggle-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"open-trailing"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotOpenTrailing : Element accepts admittedBy msg -> Element free freeAdm msg
slotOpenTrailing el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "open-trailing") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"overline"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotOverline : Element accepts admittedBy msg -> Element free freeAdm msg
slotOverline el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "overline") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"panel"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotPanel : Element accepts admittedBy msg -> Element free freeAdm msg
slotPanel el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "panel") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"prefix"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotPrefix : Element accepts admittedBy msg -> Element free freeAdm msg
slotPrefix el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "prefix") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"prefix-text"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotPrefixText : Element accepts admittedBy msg -> Element free freeAdm msg
slotPrefixText el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "prefix-text") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"prev-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotPrevIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotPrevIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "prev-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"previous-page-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotPreviousPageIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotPreviousPageIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "previous-page-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"remove-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotRemoveIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotRemoveIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "remove-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"search-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotSearchIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotSearchIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "search-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"selected"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotSelected : Element accepts admittedBy msg -> Element free freeAdm msg
slotSelected el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "selected") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"selected-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotSelectedIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotSelectedIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "selected-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"separator"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotSeparator : Element accepts admittedBy msg -> Element free freeAdm msg
slotSeparator el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "separator") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"start"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotStart : Element accepts admittedBy msg -> Element free freeAdm msg
slotStart el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "start") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"step"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotStep : Element accepts admittedBy msg -> Element free freeAdm msg
slotStep el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "step") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"subhead"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotSubhead : Element accepts admittedBy msg -> Element free freeAdm msg
slotSubhead el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "subhead") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"subtitle"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotSubtitle : Element accepts admittedBy msg -> Element free freeAdm msg
slotSubtitle el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "subtitle") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"suffix"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotSuffix : Element accepts admittedBy msg -> Element free freeAdm msg
slotSuffix el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "suffix") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"suffix-text"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotSuffixText : Element accepts admittedBy msg -> Element free freeAdm msg
slotSuffixText el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "suffix-text") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"supporting-text"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotSupportingText : Element accepts admittedBy msg -> Element free freeAdm msg
slotSupportingText el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "supporting-text") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"title"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotTitle : Element accepts admittedBy msg -> Element free freeAdm msg
slotTitle el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "title") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"toggle-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotToggleIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotToggleIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "toggle-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"trailing"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotTrailing : Element accepts admittedBy msg -> Element free freeAdm msg
slotTrailing el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"trailing-button"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotTrailingButton : Element accepts admittedBy msg -> Element free freeAdm msg
slotTrailingButton el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing-button") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"trailing-icon"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotTrailingIcon : Element accepts admittedBy msg -> Element free freeAdm msg
slotTrailingIcon el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing-icon") (HtmlIr.Element.toNode el_))


{-| Place a child element into the `"value"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule.
-}
slotValue : Element accepts admittedBy msg -> Element free freeAdm msg
slotValue el_ =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "value") (HtmlIr.Element.toNode el_))


{-| The typed IR element every constructor here produces. Re-exported so callers never import `HtmlIr.Element` directly.
-}
type alias Element accepts admittedBy msg =
    HtmlIr.Element.Element accepts admittedBy msg


{-| A typed attribute. Re-exported so callers never import `HtmlIr.Attribute` directly.
-}
type alias Attr capability msg =
    HtmlIr.Attribute.Attr capability msg


{-| The untyped IR node an `Element` wraps — the erased form, carrying no phantom claims. Re-exported for the boundaries that must store renderable content in a monomorphic field (a framework `View` record, a cache); lift it back with `<Lib>.Unsafe.fromNode`.
-}
type alias Node msg =
    HtmlIr.Node.Node msg


{-| Render any element from this library to `elm/html`.
-}
toHtml : Element accepts admittedBy msg -> Html.Html msg
toHtml =
    HtmlIr.Element.toNode >> HtmlIr.Node.toHtml


{-| Erase an element to its untyped [`Node`](#Node) — the safe out-bound direction; the phantom rows are discarded, never re-asserted.
-}
toNode : Element accepts admittedBy msg -> Node msg
toNode =
    HtmlIr.Element.toNode


{-| Map the `msg` type of any element from this library (the typed IR's `Html.map`). Structural: the tree is not rendered, rows are preserved.
-}
mapMsg : (a -> b) -> Element accepts admittedBy a -> Element accepts admittedBy b
mapMsg =
    HtmlIr.Element.map


{-| [`mapMsg`](#mapMsg) for an erased [`Node`](#Node).
-}
mapNode : (a -> b) -> Node a -> Node b
mapNode =
    HtmlIr.Node.map


{-| Attach a diff key to a child so its parent container renders as a keyed node. State and animations survive reorders, insertions, and removals. Phantom rows are preserved — a keyed chip is still a chip.
-}
key : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
key =
    HtmlIr.Element.key


{-| Memoise a subtree while its input is referentially unchanged. The result keeps its phantom rows and drops into any slot. **The view function must be a stable top-level binding** — an inline lambda allocates a fresh closure each render and silently never memoises.
-}
lazy : (a -> Element accepts admittedBy msg) -> a -> Element accepts admittedBy msg
lazy =
    HtmlIr.Element.lazy


{-| 2-argument variant of [`lazy`](#lazy).
-}
lazy2 : (a -> b -> Element accepts admittedBy msg) -> a -> b -> Element accepts admittedBy msg
lazy2 =
    HtmlIr.Element.lazy2


{-| 3-argument variant of [`lazy`](#lazy).
-}
lazy3 : (a -> b -> c -> Element accepts admittedBy msg) -> a -> b -> c -> Element accepts admittedBy msg
lazy3 =
    HtmlIr.Element.lazy3


{-| 4-argument variant of [`lazy`](#lazy).
-}
lazy4 : (a -> b -> c -> d -> Element accepts admittedBy msg) -> a -> b -> c -> d -> Element accepts admittedBy msg
lazy4 =
    HtmlIr.Element.lazy4


{-| 5-argument variant of [`lazy`](#lazy).
-}
lazy5 : (a -> b -> c -> d -> e -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> Element accepts admittedBy msg
lazy5 =
    HtmlIr.Element.lazy5


{-| 6-argument variant of [`lazy`](#lazy). Note type params skip `f` to match the underlying `VirtualDom.lazy6` convention.
-}
lazy6 : (a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg
lazy6 =
    HtmlIr.Element.lazy6


{-| 7-argument variant of [`lazy`](#lazy).
-}
lazy7 : (a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg
lazy7 =
    HtmlIr.Element.lazy7


{-| 8-argument variant of [`lazy`](#lazy). **This variant does not memoise** — the Element→Html bridge only has room for seven memoised data arguments, so the eighth forces a fresh closure each render and defeats the reference check. For real memoisation, fold the extra state into one of the first seven arguments and use [`lazy7`](#lazy7).
-}
lazy8 : (a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg
lazy8 =
    HtmlIr.Element.lazy8


{-| Add a CSS class, participating in the `class` merge. Phantom rows preserved.
-}
addClass : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
addClass =
    HtmlIr.Element.addClass


{-| Conditionally attach an attribute — applied when the flag is `True`, a no-op when `False`. Phantom rows preserved.
-}
attrIf : Bool -> Attr capability msg -> Element accepts admittedBy msg -> Element accepts admittedBy msg
attrIf =
    HtmlIr.Element.attrIf


{-| Keep an element only when the flag is `True`; `False` collapses it to an empty node that renders nothing. Phantom rows preserved.
-}
when : Bool -> Element accepts admittedBy msg -> Element accepts admittedBy msg
when =
    HtmlIr.Element.when


{-| Stamp a `data-testid` attribute for test hooks. Phantom rows preserved.
-}
testId : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg
testId =
    HtmlIr.Element.testId
