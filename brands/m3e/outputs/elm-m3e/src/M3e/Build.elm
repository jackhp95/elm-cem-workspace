module M3e.Build exposing
    ( Builder
    , toElement
    , AccordionIs, ActionListIs, AppBarIs, AssistChipIs, AutocompleteIs, AvatarIs, BadgeIs, BottomSheetIs, BottomSheetActionIs, BottomSheetTriggerIs, BreadcrumbIs, BreadcrumbItemIs, BreadcrumbItemButtonIs, ButtonIs, ButtonGroupIs, ButtonSegmentIs, CalendarIs, CardIs, CheckboxIs, ChipIs, ChipSetIs, CircularProgressIndicatorIs, CollapsibleIs, ContentPaneIs, DateInputIs, DatepickerIs, DatepickerToggleIs, DialogIs, DialogActionIs, DialogTriggerIs, DividerIs, DrawerContainerIs, DrawerToggleIs, ElevationIs, ExpandableListItemIs, ExpansionHeaderIs, ExpansionPanelIs, FabIs, FabMenuIs, FabMenuItemIs, FabMenuTriggerIs, FilterChipIs, FilterChipSetIs, FloatingPanelIs, FocusRingIs, FocusTrapIs, FormFieldIs, HeadingIs, IconIs, IconButtonIs, InputChipIs, InputChipSetIs, LinearProgressIndicatorIs, ListIs, ListActionIs, ListItemIs, ListItemButtonIs, ListOptionIs, LoadingIndicatorIs, MenuIs, MenuItemIs, MenuItemCheckboxIs, MenuItemGroupIs, MenuItemRadioIs, MenuTriggerIs, MonthViewIs, MultiYearViewIs, NavBarIs, NavItemIs, NavMenuIs, NavMenuItemIs, NavMenuItemGroupIs, NavRailIs, NavRailToggleIs, OptgroupIs, OptionIs, OptionPanelIs, PaginatorIs, PseudoCheckboxIs, PseudoRadioIs, RadioIs, RadioGroupIs, RichTooltipIs, RichTooltipActionIs, RippleIs, ScrollContainerIs, SearchBarIs, SearchViewIs, SegmentedButtonIs, SelectIs, SelectionIndicatorIs, SelectionListIs, ShapeIs, SkeletonIs, SlideIs, SlideGroupIs, SliderIs, SliderThumbIs, SnackbarIs, SplitButtonIs, SplitPaneIs, StateLayerIs, StepIs, StepPanelIs, StepperIs, StepperNextIs, StepperPreviousIs, StepperResetIs, SuggestionChipIs, SwitchIs, TabIs, TabPanelIs, TabsIs, TextHighlightIs, TextOverflowIs, TextareaAutosizeIs, ThemeIs, ThemeIconIs, TimepickerIs, TimepickerDialIs, TimepickerInputIs, TimepickerInputPeriodToggleIs, TimepickerToggleIs, TocIs, TocItemIs, ToolbarIs, TooltipIs, TreeIs, TreeItemIs, YearViewIs
    )

{-| The shared builder surface for the `M3e` brand: the opaque `Builder`
and the single `toElement` that closes any component's builder. Per-component
modules provide the seeds (`build`) and the narrowed `withX` setters; they all
share this one representation, so `toElement` is defined once (in
`M3e.Forge.Internal`) and re-exported here.

The `Is` aliases (`ButtonIs`, `CardIs`, …) let you annotate a phantom-kind
type without importing the component or its builder module.

@docs Builder
@docs toElement
@docs AccordionIs, ActionListIs, AppBarIs, AssistChipIs, AutocompleteIs, AvatarIs, BadgeIs, BottomSheetIs, BottomSheetActionIs, BottomSheetTriggerIs, BreadcrumbIs, BreadcrumbItemIs, BreadcrumbItemButtonIs, ButtonIs, ButtonGroupIs, ButtonSegmentIs, CalendarIs, CardIs, CheckboxIs, ChipIs, ChipSetIs, CircularProgressIndicatorIs, CollapsibleIs, ContentPaneIs, DateInputIs, DatepickerIs, DatepickerToggleIs, DialogIs, DialogActionIs, DialogTriggerIs, DividerIs, DrawerContainerIs, DrawerToggleIs, ElevationIs, ExpandableListItemIs, ExpansionHeaderIs, ExpansionPanelIs, FabIs, FabMenuIs, FabMenuItemIs, FabMenuTriggerIs, FilterChipIs, FilterChipSetIs, FloatingPanelIs, FocusRingIs, FocusTrapIs, FormFieldIs, HeadingIs, IconIs, IconButtonIs, InputChipIs, InputChipSetIs, LinearProgressIndicatorIs, ListIs, ListActionIs, ListItemIs, ListItemButtonIs, ListOptionIs, LoadingIndicatorIs, MenuIs, MenuItemIs, MenuItemCheckboxIs, MenuItemGroupIs, MenuItemRadioIs, MenuTriggerIs, MonthViewIs, MultiYearViewIs, NavBarIs, NavItemIs, NavMenuIs, NavMenuItemIs, NavMenuItemGroupIs, NavRailIs, NavRailToggleIs, OptgroupIs, OptionIs, OptionPanelIs, PaginatorIs, PseudoCheckboxIs, PseudoRadioIs, RadioIs, RadioGroupIs, RichTooltipIs, RichTooltipActionIs, RippleIs, ScrollContainerIs, SearchBarIs, SearchViewIs, SegmentedButtonIs, SelectIs, SelectionIndicatorIs, SelectionListIs, ShapeIs, SkeletonIs, SlideIs, SlideGroupIs, SliderIs, SliderThumbIs, SnackbarIs, SplitButtonIs, SplitPaneIs, StateLayerIs, StepIs, StepPanelIs, StepperIs, StepperNextIs, StepperPreviousIs, StepperResetIs, SuggestionChipIs, SwitchIs, TabIs, TabPanelIs, TabsIs, TextHighlightIs, TextOverflowIs, TextareaAutosizeIs, ThemeIs, ThemeIconIs, TimepickerIs, TimepickerDialIs, TimepickerInputIs, TimepickerInputPeriodToggleIs, TimepickerToggleIs, TocIs, TocItemIs, ToolbarIs, TooltipIs, TreeIs, TreeItemIs, YearViewIs

-}

