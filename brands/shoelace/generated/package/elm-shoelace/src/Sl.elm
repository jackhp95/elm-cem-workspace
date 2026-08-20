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
import Sl.Component.Alert
import Sl.Component.AnimatedImage
import Sl.Component.Animation
import Sl.Component.Avatar
import Sl.Component.Badge
import Sl.Component.Breadcrumb
import Sl.Component.BreadcrumbItem
import Sl.Component.Button
import Sl.Component.ButtonGroup
import Sl.Component.Card
import Sl.Component.Carousel
import Sl.Component.CarouselItem
import Sl.Component.Checkbox
import Sl.Component.ColorPicker
import Sl.Component.CopyButton
import Sl.Component.Details
import Sl.Component.Dialog
import Sl.Component.Divider
import Sl.Component.Drawer
import Sl.Component.Dropdown
import Sl.Component.FormatBytes
import Sl.Component.FormatDate
import Sl.Component.FormatNumber
import Sl.Component.Icon
import Sl.Component.IconButton
import Sl.Component.ImageComparer
import Sl.Component.Include
import Sl.Component.Input
import Sl.Component.Menu
import Sl.Component.MenuItem
import Sl.Component.MenuLabel
import Sl.Component.MutationObserver
import Sl.Component.Option
import Sl.Component.Popup
import Sl.Component.ProgressBar
import Sl.Component.ProgressRing
import Sl.Component.QrCode
import Sl.Component.Radio
import Sl.Component.RadioButton
import Sl.Component.RadioGroup
import Sl.Component.Range
import Sl.Component.Rating
import Sl.Component.RelativeTime
import Sl.Component.ResizeObserver
import Sl.Component.Select
import Sl.Component.Skeleton
import Sl.Component.Spinner
import Sl.Component.SplitPanel
import Sl.Component.Switch
import Sl.Component.Tab
import Sl.Component.TabGroup
import Sl.Component.TabPanel
import Sl.Component.Tag
import Sl.Component.Textarea
import Sl.Component.Tooltip
import Sl.Component.Tree
import Sl.Component.TreeItem
import Sl.Component.VisuallyHidden


{-| See `Sl.Component.Alert.component`.
-}
alert :
    List (Attr Sl.Component.Alert.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Alert.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Alert.Is s) admittedBy msg
alert =
    Sl.Component.Alert.component


