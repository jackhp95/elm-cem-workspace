module Sl.Html exposing
    ( alert, animatedImage, animation, avatar, badge, breadcrumb, breadcrumbItem, button, buttonGroup, card, carousel, carouselItem, checkbox, colorPicker, copyButton, details, dialog, divider, drawer, dropdown, formatBytes, formatDate, formatNumber, icon, iconButton, imageComparer, include, input, menu, menuItem, menuLabel, mutationObserver, option, popup, progressBar, progressRing, qrCode, radio, radioButton, radioGroup, range, rating, relativeTime, resizeObserver, select, skeleton, spinner, splitPanel, switch, tab, tabGroup, tabPanel, tag, textarea, tooltip, tree, treeItem, visuallyHidden
    , Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId
    )

{-| The loose, elm/html-like producer layer: one open-rowed constructor
per element, each owning `Ir.node "<tag>"`. This is the foundation the
`Sl-html` package exposes; every rich `Sl.<Component>` imports
its producer here and re-exposes it under a tightened signature. Depends
only on the IR substrate — no component module is imported.

The substrate types are re-exported here too, so a consumer of the
published package can write type annotations without importing
`HtmlIr.*` directly.

@docs alert, animatedImage, animation, avatar, badge, breadcrumb, breadcrumbItem, button, buttonGroup, card, carousel, carouselItem, checkbox, colorPicker, copyButton, details, dialog, divider, drawer, dropdown, formatBytes, formatDate, formatNumber, icon, iconButton, imageComparer, include, input, menu, menuItem, menuLabel, mutationObserver, option, popup, progressBar, progressRing, qrCode, radio, radioButton, radioGroup, range, rating, relativeTime, resizeObserver, select, skeleton, spinner, splitPanel, switch, tab, tabGroup, tabPanel, tag, textarea, tooltip, tree, treeItem, visuallyHidden
@docs Element, Attr, Node, toHtml, toNode, mapMsg, mapNode, key, lazy, lazy2, lazy3, lazy4, lazy5, lazy6, lazy7, lazy8, addClass, attrIf, when, testId

-}

import Html
import HtmlIr.Attribute
import HtmlIr.Element
import HtmlIr.Internal as Ir
import HtmlIr.Node