import HtmlIr.Element exposing (Element)
import M3e.Build.Accordion
import M3e.Build.ActionList
import M3e.Build.AppBar
import M3e.Build.AssistChip
import M3e.Build.Autocomplete
import M3e.Build.Avatar
import M3e.Build.Badge
import M3e.Build.BottomSheet
import M3e.Build.BottomSheetAction
import M3e.Build.BottomSheetTrigger
import M3e.Build.Breadcrumb
import M3e.Build.BreadcrumbItem
import M3e.Build.BreadcrumbItemButton
import M3e.Build.Button
import M3e.Build.ButtonGroup
import M3e.Build.ButtonSegment
import M3e.Build.Calendar
import M3e.Build.Card
import M3e.Build.Checkbox
import M3e.Build.Chip
import M3e.Build.ChipSet
import M3e.Build.CircularProgressIndicator
import M3e.Build.Collapsible
import M3e.Build.ContentPane
import M3e.Build.DateInput
import M3e.Build.Datepicker
import M3e.Build.DatepickerToggle
import M3e.Build.Dialog
import M3e.Build.DialogAction
import M3e.Build.DialogTrigger
import M3e.Build.Divider
import M3e.Build.DrawerContainer
import M3e.Build.DrawerToggle
import M3e.Build.Elevation
import M3e.Build.ExpandableListItem
import M3e.Build.ExpansionHeader
import M3e.Build.ExpansionPanel
import M3e.Build.Fab
import M3e.Build.FabMenu
import M3e.Build.FabMenuItem
import M3e.Build.FabMenuTrigger
import M3e.Build.FilterChip
import M3e.Build.FilterChipSet
import M3e.Build.FloatingPanel
import M3e.Build.FocusRing
import M3e.Build.FocusTrap
import M3e.Build.FormField
import M3e.Build.Heading
import M3e.Build.Icon
import M3e.Build.IconButton
import M3e.Build.InputChip
import M3e.Build.InputChipSet
import M3e.Build.LinearProgressIndicator
import M3e.Build.List
import M3e.Build.ListAction
import M3e.Build.ListItem
import M3e.Build.ListItemButton
import M3e.Build.ListOption
import M3e.Build.LoadingIndicator
import M3e.Build.Menu
import M3e.Build.MenuItem
import M3e.Build.MenuItemCheckbox
import M3e.Build.MenuItemGroup
import M3e.Build.MenuItemRadio
import M3e.Build.MenuTrigger
import M3e.Build.MonthView
import M3e.Build.MultiYearView
import M3e.Build.NavBar
import M3e.Build.NavItem
import M3e.Build.NavMenu
import M3e.Build.NavMenuItem
import M3e.Build.NavMenuItemGroup
import M3e.Build.NavRail
import M3e.Build.NavRailToggle
import M3e.Build.Optgroup
import M3e.Build.Option
import M3e.Build.OptionPanel
import M3e.Build.Paginator
import M3e.Build.PseudoCheckbox
import M3e.Build.PseudoRadio
import M3e.Build.Radio
import M3e.Build.RadioGroup
import M3e.Build.RichTooltip
import M3e.Build.RichTooltipAction
import M3e.Build.Ripple
import M3e.Build.ScrollContainer
import M3e.Build.SearchBar
import M3e.Build.SearchView
import M3e.Build.SegmentedButton
import M3e.Build.Select
import M3e.Build.SelectionIndicator
import M3e.Build.SelectionList
import M3e.Build.Shape
import M3e.Build.Skeleton
import M3e.Build.Slide
import M3e.Build.SlideGroup
import M3e.Build.Slider
import M3e.Build.SliderThumb
import M3e.Build.Snackbar
import M3e.Build.SplitButton
import M3e.Build.SplitPane
import M3e.Build.StateLayer
import M3e.Build.Step
import M3e.Build.StepPanel
import M3e.Build.Stepper
import M3e.Build.StepperNext
import M3e.Build.StepperPrevious
import M3e.Build.StepperReset
import M3e.Build.SuggestionChip
import M3e.Build.Switch
import M3e.Build.Tab
import M3e.Build.TabPanel
import M3e.Build.Tabs
import M3e.Build.TextHighlight
import M3e.Build.TextOverflow
import M3e.Build.TextareaAutosize
import M3e.Build.Theme
import M3e.Build.ThemeIcon
import M3e.Build.Timepicker
import M3e.Build.TimepickerDial
import M3e.Build.TimepickerInput
import M3e.Build.TimepickerInputPeriodToggle
import M3e.Build.TimepickerToggle
import M3e.Build.Toc
import M3e.Build.TocItem
import M3e.Build.Toolbar
import M3e.Build.Tooltip
import M3e.Build.Tree
import M3e.Build.TreeItem
import M3e.Build.YearView
import M3e.Forge.Internal as Internal


