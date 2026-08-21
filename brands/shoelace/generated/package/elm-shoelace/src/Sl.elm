module Sl exposing
    ( alert, animatedImage, animation, avatar, badge, breadcrumb, breadcrumbItem, button, buttonGroup, card, carousel, carouselItem, checkbox, colorPicker, copyButton, details, dialog, divider, drawer, dropdown, formatBytes, formatDate, formatNumber, icon, iconButton, imageComparer, include, input, menu, menuItem, menuLabel, mutationObserver, option, popup, progressBar, progressRing, qrCode, radio, radioButton, radioGroup, range, rating, relativeTime, resizeObserver, select, skeleton, spinner, splitPanel, switch, tab, tabGroup, tabPanel, tag, textarea, tooltip, tree, treeItem, visuallyHidden
    , text
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId
    )

{-| The general surface: every component constructor in the elm/html call
shape, one import. Signatures reference each component's aliases — reach for
`Sl.<Component>` when you want the strict per-component surface (required
content, builder, narrowed values), and `Sl.Attributes` / `Sl.Events` /
`Sl.Values` for the shared vocabulary.

`toHtml` is the render bridge to `elm/html`.

The `slot<Name>` placers assign a child element to a named slot in any
component that accepts it. Admittance is open (broad row) — wrong-kind
placements are caught by `Cem.ValidSlotKind` (elm-review).

@docs alert, animatedImage, animation, avatar, badge, breadcrumb, breadcrumbItem, button, buttonGroup, card, carousel, carouselItem, checkbox, colorPicker, copyButton, details, dialog, divider, drawer, dropdown, formatBytes, formatDate, formatNumber, icon, iconButton, imageComparer, include, input, menu, menuItem, menuLabel, mutationObserver, option, popup, progressBar, progressRing, qrCode, radio, radioButton, radioGroup, range, rating, relativeTime, resizeObserver, select, skeleton, spinner, splitPanel, switch, tab, tabGroup, tabPanel, tag, textarea, tooltip, tree, treeItem, visuallyHidden
@docs text
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared)
import HtmlIr.Node
import Sl.Internal.Types.Alert
import Sl.Internal.Types.AnimatedImage
import Sl.Internal.Types.Animation
import Sl.Internal.Types.Avatar
import Sl.Internal.Types.Badge
import Sl.Internal.Types.Breadcrumb
import Sl.Internal.Types.BreadcrumbItem
import Sl.Internal.Types.Button
import Sl.Internal.Types.ButtonGroup
import Sl.Internal.Types.Card
import Sl.Internal.Types.Carousel
import Sl.Internal.Types.CarouselItem
import Sl.Internal.Types.Checkbox
import Sl.Internal.Types.ColorPicker
import Sl.Internal.Types.CopyButton
import Sl.Internal.Types.Details
import Sl.Internal.Types.Dialog
import Sl.Internal.Types.Divider
import Sl.Internal.Types.Drawer
import Sl.Internal.Types.Dropdown
import Sl.Internal.Types.FormatBytes
import Sl.Internal.Types.FormatDate
import Sl.Internal.Types.FormatNumber
import Sl.Internal.Types.Icon
import Sl.Internal.Types.IconButton
import Sl.Internal.Types.ImageComparer
import Sl.Internal.Types.Include
import Sl.Internal.Types.Input
import Sl.Internal.Types.Menu
import Sl.Internal.Types.MenuItem
import Sl.Internal.Types.MenuLabel
import Sl.Internal.Types.MutationObserver
import Sl.Internal.Types.Option
import Sl.Internal.Types.Popup
import Sl.Internal.Types.ProgressBar
import Sl.Internal.Types.ProgressRing
import Sl.Internal.Types.QrCode
import Sl.Internal.Types.Radio
import Sl.Internal.Types.RadioButton
import Sl.Internal.Types.RadioGroup
import Sl.Internal.Types.Range
import Sl.Internal.Types.Rating
import Sl.Internal.Types.RelativeTime
import Sl.Internal.Types.ResizeObserver
import Sl.Internal.Types.Select
import Sl.Internal.Types.Skeleton
import Sl.Internal.Types.Spinner
import Sl.Internal.Types.SplitPanel
import Sl.Internal.Types.Switch
import Sl.Internal.Types.Tab
import Sl.Internal.Types.TabGroup
import Sl.Internal.Types.TabPanel
import Sl.Internal.Types.Tag
import Sl.Internal.Types.Textarea
import Sl.Internal.Types.Tooltip
import Sl.Internal.Types.Tree
import Sl.Internal.Types.TreeItem
import Sl.Internal.Types.VisuallyHidden