{-| The loose `sl-alert` producer — open attribute/child rows, elm/html call
shape. `Sl.Alert` tightens it (closed rows, slot admittance, narrowed values).
-}
alert :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
alert attrs children =
    Ir.fromNode (Ir.node "sl-alert" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-animated-image` producer — open attribute/child rows, elm/html call
shape. `Sl.AnimatedImage` tightens it (closed rows, slot admittance, narrowed values).
-}
animatedImage :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
animatedImage attrs children =
    Ir.fromNode (Ir.node "sl-animated-image" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-animation` producer — open attribute/child rows, elm/html call
shape. `Sl.Animation` tightens it (closed rows, slot admittance, narrowed values).
-}
animation :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
animation attrs children =
    Ir.fromNode (Ir.node "sl-animation" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-avatar` producer — open attribute/child rows, elm/html call
shape. `Sl.Avatar` tightens it (closed rows, slot admittance, narrowed values).
-}
avatar :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
avatar attrs children =
    Ir.fromNode (Ir.node "sl-avatar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-badge` producer — open attribute/child rows, elm/html call
shape. `Sl.Badge` tightens it (closed rows, slot admittance, narrowed values).
-}
badge :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
badge attrs children =
    Ir.fromNode (Ir.node "sl-badge" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-breadcrumb` producer — open attribute/child rows, elm/html call
shape. `Sl.Breadcrumb` tightens it (closed rows, slot admittance, narrowed values).
-}
breadcrumb :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
breadcrumb attrs children =
    Ir.fromNode (Ir.node "sl-breadcrumb" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-breadcrumb-item` producer — open attribute/child rows, elm/html call
shape. `Sl.BreadcrumbItem` tightens it (closed rows, slot admittance, narrowed values).
-}
breadcrumbItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
breadcrumbItem attrs children =
    Ir.fromNode (Ir.node "sl-breadcrumb-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-button` producer — open attribute/child rows, elm/html call
shape. `Sl.Button` tightens it (closed rows, slot admittance, narrowed values).
-}
button :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
button attrs children =
    Ir.fromNode (Ir.node "sl-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-button-group` producer — open attribute/child rows, elm/html call
shape. `Sl.ButtonGroup` tightens it (closed rows, slot admittance, narrowed values).
-}
buttonGroup :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
buttonGroup attrs children =
    Ir.fromNode (Ir.node "sl-button-group" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-card` producer — open attribute/child rows, elm/html call
shape. `Sl.Card` tightens it (closed rows, slot admittance, narrowed values).
-}
card :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
card attrs children =
    Ir.fromNode (Ir.node "sl-card" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-carousel` producer — open attribute/child rows, elm/html call
shape. `Sl.Carousel` tightens it (closed rows, slot admittance, narrowed values).
-}
carousel :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
carousel attrs children =
    Ir.fromNode (Ir.node "sl-carousel" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-carousel-item` producer — open attribute/child rows, elm/html call
shape. `Sl.CarouselItem` tightens it (closed rows, slot admittance, narrowed values).
-}
carouselItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
carouselItem attrs children =
    Ir.fromNode (Ir.node "sl-carousel-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-checkbox` producer — open attribute/child rows, elm/html call
shape. `Sl.Checkbox` tightens it (closed rows, slot admittance, narrowed values).
-}
checkbox :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
checkbox attrs children =
    Ir.fromNode (Ir.node "sl-checkbox" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-color-picker` producer — open attribute/child rows, elm/html call
shape. `Sl.ColorPicker` tightens it (closed rows, slot admittance, narrowed values).
-}
colorPicker :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
colorPicker attrs children =
    Ir.fromNode (Ir.node "sl-color-picker" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-copy-button` producer — open attribute/child rows, elm/html call
shape. `Sl.CopyButton` tightens it (closed rows, slot admittance, narrowed values).
-}
copyButton :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
copyButton attrs children =
    Ir.fromNode (Ir.node "sl-copy-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-details` producer — open attribute/child rows, elm/html call
shape. `Sl.Details` tightens it (closed rows, slot admittance, narrowed values).
-}
details :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
details attrs children =
    Ir.fromNode (Ir.node "sl-details" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-dialog` producer — open attribute/child rows, elm/html call
shape. `Sl.Dialog` tightens it (closed rows, slot admittance, narrowed values).
-}
dialog :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
dialog attrs children =
    Ir.fromNode (Ir.node "sl-dialog" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-divider` producer — open attribute/child rows, elm/html call
shape. `Sl.Divider` tightens it (closed rows, slot admittance, narrowed values).
-}
divider :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
divider attrs children =
    Ir.fromNode (Ir.node "sl-divider" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-drawer` producer — open attribute/child rows, elm/html call
shape. `Sl.Drawer` tightens it (closed rows, slot admittance, narrowed values).
-}
drawer :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
drawer attrs children =
    Ir.fromNode (Ir.node "sl-drawer" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-dropdown` producer — open attribute/child rows, elm/html call
shape. `Sl.Dropdown` tightens it (closed rows, slot admittance, narrowed values).
-}
dropdown :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
dropdown attrs children =
    Ir.fromNode (Ir.node "sl-dropdown" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-format-bytes` producer — open attribute/child rows, elm/html call
shape. `Sl.FormatBytes` tightens it (closed rows, slot admittance, narrowed values).
-}
formatBytes :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
formatBytes attrs children =
    Ir.fromNode (Ir.node "sl-format-bytes" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-format-date` producer — open attribute/child rows, elm/html call
shape. `Sl.FormatDate` tightens it (closed rows, slot admittance, narrowed values).
-}
formatDate :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
formatDate attrs children =
    Ir.fromNode (Ir.node "sl-format-date" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-format-number` producer — open attribute/child rows, elm/html call
shape. `Sl.FormatNumber` tightens it (closed rows, slot admittance, narrowed values).
-}
formatNumber :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
formatNumber attrs children =
    Ir.fromNode (Ir.node "sl-format-number" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-icon` producer — open attribute/child rows, elm/html call
shape. `Sl.Icon` tightens it (closed rows, slot admittance, narrowed values).
-}
icon :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
icon attrs children =
    Ir.fromNode (Ir.node "sl-icon" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-icon-button` producer — open attribute/child rows, elm/html call
shape. `Sl.IconButton` tightens it (closed rows, slot admittance, narrowed values).
-}
iconButton :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
iconButton attrs children =
    Ir.fromNode (Ir.node "sl-icon-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-image-comparer` producer — open attribute/child rows, elm/html call
shape. `Sl.ImageComparer` tightens it (closed rows, slot admittance, narrowed values).
-}
imageComparer :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
imageComparer attrs children =
    Ir.fromNode (Ir.node "sl-image-comparer" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-include` producer — open attribute/child rows, elm/html call
shape. `Sl.Include` tightens it (closed rows, slot admittance, narrowed values).
-}
include :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
include attrs children =
    Ir.fromNode (Ir.node "sl-include" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-input` producer — open attribute/child rows, elm/html call
shape. `Sl.Input` tightens it (closed rows, slot admittance, narrowed values).
-}
input :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
input attrs children =
    Ir.fromNode (Ir.node "sl-input" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-menu` producer — open attribute/child rows, elm/html call
shape. `Sl.Menu` tightens it (closed rows, slot admittance, narrowed values).
-}
menu :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
menu attrs children =
    Ir.fromNode (Ir.node "sl-menu" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-menu-item` producer — open attribute/child rows, elm/html call
shape. `Sl.MenuItem` tightens it (closed rows, slot admittance, narrowed values).
-}
menuItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
menuItem attrs children =
    Ir.fromNode (Ir.node "sl-menu-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-menu-label` producer — open attribute/child rows, elm/html call
shape. `Sl.MenuLabel` tightens it (closed rows, slot admittance, narrowed values).
-}
menuLabel :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
menuLabel attrs children =
    Ir.fromNode (Ir.node "sl-menu-label" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-mutation-observer` producer — open attribute/child rows, elm/html call
shape. `Sl.MutationObserver` tightens it (closed rows, slot admittance, narrowed values).
-}
mutationObserver :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
mutationObserver attrs children =
    Ir.fromNode (Ir.node "sl-mutation-observer" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-option` producer — open attribute/child rows, elm/html call
shape. `Sl.Option` tightens it (closed rows, slot admittance, narrowed values).
-}
option :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
option attrs children =
    Ir.fromNode (Ir.node "sl-option" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-popup` producer — open attribute/child rows, elm/html call
shape. `Sl.Popup` tightens it (closed rows, slot admittance, narrowed values).
-}
popup :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
popup attrs children =
    Ir.fromNode (Ir.node "sl-popup" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-progress-bar` producer — open attribute/child rows, elm/html call
shape. `Sl.ProgressBar` tightens it (closed rows, slot admittance, narrowed values).
-}
progressBar :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
progressBar attrs children =
    Ir.fromNode (Ir.node "sl-progress-bar" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-progress-ring` producer — open attribute/child rows, elm/html call
shape. `Sl.ProgressRing` tightens it (closed rows, slot admittance, narrowed values).
-}
progressRing :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
progressRing attrs children =
    Ir.fromNode (Ir.node "sl-progress-ring" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-qr-code` producer — open attribute/child rows, elm/html call
shape. `Sl.QrCode` tightens it (closed rows, slot admittance, narrowed values).
-}
qrCode :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
qrCode attrs children =
    Ir.fromNode (Ir.node "sl-qr-code" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-radio` producer — open attribute/child rows, elm/html call
shape. `Sl.Radio` tightens it (closed rows, slot admittance, narrowed values).
-}
radio :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
radio attrs children =
    Ir.fromNode (Ir.node "sl-radio" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-radio-button` producer — open attribute/child rows, elm/html call
shape. `Sl.RadioButton` tightens it (closed rows, slot admittance, narrowed values).
-}
radioButton :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
radioButton attrs children =
    Ir.fromNode (Ir.node "sl-radio-button" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-radio-group` producer — open attribute/child rows, elm/html call
shape. `Sl.RadioGroup` tightens it (closed rows, slot admittance, narrowed values).
-}
radioGroup :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
radioGroup attrs children =
    Ir.fromNode (Ir.node "sl-radio-group" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-range` producer — open attribute/child rows, elm/html call
shape. `Sl.Range` tightens it (closed rows, slot admittance, narrowed values).
-}
range :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
range attrs children =
    Ir.fromNode (Ir.node "sl-range" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-rating` producer — open attribute/child rows, elm/html call
shape. `Sl.Rating` tightens it (closed rows, slot admittance, narrowed values).
-}
rating :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
rating attrs children =
    Ir.fromNode (Ir.node "sl-rating" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-relative-time` producer — open attribute/child rows, elm/html call
shape. `Sl.RelativeTime` tightens it (closed rows, slot admittance, narrowed values).
-}
relativeTime :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
relativeTime attrs children =
    Ir.fromNode (Ir.node "sl-relative-time" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-resize-observer` producer — open attribute/child rows, elm/html call
shape. `Sl.ResizeObserver` tightens it (closed rows, slot admittance, narrowed values).
-}
resizeObserver :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
resizeObserver attrs children =
    Ir.fromNode (Ir.node "sl-resize-observer" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-select` producer — open attribute/child rows, elm/html call
shape. `Sl.Select` tightens it (closed rows, slot admittance, narrowed values).
-}
select :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
select attrs children =
    Ir.fromNode (Ir.node "sl-select" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-skeleton` producer — open attribute/child rows, elm/html call
shape. `Sl.Skeleton` tightens it (closed rows, slot admittance, narrowed values).
-}
skeleton :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
skeleton attrs children =
    Ir.fromNode (Ir.node "sl-skeleton" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-spinner` producer — open attribute/child rows, elm/html call
shape. `Sl.Spinner` tightens it (closed rows, slot admittance, narrowed values).
-}
spinner :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
spinner attrs children =
    Ir.fromNode (Ir.node "sl-spinner" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-split-panel` producer — open attribute/child rows, elm/html call
shape. `Sl.SplitPanel` tightens it (closed rows, slot admittance, narrowed values).
-}
splitPanel :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
splitPanel attrs children =
    Ir.fromNode (Ir.node "sl-split-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-switch` producer — open attribute/child rows, elm/html call
shape. `Sl.Switch` tightens it (closed rows, slot admittance, narrowed values).
-}
switch :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
switch attrs children =
    Ir.fromNode (Ir.node "sl-switch" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-tab` producer — open attribute/child rows, elm/html call
shape. `Sl.Tab` tightens it (closed rows, slot admittance, narrowed values).
-}
tab :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
tab attrs children =
    Ir.fromNode (Ir.node "sl-tab" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-tab-group` producer — open attribute/child rows, elm/html call
shape. `Sl.TabGroup` tightens it (closed rows, slot admittance, narrowed values).
-}
tabGroup :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
tabGroup attrs children =
    Ir.fromNode (Ir.node "sl-tab-group" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-tab-panel` producer — open attribute/child rows, elm/html call
shape. `Sl.TabPanel` tightens it (closed rows, slot admittance, narrowed values).
-}
tabPanel :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
tabPanel attrs children =
    Ir.fromNode (Ir.node "sl-tab-panel" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-tag` producer — open attribute/child rows, elm/html call
shape. `Sl.Tag` tightens it (closed rows, slot admittance, narrowed values).
-}
tag :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
tag attrs children =
    Ir.fromNode (Ir.node "sl-tag" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-textarea` producer — open attribute/child rows, elm/html call
shape. `Sl.Textarea` tightens it (closed rows, slot admittance, narrowed values).
-}
textarea :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
textarea attrs children =
    Ir.fromNode (Ir.node "sl-textarea" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-tooltip` producer — open attribute/child rows, elm/html call
shape. `Sl.Tooltip` tightens it (closed rows, slot admittance, narrowed values).
-}
tooltip :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
tooltip attrs children =
    Ir.fromNode (Ir.node "sl-tooltip" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-tree` producer — open attribute/child rows, elm/html call
shape. `Sl.Tree` tightens it (closed rows, slot admittance, narrowed values).
-}
tree :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
tree attrs children =
    Ir.fromNode (Ir.node "sl-tree" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-tree-item` producer — open attribute/child rows, elm/html call
shape. `Sl.TreeItem` tightens it (closed rows, slot admittance, narrowed values).
-}
treeItem :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
treeItem attrs children =
    Ir.fromNode (Ir.node "sl-tree-item" attrs (List.map HtmlIr.Element.toNode children))


{-| The loose `sl-visually-hidden` producer — open attribute/child rows, elm/html call
shape. `Sl.VisuallyHidden` tightens it (closed rows, slot admittance, narrowed values).
-}
visuallyHidden :
    List (Attr attrs msg)
    -> List (Element children childAdmittedBy msg)
    -> Element produced admittedBy msg
visuallyHidden attrs children =
    Ir.fromNode (Ir.node "sl-visually-hidden" attrs (List.map HtmlIr.Element.toNode children))


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