{-| The shared pipe-builder — see each component's `Builder` alias for its
narrowed, brand-typed form.
-}
type alias Builder row attrCaps slotCaps accepts msg =
    Internal.Builder row attrCaps slotCaps accepts msg


{-| Close any builder into its element.
-}
toElement : Builder row attrCaps slotCaps accepts msg -> Element accepts admittedBy msg
toElement =
    Internal.toElement


{-| The `Accordion` kind phantom — annotate with `List (Element (AccordionIs s) admittedBy msg)`.
-}
type alias AccordionIs s =
    M3e.Build.Accordion.Is s


{-| The `ActionList` kind phantom — annotate with `List (Element (ActionListIs s) admittedBy msg)`.
-}
type alias ActionListIs s =
    M3e.Build.ActionList.Is s


{-| The `AppBar` kind phantom — annotate with `List (Element (AppBarIs s) admittedBy msg)`.
-}
type alias AppBarIs s =
    M3e.Build.AppBar.Is s


{-| The `AssistChip` kind phantom — annotate with `List (Element (AssistChipIs s) admittedBy msg)`.
-}
type alias AssistChipIs s =
    M3e.Build.AssistChip.Is s


{-| The `Autocomplete` kind phantom — annotate with `List (Element (AutocompleteIs s) admittedBy msg)`.
-}
type alias AutocompleteIs s =
    M3e.Build.Autocomplete.Is s


{-| The `Avatar` kind phantom — annotate with `List (Element (AvatarIs s) admittedBy msg)`.
-}
type alias AvatarIs s =
    M3e.Build.Avatar.Is s


{-| The `Badge` kind phantom — annotate with `List (Element (BadgeIs s) admittedBy msg)`.
-}
type alias BadgeIs s =
    M3e.Build.Badge.Is s


{-| The `BottomSheet` kind phantom — annotate with `List (Element (BottomSheetIs s) admittedBy msg)`.
-}
type alias BottomSheetIs s =
    M3e.Build.BottomSheet.Is s


{-| The `BottomSheetAction` kind phantom — annotate with `List (Element (BottomSheetActionIs s) admittedBy msg)`.
-}
type alias BottomSheetActionIs s =
    M3e.Build.BottomSheetAction.Is s


{-| The `BottomSheetTrigger` kind phantom — annotate with `List (Element (BottomSheetTriggerIs s) admittedBy msg)`.
-}
type alias BottomSheetTriggerIs s =
    M3e.Build.BottomSheetTrigger.Is s


{-| The `Breadcrumb` kind phantom — annotate with `List (Element (BreadcrumbIs s) admittedBy msg)`.
-}
type alias BreadcrumbIs s =
    M3e.Build.Breadcrumb.Is s


{-| The `BreadcrumbItem` kind phantom — annotate with `List (Element (BreadcrumbItemIs s) admittedBy msg)`.
-}
type alias BreadcrumbItemIs s =
    M3e.Build.BreadcrumbItem.Is s


{-| The `BreadcrumbItemButton` kind phantom — annotate with `List (Element (BreadcrumbItemButtonIs s) admittedBy msg)`.
-}
type alias BreadcrumbItemButtonIs s =
    M3e.Build.BreadcrumbItemButton.Is s


{-| The `Button` kind phantom — annotate with `List (Element (ButtonIs s) admittedBy msg)`.
-}
type alias ButtonIs s =
    M3e.Build.Button.Is s


