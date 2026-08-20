module Sl.Attributes exposing
    ( class, id, slot, style, classList, styleList
    , active, allowScripts, alt, anchor, arrow, arrowPadding, attr, attrOldValue, autoSizePadding, autocomplete, autofocus, autoplay, autoplayInterval, autosizeboundary, background, caret, charData, charDataOldValue, checked, childList, circle, clearable, closable, contained, content, copyLabel, currency, date, delay, direction, disabled, distance, download, duration, easing, endDelay, errorLabel, expanded, feedbackDuration, fill, filled, fixedScrollControls, flip, flipFallbackPlacements, flipPadding, flipboundary, form, formnovalidate, from, getsymbol, gettag, helpText, hoist, hoverBridge, href, image, indeterminate, initials, inline, iterationStart, iterations, label, lazy, library, loop, max, maxOptionsVisible, maximumFractionDigits, maximumSignificantDigits, maxlength, min, minimumFractionDigits, minimumIntegerDigits, minimumSignificantDigits, minlength, mouseDragging, multiple, name, navigation, noFormatToggle, noGrouping, noHeader, noScrollControls, noSpinButtons, opacity, open, outline, pagination, panel, passwordToggle, passwordVisible, pattern, pill, placeholder, play, playbackRate, position, positionInPixels, precision, pulse, radius, readonly, rel, removable, required, rows, selected, shift, shiftPadding, shiftboundary, skidding, slidesPerMove, slidesPerPage, snap, snapThreshold, spellcheck, src, stayOpenOnSelect, step, successLabel, summary, swatches, timeZone, title, trigger, uppercase, value, vertical
    , defaultChecked, defaultSelected, defaultValue
    , activation, arrowPlacement, autoSize, autocapitalize, autocorrect, countdown, currencyDisplay, day, display, effect_, enterkeyhint, era, errorCorrection, flipFallbackStrategy, format, formenctype, formmethod, formtarget, hour, hourFormat, inputmode, loading, minute, mode, month, numeric, orientation, placement, primary, resize, second, selection, shape, size, strategy, sync, target, timeZoneName, tooltip, tooltipPlacement, type_, unit, variant, weekday, year
    , activationAuto, activationManual, arrowPlacementAnchor, arrowPlacementCenter, arrowPlacementEnd, arrowPlacementStart, autoSizeBoth, autoSizeHorizontal, autoSizeVertical, autocapitalizeCharacters, autocapitalizeNone, autocapitalizeOff, autocapitalizeOn, autocapitalizeSentences, autocapitalizeWords, autocorrectOff, autocorrectOn, countdownLtr, countdownRtl, currencyDisplayCode, currencyDisplayName, currencyDisplayNarrowsymbol, currencyDisplaySymbol, dayValue2Digit, dayNumeric, displayLong, displayNarrow, displayShort, effect_None, effect_Pulse, effect_Sheen, enterkeyhintDone, enterkeyhintEnter, enterkeyhintGo, enterkeyhintNext, enterkeyhintPrevious, enterkeyhintSearch, enterkeyhintSend, eraLong, eraNarrow, eraShort, errorCorrectionH, errorCorrectionL, errorCorrectionM, errorCorrectionQ, flipFallbackStrategyBestFit, flipFallbackStrategyInitial, formatHex, formatHsl, formatHsv, formatLong, formatNarrow, formatRgb, formatShort, formenctypeApplicationXWwwFormUrlencoded, formenctypeMultipartFormData, formenctypeTextPlain, formmethodGet, formmethodPost, formtargetBlank_, formtargetParent_, formtargetSelf_, formtargetTop_, hourValue2Digit, hourNumeric, hourFormatValue12, hourFormatValue24, hourFormatAuto, inputmodeDecimal, inputmodeEmail, inputmodeNone, inputmodeNumeric, inputmodeSearch, inputmodeTel, inputmodeText, inputmodeUrl, loadingEager, loadingLazy, minuteValue2Digit, minuteNumeric, modeCors, modeNoCors, modeSameOrigin, monthValue2Digit, monthLong, monthNarrow, monthNumeric, monthShort, numericAlways, numericAuto, orientationHorizontal, orientationVertical, placementBottom, placementBottomEnd, placementBottomStart, placementEnd, placementLeft, placementLeftEnd, placementLeftStart, placementRight, placementRightEnd, placementRightStart, placementStart, placementTop, placementTopEnd, placementTopStart, primaryEnd, primaryStart, resizeAuto, resizeNone, resizeVertical, secondValue2Digit, secondNumeric, selectionLeaf, selectionMultiple, selectionSingle, shapeCircle, shapeRounded, shapeSquare, sizeLarge, sizeMedium, sizeSmall, strategyAbsolute, strategyFixed, syncBoth, syncHeight, syncWidth, targetBlank_, targetParent_, targetSelf_, targetTop_, timeZoneNameLong, timeZoneNameShort, tooltipBottom, tooltipNone, tooltipTop, tooltipPlacementBottom, tooltipPlacementLeft, tooltipPlacementRight, tooltipPlacementTop, type_Button, type_Checkbox, type_Currency, type_Date, type_DatetimeLocal, type_Decimal, type_Email, type_Normal, type_Number, type_Password, type_Percent, type_Reset, type_Search, type_Submit, type_Tel, type_Text, type_Time, type_Url, unitBit, unitByte, variantDanger, variantDefault, variantNeutral, variantPrimary, variantSuccess, variantText, variantWarning, weekdayLong, weekdayNarrow, weekdayShort, yearValue2Digit, yearNumeric
    )

{-| The canonical shared attribute vocabulary. Every setter is an open
producer (`{ c | attr : Supported }`); each element's closed `Attrs` row
decides admittance. Enum setters here close over the library-wide UNION of
values — cross-component misuse is caught by elm-review; reach for the
per-component setters (`Sl.<Component>.<attr>`) for compile-tight narrowing.

Portmanteau setters (`variantRainbow`, `shapeRounded`, …) are nullary
aliases that pre-apply one enum token. They exist for IDE discovery:
type `variant` and autocomplete lists every value inline. Each claims
the same capability row as its base enum setter, so admittance is identical.

**Deliberately absent.** These attributes are declared by the manifest and
are real HTML, but `elm/virtual-dom` cannot write them, so this library does
not pretend to: a setter would compile, render, and silently do something
else. None of them is reachable from Elm at all — reach for a port or a
custom element instead of restoring a setter here.

  - `formaction` — `_VirtualDom_noOnOrFormAction` rewrites every `VirtualDom.attribute` key matching `/^(on|formAction$)/i` to `data-` ++ key, so this would render as `data-formaction` and never as `formaction`. The property form is closed too — `_VirtualDom_noInnerHtmlOrFormAction` rewrites the exact key `formAction`, and the lowercase key is an inert expando no element observes — so there is no working path from Elm.

@docs class, id, slot, style, classList, styleList
@docs active, allowScripts, alt, anchor, arrow, arrowPadding, attr, attrOldValue, autoSizePadding, autocomplete, autofocus, autoplay, autoplayInterval, autosizeboundary, background, caret, charData, charDataOldValue, checked, childList, circle, clearable, closable, contained, content, copyLabel, currency, date, delay, direction, disabled, distance, download, duration, easing, endDelay, errorLabel, expanded, feedbackDuration, fill, filled, fixedScrollControls, flip, flipFallbackPlacements, flipPadding, flipboundary, form, formnovalidate, from, getsymbol, gettag, helpText, hoist, hoverBridge, href, image, indeterminate, initials, inline, iterationStart, iterations, label, lazy, library, loop, max, maxOptionsVisible, maximumFractionDigits, maximumSignificantDigits, maxlength, min, minimumFractionDigits, minimumIntegerDigits, minimumSignificantDigits, minlength, mouseDragging, multiple, name, navigation, noFormatToggle, noGrouping, noHeader, noScrollControls, noSpinButtons, opacity, open, outline, pagination, panel, passwordToggle, passwordVisible, pattern, pill, placeholder, play, playbackRate, position, positionInPixels, precision, pulse, radius, readonly, rel, removable, required, rows, selected, shift, shiftPadding, shiftboundary, skidding, slidesPerMove, slidesPerPage, snap, snapThreshold, spellcheck, src, stayOpenOnSelect, step, successLabel, summary, swatches, timeZone, title, trigger, uppercase, value, vertical
@docs defaultChecked, defaultSelected, defaultValue
@docs activation, arrowPlacement, autoSize, autocapitalize, autocorrect, countdown, currencyDisplay, day, display, effect_, enterkeyhint, era, errorCorrection, flipFallbackStrategy, format, formenctype, formmethod, formtarget, hour, hourFormat, inputmode, loading, minute, mode, month, numeric, orientation, placement, primary, resize, second, selection, shape, size, strategy, sync, target, timeZoneName, tooltip, tooltipPlacement, type_, unit, variant, weekday, year
@docs activationAuto, activationManual, arrowPlacementAnchor, arrowPlacementCenter, arrowPlacementEnd, arrowPlacementStart, autoSizeBoth, autoSizeHorizontal, autoSizeVertical, autocapitalizeCharacters, autocapitalizeNone, autocapitalizeOff, autocapitalizeOn, autocapitalizeSentences, autocapitalizeWords, autocorrectOff, autocorrectOn, countdownLtr, countdownRtl, currencyDisplayCode, currencyDisplayName, currencyDisplayNarrowsymbol, currencyDisplaySymbol, dayValue2Digit, dayNumeric, displayLong, displayNarrow, displayShort, effect_None, effect_Pulse, effect_Sheen, enterkeyhintDone, enterkeyhintEnter, enterkeyhintGo, enterkeyhintNext, enterkeyhintPrevious, enterkeyhintSearch, enterkeyhintSend, eraLong, eraNarrow, eraShort, errorCorrectionH, errorCorrectionL, errorCorrectionM, errorCorrectionQ, flipFallbackStrategyBestFit, flipFallbackStrategyInitial, formatHex, formatHsl, formatHsv, formatLong, formatNarrow, formatRgb, formatShort, formenctypeApplicationXWwwFormUrlencoded, formenctypeMultipartFormData, formenctypeTextPlain, formmethodGet, formmethodPost, formtargetBlank_, formtargetParent_, formtargetSelf_, formtargetTop_, hourValue2Digit, hourNumeric, hourFormatValue12, hourFormatValue24, hourFormatAuto, inputmodeDecimal, inputmodeEmail, inputmodeNone, inputmodeNumeric, inputmodeSearch, inputmodeTel, inputmodeText, inputmodeUrl, loadingEager, loadingLazy, minuteValue2Digit, minuteNumeric, modeCors, modeNoCors, modeSameOrigin, monthValue2Digit, monthLong, monthNarrow, monthNumeric, monthShort, numericAlways, numericAuto, orientationHorizontal, orientationVertical, placementBottom, placementBottomEnd, placementBottomStart, placementEnd, placementLeft, placementLeftEnd, placementLeftStart, placementRight, placementRightEnd, placementRightStart, placementStart, placementTop, placementTopEnd, placementTopStart, primaryEnd, primaryStart, resizeAuto, resizeNone, resizeVertical, secondValue2Digit, secondNumeric, selectionLeaf, selectionMultiple, selectionSingle, shapeCircle, shapeRounded, shapeSquare, sizeLarge, sizeMedium, sizeSmall, strategyAbsolute, strategyFixed, syncBoth, syncHeight, syncWidth, targetBlank_, targetParent_, targetSelf_, targetTop_, timeZoneNameLong, timeZoneNameShort, tooltipBottom, tooltipNone, tooltipTop, tooltipPlacementBottom, tooltipPlacementLeft, tooltipPlacementRight, tooltipPlacementTop, type_Button, type_Checkbox, type_Currency, type_Date, type_DatetimeLocal, type_Decimal, type_Email, type_Normal, type_Number, type_Password, type_Percent, type_Reset, type_Search, type_Submit, type_Tel, type_Text, type_Time, type_Url, unitBit, unitByte, variantDanger, variantDefault, variantNeutral, variantPrimary, variantSuccess, variantText, variantWarning, weekdayLong, weekdayNarrow, weekdayShort, yearValue2Digit, yearNumeric

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import Sl.Values


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


{-| Activates the positioning logic and shows the popup. When this attribute is removed, the positioning logic is torn
down and the popup will be hidden. (default: `false`)
-}
active : Bool -> Attr { c | active : Supported } msg
active value_ =
    if value_ then
        Ir.attribute "active" ""

    else
        Ir.none


{-| Allows included scripts to be executed. Be sure you trust the content you are including as it will be executed as
code and can result in XSS attacks. (default: `false`)
-}
allowScripts : Bool -> Attr { c | allowScripts : Supported } msg
allowScripts value_ =
    if value_ then
        Ir.attribute "allow-scripts" ""

    else
        Ir.none


{-| A description of the image used by assistive devices.
-}
alt : String -> Attr { c | alt : Supported } msg
alt =
    Ir.attribute "alt"


{-| The element the popup will be anchored to. If the anchor lives outside of the popup, you can provide the anchor
element `id`, a DOM element reference, or a `VirtualElement`. If the anchor lives inside the popup, use the
`anchor` slot instead.
-}
anchor : String -> Attr { c | anchor : Supported } msg
anchor =
    Ir.attribute "anchor"


{-| Attaches an arrow to the popup. The arrow's size and color can be customized using the `--arrow-size` and
`--arrow-color` custom properties. For additional customizations, you can also target the arrow using
`::part(arrow)` in your stylesheet. (default: `false`)
-}
arrow : Bool -> Attr { c | arrow : Supported } msg
arrow value_ =
    if value_ then
        Ir.attribute "arrow" ""

    else
        Ir.none


{-| The amount of padding between the arrow and the edges of the popup. If the popup has a border-radius, for example,
this will prevent it from overflowing the corners. (default: `10`)
-}
arrowPadding : Float -> Attr { c | arrowPadding : Supported } msg
arrowPadding value_ =
    Ir.attribute "arrow-padding" (String.fromFloat value_)


{-| Watches for changes to attributes. To watch only specific attributes, separate them by a space, e.g.
`attr="class id title"`. To watch all attributes, use `*`.
-}
attr : String -> Attr { c | attr : Supported } msg
attr =
    Ir.attribute "attr"


{-| Indicates whether or not the attribute's previous value should be recorded when monitoring changes. (default: `false`)
-}
attrOldValue : Bool -> Attr { c | attrOldValue : Supported } msg
attrOldValue value_ =
    if value_ then
        Ir.attribute "attr-old-value" ""

    else
        Ir.none


{-| The amount of padding, in pixels, to exceed before the auto-size behavior will occur. (default: `0`)
-}
autoSizePadding : Float -> Attr { c | autoSizePadding : Supported } msg
autoSizePadding value_ =
    Ir.attribute "auto-size-padding" (String.fromFloat value_)


{-| Specifies what permission the browser has to provide assistance in filling out form field values. Refer to
[this page on MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/autocomplete) for available values.
-}
autocomplete : String -> Attr { c | autocomplete : Supported } msg
autocomplete =
    Ir.attribute "autocomplete"


{-| Indicates that the input should receive focus on page load.
-}
autofocus : Bool -> Attr { c | autofocus : Supported } msg
autofocus value_ =
    if value_ then
        Ir.attribute "autofocus" ""

    else
        Ir.none


{-| When set, the slides will scroll automatically when the user is not interacting with them. (default: `false`)
-}
autoplay : Bool -> Attr { c | autoplay : Supported } msg
autoplay value_ =
    if value_ then
        Ir.attribute "autoplay" ""

    else
        Ir.none


{-| Specifies the amount of time, in milliseconds, between each automatic scroll. (default: `3000`)
-}
autoplayInterval : Float -> Attr { c | autoplayInterval : Supported } msg
autoplayInterval value_ =
    Ir.attribute "autoplay-interval" (String.fromFloat value_)


{-| The auto-size boundary describes clipping element(s) that overflow will be checked relative to when resizing. By
default, the boundary includes overflow ancestors that will cause the element to be clipped. If needed, you can
change the boundary by passing a reference to one or more elements to this property.
-}
autosizeboundary : String -> Attr { c | autosizeboundary : Supported } msg
autosizeboundary =
    Ir.attribute "autoSizeBoundary"


{-| The background color. This can be any valid CSS color or `transparent`. It cannot be a CSS custom property. (default: `'white'`)
-}
background : String -> Attr { c | background : Supported } msg
background =
    Ir.attribute "background"


{-| Draws the button with a caret. Used to indicate that the button triggers a dropdown menu or similar behavior. (default: `false`)
-}
caret : Bool -> Attr { c | caret : Supported } msg
caret value_ =
    if value_ then
        Ir.attribute "caret" ""

    else
        Ir.none


{-| Watches for changes to the character data contained within the node. (default: `false`)
-}
charData : Bool -> Attr { c | charData : Supported } msg
charData value_ =
    if value_ then
        Ir.attribute "char-data" ""

    else
        Ir.none


{-| Indicates whether or not the previous value of the node's text should be recorded. (default: `false`)
-}
charDataOldValue : Bool -> Attr { c | charDataOldValue : Supported } msg
charDataOldValue value_ =
    if value_ then
        Ir.attribute "char-data-old-value" ""

    else
        Ir.none


{-| Draws the checkbox in a checked state. (default: `false`)

Sets the LIVE DOM property `checked`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultChecked`.

-}
checked : Bool -> Attr { c | checked : Supported } msg
checked value_ =
    Ir.property "checked" (Json.Encode.bool value_)


{-| Watches for the addition or removal of new child nodes. (default: `false`)
-}
childList : Bool -> Attr { c | childList : Supported } msg
childList value_ =
    if value_ then
        Ir.attribute "child-list" ""

    else
        Ir.none


{-| Draws a circular icon button. When this attribute is present, the button expects a single `<sl-icon>` in the
default slot. (default: `false`)
-}
circle : Bool -> Attr { c | circle : Supported } msg
circle value_ =
    if value_ then
        Ir.attribute "circle" ""

    else
        Ir.none


{-| Adds a clear button when the input is not empty. (default: `false`)
-}
clearable : Bool -> Attr { c | clearable : Supported } msg
clearable value_ =
    if value_ then
        Ir.attribute "clearable" ""

    else
        Ir.none


{-| Enables a close button that allows the user to dismiss the alert. (default: `false`)
-}
closable : Bool -> Attr { c | closable : Supported } msg
closable value_ =
    if value_ then
        Ir.attribute "closable" ""

    else
        Ir.none


{-| By default, the drawer slides out of its containing block (usually the viewport). To make the drawer slide out of
its parent element, set this attribute and add `position: relative` to the parent. (default: `false`)
-}
contained : Bool -> Attr { c | contained : Supported } msg
contained value_ =
    if value_ then
        Ir.attribute "contained" ""

    else
        Ir.none


{-| The tooltip's content. If you need to display HTML, use the `content` slot instead. (default: `''`)
-}
content : String -> Attr { c | content : Supported } msg
content =
    Ir.attribute "content"


{-| A custom label to show in the tooltip. (default: `''`)
-}
copyLabel : String -> Attr { c | copyLabel : Supported } msg
copyLabel =
    Ir.attribute "copy-label"


{-| The [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217) currency code to use when formatting. (default: `'USD'`)
-}
currency : String -> Attr { c | currency : Supported } msg
currency =
    Ir.attribute "currency"


{-| The date/time to format. If not set, the current date and time will be used. When passing a string, it's strongly
recommended to use the ISO 8601 format to ensure timezones are handled correctly. To convert a date to this format
in JavaScript, use [`date.toISOString()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/toISOString). (default: `new Date()`)
-}
date : String -> Attr { c | date : Supported } msg
date =
    Ir.attribute "date"


