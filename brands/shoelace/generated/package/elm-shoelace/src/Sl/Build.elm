module Sl.Build exposing
    ( Builder
    , toElement
    , AlertIs, AnimatedImageIs, AnimationIs, AvatarIs, BadgeIs, BreadcrumbIs, BreadcrumbItemIs, ButtonIs, ButtonGroupIs, CardIs, CarouselIs, CarouselItemIs, CheckboxIs, ColorPickerIs, CopyButtonIs, DetailsIs, DialogIs, DividerIs, DrawerIs, DropdownIs, FormatBytesIs, FormatDateIs, FormatNumberIs, IconIs, IconButtonIs, ImageComparerIs, IncludeIs, InputIs, MenuIs, MenuItemIs, MenuLabelIs, MutationObserverIs, OptionIs, PopupIs, ProgressBarIs, ProgressRingIs, QrCodeIs, RadioIs, RadioButtonIs, RadioGroupIs, RangeIs, RatingIs, RelativeTimeIs, ResizeObserverIs, SelectIs, SkeletonIs, SpinnerIs, SplitPanelIs, SwitchIs, TabIs, TabGroupIs, TabPanelIs, TagIs, TextareaIs, TooltipIs, TreeIs, TreeItemIs, VisuallyHiddenIs
    )

{-| The shared builder surface for the `Sl` brand: the opaque `Builder`
and the single `toElement` that closes any component's builder. Per-component
modules provide the seeds (`build`) and the narrowed `withX` setters; they all
share this one representation, so `toElement` is defined once (in
`Sl.Forge.Internal`) and re-exported here.

The `Is` aliases (`ButtonIs`, `CardIs`, …) let you annotate a phantom-kind
type without importing the component or its builder module.

@docs Builder
@docs toElement
@docs AlertIs, AnimatedImageIs, AnimationIs, AvatarIs, BadgeIs, BreadcrumbIs, BreadcrumbItemIs, ButtonIs, ButtonGroupIs, CardIs, CarouselIs, CarouselItemIs, CheckboxIs, ColorPickerIs, CopyButtonIs, DetailsIs, DialogIs, DividerIs, DrawerIs, DropdownIs, FormatBytesIs, FormatDateIs, FormatNumberIs, IconIs, IconButtonIs, ImageComparerIs, IncludeIs, InputIs, MenuIs, MenuItemIs, MenuLabelIs, MutationObserverIs, OptionIs, PopupIs, ProgressBarIs, ProgressRingIs, QrCodeIs, RadioIs, RadioButtonIs, RadioGroupIs, RangeIs, RatingIs, RelativeTimeIs, ResizeObserverIs, SelectIs, SkeletonIs, SpinnerIs, SplitPanelIs, SwitchIs, TabIs, TabGroupIs, TabPanelIs, TagIs, TextareaIs, TooltipIs, TreeIs, TreeItemIs, VisuallyHiddenIs

-}

import HtmlIr.Element exposing (Element)
import Sl.Build.Alert
import Sl.Build.AnimatedImage
import Sl.Build.Animation
import Sl.Build.Avatar
import Sl.Build.Badge
import Sl.Build.Breadcrumb
import Sl.Build.BreadcrumbItem
import Sl.Build.Button
import Sl.Build.ButtonGroup
import Sl.Build.Card
import Sl.Build.Carousel
import Sl.Build.CarouselItem
import Sl.Build.Checkbox
import Sl.Build.ColorPicker
import Sl.Build.CopyButton
import Sl.Build.Details
import Sl.Build.Dialog
import Sl.Build.Divider
import Sl.Build.Drawer
import Sl.Build.Dropdown
import Sl.Build.FormatBytes
import Sl.Build.FormatDate
import Sl.Build.FormatNumber
import Sl.Build.Icon
import Sl.Build.IconButton
import Sl.Build.ImageComparer
import Sl.Build.Include
import Sl.Build.Input
import Sl.Build.Menu
import Sl.Build.MenuItem
import Sl.Build.MenuLabel
import Sl.Build.MutationObserver
import Sl.Build.Option
import Sl.Build.Popup
import Sl.Build.ProgressBar
import Sl.Build.ProgressRing
import Sl.Build.QrCode
import Sl.Build.Radio
import Sl.Build.RadioButton
import Sl.Build.RadioGroup
import Sl.Build.Range
import Sl.Build.Rating
import Sl.Build.RelativeTime
import Sl.Build.ResizeObserver
import Sl.Build.Select
import Sl.Build.Skeleton
import Sl.Build.Spinner
import Sl.Build.SplitPanel
import Sl.Build.Switch
import Sl.Build.Tab
import Sl.Build.TabGroup
import Sl.Build.TabPanel
import Sl.Build.Tag
import Sl.Build.Textarea
import Sl.Build.Tooltip
import Sl.Build.Tree
import Sl.Build.TreeItem
import Sl.Build.VisuallyHidden
import Sl.Forge.Internal as Internal


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