{-| The `ButtonGroup` kind phantom — annotate with `List (Element (ButtonGroupIs s) admittedBy msg)`.
-}
type alias ButtonGroupIs s =
    M3e.Build.ButtonGroup.Is s


{-| The `ButtonSegment` kind phantom — annotate with `List (Element (ButtonSegmentIs s) admittedBy msg)`.
-}
type alias ButtonSegmentIs s =
    M3e.Build.ButtonSegment.Is s


{-| The `Calendar` kind phantom — annotate with `List (Element (CalendarIs s) admittedBy msg)`.
-}
type alias CalendarIs s =
    M3e.Build.Calendar.Is s


{-| The `Card` kind phantom — annotate with `List (Element (CardIs s) admittedBy msg)`.
-}
type alias CardIs s =
    M3e.Build.Card.Is s


{-| The `Checkbox` kind phantom — annotate with `List (Element (CheckboxIs s) admittedBy msg)`.
-}
type alias CheckboxIs s =
    M3e.Build.Checkbox.Is s


{-| The `Chip` kind phantom — annotate with `List (Element (ChipIs s) admittedBy msg)`.
-}
type alias ChipIs s =
    M3e.Build.Chip.Is s


{-| The `ChipSet` kind phantom — annotate with `List (Element (ChipSetIs s) admittedBy msg)`.
-}
type alias ChipSetIs s =
    M3e.Build.ChipSet.Is s


{-| The `CircularProgressIndicator` kind phantom — annotate with `List (Element (CircularProgressIndicatorIs s) admittedBy msg)`.
-}
type alias CircularProgressIndicatorIs s =
    M3e.Build.CircularProgressIndicator.Is s


{-| The `Collapsible` kind phantom — annotate with `List (Element (CollapsibleIs s) admittedBy msg)`.
-}
type alias CollapsibleIs s =
    M3e.Build.Collapsible.Is s


{-| The `ContentPane` kind phantom — annotate with `List (Element (ContentPaneIs s) admittedBy msg)`.
-}
type alias ContentPaneIs s =
    M3e.Build.ContentPane.Is s


{-| The `DateInput` kind phantom — annotate with `List (Element (DateInputIs s) admittedBy msg)`.
-}
type alias DateInputIs s =
    M3e.Build.DateInput.Is s


{-| The `Datepicker` kind phantom — annotate with `List (Element (DatepickerIs s) admittedBy msg)`.
-}
type alias DatepickerIs s =
    M3e.Build.Datepicker.Is s


{-| The `DatepickerToggle` kind phantom — annotate with `List (Element (DatepickerToggleIs s) admittedBy msg)`.
-}
type alias DatepickerToggleIs s =
    M3e.Build.DatepickerToggle.Is s


{-| The `Dialog` kind phantom — annotate with `List (Element (DialogIs s) admittedBy msg)`.
-}
type alias DialogIs s =
    M3e.Build.Dialog.Is s


{-| The `DialogAction` kind phantom — annotate with `List (Element (DialogActionIs s) admittedBy msg)`.
-}
type alias DialogActionIs s =
    M3e.Build.DialogAction.Is s


{-| The `DialogTrigger` kind phantom — annotate with `List (Element (DialogTriggerIs s) admittedBy msg)`.
-}
type alias DialogTriggerIs s =
    M3e.Build.DialogTrigger.Is s


{-| The `Divider` kind phantom — annotate with `List (Element (DividerIs s) admittedBy msg)`.
-}
type alias DividerIs s =
    M3e.Build.Divider.Is s


{-| The `DrawerContainer` kind phantom — annotate with `List (Element (DrawerContainerIs s) admittedBy msg)`.
-}
type alias DrawerContainerIs s =
    M3e.Build.DrawerContainer.Is s


{-| The `DrawerToggle` kind phantom — annotate with `List (Element (DrawerToggleIs s) admittedBy msg)`.
-}
type alias DrawerToggleIs s =
    M3e.Build.DrawerToggle.Is s


{-| The `Elevation` kind phantom — annotate with `List (Element (ElevationIs s) admittedBy msg)`.
-}
type alias ElevationIs s =
    M3e.Build.Elevation.Is s


{-| The `ExpandableListItem` kind phantom — annotate with `List (Element (ExpandableListItemIs s) admittedBy msg)`.
-}
type alias ExpandableListItemIs s =
    M3e.Build.ExpandableListItem.Is s


{-| The `ExpansionHeader` kind phantom — annotate with `List (Element (ExpansionHeaderIs s) admittedBy msg)`.
-}
type alias ExpansionHeaderIs s =
    M3e.Build.ExpansionHeader.Is s


{-| The `ExpansionPanel` kind phantom — annotate with `List (Element (ExpansionPanelIs s) admittedBy msg)`.
-}
type alias ExpansionPanelIs s =
    M3e.Build.ExpansionPanel.Is s


