module M3e.Attributes exposing
    ( class, id, slot, style, classList, styleList
    , action, actionable, active, activeDate, alert, anchorOffset, ariaInvalid, autoActivate, bounce, bufferValue, cascade, caseSensitive, centered, checked, clearLabel, clearable, closeLabel, color, completed, confirmLabel, contained, date, dayLabel, density, detent, detents, dialLabel, disableClose, disableHighlight, disableHover, disableRestoreFocus, disabled, disabledInteractive, discrete, dismissLabel, dismissible, download, duration, editable, elevated, emphasized, enablePressed, end, endDivider, extended, filled, firstPageLabel, fitAnchorWidth, for, handle, handleLabel, hideDelay, hideFriction, hideLabels, hideLoading, hideModeToggle, hideNoData, hidePageSize, hideRequiredMarker, hideSearchIcon, hideSelectionIndicator, hideToggle, hideable, hour, hourLabel, href, indeterminate, inline, inputLabel, inset, insetEnd, insetStart, invalid, inward, itemLabel, itemsPerPageLabel, label, labelled, lastPageLabel, length, level, linear, loaded, loading, loadingLabel, lowered, max, maxDate, maxDepth, maxRows, maxTime, min, minDate, minRows, minTime, minute, minuteLabel, modal, modeToggleLabel, monthLabel, multi, nextMonthLabel, nextMultiYearLabel, nextPageLabel, nextYearLabel, noAnimate, noDataLabel, noFocusTrap, open, opticalSize, optional, overshootLimit, pageIndex, pageSize, pageSizes, panelClass, periodLabel, periodToggleLabel, previousMonthLabel, previousMultiYearLabel, previousPageLabel, previousYearLabel, radius, range, rangeEnd, rangeStart, readonly, rel, removable, removeLabel, required, resultsLabel, returnValue, second, secondLabel, secondary, selected, selectedIndex, showDelay, showFirstLastButtons, showSeconds, start, startAt, startDivider, step, stretch, strongFocus, submenu, target, term, thin, threshold, tocIgnore, today, toggle, unbounded, validationmessages, value, vertical, weight, wrap, wrapDetents, yearLabel
    , defaultChecked, defaultSelected, defaultValue
    , animation, contrast, current, disablePagination, dividers, endMode, filter, floatLabel, format, grade, headerPosition, hideSubscript, highlightMode, icons, labelPosition, mode, motion, name, orientation, pageSizeVariant, period, position, positionX, positionY, scheme, scrollStrategy, shape, size, startMode, startView, state, timeFormat, toggleDirection, togglePosition, touchGestures, type_, variant, viewAttr, width
    , animationNone, animationPulse, animationWave, contrastHigh, contrastMedium, contrastStandard, currentDate, currentLocation, currentPage, currentStep, currentTime, currentTrue, disablePaginationAuto, disablePaginationFalse, disablePaginationTrue, dividersAbove, dividersAboveBelow, dividersBelow, dividersNone, endModeAuto, endModeOver, endModePush, endModeSide, filterContains, filterEndsWith, filterNone, filterStartsWith, floatLabelAlways, floatLabelAuto, formatValue12, formatValue24, formatAuto, gradeHigh, gradeLow, gradeMedium, headerPositionAbove, headerPositionAfter, headerPositionBefore, headerPositionBelow, hideSubscriptAlways, hideSubscriptAuto, hideSubscriptNever, highlightModeContains, highlightModeEndsWith, highlightModeStartsWith, iconsBoth, iconsNone, iconsSelected, labelPositionBelow, labelPositionEnd, modeAuto, modeBuffer, modeCompact, modeContains, modeDeterminate, modeDial, modeDocked, modeEndsWith, modeExpanded, modeFullscreen, modeIndeterminate, modeInput, modeQuery, modeStartsWith, motionExpressive, motionStandard, nameValue12SidedCookie, nameValue4LeafClover, nameValue4SidedCookie, nameValue6SidedCookie, nameValue7SidedCookie, nameValue8LeafClover, nameValue9SidedCookie, nameArch, nameArrow, nameBoom, nameBun, nameBurst, nameCircle, nameDiamond, nameFan, nameFlower, nameGem, nameGhostIsh, nameHeart, nameHexagon, nameOval, namePentagon, namePill, namePixelCircle, namePixelTriangle, namePuffy, namePuffyDiamond, nameSemicircle, nameSlanted, nameSoftBoom, nameSoftBurst, nameSquare, nameSunny, nameTriangle, nameVerySunny, orientationAuto, orientationBoth, orientationHorizontal, orientationVertical, pageSizeVariantFilled, pageSizeVariantOutlined, periodAm, periodPm, positionAbove, positionAboveAfter, positionAboveBefore, positionAfter, positionBefore, positionBelow, positionBelowAfter, positionBelowBefore, positionXAfter, positionXBefore, positionYAbove, positionYBelow, schemeAuto, schemeDark, schemeLight, scrollStrategyHide, scrollStrategyReposition, shapeAuto, shapeCircular, shapeRounded, shapeSquare, sizeExtraLarge, sizeExtraSmall, sizeLarge, sizeMedium, sizeSmall, startModeAuto, startModeOver, startModePush, startModeSide, startViewMonth, startViewMultiYear, startViewYear, stateContent, stateLoading, stateNoData, timeFormatValue12, timeFormatValue24, timeFormatAuto, toggleDirectionHorizontal, toggleDirectionVertical, togglePositionAfter, togglePositionBefore, touchGesturesAuto, touchGesturesOff, touchGesturesOn, type_Button, type_Date, type_Datetime, type_Reset, type_Submit, type_Time, variantAuto, variantConnected, variantContained, variantContent, variantDisplay, variantDocked, variantElevated, variantExpressive, variantFidelity, variantFilled, variantFlat, variantFruitSalad, variantHeadline, variantLabel, variantModal, variantMonochrome, variantNeutral, variantOutlined, variantPrimary, variantPrimaryContainer, variantRainbow, variantRounded, variantSecondary, variantSecondaryContainer, variantSegmented, variantSharp, variantStandard, variantSurface, variantTertiary, variantTertiaryContainer, variantText, variantTitle, variantTonal, variantTonalSpot, variantUncontained, variantVibrant, variantWavy, viewAttrHour, viewAttrMinute, viewAttrSecond, widthDefault, widthNarrow, widthWide
    )