{-| The `Alert` kind phantom — annotate with `List (Element (AlertIs s) admittedBy msg)`.
-}
type alias AlertIs s =
    Sl.Build.Alert.Is s


{-| The `AnimatedImage` kind phantom — annotate with `List (Element (AnimatedImageIs s) admittedBy msg)`.
-}
type alias AnimatedImageIs s =
    Sl.Build.AnimatedImage.Is s


{-| The `Animation` kind phantom — annotate with `List (Element (AnimationIs s) admittedBy msg)`.
-}
type alias AnimationIs s =
    Sl.Build.Animation.Is s


{-| The `Avatar` kind phantom — annotate with `List (Element (AvatarIs s) admittedBy msg)`.
-}
type alias AvatarIs s =
    Sl.Build.Avatar.Is s


{-| The `Badge` kind phantom — annotate with `List (Element (BadgeIs s) admittedBy msg)`.
-}
type alias BadgeIs s =
    Sl.Build.Badge.Is s


{-| The `Breadcrumb` kind phantom — annotate with `List (Element (BreadcrumbIs s) admittedBy msg)`.
-}
type alias BreadcrumbIs s =
    Sl.Build.Breadcrumb.Is s


{-| The `BreadcrumbItem` kind phantom — annotate with `List (Element (BreadcrumbItemIs s) admittedBy msg)`.
-}
type alias BreadcrumbItemIs s =
    Sl.Build.BreadcrumbItem.Is s


{-| The `Button` kind phantom — annotate with `List (Element (ButtonIs s) admittedBy msg)`.
-}
type alias ButtonIs s =
    Sl.Build.Button.Is s


{-| The `ButtonGroup` kind phantom — annotate with `List (Element (ButtonGroupIs s) admittedBy msg)`.
-}
type alias ButtonGroupIs s =
    Sl.Build.ButtonGroup.Is s


{-| The `Card` kind phantom — annotate with `List (Element (CardIs s) admittedBy msg)`.
-}
type alias CardIs s =
    Sl.Build.Card.Is s


{-| The `Carousel` kind phantom — annotate with `List (Element (CarouselIs s) admittedBy msg)`.
-}
type alias CarouselIs s =
    Sl.Build.Carousel.Is s


{-| The `CarouselItem` kind phantom — annotate with `List (Element (CarouselItemIs s) admittedBy msg)`.
-}
type alias CarouselItemIs s =
    Sl.Build.CarouselItem.Is s


{-| The `Checkbox` kind phantom — annotate with `List (Element (CheckboxIs s) admittedBy msg)`.
-}
type alias CheckboxIs s =
    Sl.Build.Checkbox.Is s


{-| The `ColorPicker` kind phantom — annotate with `List (Element (ColorPickerIs s) admittedBy msg)`.
-}
type alias ColorPickerIs s =
    Sl.Build.ColorPicker.Is s


{-| The `CopyButton` kind phantom — annotate with `List (Element (CopyButtonIs s) admittedBy msg)`.
-}
type alias CopyButtonIs s =
    Sl.Build.CopyButton.Is s


{-| The `Details` kind phantom — annotate with `List (Element (DetailsIs s) admittedBy msg)`.
-}
type alias DetailsIs s =
    Sl.Build.Details.Is s