{-| The `Fab` kind phantom — annotate with `List (Element (FabIs s) admittedBy msg)`.
-}
type alias FabIs s =
    M3e.Build.Fab.Is s


{-| The `FabMenu` kind phantom — annotate with `List (Element (FabMenuIs s) admittedBy msg)`.
-}
type alias FabMenuIs s =
    M3e.Build.FabMenu.Is s


{-| The `FabMenuItem` kind phantom — annotate with `List (Element (FabMenuItemIs s) admittedBy msg)`.
-}
type alias FabMenuItemIs s =
    M3e.Build.FabMenuItem.Is s


{-| The `FabMenuTrigger` kind phantom — annotate with `List (Element (FabMenuTriggerIs s) admittedBy msg)`.
-}
type alias FabMenuTriggerIs s =
    M3e.Build.FabMenuTrigger.Is s


{-| The `FilterChip` kind phantom — annotate with `List (Element (FilterChipIs s) admittedBy msg)`.
-}
type alias FilterChipIs s =
    M3e.Build.FilterChip.Is s


{-| The `FilterChipSet` kind phantom — annotate with `List (Element (FilterChipSetIs s) admittedBy msg)`.
-}
type alias FilterChipSetIs s =
    M3e.Build.FilterChipSet.Is s


{-| The `FloatingPanel` kind phantom — annotate with `List (Element (FloatingPanelIs s) admittedBy msg)`.
-}
type alias FloatingPanelIs s =
    M3e.Build.FloatingPanel.Is s


{-| The `FocusRing` kind phantom — annotate with `List (Element (FocusRingIs s) admittedBy msg)`.
-}
type alias FocusRingIs s =
    M3e.Build.FocusRing.Is s


{-| The `FocusTrap` kind phantom — annotate with `List (Element (FocusTrapIs s) admittedBy msg)`.
-}
type alias FocusTrapIs s =
    M3e.Build.FocusTrap.Is s


{-| The `FormField` kind phantom — annotate with `List (Element (FormFieldIs s) admittedBy msg)`.
-}
type alias FormFieldIs s =
    M3e.Build.FormField.Is s


{-| The `Heading` kind phantom — annotate with `List (Element (HeadingIs s) admittedBy msg)`.
-}
type alias HeadingIs s =
    M3e.Build.Heading.Is s


{-| The `Icon` kind phantom — annotate with `List (Element (IconIs s) admittedBy msg)`.
-}
type alias IconIs s =
    M3e.Build.Icon.Is s


{-| The `IconButton` kind phantom — annotate with `List (Element (IconButtonIs s) admittedBy msg)`.
-}
type alias IconButtonIs s =
    M3e.Build.IconButton.Is s


{-| The `InputChip` kind phantom — annotate with `List (Element (InputChipIs s) admittedBy msg)`.
-}
type alias InputChipIs s =
    M3e.Build.InputChip.Is s


{-| The `InputChipSet` kind phantom — annotate with `List (Element (InputChipSetIs s) admittedBy msg)`.
-}
type alias InputChipSetIs s =
    M3e.Build.InputChipSet.Is s


{-| The `LinearProgressIndicator` kind phantom — annotate with `List (Element (LinearProgressIndicatorIs s) admittedBy msg)`.
-}
type alias LinearProgressIndicatorIs s =
    M3e.Build.LinearProgressIndicator.Is s


{-| The `List` kind phantom — annotate with `List (Element (ListIs s) admittedBy msg)`.
-}
type alias ListIs s =
    M3e.Build.List.Is s


{-| The `ListAction` kind phantom — annotate with `List (Element (ListActionIs s) admittedBy msg)`.
-}
type alias ListActionIs s =
    M3e.Build.ListAction.Is s


{-| The `ListItem` kind phantom — annotate with `List (Element (ListItemIs s) admittedBy msg)`.
-}
type alias ListItemIs s =
    M3e.Build.ListItem.Is s


{-| The `ListItemButton` kind phantom — annotate with `List (Element (ListItemButtonIs s) admittedBy msg)`.
-}
type alias ListItemButtonIs s =
    M3e.Build.ListItemButton.Is s


{-| The `ListOption` kind phantom — annotate with `List (Element (ListOptionIs s) admittedBy msg)`.
-}
type alias ListOptionIs s =
    M3e.Build.ListOption.Is s


{-| The `LoadingIndicator` kind phantom — annotate with `List (Element (LoadingIndicatorIs s) admittedBy msg)`.
-}
type alias LoadingIndicatorIs s =
    M3e.Build.LoadingIndicator.Is s


{-| The `Menu` kind phantom — annotate with `List (Element (MenuIs s) admittedBy msg)`.
-}
type alias MenuIs s =
    M3e.Build.Menu.Is s