{-| See `Sl.Component.Alert.component`.
-}
alert :
    List (Attr Sl.Internal.Types.Alert.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Alert.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Alert.Is s) admittedBy msg
alert attrs children =
    Ir.fromNode (Ir.node "sl-alert" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.AnimatedImage.component`.
-}
animatedImage :
    List (Attr Sl.Internal.Types.AnimatedImage.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.AnimatedImage.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.AnimatedImage.Is s) admittedBy msg
animatedImage attrs children =
    Ir.fromNode (Ir.node "sl-animated-image" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Animation.component`.
-}
animation :
    List (Attr Sl.Internal.Types.Animation.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Animation.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Animation.Is s) admittedBy msg
animation attrs children =
    Ir.fromNode (Ir.node "sl-animation" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Avatar.component`.
-}
avatar :
    List (Attr Sl.Internal.Types.Avatar.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Avatar.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Avatar.Is s) admittedBy msg
avatar attrs children =
    Ir.fromNode (Ir.node "sl-avatar" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Badge.component`.
-}
badge :
    List (Attr Sl.Internal.Types.Badge.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Badge.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Badge.Is s) admittedBy msg
badge attrs children =
    Ir.fromNode (Ir.node "sl-badge" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Breadcrumb.component`.
-}
breadcrumb :
    List (Attr Sl.Internal.Types.Breadcrumb.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Breadcrumb.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Breadcrumb.Is s) admittedBy msg
breadcrumb attrs children =
    Ir.fromNode (Ir.node "sl-breadcrumb" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.BreadcrumbItem.component`.
-}
breadcrumbItem :
    List (Attr Sl.Internal.Types.BreadcrumbItem.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.BreadcrumbItem.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.BreadcrumbItem.Is s) admittedBy msg
breadcrumbItem attrs children =
    Ir.fromNode (Ir.node "sl-breadcrumb-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Button.component`.
-}
button :
    List (Attr Sl.Internal.Types.Button.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Button.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Button.Is s) admittedBy msg
button attrs children =
    Ir.fromNode (Ir.node "sl-button" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.ButtonGroup.component`.
-}
buttonGroup :
    List (Attr Sl.Internal.Types.ButtonGroup.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.ButtonGroup.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.ButtonGroup.Is s) admittedBy msg
buttonGroup attrs children =
    Ir.fromNode (Ir.node "sl-button-group" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Card.component`.
-}
card :
    List (Attr Sl.Internal.Types.Card.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Card.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Card.Is s) admittedBy msg
card attrs children =
    Ir.fromNode (Ir.node "sl-card" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Carousel.component`.
-}
carousel :
    List (Attr Sl.Internal.Types.Carousel.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Carousel.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Carousel.Is s) admittedBy msg
carousel attrs children =
    Ir.fromNode (Ir.node "sl-carousel" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.CarouselItem.component`.
-}
carouselItem :
    List (Attr Sl.Internal.Types.CarouselItem.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.CarouselItem.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.CarouselItem.Is s) admittedBy msg
carouselItem attrs children =
    Ir.fromNode (Ir.node "sl-carousel-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Checkbox.component`.
-}
checkbox :
    List (Attr Sl.Internal.Types.Checkbox.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Checkbox.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Checkbox.Is s) admittedBy msg