{-| The `Dialog` kind phantom — annotate with `List (Element (DialogIs s) admittedBy msg)`.
-}
type alias DialogIs s =
    Sl.Build.Dialog.Is s


{-| The `Divider` kind phantom — annotate with `List (Element (DividerIs s) admittedBy msg)`.
-}
type alias DividerIs s =
    Sl.Build.Divider.Is s


{-| The `Drawer` kind phantom — annotate with `List (Element (DrawerIs s) admittedBy msg)`.
-}
type alias DrawerIs s =
    Sl.Build.Drawer.Is s


{-| The `Dropdown` kind phantom — annotate with `List (Element (DropdownIs s) admittedBy msg)`.
-}
type alias DropdownIs s =
    Sl.Build.Dropdown.Is s


{-| The `FormatBytes` kind phantom — annotate with `List (Element (FormatBytesIs s) admittedBy msg)`.
-}
type alias FormatBytesIs s =
    Sl.Build.FormatBytes.Is s


{-| The `FormatDate` kind phantom — annotate with `List (Element (FormatDateIs s) admittedBy msg)`.
-}
type alias FormatDateIs s =
    Sl.Build.FormatDate.Is s


{-| The `FormatNumber` kind phantom — annotate with `List (Element (FormatNumberIs s) admittedBy msg)`.
-}
type alias FormatNumberIs s =
    Sl.Build.FormatNumber.Is s


{-| The `Icon` kind phantom — annotate with `List (Element (IconIs s) admittedBy msg)`.
-}
type alias IconIs s =
    Sl.Build.Icon.Is s


{-| The `IconButton` kind phantom — annotate with `List (Element (IconButtonIs s) admittedBy msg)`.
-}
type alias IconButtonIs s =
    Sl.Build.IconButton.Is s


{-| The `ImageComparer` kind phantom — annotate with `List (Element (ImageComparerIs s) admittedBy msg)`.
-}
type alias ImageComparerIs s =
    Sl.Build.ImageComparer.Is s


{-| The `Include` kind phantom — annotate with `List (Element (IncludeIs s) admittedBy msg)`.
-}
type alias IncludeIs s =
    Sl.Build.Include.Is s


{-| The `Input` kind phantom — annotate with `List (Element (InputIs s) admittedBy msg)`.
-}
type alias InputIs s =
    Sl.Build.Input.Is s


{-| The `Menu` kind phantom — annotate with `List (Element (MenuIs s) admittedBy msg)`.
-}
type alias MenuIs s =
    Sl.Build.Menu.Is s


{-| The `MenuItem` kind phantom — annotate with `List (Element (MenuItemIs s) admittedBy msg)`.
-}
type alias MenuItemIs s =
    Sl.Build.MenuItem.Is s


{-| The `MenuLabel` kind phantom — annotate with `List (Element (MenuLabelIs s) admittedBy msg)`.
-}
type alias MenuLabelIs s =
    Sl.Build.MenuLabel.Is s


{-| The `MutationObserver` kind phantom — annotate with `List (Element (MutationObserverIs s) admittedBy msg)`.
-}
type alias MutationObserverIs s =
    Sl.Build.MutationObserver.Is s


{-| The `Option` kind phantom — annotate with `List (Element (OptionIs s) admittedBy msg)`.
-}
type alias OptionIs s =
    Sl.Build.Option.Is s


{-| The `Popup` kind phantom — annotate with `List (Element (PopupIs s) admittedBy msg)`.
-}
type alias PopupIs s =
    Sl.Build.Popup.Is s


{-| The `ProgressBar` kind phantom — annotate with `List (Element (ProgressBarIs s) admittedBy msg)`.
-}
type alias ProgressBarIs s =
    Sl.Build.ProgressBar.Is s


{-| The `ProgressRing` kind phantom — annotate with `List (Element (ProgressRingIs s) admittedBy msg)`.
-}
type alias ProgressRingIs s =
    Sl.Build.ProgressRing.Is s


{-| The `QrCode` kind phantom — annotate with `List (Element (QrCodeIs s) admittedBy msg)`.
-}
type alias QrCodeIs s =
    Sl.Build.QrCode.Is s