{-| The `MenuItem` kind phantom — annotate with `List (Element (MenuItemIs s) admittedBy msg)`.
-}
type alias MenuItemIs s =
    M3e.Build.MenuItem.Is s


{-| The `MenuItemCheckbox` kind phantom — annotate with `List (Element (MenuItemCheckboxIs s) admittedBy msg)`.
-}
type alias MenuItemCheckboxIs s =
    M3e.Build.MenuItemCheckbox.Is s


{-| The `MenuItemGroup` kind phantom — annotate with `List (Element (MenuItemGroupIs s) admittedBy msg)`.
-}
type alias MenuItemGroupIs s =
    M3e.Build.MenuItemGroup.Is s


{-| The `MenuItemRadio` kind phantom — annotate with `List (Element (MenuItemRadioIs s) admittedBy msg)`.
-}
type alias MenuItemRadioIs s =
    M3e.Build.MenuItemRadio.Is s


{-| The `MenuTrigger` kind phantom — annotate with `List (Element (MenuTriggerIs s) admittedBy msg)`.
-}
type alias MenuTriggerIs s =
    M3e.Build.MenuTrigger.Is s


{-| The `MonthView` kind phantom — annotate with `List (Element (MonthViewIs s) admittedBy msg)`.
-}
type alias MonthViewIs s =
    M3e.Build.MonthView.Is s


{-| The `MultiYearView` kind phantom — annotate with `List (Element (MultiYearViewIs s) admittedBy msg)`.
-}
type alias MultiYearViewIs s =
    M3e.Build.MultiYearView.Is s


{-| The `NavBar` kind phantom — annotate with `List (Element (NavBarIs s) admittedBy msg)`.
-}
type alias NavBarIs s =
    M3e.Build.NavBar.Is s


{-| The `NavItem` kind phantom — annotate with `List (Element (NavItemIs s) admittedBy msg)`.
-}
type alias NavItemIs s =
    M3e.Build.NavItem.Is s


{-| The `NavMenu` kind phantom — annotate with `List (Element (NavMenuIs s) admittedBy msg)`.
-}
type alias NavMenuIs s =
    M3e.Build.NavMenu.Is s


{-| The `NavMenuItem` kind phantom — annotate with `List (Element (NavMenuItemIs s) admittedBy msg)`.
-}
type alias NavMenuItemIs s =
    M3e.Build.NavMenuItem.Is s


{-| The `NavMenuItemGroup` kind phantom — annotate with `List (Element (NavMenuItemGroupIs s) admittedBy msg)`.
-}
type alias NavMenuItemGroupIs s =
    M3e.Build.NavMenuItemGroup.Is s


{-| The `NavRail` kind phantom — annotate with `List (Element (NavRailIs s) admittedBy msg)`.
-}
type alias NavRailIs s =
    M3e.Build.NavRail.Is s


{-| The `NavRailToggle` kind phantom — annotate with `List (Element (NavRailToggleIs s) admittedBy msg)`.
-}
type alias NavRailToggleIs s =
    M3e.Build.NavRailToggle.Is s


{-| The `Optgroup` kind phantom — annotate with `List (Element (OptgroupIs s) admittedBy msg)`.
-}
type alias OptgroupIs s =
    M3e.Build.Optgroup.Is s


{-| The `Option` kind phantom — annotate with `List (Element (OptionIs s) admittedBy msg)`.
-}
type alias OptionIs s =
    M3e.Build.Option.Is s


{-| The `OptionPanel` kind phantom — annotate with `List (Element (OptionPanelIs s) admittedBy msg)`.
-}
type alias OptionPanelIs s =
    M3e.Build.OptionPanel.Is s


{-| The `Paginator` kind phantom — annotate with `List (Element (PaginatorIs s) admittedBy msg)`.
-}
type alias PaginatorIs s =
    M3e.Build.Paginator.Is s


{-| The `PseudoCheckbox` kind phantom — annotate with `List (Element (PseudoCheckboxIs s) admittedBy msg)`.
-}
type alias PseudoCheckboxIs s =
    M3e.Build.PseudoCheckbox.Is s


{-| The `PseudoRadio` kind phantom — annotate with `List (Element (PseudoRadioIs s) admittedBy msg)`.
-}
type alias PseudoRadioIs s =
    M3e.Build.PseudoRadio.Is s


{-| The `Radio` kind phantom — annotate with `List (Element (RadioIs s) admittedBy msg)`.
-}
type alias RadioIs s =
    M3e.Build.Radio.Is s


{-| The `RadioGroup` kind phantom — annotate with `List (Element (RadioGroupIs s) admittedBy msg)`.
-}
type alias RadioGroupIs s =
    M3e.Build.RadioGroup.Is s


{-| The `RichTooltip` kind phantom — annotate with `List (Element (RichTooltipIs s) admittedBy msg)`.
-}
type alias RichTooltipIs s =
    M3e.Build.RichTooltip.Is s


