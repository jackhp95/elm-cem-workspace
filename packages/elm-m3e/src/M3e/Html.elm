module M3e.Html exposing
    ( accordion, actionList, appBar, assistChip, autocomplete, avatar, badge, bottomSheet, bottomSheetAction, bottomSheetTrigger, breadcrumb, breadcrumbItem, breadcrumbItemButton, button, buttonGroup, buttonSegment, calendar, card, checkbox, chip, chipSet, circularProgressIndicator, collapsible, contentPane, dateInput, datepicker, datepickerToggle, dialog, dialogAction, dialogTrigger, divider, drawerContainer, drawerToggle, elevation, expandableListItem, expansionHeader, expansionPanel, fab, fabMenu, fabMenuItem, fabMenuTrigger, filterChip, filterChipSet, floatingPanel, focusRing, focusTrap, formField, heading, icon, iconButton, inputChip, inputChipSet, linearProgressIndicator, list, listAction, listItem, listItemButton, listOption, loadingIndicator, menu, menuItem, menuItemCheckbox, menuItemGroup, menuItemRadio, menuTrigger, monthView, multiYearView, navBar, navItem, navMenu, navMenuItem, navMenuItemGroup, navRail, navRailToggle, optgroup, option, optionPanel, paginator, pseudoCheckbox, pseudoRadio, radio, radioGroup, richTooltip, richTooltipAction, ripple, scrollContainer, searchBar, searchView, segmentedButton, select, selectionIndicator, selectionList, shape, skeleton, slide, slideGroup, slider, sliderThumb, snackbar, splitButton, splitPane, stateLayer, step, stepPanel, stepper, stepperNext, stepperPrevious, stepperReset, suggestionChip, switch, tab, tabPanel, tabs, textHighlight, textOverflow, textareaAutosize, theme, themeIcon, timepicker, timepickerDial, timepickerInput, timepickerInputPeriodToggle, timepickerToggle, toc, tocItem, toolbar, tooltip, tree, treeItem, yearView
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, keyed, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8
    )