{-| The `Radio` kind phantom — annotate with `List (Element (RadioIs s) admittedBy msg)`.
-}
type alias RadioIs s =
    Sl.Build.Radio.Is s


{-| The `RadioButton` kind phantom — annotate with `List (Element (RadioButtonIs s) admittedBy msg)`.
-}
type alias RadioButtonIs s =
    Sl.Build.RadioButton.Is s


{-| The `RadioGroup` kind phantom — annotate with `List (Element (RadioGroupIs s) admittedBy msg)`.
-}
type alias RadioGroupIs s =
    Sl.Build.RadioGroup.Is s


{-| The `Range` kind phantom — annotate with `List (Element (RangeIs s) admittedBy msg)`.
-}
type alias RangeIs s =
    Sl.Build.Range.Is s


{-| The `Rating` kind phantom — annotate with `List (Element (RatingIs s) admittedBy msg)`.
-}
type alias RatingIs s =
    Sl.Build.Rating.Is s


{-| The `RelativeTime` kind phantom — annotate with `List (Element (RelativeTimeIs s) admittedBy msg)`.
-}
type alias RelativeTimeIs s =
    Sl.Build.RelativeTime.Is s


{-| The `ResizeObserver` kind phantom — annotate with `List (Element (ResizeObserverIs s) admittedBy msg)`.
-}
type alias ResizeObserverIs s =
    Sl.Build.ResizeObserver.Is s


{-| The `Select` kind phantom — annotate with `List (Element (SelectIs s) admittedBy msg)`.
-}
type alias SelectIs s =
    Sl.Build.Select.Is s


{-| The `Skeleton` kind phantom — annotate with `List (Element (SkeletonIs s) admittedBy msg)`.
-}
type alias SkeletonIs s =
    Sl.Build.Skeleton.Is s


{-| The `Spinner` kind phantom — annotate with `List (Element (SpinnerIs s) admittedBy msg)`.
-}
type alias SpinnerIs s =
    Sl.Build.Spinner.Is s


{-| The `SplitPanel` kind phantom — annotate with `List (Element (SplitPanelIs s) admittedBy msg)`.
-}
type alias SplitPanelIs s =
    Sl.Build.SplitPanel.Is s


{-| The `Switch` kind phantom — annotate with `List (Element (SwitchIs s) admittedBy msg)`.
-}
type alias SwitchIs s =
    Sl.Build.Switch.Is s


{-| The `Tab` kind phantom — annotate with `List (Element (TabIs s) admittedBy msg)`.
-}
type alias TabIs s =
    Sl.Build.Tab.Is s


{-| The `TabGroup` kind phantom — annotate with `List (Element (TabGroupIs s) admittedBy msg)`.
-}
type alias TabGroupIs s =
    Sl.Build.TabGroup.Is s


{-| The `TabPanel` kind phantom — annotate with `List (Element (TabPanelIs s) admittedBy msg)`.
-}
type alias TabPanelIs s =
    Sl.Build.TabPanel.Is s


{-| The `Tag` kind phantom — annotate with `List (Element (TagIs s) admittedBy msg)`.
-}
type alias TagIs s =
    Sl.Build.Tag.Is s


{-| The `Textarea` kind phantom — annotate with `List (Element (TextareaIs s) admittedBy msg)`.
-}
type alias TextareaIs s =
    Sl.Build.Textarea.Is s


{-| The `Tooltip` kind phantom — annotate with `List (Element (TooltipIs s) admittedBy msg)`.
-}
type alias TooltipIs s =
    Sl.Build.Tooltip.Is s


{-| The `Tree` kind phantom — annotate with `List (Element (TreeIs s) admittedBy msg)`.
-}
type alias TreeIs s =
    Sl.Build.Tree.Is s


{-| The `TreeItem` kind phantom — annotate with `List (Element (TreeItemIs s) admittedBy msg)`.
-}
type alias TreeItemIs s =
    Sl.Build.TreeItem.Is s


{-| The `VisuallyHidden` kind phantom — annotate with `List (Element (VisuallyHiddenIs s) admittedBy msg)`.
-}
type alias VisuallyHiddenIs s =
    Sl.Build.VisuallyHidden.Is s
