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
import M3e.Component.Accordion
import M3e.Component.ActionList
import M3e.Component.AppBar
import M3e.Component.AssistChip
import M3e.Component.Autocomplete
import M3e.Component.Avatar
import M3e.Component.Badge
import M3e.Component.BottomSheet
import M3e.Component.BottomSheetAction
import M3e.Component.BottomSheetTrigger
import M3e.Component.Breadcrumb
import M3e.Component.BreadcrumbItem
import M3e.Component.BreadcrumbItemButton
import M3e.Component.Button
import M3e.Component.ButtonGroup
import M3e.Component.ButtonSegment
import M3e.Component.Calendar
import M3e.Component.Card
import M3e.Component.Checkbox
import M3e.Component.Chip
import M3e.Component.ChipSet
import M3e.Component.CircularProgressIndicator
import M3e.Component.Collapsible
import M3e.Component.ContentPane
import M3e.Component.DateInput
import M3e.Component.Datepicker
import M3e.Component.DatepickerToggle
import M3e.Component.Dialog
import M3e.Component.DialogAction
import M3e.Component.DialogTrigger
import M3e.Component.Divider
import M3e.Component.DrawerContainer
import M3e.Component.DrawerToggle
import M3e.Component.Elevation
import M3e.Component.ExpandableListItem
import M3e.Component.ExpansionHeader
import M3e.Component.ExpansionPanel
import M3e.Component.Fab
import M3e.Component.FabMenu
import M3e.Component.FabMenuItem
import M3e.Component.FabMenuTrigger
import M3e.Component.FilterChip
import M3e.Component.FilterChipSet
import M3e.Component.FloatingPanel
import M3e.Component.FocusRing
import M3e.Component.FocusTrap
import M3e.Component.FormField
import M3e.Component.Heading
import M3e.Component.Icon
import M3e.Component.IconButton
import M3e.Component.InputChip
import M3e.Component.InputChipSet
import M3e.Component.LinearProgressIndicator
import M3e.Component.List
import M3e.Component.ListAction
import M3e.Component.ListItem
import M3e.Component.ListItemButton
import M3e.Component.ListOption
import M3e.Component.LoadingIndicator
import M3e.Component.Menu
import M3e.Component.MenuItem
import M3e.Component.MenuItemCheckbox
import M3e.Component.MenuItemGroup
import M3e.Component.MenuItemRadio
import M3e.Component.MenuTrigger
import M3e.Component.MonthView
import M3e.Component.MultiYearView
import M3e.Component.NavBar
import M3e.Component.NavItem
import M3e.Component.NavMenu
import M3e.Component.NavMenuItem
import M3e.Component.NavMenuItemGroup
import M3e.Component.NavRail
import M3e.Component.NavRailToggle
import M3e.Component.Optgroup
import M3e.Component.Option
import M3e.Component.OptionPanel
import M3e.Component.Paginator
import M3e.Component.PseudoCheckbox
import M3e.Component.PseudoRadio
import M3e.Component.Radio
import M3e.Component.RadioGroup
import M3e.Component.RichTooltip
import M3e.Component.RichTooltipAction
import M3e.Component.Ripple
import M3e.Component.ScrollContainer
import M3e.Component.SearchBar
import M3e.Component.SearchView
import M3e.Component.SegmentedButton
import M3e.Component.Select
import M3e.Component.SelectionIndicator
import M3e.Component.SelectionList
import M3e.Component.Shape
import M3e.Component.Skeleton
import M3e.Component.Slide
import M3e.Component.SlideGroup
import M3e.Component.Slider
import M3e.Component.SliderThumb
import M3e.Component.Snackbar
import M3e.Component.SplitButton
import M3e.Component.SplitPane
import M3e.Component.StateLayer
import M3e.Component.Step
import M3e.Component.StepPanel
import M3e.Component.Stepper
import M3e.Component.StepperNext
import M3e.Component.StepperPrevious
import M3e.Component.StepperReset
import M3e.Component.SuggestionChip
import M3e.Component.Switch
import M3e.Component.Tab
import M3e.Component.TabPanel
import M3e.Component.Tabs
import M3e.Component.TextHighlight
import M3e.Component.TextOverflow
import M3e.Component.TextareaAutosize
import M3e.Component.Theme
import M3e.Component.ThemeIcon
import M3e.Component.Timepicker
import M3e.Component.TimepickerDial
import M3e.Component.TimepickerInput
import M3e.Component.TimepickerInputPeriodToggle
import M3e.Component.TimepickerToggle
import M3e.Component.Toc
import M3e.Component.TocItem
import M3e.Component.Toolbar
import M3e.Component.Tooltip
import M3e.Component.Tree
import M3e.Component.TreeItem
import M3e.Component.YearView