{-| The canonical shared attribute vocabulary. Every setter is an open
producer (`{ c | attr : Supported }`); each element's closed `Attrs` row
decides admittance. Enum setters here close over the library-wide UNION of
values — cross-component misuse is caught by elm-review; reach for the
per-component setters (`M3e.<Component>.<attr>`) for compile-tight narrowing.

Portmanteau setters (`variantRainbow`, `shapeRounded`, …) are nullary
aliases that pre-apply one enum token. They exist for IDE discovery:
type `variant` and autocomplete lists every value inline. Each claims
the same capability row as its base enum setter, so admittance is identical.

@docs class, id, slot, style, classList, styleList
@docs action, actionable, active, activeDate, alert, anchorOffset, ariaInvalid, autoActivate, bounce, bufferValue, cascade, caseSensitive, centered, checked, clearLabel, clearable, closeLabel, color, completed, confirmLabel, contained, date, dayLabel, density, detent, detents, dialLabel, disableClose, disableHighlight, disableHover, disableRestoreFocus, disabled, disabledInteractive, discrete, dismissLabel, dismissible, download, duration, editable, elevated, emphasized, enablePressed, end, endDivider, extended, filled, firstPageLabel, fitAnchorWidth, for, handle, handleLabel, hideDelay, hideFriction, hideLabels, hideLoading, hideModeToggle, hideNoData, hidePageSize, hideRequiredMarker, hideSearchIcon, hideSelectionIndicator, hideToggle, hideable, hour, hourLabel, href, indeterminate, inline, inputLabel, inset, insetEnd, insetStart, invalid, inward, itemLabel, itemsPerPageLabel, label, labelled, lastPageLabel, length, level, linear, loaded, loading, loadingLabel, lowered, max, maxDate, maxDepth, maxRows, maxTime, min, minDate, minRows, minTime, minute, minuteLabel, modal, modeToggleLabel, monthLabel, multi, nextMonthLabel, nextMultiYearLabel, nextPageLabel, nextYearLabel, noAnimate, noDataLabel, noFocusTrap, open, opticalSize, optional, overshootLimit, pageIndex, pageSize, pageSizes, panelClass, periodLabel, periodToggleLabel, previousMonthLabel, previousMultiYearLabel, previousPageLabel, previousYearLabel, radius, range, rangeEnd, rangeStart, readonly, rel, removable, removeLabel, required, resultsLabel, returnValue, second, secondLabel, secondary, selected, selectedIndex, showDelay, showFirstLastButtons, showSeconds, start, startAt, startDivider, step, stretch, strongFocus, submenu, target, term, thin, threshold, tocIgnore, today, toggle, unbounded, validationmessages, value, vertical, weight, wrap, wrapDetents, yearLabel
@docs defaultChecked, defaultSelected, defaultValue
@docs animation, contrast, current, disablePagination, dividers, endMode, filter, floatLabel, format, grade, headerPosition, hideSubscript, highlightMode, icons, labelPosition, mode, motion, name, orientation, pageSizeVariant, period, position, positionX, positionY, scheme, scrollStrategy, shape, size, startMode, startView, state, timeFormat, toggleDirection, togglePosition, touchGestures, type_, variant, viewAttr, width
@docs animationNone, animationPulse, animationWave, contrastHigh, contrastMedium, contrastStandard, currentDate, currentLocation, currentPage, currentStep, currentTime, currentTrue, disablePaginationAuto, disablePaginationFalse, disablePaginationTrue, dividersAbove, dividersAboveBelow, dividersBelow, dividersNone, endModeAuto, endModeOver, endModePush, endModeSide, filterContains, filterEndsWith, filterNone, filterStartsWith, floatLabelAlways, floatLabelAuto, formatValue12, formatValue24, formatAuto, gradeHigh, gradeLow, gradeMedium, headerPositionAbove, headerPositionAfter, headerPositionBefore, headerPositionBelow, hideSubscriptAlways, hideSubscriptAuto, hideSubscriptNever, highlightModeContains, highlightModeEndsWith, highlightModeStartsWith, iconsBoth, iconsNone, iconsSelected, labelPositionBelow, labelPositionEnd, modeAuto, modeBuffer, modeCompact, modeContains, modeDeterminate, modeDial, modeDocked, modeEndsWith, modeExpanded, modeFullscreen, modeIndeterminate, modeInput, modeQuery, modeStartsWith, motionExpressive, motionStandard, nameValue12SidedCookie, nameValue4LeafClover, nameValue4SidedCookie, nameValue6SidedCookie, nameValue7SidedCookie, nameValue8LeafClover, nameValue9SidedCookie, nameArch, nameArrow, nameBoom, nameBun, nameBurst, nameCircle, nameDiamond, nameFan, nameFlower, nameGem, nameGhostIsh, nameHeart, nameHexagon, nameOval, namePentagon, namePill, namePixelCircle, namePixelTriangle, namePuffy, namePuffyDiamond, nameSemicircle, nameSlanted, nameSoftBoom, nameSoftBurst, nameSquare, nameSunny, nameTriangle, nameVerySunny, orientationAuto, orientationBoth, orientationHorizontal, orientationVertical, pageSizeVariantFilled, pageSizeVariantOutlined, periodAm, periodPm, positionAbove, positionAboveAfter, positionAboveBefore, positionAfter, positionBefore, positionBelow, positionBelowAfter, positionBelowBefore, positionXAfter, positionXBefore, positionYAbove, positionYBelow, schemeAuto, schemeDark, schemeLight, scrollStrategyHide, scrollStrategyReposition, shapeAuto, shapeCircular, shapeRounded, shapeSquare, sizeExtraLarge, sizeExtraSmall, sizeLarge, sizeMedium, sizeSmall, startModeAuto, startModeOver, startModePush, startModeSide, startViewMonth, startViewMultiYear, startViewYear, stateContent, stateLoading, stateNoData, timeFormatValue12, timeFormatValue24, timeFormatAuto, toggleDirectionHorizontal, toggleDirectionVertical, togglePositionAfter, togglePositionBefore, touchGesturesAuto, touchGesturesOff, touchGesturesOn, type_Button, type_Date, type_Datetime, type_Reset, type_Submit, type_Time, variantAuto, variantConnected, variantContained, variantContent, variantDisplay, variantDocked, variantElevated, variantExpressive, variantFidelity, variantFilled, variantFlat, variantFruitSalad, variantHeadline, variantLabel, variantModal, variantMonochrome, variantNeutral, variantOutlined, variantPrimary, variantPrimaryContainer, variantRainbow, variantRounded, variantSecondary, variantSecondaryContainer, variantSegmented, variantSharp, variantStandard, variantSurface, variantTertiary, variantTertiaryContainer, variantText, variantTitle, variantTonal, variantTonalSpot, variantUncontained, variantVibrant, variantWavy, viewAttrHour, viewAttrMinute, viewAttrSecond, widthDefault, widthNarrow, widthWide

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import M3e.Values


{-| The global `class` attribute. Repeats ACCUMULATE: `[ class "a", class "b" ]` renders `class="a b"`.
-}
class : String -> Attr { c | class : Supported } msg
class =
    Ir.attribute "class"


{-| The classes whose flag is `True`, space-joined. Accumulates with every other `class` / `classList` on the element.
-}
classList : List ( String, Bool ) -> Attr { c | class : Supported } msg
classList pairs =
    Ir.attribute "class" (String.join " " (List.map Tuple.first (List.filter Tuple.second pairs)))


{-| The global `id` attribute.
-}
id : String -> Attr { c | id : Supported } msg
id =
    Ir.attribute "id"


{-| The global `slot` attribute (named-slot placement by hand).
-}
slot : String -> Attr { c | slot : Supported } msg
slot =
    Ir.attribute "slot"


{-| One inline-style declaration (the `elm/html` 0.19 shape). Declarations MERGE across every `style` / `styleList` on the element, last-wins per property.
-}
style : String -> String -> Attr { c | style : Supported } msg
style property value_ =
    Ir.styles [ ( property, value_ ) ]


{-| Inline-style declarations as a `( property, value )` list (the `elm/html` 0.18 shape). Merges exactly as `style` does.
-}
styleList : List ( String, String ) -> Attr { c | style : Supported } msg
styleList =
    Ir.styles


{-| The label of the snackbar's action. (default: `""`)
-}
action : String -> Attr { c | action : Supported } msg
action =
    Ir.attribute "action"


{-| Whether the card is "actionable" and will respond to use interaction. (default: `false`)
-}
actionable : Bool -> Attr { c | actionable : Supported } msg
actionable value_ =
    if value_ then
        Ir.attribute "actionable" ""

    else
        Ir.none


{-| Whether the view is active. (default: `false`)
-}
active : Bool -> Attr { c | active : Supported } msg
active value_ =
    if value_ then
        Ir.attribute "active" ""

    else
        Ir.none


{-| The active date. (default: `new Date()`)
-}
activeDate : String -> Attr { c | activeDate : Supported } msg
activeDate =
    Ir.attribute "active-date"


{-| Whether the dialog is an alert. (default: `false`)
-}
alert : Bool -> Attr { c | alert : Supported } msg
alert value_ =
    if value_ then
        Ir.attribute "alert" ""

    else
        Ir.none


{-| The logical margin, in pixels, between the panel and its anchor. (default: `0`)
-}
anchorOffset : Float -> Attr { c | anchorOffset : Supported } msg
anchorOffset value_ =
    Ir.attribute "anchor-offset" (String.fromFloat value_)


{-| Set the `aria-invalid` attribute.
-}
ariaInvalid : String -> Attr { c | ariaInvalid : Supported } msg
ariaInvalid =
    Ir.attribute "aria-invalid"


{-| Whether the first option should be automatically activated. (default: `false`)
-}
autoActivate : Bool -> Attr { c | autoActivate : Supported } msg
autoActivate value_ =
    if value_ then
        Ir.attribute "auto-activate" ""

    else
        Ir.none


{-| Whether the indicator presents a bounce animation when selected. (default: `false`)
-}
bounce : Bool -> Attr { c | bounce : Supported } msg
bounce value_ =
    if value_ then
        Ir.attribute "bounce" ""

    else
        Ir.none


{-| A fractional value, between 0 and `max`, indicating buffer progress. (default: `0`)
-}
bufferValue : Float -> Attr { c | bufferValue : Supported } msg
bufferValue value_ =
    Ir.attribute "buffer-value" (String.fromFloat value_)


{-| Whether multiple item selection cascades to child items. (default: `false`)
-}
cascade : Bool -> Attr { c | cascade : Supported } msg
cascade value_ =
    if value_ then
        Ir.attribute "cascade" ""

    else
        Ir.none


{-| Whether matching is case sensitive. (default: `false`)
-}
caseSensitive : Bool -> Attr { c | caseSensitive : Supported } msg
caseSensitive value_ =
    if value_ then
        Ir.attribute "case-sensitive" ""

    else
        Ir.none


{-| Whether the selection animation always originates from the center of the element's bounds,
rather than originating from the location of the click event. (default: `false`)
-}
centered : Bool -> Attr { c | centered : Supported } msg
centered value_ =
    if value_ then
        Ir.attribute "centered" ""

    else
        Ir.none


{-| Whether the element is checked. (default: `false`)

Sets the LIVE DOM property `checked`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultChecked`.

-}
checked : Bool -> Attr { c | checked : Supported } msg
checked value_ =
    Ir.property "checked" (Json.Encode.bool value_)


{-| The accessible label given to the button used to clear the search term. (default: `"Clear"`)
-}
clearLabel : String -> Attr { c | clearLabel : Supported } msg
clearLabel =
    Ir.attribute "clear-label"


{-| Whether the bar presents a button used to clear the search term. (default: `false`)
-}
clearable : Bool -> Attr { c | clearable : Supported } msg
clearable value_ =
    if value_ then
        Ir.attribute "clearable" ""

    else
        Ir.none


{-| The accessible label given to the button used to dismiss the snackbar. (default: `"Close"`)
-}
closeLabel : String -> Attr { c | closeLabel : Supported } msg
closeLabel =
    Ir.attribute "close-label"


{-| The hex color of the theme to preview (default: `"#6750A4"`)
-}
color : String -> Attr { c | color : Supported } msg
color =
    Ir.attribute "color"


{-| Whether the step has been completed. (default: `false`)
-}
completed : Bool -> Attr { c | completed : Supported } msg
completed value_ =
    if value_ then
        Ir.attribute "completed" ""

    else
        Ir.none


{-| Label given to the button used apply the selected date and close the picker. (default: `"OK"`)
-}
confirmLabel : String -> Attr { c | confirmLabel : Supported } msg
confirmLabel =
    Ir.attribute "confirm-label"


{-| Whether the view features a persistent, filled search container. (default: `false`)
-}
contained : Bool -> Attr { c | contained : Supported } msg
contained value_ =
    if value_ then
        Ir.attribute "contained" ""

    else
        Ir.none


{-| The selected date. (default: `null`)
-}
date : String -> Attr { c | date : Supported } msg
date =
    Ir.attribute "date"


{-| The accessible label given to the day segment. (default: `"Day"`)
-}
dayLabel : String -> Attr { c | dayLabel : Supported } msg
dayLabel =
    Ir.attribute "day-label"


{-| The density scale (0, -1, -2). (default: `0`)
-}
density : Float -> Attr { c | density : Supported } msg
density value_ =
    Ir.attribute "density" (String.fromFloat value_)


{-| The zero‑based index of the detent the sheet should open to.
-}
detent : Float -> Attr { c | detent : Supported } msg
detent value_ =
    Ir.attribute "detent" (String.fromFloat value_)


{-| Detents (discrete sizes) the start pane can snap to. (default: `[]`)
-}
detents : String -> Attr { c | detents : Supported } msg
detents =
    Ir.attribute "detents"


{-| Label given to the the picker when in dial mode. (default: `"Select time"`)
-}
dialLabel : String -> Attr { c | dialLabel : Supported } msg
dialLabel =
    Ir.attribute "dial-label"


{-| Whether users cannot click the backdrop or press ESC to dismiss the dialog. (default: `false`)
-}
disableClose : Bool -> Attr { c | disableClose : Supported } msg
disableClose value_ =
    if value_ then
        Ir.attribute "disable-close" ""

    else
        Ir.none


{-| Whether text highlighting is disabled. (default: `false`)
-}
disableHighlight : Bool -> Attr { c | disableHighlight : Supported } msg
disableHighlight value_ =
    if value_ then
        Ir.attribute "disable-highlight" ""

    else
        Ir.none


{-| Whether hover events will not trigger the state layer. State layers can still
be controlled manually using the `show` and `hide` methods. (default: `false`)
-}
disableHover : Bool -> Attr { c | disableHover : Supported } msg
disableHover value_ =
    if value_ then
        Ir.attribute "disable-hover" ""

    else
        Ir.none


{-| Whether to focus should not be restored to the trigger when activated. (default: `false`)
-}
disableRestoreFocus : Bool -> Attr { c | disableRestoreFocus : Supported } msg
disableRestoreFocus value_ =
    if value_ then
        Ir.attribute "disable-restore-focus" ""

    else
        Ir.none


{-| Whether the element is disabled. (default: `false`)
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled value_ =
    if value_ then
        Ir.attribute "disabled" ""

    else
        Ir.none


{-| A value indicating whether the element is disabled and interactive. (default: `false`)
-}
disabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
disabledInteractive value_ =
    if value_ then
        Ir.attribute "disabled-interactive" ""

    else
        Ir.none


{-| Whether to show tick marks. (default: `false`)
-}
discrete : Bool -> Attr { c | discrete : Supported } msg
discrete value_ =
    if value_ then
        Ir.attribute "discrete" ""

    else
        Ir.none


{-| Label given to the button used discard the selected date and close the picker. (default: `"Cancel"`)
-}
dismissLabel : String -> Attr { c | dismissLabel : Supported } msg
dismissLabel =
    Ir.attribute "dismiss-label"


{-| Whether a button is presented that can be used to close the snackbar. (default: `false`)
-}
dismissible : Bool -> Attr { c | dismissible : Supported } msg
dismissible value_ =
    if value_ then
        Ir.attribute "dismissible" ""

    else
        Ir.none


{-| A value indicating whether the `target` of the link button will be downloaded, optionally specifying the new name of the file. (default: `null`)
-}
download : String -> Attr { c | download : Supported } msg
download =
    Ir.attribute "download"


{-| The length of time, in milliseconds, to wait before automatically dismissing the snackbar. (default: `3000`)
-}
duration : Float -> Attr { c | duration : Supported } msg
duration value_ =
    Ir.attribute "duration" (String.fromFloat value_)


{-| Whether the step is editable and users can return to it after completion. (default: `false`)
-}
editable : Bool -> Attr { c | editable : Supported } msg
editable value_ =
    if value_ then
        Ir.attribute "editable" ""

    else
        Ir.none


{-| Whether the toolbar is elevated. (default: `false`)
-}
elevated : Bool -> Attr { c | elevated : Supported } msg
elevated value_ =
    if value_ then
        Ir.attribute "elevated" ""

    else
        Ir.none


{-| Whether the heading uses an emphasized typescale. (default: `false`)
-}
emphasized : Bool -> Attr { c | emphasized : Supported } msg
emphasized value_ =
    if value_ then
        Ir.attribute "emphasized" ""

    else
        Ir.none


{-| Whether pressed events will trigger the state layer. State layers can still
be controlled manually using the `show` and `hide` methods. (default: `false`)
-}
enablePressed : Bool -> Attr { c | enablePressed : Supported } msg
enablePressed value_ =
    if value_ then
        Ir.attribute "enable-pressed" ""

    else
        Ir.none


{-| Whether the end drawer is open. (default: `false`)
-}
end : Bool -> Attr { c | end : Supported } msg
end value_ =
    if value_ then
        Ir.attribute "end" ""

    else
        Ir.none


{-| Whether to show a divider between the end drawer and content for `side` mode. (default: `false`)
-}
endDivider : Bool -> Attr { c | endDivider : Supported } msg
endDivider value_ =
    if value_ then
        Ir.attribute "end-divider" ""

    else
        Ir.none


{-| Whether the button is extended to show the label. (default: `false`)
-}
extended : Bool -> Attr { c | extended : Supported } msg
extended value_ =
    if value_ then
        Ir.attribute "extended" ""

    else
        Ir.none


{-| Whether the icon is filled. (default: `false`)
-}
filled : Bool -> Attr { c | filled : Supported } msg
filled value_ =
    if value_ then
        Ir.attribute "filled" ""

    else
        Ir.none


{-| The accessible label given to the button used to move to the first page. (default: `"First page"`)
-}
firstPageLabel : String -> Attr { c | firstPageLabel : Supported } msg
firstPageLabel =
    Ir.attribute "first-page-label"


{-| Whether the panel's width should match its anchor's width. (default: `false`)
-}
fitAnchorWidth : Bool -> Attr { c | fitAnchorWidth : Supported } msg
fitAnchorWidth value_ =
    if value_ then
        Ir.attribute "fit-anchor-width" ""

    else
        Ir.none


{-| The identifier of the interactive control to which this element is attached. (default: `null`)
-}
for : String -> Attr { c | for : Supported } msg
for =
    Ir.attribute "for"


{-| Whether to display a drag handle and enable the top region of the sheet as a gesture
surface for dragging between detents. (default: `false`)
-}
handle : Bool -> Attr { c | handle : Supported } msg
handle value_ =
    if value_ then
        Ir.attribute "handle" ""

    else
        Ir.none


{-| The accessible label given to the drag handle. (default: `"Drag handle"`)
-}
handleLabel : String -> Attr { c | handleLabel : Supported } msg
handleLabel =
    Ir.attribute "handle-label"


{-| The amount of time, in milliseconds, before hiding the tooltip. (default: `200`)
-}
hideDelay : Float -> Attr { c | hideDelay : Supported } msg
hideDelay value_ =
    Ir.attribute "hide-delay" (String.fromFloat value_)


{-| The friction coefficient to hide the sheet. (default: `0.5`)
-}
hideFriction : Float -> Attr { c | hideFriction : Supported } msg
hideFriction value_ =
    Ir.attribute "hide-friction" (String.fromFloat value_)


{-| Whether to hide field labels. (default: `false`)
-}
hideLabels : Bool -> Attr { c | hideLabels : Supported } msg
hideLabels value_ =
    if value_ then
        Ir.attribute "hide-labels" ""

    else
        Ir.none


{-| Whether to hide the menu when loading options. (default: `false`)
-}
hideLoading : Bool -> Attr { c | hideLoading : Supported } msg
hideLoading value_ =
    if value_ then
        Ir.attribute "hide-loading" ""

    else
        Ir.none


{-| Whether to hide the mode toggle button. (default: `false`)
-}
hideModeToggle : Bool -> Attr { c | hideModeToggle : Supported } msg
hideModeToggle value_ =
    if value_ then
        Ir.attribute "hide-mode-toggle" ""

    else
        Ir.none


{-| Whether to hide the menu when there are no options to show. (default: `false`)
-}
hideNoData : Bool -> Attr { c | hideNoData : Supported } msg
hideNoData value_ =
    if value_ then
        Ir.attribute "hide-no-data" ""

    else
        Ir.none


{-| Whether to hide page size selection. (default: `false`)
-}
hidePageSize : Bool -> Attr { c | hidePageSize : Supported } msg
hidePageSize value_ =
    if value_ then
        Ir.attribute "hide-page-size" ""

    else
        Ir.none


{-| Whether the required marker should be hidden. (default: `false`)
-}
hideRequiredMarker : Bool -> Attr { c | hideRequiredMarker : Supported } msg
hideRequiredMarker value_ =
    if value_ then
        Ir.attribute "hide-required-marker" ""

    else
        Ir.none


{-| Whether to hide the search icon. (default: `false`)
-}
hideSearchIcon : Bool -> Attr { c | hideSearchIcon : Supported } msg
hideSearchIcon value_ =
    if value_ then
        Ir.attribute "hide-search-icon" ""

    else
        Ir.none


{-| Whether to hide the selection indicator. (default: `false`)
-}
hideSelectionIndicator : Bool -> Attr { c | hideSelectionIndicator : Supported } msg
hideSelectionIndicator value_ =
    if value_ then
        Ir.attribute "hide-selection-indicator" ""

    else
        Ir.none


{-| Whether to hide the expansion toggle. (default: `false`)
-}
hideToggle : Bool -> Attr { c | hideToggle : Supported } msg
hideToggle value_ =
    if value_ then
        Ir.attribute "hide-toggle" ""

    else
        Ir.none


{-| Whether the bottom sheet can hide when its swiped down. (default: `false`)
-}
hideable : Bool -> Attr { c | hideable : Supported } msg
hideable value_ =
    if value_ then
        Ir.attribute "hideable" ""

    else
        Ir.none


{-| The hour, in 24-hour time, from 0..23. (default: `null`)
-}
hour : Float -> Attr { c | hour : Supported } msg
hour value_ =
    Ir.attribute "hour" (String.fromFloat value_)


{-| The label for the hour field. (default: `"Hour"`)
-}
hourLabel : String -> Attr { c | hourLabel : Supported } msg
hourLabel =
    Ir.attribute "hour-label"


{-| The URL to which the link button points. (default: `""`)
-}
href : String -> Attr { c | href : Supported } msg
href =
    Ir.attribute "href"


{-| A value indicating whether the element's selected / checked state is indeterminate. (default: `false`)
-}
indeterminate : Bool -> Attr { c | indeterminate : Supported } msg
indeterminate value_ =
    if value_ then
        Ir.attribute "indeterminate" ""

    else
        Ir.none


{-| Whether to present the card inline with surrounding content. (default: `false`)
-}
inline : Bool -> Attr { c | inline : Supported } msg
inline value_ =
    if value_ then
        Ir.attribute "inline" ""

    else
        Ir.none


{-| Label given to the the picker when in input mode. (default: `"Edit time"`)
-}
inputLabel : String -> Attr { c | inputLabel : Supported } msg
inputLabel =
    Ir.attribute "input-label"


{-| Whether the divider is indented with equal padding on both sides. (default: `false`)
-}
inset : Bool -> Attr { c | inset : Supported } msg
inset value_ =
    if value_ then
        Ir.attribute "inset" ""

    else
        Ir.none


{-| Whether the divider is indented with padding on the trailing side. (default: `false`)
-}
insetEnd : Bool -> Attr { c | insetEnd : Supported } msg
insetEnd value_ =
    if value_ then
        Ir.attribute "inset-end" ""

    else
        Ir.none


{-| Whether the divider is indented with padding on the leading side. (default: `false`)
-}
insetStart : Bool -> Attr { c | insetStart : Supported } msg
insetStart value_ =
    if value_ then
        Ir.attribute "inset-start" ""

    else
        Ir.none


{-| Whether the step has an error. (default: `false`)
-}
invalid : Bool -> Attr { c | invalid : Supported } msg
invalid value_ =
    if value_ then
        Ir.attribute "invalid" ""

    else
        Ir.none


{-| Whether the focus ring animates inward instead of outward. (default: `false`)
-}
inward : Bool -> Attr { c | inward : Supported } msg
inward value_ =
    if value_ then
        Ir.attribute "inward" ""

    else
        Ir.none


{-| The accessible label given to the item's internal button. (default: `""`)
-}
itemLabel : String -> Attr { c | itemLabel : Supported } msg
itemLabel =
    Ir.attribute "item-label"


{-| The label for the page size selector. (default: `"Items per page:"`)
-}
itemsPerPageLabel : String -> Attr { c | itemsPerPageLabel : Supported } msg
itemsPerPageLabel =
    Ir.attribute "items-per-page-label"


{-| The accessible label given to the movable drag handle. (default: `"Resize panes"`)
-}
label : String -> Attr { c | label : Supported } msg
label =
    Ir.attribute "label"


{-| Whether to show value labels when activated. (default: `false`)
-}
labelled : Bool -> Attr { c | labelled : Supported } msg
labelled value_ =
    if value_ then
        Ir.attribute "labelled" ""

    else
        Ir.none


{-| The accessible label given to the button used to move to the last page. (default: `"Last page"`)
-}
lastPageLabel : String -> Attr { c | lastPageLabel : Supported } msg
lastPageLabel =
    Ir.attribute "last-page-label"


{-| The length of the total number of items which are being paginated. (default: `0`)
-}
length : Float -> Attr { c | length : Supported } msg
length value_ =
    Ir.attribute "length" (String.fromFloat value_)


{-| The accessibility level of the heading.
-}
level : Int -> Attr { c | level : Supported } msg
level value_ =
    Ir.attribute "level" (String.fromInt value_)


{-| Whether the validity of previous steps should be checked or not. (default: `false`)
-}
linear : Bool -> Attr { c | linear : Supported } msg
linear value_ =
    if value_ then
        Ir.attribute "linear" ""

    else
        Ir.none


{-| Whether the content of the skeleton has been loaded. (default: `false`)
-}
loaded : Bool -> Attr { c | loaded : Supported } msg
loaded value_ =
    if value_ then
        Ir.attribute "loaded" ""

    else
        Ir.none


{-| Whether options are being loaded. (default: `false`)
-}
loading : Bool -> Attr { c | loading : Supported } msg
loading value_ =
    if value_ then
        Ir.attribute "loading" ""

    else
        Ir.none


{-| The text announced and presented when loading options. (default: `"Loading..."`)
-}
loadingLabel : String -> Attr { c | loadingLabel : Supported } msg
loadingLabel =
    Ir.attribute "loading-label"


{-| Whether to present a lowered elevation. (default: `false`)
-}
lowered : Bool -> Attr { c | lowered : Supported } msg
lowered value_ =
    if value_ then
        Ir.attribute "lowered" ""

    else
        Ir.none


{-| A fractional value, between 0 and 100, indicating the maximum size of the start pane. (default: `100`)
-}
max : Float -> Attr { c | max : Supported } msg
max value_ =
    Ir.attribute "max" (String.fromFloat value_)


{-| The maximum date that can be selected. (default: `null`)
-}
maxDate : String -> Attr { c | maxDate : Supported } msg
maxDate =
    Ir.attribute "max-date"


{-| The maximum depth of the table of contents. (default: `2`)
-}
maxDepth : Float -> Attr { c | maxDepth : Supported } msg
maxDepth value_ =
    Ir.attribute "max-depth" (String.fromFloat value_)


{-| The maximum amount of rows in the `textarea`. (default: `0`)
-}
maxRows : Float -> Attr { c | maxRows : Supported } msg
maxRows value_ =
    Ir.attribute "max-rows" (String.fromFloat value_)


{-| The maximum time that can be selected. (default: `null`)
-}
maxTime : String -> Attr { c | maxTime : Supported } msg
maxTime =
    Ir.attribute "max-time"


{-| A fractional value, between 0 and 100, indicating the minimum size of the start pane. (default: `0`)
-}
min : Float -> Attr { c | min : Supported } msg
min value_ =
    Ir.attribute "min" (String.fromFloat value_)


{-| The minimum date that can be selected. (default: `null`)
-}
minDate : String -> Attr { c | minDate : Supported } msg
minDate =
    Ir.attribute "min-date"


{-| The minimum amount of rows in the `textarea`. (default: `0`)
-}
minRows : Float -> Attr { c | minRows : Supported } msg
minRows value_ =
    Ir.attribute "min-rows" (String.fromFloat value_)


{-| The minimum time that can be selected. (default: `null`)
-}
minTime : String -> Attr { c | minTime : Supported } msg
minTime =
    Ir.attribute "min-time"


{-| The minute, from 0..59. (default: `null`)
-}
minute : Float -> Attr { c | minute : Supported } msg
minute value_ =
    Ir.attribute "minute" (String.fromFloat value_)


{-| The label for the minute field. (default: `"Minute"`)
-}
minuteLabel : String -> Attr { c | minuteLabel : Supported } msg
minuteLabel =
    Ir.attribute "minute-label"


{-| Whether the bottom sheet behaves as modal. (default: `false`)
-}
modal : Bool -> Attr { c | modal : Supported } msg
modal value_ =
    if value_ then
        Ir.attribute "modal" ""

    else
        Ir.none


{-| The accessible label given to the mode toggle button. (default: `"Toggle input picker"`)
-}
modeToggleLabel : String -> Attr { c | modeToggleLabel : Supported } msg
modeToggleLabel =
    Ir.attribute "mode-toggle-label"


{-| The accessible label given to the month segment. (default: `"Month"`)
-}
monthLabel : String -> Attr { c | monthLabel : Supported } msg
monthLabel =
    Ir.attribute "month-label"


{-| Whether multiple items can be selected. (default: `false`)
-}
multi : Bool -> Attr { c | multi : Supported } msg
multi value_ =
    if value_ then
        Ir.attribute "multi" ""

    else
        Ir.none


{-| The accessible label given to the button used to move to the next month. (default: `"Next month"`)
-}
nextMonthLabel : String -> Attr { c | nextMonthLabel : Supported } msg
nextMonthLabel =
    Ir.attribute "next-month-label"


{-| The accessible label given to the button used to move to the next 24 years. (default: `"Next 24 years"`)
-}
nextMultiYearLabel : String -> Attr { c | nextMultiYearLabel : Supported } msg
nextMultiYearLabel =
    Ir.attribute "next-multi-year-label"


{-| The accessible label given to the button used to move to the next page. (default: `"Next page"`)
-}
nextPageLabel : String -> Attr { c | nextPageLabel : Supported } msg
nextPageLabel =
    Ir.attribute "next-page-label"


{-| The accessible label given to the button used to move to the next year. (default: `"Next year"`)
-}
nextYearLabel : String -> Attr { c | nextYearLabel : Supported } msg
nextYearLabel =
    Ir.attribute "next-year-label"


{-| Whether to disable animation. (default: `false`)
-}
noAnimate : Bool -> Attr { c | noAnimate : Supported } msg
noAnimate value_ =
    if value_ then
        Ir.attribute "no-animate" ""

    else
        Ir.none


{-| The text announced and presented when no options are available for the current term. (default: `"No options"`)
-}
noDataLabel : String -> Attr { c | noDataLabel : Supported } msg
noDataLabel =
    Ir.attribute "no-data-label"


{-| Whether to disable focus trapping, which keeps keyboard `Tab` navigation within the dialog. (default: `false`)
-}
noFocusTrap : Bool -> Attr { c | noFocusTrap : Supported } msg
noFocusTrap value_ =
    if value_ then
        Ir.attribute "no-focus-trap" ""

    else
        Ir.none


{-| Whether the item is expanded. (default: `false`)
-}
open : Bool -> Attr { c | open : Supported } msg
open value_ =
    if value_ then
        Ir.attribute "open" ""

    else
        Ir.none


{-| A value from 20 to 48 indicating the optical size of the icon. (default: `24`)
-}
opticalSize : Float -> Attr { c | opticalSize : Supported } msg
opticalSize value_ =
    Ir.attribute "optical-size" (String.fromFloat value_)


{-| Whether the step is optional. (default: `false`)
-}
optional : Bool -> Attr { c | optional : Supported } msg
optional value_ =
    if value_ then
        Ir.attribute "optional" ""

    else
        Ir.none


{-| A fractional value, between 0 and 100, indicating the maximum visual overshoot allowed when dragging past the minimum or maximum size. (default: `4`)
-}
overshootLimit : Float -> Attr { c | overshootLimit : Supported } msg
overshootLimit value_ =
    Ir.attribute "overshoot-limit" (String.fromFloat value_)


{-| The zero-based page index of the displayed list of items. (default: `0`)
-}
pageIndex : Float -> Attr { c | pageIndex : Supported } msg
pageIndex value_ =
    Ir.attribute "page-index" (String.fromFloat value_)


{-| The number of items to display in a page. (default: `50`)
-}
pageSize : String -> Attr { c | pageSize : Supported } msg
pageSize =
    Ir.attribute "page-size"


{-| A comma separated list of available page sizes. (default: `"5,10,25,50,100"`)
-}
pageSizes : String -> Attr { c | pageSizes : Supported } msg
pageSizes =
    Ir.attribute "page-sizes"


{-| Class or list of classes to be applied to the select's overlay panel. (default: `""`)
-}
panelClass : String -> Attr { c | panelClass : Supported } msg
panelClass =
    Ir.attribute "panel-class"


{-| The accessible label given to the period segment (AM/PM). (default: `"Period"`)
-}
periodLabel : String -> Attr { c | periodLabel : Supported } msg
periodLabel =
    Ir.attribute "period-label"


{-| The accessible label given to the period toggle. (default: `"AM or PM"`)
-}
periodToggleLabel : String -> Attr { c | periodToggleLabel : Supported } msg
periodToggleLabel =
    Ir.attribute "period-toggle-label"


{-| The accessible label given to the button used to move to the previous month. (default: `"Previous month"`)
-}
previousMonthLabel : String -> Attr { c | previousMonthLabel : Supported } msg
previousMonthLabel =
    Ir.attribute "previous-month-label"


{-| The accessible label given to the button used to move to the previous 24 years. (default: `"Previous 24 years"`)
-}
previousMultiYearLabel : String -> Attr { c | previousMultiYearLabel : Supported } msg
previousMultiYearLabel =
    Ir.attribute "previous-multi-year-label"


{-| The accessible label given to the button used to move to the previous page. (default: `"Previous page"`)
-}
previousPageLabel : String -> Attr { c | previousPageLabel : Supported } msg
previousPageLabel =
    Ir.attribute "previous-page-label"


{-| The accessible label given to the button used to move to the previous year. (default: `"Previous year"`)
-}
previousYearLabel : String -> Attr { c | previousYearLabel : Supported } msg
previousYearLabel =
    Ir.attribute "previous-year-label"


{-| The radius, in pixels, of the ripple. (default: `null`)
-}
radius : Float -> Attr { c | radius : Supported } msg
radius value_ =
    Ir.attribute "radius" (String.fromFloat value_)


{-| Whether a range of dates can be selected. (default: `false`)
-}
range : Bool -> Attr { c | range : Supported } msg
range value_ =
    if value_ then
        Ir.attribute "range" ""

    else
        Ir.none


{-| End of a date range. (default: `null`)
-}
rangeEnd : String -> Attr { c | rangeEnd : Supported } msg
rangeEnd =
    Ir.attribute "range-end"


{-| Start of a date range. (default: `null`)
-}
rangeStart : String -> Attr { c | rangeStart : Supported } msg
rangeStart =
    Ir.attribute "range-start"


{-| A value indicating whether the element is read-only. (default: `false`)
-}
readonly : Bool -> Attr { c | readonly : Supported } msg
readonly value_ =
    if value_ then
        Ir.attribute "readonly" ""

    else
        Ir.none


{-| The relationship between the `target` of the link button and the document. (default: `""`)
-}
rel : String -> Attr { c | rel : Supported } msg
rel =
    Ir.attribute "rel"


{-| Whether the chip is removable. (default: `false`)
-}
removable : Bool -> Attr { c | removable : Supported } msg
removable value_ =
    if value_ then
        Ir.attribute "removable" ""

    else
        Ir.none


{-| The accessible label given to the button used to remove the chip. (default: `"Remove"`)
-}
removeLabel : String -> Attr { c | removeLabel : Supported } msg
removeLabel =
    Ir.attribute "remove-label"


{-| Whether the element is required. (default: `false`)
-}
required : Bool -> Attr { c | required : Supported } msg
required value_ =
    if value_ then
        Ir.attribute "required" ""

    else
        Ir.none


{-| The text announced when available options change for the current term. (default: `(count) =>`${count} options\`\`)
-}
resultsLabel : String -> Attr { c | resultsLabel : Supported } msg
resultsLabel =
    Ir.attribute "results-label"


{-| The value to return from the dialog. (default: `""`)
-}
returnValue : String -> Attr { c | returnValue : Supported } msg
returnValue =
    Ir.attribute "return-value"


{-| The second, from 0..59. (default: `null`)
-}
second : Float -> Attr { c | second : Supported } msg
second value_ =
    Ir.attribute "second" (String.fromFloat value_)


{-| The label for the second field. (default: `"Second"`)
-}
secondLabel : String -> Attr { c | secondLabel : Supported } msg
secondLabel =
    Ir.attribute "second-label"


{-| Marks this trigger as a secondary trigger for accessibility. Secondary triggers do not receive ARIA ownership. (default: `false`)
-}
secondary : Bool -> Attr { c | secondary : Supported } msg
secondary value_ =
    if value_ then
        Ir.attribute "secondary" ""

    else
        Ir.none


{-| Whether the item is selected. (default: `false`)

Sets the LIVE DOM property `selected`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultSelected`.

CAVEAT — this setter cannot RESYNC. `elm/virtual-dom` only re-forces an unchanged controlled property for the names `value` and `checked`; `selected` is compared by identity, so re-rendering the same model value after the user has changed it through the element's own UI will NOT push it back to the DOM. Keep the model in sync with a `change` handler.

-}
selected : Bool -> Attr { c | selected : Supported } msg
selected value_ =
    Ir.property "selected" (Json.Encode.bool value_)


{-| The zero-based index of the visible item. (default: `null`)
-}
selectedIndex : Float -> Attr { c | selectedIndex : Supported } msg
selectedIndex value_ =
    Ir.attribute "selected-index" (String.fromFloat value_)


{-| The amount of time, in milliseconds, before showing the tooltip. (default: `0`)
-}
showDelay : Float -> Attr { c | showDelay : Supported } msg
showDelay value_ =
    Ir.attribute "show-delay" (String.fromFloat value_)


{-| Whether to show first/last buttons. (default: `false`)
-}
showFirstLastButtons : Bool -> Attr { c | showFirstLastButtons : Supported } msg
showFirstLastButtons value_ =
    if value_ then
        Ir.attribute "show-first-last-buttons" ""

    else
        Ir.none


{-| Whether to show seconds. (default: `false`)
-}
showSeconds : Bool -> Attr { c | showSeconds : Supported } msg
showSeconds value_ =
    if value_ then
        Ir.attribute "show-seconds" ""

    else
        Ir.none


{-| Whether the start drawer is open. (default: `false`)
-}
start : Bool -> Attr { c | start : Supported } msg
start value_ =
    if value_ then
        Ir.attribute "start" ""

    else
        Ir.none


{-| A date specifying the period (month or year) to start the calendar in. (default: `null`)
-}
startAt : String -> Attr { c | startAt : Supported } msg
startAt =
    Ir.attribute "start-at"


{-| Whether to show a divider between the start drawer and content for `side` mode. (default: `false`)
-}
startDivider : Bool -> Attr { c | startDivider : Supported } msg
startDivider value_ =
    if value_ then
        Ir.attribute "start-divider" ""

    else
        Ir.none


{-| A fractional value, between 0 and 100, indicating the increment by which to adjust the value when resized via keyboard. (default: `1`)
-}
step : Float -> Attr { c | step : Supported } msg
step value_ =
    Ir.attribute "step" (String.fromFloat value_)


{-| Whether tabs are stretched to fill the header. (default: `false`)
-}
stretch : Bool -> Attr { c | stretch : Supported } msg
stretch value_ =
    if value_ then
        Ir.attribute "stretch" ""

    else
        Ir.none


{-| Whether to enable strong focus indicators. (default: `false`)
-}
strongFocus : Bool -> Attr { c | strongFocus : Supported } msg
strongFocus value_ =
    if value_ then
        Ir.attribute "strong-focus" ""

    else
        Ir.none


{-| A value indicating whether the menu is a submenu. (default: `false`)
-}
submenu : Bool -> Attr { c | submenu : Supported } msg
submenu value_ =
    if value_ then
        Ir.attribute "submenu" ""

    else
        Ir.none


{-| The target of the link button. (default: `""`)
-}
target : String -> Attr { c | target : Supported } msg
target =
    Ir.attribute "target"


{-| The term to highlight. (default: `""`)
-}
term : String -> Attr { c | term : Supported } msg
term =
    Ir.attribute "term"


{-| Whether to present thin scrollbars. (default: `false`)
-}
thin : Bool -> Attr { c | thin : Supported } msg
thin value_ =
    if value_ then
        Ir.attribute "thin" ""

    else
        Ir.none


{-| A value, in pixels, indicating the scroll threshold at which to begin showing pagination controls. (default: `0`)
-}
threshold : Float -> Attr { c | threshold : Supported } msg
threshold value_ =
    Ir.attribute "threshold" (String.fromFloat value_)


{-| Exclude this heading from the table of contents generated by an `m3e-toc` component. `m3e-toc-ignore` is a valueless presence marker the `m3e-toc` reads from heading elements; it is not an `m3e-heading` CEM attribute, so it is injected here as a heading-scoped synthetic capability.
-}
tocIgnore : Bool -> Attr { c | tocIgnore : Supported } msg
tocIgnore value_ =
    if value_ then
        Ir.attribute "m3e-toc-ignore" ""

    else
        Ir.none


{-| Today's date. (default: `new Date()`)
-}
today : String -> Attr { c | today : Supported } msg
today =
    Ir.attribute "today"


{-| Whether the button will toggle between selected and unselected states. (default: `false`)
-}
toggle : Bool -> Attr { c | toggle : Supported } msg
toggle value_ =
    if value_ then
        Ir.attribute "toggle" ""

    else
        Ir.none


{-| Whether the ripple is visible outside the element's bounds. (default: `false`)
-}
unbounded : Bool -> Attr { c | unbounded : Supported } msg
unbounded value_ =
    if value_ then
        Ir.attribute "unbounded" ""

    else
        Ir.none


{-| Validation messages mapped to individual error types.
-}
validationmessages : String -> Attr { c | validationmessages : Supported } msg
validationmessages =
    Ir.attribute "validationMessages"


{-| A string representing the value of the switch. (default: `"on"`)

Sets the LIVE DOM property `value`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultValue`.

-}
value : String -> Attr { c | value : Supported } msg
value value_ =
    Ir.property "value" (Json.Encode.string value_)


{-| Whether the element is oriented vertically. (default: `false`)
-}
vertical : Bool -> Attr { c | vertical : Supported } msg
vertical value_ =
    if value_ then
        Ir.attribute "vertical" ""

    else
        Ir.none


{-| A value from 100 to 700 indicating the weight of the icon. (default: `400`)
-}
weight : Int -> Attr { c | weight : Supported } msg
weight value_ =
    Ir.attribute "weight" (String.fromInt value_)


{-| Whether items wrap to a new line. (default: `false`)
-}
wrap : Bool -> Attr { c | wrap : Supported } msg
wrap value_ =
    if value_ then
        Ir.attribute "wrap" ""

    else
        Ir.none


{-| Whether cycling through detents will wrap. (default: `false`)
-}
wrapDetents : Bool -> Attr { c | wrapDetents : Supported } msg
wrapDetents value_ =
    if value_ then
        Ir.attribute "wrap-detents" ""

    else
        Ir.none


{-| The accessible label given to the year segment. (default: `"Year"`)
-}
yearLabel : String -> Attr { c | yearLabel : Supported } msg
yearLabel =
    Ir.attribute "year-label"


{-| Set the `checked` CONTENT attribute — the element's DEFAULT/initial `checked`, mirroring HTML's own `defaultChecked` IDL attribute. Unlike `checked` (which writes the live DOM property) this one SERIALIZES: it is what server-rendered markup and `outerHTML` show, and it is what a form reset restores to.
-}
defaultChecked : Bool -> Attr { c | checked : Supported } msg
defaultChecked value_ =
    if value_ then
        Ir.attribute "checked" ""

    else
        Ir.none


{-| Set the `selected` CONTENT attribute — the element's DEFAULT/initial `selected`, mirroring HTML's own `defaultSelected` IDL attribute. Unlike `selected` (which writes the live DOM property) this one SERIALIZES: it is what server-rendered markup and `outerHTML` show, and it is what a form reset restores to. Pair it with `selected` for the live state; see that setter's resync caveat.
-}
defaultSelected : Bool -> Attr { c | selected : Supported } msg
defaultSelected value_ =
    if value_ then
        Ir.attribute "selected" ""

    else
        Ir.none


{-| Set the `value` CONTENT attribute — the element's DEFAULT/initial `value`, mirroring HTML's own `defaultValue` IDL attribute. Unlike `value` (which writes the live DOM property) this one SERIALIZES: it is what server-rendered markup and `outerHTML` show, and it is what a form reset restores to.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    Ir.attribute "value"


{-| The animation effect of the skeleton. (default: `"wave"`)
-}
animation : Value M3e.Values.Animation -> Attr { c | animation : Supported } msg
animation value_ =
    Ir.attribute "animation" (HtmlIr.Value.toString value_)


{-| The contrast level of the theme. (default: `"standard"`)
-}
contrast : Value M3e.Values.Contrast -> Attr { c | contrast : Supported } msg
contrast value_ =
    Ir.attribute "contrast" (HtmlIr.Value.toString value_)


{-| Indicates the current item in the breadcrumb path.
-}
current : Value M3e.Values.Current -> Attr { c | current : Supported } msg
current value_ =
    Ir.attribute "current" (HtmlIr.Value.toString value_)


{-| Whether scroll buttons are disabled.
-}
disablePagination : Value M3e.Values.DisablePagination -> Attr { c | disablePagination : Supported } msg
disablePagination value_ =
    Ir.attribute "disable-pagination" (HtmlIr.Value.toString value_)


{-| The dividers used to separate scrollable content. (default: `"above-below"`)
-}
dividers : Value M3e.Values.Dividers -> Attr { c | dividers : Supported } msg
dividers value_ =
    Ir.attribute "dividers" (HtmlIr.Value.toString value_)


{-| The behavior mode of the end drawer. (default: `"side"`)
-}
endMode : Value M3e.Values.EndMode -> Attr { c | endMode : Supported } msg
endMode value_ =
    Ir.attribute "end-mode" (HtmlIr.Value.toString value_)


{-| Mode in which to filter options. (default: `"contains"`)
-}
filter : Value M3e.Values.Filter -> Attr { c | filter : Supported } msg
filter value_ =
    Ir.attribute "filter" (HtmlIr.Value.toString value_)


{-| Specifies whether the label should float always or only when necessary. (default: `"auto"`)
-}
floatLabel : Value M3e.Values.FloatLabel -> Attr { c | floatLabel : Supported } msg
floatLabel value_ =
    Ir.attribute "float-label" (HtmlIr.Value.toString value_)


{-| Whether to use a 12‑hour or 24‑hour clock. (default: `"12"`)
-}
format : Value M3e.Values.Format -> Attr { c | format : Supported } msg
format value_ =
    Ir.attribute "format" (HtmlIr.Value.toString value_)


{-| The grade of the icon. (default: `"medium"`)
-}
grade : Value M3e.Values.Grade -> Attr { c | grade : Supported } msg
grade value_ =
    Ir.attribute "grade" (HtmlIr.Value.toString value_)


{-| The position of the tab headers. (default: `"before"`)
-}
headerPosition : Value M3e.Values.HeaderPosition -> Attr { c | headerPosition : Supported } msg
headerPosition value_ =
    Ir.attribute "header-position" (HtmlIr.Value.toString value_)


{-| Whether subscript content is hidden. (default: `"auto"`)
-}
hideSubscript : Value M3e.Values.HideSubscript -> Attr { c | hideSubscript : Supported } msg
hideSubscript value_ =
    Ir.attribute "hide-subscript" (HtmlIr.Value.toString value_)


{-| The mode in which to highlight a term. (default: `"contains"`)
-}
highlightMode : Value M3e.Values.HighlightMode -> Attr { c | highlightMode : Supported } msg
highlightMode value_ =
    Ir.attribute "highlight-mode" (HtmlIr.Value.toString value_)


{-| The icons to present. (default: `"none"`)
-}
icons : Value M3e.Values.Icons -> Attr { c | icons : Supported } msg
icons value_ =
    Ir.attribute "icons" (HtmlIr.Value.toString value_)


{-| The position of the step labels, when oriented horizontally. (default: `"end"`)
-}
labelPosition : Value M3e.Values.LabelPosition -> Attr { c | labelPosition : Supported } msg
labelPosition value_ =
    Ir.attribute "label-position" (HtmlIr.Value.toString value_)


{-| The mode in which to select time. (default: `"dial"`)
-}
mode : Value M3e.Values.Mode -> Attr { c | mode : Supported } msg
mode value_ =
    Ir.attribute "mode" (HtmlIr.Value.toString value_)


{-| The motion scheme. (default: `"standard"`)
-}
motion : Value M3e.Values.Motion -> Attr { c | motion : Supported } msg
motion value_ =
    Ir.attribute "motion" (HtmlIr.Value.toString value_)


{-| The name that identifies the element when submitting the associated form.
-}
name : Value M3e.Values.Name -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" (HtmlIr.Value.toString value_)


{-| The orientation of the toggle. (default: `"vertical"`)
-}
orientation : Value M3e.Values.Orientation -> Attr { c | orientation : Supported } msg
orientation value_ =
    Ir.attribute "orientation" (HtmlIr.Value.toString value_)


{-| The appearance variant of the page size field. (default: `"outlined"`)
-}
pageSizeVariant : Value M3e.Values.PageSizeVariant -> Attr { c | pageSizeVariant : Supported } msg
pageSizeVariant value_ =
    Ir.attribute "page-size-variant" (HtmlIr.Value.toString value_)


{-| The 12-hour time period. (default: `"am"`)
-}
period : Value M3e.Values.Period -> Attr { c | period : Supported } msg
period value_ =
    Ir.attribute "period" (HtmlIr.Value.toString value_)


{-| The position of the tooltip. (default: `"below"`)
-}
position : Value M3e.Values.Position -> Attr { c | position : Supported } msg
position value_ =
    Ir.attribute "position" (HtmlIr.Value.toString value_)


{-| The position of the menu, on the x-axis. (default: `"after"`)
-}
positionX : Value M3e.Values.PositionX -> Attr { c | positionX : Supported } msg
positionX value_ =
    Ir.attribute "position-x" (HtmlIr.Value.toString value_)


{-| The position of the menu, on the y-axis. (default: `"below"`)
-}
positionY : Value M3e.Values.PositionY -> Attr { c | positionY : Supported } msg
positionY value_ =
    Ir.attribute "position-y" (HtmlIr.Value.toString value_)


{-| The color scheme of the theme. (default: `"auto"`)
-}
scheme : Value M3e.Values.Scheme -> Attr { c | scheme : Supported } msg
scheme value_ =
    Ir.attribute "scheme" (HtmlIr.Value.toString value_)


{-| The strategy that controls how the panel behaves when its trigger scrolls. (default: `"hide"`)
-}
scrollStrategy : Value M3e.Values.ScrollStrategy -> Attr { c | scrollStrategy : Supported } msg
scrollStrategy value_ =
    Ir.attribute "scroll-strategy" (HtmlIr.Value.toString value_)


{-| The shape of the toolbar. (default: `"square"`)
-}
shape : Value M3e.Values.Shape -> Attr { c | shape : Supported } msg
shape value_ =
    Ir.attribute "shape" (HtmlIr.Value.toString value_)


{-| The size of the button. (default: `"small"`)
-}
size : Value M3e.Values.Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (HtmlIr.Value.toString value_)


{-| The behavior mode of the start drawer. (default: `"side"`)
-}
startMode : Value M3e.Values.StartMode -> Attr { c | startMode : Supported } msg
startMode value_ =
    Ir.attribute "start-mode" (HtmlIr.Value.toString value_)


{-| The initial view used to select a date. (default: `"month"`)
-}
startView : Value M3e.Values.StartView -> Attr { c | startView : Supported } msg
startView value_ =
    Ir.attribute "start-view" (HtmlIr.Value.toString value_)


{-| The state for which to present content. (default: `"content"`)
-}
state : Value M3e.Values.State -> Attr { c | state : Supported } msg
state value_ =
    Ir.attribute "state" (HtmlIr.Value.toString value_)


{-| Format used when editing time values. (default: `"12"`)
-}
timeFormat : Value M3e.Values.TimeFormat -> Attr { c | timeFormat : Supported } msg
timeFormat value_ =
    Ir.attribute "time-format" (HtmlIr.Value.toString value_)


{-| The direction of the expansion toggle. (default: `"vertical"`)
-}
toggleDirection : Value M3e.Values.ToggleDirection -> Attr { c | toggleDirection : Supported } msg
toggleDirection value_ =
    Ir.attribute "toggle-direction" (HtmlIr.Value.toString value_)


{-| The position of the expansion toggle. (default: `"after"`)
-}
togglePosition : Value M3e.Values.TogglePosition -> Attr { c | togglePosition : Supported } msg
togglePosition value_ =
    Ir.attribute "toggle-position" (HtmlIr.Value.toString value_)


{-| The mode in which to handle touch gestures. (default: `"auto"`)
-}
touchGestures : Value M3e.Values.TouchGestures -> Attr { c | touchGestures : Supported } msg
touchGestures value_ =
    Ir.attribute "touch-gestures" (HtmlIr.Value.toString value_)


{-| The type of the element. (default: `"button"`)
-}
type_ : Value M3e.Values.Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (HtmlIr.Value.toString value_)


{-| The appearance variant of the toolbar. (default: `"standard"`)
-}
variant : Value M3e.Values.Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (HtmlIr.Value.toString value_)


{-| The view used to input time. (default: `"hour"`)
-}
viewAttr : Value M3e.Values.ViewAttr -> Attr { c | viewAttr : Supported } msg
viewAttr value_ =
    Ir.attribute "view" (HtmlIr.Value.toString value_)


{-| The width of the button. (default: `"default"`)
-}
width : Value M3e.Values.Width -> Attr { c | width : Supported } msg
width value_ =
    Ir.attribute "width" (HtmlIr.Value.toString value_)


{-| Set the `animation` attribute to `"none"`. Portmanteau of `animation` + `none` — for IDE discovery and single-import ergonomics.
-}
animationNone : Attr { c | animation : Supported } msg
animationNone =
    Ir.attribute "animation" "none"


{-| Set the `animation` attribute to `"pulse"`. Portmanteau of `animation` + `pulse` — for IDE discovery and single-import ergonomics.
-}
animationPulse : Attr { c | animation : Supported } msg
animationPulse =
    Ir.attribute "animation" "pulse"


{-| Set the `animation` attribute to `"wave"`. Portmanteau of `animation` + `wave` — for IDE discovery and single-import ergonomics.
-}
animationWave : Attr { c | animation : Supported } msg
animationWave =
    Ir.attribute "animation" "wave"


{-| Set the `contrast` attribute to `"high"`. Portmanteau of `contrast` + `high` — for IDE discovery and single-import ergonomics.
-}
contrastHigh : Attr { c | contrast : Supported } msg
contrastHigh =
    Ir.attribute "contrast" "high"


{-| Set the `contrast` attribute to `"medium"`. Portmanteau of `contrast` + `medium` — for IDE discovery and single-import ergonomics.
-}
contrastMedium : Attr { c | contrast : Supported } msg
contrastMedium =
    Ir.attribute "contrast" "medium"


{-| Set the `contrast` attribute to `"standard"`. Portmanteau of `contrast` + `standard` — for IDE discovery and single-import ergonomics.
-}
contrastStandard : Attr { c | contrast : Supported } msg
contrastStandard =
    Ir.attribute "contrast" "standard"


{-| Set the `current` attribute to `"date"`. Portmanteau of `current` + `date` — for IDE discovery and single-import ergonomics.
-}
currentDate : Attr { c | current : Supported } msg
currentDate =
    Ir.attribute "current" "date"


{-| Set the `current` attribute to `"location"`. Portmanteau of `current` + `location` — for IDE discovery and single-import ergonomics.
-}
currentLocation : Attr { c | current : Supported } msg
currentLocation =
    Ir.attribute "current" "location"


{-| Set the `current` attribute to `"page"`. Portmanteau of `current` + `page` — for IDE discovery and single-import ergonomics.
-}
currentPage : Attr { c | current : Supported } msg
currentPage =
    Ir.attribute "current" "page"


{-| Set the `current` attribute to `"step"`. Portmanteau of `current` + `step` — for IDE discovery and single-import ergonomics.
-}
currentStep : Attr { c | current : Supported } msg
currentStep =
    Ir.attribute "current" "step"


{-| Set the `current` attribute to `"time"`. Portmanteau of `current` + `time` — for IDE discovery and single-import ergonomics.
-}
currentTime : Attr { c | current : Supported } msg
currentTime =
    Ir.attribute "current" "time"


{-| Set the `current` attribute to `"true"`. Portmanteau of `current` + `true` — for IDE discovery and single-import ergonomics.
-}
currentTrue : Attr { c | current : Supported } msg
currentTrue =
    Ir.attribute "current" "true"


{-| Set the `disable-pagination` attribute to `"auto"`. Portmanteau of `disablePagination` + `auto` — for IDE discovery and single-import ergonomics.
-}
disablePaginationAuto : Attr { c | disablePagination : Supported } msg
disablePaginationAuto =
    Ir.attribute "disable-pagination" "auto"


{-| Set the `disable-pagination` attribute to `"false"`. Portmanteau of `disablePagination` + `false` — for IDE discovery and single-import ergonomics.
-}
disablePaginationFalse : Attr { c | disablePagination : Supported } msg
disablePaginationFalse =
    Ir.attribute "disable-pagination" "false"


{-| Set the `disable-pagination` attribute to `"true"`. Portmanteau of `disablePagination` + `true` — for IDE discovery and single-import ergonomics.
-}
disablePaginationTrue : Attr { c | disablePagination : Supported } msg
disablePaginationTrue =
    Ir.attribute "disable-pagination" "true"


{-| Set the `dividers` attribute to `"above"`. Portmanteau of `dividers` + `above` — for IDE discovery and single-import ergonomics.
-}
dividersAbove : Attr { c | dividers : Supported } msg
dividersAbove =
    Ir.attribute "dividers" "above"


{-| Set the `dividers` attribute to `"above-below"`. Portmanteau of `dividers` + `above-below` — for IDE discovery and single-import ergonomics.
-}
dividersAboveBelow : Attr { c | dividers : Supported } msg
dividersAboveBelow =
    Ir.attribute "dividers" "above-below"


{-| Set the `dividers` attribute to `"below"`. Portmanteau of `dividers` + `below` — for IDE discovery and single-import ergonomics.
-}
dividersBelow : Attr { c | dividers : Supported } msg
dividersBelow =
    Ir.attribute "dividers" "below"


{-| Set the `dividers` attribute to `"none"`. Portmanteau of `dividers` + `none` — for IDE discovery and single-import ergonomics.
-}
dividersNone : Attr { c | dividers : Supported } msg
dividersNone =
    Ir.attribute "dividers" "none"


{-| Set the `end-mode` attribute to `"auto"`. Portmanteau of `endMode` + `auto` — for IDE discovery and single-import ergonomics.
-}
endModeAuto : Attr { c | endMode : Supported } msg
endModeAuto =
    Ir.attribute "end-mode" "auto"


{-| Set the `end-mode` attribute to `"over"`. Portmanteau of `endMode` + `over` — for IDE discovery and single-import ergonomics.
-}
endModeOver : Attr { c | endMode : Supported } msg
endModeOver =
    Ir.attribute "end-mode" "over"


{-| Set the `end-mode` attribute to `"push"`. Portmanteau of `endMode` + `push` — for IDE discovery and single-import ergonomics.
-}
endModePush : Attr { c | endMode : Supported } msg
endModePush =
    Ir.attribute "end-mode" "push"


{-| Set the `end-mode` attribute to `"side"`. Portmanteau of `endMode` + `side` — for IDE discovery and single-import ergonomics.
-}
endModeSide : Attr { c | endMode : Supported } msg
endModeSide =
    Ir.attribute "end-mode" "side"


{-| Set the `filter` attribute to `"contains"`. Portmanteau of `filter` + `contains` — for IDE discovery and single-import ergonomics.
-}
filterContains : Attr { c | filter : Supported } msg
filterContains =
    Ir.attribute "filter" "contains"


{-| Set the `filter` attribute to `"ends-with"`. Portmanteau of `filter` + `ends-with` — for IDE discovery and single-import ergonomics.
-}
filterEndsWith : Attr { c | filter : Supported } msg
filterEndsWith =
    Ir.attribute "filter" "ends-with"


{-| Set the `filter` attribute to `"none"`. Portmanteau of `filter` + `none` — for IDE discovery and single-import ergonomics.
-}
filterNone : Attr { c | filter : Supported } msg
filterNone =
    Ir.attribute "filter" "none"


{-| Set the `filter` attribute to `"starts-with"`. Portmanteau of `filter` + `starts-with` — for IDE discovery and single-import ergonomics.
-}
filterStartsWith : Attr { c | filter : Supported } msg
filterStartsWith =
    Ir.attribute "filter" "starts-with"


{-| Set the `float-label` attribute to `"always"`. Portmanteau of `floatLabel` + `always` — for IDE discovery and single-import ergonomics.
-}
floatLabelAlways : Attr { c | floatLabel : Supported } msg
floatLabelAlways =
    Ir.attribute "float-label" "always"


{-| Set the `float-label` attribute to `"auto"`. Portmanteau of `floatLabel` + `auto` — for IDE discovery and single-import ergonomics.
-}
floatLabelAuto : Attr { c | floatLabel : Supported } msg
floatLabelAuto =
    Ir.attribute "float-label" "auto"


{-| Set the `format` attribute to `"12"`. Portmanteau of `format` + `12` — for IDE discovery and single-import ergonomics.
-}
formatValue12 : Attr { c | format : Supported } msg
formatValue12 =
    Ir.attribute "format" "12"


{-| Set the `format` attribute to `"24"`. Portmanteau of `format` + `24` — for IDE discovery and single-import ergonomics.
-}
formatValue24 : Attr { c | format : Supported } msg
formatValue24 =
    Ir.attribute "format" "24"


{-| Set the `format` attribute to `"auto"`. Portmanteau of `format` + `auto` — for IDE discovery and single-import ergonomics.
-}
formatAuto : Attr { c | format : Supported } msg
formatAuto =
    Ir.attribute "format" "auto"


{-| Set the `grade` attribute to `"high"`. Portmanteau of `grade` + `high` — for IDE discovery and single-import ergonomics.
-}
gradeHigh : Attr { c | grade : Supported } msg
gradeHigh =
    Ir.attribute "grade" "high"


{-| Set the `grade` attribute to `"low"`. Portmanteau of `grade` + `low` — for IDE discovery and single-import ergonomics.
-}
gradeLow : Attr { c | grade : Supported } msg
gradeLow =
    Ir.attribute "grade" "low"


{-| Set the `grade` attribute to `"medium"`. Portmanteau of `grade` + `medium` — for IDE discovery and single-import ergonomics.
-}
gradeMedium : Attr { c | grade : Supported } msg
gradeMedium =
    Ir.attribute "grade" "medium"


{-| Set the `header-position` attribute to `"above"`. Portmanteau of `headerPosition` + `above` — for IDE discovery and single-import ergonomics.
-}
headerPositionAbove : Attr { c | headerPosition : Supported } msg
headerPositionAbove =
    Ir.attribute "header-position" "above"


{-| Set the `header-position` attribute to `"after"`. Portmanteau of `headerPosition` + `after` — for IDE discovery and single-import ergonomics.
-}
headerPositionAfter : Attr { c | headerPosition : Supported } msg
headerPositionAfter =
    Ir.attribute "header-position" "after"


{-| Set the `header-position` attribute to `"before"`. Portmanteau of `headerPosition` + `before` — for IDE discovery and single-import ergonomics.
-}
headerPositionBefore : Attr { c | headerPosition : Supported } msg
headerPositionBefore =
    Ir.attribute "header-position" "before"


{-| Set the `header-position` attribute to `"below"`. Portmanteau of `headerPosition` + `below` — for IDE discovery and single-import ergonomics.
-}
headerPositionBelow : Attr { c | headerPosition : Supported } msg
headerPositionBelow =
    Ir.attribute "header-position" "below"


{-| Set the `hide-subscript` attribute to `"always"`. Portmanteau of `hideSubscript` + `always` — for IDE discovery and single-import ergonomics.
-}
hideSubscriptAlways : Attr { c | hideSubscript : Supported } msg
hideSubscriptAlways =
    Ir.attribute "hide-subscript" "always"


{-| Set the `hide-subscript` attribute to `"auto"`. Portmanteau of `hideSubscript` + `auto` — for IDE discovery and single-import ergonomics.
-}
hideSubscriptAuto : Attr { c | hideSubscript : Supported } msg
hideSubscriptAuto =
    Ir.attribute "hide-subscript" "auto"


{-| Set the `hide-subscript` attribute to `"never"`. Portmanteau of `hideSubscript` + `never` — for IDE discovery and single-import ergonomics.
-}
hideSubscriptNever : Attr { c | hideSubscript : Supported } msg
hideSubscriptNever =
    Ir.attribute "hide-subscript" "never"


{-| Set the `highlight-mode` attribute to `"contains"`. Portmanteau of `highlightMode` + `contains` — for IDE discovery and single-import ergonomics.
-}
highlightModeContains : Attr { c | highlightMode : Supported } msg
highlightModeContains =
    Ir.attribute "highlight-mode" "contains"


{-| Set the `highlight-mode` attribute to `"ends-with"`. Portmanteau of `highlightMode` + `ends-with` — for IDE discovery and single-import ergonomics.
-}
highlightModeEndsWith : Attr { c | highlightMode : Supported } msg
highlightModeEndsWith =
    Ir.attribute "highlight-mode" "ends-with"


{-| Set the `highlight-mode` attribute to `"starts-with"`. Portmanteau of `highlightMode` + `starts-with` — for IDE discovery and single-import ergonomics.
-}
highlightModeStartsWith : Attr { c | highlightMode : Supported } msg
highlightModeStartsWith =
    Ir.attribute "highlight-mode" "starts-with"


{-| Set the `icons` attribute to `"both"`. Portmanteau of `icons` + `both` — for IDE discovery and single-import ergonomics.
-}
iconsBoth : Attr { c | icons : Supported } msg
iconsBoth =
    Ir.attribute "icons" "both"


{-| Set the `icons` attribute to `"none"`. Portmanteau of `icons` + `none` — for IDE discovery and single-import ergonomics.
-}
iconsNone : Attr { c | icons : Supported } msg
iconsNone =
    Ir.attribute "icons" "none"


{-| Set the `icons` attribute to `"selected"`. Portmanteau of `icons` + `selected` — for IDE discovery and single-import ergonomics.
-}
iconsSelected : Attr { c | icons : Supported } msg
iconsSelected =
    Ir.attribute "icons" "selected"


{-| Set the `label-position` attribute to `"below"`. Portmanteau of `labelPosition` + `below` — for IDE discovery and single-import ergonomics.
-}
labelPositionBelow : Attr { c | labelPosition : Supported } msg
labelPositionBelow =
    Ir.attribute "label-position" "below"


{-| Set the `label-position` attribute to `"end"`. Portmanteau of `labelPosition` + `end` — for IDE discovery and single-import ergonomics.
-}
labelPositionEnd : Attr { c | labelPosition : Supported } msg
labelPositionEnd =
    Ir.attribute "label-position" "end"


{-| Set the `mode` attribute to `"auto"`. Portmanteau of `mode` + `auto` — for IDE discovery and single-import ergonomics.
-}
modeAuto : Attr { c | mode : Supported } msg
modeAuto =
    Ir.attribute "mode" "auto"


{-| Set the `mode` attribute to `"buffer"`. Portmanteau of `mode` + `buffer` — for IDE discovery and single-import ergonomics.
-}
modeBuffer : Attr { c | mode : Supported } msg
modeBuffer =
    Ir.attribute "mode" "buffer"


{-| Set the `mode` attribute to `"compact"`. Portmanteau of `mode` + `compact` — for IDE discovery and single-import ergonomics.
-}
modeCompact : Attr { c | mode : Supported } msg
modeCompact =
    Ir.attribute "mode" "compact"


{-| Set the `mode` attribute to `"contains"`. Portmanteau of `mode` + `contains` — for IDE discovery and single-import ergonomics.
-}
modeContains : Attr { c | mode : Supported } msg
modeContains =
    Ir.attribute "mode" "contains"


{-| Set the `mode` attribute to `"determinate"`. Portmanteau of `mode` + `determinate` — for IDE discovery and single-import ergonomics.
-}
modeDeterminate : Attr { c | mode : Supported } msg
modeDeterminate =
    Ir.attribute "mode" "determinate"


{-| Set the `mode` attribute to `"dial"`. Portmanteau of `mode` + `dial` — for IDE discovery and single-import ergonomics.
-}
modeDial : Attr { c | mode : Supported } msg
modeDial =
    Ir.attribute "mode" "dial"


{-| Set the `mode` attribute to `"docked"`. Portmanteau of `mode` + `docked` — for IDE discovery and single-import ergonomics.
-}
modeDocked : Attr { c | mode : Supported } msg
modeDocked =
    Ir.attribute "mode" "docked"


{-| Set the `mode` attribute to `"ends-with"`. Portmanteau of `mode` + `ends-with` — for IDE discovery and single-import ergonomics.
-}
modeEndsWith : Attr { c | mode : Supported } msg
modeEndsWith =
    Ir.attribute "mode" "ends-with"


{-| Set the `mode` attribute to `"expanded"`. Portmanteau of `mode` + `expanded` — for IDE discovery and single-import ergonomics.
-}
modeExpanded : Attr { c | mode : Supported } msg
modeExpanded =
    Ir.attribute "mode" "expanded"


{-| Set the `mode` attribute to `"fullscreen"`. Portmanteau of `mode` + `fullscreen` — for IDE discovery and single-import ergonomics.
-}
modeFullscreen : Attr { c | mode : Supported } msg
modeFullscreen =
    Ir.attribute "mode" "fullscreen"


{-| Set the `mode` attribute to `"indeterminate"`. Portmanteau of `mode` + `indeterminate` — for IDE discovery and single-import ergonomics.
-}
modeIndeterminate : Attr { c | mode : Supported } msg
modeIndeterminate =
    Ir.attribute "mode" "indeterminate"


{-| Set the `mode` attribute to `"input"`. Portmanteau of `mode` + `input` — for IDE discovery and single-import ergonomics.
-}
modeInput : Attr { c | mode : Supported } msg
modeInput =
    Ir.attribute "mode" "input"


{-| Set the `mode` attribute to `"query"`. Portmanteau of `mode` + `query` — for IDE discovery and single-import ergonomics.
-}
modeQuery : Attr { c | mode : Supported } msg
modeQuery =
    Ir.attribute "mode" "query"


{-| Set the `mode` attribute to `"starts-with"`. Portmanteau of `mode` + `starts-with` — for IDE discovery and single-import ergonomics.
-}
modeStartsWith : Attr { c | mode : Supported } msg
modeStartsWith =
    Ir.attribute "mode" "starts-with"


{-| Set the `motion` attribute to `"expressive"`. Portmanteau of `motion` + `expressive` — for IDE discovery and single-import ergonomics.
-}
motionExpressive : Attr { c | motion : Supported } msg
motionExpressive =
    Ir.attribute "motion" "expressive"


{-| Set the `motion` attribute to `"standard"`. Portmanteau of `motion` + `standard` — for IDE discovery and single-import ergonomics.
-}
motionStandard : Attr { c | motion : Supported } msg
motionStandard =
    Ir.attribute "motion" "standard"


{-| Set the `name` attribute to `"12-sided-cookie"`. Portmanteau of `name` + `12-sided-cookie` — for IDE discovery and single-import ergonomics.
-}
nameValue12SidedCookie : Attr { c | name : Supported } msg
nameValue12SidedCookie =
    Ir.attribute "name" "12-sided-cookie"


{-| Set the `name` attribute to `"4-leaf-clover"`. Portmanteau of `name` + `4-leaf-clover` — for IDE discovery and single-import ergonomics.
-}
nameValue4LeafClover : Attr { c | name : Supported } msg
nameValue4LeafClover =
    Ir.attribute "name" "4-leaf-clover"


{-| Set the `name` attribute to `"4-sided-cookie"`. Portmanteau of `name` + `4-sided-cookie` — for IDE discovery and single-import ergonomics.
-}
nameValue4SidedCookie : Attr { c | name : Supported } msg
nameValue4SidedCookie =
    Ir.attribute "name" "4-sided-cookie"


{-| Set the `name` attribute to `"6-sided-cookie"`. Portmanteau of `name` + `6-sided-cookie` — for IDE discovery and single-import ergonomics.
-}
nameValue6SidedCookie : Attr { c | name : Supported } msg
nameValue6SidedCookie =
    Ir.attribute "name" "6-sided-cookie"


{-| Set the `name` attribute to `"7-sided-cookie"`. Portmanteau of `name` + `7-sided-cookie` — for IDE discovery and single-import ergonomics.
-}
nameValue7SidedCookie : Attr { c | name : Supported } msg
nameValue7SidedCookie =
    Ir.attribute "name" "7-sided-cookie"


{-| Set the `name` attribute to `"8-leaf-clover"`. Portmanteau of `name` + `8-leaf-clover` — for IDE discovery and single-import ergonomics.
-}
nameValue8LeafClover : Attr { c | name : Supported } msg
nameValue8LeafClover =
    Ir.attribute "name" "8-leaf-clover"


{-| Set the `name` attribute to `"9-sided-cookie"`. Portmanteau of `name` + `9-sided-cookie` — for IDE discovery and single-import ergonomics.
-}
nameValue9SidedCookie : Attr { c | name : Supported } msg
nameValue9SidedCookie =
    Ir.attribute "name" "9-sided-cookie"


{-| Set the `name` attribute to `"arch"`. Portmanteau of `name` + `arch` — for IDE discovery and single-import ergonomics.
-}
nameArch : Attr { c | name : Supported } msg
nameArch =
    Ir.attribute "name" "arch"


{-| Set the `name` attribute to `"arrow"`. Portmanteau of `name` + `arrow` — for IDE discovery and single-import ergonomics.
-}
nameArrow : Attr { c | name : Supported } msg
nameArrow =
    Ir.attribute "name" "arrow"


{-| Set the `name` attribute to `"boom"`. Portmanteau of `name` + `boom` — for IDE discovery and single-import ergonomics.
-}
nameBoom : Attr { c | name : Supported } msg
nameBoom =
    Ir.attribute "name" "boom"


{-| Set the `name` attribute to `"bun"`. Portmanteau of `name` + `bun` — for IDE discovery and single-import ergonomics.
-}
nameBun : Attr { c | name : Supported } msg
nameBun =
    Ir.attribute "name" "bun"


{-| Set the `name` attribute to `"burst"`. Portmanteau of `name` + `burst` — for IDE discovery and single-import ergonomics.
-}
nameBurst : Attr { c | name : Supported } msg
nameBurst =
    Ir.attribute "name" "burst"


{-| Set the `name` attribute to `"circle"`. Portmanteau of `name` + `circle` — for IDE discovery and single-import ergonomics.
-}
nameCircle : Attr { c | name : Supported } msg
nameCircle =
    Ir.attribute "name" "circle"


{-| Set the `name` attribute to `"diamond"`. Portmanteau of `name` + `diamond` — for IDE discovery and single-import ergonomics.
-}
nameDiamond : Attr { c | name : Supported } msg
nameDiamond =
    Ir.attribute "name" "diamond"


{-| Set the `name` attribute to `"fan"`. Portmanteau of `name` + `fan` — for IDE discovery and single-import ergonomics.
-}
nameFan : Attr { c | name : Supported } msg
nameFan =
    Ir.attribute "name" "fan"


{-| Set the `name` attribute to `"flower"`. Portmanteau of `name` + `flower` — for IDE discovery and single-import ergonomics.
-}
nameFlower : Attr { c | name : Supported } msg
nameFlower =
    Ir.attribute "name" "flower"


{-| Set the `name` attribute to `"gem"`. Portmanteau of `name` + `gem` — for IDE discovery and single-import ergonomics.
-}
nameGem : Attr { c | name : Supported } msg
nameGem =
    Ir.attribute "name" "gem"


{-| Set the `name` attribute to `"ghost-ish"`. Portmanteau of `name` + `ghost-ish` — for IDE discovery and single-import ergonomics.
-}
nameGhostIsh : Attr { c | name : Supported } msg
nameGhostIsh =
    Ir.attribute "name" "ghost-ish"


{-| Set the `name` attribute to `"heart"`. Portmanteau of `name` + `heart` — for IDE discovery and single-import ergonomics.
-}
nameHeart : Attr { c | name : Supported } msg
nameHeart =
    Ir.attribute "name" "heart"


{-| Set the `name` attribute to `"hexagon"`. Portmanteau of `name` + `hexagon` — for IDE discovery and single-import ergonomics.
-}
nameHexagon : Attr { c | name : Supported } msg
nameHexagon =
    Ir.attribute "name" "hexagon"


{-| Set the `name` attribute to `"oval"`. Portmanteau of `name` + `oval` — for IDE discovery and single-import ergonomics.
-}
nameOval : Attr { c | name : Supported } msg
nameOval =
    Ir.attribute "name" "oval"


{-| Set the `name` attribute to `"pentagon"`. Portmanteau of `name` + `pentagon` — for IDE discovery and single-import ergonomics.
-}
namePentagon : Attr { c | name : Supported } msg
namePentagon =
    Ir.attribute "name" "pentagon"


{-| Set the `name` attribute to `"pill"`. Portmanteau of `name` + `pill` — for IDE discovery and single-import ergonomics.
-}
namePill : Attr { c | name : Supported } msg
namePill =
    Ir.attribute "name" "pill"


{-| Set the `name` attribute to `"pixel-circle"`. Portmanteau of `name` + `pixel-circle` — for IDE discovery and single-import ergonomics.
-}
namePixelCircle : Attr { c | name : Supported } msg
namePixelCircle =
    Ir.attribute "name" "pixel-circle"


{-| Set the `name` attribute to `"pixel-triangle"`. Portmanteau of `name` + `pixel-triangle` — for IDE discovery and single-import ergonomics.
-}
namePixelTriangle : Attr { c | name : Supported } msg
namePixelTriangle =
    Ir.attribute "name" "pixel-triangle"


{-| Set the `name` attribute to `"puffy"`. Portmanteau of `name` + `puffy` — for IDE discovery and single-import ergonomics.
-}
namePuffy : Attr { c | name : Supported } msg
namePuffy =
    Ir.attribute "name" "puffy"


{-| Set the `name` attribute to `"puffy-diamond"`. Portmanteau of `name` + `puffy-diamond` — for IDE discovery and single-import ergonomics.
-}
namePuffyDiamond : Attr { c | name : Supported } msg
namePuffyDiamond =
    Ir.attribute "name" "puffy-diamond"


{-| Set the `name` attribute to `"semicircle"`. Portmanteau of `name` + `semicircle` — for IDE discovery and single-import ergonomics.
-}
nameSemicircle : Attr { c | name : Supported } msg
nameSemicircle =
    Ir.attribute "name" "semicircle"


{-| Set the `name` attribute to `"slanted"`. Portmanteau of `name` + `slanted` — for IDE discovery and single-import ergonomics.
-}
nameSlanted : Attr { c | name : Supported } msg
nameSlanted =
    Ir.attribute "name" "slanted"


{-| Set the `name` attribute to `"soft-boom"`. Portmanteau of `name` + `soft-boom` — for IDE discovery and single-import ergonomics.
-}
nameSoftBoom : Attr { c | name : Supported } msg
nameSoftBoom =
    Ir.attribute "name" "soft-boom"


{-| Set the `name` attribute to `"soft-burst"`. Portmanteau of `name` + `soft-burst` — for IDE discovery and single-import ergonomics.
-}
nameSoftBurst : Attr { c | name : Supported } msg
nameSoftBurst =
    Ir.attribute "name" "soft-burst"


{-| Set the `name` attribute to `"square"`. Portmanteau of `name` + `square` — for IDE discovery and single-import ergonomics.
-}
nameSquare : Attr { c | name : Supported } msg
nameSquare =
    Ir.attribute "name" "square"


{-| Set the `name` attribute to `"sunny"`. Portmanteau of `name` + `sunny` — for IDE discovery and single-import ergonomics.
-}
nameSunny : Attr { c | name : Supported } msg
nameSunny =
    Ir.attribute "name" "sunny"


{-| Set the `name` attribute to `"triangle"`. Portmanteau of `name` + `triangle` — for IDE discovery and single-import ergonomics.
-}
nameTriangle : Attr { c | name : Supported } msg
nameTriangle =
    Ir.attribute "name" "triangle"


{-| Set the `name` attribute to `"very-sunny"`. Portmanteau of `name` + `very-sunny` — for IDE discovery and single-import ergonomics.
-}
nameVerySunny : Attr { c | name : Supported } msg
nameVerySunny =
    Ir.attribute "name" "very-sunny"


{-| Set the `orientation` attribute to `"auto"`. Portmanteau of `orientation` + `auto` — for IDE discovery and single-import ergonomics.
-}
orientationAuto : Attr { c | orientation : Supported } msg
orientationAuto =
    Ir.attribute "orientation" "auto"


{-| Set the `orientation` attribute to `"both"`. Portmanteau of `orientation` + `both` — for IDE discovery and single-import ergonomics.
-}
orientationBoth : Attr { c | orientation : Supported } msg
orientationBoth =
    Ir.attribute "orientation" "both"


{-| Set the `orientation` attribute to `"horizontal"`. Portmanteau of `orientation` + `horizontal` — for IDE discovery and single-import ergonomics.
-}
orientationHorizontal : Attr { c | orientation : Supported } msg
orientationHorizontal =
    Ir.attribute "orientation" "horizontal"


{-| Set the `orientation` attribute to `"vertical"`. Portmanteau of `orientation` + `vertical` — for IDE discovery and single-import ergonomics.
-}
orientationVertical : Attr { c | orientation : Supported } msg
orientationVertical =
    Ir.attribute "orientation" "vertical"


{-| Set the `page-size-variant` attribute to `"filled"`. Portmanteau of `pageSizeVariant` + `filled` — for IDE discovery and single-import ergonomics.
-}
pageSizeVariantFilled : Attr { c | pageSizeVariant : Supported } msg
pageSizeVariantFilled =
    Ir.attribute "page-size-variant" "filled"


{-| Set the `page-size-variant` attribute to `"outlined"`. Portmanteau of `pageSizeVariant` + `outlined` — for IDE discovery and single-import ergonomics.
-}
pageSizeVariantOutlined : Attr { c | pageSizeVariant : Supported } msg
pageSizeVariantOutlined =
    Ir.attribute "page-size-variant" "outlined"


{-| Set the `period` attribute to `"am"`. Portmanteau of `period` + `am` — for IDE discovery and single-import ergonomics.
-}
periodAm : Attr { c | period : Supported } msg
periodAm =
    Ir.attribute "period" "am"


{-| Set the `period` attribute to `"pm"`. Portmanteau of `period` + `pm` — for IDE discovery and single-import ergonomics.
-}
periodPm : Attr { c | period : Supported } msg
periodPm =
    Ir.attribute "period" "pm"


{-| Set the `position` attribute to `"above"`. Portmanteau of `position` + `above` — for IDE discovery and single-import ergonomics.
-}
positionAbove : Attr { c | position : Supported } msg
positionAbove =
    Ir.attribute "position" "above"


{-| Set the `position` attribute to `"above-after"`. Portmanteau of `position` + `above-after` — for IDE discovery and single-import ergonomics.
-}
positionAboveAfter : Attr { c | position : Supported } msg
positionAboveAfter =
    Ir.attribute "position" "above-after"


{-| Set the `position` attribute to `"above-before"`. Portmanteau of `position` + `above-before` — for IDE discovery and single-import ergonomics.
-}
positionAboveBefore : Attr { c | position : Supported } msg
positionAboveBefore =
    Ir.attribute "position" "above-before"


{-| Set the `position` attribute to `"after"`. Portmanteau of `position` + `after` — for IDE discovery and single-import ergonomics.
-}
positionAfter : Attr { c | position : Supported } msg
positionAfter =
    Ir.attribute "position" "after"


{-| Set the `position` attribute to `"before"`. Portmanteau of `position` + `before` — for IDE discovery and single-import ergonomics.
-}
positionBefore : Attr { c | position : Supported } msg
positionBefore =
    Ir.attribute "position" "before"


{-| Set the `position` attribute to `"below"`. Portmanteau of `position` + `below` — for IDE discovery and single-import ergonomics.
-}
positionBelow : Attr { c | position : Supported } msg
positionBelow =
    Ir.attribute "position" "below"


{-| Set the `position` attribute to `"below-after"`. Portmanteau of `position` + `below-after` — for IDE discovery and single-import ergonomics.
-}
positionBelowAfter : Attr { c | position : Supported } msg
positionBelowAfter =
    Ir.attribute "position" "below-after"


{-| Set the `position` attribute to `"below-before"`. Portmanteau of `position` + `below-before` — for IDE discovery and single-import ergonomics.
-}
positionBelowBefore : Attr { c | position : Supported } msg
positionBelowBefore =
    Ir.attribute "position" "below-before"


{-| Set the `position-x` attribute to `"after"`. Portmanteau of `positionX` + `after` — for IDE discovery and single-import ergonomics.
-}
positionXAfter : Attr { c | positionX : Supported } msg
positionXAfter =
    Ir.attribute "position-x" "after"


{-| Set the `position-x` attribute to `"before"`. Portmanteau of `positionX` + `before` — for IDE discovery and single-import ergonomics.
-}
positionXBefore : Attr { c | positionX : Supported } msg
positionXBefore =
    Ir.attribute "position-x" "before"


{-| Set the `position-y` attribute to `"above"`. Portmanteau of `positionY` + `above` — for IDE discovery and single-import ergonomics.
-}
positionYAbove : Attr { c | positionY : Supported } msg
positionYAbove =
    Ir.attribute "position-y" "above"


{-| Set the `position-y` attribute to `"below"`. Portmanteau of `positionY` + `below` — for IDE discovery and single-import ergonomics.
-}
positionYBelow : Attr { c | positionY : Supported } msg
positionYBelow =
    Ir.attribute "position-y" "below"


{-| Set the `scheme` attribute to `"auto"`. Portmanteau of `scheme` + `auto` — for IDE discovery and single-import ergonomics.
-}
schemeAuto : Attr { c | scheme : Supported } msg
schemeAuto =
    Ir.attribute "scheme" "auto"


{-| Set the `scheme` attribute to `"dark"`. Portmanteau of `scheme` + `dark` — for IDE discovery and single-import ergonomics.
-}
schemeDark : Attr { c | scheme : Supported } msg
schemeDark =
    Ir.attribute "scheme" "dark"


{-| Set the `scheme` attribute to `"light"`. Portmanteau of `scheme` + `light` — for IDE discovery and single-import ergonomics.
-}
schemeLight : Attr { c | scheme : Supported } msg
schemeLight =
    Ir.attribute "scheme" "light"


{-| Set the `scroll-strategy` attribute to `"hide"`. Portmanteau of `scrollStrategy` + `hide` — for IDE discovery and single-import ergonomics.
-}
scrollStrategyHide : Attr { c | scrollStrategy : Supported } msg
scrollStrategyHide =
    Ir.attribute "scroll-strategy" "hide"


{-| Set the `scroll-strategy` attribute to `"reposition"`. Portmanteau of `scrollStrategy` + `reposition` — for IDE discovery and single-import ergonomics.
-}
scrollStrategyReposition : Attr { c | scrollStrategy : Supported } msg
scrollStrategyReposition =
    Ir.attribute "scroll-strategy" "reposition"


{-| Set the `shape` attribute to `"auto"`. Portmanteau of `shape` + `auto` — for IDE discovery and single-import ergonomics.
-}
shapeAuto : Attr { c | shape : Supported } msg
shapeAuto =
    Ir.attribute "shape" "auto"


{-| Set the `shape` attribute to `"circular"`. Portmanteau of `shape` + `circular` — for IDE discovery and single-import ergonomics.
-}
shapeCircular : Attr { c | shape : Supported } msg
shapeCircular =
    Ir.attribute "shape" "circular"


{-| Set the `shape` attribute to `"rounded"`. Portmanteau of `shape` + `rounded` — for IDE discovery and single-import ergonomics.
-}
shapeRounded : Attr { c | shape : Supported } msg
shapeRounded =
    Ir.attribute "shape" "rounded"


{-| Set the `shape` attribute to `"square"`. Portmanteau of `shape` + `square` — for IDE discovery and single-import ergonomics.
-}
shapeSquare : Attr { c | shape : Supported } msg
shapeSquare =
    Ir.attribute "shape" "square"


{-| Set the `size` attribute to `"extra-large"`. Portmanteau of `size` + `extra-large` — for IDE discovery and single-import ergonomics.
-}
sizeExtraLarge : Attr { c | size : Supported } msg
sizeExtraLarge =
    Ir.attribute "size" "extra-large"


{-| Set the `size` attribute to `"extra-small"`. Portmanteau of `size` + `extra-small` — for IDE discovery and single-import ergonomics.
-}
sizeExtraSmall : Attr { c | size : Supported } msg
sizeExtraSmall =
    Ir.attribute "size" "extra-small"


{-| Set the `size` attribute to `"large"`. Portmanteau of `size` + `large` — for IDE discovery and single-import ergonomics.
-}
sizeLarge : Attr { c | size : Supported } msg
sizeLarge =
    Ir.attribute "size" "large"


{-| Set the `size` attribute to `"medium"`. Portmanteau of `size` + `medium` — for IDE discovery and single-import ergonomics.
-}
sizeMedium : Attr { c | size : Supported } msg
sizeMedium =
    Ir.attribute "size" "medium"


{-| Set the `size` attribute to `"small"`. Portmanteau of `size` + `small` — for IDE discovery and single-import ergonomics.
-}
sizeSmall : Attr { c | size : Supported } msg
sizeSmall =
    Ir.attribute "size" "small"


{-| Set the `start-mode` attribute to `"auto"`. Portmanteau of `startMode` + `auto` — for IDE discovery and single-import ergonomics.
-}
startModeAuto : Attr { c | startMode : Supported } msg
startModeAuto =
    Ir.attribute "start-mode" "auto"


{-| Set the `start-mode` attribute to `"over"`. Portmanteau of `startMode` + `over` — for IDE discovery and single-import ergonomics.
-}
startModeOver : Attr { c | startMode : Supported } msg
startModeOver =
    Ir.attribute "start-mode" "over"


{-| Set the `start-mode` attribute to `"push"`. Portmanteau of `startMode` + `push` — for IDE discovery and single-import ergonomics.
-}
startModePush : Attr { c | startMode : Supported } msg
startModePush =
    Ir.attribute "start-mode" "push"


{-| Set the `start-mode` attribute to `"side"`. Portmanteau of `startMode` + `side` — for IDE discovery and single-import ergonomics.
-}
startModeSide : Attr { c | startMode : Supported } msg
startModeSide =
    Ir.attribute "start-mode" "side"


{-| Set the `start-view` attribute to `"month"`. Portmanteau of `startView` + `month` — for IDE discovery and single-import ergonomics.
-}
startViewMonth : Attr { c | startView : Supported } msg
startViewMonth =
    Ir.attribute "start-view" "month"


{-| Set the `start-view` attribute to `"multi-year"`. Portmanteau of `startView` + `multi-year` — for IDE discovery and single-import ergonomics.
-}
startViewMultiYear : Attr { c | startView : Supported } msg
startViewMultiYear =
    Ir.attribute "start-view" "multi-year"


{-| Set the `start-view` attribute to `"year"`. Portmanteau of `startView` + `year` — for IDE discovery and single-import ergonomics.
-}
startViewYear : Attr { c | startView : Supported } msg
startViewYear =
    Ir.attribute "start-view" "year"


{-| Set the `state` attribute to `"content"`. Portmanteau of `state` + `content` — for IDE discovery and single-import ergonomics.
-}
stateContent : Attr { c | state : Supported } msg
stateContent =
    Ir.attribute "state" "content"


{-| Set the `state` attribute to `"loading"`. Portmanteau of `state` + `loading` — for IDE discovery and single-import ergonomics.
-}
stateLoading : Attr { c | state : Supported } msg
stateLoading =
    Ir.attribute "state" "loading"


{-| Set the `state` attribute to `"no-data"`. Portmanteau of `state` + `no-data` — for IDE discovery and single-import ergonomics.
-}
stateNoData : Attr { c | state : Supported } msg
stateNoData =
    Ir.attribute "state" "no-data"


{-| Set the `time-format` attribute to `"12"`. Portmanteau of `timeFormat` + `12` — for IDE discovery and single-import ergonomics.
-}
timeFormatValue12 : Attr { c | timeFormat : Supported } msg
timeFormatValue12 =
    Ir.attribute "time-format" "12"


{-| Set the `time-format` attribute to `"24"`. Portmanteau of `timeFormat` + `24` — for IDE discovery and single-import ergonomics.
-}
timeFormatValue24 : Attr { c | timeFormat : Supported } msg
timeFormatValue24 =
    Ir.attribute "time-format" "24"


{-| Set the `time-format` attribute to `"auto"`. Portmanteau of `timeFormat` + `auto` — for IDE discovery and single-import ergonomics.
-}
timeFormatAuto : Attr { c | timeFormat : Supported } msg
timeFormatAuto =
    Ir.attribute "time-format" "auto"


{-| Set the `toggle-direction` attribute to `"horizontal"`. Portmanteau of `toggleDirection` + `horizontal` — for IDE discovery and single-import ergonomics.
-}
toggleDirectionHorizontal : Attr { c | toggleDirection : Supported } msg
toggleDirectionHorizontal =
    Ir.attribute "toggle-direction" "horizontal"


{-| Set the `toggle-direction` attribute to `"vertical"`. Portmanteau of `toggleDirection` + `vertical` — for IDE discovery and single-import ergonomics.
-}
toggleDirectionVertical : Attr { c | toggleDirection : Supported } msg
toggleDirectionVertical =
    Ir.attribute "toggle-direction" "vertical"


{-| Set the `toggle-position` attribute to `"after"`. Portmanteau of `togglePosition` + `after` — for IDE discovery and single-import ergonomics.
-}
togglePositionAfter : Attr { c | togglePosition : Supported } msg
togglePositionAfter =
    Ir.attribute "toggle-position" "after"


{-| Set the `toggle-position` attribute to `"before"`. Portmanteau of `togglePosition` + `before` — for IDE discovery and single-import ergonomics.
-}
togglePositionBefore : Attr { c | togglePosition : Supported } msg
togglePositionBefore =
    Ir.attribute "toggle-position" "before"


{-| Set the `touch-gestures` attribute to `"auto"`. Portmanteau of `touchGestures` + `auto` — for IDE discovery and single-import ergonomics.
-}
touchGesturesAuto : Attr { c | touchGestures : Supported } msg
touchGesturesAuto =
    Ir.attribute "touch-gestures" "auto"


{-| Set the `touch-gestures` attribute to `"off"`. Portmanteau of `touchGestures` + `off` — for IDE discovery and single-import ergonomics.
-}
touchGesturesOff : Attr { c | touchGestures : Supported } msg
touchGesturesOff =
    Ir.attribute "touch-gestures" "off"


{-| Set the `touch-gestures` attribute to `"on"`. Portmanteau of `touchGestures` + `on` — for IDE discovery and single-import ergonomics.
-}
touchGesturesOn : Attr { c | touchGestures : Supported } msg
touchGesturesOn =
    Ir.attribute "touch-gestures" "on"


{-| Set the `type` attribute to `"button"`. Portmanteau of `type_` + `button` — for IDE discovery and single-import ergonomics.
-}
type_Button : Attr { c | type_ : Supported } msg
type_Button =
    Ir.attribute "type" "button"


{-| Set the `type` attribute to `"date"`. Portmanteau of `type_` + `date` — for IDE discovery and single-import ergonomics.
-}
type_Date : Attr { c | type_ : Supported } msg
type_Date =
    Ir.attribute "type" "date"


{-| Set the `type` attribute to `"datetime"`. Portmanteau of `type_` + `datetime` — for IDE discovery and single-import ergonomics.
-}
type_Datetime : Attr { c | type_ : Supported } msg
type_Datetime =
    Ir.attribute "type" "datetime"


{-| Set the `type` attribute to `"reset"`. Portmanteau of `type_` + `reset` — for IDE discovery and single-import ergonomics.
-}
type_Reset : Attr { c | type_ : Supported } msg
type_Reset =
    Ir.attribute "type" "reset"


{-| Set the `type` attribute to `"submit"`. Portmanteau of `type_` + `submit` — for IDE discovery and single-import ergonomics.
-}
type_Submit : Attr { c | type_ : Supported } msg
type_Submit =
    Ir.attribute "type" "submit"


{-| Set the `type` attribute to `"time"`. Portmanteau of `type_` + `time` — for IDE discovery and single-import ergonomics.
-}
type_Time : Attr { c | type_ : Supported } msg
type_Time =
    Ir.attribute "type" "time"


{-| Set the `variant` attribute to `"auto"`. Portmanteau of `variant` + `auto` — for IDE discovery and single-import ergonomics.
-}
variantAuto : Attr { c | variant : Supported } msg
variantAuto =
    Ir.attribute "variant" "auto"


{-| Set the `variant` attribute to `"connected"`. Portmanteau of `variant` + `connected` — for IDE discovery and single-import ergonomics.
-}
variantConnected : Attr { c | variant : Supported } msg
variantConnected =
    Ir.attribute "variant" "connected"


{-| Set the `variant` attribute to `"contained"`. Portmanteau of `variant` + `contained` — for IDE discovery and single-import ergonomics.
-}
variantContained : Attr { c | variant : Supported } msg
variantContained =
    Ir.attribute "variant" "contained"


{-| Set the `variant` attribute to `"content"`. Portmanteau of `variant` + `content` — for IDE discovery and single-import ergonomics.
-}
variantContent : Attr { c | variant : Supported } msg
variantContent =
    Ir.attribute "variant" "content"


{-| Set the `variant` attribute to `"display"`. Portmanteau of `variant` + `display` — for IDE discovery and single-import ergonomics.
-}
variantDisplay : Attr { c | variant : Supported } msg
variantDisplay =
    Ir.attribute "variant" "display"


{-| Set the `variant` attribute to `"docked"`. Portmanteau of `variant` + `docked` — for IDE discovery and single-import ergonomics.
-}
variantDocked : Attr { c | variant : Supported } msg
variantDocked =
    Ir.attribute "variant" "docked"


{-| Set the `variant` attribute to `"elevated"`. Portmanteau of `variant` + `elevated` — for IDE discovery and single-import ergonomics.
-}
variantElevated : Attr { c | variant : Supported } msg
variantElevated =
    Ir.attribute "variant" "elevated"


{-| Set the `variant` attribute to `"expressive"`. Portmanteau of `variant` + `expressive` — for IDE discovery and single-import ergonomics.
-}
variantExpressive : Attr { c | variant : Supported } msg
variantExpressive =
    Ir.attribute "variant" "expressive"


{-| Set the `variant` attribute to `"fidelity"`. Portmanteau of `variant` + `fidelity` — for IDE discovery and single-import ergonomics.
-}
variantFidelity : Attr { c | variant : Supported } msg
variantFidelity =
    Ir.attribute "variant" "fidelity"


{-| Set the `variant` attribute to `"filled"`. Portmanteau of `variant` + `filled` — for IDE discovery and single-import ergonomics.
-}
variantFilled : Attr { c | variant : Supported } msg
variantFilled =
    Ir.attribute "variant" "filled"


{-| Set the `variant` attribute to `"flat"`. Portmanteau of `variant` + `flat` — for IDE discovery and single-import ergonomics.
-}
variantFlat : Attr { c | variant : Supported } msg
variantFlat =
    Ir.attribute "variant" "flat"


{-| Set the `variant` attribute to `"fruit-salad"`. Portmanteau of `variant` + `fruit-salad` — for IDE discovery and single-import ergonomics.
-}
variantFruitSalad : Attr { c | variant : Supported } msg
variantFruitSalad =
    Ir.attribute "variant" "fruit-salad"


{-| Set the `variant` attribute to `"headline"`. Portmanteau of `variant` + `headline` — for IDE discovery and single-import ergonomics.
-}
variantHeadline : Attr { c | variant : Supported } msg
variantHeadline =
    Ir.attribute "variant" "headline"


{-| Set the `variant` attribute to `"label"`. Portmanteau of `variant` + `label` — for IDE discovery and single-import ergonomics.
-}
variantLabel : Attr { c | variant : Supported } msg
variantLabel =
    Ir.attribute "variant" "label"


{-| Set the `variant` attribute to `"modal"`. Portmanteau of `variant` + `modal` — for IDE discovery and single-import ergonomics.
-}
variantModal : Attr { c | variant : Supported } msg
variantModal =
    Ir.attribute "variant" "modal"


{-| Set the `variant` attribute to `"monochrome"`. Portmanteau of `variant` + `monochrome` — for IDE discovery and single-import ergonomics.
-}
variantMonochrome : Attr { c | variant : Supported } msg
variantMonochrome =
    Ir.attribute "variant" "monochrome"


{-| Set the `variant` attribute to `"neutral"`. Portmanteau of `variant` + `neutral` — for IDE discovery and single-import ergonomics.
-}
variantNeutral : Attr { c | variant : Supported } msg
variantNeutral =
    Ir.attribute "variant" "neutral"


{-| Set the `variant` attribute to `"outlined"`. Portmanteau of `variant` + `outlined` — for IDE discovery and single-import ergonomics.
-}
variantOutlined : Attr { c | variant : Supported } msg
variantOutlined =
    Ir.attribute "variant" "outlined"


{-| Set the `variant` attribute to `"primary"`. Portmanteau of `variant` + `primary` — for IDE discovery and single-import ergonomics.
-}
variantPrimary : Attr { c | variant : Supported } msg
variantPrimary =
    Ir.attribute "variant" "primary"


{-| Set the `variant` attribute to `"primary-container"`. Portmanteau of `variant` + `primary-container` — for IDE discovery and single-import ergonomics.
-}
variantPrimaryContainer : Attr { c | variant : Supported } msg
variantPrimaryContainer =
    Ir.attribute "variant" "primary-container"


{-| Set the `variant` attribute to `"rainbow"`. Portmanteau of `variant` + `rainbow` — for IDE discovery and single-import ergonomics.
-}
variantRainbow : Attr { c | variant : Supported } msg
variantRainbow =
    Ir.attribute "variant" "rainbow"


{-| Set the `variant` attribute to `"rounded"`. Portmanteau of `variant` + `rounded` — for IDE discovery and single-import ergonomics.
-}
variantRounded : Attr { c | variant : Supported } msg
variantRounded =
    Ir.attribute "variant" "rounded"


{-| Set the `variant` attribute to `"secondary"`. Portmanteau of `variant` + `secondary` — for IDE discovery and single-import ergonomics.
-}
variantSecondary : Attr { c | variant : Supported } msg
variantSecondary =
    Ir.attribute "variant" "secondary"


{-| Set the `variant` attribute to `"secondary-container"`. Portmanteau of `variant` + `secondary-container` — for IDE discovery and single-import ergonomics.
-}
variantSecondaryContainer : Attr { c | variant : Supported } msg
variantSecondaryContainer =
    Ir.attribute "variant" "secondary-container"


{-| Set the `variant` attribute to `"segmented"`. Portmanteau of `variant` + `segmented` — for IDE discovery and single-import ergonomics.
-}
variantSegmented : Attr { c | variant : Supported } msg
variantSegmented =
    Ir.attribute "variant" "segmented"


{-| Set the `variant` attribute to `"sharp"`. Portmanteau of `variant` + `sharp` — for IDE discovery and single-import ergonomics.
-}
variantSharp : Attr { c | variant : Supported } msg
variantSharp =
    Ir.attribute "variant" "sharp"


{-| Set the `variant` attribute to `"standard"`. Portmanteau of `variant` + `standard` — for IDE discovery and single-import ergonomics.
-}
variantStandard : Attr { c | variant : Supported } msg
variantStandard =
    Ir.attribute "variant" "standard"


{-| Set the `variant` attribute to `"surface"`. Portmanteau of `variant` + `surface` — for IDE discovery and single-import ergonomics.
-}
variantSurface : Attr { c | variant : Supported } msg
variantSurface =
    Ir.attribute "variant" "surface"


{-| Set the `variant` attribute to `"tertiary"`. Portmanteau of `variant` + `tertiary` — for IDE discovery and single-import ergonomics.
-}
variantTertiary : Attr { c | variant : Supported } msg
variantTertiary =
    Ir.attribute "variant" "tertiary"


{-| Set the `variant` attribute to `"tertiary-container"`. Portmanteau of `variant` + `tertiary-container` — for IDE discovery and single-import ergonomics.
-}
variantTertiaryContainer : Attr { c | variant : Supported } msg
variantTertiaryContainer =
    Ir.attribute "variant" "tertiary-container"


{-| Set the `variant` attribute to `"text"`. Portmanteau of `variant` + `text` — for IDE discovery and single-import ergonomics.
-}
variantText : Attr { c | variant : Supported } msg
variantText =
    Ir.attribute "variant" "text"


{-| Set the `variant` attribute to `"title"`. Portmanteau of `variant` + `title` — for IDE discovery and single-import ergonomics.
-}
variantTitle : Attr { c | variant : Supported } msg
variantTitle =
    Ir.attribute "variant" "title"


{-| Set the `variant` attribute to `"tonal"`. Portmanteau of `variant` + `tonal` — for IDE discovery and single-import ergonomics.
-}
variantTonal : Attr { c | variant : Supported } msg
variantTonal =
    Ir.attribute "variant" "tonal"


{-| Set the `variant` attribute to `"tonal-spot"`. Portmanteau of `variant` + `tonal-spot` — for IDE discovery and single-import ergonomics.
-}
variantTonalSpot : Attr { c | variant : Supported } msg
variantTonalSpot =
    Ir.attribute "variant" "tonal-spot"


{-| Set the `variant` attribute to `"uncontained"`. Portmanteau of `variant` + `uncontained` — for IDE discovery and single-import ergonomics.
-}
variantUncontained : Attr { c | variant : Supported } msg
variantUncontained =
    Ir.attribute "variant" "uncontained"


{-| Set the `variant` attribute to `"vibrant"`. Portmanteau of `variant` + `vibrant` — for IDE discovery and single-import ergonomics.
-}
variantVibrant : Attr { c | variant : Supported } msg
variantVibrant =
    Ir.attribute "variant" "vibrant"


{-| Set the `variant` attribute to `"wavy"`. Portmanteau of `variant` + `wavy` — for IDE discovery and single-import ergonomics.
-}
variantWavy : Attr { c | variant : Supported } msg
variantWavy =
    Ir.attribute "variant" "wavy"


{-| Set the `view` attribute to `"hour"`. Portmanteau of `viewAttr` + `hour` — for IDE discovery and single-import ergonomics.
-}
viewAttrHour : Attr { c | viewAttr : Supported } msg
viewAttrHour =
    Ir.attribute "view" "hour"


{-| Set the `view` attribute to `"minute"`. Portmanteau of `viewAttr` + `minute` — for IDE discovery and single-import ergonomics.
-}
viewAttrMinute : Attr { c | viewAttr : Supported } msg
viewAttrMinute =
    Ir.attribute "view" "minute"


{-| Set the `view` attribute to `"second"`. Portmanteau of `viewAttr` + `second` — for IDE discovery and single-import ergonomics.
-}
viewAttrSecond : Attr { c | viewAttr : Supported } msg
viewAttrSecond =
    Ir.attribute "view" "second"


{-| Set the `width` attribute to `"default"`. Portmanteau of `width` + `default` — for IDE discovery and single-import ergonomics.
-}
widthDefault : Attr { c | width : Supported } msg
widthDefault =
    Ir.attribute "width" "default"


{-| Set the `width` attribute to `"narrow"`. Portmanteau of `width` + `narrow` — for IDE discovery and single-import ergonomics.
-}
widthNarrow : Attr { c | width : Supported } msg
widthNarrow =
    Ir.attribute "width" "narrow"


{-| Set the `width` attribute to `"wide"`. Portmanteau of `width` + `wide` — for IDE discovery and single-import ergonomics.
-}
widthWide : Attr { c | width : Supported } msg
widthWide =
    Ir.attribute "width" "wide"