checkbox attrs children =
    Ir.fromNode (Ir.node "sl-checkbox" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.ColorPicker.component`.
-}
colorPicker :
    List (Attr Sl.Internal.Types.ColorPicker.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.ColorPicker.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.ColorPicker.Is s) admittedBy msg
colorPicker attrs children =
    Ir.fromNode (Ir.node "sl-color-picker" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.CopyButton.component`.
-}
copyButton :
    List (Attr Sl.Internal.Types.CopyButton.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.CopyButton.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.CopyButton.Is s) admittedBy msg
copyButton attrs children =
    Ir.fromNode (Ir.node "sl-copy-button" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Details.component`.
-}
details :
    List (Attr Sl.Internal.Types.Details.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Details.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Details.Is s) admittedBy msg
details attrs children =
    Ir.fromNode (Ir.node "sl-details" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Dialog.component`.
-}
dialog :
    List (Attr Sl.Internal.Types.Dialog.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Dialog.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Dialog.Is s) admittedBy msg
dialog attrs children =
    Ir.fromNode (Ir.node "sl-dialog" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Divider.component`.
-}
divider :
    List (Attr Sl.Internal.Types.Divider.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Divider.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Divider.Is s) admittedBy msg
divider attrs children =
    Ir.fromNode (Ir.node "sl-divider" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Drawer.component`.
-}
drawer :
    List (Attr Sl.Internal.Types.Drawer.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Drawer.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Drawer.Is s) admittedBy msg
drawer attrs children =
    Ir.fromNode (Ir.node "sl-drawer" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Dropdown.component`.
-}
dropdown :
    List (Attr Sl.Internal.Types.Dropdown.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Dropdown.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Dropdown.Is s) admittedBy msg
dropdown attrs children =
    Ir.fromNode (Ir.node "sl-dropdown" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.FormatBytes.component`.
-}
formatBytes :
    List (Attr Sl.Internal.Types.FormatBytes.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.FormatBytes.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.FormatBytes.Is s) admittedBy msg
formatBytes attrs children =
    Ir.fromNode (Ir.node "sl-format-bytes" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.FormatDate.component`.
-}
formatDate :
    List (Attr Sl.Internal.Types.FormatDate.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.FormatDate.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.FormatDate.Is s) admittedBy msg
formatDate attrs children =
    Ir.fromNode (Ir.node "sl-format-date" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.FormatNumber.component`.
-}
formatNumber :
    List (Attr Sl.Internal.Types.FormatNumber.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.FormatNumber.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.FormatNumber.Is s) admittedBy msg
formatNumber attrs children =
    Ir.fromNode (Ir.node "sl-format-number" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Icon.component`.
-}
icon :
    List (Attr Sl.Internal.Types.Icon.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Icon.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Icon.Is s) admittedBy msg
icon attrs children =
    Ir.fromNode (Ir.node "sl-icon" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.IconButton.component`.
-}
iconButton :
    List (Attr Sl.Internal.Types.IconButton.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.IconButton.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.IconButton.Is s) admittedBy msg
iconButton attrs children =
    Ir.fromNode (Ir.node "sl-icon-button" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.ImageComparer.component`.
-}
imageComparer :
    List (Attr Sl.Internal.Types.ImageComparer.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.ImageComparer.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.ImageComparer.Is s) admittedBy msg
imageComparer attrs children =
    Ir.fromNode (Ir.node "sl-image-comparer" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Include.component`.
-}
include :
    List (Attr Sl.Internal.Types.Include.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Include.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Include.Is s) admittedBy msg
include attrs children =
    Ir.fromNode (Ir.node "sl-include" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Input.component`.
-}
input :
    List (Attr Sl.Internal.Types.Input.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Input.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Input.Is s) admittedBy msg
input attrs children =
    Ir.fromNode (Ir.node "sl-input" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Menu.component`.
-}
menu :
    List (Attr Sl.Internal.Types.Menu.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Menu.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Menu.Is s) admittedBy msg