{-| The loose `m3e-accordion` producer — open attribute/child rows, no required record. See `M3e.Component.Accordion.component` for the required-content form.
-}
accordion :
    List (Attr M3e.Component.Accordion.Attrs msg)
    -> List (Element M3e.Component.Accordion.Content (M3e.Component.Accordion.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Accordion.Is s) admittedBy msg
accordion attrs children =
    Ir.fromNode (Ir.node "m3e-accordion" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.ActionList.component`.
-}
actionList :
    List (Attr M3e.Component.ActionList.Attrs msg)
    -> List (Element M3e.Component.ActionList.Content (M3e.Component.ActionList.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ActionList.Is s) admittedBy msg
actionList =
    M3e.Component.ActionList.component


{-| See `M3e.Component.AppBar.component`.
-}
appBar :
    List (Attr M3e.Component.AppBar.Attrs msg)
    -> List (Element childAccepts (M3e.Component.AppBar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.AppBar.Is s) admittedBy msg
appBar =
    M3e.Component.AppBar.component


{-| The loose `m3e-assist-chip` producer — open attribute/child rows, no required record. See `M3e.Component.AssistChip.component` for the required-content form.
-}
assistChip :
    List (Attr M3e.Component.AssistChip.Attrs msg)
    -> List (Element M3e.Component.AssistChip.Content (M3e.Component.AssistChip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.AssistChip.Is s) admittedBy msg
assistChip attrs children =
    Ir.fromNode (Ir.node "m3e-assist-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.Autocomplete.component`.
-}
autocomplete :
    List (Attr M3e.Component.Autocomplete.Attrs msg)
    -> List (Element M3e.Component.Autocomplete.Content (M3e.Component.Autocomplete.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Autocomplete.Is s) admittedBy msg
autocomplete =
    M3e.Component.Autocomplete.component


{-| See `M3e.Component.Avatar.component`.
-}
avatar :
    List (Attr M3e.Component.Avatar.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Avatar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Avatar.Is s) admittedBy msg
avatar =
    M3e.Component.Avatar.component


{-| See `M3e.Component.Badge.component`.
-}
badge :
    List (Attr M3e.Component.Badge.Attrs msg)
    -> List (Element M3e.Component.Badge.Content (M3e.Component.Badge.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Badge.Is s) admittedBy msg
badge =
    M3e.Component.Badge.component


{-| See `M3e.Component.BottomSheet.component`.
-}
bottomSheet :
    List (Attr M3e.Component.BottomSheet.Attrs msg)
    -> List (Element childAccepts (M3e.Component.BottomSheet.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.BottomSheet.Is s) admittedBy msg
bottomSheet =
    M3e.Component.BottomSheet.component


{-| See `M3e.Component.BottomSheetAction.component`.
-}
bottomSheetAction :
    List (Attr M3e.Component.BottomSheetAction.Attrs msg)
    -> List (Element M3e.Component.BottomSheetAction.Content (M3e.Component.BottomSheetAction.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.BottomSheetAction.Is s) admittedBy msg
bottomSheetAction =
    M3e.Component.BottomSheetAction.component


{-| See `M3e.Component.BottomSheetTrigger.component`.
-}
bottomSheetTrigger :
    List (Attr M3e.Component.BottomSheetTrigger.Attrs msg)
    -> List (Element M3e.Component.BottomSheetTrigger.Content (M3e.Component.BottomSheetTrigger.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.BottomSheetTrigger.Is s) admittedBy msg
bottomSheetTrigger =
    M3e.Component.BottomSheetTrigger.component


{-| The loose `m3e-breadcrumb` producer — open attribute/child rows, no required record. See `M3e.Component.Breadcrumb.component` for the required-content form.
-}
breadcrumb :
    List (Attr M3e.Component.Breadcrumb.Attrs msg)
    -> List (Element M3e.Component.Breadcrumb.Content (M3e.Component.Breadcrumb.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Breadcrumb.Is s) admittedBy msg
breadcrumb attrs children =
    Ir.fromNode (Ir.node "m3e-breadcrumb" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.BreadcrumbItem.component`.
-}
breadcrumbItem :
    List (Attr M3e.Component.BreadcrumbItem.Attrs msg)
    -> List (Element M3e.Component.BreadcrumbItem.Content (M3e.Component.BreadcrumbItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.BreadcrumbItem.Is s) admittedBy msg
breadcrumbItem =
    M3e.Component.BreadcrumbItem.component


{-| See `M3e.Component.BreadcrumbItemButton.component`.
-}
breadcrumbItemButton :
    List (Attr M3e.Component.BreadcrumbItemButton.Attrs msg)
    -> List (Element M3e.Component.BreadcrumbItemButton.Content (M3e.Component.BreadcrumbItemButton.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.BreadcrumbItemButton.Is s) admittedBy msg
breadcrumbItemButton =
    M3e.Component.BreadcrumbItemButton.component


{-| The loose `m3e-button` producer — open attribute/child rows, no required record. See `M3e.Component.Button.component` for the required-content form.
-}
button :
    List (Attr M3e.Component.Button.Attrs msg)
    -> List (Element M3e.Component.Button.Content (M3e.Component.Button.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Button.Is s) admittedBy msg
button attrs children =
    Ir.fromNode (Ir.node "m3e-button" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.ButtonGroup.component`.
-}
buttonGroup :
    List (Attr M3e.Component.ButtonGroup.Attrs msg)
    -> List (Element M3e.Component.ButtonGroup.Content (M3e.Component.ButtonGroup.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ButtonGroup.Is s) admittedBy msg
buttonGroup =
    M3e.Component.ButtonGroup.component


{-| See `M3e.Component.ButtonSegment.component`.
-}
buttonSegment :
    List (Attr M3e.Component.ButtonSegment.Attrs msg)
    -> List (Element M3e.Component.ButtonSegment.Content (M3e.Component.ButtonSegment.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ButtonSegment.Is s) admittedBy msg
buttonSegment =
    M3e.Component.ButtonSegment.component


{-| See `M3e.Component.Calendar.component`.
-}
calendar :
    List (Attr M3e.Component.Calendar.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Calendar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Calendar.Is s) admittedBy msg
calendar =
    M3e.Component.Calendar.component


{-| See `M3e.Component.Card.component`.
-}
card :
    List (Attr M3e.Component.Card.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Card.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Card.Is s) admittedBy msg
card =
    M3e.Component.Card.component


{-| See `M3e.Component.Checkbox.component`.
-}
checkbox :
    List (Attr M3e.Component.Checkbox.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Checkbox.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Checkbox.Is s) admittedBy msg
checkbox =
    M3e.Component.Checkbox.component


{-| The loose `m3e-chip` producer — open attribute/child rows, no required record. See `M3e.Component.Chip.component` for the required-content form.
-}
chip :
    List (Attr M3e.Component.Chip.Attrs msg)
    -> List (Element M3e.Component.Chip.Content (M3e.Component.Chip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Chip.Is s) admittedBy msg
chip attrs children =
    Ir.fromNode (Ir.node "m3e-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.ChipSet.component`.
-}
chipSet :
    List (Attr M3e.Component.ChipSet.Attrs msg)
    -> List (Element M3e.Component.ChipSet.Content (M3e.Component.ChipSet.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ChipSet.Is s) admittedBy msg
chipSet =
    M3e.Component.ChipSet.component


{-| See `M3e.Component.CircularProgressIndicator.component`.
-}
circularProgressIndicator :
    List (Attr M3e.Component.CircularProgressIndicator.Attrs msg)
    -> List (Element childAccepts (M3e.Component.CircularProgressIndicator.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.CircularProgressIndicator.Is s) admittedBy msg
circularProgressIndicator =
    M3e.Component.CircularProgressIndicator.component


{-| See `M3e.Component.Collapsible.component`.
-}
collapsible :
    List (Attr M3e.Component.Collapsible.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Collapsible.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Collapsible.Is s) admittedBy msg
collapsible =
    M3e.Component.Collapsible.component


{-| See `M3e.Component.ContentPane.component`.
-}
contentPane :
    List (Attr M3e.Component.ContentPane.Attrs msg)
    -> List (Element childAccepts (M3e.Component.ContentPane.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ContentPane.Is s) admittedBy msg
contentPane =
    M3e.Component.ContentPane.component


{-| See `M3e.Component.DateInput.component`.
-}
dateInput :
    List (Attr M3e.Component.DateInput.Attrs msg)
    -> List (Element childAccepts (M3e.Component.DateInput.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.DateInput.Is s) admittedBy msg
dateInput =
    M3e.Component.DateInput.component


{-| See `M3e.Component.Datepicker.component`.
-}
datepicker :
    List (Attr M3e.Component.Datepicker.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Datepicker.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Datepicker.Is s) admittedBy msg
datepicker =
    M3e.Component.Datepicker.component


{-| See `M3e.Component.DatepickerToggle.component`.
-}
datepickerToggle :
    List (Attr M3e.Component.DatepickerToggle.Attrs msg)
    -> List (Element childAccepts (M3e.Component.DatepickerToggle.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.DatepickerToggle.Is s) admittedBy msg
datepickerToggle =
    M3e.Component.DatepickerToggle.component


{-| See `M3e.Component.Dialog.component`.
-}
dialog :
    List (Attr M3e.Component.Dialog.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Dialog.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Dialog.Is s) admittedBy msg
dialog =
    M3e.Component.Dialog.component


{-| See `M3e.Component.DialogAction.component`.
-}
dialogAction :
    List (Attr M3e.Component.DialogAction.Attrs msg)
    -> List (Element childAccepts (M3e.Component.DialogAction.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.DialogAction.Is s) admittedBy msg
dialogAction =
    M3e.Component.DialogAction.component


{-| See `M3e.Component.DialogTrigger.component`.
-}
dialogTrigger :
    List (Attr M3e.Component.DialogTrigger.Attrs msg)
    -> List (Element childAccepts (M3e.Component.DialogTrigger.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.DialogTrigger.Is s) admittedBy msg
dialogTrigger =
    M3e.Component.DialogTrigger.component


{-| See `M3e.Component.Divider.component`.
-}
divider :
    List (Attr M3e.Component.Divider.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Divider.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Divider.Is s) admittedBy msg
divider =
    M3e.Component.Divider.component


{-| See `M3e.Component.DrawerContainer.component`.
-}
drawerContainer :
    List (Attr M3e.Component.DrawerContainer.Attrs msg)
    -> List (Element childAccepts (M3e.Component.DrawerContainer.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.DrawerContainer.Is s) admittedBy msg
drawerContainer =
    M3e.Component.DrawerContainer.component


{-| See `M3e.Component.DrawerToggle.component`.
-}
drawerToggle :
    List (Attr M3e.Component.DrawerToggle.Attrs msg)
    -> List (Element childAccepts (M3e.Component.DrawerToggle.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.DrawerToggle.Is s) admittedBy msg
drawerToggle =
    M3e.Component.DrawerToggle.component


{-| See `M3e.Component.Elevation.component`.
-}
elevation :
    List (Attr M3e.Component.Elevation.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Elevation.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Elevation.Is s) admittedBy msg
elevation =
    M3e.Component.Elevation.component


{-| See `M3e.Component.ExpandableListItem.component`.
-}
expandableListItem :
    List (Attr M3e.Component.ExpandableListItem.Attrs msg)
    -> List (Element M3e.Component.ExpandableListItem.Content (M3e.Component.ExpandableListItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ExpandableListItem.Is s) admittedBy msg
expandableListItem =
    M3e.Component.ExpandableListItem.component


{-| See `M3e.Component.ExpansionHeader.component`.
-}
expansionHeader :
    List (Attr M3e.Component.ExpansionHeader.Attrs msg)
    -> List (Element M3e.Component.ExpansionHeader.Content (M3e.Component.ExpansionHeader.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ExpansionHeader.Is s) admittedBy msg
expansionHeader =
    M3e.Component.ExpansionHeader.component


{-| The loose `m3e-expansion-panel` producer — open attribute/child rows, no required record. See `M3e.Component.ExpansionPanel.component` for the required-content form.
-}
expansionPanel :
    List (Attr M3e.Component.ExpansionPanel.Attrs msg)
    -> List (Element childAccepts (M3e.Component.ExpansionPanel.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ExpansionPanel.Is s) admittedBy msg
expansionPanel attrs children =
    Ir.fromNode (Ir.node "m3e-expansion-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-fab` producer — open attribute/child rows, no required record. See `M3e.Component.Fab.component` for the required-content form.
-}
fab :
    List (Attr M3e.Component.Fab.Attrs msg)
    -> List (Element M3e.Component.Fab.Content (M3e.Component.Fab.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Fab.Is s) admittedBy msg
fab attrs children =
    Ir.fromNode (Ir.node "m3e-fab" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.FabMenu.component`.
-}
fabMenu :
    List (Attr M3e.Component.FabMenu.Attrs msg)
    -> List (Element M3e.Component.FabMenu.Content (M3e.Component.FabMenu.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.FabMenu.Is s) admittedBy msg
fabMenu =
    M3e.Component.FabMenu.component


{-| See `M3e.Component.FabMenuItem.component`.
-}
fabMenuItem :
    List (Attr M3e.Component.FabMenuItem.Attrs msg)
    -> List (Element childAccepts (M3e.Component.FabMenuItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.FabMenuItem.Is s) admittedBy msg
fabMenuItem =
    M3e.Component.FabMenuItem.component


{-| See `M3e.Component.FabMenuTrigger.component`.
-}
fabMenuTrigger :
    List (Attr M3e.Component.FabMenuTrigger.Attrs msg)
    -> List (Element childAccepts (M3e.Component.FabMenuTrigger.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.FabMenuTrigger.Is s) admittedBy msg
fabMenuTrigger =
    M3e.Component.FabMenuTrigger.component


{-| The loose `m3e-filter-chip` producer — open attribute/child rows, no required record. See `M3e.Component.FilterChip.component` for the required-content form.
-}
filterChip :
    List (Attr M3e.Component.FilterChip.Attrs msg)
    -> List (Element M3e.Component.FilterChip.Content (M3e.Component.FilterChip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.FilterChip.Is s) admittedBy msg
filterChip attrs children =
    Ir.fromNode (Ir.node "m3e-filter-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.FilterChipSet.component`.
-}
filterChipSet :
    List (Attr M3e.Component.FilterChipSet.Attrs msg)
    -> List (Element M3e.Component.FilterChipSet.Content (M3e.Component.FilterChipSet.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.FilterChipSet.Is s) admittedBy msg
filterChipSet =
    M3e.Component.FilterChipSet.component


{-| See `M3e.Component.FloatingPanel.component`.
-}
floatingPanel :
    List (Attr M3e.Component.FloatingPanel.Attrs msg)
    -> List (Element childAccepts (M3e.Component.FloatingPanel.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.FloatingPanel.Is s) admittedBy msg
floatingPanel =
    M3e.Component.FloatingPanel.component


{-| See `M3e.Component.FocusRing.component`.
-}
focusRing :
    List (Attr M3e.Component.FocusRing.Attrs msg)
    -> List (Element childAccepts (M3e.Component.FocusRing.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.FocusRing.Is s) admittedBy msg
focusRing =
    M3e.Component.FocusRing.component


{-| See `M3e.Component.FocusTrap.component`.
-}
focusTrap :
    List (Attr M3e.Component.FocusTrap.Attrs msg)
    -> List (Element childAccepts (M3e.Component.FocusTrap.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.FocusTrap.Is s) admittedBy msg
focusTrap =
    M3e.Component.FocusTrap.component


{-| See `M3e.Component.FormField.component`.
-}
formField :
    List (Attr M3e.Component.FormField.Attrs msg)
    -> List (Element childAccepts (M3e.Component.FormField.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.FormField.Is s) admittedBy msg
formField =
    M3e.Component.FormField.component


{-| The loose `m3e-heading` producer — open attribute/child rows, no required record. See `M3e.Component.Heading.component` for the required-content form.
-}
heading :
    List (Attr M3e.Component.Heading.Attrs msg)
    -> List (Element M3e.Component.Heading.Content (M3e.Component.Heading.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Heading.Is s) admittedBy msg
heading attrs children =
    Ir.fromNode (Ir.node "m3e-heading" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.Icon.component`.
-}
icon :
    List (Attr M3e.Component.Icon.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Icon.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Icon.Is s) admittedBy msg
icon =
    M3e.Component.Icon.component


{-| The loose `m3e-icon-button` producer — open attribute/child rows, no required record. See `M3e.Component.IconButton.component` for the required-content form.
-}
iconButton :
    List (Attr M3e.Component.IconButton.Attrs msg)
    -> List (Element M3e.Component.IconButton.Content (M3e.Component.IconButton.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.IconButton.Is s) admittedBy msg
iconButton attrs children =
    Ir.fromNode (Ir.node "m3e-icon-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-input-chip` producer — open attribute/child rows, no required record. See `M3e.Component.InputChip.component` for the required-content form.
-}
inputChip :
    List (Attr M3e.Component.InputChip.Attrs msg)
    -> List (Element M3e.Component.InputChip.Content (M3e.Component.InputChip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.InputChip.Is s) admittedBy msg
inputChip attrs children =
    Ir.fromNode (Ir.node "m3e-input-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.InputChipSet.component`.
-}
inputChipSet :
    List (Attr M3e.Component.InputChipSet.Attrs msg)
    -> List (Element M3e.Component.InputChipSet.Content (M3e.Component.InputChipSet.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.InputChipSet.Is s) admittedBy msg
inputChipSet =
    M3e.Component.InputChipSet.component


{-| See `M3e.Component.LinearProgressIndicator.component`.
-}
linearProgressIndicator :
    List (Attr M3e.Component.LinearProgressIndicator.Attrs msg)
    -> List (Element childAccepts (M3e.Component.LinearProgressIndicator.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.LinearProgressIndicator.Is s) admittedBy msg
linearProgressIndicator =
    M3e.Component.LinearProgressIndicator.component


{-| See `M3e.Component.List.component`.
-}
list :
    List (Attr M3e.Component.List.Attrs msg)
    -> List (Element M3e.Component.List.Content (M3e.Component.List.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.List.Is s) admittedBy msg
list =
    M3e.Component.List.component


{-| See `M3e.Component.ListAction.component`.
-}
listAction :
    List (Attr M3e.Component.ListAction.Attrs msg)
    -> List (Element M3e.Component.ListAction.Content (M3e.Component.ListAction.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ListAction.Is s) admittedBy msg
listAction =
    M3e.Component.ListAction.component


{-| See `M3e.Component.ListItem.component`.
-}
listItem :
    List (Attr M3e.Component.ListItem.Attrs msg)
    -> List (Element M3e.Component.ListItem.Content (M3e.Component.ListItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ListItem.Is s) admittedBy msg
listItem =
    M3e.Component.ListItem.component


{-| See `M3e.Component.ListItemButton.component`.
-}
listItemButton :
    List (Attr M3e.Component.ListItemButton.Attrs msg)
    -> List (Element M3e.Component.ListItemButton.Content (M3e.Component.ListItemButton.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ListItemButton.Is s) admittedBy msg
listItemButton =
    M3e.Component.ListItemButton.component


{-| See `M3e.Component.ListOption.component`.
-}
listOption :
    List (Attr M3e.Component.ListOption.Attrs msg)
    -> List (Element M3e.Component.ListOption.Content (M3e.Component.ListOption.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ListOption.Is s) admittedBy msg
listOption =
    M3e.Component.ListOption.component


{-| See `M3e.Component.LoadingIndicator.component`.
-}
loadingIndicator :
    List (Attr M3e.Component.LoadingIndicator.Attrs msg)
    -> List (Element childAccepts (M3e.Component.LoadingIndicator.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.LoadingIndicator.Is s) admittedBy msg
loadingIndicator =
    M3e.Component.LoadingIndicator.component


{-| See `M3e.Component.Menu.component`.
-}
menu :
    List (Attr M3e.Component.Menu.Attrs msg)
    -> List (Element M3e.Component.Menu.Content (M3e.Component.Menu.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Menu.Is s) admittedBy msg
menu =
    M3e.Component.Menu.component


{-| See `M3e.Component.MenuItem.component`.
-}
menuItem :
    List (Attr M3e.Component.MenuItem.Attrs msg)
    -> List (Element M3e.Component.MenuItem.Content (M3e.Component.MenuItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.MenuItem.Is s) admittedBy msg
menuItem =
    M3e.Component.MenuItem.component


{-| See `M3e.Component.MenuItemCheckbox.component`.
-}
menuItemCheckbox :
    List (Attr M3e.Component.MenuItemCheckbox.Attrs msg)
    -> List (Element M3e.Component.MenuItemCheckbox.Content (M3e.Component.MenuItemCheckbox.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.MenuItemCheckbox.Is s) admittedBy msg
menuItemCheckbox =
    M3e.Component.MenuItemCheckbox.component


{-| See `M3e.Component.MenuItemGroup.component`.
-}
menuItemGroup :
    List (Attr M3e.Component.MenuItemGroup.Attrs msg)
    -> List (Element M3e.Component.MenuItemGroup.Content (M3e.Component.MenuItemGroup.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.MenuItemGroup.Is s) admittedBy msg
menuItemGroup =
    M3e.Component.MenuItemGroup.component


{-| See `M3e.Component.MenuItemRadio.component`.
-}
menuItemRadio :
    List (Attr M3e.Component.MenuItemRadio.Attrs msg)
    -> List (Element M3e.Component.MenuItemRadio.Content (M3e.Component.MenuItemRadio.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.MenuItemRadio.Is s) admittedBy msg
menuItemRadio =
    M3e.Component.MenuItemRadio.component


{-| See `M3e.Component.MenuTrigger.component`.
-}
menuTrigger :
    List (Attr M3e.Component.MenuTrigger.Attrs msg)
    -> List (Element childAccepts (M3e.Component.MenuTrigger.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.MenuTrigger.Is s) admittedBy msg
menuTrigger =
    M3e.Component.MenuTrigger.component


{-| See `M3e.Component.MonthView.component`.
-}
monthView :
    List (Attr M3e.Component.MonthView.Attrs msg)
    -> List (Element childAccepts (M3e.Component.MonthView.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.MonthView.Is s) admittedBy msg
monthView =
    M3e.Component.MonthView.component


{-| See `M3e.Component.MultiYearView.component`.
-}
multiYearView :
    List (Attr M3e.Component.MultiYearView.Attrs msg)
    -> List (Element childAccepts (M3e.Component.MultiYearView.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.MultiYearView.Is s) admittedBy msg
multiYearView =
    M3e.Component.MultiYearView.component


{-| See `M3e.Component.NavBar.component`.
-}
navBar :
    List (Attr M3e.Component.NavBar.Attrs msg)
    -> List (Element M3e.Component.NavBar.Content (M3e.Component.NavBar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.NavBar.Is s) admittedBy msg
navBar =
    M3e.Component.NavBar.component


{-| See `M3e.Component.NavItem.component`.
-}
navItem :
    List (Attr M3e.Component.NavItem.Attrs msg)
    -> List (Element M3e.Component.NavItem.Content (M3e.Component.NavItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.NavItem.Is s) admittedBy msg
navItem =
    M3e.Component.NavItem.component


{-| See `M3e.Component.NavMenu.component`.
-}
navMenu :
    List (Attr M3e.Component.NavMenu.Attrs msg)
    -> List (Element M3e.Component.NavMenu.Content (M3e.Component.NavMenu.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.NavMenu.Is s) admittedBy msg
navMenu =
    M3e.Component.NavMenu.component


{-| The loose `m3e-nav-menu-item` producer — open attribute/child rows, no required record. See `M3e.Component.NavMenuItem.component` for the required-content form.
-}
navMenuItem :
    List (Attr M3e.Component.NavMenuItem.Attrs msg)
    -> List (Element M3e.Component.NavMenuItem.Content (M3e.Component.NavMenuItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.NavMenuItem.Is s) admittedBy msg
navMenuItem attrs children =
    Ir.fromNode (Ir.node "m3e-nav-menu-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.NavMenuItemGroup.component`.
-}
navMenuItemGroup :
    List (Attr M3e.Component.NavMenuItemGroup.Attrs msg)
    -> List (Element M3e.Component.NavMenuItemGroup.Content (M3e.Component.NavMenuItemGroup.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.NavMenuItemGroup.Is s) admittedBy msg
navMenuItemGroup =
    M3e.Component.NavMenuItemGroup.component


{-| See `M3e.Component.NavRail.component`.
-}
navRail :
    List (Attr M3e.Component.NavRail.Attrs msg)
    -> List (Element M3e.Component.NavRail.Content (M3e.Component.NavRail.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.NavRail.Is s) admittedBy msg
navRail =
    M3e.Component.NavRail.component


{-| See `M3e.Component.NavRailToggle.component`.
-}
navRailToggle :
    List (Attr M3e.Component.NavRailToggle.Attrs msg)
    -> List (Element childAccepts (M3e.Component.NavRailToggle.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.NavRailToggle.Is s) admittedBy msg
navRailToggle =
    M3e.Component.NavRailToggle.component


{-| See `M3e.Component.Optgroup.component`.
-}
optgroup :
    List (Attr M3e.Component.Optgroup.Attrs msg)
    -> List (Element M3e.Component.Optgroup.Content (M3e.Component.Optgroup.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Optgroup.Is s) admittedBy msg
optgroup =
    M3e.Component.Optgroup.component


{-| The loose `m3e-option` producer — open attribute/child rows, no required record. See `M3e.Component.Option.component` for the required-content form.
-}
option :
    List (Attr M3e.Component.Option.Attrs msg)
    -> List (Element M3e.Component.Option.Content (M3e.Component.Option.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Option.Is s) admittedBy msg
option attrs children =
    Ir.fromNode (Ir.node "m3e-option" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.OptionPanel.component`.
-}
optionPanel :
    List (Attr M3e.Component.OptionPanel.Attrs msg)
    -> List (Element M3e.Component.OptionPanel.Content (M3e.Component.OptionPanel.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.OptionPanel.Is s) admittedBy msg
optionPanel =
    M3e.Component.OptionPanel.component


{-| See `M3e.Component.Paginator.component`.
-}
paginator :
    List (Attr M3e.Component.Paginator.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Paginator.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Paginator.Is s) admittedBy msg
paginator =
    M3e.Component.Paginator.component


{-| See `M3e.Component.PseudoCheckbox.component`.
-}
pseudoCheckbox :
    List (Attr M3e.Component.PseudoCheckbox.Attrs msg)
    -> List (Element childAccepts (M3e.Component.PseudoCheckbox.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.PseudoCheckbox.Is s) admittedBy msg
pseudoCheckbox =
    M3e.Component.PseudoCheckbox.component


{-| See `M3e.Component.PseudoRadio.component`.
-}
pseudoRadio :
    List (Attr M3e.Component.PseudoRadio.Attrs msg)
    -> List (Element childAccepts (M3e.Component.PseudoRadio.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.PseudoRadio.Is s) admittedBy msg
pseudoRadio =
    M3e.Component.PseudoRadio.component


{-| See `M3e.Component.Radio.component`.
-}
radio :
    List (Attr M3e.Component.Radio.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Radio.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Radio.Is s) admittedBy msg
radio =
    M3e.Component.Radio.component


{-| The loose `m3e-radio-group` producer — open attribute/child rows, no required record. See `M3e.Component.RadioGroup.component` for the required-content form.
-}
radioGroup :
    List (Attr M3e.Component.RadioGroup.Attrs msg)
    -> List (Element childAccepts (M3e.Component.RadioGroup.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.RadioGroup.Is s) admittedBy msg
radioGroup attrs children =
    Ir.fromNode (Ir.node "m3e-radio-group" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-rich-tooltip` producer — open attribute/child rows, no required record. See `M3e.Component.RichTooltip.component` for the required-content form.
-}
richTooltip :
    List (Attr M3e.Component.RichTooltip.Attrs msg)
    -> List (Element M3e.Component.RichTooltip.Content (M3e.Component.RichTooltip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.RichTooltip.Is s) admittedBy msg
richTooltip attrs children =
    Ir.fromNode (Ir.node "m3e-rich-tooltip" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-rich-tooltip-action` producer — open attribute/child rows, no required record. See `M3e.Component.RichTooltipAction.component` for the required-content form.
-}
richTooltipAction :
    List (Attr M3e.Component.RichTooltipAction.Attrs msg)
    -> List (Element M3e.Component.RichTooltipAction.Content (M3e.Component.RichTooltipAction.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.RichTooltipAction.Is s) admittedBy msg
richTooltipAction attrs children =
    Ir.fromNode (Ir.node "m3e-rich-tooltip-action" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.Ripple.component`.
-}
ripple :
    List (Attr M3e.Component.Ripple.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Ripple.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Ripple.Is s) admittedBy msg
ripple =
    M3e.Component.Ripple.component


{-| See `M3e.Component.ScrollContainer.component`.
-}
scrollContainer :
    List (Attr M3e.Component.ScrollContainer.Attrs msg)
    -> List (Element childAccepts (M3e.Component.ScrollContainer.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ScrollContainer.Is s) admittedBy msg
scrollContainer =
    M3e.Component.ScrollContainer.component


{-| The loose `m3e-search-bar` producer — open attribute/child rows, no required record. See `M3e.Component.SearchBar.component` for the required-content form.
-}
searchBar :
    List (Attr M3e.Component.SearchBar.Attrs msg)
    -> List (Element childAccepts (M3e.Component.SearchBar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.SearchBar.Is s) admittedBy msg
searchBar attrs children =
    Ir.fromNode (Ir.node "m3e-search-bar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-search-view` producer — open attribute/child rows, no required record. See `M3e.Component.SearchView.component` for the required-content form.
-}
searchView :
    List (Attr M3e.Component.SearchView.Attrs msg)
    -> List (Element childAccepts (M3e.Component.SearchView.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.SearchView.Is s) admittedBy msg
searchView attrs children =
    Ir.fromNode (Ir.node "m3e-search-view" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-segmented-button` producer — open attribute/child rows, no required record. See `M3e.Component.SegmentedButton.component` for the required-content form.
-}
segmentedButton :
    List (Attr M3e.Component.SegmentedButton.Attrs msg)
    -> List (Element M3e.Component.SegmentedButton.Content (M3e.Component.SegmentedButton.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.SegmentedButton.Is s) admittedBy msg
segmentedButton attrs children =
    Ir.fromNode (Ir.node "m3e-segmented-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-select` producer — open attribute/child rows, no required record. See `M3e.Component.Select.component` for the required-content form.
-}
select :
    List (Attr M3e.Component.Select.Attrs msg)
    -> List (Element M3e.Component.Select.Content (M3e.Component.Select.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Select.Is s) admittedBy msg
select attrs children =
    Ir.fromNode (Ir.node "m3e-select" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.SelectionIndicator.component`.
-}
selectionIndicator :
    List (Attr M3e.Component.SelectionIndicator.Attrs msg)
    -> List (Element childAccepts (M3e.Component.SelectionIndicator.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.SelectionIndicator.Is s) admittedBy msg
selectionIndicator =
    M3e.Component.SelectionIndicator.component


{-| See `M3e.Component.SelectionList.component`.
-}
selectionList :
    List (Attr M3e.Component.SelectionList.Attrs msg)
    -> List (Element M3e.Component.SelectionList.Content (M3e.Component.SelectionList.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.SelectionList.Is s) admittedBy msg
selectionList =
    M3e.Component.SelectionList.component


{-| See `M3e.Component.Shape.component`.
-}
shape :
    List (Attr M3e.Component.Shape.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Shape.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Shape.Is s) admittedBy msg
shape =
    M3e.Component.Shape.component


{-| See `M3e.Component.Skeleton.component`.
-}
skeleton :
    List (Attr M3e.Component.Skeleton.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Skeleton.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Skeleton.Is s) admittedBy msg
skeleton =
    M3e.Component.Skeleton.component


{-| See `M3e.Component.Slide.component`.
-}
slide :
    List (Attr M3e.Component.Slide.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Slide.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Slide.Is s) admittedBy msg
slide =
    M3e.Component.Slide.component


{-| See `M3e.Component.SlideGroup.component`.
-}
slideGroup :
    List (Attr M3e.Component.SlideGroup.Attrs msg)
    -> List (Element childAccepts (M3e.Component.SlideGroup.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.SlideGroup.Is s) admittedBy msg
slideGroup =
    M3e.Component.SlideGroup.component


{-| The loose `m3e-slider` producer — open attribute/child rows, no required record. See `M3e.Component.Slider.component` for the required-content form.
-}
slider :
    List (Attr M3e.Component.Slider.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Slider.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Slider.Is s) admittedBy msg
slider attrs children =
    Ir.fromNode (Ir.node "m3e-slider" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.SliderThumb.component`.
-}
sliderThumb :
    List (Attr M3e.Component.SliderThumb.Attrs msg)
    -> List (Element childAccepts (M3e.Component.SliderThumb.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.SliderThumb.Is s) admittedBy msg
sliderThumb =
    M3e.Component.SliderThumb.component


{-| The loose `m3e-snackbar` producer — open attribute/child rows, no required record. See `M3e.Component.Snackbar.component` for the required-content form.
-}
snackbar :
    List (Attr M3e.Component.Snackbar.Attrs msg)
    -> List (Element M3e.Component.Snackbar.Content (M3e.Component.Snackbar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Snackbar.Is s) admittedBy msg
snackbar attrs children =
    Ir.fromNode (Ir.node "m3e-snackbar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-split-button` producer — open attribute/child rows, no required record. See `M3e.Component.SplitButton.component` for the required-content form.
-}
splitButton :
    List (Attr M3e.Component.SplitButton.Attrs msg)
    -> List (Element childAccepts (M3e.Component.SplitButton.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.SplitButton.Is s) admittedBy msg
splitButton attrs children =
    Ir.fromNode (Ir.node "m3e-split-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-split-pane` producer — open attribute/child rows, no required record. See `M3e.Component.SplitPane.component` for the required-content form.
-}
splitPane :
    List (Attr M3e.Component.SplitPane.Attrs msg)
    -> List (Element childAccepts (M3e.Component.SplitPane.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.SplitPane.Is s) admittedBy msg
splitPane attrs children =
    Ir.fromNode (Ir.node "m3e-split-pane" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.StateLayer.component`.
-}
stateLayer :
    List (Attr M3e.Component.StateLayer.Attrs msg)
    -> List (Element childAccepts (M3e.Component.StateLayer.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.StateLayer.Is s) admittedBy msg
stateLayer =
    M3e.Component.StateLayer.component


{-| The loose `m3e-step` producer — open attribute/child rows, no required record. See `M3e.Component.Step.component` for the required-content form.
-}
step :
    List (Attr M3e.Component.Step.Attrs msg)
    -> List (Element M3e.Component.Step.Content (M3e.Component.Step.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Step.Is s) admittedBy msg
step attrs children =
    Ir.fromNode (Ir.node "m3e-step" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.StepPanel.component`.
-}
stepPanel :
    List (Attr M3e.Component.StepPanel.Attrs msg)
    -> List (Element childAccepts (M3e.Component.StepPanel.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.StepPanel.Is s) admittedBy msg
stepPanel =
    M3e.Component.StepPanel.component


{-| See `M3e.Component.Stepper.component`.
-}
stepper :
    List (Attr M3e.Component.Stepper.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Stepper.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Stepper.Is s) admittedBy msg
stepper =
    M3e.Component.Stepper.component


{-| See `M3e.Component.StepperNext.component`.
-}
stepperNext :
    List (Attr M3e.Component.StepperNext.Attrs msg)
    -> List (Element childAccepts (M3e.Component.StepperNext.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.StepperNext.Is s) admittedBy msg
stepperNext =
    M3e.Component.StepperNext.component


{-| See `M3e.Component.StepperPrevious.component`.
-}
stepperPrevious :
    List (Attr M3e.Component.StepperPrevious.Attrs msg)
    -> List (Element childAccepts (M3e.Component.StepperPrevious.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.StepperPrevious.Is s) admittedBy msg
stepperPrevious =
    M3e.Component.StepperPrevious.component


{-| See `M3e.Component.StepperReset.component`.
-}
stepperReset :
    List (Attr M3e.Component.StepperReset.Attrs msg)
    -> List (Element childAccepts (M3e.Component.StepperReset.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.StepperReset.Is s) admittedBy msg
stepperReset =
    M3e.Component.StepperReset.component


{-| The loose `m3e-suggestion-chip` producer — open attribute/child rows, no required record. See `M3e.Component.SuggestionChip.component` for the required-content form.
-}
suggestionChip :
    List (Attr M3e.Component.SuggestionChip.Attrs msg)
    -> List (Element M3e.Component.SuggestionChip.Content (M3e.Component.SuggestionChip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.SuggestionChip.Is s) admittedBy msg
suggestionChip attrs children =
    Ir.fromNode (Ir.node "m3e-suggestion-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.Switch.component`.
-}
switch :
    List (Attr M3e.Component.Switch.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Switch.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Switch.Is s) admittedBy msg
switch =
    M3e.Component.Switch.component


{-| See `M3e.Component.Tab.component`.
-}
tab :
    List (Attr M3e.Component.Tab.Attrs msg)
    -> List (Element M3e.Component.Tab.Content (M3e.Component.Tab.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Tab.Is s) admittedBy msg
tab =
    M3e.Component.Tab.component


{-| See `M3e.Component.TabPanel.component`.
-}
tabPanel :
    List (Attr M3e.Component.TabPanel.Attrs msg)
    -> List (Element childAccepts (M3e.Component.TabPanel.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.TabPanel.Is s) admittedBy msg
tabPanel =
    M3e.Component.TabPanel.component


{-| See `M3e.Component.Tabs.component`.
-}
tabs :
    List (Attr M3e.Component.Tabs.Attrs msg)
    -> List (Element M3e.Component.Tabs.Content (M3e.Component.Tabs.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Tabs.Is s) admittedBy msg
tabs =
    M3e.Component.Tabs.component


{-| See `M3e.Component.TextHighlight.component`.
-}
textHighlight :
    List (Attr M3e.Component.TextHighlight.Attrs msg)
    -> List (Element childAccepts (M3e.Component.TextHighlight.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.TextHighlight.Is s) admittedBy msg
textHighlight =
    M3e.Component.TextHighlight.component


{-| See `M3e.Component.TextOverflow.component`.
-}
textOverflow :
    List (Attr M3e.Component.TextOverflow.Attrs msg)
    -> List (Element M3e.Component.TextOverflow.Content (M3e.Component.TextOverflow.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.TextOverflow.Is s) admittedBy msg
textOverflow =
    M3e.Component.TextOverflow.component


{-| See `M3e.Component.TextareaAutosize.component`.
-}
textareaAutosize :
    List (Attr M3e.Component.TextareaAutosize.Attrs msg)
    -> List (Element childAccepts (M3e.Component.TextareaAutosize.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.TextareaAutosize.Is s) admittedBy msg
textareaAutosize =
    M3e.Component.TextareaAutosize.component


{-| See `M3e.Component.Theme.component`.
-}
theme :
    List (Attr M3e.Component.Theme.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Theme.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Theme.Is s) admittedBy msg
theme =
    M3e.Component.Theme.component


{-| See `M3e.Component.ThemeIcon.component`.
-}
themeIcon :
    List (Attr M3e.Component.ThemeIcon.Attrs msg)
    -> List (Element childAccepts (M3e.Component.ThemeIcon.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.ThemeIcon.Is s) admittedBy msg
themeIcon =
    M3e.Component.ThemeIcon.component


{-| See `M3e.Component.Timepicker.component`.
-}
timepicker :
    List (Attr M3e.Component.Timepicker.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Timepicker.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Timepicker.Is s) admittedBy msg
timepicker =
    M3e.Component.Timepicker.component


{-| See `M3e.Component.TimepickerDial.component`.
-}
timepickerDial :
    List (Attr M3e.Component.TimepickerDial.Attrs msg)
    -> List (Element childAccepts (M3e.Component.TimepickerDial.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.TimepickerDial.Is s) admittedBy msg
timepickerDial =
    M3e.Component.TimepickerDial.component


{-| See `M3e.Component.TimepickerInput.component`.
-}
timepickerInput :
    List (Attr M3e.Component.TimepickerInput.Attrs msg)
    -> List (Element childAccepts (M3e.Component.TimepickerInput.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.TimepickerInput.Is s) admittedBy msg
timepickerInput =
    M3e.Component.TimepickerInput.component


{-| See `M3e.Component.TimepickerInputPeriodToggle.component`.
-}
timepickerInputPeriodToggle :
    List (Attr M3e.Component.TimepickerInputPeriodToggle.Attrs msg)
    -> List (Element childAccepts (M3e.Component.TimepickerInputPeriodToggle.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.TimepickerInputPeriodToggle.Is s) admittedBy msg
timepickerInputPeriodToggle =
    M3e.Component.TimepickerInputPeriodToggle.component


{-| See `M3e.Component.TimepickerToggle.component`.
-}
timepickerToggle :
    List (Attr M3e.Component.TimepickerToggle.Attrs msg)
    -> List (Element childAccepts (M3e.Component.TimepickerToggle.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.TimepickerToggle.Is s) admittedBy msg
timepickerToggle =
    M3e.Component.TimepickerToggle.component


{-| See `M3e.Component.Toc.component`.
-}
toc :
    List (Attr M3e.Component.Toc.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Toc.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Toc.Is s) admittedBy msg
toc =
    M3e.Component.Toc.component


{-| The loose `m3e-toc-item` producer — open attribute/child rows, no required record. See `M3e.Component.TocItem.component` for the required-content form.
-}
tocItem :
    List (Attr M3e.Component.TocItem.Attrs msg)
    -> List (Element M3e.Component.TocItem.Content (M3e.Component.TocItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.TocItem.Is s) admittedBy msg
tocItem attrs children =
    Ir.fromNode (Ir.node "m3e-toc-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.Toolbar.component`.
-}
toolbar :
    List (Attr M3e.Component.Toolbar.Attrs msg)
    -> List (Element childAccepts (M3e.Component.Toolbar.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Toolbar.Is s) admittedBy msg
toolbar =
    M3e.Component.Toolbar.component


{-| The loose `m3e-tooltip` producer — open attribute/child rows, no required record. See `M3e.Component.Tooltip.component` for the required-content form.
-}
tooltip :
    List (Attr M3e.Component.Tooltip.Attrs msg)
    -> List (Element M3e.Component.Tooltip.Content (M3e.Component.Tooltip.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Tooltip.Is s) admittedBy msg
tooltip attrs children =
    Ir.fromNode (Ir.node "m3e-tooltip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.Tree.component`.
-}
tree :
    List (Attr M3e.Component.Tree.Attrs msg)
    -> List (Element M3e.Component.Tree.Content (M3e.Component.Tree.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.Tree.Is s) admittedBy msg
tree =
    M3e.Component.Tree.component


{-| The loose `m3e-tree-item` producer — open attribute/child rows, no required record. See `M3e.Component.TreeItem.component` for the required-content form.
-}
treeItem :
    List (Attr M3e.Component.TreeItem.Attrs msg)
    -> List (Element M3e.Component.TreeItem.Content (M3e.Component.TreeItem.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.TreeItem.Is s) admittedBy msg
treeItem attrs children =
    Ir.fromNode (Ir.node "m3e-tree-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `M3e.Component.YearView.component`.
-}
yearView :
    List (Attr M3e.Component.YearView.Attrs msg)
    -> List (Element childAccepts (M3e.Component.YearView.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Component.YearView.Is s) admittedBy msg
yearView =
    M3e.Component.YearView.component


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