{-| The `RichTooltipAction` kind phantom — annotate with `List (Element (RichTooltipActionIs s) admittedBy msg)`.
-}
type alias RichTooltipActionIs s =
    M3e.Build.RichTooltipAction.Is s


{-| The `Ripple` kind phantom — annotate with `List (Element (RippleIs s) admittedBy msg)`.
-}
type alias RippleIs s =
    M3e.Build.Ripple.Is s


{-| The `ScrollContainer` kind phantom — annotate with `List (Element (ScrollContainerIs s) admittedBy msg)`.
-}
type alias ScrollContainerIs s =
    M3e.Build.ScrollContainer.Is s


{-| The `SearchBar` kind phantom — annotate with `List (Element (SearchBarIs s) admittedBy msg)`.
-}
type alias SearchBarIs s =
    M3e.Build.SearchBar.Is s


{-| The `SearchView` kind phantom — annotate with `List (Element (SearchViewIs s) admittedBy msg)`.
-}
type alias SearchViewIs s =
    M3e.Build.SearchView.Is s


{-| The `SegmentedButton` kind phantom — annotate with `List (Element (SegmentedButtonIs s) admittedBy msg)`.
-}
type alias SegmentedButtonIs s =
    M3e.Build.SegmentedButton.Is s


{-| The `Select` kind phantom — annotate with `List (Element (SelectIs s) admittedBy msg)`.
-}
type alias SelectIs s =
    M3e.Build.Select.Is s


{-| The `SelectionIndicator` kind phantom — annotate with `List (Element (SelectionIndicatorIs s) admittedBy msg)`.
-}
type alias SelectionIndicatorIs s =
    M3e.Build.SelectionIndicator.Is s


{-| The `SelectionList` kind phantom — annotate with `List (Element (SelectionListIs s) admittedBy msg)`.
-}
type alias SelectionListIs s =
    M3e.Build.SelectionList.Is s


{-| The `Shape` kind phantom — annotate with `List (Element (ShapeIs s) admittedBy msg)`.
-}
type alias ShapeIs s =
    M3e.Build.Shape.Is s


{-| The `Skeleton` kind phantom — annotate with `List (Element (SkeletonIs s) admittedBy msg)`.
-}
type alias SkeletonIs s =
    M3e.Build.Skeleton.Is s


{-| The `Slide` kind phantom — annotate with `List (Element (SlideIs s) admittedBy msg)`.
-}
type alias SlideIs s =
    M3e.Build.Slide.Is s


{-| The `SlideGroup` kind phantom — annotate with `List (Element (SlideGroupIs s) admittedBy msg)`.
-}
type alias SlideGroupIs s =
    M3e.Build.SlideGroup.Is s


{-| The `Slider` kind phantom — annotate with `List (Element (SliderIs s) admittedBy msg)`.
-}
type alias SliderIs s =
    M3e.Build.Slider.Is s


{-| The `SliderThumb` kind phantom — annotate with `List (Element (SliderThumbIs s) admittedBy msg)`.
-}
type alias SliderThumbIs s =
    M3e.Build.SliderThumb.Is s


{-| The `Snackbar` kind phantom — annotate with `List (Element (SnackbarIs s) admittedBy msg)`.
-}
type alias SnackbarIs s =
    M3e.Build.Snackbar.Is s


{-| The `SplitButton` kind phantom — annotate with `List (Element (SplitButtonIs s) admittedBy msg)`.
-}
type alias SplitButtonIs s =
    M3e.Build.SplitButton.Is s


{-| The `SplitPane` kind phantom — annotate with `List (Element (SplitPaneIs s) admittedBy msg)`.
-}
type alias SplitPaneIs s =
    M3e.Build.SplitPane.Is s


{-| The `StateLayer` kind phantom — annotate with `List (Element (StateLayerIs s) admittedBy msg)`.
-}
type alias StateLayerIs s =
    M3e.Build.StateLayer.Is s


{-| The `Step` kind phantom — annotate with `List (Element (StepIs s) admittedBy msg)`.
-}
type alias StepIs s =
    M3e.Build.Step.Is s


{-| The `StepPanel` kind phantom — annotate with `List (Element (StepPanelIs s) admittedBy msg)`.
-}
type alias StepPanelIs s =
    M3e.Build.StepPanel.Is s


{-| The `Stepper` kind phantom — annotate with `List (Element (StepperIs s) admittedBy msg)`.
-}
type alias StepperIs s =
    M3e.Build.Stepper.Is s


{-| The `StepperNext` kind phantom — annotate with `List (Element (StepperNextIs s) admittedBy msg)`.
-}
type alias StepperNextIs s =
    M3e.Build.StepperNext.Is s


{-| The `StepperPrevious` kind phantom — annotate with `List (Element (StepperPreviousIs s) admittedBy msg)`.
-}
type alias StepperPreviousIs s =
    M3e.Build.StepperPrevious.Is s