menu attrs children =
    Ir.fromNode (Ir.node "sl-menu" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.MenuItem.component`.
-}
menuItem :
    List (Attr Sl.Internal.Types.MenuItem.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.MenuItem.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.MenuItem.Is s) admittedBy msg
menuItem attrs children =
    Ir.fromNode (Ir.node "sl-menu-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.MenuLabel.component`.
-}
menuLabel :
    List (Attr Sl.Internal.Types.MenuLabel.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.MenuLabel.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.MenuLabel.Is s) admittedBy msg
menuLabel attrs children =
    Ir.fromNode (Ir.node "sl-menu-label" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.MutationObserver.component`.
-}
mutationObserver :
    List (Attr Sl.Internal.Types.MutationObserver.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.MutationObserver.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.MutationObserver.Is s) admittedBy msg
mutationObserver attrs children =
    Ir.fromNode (Ir.node "sl-mutation-observer" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Option.component`.
-}
option :
    List (Attr Sl.Internal.Types.Option.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Option.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Option.Is s) admittedBy msg
option attrs children =
    Ir.fromNode (Ir.node "sl-option" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Popup.component`.
-}
popup :
    List (Attr Sl.Internal.Types.Popup.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Popup.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Popup.Is s) admittedBy msg
popup attrs children =
    Ir.fromNode (Ir.node "sl-popup" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.ProgressBar.component`.
-}
progressBar :
    List (Attr Sl.Internal.Types.ProgressBar.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.ProgressBar.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.ProgressBar.Is s) admittedBy msg
progressBar attrs children =
    Ir.fromNode (Ir.node "sl-progress-bar" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.ProgressRing.component`.
-}
progressRing :
    List (Attr Sl.Internal.Types.ProgressRing.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.ProgressRing.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.ProgressRing.Is s) admittedBy msg
progressRing attrs children =
    Ir.fromNode (Ir.node "sl-progress-ring" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.QrCode.component`.
-}
qrCode :
    List (Attr Sl.Internal.Types.QrCode.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.QrCode.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.QrCode.Is s) admittedBy msg
qrCode attrs children =
    Ir.fromNode (Ir.node "sl-qr-code" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Radio.component`.
-}
radio :
    List (Attr Sl.Internal.Types.Radio.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Radio.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Radio.Is s) admittedBy msg
radio attrs children =
    Ir.fromNode (Ir.node "sl-radio" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.RadioButton.component`.
-}
radioButton :
    List (Attr Sl.Internal.Types.RadioButton.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.RadioButton.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.RadioButton.Is s) admittedBy msg
radioButton attrs children =
    Ir.fromNode (Ir.node "sl-radio-button" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.RadioGroup.component`.
-}
radioGroup :
    List (Attr Sl.Internal.Types.RadioGroup.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.RadioGroup.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.RadioGroup.Is s) admittedBy msg
radioGroup attrs children =
    Ir.fromNode (Ir.node "sl-radio-group" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Range.component`.
-}
range :
    List (Attr Sl.Internal.Types.Range.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Range.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Range.Is s) admittedBy msg
range attrs children =
    Ir.fromNode (Ir.node "sl-range" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Rating.component`.
-}
rating :
    List (Attr Sl.Internal.Types.Rating.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Rating.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Rating.Is s) admittedBy msg
rating attrs children =
    Ir.fromNode (Ir.node "sl-rating" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.RelativeTime.component`.
-}
relativeTime :
    List (Attr Sl.Internal.Types.RelativeTime.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.RelativeTime.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.RelativeTime.Is s) admittedBy msg
relativeTime attrs children =
    Ir.fromNode (Ir.node "sl-relative-time" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.ResizeObserver.component`.
-}
resizeObserver :
    List (Attr Sl.Internal.Types.ResizeObserver.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.ResizeObserver.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.ResizeObserver.Is s) admittedBy msg
resizeObserver attrs children =
    Ir.fromNode (Ir.node "sl-resize-observer" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Select.component`.
-}
select :
    List (Attr Sl.Internal.Types.Select.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Select.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Select.Is s) admittedBy msg