{-| The loose, elm/html-like producer layer: one open-rowed constructor
per element, each owning `Ir.node "<tag>"`. This is the foundation the
`M3e-html` package exposes; every rich `M3e.<Component>` imports
its producer here and re-exposes it under a tightened signature. Depends
only on the IR substrate — no component module is imported.

The substrate types are re-exported here too, so a consumer of the
published package can write type annotations without importing
`HtmlIr.*` directly.

@docs accordion, actionList, appBar, assistChip, autocomplete, avatar, badge, bottomSheet, bottomSheetAction, bottomSheetTrigger, breadcrumb, breadcrumbItem, breadcrumbItemButton, button, buttonGroup, buttonSegment, calendar, card, checkbox, chip, chipSet, circularProgressIndicator, collapsible, contentPane, dateInput, datepicker, datepickerToggle, dialog, dialogAction, dialogTrigger, divider, drawerContainer, drawerToggle, elevation, expandableListItem, expansionHeader, expansionPanel, fab, fabMenu, fabMenuItem, fabMenuTrigger, filterChip, filterChipSet, floatingPanel, focusRing, focusTrap, formField, heading, icon, iconButton, inputChip, inputChipSet, linearProgressIndicator, list, listAction, listItem, listItemButton, listOption, loadingIndicator, menu, menuItem, menuItemCheckbox, menuItemGroup, menuItemRadio, menuTrigger, monthView, multiYearView, navBar, navItem, navMenu, navMenuItem, navMenuItemGroup, navRail, navRailToggle, optgroup, option, optionPanel, paginator, pseudoCheckbox, pseudoRadio, radio, radioGroup, richTooltip, richTooltipAction, ripple, scrollContainer, searchBar, searchView, segmentedButton, select, selectionIndicator, selectionList, shape, skeleton, slide, slideGroup, slider, sliderThumb, snackbar, splitButton, splitPane, stateLayer, step, stepPanel, stepper, stepperNext, stepperPrevious, stepperReset, suggestionChip, switch, tab, tabPanel, tabs, textHighlight, textOverflow, textareaAutosize, theme, themeIcon, timepicker, timepickerDial, timepickerInput, timepickerInputPeriodToggle, timepickerToggle, toc, tocItem, toolbar, tooltip, tree, treeItem, yearView
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, keyed, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Node


{-| The loose `m3e-accordion` producer — open attribute/child rows, elm/html call
shape. `M3e.Accordion` tightens it (closed rows, slot admittance, narrowed values).
-}
accordion :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
accordion attrs children =
    Ir.fromNode (Ir.node "m3e-accordion" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-action-list` producer — open attribute/child rows, elm/html call
shape. `M3e.ActionList` tightens it (closed rows, slot admittance, narrowed values).
-}
actionList :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
actionList attrs children =
    Ir.fromNode (Ir.node "m3e-action-list" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-app-bar` producer — open attribute/child rows, elm/html call
shape. `M3e.AppBar` tightens it (closed rows, slot admittance, narrowed values).
-}
appBar :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
appBar attrs children =
    Ir.fromNode (Ir.node "m3e-app-bar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-assist-chip` producer — open attribute/child rows, elm/html call
shape. `M3e.AssistChip` tightens it (closed rows, slot admittance, narrowed values).
-}
assistChip :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
assistChip attrs children =
    Ir.fromNode (Ir.node "m3e-assist-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-autocomplete` producer — open attribute/child rows, elm/html call
shape. `M3e.Autocomplete` tightens it (closed rows, slot admittance, narrowed values).
-}
autocomplete :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
autocomplete attrs children =
    Ir.fromNode (Ir.node "m3e-autocomplete" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-avatar` producer — open attribute/child rows, elm/html call
shape. `M3e.Avatar` tightens it (closed rows, slot admittance, narrowed values).
-}
avatar :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
avatar attrs children =
    Ir.fromNode (Ir.node "m3e-avatar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-badge` producer — open attribute/child rows, elm/html call
shape. `M3e.Badge` tightens it (closed rows, slot admittance, narrowed values).
-}
badge :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
badge attrs children =
    Ir.fromNode (Ir.node "m3e-badge" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-bottom-sheet` producer — open attribute/child rows, elm/html call
shape. `M3e.BottomSheet` tightens it (closed rows, slot admittance, narrowed values).
-}
bottomSheet :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
bottomSheet attrs children =
    Ir.fromNode (Ir.node "m3e-bottom-sheet" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-bottom-sheet-action` producer — open attribute/child rows, elm/html call
shape. `M3e.BottomSheetAction` tightens it (closed rows, slot admittance, narrowed values).
-}
bottomSheetAction :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
bottomSheetAction attrs children =
    Ir.fromNode (Ir.node "m3e-bottom-sheet-action" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-bottom-sheet-trigger` producer — open attribute/child rows, elm/html call
shape. `M3e.BottomSheetTrigger` tightens it (closed rows, slot admittance, narrowed values).
-}
bottomSheetTrigger :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
bottomSheetTrigger attrs children =
    Ir.fromNode (Ir.node "m3e-bottom-sheet-trigger" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-breadcrumb` producer — open attribute/child rows, elm/html call
shape. `M3e.Breadcrumb` tightens it (closed rows, slot admittance, narrowed values).
-}
breadcrumb :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
breadcrumb attrs children =
    Ir.fromNode (Ir.node "m3e-breadcrumb" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-breadcrumb-item` producer — open attribute/child rows, elm/html call
shape. `M3e.BreadcrumbItem` tightens it (closed rows, slot admittance, narrowed values).
-}
breadcrumbItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
breadcrumbItem attrs children =
    Ir.fromNode (Ir.node "m3e-breadcrumb-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-breadcrumb-item-button` producer — open attribute/child rows, elm/html call
shape. `M3e.BreadcrumbItemButton` tightens it (closed rows, slot admittance, narrowed values).
-}
breadcrumbItemButton :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
breadcrumbItemButton attrs children =
    Ir.fromNode (Ir.node "m3e-breadcrumb-item-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-button` producer — open attribute/child rows, elm/html call
shape. `M3e.Button` tightens it (closed rows, slot admittance, narrowed values).
-}
button :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
button attrs children =
    Ir.fromNode (Ir.node "m3e-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-button-group` producer — open attribute/child rows, elm/html call
shape. `M3e.ButtonGroup` tightens it (closed rows, slot admittance, narrowed values).
-}
buttonGroup :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
buttonGroup attrs children =
    Ir.fromNode (Ir.node "m3e-button-group" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-button-segment` producer — open attribute/child rows, elm/html call
shape. `M3e.ButtonSegment` tightens it (closed rows, slot admittance, narrowed values).
-}
buttonSegment :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
buttonSegment attrs children =
    Ir.fromNode (Ir.node "m3e-button-segment" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-calendar` producer — open attribute/child rows, elm/html call
shape. `M3e.Calendar` tightens it (closed rows, slot admittance, narrowed values).
-}
calendar :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
calendar attrs children =
    Ir.fromNode (Ir.node "m3e-calendar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-card` producer — open attribute/child rows, elm/html call
shape. `M3e.Card` tightens it (closed rows, slot admittance, narrowed values).
-}
card :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
card attrs children =
    Ir.fromNode (Ir.node "m3e-card" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-checkbox` producer — open attribute/child rows, elm/html call
shape. `M3e.Checkbox` tightens it (closed rows, slot admittance, narrowed values).
-}
checkbox :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
checkbox attrs children =
    Ir.fromNode (Ir.node "m3e-checkbox" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-chip` producer — open attribute/child rows, elm/html call
shape. `M3e.Chip` tightens it (closed rows, slot admittance, narrowed values).
-}
chip :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
chip attrs children =
    Ir.fromNode (Ir.node "m3e-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-chip-set` producer — open attribute/child rows, elm/html call
shape. `M3e.ChipSet` tightens it (closed rows, slot admittance, narrowed values).
-}
chipSet :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
chipSet attrs children =
    Ir.fromNode (Ir.node "m3e-chip-set" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-circular-progress-indicator` producer — open attribute/child rows, elm/html call
shape. `M3e.CircularProgressIndicator` tightens it (closed rows, slot admittance, narrowed values).
-}
circularProgressIndicator :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
circularProgressIndicator attrs children =
    Ir.fromNode (Ir.node "m3e-circular-progress-indicator" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-collapsible` producer — open attribute/child rows, elm/html call
shape. `M3e.Collapsible` tightens it (closed rows, slot admittance, narrowed values).
-}
collapsible :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
collapsible attrs children =
    Ir.fromNode (Ir.node "m3e-collapsible" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-content-pane` producer — open attribute/child rows, elm/html call
shape. `M3e.ContentPane` tightens it (closed rows, slot admittance, narrowed values).
-}
contentPane :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
contentPane attrs children =
    Ir.fromNode (Ir.node "m3e-content-pane" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-date-input` producer — open attribute/child rows, elm/html call
shape. `M3e.DateInput` tightens it (closed rows, slot admittance, narrowed values).
-}
dateInput :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
dateInput attrs children =
    Ir.fromNode (Ir.node "m3e-date-input" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-datepicker` producer — open attribute/child rows, elm/html call
shape. `M3e.Datepicker` tightens it (closed rows, slot admittance, narrowed values).
-}
datepicker :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
datepicker attrs children =
    Ir.fromNode (Ir.node "m3e-datepicker" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-datepicker-toggle` producer — open attribute/child rows, elm/html call
shape. `M3e.DatepickerToggle` tightens it (closed rows, slot admittance, narrowed values).
-}
datepickerToggle :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
datepickerToggle attrs children =
    Ir.fromNode (Ir.node "m3e-datepicker-toggle" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-dialog` producer — open attribute/child rows, elm/html call
shape. `M3e.Dialog` tightens it (closed rows, slot admittance, narrowed values).
-}
dialog :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
dialog attrs children =
    Ir.fromNode (Ir.node "m3e-dialog" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-dialog-action` producer — open attribute/child rows, elm/html call
shape. `M3e.DialogAction` tightens it (closed rows, slot admittance, narrowed values).
-}
dialogAction :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
dialogAction attrs children =
    Ir.fromNode (Ir.node "m3e-dialog-action" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-dialog-trigger` producer — open attribute/child rows, elm/html call
shape. `M3e.DialogTrigger` tightens it (closed rows, slot admittance, narrowed values).
-}
dialogTrigger :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
dialogTrigger attrs children =
    Ir.fromNode (Ir.node "m3e-dialog-trigger" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-divider` producer — open attribute/child rows, elm/html call
shape. `M3e.Divider` tightens it (closed rows, slot admittance, narrowed values).
-}
divider :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
divider attrs children =
    Ir.fromNode (Ir.node "m3e-divider" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-drawer-container` producer — open attribute/child rows, elm/html call
shape. `M3e.DrawerContainer` tightens it (closed rows, slot admittance, narrowed values).
-}
drawerContainer :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
drawerContainer attrs children =
    Ir.fromNode (Ir.node "m3e-drawer-container" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-drawer-toggle` producer — open attribute/child rows, elm/html call
shape. `M3e.DrawerToggle` tightens it (closed rows, slot admittance, narrowed values).
-}
drawerToggle :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
drawerToggle attrs children =
    Ir.fromNode (Ir.node "m3e-drawer-toggle" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-elevation` producer — open attribute/child rows, elm/html call
shape. `M3e.Elevation` tightens it (closed rows, slot admittance, narrowed values).
-}
elevation :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
elevation attrs children =
    Ir.fromNode (Ir.node "m3e-elevation" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-expandable-list-item` producer — open attribute/child rows, elm/html call
shape. `M3e.ExpandableListItem` tightens it (closed rows, slot admittance, narrowed values).
-}
expandableListItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
expandableListItem attrs children =
    Ir.fromNode (Ir.node "m3e-expandable-list-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-expansion-header` producer — open attribute/child rows, elm/html call
shape. `M3e.ExpansionHeader` tightens it (closed rows, slot admittance, narrowed values).
-}
expansionHeader :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
expansionHeader attrs children =
    Ir.fromNode (Ir.node "m3e-expansion-header" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-expansion-panel` producer — open attribute/child rows, elm/html call
shape. `M3e.ExpansionPanel` tightens it (closed rows, slot admittance, narrowed values).
-}
expansionPanel :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
expansionPanel attrs children =
    Ir.fromNode (Ir.node "m3e-expansion-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-fab` producer — open attribute/child rows, elm/html call
shape. `M3e.Fab` tightens it (closed rows, slot admittance, narrowed values).
-}
fab :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
fab attrs children =
    Ir.fromNode (Ir.node "m3e-fab" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-fab-menu` producer — open attribute/child rows, elm/html call
shape. `M3e.FabMenu` tightens it (closed rows, slot admittance, narrowed values).
-}
fabMenu :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
fabMenu attrs children =
    Ir.fromNode (Ir.node "m3e-fab-menu" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-fab-menu-item` producer — open attribute/child rows, elm/html call
shape. `M3e.FabMenuItem` tightens it (closed rows, slot admittance, narrowed values).
-}
fabMenuItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
fabMenuItem attrs children =
    Ir.fromNode (Ir.node "m3e-fab-menu-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-fab-menu-trigger` producer — open attribute/child rows, elm/html call
shape. `M3e.FabMenuTrigger` tightens it (closed rows, slot admittance, narrowed values).
-}
fabMenuTrigger :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
fabMenuTrigger attrs children =
    Ir.fromNode (Ir.node "m3e-fab-menu-trigger" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-filter-chip` producer — open attribute/child rows, elm/html call
shape. `M3e.FilterChip` tightens it (closed rows, slot admittance, narrowed values).
-}
filterChip :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
filterChip attrs children =
    Ir.fromNode (Ir.node "m3e-filter-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-filter-chip-set` producer — open attribute/child rows, elm/html call
shape. `M3e.FilterChipSet` tightens it (closed rows, slot admittance, narrowed values).
-}
filterChipSet :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
filterChipSet attrs children =
    Ir.fromNode (Ir.node "m3e-filter-chip-set" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-floating-panel` producer — open attribute/child rows, elm/html call
shape. `M3e.FloatingPanel` tightens it (closed rows, slot admittance, narrowed values).
-}
floatingPanel :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
floatingPanel attrs children =
    Ir.fromNode (Ir.node "m3e-floating-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-focus-ring` producer — open attribute/child rows, elm/html call
shape. `M3e.FocusRing` tightens it (closed rows, slot admittance, narrowed values).
-}
focusRing :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
focusRing attrs children =
    Ir.fromNode (Ir.node "m3e-focus-ring" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-focus-trap` producer — open attribute/child rows, elm/html call
shape. `M3e.FocusTrap` tightens it (closed rows, slot admittance, narrowed values).
-}
focusTrap :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
focusTrap attrs children =
    Ir.fromNode (Ir.node "m3e-focus-trap" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-form-field` producer — open attribute/child rows, elm/html call
shape. `M3e.FormField` tightens it (closed rows, slot admittance, narrowed values).
-}
formField :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
formField attrs children =
    Ir.fromNode (Ir.node "m3e-form-field" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-heading` producer — open attribute/child rows, elm/html call
shape. `M3e.Heading` tightens it (closed rows, slot admittance, narrowed values).
-}
heading :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
heading attrs children =
    Ir.fromNode (Ir.node "m3e-heading" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-icon` producer — open attribute/child rows, elm/html call
shape. `M3e.Icon` tightens it (closed rows, slot admittance, narrowed values).
-}
icon :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
icon attrs children =
    Ir.fromNode (Ir.node "m3e-icon" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-icon-button` producer — open attribute/child rows, elm/html call
shape. `M3e.IconButton` tightens it (closed rows, slot admittance, narrowed values).
-}
iconButton :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
iconButton attrs children =
    Ir.fromNode (Ir.node "m3e-icon-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-input-chip` producer — open attribute/child rows, elm/html call
shape. `M3e.InputChip` tightens it (closed rows, slot admittance, narrowed values).
-}
inputChip :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
inputChip attrs children =
    Ir.fromNode (Ir.node "m3e-input-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-input-chip-set` producer — open attribute/child rows, elm/html call
shape. `M3e.InputChipSet` tightens it (closed rows, slot admittance, narrowed values).
-}
inputChipSet :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
inputChipSet attrs children =
    Ir.fromNode (Ir.node "m3e-input-chip-set" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-linear-progress-indicator` producer — open attribute/child rows, elm/html call
shape. `M3e.LinearProgressIndicator` tightens it (closed rows, slot admittance, narrowed values).
-}
linearProgressIndicator :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
linearProgressIndicator attrs children =
    Ir.fromNode (Ir.node "m3e-linear-progress-indicator" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-list` producer — open attribute/child rows, elm/html call
shape. `M3e.List` tightens it (closed rows, slot admittance, narrowed values).
-}
list :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
list attrs children =
    Ir.fromNode (Ir.node "m3e-list" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-list-action` producer — open attribute/child rows, elm/html call
shape. `M3e.ListAction` tightens it (closed rows, slot admittance, narrowed values).
-}
listAction :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
listAction attrs children =
    Ir.fromNode (Ir.node "m3e-list-action" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-list-item` producer — open attribute/child rows, elm/html call
shape. `M3e.ListItem` tightens it (closed rows, slot admittance, narrowed values).
-}
listItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
listItem attrs children =
    Ir.fromNode (Ir.node "m3e-list-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-list-item-button` producer — open attribute/child rows, elm/html call
shape. `M3e.ListItemButton` tightens it (closed rows, slot admittance, narrowed values).
-}
listItemButton :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
listItemButton attrs children =
    Ir.fromNode (Ir.node "m3e-list-item-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-list-option` producer — open attribute/child rows, elm/html call
shape. `M3e.ListOption` tightens it (closed rows, slot admittance, narrowed values).
-}
listOption :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
listOption attrs children =
    Ir.fromNode (Ir.node "m3e-list-option" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-loading-indicator` producer — open attribute/child rows, elm/html call
shape. `M3e.LoadingIndicator` tightens it (closed rows, slot admittance, narrowed values).
-}
loadingIndicator :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
loadingIndicator attrs children =
    Ir.fromNode (Ir.node "m3e-loading-indicator" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-menu` producer — open attribute/child rows, elm/html call
shape. `M3e.Menu` tightens it (closed rows, slot admittance, narrowed values).
-}
menu :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
menu attrs children =
    Ir.fromNode (Ir.node "m3e-menu" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-menu-item` producer — open attribute/child rows, elm/html call
shape. `M3e.MenuItem` tightens it (closed rows, slot admittance, narrowed values).
-}
menuItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
menuItem attrs children =
    Ir.fromNode (Ir.node "m3e-menu-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-menu-item-checkbox` producer — open attribute/child rows, elm/html call
shape. `M3e.MenuItemCheckbox` tightens it (closed rows, slot admittance, narrowed values).
-}
menuItemCheckbox :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
menuItemCheckbox attrs children =
    Ir.fromNode (Ir.node "m3e-menu-item-checkbox" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-menu-item-group` producer — open attribute/child rows, elm/html call
shape. `M3e.MenuItemGroup` tightens it (closed rows, slot admittance, narrowed values).
-}
menuItemGroup :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
menuItemGroup attrs children =
    Ir.fromNode (Ir.node "m3e-menu-item-group" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-menu-item-radio` producer — open attribute/child rows, elm/html call
shape. `M3e.MenuItemRadio` tightens it (closed rows, slot admittance, narrowed values).
-}
menuItemRadio :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
menuItemRadio attrs children =
    Ir.fromNode (Ir.node "m3e-menu-item-radio" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-menu-trigger` producer — open attribute/child rows, elm/html call
shape. `M3e.MenuTrigger` tightens it (closed rows, slot admittance, narrowed values).
-}
menuTrigger :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
menuTrigger attrs children =
    Ir.fromNode (Ir.node "m3e-menu-trigger" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-month-view` producer — open attribute/child rows, elm/html call
shape. `M3e.MonthView` tightens it (closed rows, slot admittance, narrowed values).
-}
monthView :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
monthView attrs children =
    Ir.fromNode (Ir.node "m3e-month-view" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-multi-year-view` producer — open attribute/child rows, elm/html call
shape. `M3e.MultiYearView` tightens it (closed rows, slot admittance, narrowed values).
-}
multiYearView :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
multiYearView attrs children =
    Ir.fromNode (Ir.node "m3e-multi-year-view" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-nav-bar` producer — open attribute/child rows, elm/html call
shape. `M3e.NavBar` tightens it (closed rows, slot admittance, narrowed values).
-}
navBar :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
navBar attrs children =
    Ir.fromNode (Ir.node "m3e-nav-bar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-nav-item` producer — open attribute/child rows, elm/html call
shape. `M3e.NavItem` tightens it (closed rows, slot admittance, narrowed values).
-}
navItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
navItem attrs children =
    Ir.fromNode (Ir.node "m3e-nav-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-nav-menu` producer — open attribute/child rows, elm/html call
shape. `M3e.NavMenu` tightens it (closed rows, slot admittance, narrowed values).
-}
navMenu :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
navMenu attrs children =
    Ir.fromNode (Ir.node "m3e-nav-menu" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-nav-menu-item` producer — open attribute/child rows, elm/html call
shape. `M3e.NavMenuItem` tightens it (closed rows, slot admittance, narrowed values).
-}
navMenuItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
navMenuItem attrs children =
    Ir.fromNode (Ir.node "m3e-nav-menu-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-nav-menu-item-group` producer — open attribute/child rows, elm/html call
shape. `M3e.NavMenuItemGroup` tightens it (closed rows, slot admittance, narrowed values).
-}
navMenuItemGroup :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
navMenuItemGroup attrs children =
    Ir.fromNode (Ir.node "m3e-nav-menu-item-group" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-nav-rail` producer — open attribute/child rows, elm/html call
shape. `M3e.NavRail` tightens it (closed rows, slot admittance, narrowed values).
-}
navRail :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
navRail attrs children =
    Ir.fromNode (Ir.node "m3e-nav-rail" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-nav-rail-toggle` producer — open attribute/child rows, elm/html call
shape. `M3e.NavRailToggle` tightens it (closed rows, slot admittance, narrowed values).
-}
navRailToggle :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
navRailToggle attrs children =
    Ir.fromNode (Ir.node "m3e-nav-rail-toggle" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-optgroup` producer — open attribute/child rows, elm/html call
shape. `M3e.Optgroup` tightens it (closed rows, slot admittance, narrowed values).
-}
optgroup :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
optgroup attrs children =
    Ir.fromNode (Ir.node "m3e-optgroup" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-option` producer — open attribute/child rows, elm/html call
shape. `M3e.Option` tightens it (closed rows, slot admittance, narrowed values).
-}
option :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
option attrs children =
    Ir.fromNode (Ir.node "m3e-option" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-option-panel` producer — open attribute/child rows, elm/html call
shape. `M3e.OptionPanel` tightens it (closed rows, slot admittance, narrowed values).
-}
optionPanel :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
optionPanel attrs children =
    Ir.fromNode (Ir.node "m3e-option-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-paginator` producer — open attribute/child rows, elm/html call
shape. `M3e.Paginator` tightens it (closed rows, slot admittance, narrowed values).
-}
paginator :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
paginator attrs children =
    Ir.fromNode (Ir.node "m3e-paginator" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-pseudo-checkbox` producer — open attribute/child rows, elm/html call
shape. `M3e.PseudoCheckbox` tightens it (closed rows, slot admittance, narrowed values).
-}
pseudoCheckbox :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
pseudoCheckbox attrs children =
    Ir.fromNode (Ir.node "m3e-pseudo-checkbox" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-pseudo-radio` producer — open attribute/child rows, elm/html call
shape. `M3e.PseudoRadio` tightens it (closed rows, slot admittance, narrowed values).
-}
pseudoRadio :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
pseudoRadio attrs children =
    Ir.fromNode (Ir.node "m3e-pseudo-radio" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-radio` producer — open attribute/child rows, elm/html call
shape. `M3e.Radio` tightens it (closed rows, slot admittance, narrowed values).
-}
radio :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
radio attrs children =
    Ir.fromNode (Ir.node "m3e-radio" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-radio-group` producer — open attribute/child rows, elm/html call
shape. `M3e.RadioGroup` tightens it (closed rows, slot admittance, narrowed values).
-}
radioGroup :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
radioGroup attrs children =
    Ir.fromNode (Ir.node "m3e-radio-group" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-rich-tooltip` producer — open attribute/child rows, elm/html call
shape. `M3e.RichTooltip` tightens it (closed rows, slot admittance, narrowed values).
-}
richTooltip :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
richTooltip attrs children =
    Ir.fromNode (Ir.node "m3e-rich-tooltip" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-rich-tooltip-action` producer — open attribute/child rows, elm/html call
shape. `M3e.RichTooltipAction` tightens it (closed rows, slot admittance, narrowed values).
-}
richTooltipAction :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
richTooltipAction attrs children =
    Ir.fromNode (Ir.node "m3e-rich-tooltip-action" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-ripple` producer — open attribute/child rows, elm/html call
shape. `M3e.Ripple` tightens it (closed rows, slot admittance, narrowed values).
-}
ripple :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
ripple attrs children =
    Ir.fromNode (Ir.node "m3e-ripple" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-scroll-container` producer — open attribute/child rows, elm/html call
shape. `M3e.ScrollContainer` tightens it (closed rows, slot admittance, narrowed values).
-}
scrollContainer :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
scrollContainer attrs children =
    Ir.fromNode (Ir.node "m3e-scroll-container" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-search-bar` producer — open attribute/child rows, elm/html call
shape. `M3e.SearchBar` tightens it (closed rows, slot admittance, narrowed values).
-}
searchBar :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
searchBar attrs children =
    Ir.fromNode (Ir.node "m3e-search-bar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-search-view` producer — open attribute/child rows, elm/html call
shape. `M3e.SearchView` tightens it (closed rows, slot admittance, narrowed values).
-}
searchView :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
searchView attrs children =
    Ir.fromNode (Ir.node "m3e-search-view" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-segmented-button` producer — open attribute/child rows, elm/html call
shape. `M3e.SegmentedButton` tightens it (closed rows, slot admittance, narrowed values).
-}
segmentedButton :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
segmentedButton attrs children =
    Ir.fromNode (Ir.node "m3e-segmented-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-select` producer — open attribute/child rows, elm/html call
shape. `M3e.Select` tightens it (closed rows, slot admittance, narrowed values).
-}
select :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
select attrs children =
    Ir.fromNode (Ir.node "m3e-select" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-selection-indicator` producer — open attribute/child rows, elm/html call
shape. `M3e.SelectionIndicator` tightens it (closed rows, slot admittance, narrowed values).
-}
selectionIndicator :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
selectionIndicator attrs children =
    Ir.fromNode (Ir.node "m3e-selection-indicator" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-selection-list` producer — open attribute/child rows, elm/html call
shape. `M3e.SelectionList` tightens it (closed rows, slot admittance, narrowed values).
-}
selectionList :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
selectionList attrs children =
    Ir.fromNode (Ir.node "m3e-selection-list" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-shape` producer — open attribute/child rows, elm/html call
shape. `M3e.Shape` tightens it (closed rows, slot admittance, narrowed values).
-}
shape :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
shape attrs children =
    Ir.fromNode (Ir.node "m3e-shape" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-skeleton` producer — open attribute/child rows, elm/html call
shape. `M3e.Skeleton` tightens it (closed rows, slot admittance, narrowed values).
-}
skeleton :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
skeleton attrs children =
    Ir.fromNode (Ir.node "m3e-skeleton" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-slide` producer — open attribute/child rows, elm/html call
shape. `M3e.Slide` tightens it (closed rows, slot admittance, narrowed values).
-}
slide :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
slide attrs children =
    Ir.fromNode (Ir.node "m3e-slide" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-slide-group` producer — open attribute/child rows, elm/html call
shape. `M3e.SlideGroup` tightens it (closed rows, slot admittance, narrowed values).
-}
slideGroup :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
slideGroup attrs children =
    Ir.fromNode (Ir.node "m3e-slide-group" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-slider` producer — open attribute/child rows, elm/html call
shape. `M3e.Slider` tightens it (closed rows, slot admittance, narrowed values).
-}
slider :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
slider attrs children =
    Ir.fromNode (Ir.node "m3e-slider" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-slider-thumb` producer — open attribute/child rows, elm/html call
shape. `M3e.SliderThumb` tightens it (closed rows, slot admittance, narrowed values).
-}
sliderThumb :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
sliderThumb attrs children =
    Ir.fromNode (Ir.node "m3e-slider-thumb" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-snackbar` producer — open attribute/child rows, elm/html call
shape. `M3e.Snackbar` tightens it (closed rows, slot admittance, narrowed values).
-}
snackbar :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
snackbar attrs children =
    Ir.fromNode (Ir.node "m3e-snackbar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-split-button` producer — open attribute/child rows, elm/html call
shape. `M3e.SplitButton` tightens it (closed rows, slot admittance, narrowed values).
-}
splitButton :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
splitButton attrs children =
    Ir.fromNode (Ir.node "m3e-split-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-split-pane` producer — open attribute/child rows, elm/html call
shape. `M3e.SplitPane` tightens it (closed rows, slot admittance, narrowed values).
-}
splitPane :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
splitPane attrs children =
    Ir.fromNode (Ir.node "m3e-split-pane" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-state-layer` producer — open attribute/child rows, elm/html call
shape. `M3e.StateLayer` tightens it (closed rows, slot admittance, narrowed values).
-}
stateLayer :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
stateLayer attrs children =
    Ir.fromNode (Ir.node "m3e-state-layer" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-step` producer — open attribute/child rows, elm/html call
shape. `M3e.Step` tightens it (closed rows, slot admittance, narrowed values).
-}
step :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
step attrs children =
    Ir.fromNode (Ir.node "m3e-step" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-step-panel` producer — open attribute/child rows, elm/html call
shape. `M3e.StepPanel` tightens it (closed rows, slot admittance, narrowed values).
-}
stepPanel :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
stepPanel attrs children =
    Ir.fromNode (Ir.node "m3e-step-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-stepper` producer — open attribute/child rows, elm/html call
shape. `M3e.Stepper` tightens it (closed rows, slot admittance, narrowed values).
-}
stepper :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
stepper attrs children =
    Ir.fromNode (Ir.node "m3e-stepper" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-stepper-next` producer — open attribute/child rows, elm/html call
shape. `M3e.StepperNext` tightens it (closed rows, slot admittance, narrowed values).
-}
stepperNext :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
stepperNext attrs children =
    Ir.fromNode (Ir.node "m3e-stepper-next" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-stepper-previous` producer — open attribute/child rows, elm/html call
shape. `M3e.StepperPrevious` tightens it (closed rows, slot admittance, narrowed values).
-}
stepperPrevious :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
stepperPrevious attrs children =
    Ir.fromNode (Ir.node "m3e-stepper-previous" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-stepper-reset` producer — open attribute/child rows, elm/html call
shape. `M3e.StepperReset` tightens it (closed rows, slot admittance, narrowed values).
-}
stepperReset :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
stepperReset attrs children =
    Ir.fromNode (Ir.node "m3e-stepper-reset" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-suggestion-chip` producer — open attribute/child rows, elm/html call
shape. `M3e.SuggestionChip` tightens it (closed rows, slot admittance, narrowed values).
-}
suggestionChip :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
suggestionChip attrs children =
    Ir.fromNode (Ir.node "m3e-suggestion-chip" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-switch` producer — open attribute/child rows, elm/html call
shape. `M3e.Switch` tightens it (closed rows, slot admittance, narrowed values).
-}
switch :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
switch attrs children =
    Ir.fromNode (Ir.node "m3e-switch" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-tab` producer — open attribute/child rows, elm/html call
shape. `M3e.Tab` tightens it (closed rows, slot admittance, narrowed values).
-}
tab :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
tab attrs children =
    Ir.fromNode (Ir.node "m3e-tab" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-tab-panel` producer — open attribute/child rows, elm/html call
shape. `M3e.TabPanel` tightens it (closed rows, slot admittance, narrowed values).
-}
tabPanel :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
tabPanel attrs children =
    Ir.fromNode (Ir.node "m3e-tab-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-tabs` producer — open attribute/child rows, elm/html call
shape. `M3e.Tabs` tightens it (closed rows, slot admittance, narrowed values).
-}
tabs :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
tabs attrs children =
    Ir.fromNode (Ir.node "m3e-tabs" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-text-highlight` producer — open attribute/child rows, elm/html call
shape. `M3e.TextHighlight` tightens it (closed rows, slot admittance, narrowed values).
-}
textHighlight :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
textHighlight attrs children =
    Ir.fromNode (Ir.node "m3e-text-highlight" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-text-overflow` producer — open attribute/child rows, elm/html call
shape. `M3e.TextOverflow` tightens it (closed rows, slot admittance, narrowed values).
-}
textOverflow :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
textOverflow attrs children =
    Ir.fromNode (Ir.node "m3e-text-overflow" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-textarea-autosize` producer — open attribute/child rows, elm/html call
shape. `M3e.TextareaAutosize` tightens it (closed rows, slot admittance, narrowed values).
-}
textareaAutosize :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
textareaAutosize attrs children =
    Ir.fromNode (Ir.node "m3e-textarea-autosize" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-theme` producer — open attribute/child rows, elm/html call
shape. `M3e.Theme` tightens it (closed rows, slot admittance, narrowed values).
-}
theme :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
theme attrs children =
    Ir.fromNode (Ir.node "m3e-theme" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-theme-icon` producer — open attribute/child rows, elm/html call
shape. `M3e.ThemeIcon` tightens it (closed rows, slot admittance, narrowed values).
-}
themeIcon :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
themeIcon attrs children =
    Ir.fromNode (Ir.node "m3e-theme-icon" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-timepicker` producer — open attribute/child rows, elm/html call
shape. `M3e.Timepicker` tightens it (closed rows, slot admittance, narrowed values).
-}
timepicker :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
timepicker attrs children =
    Ir.fromNode (Ir.node "m3e-timepicker" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-timepicker-dial` producer — open attribute/child rows, elm/html call
shape. `M3e.TimepickerDial` tightens it (closed rows, slot admittance, narrowed values).
-}
timepickerDial :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
timepickerDial attrs children =
    Ir.fromNode (Ir.node "m3e-timepicker-dial" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-timepicker-input` producer — open attribute/child rows, elm/html call
shape. `M3e.TimepickerInput` tightens it (closed rows, slot admittance, narrowed values).
-}
timepickerInput :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
timepickerInput attrs children =
    Ir.fromNode (Ir.node "m3e-timepicker-input" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-timepicker-input-period-toggle` producer — open attribute/child rows, elm/html call
shape. `M3e.TimepickerInputPeriodToggle` tightens it (closed rows, slot admittance, narrowed values).
-}
timepickerInputPeriodToggle :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
timepickerInputPeriodToggle attrs children =
    Ir.fromNode (Ir.node "m3e-timepicker-input-period-toggle" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-timepicker-toggle` producer — open attribute/child rows, elm/html call
shape. `M3e.TimepickerToggle` tightens it (closed rows, slot admittance, narrowed values).
-}
timepickerToggle :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
timepickerToggle attrs children =
    Ir.fromNode (Ir.node "m3e-timepicker-toggle" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-toc` producer — open attribute/child rows, elm/html call
shape. `M3e.Toc` tightens it (closed rows, slot admittance, narrowed values).
-}
toc :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
toc attrs children =
    Ir.fromNode (Ir.node "m3e-toc" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-toc-item` producer — open attribute/child rows, elm/html call
shape. `M3e.TocItem` tightens it (closed rows, slot admittance, narrowed values).
-}
tocItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
tocItem attrs children =
    Ir.fromNode (Ir.node "m3e-toc-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-toolbar` producer — open attribute/child rows, elm/html call
shape. `M3e.Toolbar` tightens it (closed rows, slot admittance, narrowed values).
-}
toolbar :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
toolbar attrs children =
    Ir.fromNode (Ir.node "m3e-toolbar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-tooltip` producer — open attribute/child rows, elm/html call
shape. `M3e.Tooltip` tightens it (closed rows, slot admittance, narrowed values).
-}
tooltip :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
tooltip attrs children =
    Ir.fromNode (Ir.node "m3e-tooltip" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-tree` producer — open attribute/child rows, elm/html call
shape. `M3e.Tree` tightens it (closed rows, slot admittance, narrowed values).
-}
tree :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
tree attrs children =
    Ir.fromNode (Ir.node "m3e-tree" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-tree-item` producer — open attribute/child rows, elm/html call
shape. `M3e.TreeItem` tightens it (closed rows, slot admittance, narrowed values).
-}
treeItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
treeItem attrs children =
    Ir.fromNode (Ir.node "m3e-tree-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `m3e-year-view` producer — open attribute/child rows, elm/html call
shape. `M3e.YearView` tightens it (closed rows, slot admittance, narrowed values).
-}
yearView :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
yearView attrs children =
    Ir.fromNode (Ir.node "m3e-year-view" attrs (List.map HtmlIr.Element.toNode children))


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


{-| A keyed node — like `node` but children carry diff keys for VirtualDom's keyed-node diffing. Lists that reorder/insert/remove keep their children's state and animation. Each child is a `(String, Node msg)` pair.
-}
keyed : String -> List (Attr attrs msg) -> List ( String, Node msg ) -> Node msg
keyed tagName attrs children =
    HtmlIr.Node.keyedNode tagName attrs children


{-| A lazily-rendered subtree — Elm's `VirtualDom.lazy` memoizes rendered output by reference-equality of the function and argument. **Stable top-level function required** — an inline lambda allocates a fresh closure each render and silently never memoizes. The body returns `Html.Html msg`, not [`Element`](#Element); see type signature.
-}
lazy : (a -> Html.Html msg) -> a -> Node msg
lazy func arg =
    HtmlIr.Node.lazy func arg


{-| 2-argument variant of [`lazy`](#lazy).
-}
lazy2 : (a -> b -> Html.Html msg) -> a -> b -> Node msg
lazy2 func arg1 arg2 =
    HtmlIr.Node.lazy2 func arg1 arg2


{-| 3-argument variant of [`lazy`](#lazy).
-}
lazy3 : (a -> b -> c -> Html.Html msg) -> a -> b -> c -> Node msg
lazy3 func arg1 arg2 arg3 =
    HtmlIr.Node.lazy3 func arg1 arg2 arg3


{-| 4-argument variant of [`lazy`](#lazy).
-}
lazy4 : (a -> b -> c -> d -> Html.Html msg) -> a -> b -> c -> d -> Node msg
lazy4 func arg1 arg2 arg3 arg4 =
    HtmlIr.Node.lazy4 func arg1 arg2 arg3 arg4


{-| 5-argument variant of [`lazy`](#lazy).
-}
lazy5 : (a -> b -> c -> d -> e -> Html.Html msg) -> a -> b -> c -> d -> e -> Node msg
lazy5 func arg1 arg2 arg3 arg4 arg5 =
    HtmlIr.Node.lazy5 func arg1 arg2 arg3 arg4 arg5


{-| 6-argument variant of [`lazy`](#lazy). Note type params skip `f` to match the underlying `VirtualDom.lazy6` convention.
-}
lazy6 : (a -> b -> c -> d -> e -> g -> Html.Html msg) -> a -> b -> c -> d -> e -> g -> Node msg
lazy6 func arg1 arg2 arg3 arg4 arg5 arg6 =
    HtmlIr.Node.lazy6 func arg1 arg2 arg3 arg4 arg5 arg6


{-| 7-argument variant of [`lazy`](#lazy).
-}
lazy7 : (a -> b -> c -> d -> e -> g -> h -> Html.Html msg) -> a -> b -> c -> d -> e -> g -> h -> Node msg
lazy7 func arg1 arg2 arg3 arg4 arg5 arg6 arg7 =
    HtmlIr.Node.lazy7 func arg1 arg2 arg3 arg4 arg5 arg6 arg7


{-| 8-argument variant of [`lazy`](#lazy).
-}
lazy8 : (a -> b -> c -> d -> e -> g -> h -> i -> Html.Html msg) -> a -> b -> c -> d -> e -> g -> h -> i -> Node msg
lazy8 func arg1 arg2 arg3 arg4 arg5 arg6 arg7 arg8 =
    HtmlIr.Node.lazy8 func arg1 arg2 arg3 arg4 arg5 arg6 arg7 arg8