{-| The `StepperReset` kind phantom — annotate with `List (Element (StepperResetIs s) admittedBy msg)`.
-}
type alias StepperResetIs s =
    M3e.Build.StepperReset.Is s


{-| The `SuggestionChip` kind phantom — annotate with `List (Element (SuggestionChipIs s) admittedBy msg)`.
-}
type alias SuggestionChipIs s =
    M3e.Build.SuggestionChip.Is s


{-| The `Switch` kind phantom — annotate with `List (Element (SwitchIs s) admittedBy msg)`.
-}
type alias SwitchIs s =
    M3e.Build.Switch.Is s


{-| The `Tab` kind phantom — annotate with `List (Element (TabIs s) admittedBy msg)`.
-}
type alias TabIs s =
    M3e.Build.Tab.Is s


{-| The `TabPanel` kind phantom — annotate with `List (Element (TabPanelIs s) admittedBy msg)`.
-}
type alias TabPanelIs s =
    M3e.Build.TabPanel.Is s


{-| The `Tabs` kind phantom — annotate with `List (Element (TabsIs s) admittedBy msg)`.
-}
type alias TabsIs s =
    M3e.Build.Tabs.Is s


{-| The `TextHighlight` kind phantom — annotate with `List (Element (TextHighlightIs s) admittedBy msg)`.
-}
type alias TextHighlightIs s =
    M3e.Build.TextHighlight.Is s


{-| The `TextOverflow` kind phantom — annotate with `List (Element (TextOverflowIs s) admittedBy msg)`.
-}
type alias TextOverflowIs s =
    M3e.Build.TextOverflow.Is s


{-| The `TextareaAutosize` kind phantom — annotate with `List (Element (TextareaAutosizeIs s) admittedBy msg)`.
-}
type alias TextareaAutosizeIs s =
    M3e.Build.TextareaAutosize.Is s


{-| The `Theme` kind phantom — annotate with `List (Element (ThemeIs s) admittedBy msg)`.
-}
type alias ThemeIs s =
    M3e.Build.Theme.Is s


{-| The `ThemeIcon` kind phantom — annotate with `List (Element (ThemeIconIs s) admittedBy msg)`.
-}
type alias ThemeIconIs s =
    M3e.Build.ThemeIcon.Is s


{-| The `Timepicker` kind phantom — annotate with `List (Element (TimepickerIs s) admittedBy msg)`.
-}
type alias TimepickerIs s =
    M3e.Build.Timepicker.Is s


{-| The `TimepickerDial` kind phantom — annotate with `List (Element (TimepickerDialIs s) admittedBy msg)`.
-}
type alias TimepickerDialIs s =
    M3e.Build.TimepickerDial.Is s


{-| The `TimepickerInput` kind phantom — annotate with `List (Element (TimepickerInputIs s) admittedBy msg)`.
-}
type alias TimepickerInputIs s =
    M3e.Build.TimepickerInput.Is s


{-| The `TimepickerInputPeriodToggle` kind phantom — annotate with `List (Element (TimepickerInputPeriodToggleIs s) admittedBy msg)`.
-}
type alias TimepickerInputPeriodToggleIs s =
    M3e.Build.TimepickerInputPeriodToggle.Is s


{-| The `TimepickerToggle` kind phantom — annotate with `List (Element (TimepickerToggleIs s) admittedBy msg)`.
-}
type alias TimepickerToggleIs s =
    M3e.Build.TimepickerToggle.Is s


{-| The `Toc` kind phantom — annotate with `List (Element (TocIs s) admittedBy msg)`.
-}
type alias TocIs s =
    M3e.Build.Toc.Is s


{-| The `TocItem` kind phantom — annotate with `List (Element (TocItemIs s) admittedBy msg)`.
-}
type alias TocItemIs s =
    M3e.Build.TocItem.Is s


{-| The `Toolbar` kind phantom — annotate with `List (Element (ToolbarIs s) admittedBy msg)`.
-}
type alias ToolbarIs s =
    M3e.Build.Toolbar.Is s


{-| The `Tooltip` kind phantom — annotate with `List (Element (TooltipIs s) admittedBy msg)`.
-}
type alias TooltipIs s =
    M3e.Build.Tooltip.Is s


{-| The `Tree` kind phantom — annotate with `List (Element (TreeIs s) admittedBy msg)`.
-}
type alias TreeIs s =
    M3e.Build.Tree.Is s


{-| The `TreeItem` kind phantom — annotate with `List (Element (TreeItemIs s) admittedBy msg)`.
-}
type alias TreeItemIs s =
    M3e.Build.TreeItem.Is s


{-| The `YearView` kind phantom — annotate with `List (Element (YearViewIs s) admittedBy msg)`.
-}
type alias YearViewIs s =
    M3e.Build.YearView.Is s