{-| See `Sl.Component.AnimatedImage.component`.
-}
animatedImage :
    List (Attr Sl.Component.AnimatedImage.Attrs msg)
    -> List (Element childAccepts (Sl.Component.AnimatedImage.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.AnimatedImage.Is s) admittedBy msg
animatedImage =
    Sl.Component.AnimatedImage.component


{-| See `Sl.Component.Animation.component`.
-}
animation :
    List (Attr Sl.Component.Animation.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Animation.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Animation.Is s) admittedBy msg
animation =
    Sl.Component.Animation.component


{-| See `Sl.Component.Avatar.component`.
-}
avatar :
    List (Attr Sl.Component.Avatar.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Avatar.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Avatar.Is s) admittedBy msg
avatar =
    Sl.Component.Avatar.component


{-| See `Sl.Component.Badge.component`.
-}
badge :
    List (Attr Sl.Component.Badge.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Badge.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Badge.Is s) admittedBy msg
badge =
    Sl.Component.Badge.component


{-| See `Sl.Component.Breadcrumb.component`.
-}
breadcrumb :
    List (Attr Sl.Component.Breadcrumb.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Breadcrumb.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Breadcrumb.Is s) admittedBy msg
breadcrumb =
    Sl.Component.Breadcrumb.component


{-| See `Sl.Component.BreadcrumbItem.component`.
-}
breadcrumbItem :
    List (Attr Sl.Component.BreadcrumbItem.Attrs msg)
    -> List (Element childAccepts (Sl.Component.BreadcrumbItem.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.BreadcrumbItem.Is s) admittedBy msg
breadcrumbItem =
    Sl.Component.BreadcrumbItem.component


{-| See `Sl.Component.Button.component`.
-}
button :
    List (Attr Sl.Component.Button.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Button.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Button.Is s) admittedBy msg
button =
    Sl.Component.Button.component


{-| See `Sl.Component.ButtonGroup.component`.
-}
buttonGroup :
    List (Attr Sl.Component.ButtonGroup.Attrs msg)
    -> List (Element childAccepts (Sl.Component.ButtonGroup.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.ButtonGroup.Is s) admittedBy msg
buttonGroup =
    Sl.Component.ButtonGroup.component


{-| See `Sl.Component.Card.component`.
-}
card :
    List (Attr Sl.Component.Card.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Card.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Card.Is s) admittedBy msg
card =
    Sl.Component.Card.component


{-| See `Sl.Component.Carousel.component`.
-}
carousel :
    List (Attr Sl.Component.Carousel.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Carousel.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Carousel.Is s) admittedBy msg
carousel =
    Sl.Component.Carousel.component


{-| See `Sl.Component.CarouselItem.component`.
-}
carouselItem :
    List (Attr Sl.Component.CarouselItem.Attrs msg)
    -> List (Element childAccepts (Sl.Component.CarouselItem.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.CarouselItem.Is s) admittedBy msg
carouselItem =
    Sl.Component.CarouselItem.component


{-| See `Sl.Component.Checkbox.component`.
-}
checkbox :
    List (Attr Sl.Component.Checkbox.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Checkbox.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Checkbox.Is s) admittedBy msg
checkbox =
    Sl.Component.Checkbox.component


{-| See `Sl.Component.ColorPicker.component`.
-}
colorPicker :
    List (Attr Sl.Component.ColorPicker.Attrs msg)
    -> List (Element childAccepts (Sl.Component.ColorPicker.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.ColorPicker.Is s) admittedBy msg
colorPicker =
    Sl.Component.ColorPicker.component


{-| See `Sl.Component.CopyButton.component`.
-}
copyButton :
    List (Attr Sl.Component.CopyButton.Attrs msg)
    -> List (Element childAccepts (Sl.Component.CopyButton.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.CopyButton.Is s) admittedBy msg
copyButton =
    Sl.Component.CopyButton.component


{-| See `Sl.Component.Details.component`.
-}
details :
    List (Attr Sl.Component.Details.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Details.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Details.Is s) admittedBy msg
details =
    Sl.Component.Details.component


{-| See `Sl.Component.Dialog.component`.
-}
dialog :
    List (Attr Sl.Component.Dialog.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Dialog.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Dialog.Is s) admittedBy msg
dialog =
    Sl.Component.Dialog.component


{-| See `Sl.Component.Divider.component`.
-}
divider :
    List (Attr Sl.Component.Divider.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Divider.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Divider.Is s) admittedBy msg
divider =
    Sl.Component.Divider.component


{-| See `Sl.Component.Drawer.component`.
-}
drawer :
    List (Attr Sl.Component.Drawer.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Drawer.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Drawer.Is s) admittedBy msg
drawer =
    Sl.Component.Drawer.component


{-| See `Sl.Component.Dropdown.component`.
-}
dropdown :
    List (Attr Sl.Component.Dropdown.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Dropdown.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Dropdown.Is s) admittedBy msg
dropdown =
    Sl.Component.Dropdown.component


{-| See `Sl.Component.FormatBytes.component`.
-}
formatBytes :
    List (Attr Sl.Component.FormatBytes.Attrs msg)
    -> List (Element childAccepts (Sl.Component.FormatBytes.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.FormatBytes.Is s) admittedBy msg
formatBytes =
    Sl.Component.FormatBytes.component


{-| See `Sl.Component.FormatDate.component`.
-}
formatDate :
    List (Attr Sl.Component.FormatDate.Attrs msg)
    -> List (Element childAccepts (Sl.Component.FormatDate.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.FormatDate.Is s) admittedBy msg
formatDate =
    Sl.Component.FormatDate.component


{-| See `Sl.Component.FormatNumber.component`.
-}
formatNumber :
    List (Attr Sl.Component.FormatNumber.Attrs msg)
    -> List (Element childAccepts (Sl.Component.FormatNumber.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.FormatNumber.Is s) admittedBy msg
formatNumber =
    Sl.Component.FormatNumber.component


{-| See `Sl.Component.Icon.component`.
-}
icon :
    List (Attr Sl.Component.Icon.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Icon.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Icon.Is s) admittedBy msg
icon =
    Sl.Component.Icon.component


{-| See `Sl.Component.IconButton.component`.
-}
iconButton :
    List (Attr Sl.Component.IconButton.Attrs msg)
    -> List (Element childAccepts (Sl.Component.IconButton.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.IconButton.Is s) admittedBy msg
iconButton =
    Sl.Component.IconButton.component


{-| See `Sl.Component.ImageComparer.component`.
-}
imageComparer :
    List (Attr Sl.Component.ImageComparer.Attrs msg)
    -> List (Element childAccepts (Sl.Component.ImageComparer.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.ImageComparer.Is s) admittedBy msg
imageComparer =
    Sl.Component.ImageComparer.component


{-| See `Sl.Component.Include.component`.
-}
include :
    List (Attr Sl.Component.Include.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Include.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Include.Is s) admittedBy msg
include =
    Sl.Component.Include.component


{-| See `Sl.Component.Input.component`.
-}
input :
    List (Attr Sl.Component.Input.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Input.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Input.Is s) admittedBy msg
input =
    Sl.Component.Input.component


{-| See `Sl.Component.Menu.component`.
-}
menu :
    List (Attr Sl.Component.Menu.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Menu.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Menu.Is s) admittedBy msg
menu =
    Sl.Component.Menu.component


{-| See `Sl.Component.MenuItem.component`.
-}
menuItem :
    List (Attr Sl.Component.MenuItem.Attrs msg)
    -> List (Element childAccepts (Sl.Component.MenuItem.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.MenuItem.Is s) admittedBy msg
menuItem =
    Sl.Component.MenuItem.component


{-| See `Sl.Component.MenuLabel.component`.
-}
menuLabel :
    List (Attr Sl.Component.MenuLabel.Attrs msg)
    -> List (Element childAccepts (Sl.Component.MenuLabel.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.MenuLabel.Is s) admittedBy msg
menuLabel =
    Sl.Component.MenuLabel.component


{-| See `Sl.Component.MutationObserver.component`.
-}
mutationObserver :
    List (Attr Sl.Component.MutationObserver.Attrs msg)
    -> List (Element childAccepts (Sl.Component.MutationObserver.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.MutationObserver.Is s) admittedBy msg
mutationObserver =
    Sl.Component.MutationObserver.component


{-| See `Sl.Component.Option.component`.
-}
option :
    List (Attr Sl.Component.Option.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Option.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Option.Is s) admittedBy msg
option =
    Sl.Component.Option.component


{-| See `Sl.Component.Popup.component`.
-}
popup :
    List (Attr Sl.Component.Popup.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Popup.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Popup.Is s) admittedBy msg
popup =
    Sl.Component.Popup.component


{-| See `Sl.Component.ProgressBar.component`.
-}
progressBar :
    List (Attr Sl.Component.ProgressBar.Attrs msg)
    -> List (Element childAccepts (Sl.Component.ProgressBar.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.ProgressBar.Is s) admittedBy msg
progressBar =
    Sl.Component.ProgressBar.component


{-| See `Sl.Component.ProgressRing.component`.
-}
progressRing :
    List (Attr Sl.Component.ProgressRing.Attrs msg)
    -> List (Element childAccepts (Sl.Component.ProgressRing.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.ProgressRing.Is s) admittedBy msg
progressRing =
    Sl.Component.ProgressRing.component


{-| See `Sl.Component.QrCode.component`.
-}
qrCode :
    List (Attr Sl.Component.QrCode.Attrs msg)
    -> List (Element childAccepts (Sl.Component.QrCode.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.QrCode.Is s) admittedBy msg
qrCode =
    Sl.Component.QrCode.component


{-| See `Sl.Component.Radio.component`.
-}
radio :
    List (Attr Sl.Component.Radio.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Radio.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Radio.Is s) admittedBy msg
radio =
    Sl.Component.Radio.component


{-| See `Sl.Component.RadioButton.component`.
-}
radioButton :
    List (Attr Sl.Component.RadioButton.Attrs msg)
    -> List (Element childAccepts (Sl.Component.RadioButton.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.RadioButton.Is s) admittedBy msg
radioButton =
    Sl.Component.RadioButton.component


{-| See `Sl.Component.RadioGroup.component`.
-}
radioGroup :
    List (Attr Sl.Component.RadioGroup.Attrs msg)
    -> List (Element childAccepts (Sl.Component.RadioGroup.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.RadioGroup.Is s) admittedBy msg
radioGroup =
    Sl.Component.RadioGroup.component


{-| See `Sl.Component.Range.component`.
-}
range :
    List (Attr Sl.Component.Range.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Range.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Range.Is s) admittedBy msg
range =
    Sl.Component.Range.component


{-| See `Sl.Component.Rating.component`.
-}
rating :
    List (Attr Sl.Component.Rating.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Rating.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Rating.Is s) admittedBy msg
rating =
    Sl.Component.Rating.component


{-| See `Sl.Component.RelativeTime.component`.
-}
relativeTime :
    List (Attr Sl.Component.RelativeTime.Attrs msg)
    -> List (Element childAccepts (Sl.Component.RelativeTime.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.RelativeTime.Is s) admittedBy msg
relativeTime =
    Sl.Component.RelativeTime.component


{-| See `Sl.Component.ResizeObserver.component`.
-}
resizeObserver :
    List (Attr Sl.Component.ResizeObserver.Attrs msg)
    -> List (Element childAccepts (Sl.Component.ResizeObserver.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.ResizeObserver.Is s) admittedBy msg
resizeObserver =
    Sl.Component.ResizeObserver.component


{-| See `Sl.Component.Select.component`.
-}
select :
    List (Attr Sl.Component.Select.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Select.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Select.Is s) admittedBy msg
select =
    Sl.Component.Select.component


{-| See `Sl.Component.Skeleton.component`.
-}
skeleton :
    List (Attr Sl.Component.Skeleton.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Skeleton.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Skeleton.Is s) admittedBy msg
skeleton =
    Sl.Component.Skeleton.component


{-| See `Sl.Component.Spinner.component`.
-}
spinner :
    List (Attr Sl.Component.Spinner.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Spinner.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Spinner.Is s) admittedBy msg
spinner =
    Sl.Component.Spinner.component


{-| See `Sl.Component.SplitPanel.component`.
-}
splitPanel :
    List (Attr Sl.Component.SplitPanel.Attrs msg)
    -> List (Element childAccepts (Sl.Component.SplitPanel.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.SplitPanel.Is s) admittedBy msg
splitPanel =
    Sl.Component.SplitPanel.component


{-| See `Sl.Component.Switch.component`.
-}
switch :
    List (Attr Sl.Component.Switch.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Switch.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Switch.Is s) admittedBy msg
switch =
    Sl.Component.Switch.component


{-| See `Sl.Component.Tab.component`.
-}
tab :
    List (Attr Sl.Component.Tab.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Tab.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Tab.Is s) admittedBy msg
tab =
    Sl.Component.Tab.component


{-| See `Sl.Component.TabGroup.component`.
-}
tabGroup :
    List (Attr Sl.Component.TabGroup.Attrs msg)
    -> List (Element childAccepts (Sl.Component.TabGroup.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.TabGroup.Is s) admittedBy msg
tabGroup =
    Sl.Component.TabGroup.component


{-| See `Sl.Component.TabPanel.component`.
-}
tabPanel :
    List (Attr Sl.Component.TabPanel.Attrs msg)
    -> List (Element childAccepts (Sl.Component.TabPanel.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.TabPanel.Is s) admittedBy msg
tabPanel =
    Sl.Component.TabPanel.component


{-| See `Sl.Component.Tag.component`.
-}
tag :
    List (Attr Sl.Component.Tag.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Tag.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Tag.Is s) admittedBy msg
tag =
    Sl.Component.Tag.component


{-| See `Sl.Component.Textarea.component`.
-}
textarea :
    List (Attr Sl.Component.Textarea.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Textarea.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Textarea.Is s) admittedBy msg
textarea =
    Sl.Component.Textarea.component


{-| See `Sl.Component.Tooltip.component`.
-}
tooltip :
    List (Attr Sl.Component.Tooltip.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Tooltip.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Tooltip.Is s) admittedBy msg
tooltip =
    Sl.Component.Tooltip.component


{-| See `Sl.Component.Tree.component`.
-}
tree :
    List (Attr Sl.Component.Tree.Attrs msg)
    -> List (Element childAccepts (Sl.Component.Tree.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.Tree.Is s) admittedBy msg
tree =
    Sl.Component.Tree.component


{-| See `Sl.Component.TreeItem.component`.
-}
treeItem :
    List (Attr Sl.Component.TreeItem.Attrs msg)
    -> List (Element childAccepts (Sl.Component.TreeItem.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.TreeItem.Is s) admittedBy msg
treeItem =
    Sl.Component.TreeItem.component


{-| See `Sl.Component.VisuallyHidden.component`.
-}
visuallyHidden :
    List (Attr Sl.Component.VisuallyHidden.Attrs msg)
    -> List (Element childAccepts (Sl.Component.VisuallyHidden.ChildAdmittedBy childAdm) msg)
    -> Element (Sl.Component.VisuallyHidden.Is s) admittedBy msg
visuallyHidden =
    Sl.Component.VisuallyHidden.component


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