select attrs children =
    Ir.fromNode (Ir.node "sl-select" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Skeleton.component`.
-}
skeleton :
    List (Attr Sl.Internal.Types.Skeleton.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Skeleton.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Skeleton.Is s) admittedBy msg
skeleton attrs children =
    Ir.fromNode (Ir.node "sl-skeleton" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Spinner.component`.
-}
spinner :
    List (Attr Sl.Internal.Types.Spinner.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Spinner.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Spinner.Is s) admittedBy msg
spinner attrs children =
    Ir.fromNode (Ir.node "sl-spinner" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.SplitPanel.component`.
-}
splitPanel :
    List (Attr Sl.Internal.Types.SplitPanel.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.SplitPanel.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.SplitPanel.Is s) admittedBy msg
splitPanel attrs children =
    Ir.fromNode (Ir.node "sl-split-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Switch.component`.
-}
switch :
    List (Attr Sl.Internal.Types.Switch.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Switch.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Switch.Is s) admittedBy msg
switch attrs children =
    Ir.fromNode (Ir.node "sl-switch" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Tab.component`.
-}
tab :
    List (Attr Sl.Internal.Types.Tab.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Tab.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Tab.Is s) admittedBy msg
tab attrs children =
    Ir.fromNode (Ir.node "sl-tab" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.TabGroup.component`.
-}
tabGroup :
    List (Attr Sl.Internal.Types.TabGroup.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.TabGroup.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.TabGroup.Is s) admittedBy msg
tabGroup attrs children =
    Ir.fromNode (Ir.node "sl-tab-group" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.TabPanel.component`.
-}
tabPanel :
    List (Attr Sl.Internal.Types.TabPanel.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.TabPanel.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.TabPanel.Is s) admittedBy msg
tabPanel attrs children =
    Ir.fromNode (Ir.node "sl-tab-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Tag.component`.
-}
tag :
    List (Attr Sl.Internal.Types.Tag.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Tag.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Tag.Is s) admittedBy msg
tag attrs children =
    Ir.fromNode (Ir.node "sl-tag" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Textarea.component`.
-}
textarea :
    List (Attr Sl.Internal.Types.Textarea.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Textarea.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Textarea.Is s) admittedBy msg
textarea attrs children =
    Ir.fromNode (Ir.node "sl-textarea" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Tooltip.component`.
-}
tooltip :
    List (Attr Sl.Internal.Types.Tooltip.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Tooltip.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Tooltip.Is s) admittedBy msg
tooltip attrs children =
    Ir.fromNode (Ir.node "sl-tooltip" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.Tree.component`.
-}
tree :
    List (Attr Sl.Internal.Types.Tree.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.Tree.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.Tree.Is s) admittedBy msg
tree attrs children =
    Ir.fromNode (Ir.node "sl-tree" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.TreeItem.component`.
-}
treeItem :
    List (Attr Sl.Internal.Types.TreeItem.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.TreeItem.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.TreeItem.Is s) admittedBy msg
treeItem attrs children =
    Ir.fromNode (Ir.node "sl-tree-item" attrs (List.map HtmlIr.Element.toNode children))


{-| See `Sl.Component.VisuallyHidden.component`.
-}
visuallyHidden :
    List (Attr Sl.Internal.Types.VisuallyHidden.Attrs msg)
    -> List (Element childAccepts (Sl.Internal.Types.VisuallyHidden.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Internal.Types.VisuallyHidden.Is s) admittedBy msg
visuallyHidden attrs children =
    Ir.fromNode (Ir.node "sl-visually-hidden" attrs (List.map HtmlIr.Element.toNode children))


{-| The shared text atom — admissible into any library's opted-in slot.
-}
text : String -> Element { s | sharedText : Shared } admittedBy msg
text value_ =
    Ir.fromNode (Ir.text value_)


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