{-| The number of milliseconds to delay the start of the animation. (default: `0`)
-}
delay : Float -> Attr { c | delay : Supported } msg
delay value_ =
    Ir.attribute "delay" (String.fromFloat value_)


{-| Determines the direction of playback as well as the behavior when reaching the end of an iteration.
[Learn more](https://developer.mozilla.org/en-US/docs/Web/CSS/animation-direction) (default: `'normal'`)
-}
direction : String -> Attr { c | direction : Supported } msg
direction =
    Ir.attribute "direction"


{-| Disables the button. (default: `false`)
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled value_ =
    if value_ then
        Ir.attribute "disabled" ""

    else
        Ir.none


{-| The distance in pixels from which to offset the panel away from its trigger. (default: `0`)
-}
distance : Float -> Attr { c | distance : Supported } msg
distance value_ =
    Ir.attribute "distance" (String.fromFloat value_)


{-| Tells the browser to download the linked file as this filename. Only used when `href` is present.
-}
download : String -> Attr { c | download : Supported } msg
download =
    Ir.attribute "download"


{-| The length of time, in milliseconds, the alert will show before closing itself. If the user interacts with
the alert before it closes (e.g. moves the mouse over it), the timer will restart. Defaults to `Infinity`, meaning
the alert will not close on its own. (default: `Infinity`)
-}
duration : Float -> Attr { c | duration : Supported } msg
duration value_ =
    Ir.attribute "duration" (String.fromFloat value_)


{-| The easing function to use for the animation. This can be a Shoelace easing function or a custom easing function
such as `cubic-bezier(0, 1, .76, 1.14)`. (default: `'linear'`)
-}
easing : String -> Attr { c | easing : Supported } msg
easing =
    Ir.attribute "easing"


{-| The number of milliseconds to delay after the active period of an animation sequence. (default: `0`)
-}
endDelay : Float -> Attr { c | endDelay : Supported } msg
endDelay value_ =
    Ir.attribute "end-delay" (String.fromFloat value_)


{-| A custom label to show in the tooltip when a copy error occurs. (default: `''`)
-}
errorLabel : String -> Attr { c | errorLabel : Supported } msg
errorLabel =
    Ir.attribute "error-label"


{-| Expands the tree item. (default: `false`)
-}
expanded : Bool -> Attr { c | expanded : Supported } msg
expanded value_ =
    if value_ then
        Ir.attribute "expanded" ""

    else
        Ir.none


{-| The length of time to show feedback before restoring the default trigger. (default: `1000`)
-}
feedbackDuration : Float -> Attr { c | feedbackDuration : Supported } msg
feedbackDuration value_ =
    Ir.attribute "feedback-duration" (String.fromFloat value_)


{-| Sets how the animation applies styles to its target before and after its execution. (default: `'auto'`)
-}
fill : String -> Attr { c | fill : Supported } msg
fill =
    Ir.attribute "fill"


{-| Draws a filled input. (default: `false`)
-}
filled : Bool -> Attr { c | filled : Supported } msg
filled value_ =
    if value_ then
        Ir.attribute "filled" ""

    else
        Ir.none


{-| Prevent scroll buttons from being hidden when inactive. (default: `false`)
-}
fixedScrollControls : Bool -> Attr { c | fixedScrollControls : Supported } msg
fixedScrollControls value_ =
    if value_ then
        Ir.attribute "fixed-scroll-controls" ""

    else
        Ir.none


{-| When set, placement of the popup will flip to the opposite site to keep it in view. You can use
`flipFallbackPlacements` to further configure how the fallback placement is determined. (default: `false`)
-}
flip : Bool -> Attr { c | flip : Supported } msg
flip value_ =
    if value_ then
        Ir.attribute "flip" ""

    else
        Ir.none


{-| If the preferred placement doesn't fit, popup will be tested in these fallback placements until one fits. Must be a
string of any number of placements separated by a space, e.g. "top bottom left". If no placement fits, the flip
fallback strategy will be used instead. (default: `''`)
-}
flipFallbackPlacements : String -> Attr { c | flipFallbackPlacements : Supported } msg
flipFallbackPlacements =
    Ir.attribute "flip-fallback-placements"


{-| The amount of padding, in pixels, to exceed before the flip behavior will occur. (default: `0`)
-}
flipPadding : Float -> Attr { c | flipPadding : Supported } msg
flipPadding value_ =
    Ir.attribute "flip-padding" (String.fromFloat value_)


{-| The flip boundary describes clipping element(s) that overflow will be checked relative to when flipping. By
default, the boundary includes overflow ancestors that will cause the element to be clipped. If needed, you can
change the boundary by passing a reference to one or more elements to this property.
-}
flipboundary : String -> Attr { c | flipboundary : Supported } msg
flipboundary =
    Ir.attribute "flipBoundary"


{-| The "form owner" to associate the button with. If omitted, the closest containing form will be used instead. The
value of this attribute must be an id of a form in the same document or shadow root as the button.
-}
form : String -> Attr { c | form : Supported } msg
form =
    Ir.attribute "form"


{-| Used to override the form owner's `novalidate` attribute.
-}
formnovalidate : Bool -> Attr { c | formnovalidate : Supported } msg
formnovalidate value_ =
    if value_ then
        Ir.attribute "formnovalidate" ""

    else
        Ir.none


{-| An id that references an element in the same document from which data will be copied. If both this and `value` are
present, this value will take precedence. By default, the target element's `textContent` will be copied. To copy an
attribute, append the attribute name wrapped in square brackets, e.g. `from="el[value]"`. To copy a property,
append a dot and the property name, e.g. `from="el.value"`. (default: `''`)
-}
from : String -> Attr { c | from : Supported } msg
from =
    Ir.attribute "from"


{-| A function that customizes the symbol to be rendered. The first and only argument is the rating's current value.
The function should return a string containing trusted HTML of the symbol to render at the specified value. Works
well with `<sl-icon>` elements.
-}
getsymbol : String -> Attr { c | getsymbol : Supported } msg
getsymbol =
    Ir.attribute "getSymbol"


{-| A function that customizes the tags to be rendered when multiple=true. The first argument is the option, the second
is the current tag's index. The function should return either a Lit TemplateResult or a string containing trusted HTML of the symbol to render at
the specified value.
-}
gettag : String -> Attr { c | gettag : Supported } msg
gettag =
    Ir.attribute "getTag"


{-| The checkbox's help text. If you need to display HTML, use the `help-text` slot instead. (default: `''`)
-}
helpText : String -> Attr { c | helpText : Supported } msg
helpText =
    Ir.attribute "help-text"


{-| Enable this option to prevent the panel from being clipped when the component is placed inside a container with
`overflow: auto|scroll`. Hoisting uses a fixed positioning strategy that works in many, but not all, scenarios. (default: `false`)
-}
hoist : Bool -> Attr { c | hoist : Supported } msg
hoist value_ =
    if value_ then
        Ir.attribute "hoist" ""

    else
        Ir.none


{-| When a gap exists between the anchor and the popup element, this option will add a "hover bridge" that fills the
gap using an invisible element. This makes listening for events such as `mouseenter` and `mouseleave` more sane
because the pointer never technically leaves the element. The hover bridge will only be drawn when the popover is
active. (default: `false`)
-}
hoverBridge : Bool -> Attr { c | hoverBridge : Supported } msg
hoverBridge value_ =
    if value_ then
        Ir.attribute "hover-bridge" ""

    else
        Ir.none


{-| Optional URL to direct the user to when the breadcrumb item is activated. When set, a link will be rendered
internally. When unset, a button will be rendered instead.
-}
href : String -> Attr { c | href : Supported } msg
href =
    Ir.attribute "href"


{-| The image source to use for the avatar. (default: `''`)
-}
image : String -> Attr { c | image : Supported } msg
image =
    Ir.attribute "image"


{-| Draws the checkbox in an indeterminate state. This is usually applied to checkboxes that represents a "select
all/none" behavior when associated checkboxes have a mix of checked and unchecked states. (default: `false`)
-}
indeterminate : Bool -> Attr { c | indeterminate : Supported } msg
indeterminate value_ =
    if value_ then
        Ir.attribute "indeterminate" ""

    else
        Ir.none


{-| Initials to use as a fallback when no image is available (1-2 characters max recommended). (default: `''`)
-}
initials : String -> Attr { c | initials : Supported } msg
initials =
    Ir.attribute "initials"


{-| Renders the color picker inline rather than in a dropdown. (default: `false`)
-}
inline : Bool -> Attr { c | inline : Supported } msg
inline value_ =
    if value_ then
        Ir.attribute "inline" ""

    else
        Ir.none


{-| The offset at which to start the animation, usually between 0 (start) and 1 (end). (default: `0`)
-}
iterationStart : Float -> Attr { c | iterationStart : Supported } msg
iterationStart value_ =
    Ir.attribute "iteration-start" (String.fromFloat value_)


{-| The number of iterations to run before the animation completes. Defaults to `Infinity`, which loops. (default: `Infinity`)
-}
iterations : String -> Attr { c | iterations : Supported } msg
iterations =
    Ir.attribute "iterations"


{-| A label to use to describe the avatar to assistive devices. (default: `''`)
-}
label : String -> Attr { c | label : Supported } msg
label =
    Ir.attribute "label"


{-| Enables lazy loading behavior. (default: `false`)
-}
lazy : Bool -> Attr { c | lazy : Supported } msg
lazy value_ =
    if value_ then
        Ir.attribute "lazy" ""

    else
        Ir.none


{-| The name of a registered custom icon library. (default: `'default'`)
-}
library : String -> Attr { c | library : Supported } msg
library =
    Ir.attribute "library"


{-| When set, allows the user to navigate the carousel in the same direction indefinitely. (default: `false`)
-}
loop : Bool -> Attr { c | loop : Supported } msg
loop value_ =
    if value_ then
        Ir.attribute "loop" ""

    else
        Ir.none


{-| The input's maximum value. Only applies to date and number input types.
-}
max : String -> Attr { c | max : Supported } msg
max =
    Ir.attribute "max"


{-| The maximum number of selected options to show when `multiple` is true. After the maximum, "+n" will be shown to
indicate the number of additional items that are selected. Set to 0 to remove the limit. (default: `3`)
-}
maxOptionsVisible : Float -> Attr { c | maxOptionsVisible : Supported } msg
maxOptionsVisible value_ =
    Ir.attribute "max-options-visible" (String.fromFloat value_)


{-| The maximum number of fraction digits to use. Possible values are 0-0.
-}
maximumFractionDigits : Float -> Attr { c | maximumFractionDigits : Supported } msg
maximumFractionDigits value_ =
    Ir.attribute "maximum-fraction-digits" (String.fromFloat value_)


{-| The maximum number of significant digits to use,. Possible values are 1-21.
-}
maximumSignificantDigits : Float -> Attr { c | maximumSignificantDigits : Supported } msg
maximumSignificantDigits value_ =
    Ir.attribute "maximum-significant-digits" (String.fromFloat value_)


{-| The maximum length of input that will be considered valid.
-}
maxlength : Float -> Attr { c | maxlength : Supported } msg
maxlength value_ =
    Ir.attribute "maxlength" (String.fromFloat value_)


{-| The input's minimum value. Only applies to date and number input types.
-}
min : String -> Attr { c | min : Supported } msg
min =
    Ir.attribute "min"


{-| The minimum number of fraction digits to use. Possible values are 0-20.
-}
minimumFractionDigits : Float -> Attr { c | minimumFractionDigits : Supported } msg
minimumFractionDigits value_ =
    Ir.attribute "minimum-fraction-digits" (String.fromFloat value_)


{-| The minimum number of integer digits to use. Possible values are 1-21.
-}
minimumIntegerDigits : Float -> Attr { c | minimumIntegerDigits : Supported } msg
minimumIntegerDigits value_ =
    Ir.attribute "minimum-integer-digits" (String.fromFloat value_)


{-| The minimum number of significant digits to use. Possible values are 1-21.
-}
minimumSignificantDigits : Float -> Attr { c | minimumSignificantDigits : Supported } msg
minimumSignificantDigits value_ =
    Ir.attribute "minimum-significant-digits" (String.fromFloat value_)


{-| The minimum length of input that will be considered valid.
-}
minlength : Float -> Attr { c | minlength : Supported } msg
minlength value_ =
    Ir.attribute "minlength" (String.fromFloat value_)


{-| When set, it is possible to scroll through the slides by dragging them with the mouse. (default: `false`)
-}
mouseDragging : Bool -> Attr { c | mouseDragging : Supported } msg
mouseDragging value_ =
    if value_ then
        Ir.attribute "mouse-dragging" ""

    else
        Ir.none


{-| Allows more than one option to be selected. (default: `false`)
-}
multiple : Bool -> Attr { c | multiple : Supported } msg
multiple value_ =
    if value_ then
        Ir.attribute "multiple" ""

    else
        Ir.none


{-| The name of the built-in animation to use. For custom animations, use the `keyframes` prop. (default: `'none'`)
-}
name : String -> Attr { c | name : Supported } msg
name =
    Ir.attribute "name"


{-| When set, show the carousel's navigation. (default: `false`)
-}
navigation : Bool -> Attr { c | navigation : Supported } msg
navigation value_ =
    if value_ then
        Ir.attribute "navigation" ""

    else
        Ir.none


{-| Removes the button that lets users toggle between format. (default: `false`)
-}
noFormatToggle : Bool -> Attr { c | noFormatToggle : Supported } msg
noFormatToggle value_ =
    if value_ then
        Ir.attribute "no-format-toggle" ""

    else
        Ir.none


{-| Turns off grouping separators. (default: `false`)
-}
noGrouping : Bool -> Attr { c | noGrouping : Supported } msg
noGrouping value_ =
    if value_ then
        Ir.attribute "no-grouping" ""

    else
        Ir.none


{-| Disables the header. This will also remove the default close button, so please ensure you provide an easy,
accessible way for users to dismiss the dialog. (default: `false`)
-}
noHeader : Bool -> Attr { c | noHeader : Supported } msg
noHeader value_ =
    if value_ then
        Ir.attribute "no-header" ""

    else
        Ir.none


{-| Disables the scroll arrows that appear when tabs overflow. (default: `false`)
-}
noScrollControls : Bool -> Attr { c | noScrollControls : Supported } msg
noScrollControls value_ =
    if value_ then
        Ir.attribute "no-scroll-controls" ""

    else
        Ir.none


{-| Hides the browser's built-in increment/decrement spin buttons for number inputs. (default: `false`)
-}
noSpinButtons : Bool -> Attr { c | noSpinButtons : Supported } msg
noSpinButtons value_ =
    if value_ then
        Ir.attribute "no-spin-buttons" ""

    else
        Ir.none


{-| Shows the opacity slider. Enabling this will cause the formatted value to be HEXA, RGBA, or HSLA. (default: `false`)
-}
opacity : Bool -> Attr { c | opacity : Supported } msg
opacity value_ =
    if value_ then
        Ir.attribute "opacity" ""

    else
        Ir.none


{-| Indicates whether or not the alert is open. You can toggle this attribute to show and hide the alert, or you can
use the `show()` and `hide()` methods and this attribute will reflect the alert's open state. (default: `false`)
-}
open : Bool -> Attr { c | open : Supported } msg
open value_ =
    if value_ then
        Ir.attribute "open" ""

    else
        Ir.none


{-| Draws an outlined button. (default: `false`)
-}
outline : Bool -> Attr { c | outline : Supported } msg
outline value_ =
    if value_ then
        Ir.attribute "outline" ""

    else
        Ir.none


{-| When set, show the carousel's pagination indicators. (default: `false`)
-}
pagination : Bool -> Attr { c | pagination : Supported } msg
pagination value_ =
    if value_ then
        Ir.attribute "pagination" ""

    else
        Ir.none


{-| The name of the tab panel this tab is associated with. The panel must be located in the same tab group. (default: `''`)
-}
panel : String -> Attr { c | panel : Supported } msg
panel =
    Ir.attribute "panel"


{-| Adds a button to toggle the password's visibility. Only applies to password types. (default: `false`)
-}
passwordToggle : Bool -> Attr { c | passwordToggle : Supported } msg
passwordToggle value_ =
    if value_ then
        Ir.attribute "password-toggle" ""

    else
        Ir.none


{-| Determines whether or not the password is currently visible. Only applies to password input types. (default: `false`)
-}
passwordVisible : Bool -> Attr { c | passwordVisible : Supported } msg
passwordVisible value_ =
    if value_ then
        Ir.attribute "password-visible" ""

    else
        Ir.none


{-| A regular expression pattern to validate input against.
-}
pattern : String -> Attr { c | pattern : Supported } msg
pattern =
    Ir.attribute "pattern"


{-| Draws a pill-style badge with rounded edges. (default: `false`)
-}
pill : Bool -> Attr { c | pill : Supported } msg
pill value_ =
    if value_ then
        Ir.attribute "pill" ""

    else
        Ir.none


{-| Placeholder text to show as a hint when the input is empty. (default: `''`)
-}
placeholder : String -> Attr { c | placeholder : Supported } msg
placeholder =
    Ir.attribute "placeholder"


{-| Plays the animation. When this attribute is remove, the animation will pause.
-}
play : Bool -> Attr { c | play : Supported } msg
play value_ =
    if value_ then
        Ir.attribute "play" ""

    else
        Ir.none


{-| Sets the animation's playback rate. The default is `1`, which plays the animation at a normal speed. Setting this
to `2`, for example, will double the animation's speed. A negative value can be used to reverse the animation. This
value can be changed without causing the animation to restart. (default: `1`)
-}
playbackRate : Float -> Attr { c | playbackRate : Supported } msg
playbackRate value_ =
    Ir.attribute "playback-rate" (String.fromFloat value_)


{-| The position of the divider as a percentage. (default: `50`)
-}
position : Float -> Attr { c | position : Supported } msg
position value_ =
    Ir.attribute "position" (String.fromFloat value_)


{-| The current position of the divider from the primary panel's edge in pixels.
-}
positionInPixels : Float -> Attr { c | positionInPixels : Supported } msg
positionInPixels value_ =
    Ir.attribute "position-in-pixels" (String.fromFloat value_)


{-| The precision at which the rating will increase and decrease. For example, to allow half-star ratings, set this
attribute to `0.5`. (default: `1`)
-}
precision : Float -> Attr { c | precision : Supported } msg
precision value_ =
    Ir.attribute "precision" (String.fromFloat value_)


{-| Makes the badge pulsate to draw attention. (default: `false`)
-}
pulse : Bool -> Attr { c | pulse : Supported } msg
pulse value_ =
    if value_ then
        Ir.attribute "pulse" ""

    else
        Ir.none


{-| The edge radius of each module. Must be between 0 and 0.5. (default: `0`)
-}
radius : Float -> Attr { c | radius : Supported } msg
radius value_ =
    Ir.attribute "radius" (String.fromFloat value_)


{-| Makes the input readonly. (default: `false`)
-}
readonly : Bool -> Attr { c | readonly : Supported } msg
readonly value_ =
    if value_ then
        Ir.attribute "readonly" ""

    else
        Ir.none


{-| The `rel` attribute to use on the link. Only used when `href` is set. (default: `'noreferrer noopener'`)
-}
rel : String -> Attr { c | rel : Supported } msg
rel =
    Ir.attribute "rel"


{-| Makes the tag removable and shows a remove button. (default: `false`)
-}
removable : Bool -> Attr { c | removable : Supported } msg
removable value_ =
    if value_ then
        Ir.attribute "removable" ""

    else
        Ir.none


{-| Makes the checkbox a required field. (default: `false`)
-}
required : Bool -> Attr { c | required : Supported } msg
required value_ =
    if value_ then
        Ir.attribute "required" ""

    else
        Ir.none


{-| The number of rows to display by default. (default: `4`)
-}
rows : Float -> Attr { c | rows : Supported } msg
rows value_ =
    Ir.attribute "rows" (String.fromFloat value_)


{-| Draws the tree item in a selected state. (default: `false`)

Sets the LIVE DOM property `selected`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultSelected`.

CAVEAT — this setter cannot RESYNC. `elm/virtual-dom` only re-forces an unchanged controlled property for the names `value` and `checked`; `selected` is compared by identity, so re-rendering the same model value after the user has changed it through the element's own UI will NOT push it back to the DOM. Keep the model in sync with a `change` handler.

-}
selected : Bool -> Attr { c | selected : Supported } msg
selected value_ =
    Ir.property "selected" (Json.Encode.bool value_)


{-| Moves the popup along the axis to keep it in view when clipped. (default: `false`)
-}
shift : Bool -> Attr { c | shift : Supported } msg
shift value_ =
    if value_ then
        Ir.attribute "shift" ""

    else
        Ir.none


{-| The amount of padding, in pixels, to exceed before the shift behavior will occur. (default: `0`)
-}
shiftPadding : Float -> Attr { c | shiftPadding : Supported } msg
shiftPadding value_ =
    Ir.attribute "shift-padding" (String.fromFloat value_)


{-| The shift boundary describes clipping element(s) that overflow will be checked relative to when shifting. By
default, the boundary includes overflow ancestors that will cause the element to be clipped. If needed, you can
change the boundary by passing a reference to one or more elements to this property.
-}
shiftboundary : String -> Attr { c | shiftboundary : Supported } msg
shiftboundary =
    Ir.attribute "shiftBoundary"


{-| The distance in pixels from which to offset the panel along its trigger. (default: `0`)
-}
skidding : Float -> Attr { c | skidding : Supported } msg
skidding value_ =
    Ir.attribute "skidding" (String.fromFloat value_)


{-| Specifies the number of slides the carousel will advance when scrolling, useful when specifying a `slides-per-page`
greater than one. It can't be higher than `slides-per-page`. (default: `1`)
-}
slidesPerMove : Float -> Attr { c | slidesPerMove : Supported } msg
slidesPerMove value_ =
    Ir.attribute "slides-per-move" (String.fromFloat value_)


{-| Specifies how many slides should be shown at a given time. (default: `1`)
-}
slidesPerPage : Float -> Attr { c | slidesPerPage : Supported } msg
slidesPerPage value_ =
    Ir.attribute "slides-per-page" (String.fromFloat value_)


{-| Either one or more space-separated values at which the divider should snap, in pixels, percentages, or repeat expressions e.g. `'100px 50% 500px' or`repeat(50%) 10px`,
or a function which takes in a`SnapFunctionParams`, and returns a position to snap to, e.g.`({ pos }) => Math.round(pos / 8) \* 8\`.
-}
snap : String -> Attr { c | snap : Supported } msg
snap =
    Ir.attribute "snap"


{-| How close the divider must be to a snap point until snapping occurs. (default: `12`)
-}
snapThreshold : Float -> Attr { c | snapThreshold : Supported } msg
snapThreshold value_ =
    Ir.attribute "snap-threshold" (String.fromFloat value_)


{-| Enables spell checking on the input. (default: `true`)
-}
spellcheck : Bool -> Attr { c | spellcheck : Supported } msg
spellcheck value_ =
    if value_ then
        Ir.attribute "spellcheck" ""

    else
        Ir.none


{-| The path to the image to load.
-}
src : String -> Attr { c | src : Supported } msg
src =
    Ir.attribute "src"


{-| By default, the dropdown is closed when an item is selected. This attribute will keep it open instead. Useful for
dropdowns that allow for multiple interactions. (default: `false`)
-}
stayOpenOnSelect : Bool -> Attr { c | stayOpenOnSelect : Supported } msg
stayOpenOnSelect value_ =
    if value_ then
        Ir.attribute "stay-open-on-select" ""

    else
        Ir.none


{-| Specifies the granularity that the value must adhere to, or the special value `any` which means no stepping is
implied, allowing any numeric value. Only applies to date and number input types.
-}
step : String -> Attr { c | step : Supported } msg
step =
    Ir.attribute "step"


{-| A custom label to show in the tooltip after copying. (default: `''`)
-}
successLabel : String -> Attr { c | successLabel : Supported } msg
successLabel =
    Ir.attribute "success-label"


{-| The summary to show in the header. If you need to display HTML, use the `summary` slot instead.
-}
summary : String -> Attr { c | summary : Supported } msg
summary =
    Ir.attribute "summary"


{-| One or more predefined color swatches to display as presets in the color picker. Can include any format the color
picker can parse, including HEX(A), RGB(A), HSL(A), HSV(A), and CSS color names. Each color must be separated by a
semicolon (`;`). Alternatively, you can pass an array of color values to this property using JavaScript. (default: `''`)
-}
swatches : String -> Attr { c | swatches : Supported } msg
swatches =
    Ir.attribute "swatches"


{-| The time zone to express the time in.
-}
timeZone : String -> Attr { c | timeZone : Supported } msg
timeZone =
    Ir.attribute "time-zone"


{-| Set the `title` attribute. (default: `''`)
-}
title : String -> Attr { c | title : Supported } msg
title =
    Ir.attribute "title"


{-| Controls how the tooltip is activated. Possible options include `click`, `hover`, `focus`, and `manual`. Multiple
options can be passed by separating them with a space. When manual is used, the tooltip must be activated
programmatically. (default: `'hover focus'`)
-}
trigger : String -> Attr { c | trigger : Supported } msg
trigger =
    Ir.attribute "trigger"


{-| By default, values are lowercase. With this attribute, values will be uppercase instead. (default: `false`)
-}
uppercase : Bool -> Attr { c | uppercase : Supported } msg
uppercase value_ =
    if value_ then
        Ir.attribute "uppercase" ""

    else
        Ir.none


{-| The value of the button, submitted as a pair with the button's name as part of the form data, but only when this
button is the submitter. This attribute is ignored when `href` is present. (default: `''`)

Sets the LIVE DOM property `value`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultValue`.

-}
value : String -> Attr { c | value : Supported } msg
value value_ =
    Ir.property "value" (Json.Encode.string value_)


{-| Draws the divider in a vertical orientation. (default: `false`)
-}
vertical : Bool -> Attr { c | vertical : Supported } msg
vertical value_ =
    if value_ then
        Ir.attribute "vertical" ""

    else
        Ir.none


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


{-| When set to auto, navigating tabs with the arrow keys will instantly show the corresponding tab panel. When set to
manual, the tab will receive focus but will not show until the user presses spacebar or enter. (default: `'auto'`)
-}
activation : Value Sl.Values.Activation -> Attr { c | activation : Supported } msg
activation value_ =
    Ir.attribute "activation" (HtmlIr.Value.toString value_)


{-| The placement of the arrow. The default is `anchor`, which will align the arrow as close to the center of the
anchor as possible, considering available space and `arrow-padding`. A value of `start`, `end`, or `center` will
align the arrow to the start, end, or center of the popover instead. (default: `'anchor'`)
-}
arrowPlacement : Value Sl.Values.ArrowPlacement -> Attr { c | arrowPlacement : Supported } msg
arrowPlacement value_ =
    Ir.attribute "arrow-placement" (HtmlIr.Value.toString value_)


{-| When set, this will cause the popup to automatically resize itself to prevent it from overflowing.
-}
autoSize : Value Sl.Values.AutoSize -> Attr { c | autoSize : Supported } msg
autoSize value_ =
    Ir.attribute "auto-size" (HtmlIr.Value.toString value_)


{-| Controls whether and how text input is automatically capitalized as it is entered by the user.
-}
autocapitalize : Value Sl.Values.Autocapitalize -> Attr { c | autocapitalize : Supported } msg
autocapitalize value_ =
    Ir.attribute "autocapitalize" (HtmlIr.Value.toString value_)


{-| Indicates whether the browser's autocorrect feature is on or off.
-}
autocorrect : Value Sl.Values.Autocorrect -> Attr { c | autocorrect : Supported } msg
autocorrect value_ =
    Ir.attribute "autocorrect" (HtmlIr.Value.toString value_)


{-| Enables a countdown that indicates the remaining time the alert will be displayed.
Typically used to indicate the remaining time before a whole app refresh.
-}
countdown : Value Sl.Values.Countdown -> Attr { c | countdown : Supported } msg
countdown value_ =
    Ir.attribute "countdown" (HtmlIr.Value.toString value_)


{-| How to display the currency. (default: `'symbol'`)
-}
currencyDisplay : Value Sl.Values.CurrencyDisplay -> Attr { c | currencyDisplay : Supported } msg
currencyDisplay value_ =
    Ir.attribute "currency-display" (HtmlIr.Value.toString value_)


{-| The format for displaying the day.
-}
day : Value Sl.Values.Day -> Attr { c | day : Supported } msg
day value_ =
    Ir.attribute "day" (HtmlIr.Value.toString value_)


{-| Determines how to display the result, e.g. "100 bytes", "100 b", or "100b". (default: `'short'`)
-}
display : Value Sl.Values.Display -> Attr { c | display : Supported } msg
display value_ =
    Ir.attribute "display" (HtmlIr.Value.toString value_)


{-| Determines which effect the skeleton will use. (default: `'none'`)
-}
effect_ : Value Sl.Values.Effect -> Attr { c | effect_ : Supported } msg
effect_ value_ =
    Ir.attribute "effect" (HtmlIr.Value.toString value_)


{-| Used to customize the label or icon of the Enter key on virtual keyboards.
-}
enterkeyhint : Value Sl.Values.Enterkeyhint -> Attr { c | enterkeyhint : Supported } msg
enterkeyhint value_ =
    Ir.attribute "enterkeyhint" (HtmlIr.Value.toString value_)


{-| The format for displaying the era.
-}
era : Value Sl.Values.Era -> Attr { c | era : Supported } msg
era value_ =
    Ir.attribute "era" (HtmlIr.Value.toString value_)


{-| The level of error correction to use. [Learn more](https://www.qrcode.com/en/about/error_correction.html) (default: `'H'`)
-}
errorCorrection : Value Sl.Values.ErrorCorrection -> Attr { c | errorCorrection : Supported } msg
errorCorrection value_ =
    Ir.attribute "error-correction" (HtmlIr.Value.toString value_)


{-| When neither the preferred placement nor the fallback placements fit, this value will be used to determine whether
the popup should be positioned using the best available fit based on available space or as it was initially
preferred. (default: `'best-fit'`)
-}
flipFallbackStrategy : Value Sl.Values.FlipFallbackStrategy -> Attr { c | flipFallbackStrategy : Supported } msg
flipFallbackStrategy value_ =
    Ir.attribute "flip-fallback-strategy" (HtmlIr.Value.toString value_)


{-| The format to use. If opacity is enabled, these will translate to HEXA, RGBA, HSLA, and HSVA respectively. The color
picker will accept user input in any format (including CSS color names) and convert it to the desired format. (default: `'hex'`)
-}
format : Value Sl.Values.Format -> Attr { c | format : Supported } msg
format value_ =
    Ir.attribute "format" (HtmlIr.Value.toString value_)


{-| Used to override the form owner's `enctype` attribute.
-}
formenctype : Value Sl.Values.Formenctype -> Attr { c | formenctype : Supported } msg
formenctype value_ =
    Ir.attribute "formenctype" (HtmlIr.Value.toString value_)


{-| Used to override the form owner's `method` attribute.
-}
formmethod : Value Sl.Values.Formmethod -> Attr { c | formmethod : Supported } msg
formmethod value_ =
    Ir.attribute "formmethod" (HtmlIr.Value.toString value_)


{-| Used to override the form owner's `target` attribute.
-}
formtarget : Value Sl.Values.Formtarget -> Attr { c | formtarget : Supported } msg
formtarget value_ =
    Ir.attribute "formtarget" (HtmlIr.Value.toString value_)


{-| The format for displaying the hour.
-}
hour : Value Sl.Values.Hour -> Attr { c | hour : Supported } msg
hour value_ =
    Ir.attribute "hour" (HtmlIr.Value.toString value_)


{-| The format for displaying the hour. (default: `'auto'`)
-}
hourFormat : Value Sl.Values.HourFormat -> Attr { c | hourFormat : Supported } msg
hourFormat value_ =
    Ir.attribute "hour-format" (HtmlIr.Value.toString value_)


{-| Tells the browser what type of data will be entered by the user, allowing it to display the appropriate virtual
keyboard on supportive devices.
-}
inputmode : Value Sl.Values.Inputmode -> Attr { c | inputmode : Supported } msg
inputmode value_ =
    Ir.attribute "inputmode" (HtmlIr.Value.toString value_)


{-| Indicates how the browser should load the image. (default: `'eager'`)
-}
loading : Value Sl.Values.Loading -> Attr { c | loading : Supported } msg
loading value_ =
    Ir.attribute "loading" (HtmlIr.Value.toString value_)


{-| The format for displaying the minute.
-}
minute : Value Sl.Values.Minute -> Attr { c | minute : Supported } msg
minute value_ =
    Ir.attribute "minute" (HtmlIr.Value.toString value_)


{-| The fetch mode to use. (default: `'cors'`)
-}
mode : Value Sl.Values.Mode -> Attr { c | mode : Supported } msg
mode value_ =
    Ir.attribute "mode" (HtmlIr.Value.toString value_)


{-| The format for displaying the month.
-}
month : Value Sl.Values.Month -> Attr { c | month : Supported } msg
month value_ =
    Ir.attribute "month" (HtmlIr.Value.toString value_)


{-| When `auto`, values such as "yesterday" and "tomorrow" will be shown when possible. When `always`, values such as
"1 day ago" and "in 1 day" will be shown. (default: `'auto'`)
-}
numeric : Value Sl.Values.Numeric -> Attr { c | numeric : Supported } msg
numeric value_ =
    Ir.attribute "numeric" (HtmlIr.Value.toString value_)


{-| Specifies the orientation in which the carousel will lay out. (default: `'horizontal'`)
-}
orientation : Value Sl.Values.Orientation -> Attr { c | orientation : Supported } msg
orientation value_ =
    Ir.attribute "orientation" (HtmlIr.Value.toString value_)


{-| The direction from which the drawer will open. (default: `'end'`)
-}
placement : Value Sl.Values.Placement -> Attr { c | placement : Supported } msg
placement value_ =
    Ir.attribute "placement" (HtmlIr.Value.toString value_)


{-| If no primary panel is designated, both panels will resize proportionally when the host element is resized. If a
primary panel is designated, it will maintain its size and the other panel will grow or shrink as needed when the
host element is resized.
-}
primary : Value Sl.Values.Primary -> Attr { c | primary : Supported } msg
primary value_ =
    Ir.attribute "primary" (HtmlIr.Value.toString value_)


{-| Controls how the textarea can be resized. (default: `'vertical'`)
-}
resize : Value Sl.Values.Resize -> Attr { c | resize : Supported } msg
resize value_ =
    Ir.attribute "resize" (HtmlIr.Value.toString value_)


{-| The format for displaying the second.
-}
second : Value Sl.Values.Second -> Attr { c | second : Supported } msg
second value_ =
    Ir.attribute "second" (HtmlIr.Value.toString value_)


{-| The selection behavior of the tree. Single selection allows only one node to be selected at a time. Multiple
displays checkboxes and allows more than one node to be selected. Leaf allows only leaf nodes to be selected. (default: `'single'`)
-}
selection : Value Sl.Values.Selection -> Attr { c | selection : Supported } msg
selection value_ =
    Ir.attribute "selection" (HtmlIr.Value.toString value_)


{-| The shape of the avatar. (default: `'circle'`)
-}
shape : Value Sl.Values.Shape -> Attr { c | shape : Supported } msg
shape value_ =
    Ir.attribute "shape" (HtmlIr.Value.toString value_)


{-| The button's size. (default: `'medium'`)
-}
size : Value Sl.Values.Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (HtmlIr.Value.toString value_)


{-| Determines how the popup is positioned. The `absolute` strategy works well in most cases, but if overflow is
clipped, using a `fixed` position strategy can often workaround it. (default: `'absolute'`)
-}
strategy : Value Sl.Values.Strategy -> Attr { c | strategy : Supported } msg
strategy value_ =
    Ir.attribute "strategy" (HtmlIr.Value.toString value_)


{-| Syncs the popup width or height to that of the trigger element.
-}
sync : Value Sl.Values.Sync -> Attr { c | sync : Supported } msg
sync value_ =
    Ir.attribute "sync" (HtmlIr.Value.toString value_)


{-| Tells the browser where to open the link. Only used when `href` is set.
-}
target : Value Sl.Values.Target -> Attr { c | target : Supported } msg
target value_ =
    Ir.attribute "target" (HtmlIr.Value.toString value_)


{-| The format for displaying the time.
-}
timeZoneName : Value Sl.Values.TimeZoneName -> Attr { c | timeZoneName : Supported } msg
timeZoneName value_ =
    Ir.attribute "time-zone-name" (HtmlIr.Value.toString value_)


{-| The preferred placement of the range's tooltip. (default: `'top'`)
-}
tooltip : Value Sl.Values.Tooltip -> Attr { c | tooltip : Supported } msg
tooltip value_ =
    Ir.attribute "tooltip" (HtmlIr.Value.toString value_)


{-| The preferred placement of the tooltip. (default: `'top'`)
-}
tooltipPlacement : Value Sl.Values.TooltipPlacement -> Attr { c | tooltipPlacement : Supported } msg
tooltipPlacement value_ =
    Ir.attribute "tooltip-placement" (HtmlIr.Value.toString value_)


{-| The type of button. Note that the default value is `button` instead of `submit`, which is opposite of how native
`<button>` elements behave. When the type is `submit`, the button will submit the surrounding form. (default: `'button'`)
-}
type_ : Value Sl.Values.Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (HtmlIr.Value.toString value_)


{-| The type of unit to display. (default: `'byte'`)
-}
unit : Value Sl.Values.Unit -> Attr { c | unit : Supported } msg
unit value_ =
    Ir.attribute "unit" (HtmlIr.Value.toString value_)


{-| The alert's theme variant. (default: `'primary'`)
-}
variant : Value Sl.Values.Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (HtmlIr.Value.toString value_)


{-| The format for displaying the weekday.
-}
weekday : Value Sl.Values.Weekday -> Attr { c | weekday : Supported } msg
weekday value_ =
    Ir.attribute "weekday" (HtmlIr.Value.toString value_)


{-| The format for displaying the year.
-}
year : Value Sl.Values.Year -> Attr { c | year : Supported } msg
year value_ =
    Ir.attribute "year" (HtmlIr.Value.toString value_)


{-| Set the `activation` attribute to `"auto"`. Portmanteau of `activation` + `auto` — for IDE discovery and single-import ergonomics.
-}
activationAuto : Attr { c | activation : Supported } msg
activationAuto =
    Ir.attribute "activation" "auto"


{-| Set the `activation` attribute to `"manual"`. Portmanteau of `activation` + `manual` — for IDE discovery and single-import ergonomics.
-}
activationManual : Attr { c | activation : Supported } msg
activationManual =
    Ir.attribute "activation" "manual"


{-| Set the `arrow-placement` attribute to `"anchor"`. Portmanteau of `arrowPlacement` + `anchor` — for IDE discovery and single-import ergonomics.
-}
arrowPlacementAnchor : Attr { c | arrowPlacement : Supported } msg
arrowPlacementAnchor =
    Ir.attribute "arrow-placement" "anchor"


{-| Set the `arrow-placement` attribute to `"center"`. Portmanteau of `arrowPlacement` + `center` — for IDE discovery and single-import ergonomics.
-}
arrowPlacementCenter : Attr { c | arrowPlacement : Supported } msg
arrowPlacementCenter =
    Ir.attribute "arrow-placement" "center"


{-| Set the `arrow-placement` attribute to `"end"`. Portmanteau of `arrowPlacement` + `end` — for IDE discovery and single-import ergonomics.
-}
arrowPlacementEnd : Attr { c | arrowPlacement : Supported } msg
arrowPlacementEnd =
    Ir.attribute "arrow-placement" "end"


{-| Set the `arrow-placement` attribute to `"start"`. Portmanteau of `arrowPlacement` + `start` — for IDE discovery and single-import ergonomics.
-}
arrowPlacementStart : Attr { c | arrowPlacement : Supported } msg
arrowPlacementStart =
    Ir.attribute "arrow-placement" "start"


{-| Set the `auto-size` attribute to `"both"`. Portmanteau of `autoSize` + `both` — for IDE discovery and single-import ergonomics.
-}
autoSizeBoth : Attr { c | autoSize : Supported } msg
autoSizeBoth =
    Ir.attribute "auto-size" "both"


{-| Set the `auto-size` attribute to `"horizontal"`. Portmanteau of `autoSize` + `horizontal` — for IDE discovery and single-import ergonomics.
-}
autoSizeHorizontal : Attr { c | autoSize : Supported } msg
autoSizeHorizontal =
    Ir.attribute "auto-size" "horizontal"


{-| Set the `auto-size` attribute to `"vertical"`. Portmanteau of `autoSize` + `vertical` — for IDE discovery and single-import ergonomics.
-}
autoSizeVertical : Attr { c | autoSize : Supported } msg
autoSizeVertical =
    Ir.attribute "auto-size" "vertical"


{-| Set the `autocapitalize` attribute to `"characters"`. Portmanteau of `autocapitalize` + `characters` — for IDE discovery and single-import ergonomics.
-}
autocapitalizeCharacters : Attr { c | autocapitalize : Supported } msg
autocapitalizeCharacters =
    Ir.attribute "autocapitalize" "characters"


{-| Set the `autocapitalize` attribute to `"none"`. Portmanteau of `autocapitalize` + `none` — for IDE discovery and single-import ergonomics.
-}
autocapitalizeNone : Attr { c | autocapitalize : Supported } msg
autocapitalizeNone =
    Ir.attribute "autocapitalize" "none"


{-| Set the `autocapitalize` attribute to `"off"`. Portmanteau of `autocapitalize` + `off` — for IDE discovery and single-import ergonomics.
-}
autocapitalizeOff : Attr { c | autocapitalize : Supported } msg
autocapitalizeOff =
    Ir.attribute "autocapitalize" "off"


{-| Set the `autocapitalize` attribute to `"on"`. Portmanteau of `autocapitalize` + `on` — for IDE discovery and single-import ergonomics.
-}
autocapitalizeOn : Attr { c | autocapitalize : Supported } msg
autocapitalizeOn =
    Ir.attribute "autocapitalize" "on"


{-| Set the `autocapitalize` attribute to `"sentences"`. Portmanteau of `autocapitalize` + `sentences` — for IDE discovery and single-import ergonomics.
-}
autocapitalizeSentences : Attr { c | autocapitalize : Supported } msg
autocapitalizeSentences =
    Ir.attribute "autocapitalize" "sentences"


{-| Set the `autocapitalize` attribute to `"words"`. Portmanteau of `autocapitalize` + `words` — for IDE discovery and single-import ergonomics.
-}
autocapitalizeWords : Attr { c | autocapitalize : Supported } msg
autocapitalizeWords =
    Ir.attribute "autocapitalize" "words"


{-| Set the `autocorrect` attribute to `"off"`. Portmanteau of `autocorrect` + `off` — for IDE discovery and single-import ergonomics.
-}
autocorrectOff : Attr { c | autocorrect : Supported } msg
autocorrectOff =
    Ir.attribute "autocorrect" "off"


{-| Set the `autocorrect` attribute to `"on"`. Portmanteau of `autocorrect` + `on` — for IDE discovery and single-import ergonomics.
-}
autocorrectOn : Attr { c | autocorrect : Supported } msg
autocorrectOn =
    Ir.attribute "autocorrect" "on"


{-| Set the `countdown` attribute to `"ltr"`. Portmanteau of `countdown` + `ltr` — for IDE discovery and single-import ergonomics.
-}
countdownLtr : Attr { c | countdown : Supported } msg
countdownLtr =
    Ir.attribute "countdown" "ltr"


{-| Set the `countdown` attribute to `"rtl"`. Portmanteau of `countdown` + `rtl` — for IDE discovery and single-import ergonomics.
-}
countdownRtl : Attr { c | countdown : Supported } msg
countdownRtl =
    Ir.attribute "countdown" "rtl"


{-| Set the `currency-display` attribute to `"code"`. Portmanteau of `currencyDisplay` + `code` — for IDE discovery and single-import ergonomics.
-}
currencyDisplayCode : Attr { c | currencyDisplay : Supported } msg
currencyDisplayCode =
    Ir.attribute "currency-display" "code"


{-| Set the `currency-display` attribute to `"name"`. Portmanteau of `currencyDisplay` + `name` — for IDE discovery and single-import ergonomics.
-}
currencyDisplayName : Attr { c | currencyDisplay : Supported } msg
currencyDisplayName =
    Ir.attribute "currency-display" "name"


{-| Set the `currency-display` attribute to `"narrowSymbol"`. Portmanteau of `currencyDisplay` + `narrowSymbol` — for IDE discovery and single-import ergonomics.
-}
currencyDisplayNarrowsymbol : Attr { c | currencyDisplay : Supported } msg
currencyDisplayNarrowsymbol =
    Ir.attribute "currency-display" "narrowSymbol"


{-| Set the `currency-display` attribute to `"symbol"`. Portmanteau of `currencyDisplay` + `symbol` — for IDE discovery and single-import ergonomics.
-}
currencyDisplaySymbol : Attr { c | currencyDisplay : Supported } msg
currencyDisplaySymbol =
    Ir.attribute "currency-display" "symbol"


{-| Set the `day` attribute to `"2-digit"`. Portmanteau of `day` + `2-digit` — for IDE discovery and single-import ergonomics.
-}
dayValue2Digit : Attr { c | day : Supported } msg
dayValue2Digit =
    Ir.attribute "day" "2-digit"


{-| Set the `day` attribute to `"numeric"`. Portmanteau of `day` + `numeric` — for IDE discovery and single-import ergonomics.
-}
dayNumeric : Attr { c | day : Supported } msg
dayNumeric =
    Ir.attribute "day" "numeric"


{-| Set the `display` attribute to `"long"`. Portmanteau of `display` + `long` — for IDE discovery and single-import ergonomics.
-}
displayLong : Attr { c | display : Supported } msg
displayLong =
    Ir.attribute "display" "long"


{-| Set the `display` attribute to `"narrow"`. Portmanteau of `display` + `narrow` — for IDE discovery and single-import ergonomics.
-}
displayNarrow : Attr { c | display : Supported } msg
displayNarrow =
    Ir.attribute "display" "narrow"


{-| Set the `display` attribute to `"short"`. Portmanteau of `display` + `short` — for IDE discovery and single-import ergonomics.
-}
displayShort : Attr { c | display : Supported } msg
displayShort =
    Ir.attribute "display" "short"


{-| Set the `effect` attribute to `"none"`. Portmanteau of `effect_` + `none` — for IDE discovery and single-import ergonomics.
-}
effect_None : Attr { c | effect_ : Supported } msg
effect_None =
    Ir.attribute "effect" "none"


{-| Set the `effect` attribute to `"pulse"`. Portmanteau of `effect_` + `pulse` — for IDE discovery and single-import ergonomics.
-}
effect_Pulse : Attr { c | effect_ : Supported } msg
effect_Pulse =
    Ir.attribute "effect" "pulse"


{-| Set the `effect` attribute to `"sheen"`. Portmanteau of `effect_` + `sheen` — for IDE discovery and single-import ergonomics.
-}
effect_Sheen : Attr { c | effect_ : Supported } msg
effect_Sheen =
    Ir.attribute "effect" "sheen"


{-| Set the `enterkeyhint` attribute to `"done"`. Portmanteau of `enterkeyhint` + `done` — for IDE discovery and single-import ergonomics.
-}
enterkeyhintDone : Attr { c | enterkeyhint : Supported } msg
enterkeyhintDone =
    Ir.attribute "enterkeyhint" "done"


{-| Set the `enterkeyhint` attribute to `"enter"`. Portmanteau of `enterkeyhint` + `enter` — for IDE discovery and single-import ergonomics.
-}
enterkeyhintEnter : Attr { c | enterkeyhint : Supported } msg
enterkeyhintEnter =
    Ir.attribute "enterkeyhint" "enter"


{-| Set the `enterkeyhint` attribute to `"go"`. Portmanteau of `enterkeyhint` + `go` — for IDE discovery and single-import ergonomics.
-}
enterkeyhintGo : Attr { c | enterkeyhint : Supported } msg
enterkeyhintGo =
    Ir.attribute "enterkeyhint" "go"


{-| Set the `enterkeyhint` attribute to `"next"`. Portmanteau of `enterkeyhint` + `next` — for IDE discovery and single-import ergonomics.
-}
enterkeyhintNext : Attr { c | enterkeyhint : Supported } msg
enterkeyhintNext =
    Ir.attribute "enterkeyhint" "next"


{-| Set the `enterkeyhint` attribute to `"previous"`. Portmanteau of `enterkeyhint` + `previous` — for IDE discovery and single-import ergonomics.
-}
enterkeyhintPrevious : Attr { c | enterkeyhint : Supported } msg
enterkeyhintPrevious =
    Ir.attribute "enterkeyhint" "previous"


{-| Set the `enterkeyhint` attribute to `"search"`. Portmanteau of `enterkeyhint` + `search` — for IDE discovery and single-import ergonomics.
-}
enterkeyhintSearch : Attr { c | enterkeyhint : Supported } msg
enterkeyhintSearch =
    Ir.attribute "enterkeyhint" "search"


{-| Set the `enterkeyhint` attribute to `"send"`. Portmanteau of `enterkeyhint` + `send` — for IDE discovery and single-import ergonomics.
-}
enterkeyhintSend : Attr { c | enterkeyhint : Supported } msg
enterkeyhintSend =
    Ir.attribute "enterkeyhint" "send"


{-| Set the `era` attribute to `"long"`. Portmanteau of `era` + `long` — for IDE discovery and single-import ergonomics.
-}
eraLong : Attr { c | era : Supported } msg
eraLong =
    Ir.attribute "era" "long"


{-| Set the `era` attribute to `"narrow"`. Portmanteau of `era` + `narrow` — for IDE discovery and single-import ergonomics.
-}
eraNarrow : Attr { c | era : Supported } msg
eraNarrow =
    Ir.attribute "era" "narrow"


{-| Set the `era` attribute to `"short"`. Portmanteau of `era` + `short` — for IDE discovery and single-import ergonomics.
-}
eraShort : Attr { c | era : Supported } msg
eraShort =
    Ir.attribute "era" "short"


{-| Set the `error-correction` attribute to `"H"`. Portmanteau of `errorCorrection` + `H` — for IDE discovery and single-import ergonomics.
-}
errorCorrectionH : Attr { c | errorCorrection : Supported } msg
errorCorrectionH =
    Ir.attribute "error-correction" "H"


{-| Set the `error-correction` attribute to `"L"`. Portmanteau of `errorCorrection` + `L` — for IDE discovery and single-import ergonomics.
-}
errorCorrectionL : Attr { c | errorCorrection : Supported } msg
errorCorrectionL =
    Ir.attribute "error-correction" "L"


{-| Set the `error-correction` attribute to `"M"`. Portmanteau of `errorCorrection` + `M` — for IDE discovery and single-import ergonomics.
-}
errorCorrectionM : Attr { c | errorCorrection : Supported } msg
errorCorrectionM =
    Ir.attribute "error-correction" "M"


{-| Set the `error-correction` attribute to `"Q"`. Portmanteau of `errorCorrection` + `Q` — for IDE discovery and single-import ergonomics.
-}
errorCorrectionQ : Attr { c | errorCorrection : Supported } msg
errorCorrectionQ =
    Ir.attribute "error-correction" "Q"


{-| Set the `flip-fallback-strategy` attribute to `"best-fit"`. Portmanteau of `flipFallbackStrategy` + `best-fit` — for IDE discovery and single-import ergonomics.
-}
flipFallbackStrategyBestFit : Attr { c | flipFallbackStrategy : Supported } msg
flipFallbackStrategyBestFit =
    Ir.attribute "flip-fallback-strategy" "best-fit"


{-| Set the `flip-fallback-strategy` attribute to `"initial"`. Portmanteau of `flipFallbackStrategy` + `initial` — for IDE discovery and single-import ergonomics.
-}
flipFallbackStrategyInitial : Attr { c | flipFallbackStrategy : Supported } msg
flipFallbackStrategyInitial =
    Ir.attribute "flip-fallback-strategy" "initial"


{-| Set the `format` attribute to `"hex"`. Portmanteau of `format` + `hex` — for IDE discovery and single-import ergonomics.
-}
formatHex : Attr { c | format : Supported } msg
formatHex =
    Ir.attribute "format" "hex"


{-| Set the `format` attribute to `"hsl"`. Portmanteau of `format` + `hsl` — for IDE discovery and single-import ergonomics.
-}
formatHsl : Attr { c | format : Supported } msg
formatHsl =
    Ir.attribute "format" "hsl"


{-| Set the `format` attribute to `"hsv"`. Portmanteau of `format` + `hsv` — for IDE discovery and single-import ergonomics.
-}
formatHsv : Attr { c | format : Supported } msg
formatHsv =
    Ir.attribute "format" "hsv"


{-| Set the `format` attribute to `"long"`. Portmanteau of `format` + `long` — for IDE discovery and single-import ergonomics.
-}
formatLong : Attr { c | format : Supported } msg
formatLong =
    Ir.attribute "format" "long"


{-| Set the `format` attribute to `"narrow"`. Portmanteau of `format` + `narrow` — for IDE discovery and single-import ergonomics.
-}
formatNarrow : Attr { c | format : Supported } msg
formatNarrow =
    Ir.attribute "format" "narrow"


{-| Set the `format` attribute to `"rgb"`. Portmanteau of `format` + `rgb` — for IDE discovery and single-import ergonomics.
-}
formatRgb : Attr { c | format : Supported } msg
formatRgb =
    Ir.attribute "format" "rgb"


{-| Set the `format` attribute to `"short"`. Portmanteau of `format` + `short` — for IDE discovery and single-import ergonomics.
-}
formatShort : Attr { c | format : Supported } msg
formatShort =
    Ir.attribute "format" "short"


{-| Set the `formenctype` attribute to `"application/x-www-form-urlencoded"`. Portmanteau of `formenctype` + `application/x-www-form-urlencoded` — for IDE discovery and single-import ergonomics.
-}
formenctypeApplicationXWwwFormUrlencoded : Attr { c | formenctype : Supported } msg
formenctypeApplicationXWwwFormUrlencoded =
    Ir.attribute "formenctype" "application/x-www-form-urlencoded"


{-| Set the `formenctype` attribute to `"multipart/form-data"`. Portmanteau of `formenctype` + `multipart/form-data` — for IDE discovery and single-import ergonomics.
-}
formenctypeMultipartFormData : Attr { c | formenctype : Supported } msg
formenctypeMultipartFormData =
    Ir.attribute "formenctype" "multipart/form-data"


{-| Set the `formenctype` attribute to `"text/plain"`. Portmanteau of `formenctype` + `text/plain` — for IDE discovery and single-import ergonomics.
-}
formenctypeTextPlain : Attr { c | formenctype : Supported } msg
formenctypeTextPlain =
    Ir.attribute "formenctype" "text/plain"


{-| Set the `formmethod` attribute to `"get"`. Portmanteau of `formmethod` + `get` — for IDE discovery and single-import ergonomics.
-}
formmethodGet : Attr { c | formmethod : Supported } msg
formmethodGet =
    Ir.attribute "formmethod" "get"


{-| Set the `formmethod` attribute to `"post"`. Portmanteau of `formmethod` + `post` — for IDE discovery and single-import ergonomics.
-}
formmethodPost : Attr { c | formmethod : Supported } msg
formmethodPost =
    Ir.attribute "formmethod" "post"


{-| Set the `formtarget` attribute to `"_blank"`. Portmanteau of `formtarget` + `_blank` — for IDE discovery and single-import ergonomics.
-}
formtargetBlank_ : Attr { c | formtarget : Supported } msg
formtargetBlank_ =
    Ir.attribute "formtarget" "_blank"


{-| Set the `formtarget` attribute to `"_parent"`. Portmanteau of `formtarget` + `_parent` — for IDE discovery and single-import ergonomics.
-}
formtargetParent_ : Attr { c | formtarget : Supported } msg
formtargetParent_ =
    Ir.attribute "formtarget" "_parent"


{-| Set the `formtarget` attribute to `"_self"`. Portmanteau of `formtarget` + `_self` — for IDE discovery and single-import ergonomics.
-}
formtargetSelf_ : Attr { c | formtarget : Supported } msg
formtargetSelf_ =
    Ir.attribute "formtarget" "_self"


{-| Set the `formtarget` attribute to `"_top"`. Portmanteau of `formtarget` + `_top` — for IDE discovery and single-import ergonomics.
-}
formtargetTop_ : Attr { c | formtarget : Supported } msg
formtargetTop_ =
    Ir.attribute "formtarget" "_top"


{-| Set the `hour` attribute to `"2-digit"`. Portmanteau of `hour` + `2-digit` — for IDE discovery and single-import ergonomics.
-}
hourValue2Digit : Attr { c | hour : Supported } msg
hourValue2Digit =
    Ir.attribute "hour" "2-digit"


{-| Set the `hour` attribute to `"numeric"`. Portmanteau of `hour` + `numeric` — for IDE discovery and single-import ergonomics.
-}
hourNumeric : Attr { c | hour : Supported } msg
hourNumeric =
    Ir.attribute "hour" "numeric"


{-| Set the `hour-format` attribute to `"12"`. Portmanteau of `hourFormat` + `12` — for IDE discovery and single-import ergonomics.
-}
hourFormatValue12 : Attr { c | hourFormat : Supported } msg
hourFormatValue12 =
    Ir.attribute "hour-format" "12"


{-| Set the `hour-format` attribute to `"24"`. Portmanteau of `hourFormat` + `24` — for IDE discovery and single-import ergonomics.
-}
hourFormatValue24 : Attr { c | hourFormat : Supported } msg
hourFormatValue24 =
    Ir.attribute "hour-format" "24"


{-| Set the `hour-format` attribute to `"auto"`. Portmanteau of `hourFormat` + `auto` — for IDE discovery and single-import ergonomics.
-}
hourFormatAuto : Attr { c | hourFormat : Supported } msg
hourFormatAuto =
    Ir.attribute "hour-format" "auto"


{-| Set the `inputmode` attribute to `"decimal"`. Portmanteau of `inputmode` + `decimal` — for IDE discovery and single-import ergonomics.
-}
inputmodeDecimal : Attr { c | inputmode : Supported } msg
inputmodeDecimal =
    Ir.attribute "inputmode" "decimal"


{-| Set the `inputmode` attribute to `"email"`. Portmanteau of `inputmode` + `email` — for IDE discovery and single-import ergonomics.
-}
inputmodeEmail : Attr { c | inputmode : Supported } msg
inputmodeEmail =
    Ir.attribute "inputmode" "email"


{-| Set the `inputmode` attribute to `"none"`. Portmanteau of `inputmode` + `none` — for IDE discovery and single-import ergonomics.
-}
inputmodeNone : Attr { c | inputmode : Supported } msg
inputmodeNone =
    Ir.attribute "inputmode" "none"


{-| Set the `inputmode` attribute to `"numeric"`. Portmanteau of `inputmode` + `numeric` — for IDE discovery and single-import ergonomics.
-}
inputmodeNumeric : Attr { c | inputmode : Supported } msg
inputmodeNumeric =
    Ir.attribute "inputmode" "numeric"


{-| Set the `inputmode` attribute to `"search"`. Portmanteau of `inputmode` + `search` — for IDE discovery and single-import ergonomics.
-}
inputmodeSearch : Attr { c | inputmode : Supported } msg
inputmodeSearch =
    Ir.attribute "inputmode" "search"


{-| Set the `inputmode` attribute to `"tel"`. Portmanteau of `inputmode` + `tel` — for IDE discovery and single-import ergonomics.
-}
inputmodeTel : Attr { c | inputmode : Supported } msg
inputmodeTel =
    Ir.attribute "inputmode" "tel"


{-| Set the `inputmode` attribute to `"text"`. Portmanteau of `inputmode` + `text` — for IDE discovery and single-import ergonomics.
-}
inputmodeText : Attr { c | inputmode : Supported } msg
inputmodeText =
    Ir.attribute "inputmode" "text"


{-| Set the `inputmode` attribute to `"url"`. Portmanteau of `inputmode` + `url` — for IDE discovery and single-import ergonomics.
-}
inputmodeUrl : Attr { c | inputmode : Supported } msg
inputmodeUrl =
    Ir.attribute "inputmode" "url"


{-| Set the `loading` attribute to `"eager"`. Portmanteau of `loading` + `eager` — for IDE discovery and single-import ergonomics.
-}
loadingEager : Attr { c | loading : Supported } msg
loadingEager =
    Ir.attribute "loading" "eager"


{-| Set the `loading` attribute to `"lazy"`. Portmanteau of `loading` + `lazy` — for IDE discovery and single-import ergonomics.
-}
loadingLazy : Attr { c | loading : Supported } msg
loadingLazy =
    Ir.attribute "loading" "lazy"


{-| Set the `minute` attribute to `"2-digit"`. Portmanteau of `minute` + `2-digit` — for IDE discovery and single-import ergonomics.
-}
minuteValue2Digit : Attr { c | minute : Supported } msg
minuteValue2Digit =
    Ir.attribute "minute" "2-digit"


{-| Set the `minute` attribute to `"numeric"`. Portmanteau of `minute` + `numeric` — for IDE discovery and single-import ergonomics.
-}
minuteNumeric : Attr { c | minute : Supported } msg
minuteNumeric =
    Ir.attribute "minute" "numeric"


{-| Set the `mode` attribute to `"cors"`. Portmanteau of `mode` + `cors` — for IDE discovery and single-import ergonomics.
-}
modeCors : Attr { c | mode : Supported } msg
modeCors =
    Ir.attribute "mode" "cors"


{-| Set the `mode` attribute to `"no-cors"`. Portmanteau of `mode` + `no-cors` — for IDE discovery and single-import ergonomics.
-}
modeNoCors : Attr { c | mode : Supported } msg
modeNoCors =
    Ir.attribute "mode" "no-cors"


{-| Set the `mode` attribute to `"same-origin"`. Portmanteau of `mode` + `same-origin` — for IDE discovery and single-import ergonomics.
-}
modeSameOrigin : Attr { c | mode : Supported } msg
modeSameOrigin =
    Ir.attribute "mode" "same-origin"


{-| Set the `month` attribute to `"2-digit"`. Portmanteau of `month` + `2-digit` — for IDE discovery and single-import ergonomics.
-}
monthValue2Digit : Attr { c | month : Supported } msg
monthValue2Digit =
    Ir.attribute "month" "2-digit"


{-| Set the `month` attribute to `"long"`. Portmanteau of `month` + `long` — for IDE discovery and single-import ergonomics.
-}
monthLong : Attr { c | month : Supported } msg
monthLong =
    Ir.attribute "month" "long"


{-| Set the `month` attribute to `"narrow"`. Portmanteau of `month` + `narrow` — for IDE discovery and single-import ergonomics.
-}
monthNarrow : Attr { c | month : Supported } msg
monthNarrow =
    Ir.attribute "month" "narrow"


{-| Set the `month` attribute to `"numeric"`. Portmanteau of `month` + `numeric` — for IDE discovery and single-import ergonomics.
-}
monthNumeric : Attr { c | month : Supported } msg
monthNumeric =
    Ir.attribute "month" "numeric"


{-| Set the `month` attribute to `"short"`. Portmanteau of `month` + `short` — for IDE discovery and single-import ergonomics.
-}
monthShort : Attr { c | month : Supported } msg
monthShort =
    Ir.attribute "month" "short"


{-| Set the `numeric` attribute to `"always"`. Portmanteau of `numeric` + `always` — for IDE discovery and single-import ergonomics.
-}
numericAlways : Attr { c | numeric : Supported } msg
numericAlways =
    Ir.attribute "numeric" "always"


{-| Set the `numeric` attribute to `"auto"`. Portmanteau of `numeric` + `auto` — for IDE discovery and single-import ergonomics.
-}
numericAuto : Attr { c | numeric : Supported } msg
numericAuto =
    Ir.attribute "numeric" "auto"


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


{-| Set the `placement` attribute to `"bottom"`. Portmanteau of `placement` + `bottom` — for IDE discovery and single-import ergonomics.
-}
placementBottom : Attr { c | placement : Supported } msg
placementBottom =
    Ir.attribute "placement" "bottom"


{-| Set the `placement` attribute to `"bottom-end"`. Portmanteau of `placement` + `bottom-end` — for IDE discovery and single-import ergonomics.
-}
placementBottomEnd : Attr { c | placement : Supported } msg
placementBottomEnd =
    Ir.attribute "placement" "bottom-end"


{-| Set the `placement` attribute to `"bottom-start"`. Portmanteau of `placement` + `bottom-start` — for IDE discovery and single-import ergonomics.
-}
placementBottomStart : Attr { c | placement : Supported } msg
placementBottomStart =
    Ir.attribute "placement" "bottom-start"


{-| Set the `placement` attribute to `"end"`. Portmanteau of `placement` + `end` — for IDE discovery and single-import ergonomics.
-}
placementEnd : Attr { c | placement : Supported } msg
placementEnd =
    Ir.attribute "placement" "end"


{-| Set the `placement` attribute to `"left"`. Portmanteau of `placement` + `left` — for IDE discovery and single-import ergonomics.
-}
placementLeft : Attr { c | placement : Supported } msg
placementLeft =
    Ir.attribute "placement" "left"


{-| Set the `placement` attribute to `"left-end"`. Portmanteau of `placement` + `left-end` — for IDE discovery and single-import ergonomics.
-}
placementLeftEnd : Attr { c | placement : Supported } msg
placementLeftEnd =
    Ir.attribute "placement" "left-end"


{-| Set the `placement` attribute to `"left-start"`. Portmanteau of `placement` + `left-start` — for IDE discovery and single-import ergonomics.
-}
placementLeftStart : Attr { c | placement : Supported } msg
placementLeftStart =
    Ir.attribute "placement" "left-start"


{-| Set the `placement` attribute to `"right"`. Portmanteau of `placement` + `right` — for IDE discovery and single-import ergonomics.
-}
placementRight : Attr { c | placement : Supported } msg
placementRight =
    Ir.attribute "placement" "right"


{-| Set the `placement` attribute to `"right-end"`. Portmanteau of `placement` + `right-end` — for IDE discovery and single-import ergonomics.
-}
placementRightEnd : Attr { c | placement : Supported } msg
placementRightEnd =
    Ir.attribute "placement" "right-end"


{-| Set the `placement` attribute to `"right-start"`. Portmanteau of `placement` + `right-start` — for IDE discovery and single-import ergonomics.
-}
placementRightStart : Attr { c | placement : Supported } msg
placementRightStart =
    Ir.attribute "placement" "right-start"


{-| Set the `placement` attribute to `"start"`. Portmanteau of `placement` + `start` — for IDE discovery and single-import ergonomics.
-}
placementStart : Attr { c | placement : Supported } msg
placementStart =
    Ir.attribute "placement" "start"


{-| Set the `placement` attribute to `"top"`. Portmanteau of `placement` + `top` — for IDE discovery and single-import ergonomics.
-}
placementTop : Attr { c | placement : Supported } msg
placementTop =
    Ir.attribute "placement" "top"


{-| Set the `placement` attribute to `"top-end"`. Portmanteau of `placement` + `top-end` — for IDE discovery and single-import ergonomics.
-}
placementTopEnd : Attr { c | placement : Supported } msg
placementTopEnd =
    Ir.attribute "placement" "top-end"


{-| Set the `placement` attribute to `"top-start"`. Portmanteau of `placement` + `top-start` — for IDE discovery and single-import ergonomics.
-}
placementTopStart : Attr { c | placement : Supported } msg
placementTopStart =
    Ir.attribute "placement" "top-start"


{-| Set the `primary` attribute to `"end"`. Portmanteau of `primary` + `end` — for IDE discovery and single-import ergonomics.
-}
primaryEnd : Attr { c | primary : Supported } msg
primaryEnd =
    Ir.attribute "primary" "end"


{-| Set the `primary` attribute to `"start"`. Portmanteau of `primary` + `start` — for IDE discovery and single-import ergonomics.
-}
primaryStart : Attr { c | primary : Supported } msg
primaryStart =
    Ir.attribute "primary" "start"


{-| Set the `resize` attribute to `"auto"`. Portmanteau of `resize` + `auto` — for IDE discovery and single-import ergonomics.
-}
resizeAuto : Attr { c | resize : Supported } msg
resizeAuto =
    Ir.attribute "resize" "auto"


{-| Set the `resize` attribute to `"none"`. Portmanteau of `resize` + `none` — for IDE discovery and single-import ergonomics.
-}
resizeNone : Attr { c | resize : Supported } msg
resizeNone =
    Ir.attribute "resize" "none"


{-| Set the `resize` attribute to `"vertical"`. Portmanteau of `resize` + `vertical` — for IDE discovery and single-import ergonomics.
-}
resizeVertical : Attr { c | resize : Supported } msg
resizeVertical =
    Ir.attribute "resize" "vertical"


{-| Set the `second` attribute to `"2-digit"`. Portmanteau of `second` + `2-digit` — for IDE discovery and single-import ergonomics.
-}
secondValue2Digit : Attr { c | second : Supported } msg
secondValue2Digit =
    Ir.attribute "second" "2-digit"


{-| Set the `second` attribute to `"numeric"`. Portmanteau of `second` + `numeric` — for IDE discovery and single-import ergonomics.
-}
secondNumeric : Attr { c | second : Supported } msg
secondNumeric =
    Ir.attribute "second" "numeric"


{-| Set the `selection` attribute to `"leaf"`. Portmanteau of `selection` + `leaf` — for IDE discovery and single-import ergonomics.
-}
selectionLeaf : Attr { c | selection : Supported } msg
selectionLeaf =
    Ir.attribute "selection" "leaf"


{-| Set the `selection` attribute to `"multiple"`. Portmanteau of `selection` + `multiple` — for IDE discovery and single-import ergonomics.
-}
selectionMultiple : Attr { c | selection : Supported } msg
selectionMultiple =
    Ir.attribute "selection" "multiple"


{-| Set the `selection` attribute to `"single"`. Portmanteau of `selection` + `single` — for IDE discovery and single-import ergonomics.
-}
selectionSingle : Attr { c | selection : Supported } msg
selectionSingle =
    Ir.attribute "selection" "single"


{-| Set the `shape` attribute to `"circle"`. Portmanteau of `shape` + `circle` — for IDE discovery and single-import ergonomics.
-}
shapeCircle : Attr { c | shape : Supported } msg
shapeCircle =
    Ir.attribute "shape" "circle"


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


{-| Set the `strategy` attribute to `"absolute"`. Portmanteau of `strategy` + `absolute` — for IDE discovery and single-import ergonomics.
-}
strategyAbsolute : Attr { c | strategy : Supported } msg
strategyAbsolute =
    Ir.attribute "strategy" "absolute"


{-| Set the `strategy` attribute to `"fixed"`. Portmanteau of `strategy` + `fixed` — for IDE discovery and single-import ergonomics.
-}
strategyFixed : Attr { c | strategy : Supported } msg
strategyFixed =
    Ir.attribute "strategy" "fixed"


{-| Set the `sync` attribute to `"both"`. Portmanteau of `sync` + `both` — for IDE discovery and single-import ergonomics.
-}
syncBoth : Attr { c | sync : Supported } msg
syncBoth =
    Ir.attribute "sync" "both"


{-| Set the `sync` attribute to `"height"`. Portmanteau of `sync` + `height` — for IDE discovery and single-import ergonomics.
-}
syncHeight : Attr { c | sync : Supported } msg
syncHeight =
    Ir.attribute "sync" "height"


{-| Set the `sync` attribute to `"width"`. Portmanteau of `sync` + `width` — for IDE discovery and single-import ergonomics.
-}
syncWidth : Attr { c | sync : Supported } msg
syncWidth =
    Ir.attribute "sync" "width"


{-| Set the `target` attribute to `"_blank"`. Portmanteau of `target` + `_blank` — for IDE discovery and single-import ergonomics.
-}
targetBlank_ : Attr { c | target : Supported } msg
targetBlank_ =
    Ir.attribute "target" "_blank"


{-| Set the `target` attribute to `"_parent"`. Portmanteau of `target` + `_parent` — for IDE discovery and single-import ergonomics.
-}
targetParent_ : Attr { c | target : Supported } msg
targetParent_ =
    Ir.attribute "target" "_parent"


{-| Set the `target` attribute to `"_self"`. Portmanteau of `target` + `_self` — for IDE discovery and single-import ergonomics.
-}
targetSelf_ : Attr { c | target : Supported } msg
targetSelf_ =
    Ir.attribute "target" "_self"


{-| Set the `target` attribute to `"_top"`. Portmanteau of `target` + `_top` — for IDE discovery and single-import ergonomics.
-}
targetTop_ : Attr { c | target : Supported } msg
targetTop_ =
    Ir.attribute "target" "_top"


{-| Set the `time-zone-name` attribute to `"long"`. Portmanteau of `timeZoneName` + `long` — for IDE discovery and single-import ergonomics.
-}
timeZoneNameLong : Attr { c | timeZoneName : Supported } msg
timeZoneNameLong =
    Ir.attribute "time-zone-name" "long"


{-| Set the `time-zone-name` attribute to `"short"`. Portmanteau of `timeZoneName` + `short` — for IDE discovery and single-import ergonomics.
-}
timeZoneNameShort : Attr { c | timeZoneName : Supported } msg
timeZoneNameShort =
    Ir.attribute "time-zone-name" "short"


{-| Set the `tooltip` attribute to `"bottom"`. Portmanteau of `tooltip` + `bottom` — for IDE discovery and single-import ergonomics.
-}
tooltipBottom : Attr { c | tooltip : Supported } msg
tooltipBottom =
    Ir.attribute "tooltip" "bottom"


{-| Set the `tooltip` attribute to `"none"`. Portmanteau of `tooltip` + `none` — for IDE discovery and single-import ergonomics.
-}
tooltipNone : Attr { c | tooltip : Supported } msg
tooltipNone =
    Ir.attribute "tooltip" "none"


{-| Set the `tooltip` attribute to `"top"`. Portmanteau of `tooltip` + `top` — for IDE discovery and single-import ergonomics.
-}
tooltipTop : Attr { c | tooltip : Supported } msg
tooltipTop =
    Ir.attribute "tooltip" "top"


{-| Set the `tooltip-placement` attribute to `"bottom"`. Portmanteau of `tooltipPlacement` + `bottom` — for IDE discovery and single-import ergonomics.
-}
tooltipPlacementBottom : Attr { c | tooltipPlacement : Supported } msg
tooltipPlacementBottom =
    Ir.attribute "tooltip-placement" "bottom"


{-| Set the `tooltip-placement` attribute to `"left"`. Portmanteau of `tooltipPlacement` + `left` — for IDE discovery and single-import ergonomics.
-}
tooltipPlacementLeft : Attr { c | tooltipPlacement : Supported } msg
tooltipPlacementLeft =
    Ir.attribute "tooltip-placement" "left"


{-| Set the `tooltip-placement` attribute to `"right"`. Portmanteau of `tooltipPlacement` + `right` — for IDE discovery and single-import ergonomics.
-}
tooltipPlacementRight : Attr { c | tooltipPlacement : Supported } msg
tooltipPlacementRight =
    Ir.attribute "tooltip-placement" "right"


{-| Set the `tooltip-placement` attribute to `"top"`. Portmanteau of `tooltipPlacement` + `top` — for IDE discovery and single-import ergonomics.
-}
tooltipPlacementTop : Attr { c | tooltipPlacement : Supported } msg
tooltipPlacementTop =
    Ir.attribute "tooltip-placement" "top"


{-| Set the `type` attribute to `"button"`. Portmanteau of `type_` + `button` — for IDE discovery and single-import ergonomics.
-}
type_Button : Attr { c | type_ : Supported } msg
type_Button =
    Ir.attribute "type" "button"


{-| Set the `type` attribute to `"checkbox"`. Portmanteau of `type_` + `checkbox` — for IDE discovery and single-import ergonomics.
-}
type_Checkbox : Attr { c | type_ : Supported } msg
type_Checkbox =
    Ir.attribute "type" "checkbox"


{-| Set the `type` attribute to `"currency"`. Portmanteau of `type_` + `currency` — for IDE discovery and single-import ergonomics.
-}
type_Currency : Attr { c | type_ : Supported } msg
type_Currency =
    Ir.attribute "type" "currency"


{-| Set the `type` attribute to `"date"`. Portmanteau of `type_` + `date` — for IDE discovery and single-import ergonomics.
-}
type_Date : Attr { c | type_ : Supported } msg
type_Date =
    Ir.attribute "type" "date"


{-| Set the `type` attribute to `"datetime-local"`. Portmanteau of `type_` + `datetime-local` — for IDE discovery and single-import ergonomics.
-}
type_DatetimeLocal : Attr { c | type_ : Supported } msg
type_DatetimeLocal =
    Ir.attribute "type" "datetime-local"


{-| Set the `type` attribute to `"decimal"`. Portmanteau of `type_` + `decimal` — for IDE discovery and single-import ergonomics.
-}
type_Decimal : Attr { c | type_ : Supported } msg
type_Decimal =
    Ir.attribute "type" "decimal"


{-| Set the `type` attribute to `"email"`. Portmanteau of `type_` + `email` — for IDE discovery and single-import ergonomics.
-}
type_Email : Attr { c | type_ : Supported } msg
type_Email =
    Ir.attribute "type" "email"


{-| Set the `type` attribute to `"normal"`. Portmanteau of `type_` + `normal` — for IDE discovery and single-import ergonomics.
-}
type_Normal : Attr { c | type_ : Supported } msg
type_Normal =
    Ir.attribute "type" "normal"


{-| Set the `type` attribute to `"number"`. Portmanteau of `type_` + `number` — for IDE discovery and single-import ergonomics.
-}
type_Number : Attr { c | type_ : Supported } msg
type_Number =
    Ir.attribute "type" "number"


{-| Set the `type` attribute to `"password"`. Portmanteau of `type_` + `password` — for IDE discovery and single-import ergonomics.
-}
type_Password : Attr { c | type_ : Supported } msg
type_Password =
    Ir.attribute "type" "password"


{-| Set the `type` attribute to `"percent"`. Portmanteau of `type_` + `percent` — for IDE discovery and single-import ergonomics.
-}
type_Percent : Attr { c | type_ : Supported } msg
type_Percent =
    Ir.attribute "type" "percent"


{-| Set the `type` attribute to `"reset"`. Portmanteau of `type_` + `reset` — for IDE discovery and single-import ergonomics.
-}
type_Reset : Attr { c | type_ : Supported } msg
type_Reset =
    Ir.attribute "type" "reset"


{-| Set the `type` attribute to `"search"`. Portmanteau of `type_` + `search` — for IDE discovery and single-import ergonomics.
-}
type_Search : Attr { c | type_ : Supported } msg
type_Search =
    Ir.attribute "type" "search"


{-| Set the `type` attribute to `"submit"`. Portmanteau of `type_` + `submit` — for IDE discovery and single-import ergonomics.
-}
type_Submit : Attr { c | type_ : Supported } msg
type_Submit =
    Ir.attribute "type" "submit"


{-| Set the `type` attribute to `"tel"`. Portmanteau of `type_` + `tel` — for IDE discovery and single-import ergonomics.
-}
type_Tel : Attr { c | type_ : Supported } msg
type_Tel =
    Ir.attribute "type" "tel"


{-| Set the `type` attribute to `"text"`. Portmanteau of `type_` + `text` — for IDE discovery and single-import ergonomics.
-}
type_Text : Attr { c | type_ : Supported } msg
type_Text =
    Ir.attribute "type" "text"


{-| Set the `type` attribute to `"time"`. Portmanteau of `type_` + `time` — for IDE discovery and single-import ergonomics.
-}
type_Time : Attr { c | type_ : Supported } msg
type_Time =
    Ir.attribute "type" "time"


{-| Set the `type` attribute to `"url"`. Portmanteau of `type_` + `url` — for IDE discovery and single-import ergonomics.
-}
type_Url : Attr { c | type_ : Supported } msg
type_Url =
    Ir.attribute "type" "url"


{-| Set the `unit` attribute to `"bit"`. Portmanteau of `unit` + `bit` — for IDE discovery and single-import ergonomics.
-}
unitBit : Attr { c | unit : Supported } msg
unitBit =
    Ir.attribute "unit" "bit"


{-| Set the `unit` attribute to `"byte"`. Portmanteau of `unit` + `byte` — for IDE discovery and single-import ergonomics.
-}
unitByte : Attr { c | unit : Supported } msg
unitByte =
    Ir.attribute "unit" "byte"


{-| Set the `variant` attribute to `"danger"`. Portmanteau of `variant` + `danger` — for IDE discovery and single-import ergonomics.
-}
variantDanger : Attr { c | variant : Supported } msg
variantDanger =
    Ir.attribute "variant" "danger"


{-| Set the `variant` attribute to `"default"`. Portmanteau of `variant` + `default` — for IDE discovery and single-import ergonomics.
-}
variantDefault : Attr { c | variant : Supported } msg
variantDefault =
    Ir.attribute "variant" "default"


{-| Set the `variant` attribute to `"neutral"`. Portmanteau of `variant` + `neutral` — for IDE discovery and single-import ergonomics.
-}
variantNeutral : Attr { c | variant : Supported } msg
variantNeutral =
    Ir.attribute "variant" "neutral"


{-| Set the `variant` attribute to `"primary"`. Portmanteau of `variant` + `primary` — for IDE discovery and single-import ergonomics.
-}
variantPrimary : Attr { c | variant : Supported } msg
variantPrimary =
    Ir.attribute "variant" "primary"


{-| Set the `variant` attribute to `"success"`. Portmanteau of `variant` + `success` — for IDE discovery and single-import ergonomics.
-}
variantSuccess : Attr { c | variant : Supported } msg
variantSuccess =
    Ir.attribute "variant" "success"


{-| Set the `variant` attribute to `"text"`. Portmanteau of `variant` + `text` — for IDE discovery and single-import ergonomics.
-}
variantText : Attr { c | variant : Supported } msg
variantText =
    Ir.attribute "variant" "text"


{-| Set the `variant` attribute to `"warning"`. Portmanteau of `variant` + `warning` — for IDE discovery and single-import ergonomics.
-}
variantWarning : Attr { c | variant : Supported } msg
variantWarning =
    Ir.attribute "variant" "warning"


{-| Set the `weekday` attribute to `"long"`. Portmanteau of `weekday` + `long` — for IDE discovery and single-import ergonomics.
-}
weekdayLong : Attr { c | weekday : Supported } msg
weekdayLong =
    Ir.attribute "weekday" "long"


{-| Set the `weekday` attribute to `"narrow"`. Portmanteau of `weekday` + `narrow` — for IDE discovery and single-import ergonomics.
-}
weekdayNarrow : Attr { c | weekday : Supported } msg
weekdayNarrow =
    Ir.attribute "weekday" "narrow"


{-| Set the `weekday` attribute to `"short"`. Portmanteau of `weekday` + `short` — for IDE discovery and single-import ergonomics.
-}
weekdayShort : Attr { c | weekday : Supported } msg
weekdayShort =
    Ir.attribute "weekday" "short"


{-| Set the `year` attribute to `"2-digit"`. Portmanteau of `year` + `2-digit` — for IDE discovery and single-import ergonomics.
-}
yearValue2Digit : Attr { c | year : Supported } msg
yearValue2Digit =
    Ir.attribute "year" "2-digit"


{-| Set the `year` attribute to `"numeric"`. Portmanteau of `year` + `numeric` — for IDE discovery and single-import ergonomics.
-}
yearNumeric : Attr { c | year : Supported } msg
yearNumeric =
    Ir.attribute "year" "numeric"
