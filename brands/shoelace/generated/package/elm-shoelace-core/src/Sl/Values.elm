module Sl.Values exposing
    ( Value
    , toString
    , Activation, ArrowPlacement, AutoSize, Autocapitalize, Autocorrect, Countdown, CurrencyDisplay, Day, Display, Effect, Enterkeyhint, Era, ErrorCorrection, FlipFallbackStrategy, Format, Formenctype, Formmethod, Formtarget, Hour, HourFormat, Inputmode, Loading, Minute, Mode, Month, Numeric, Orientation, Placement, Primary, Resize, Second, Selection, Shape, Size, Strategy, Sync, Target, TimeZoneName, Tooltip, TooltipPlacement, Type, Unit, Variant, Weekday, Year
    , activationFromString, activationValues, arrowPlacementFromString, arrowPlacementValues, autoSizeFromString, autoSizeValues, autocapitalizeFromString, autocapitalizeValues, autocorrectFromString, autocorrectValues, countdownFromString, countdownValues, currencyDisplayFromString, currencyDisplayValues, dayFromString, dayValues, displayFromString, displayValues, effect_FromString, effect_Values, enterkeyhintFromString, enterkeyhintValues, eraFromString, eraValues, errorCorrectionFromString, errorCorrectionValues, flipFallbackStrategyFromString, flipFallbackStrategyValues, formatFromString, formatValues, formenctypeFromString, formenctypeValues, formmethodFromString, formmethodValues, formtargetFromString, formtargetValues, hourFormatFromString, hourFormatValues, hourFromString, hourValues, inputmodeFromString, inputmodeValues, loadingFromString, loadingValues, minuteFromString, minuteValues, modeFromString, modeValues, monthFromString, monthValues, numericFromString, numericValues, orientationFromString, orientationValues, placementFromString, placementValues, primaryFromString, primaryValues, resizeFromString, resizeValues, secondFromString, secondValues, selectionFromString, selectionValues, shapeFromString, shapeValues, sizeFromString, sizeValues, strategyFromString, strategyValues, syncFromString, syncValues, targetFromString, targetValues, timeZoneNameFromString, timeZoneNameValues, tooltipFromString, tooltipPlacementFromString, tooltipPlacementValues, tooltipValues, type_FromString, type_Values, unitFromString, unitValues, variantFromString, variantValues, weekdayFromString, weekdayValues, yearFromString, yearValues
    , value12, value2Digit, value24, h, l, m, q, blank_, parent_, self_, top_, absolute, always, anchor, applicationXWwwFormUrlencoded, auto, bestFit, bit, both, bottom, bottomEnd, bottomStart, button, byte, center, characters, checkbox, circle, code, cors, currency, danger, date, datetimeLocal, decimal, default, done, eager, email, end, enter, fixed, get, go, height, hex, horizontal, hsl, hsv, initial, large, lazy, leaf, left, leftEnd, leftStart, long, ltr, manual, medium, multipartFormData, multiple, name, narrow, narrowsymbol, neutral, next, noCors, none, normal, number, numeric, off, on, password, percent, post, previous, primary, pulse, reset, rgb, right, rightEnd, rightStart, rounded, rtl, sameOrigin, search, send, sentences, sheen, short, single, small, square, start, submit, success, symbol, tel, text, textPlain, time, top, topEnd, topStart, url, vertical, warning, width, words
    , activationAuto, activationManual, arrowPlacementAnchor, arrowPlacementCenter, arrowPlacementEnd, arrowPlacementStart, autoSizeBoth, autoSizeHorizontal, autoSizeVertical, autocapitalizeCharacters, autocapitalizeNone, autocapitalizeOff, autocapitalizeOn, autocapitalizeSentences, autocapitalizeWords, autocorrectOff, autocorrectOn, countdownLtr, countdownRtl, currencyDisplayCode, currencyDisplayName, currencyDisplayNarrowsymbol, currencyDisplaySymbol, dayValue2Digit, dayNumeric, displayLong, displayNarrow, displayShort, effect_None, effect_Pulse, effect_Sheen, enterkeyhintDone, enterkeyhintEnter, enterkeyhintGo, enterkeyhintNext, enterkeyhintPrevious, enterkeyhintSearch, enterkeyhintSend, eraLong, eraNarrow, eraShort, errorCorrectionH, errorCorrectionL, errorCorrectionM, errorCorrectionQ, flipFallbackStrategyBestFit, flipFallbackStrategyInitial, formatHex, formatHsl, formatHsv, formatLong, formatNarrow, formatRgb, formatShort, formenctypeApplicationXWwwFormUrlencoded, formenctypeMultipartFormData, formenctypeTextPlain, formmethodGet, formmethodPost, formtargetBlank_, formtargetParent_, formtargetSelf_, formtargetTop_, hourValue2Digit, hourNumeric, hourFormatValue12, hourFormatValue24, hourFormatAuto, inputmodeDecimal, inputmodeEmail, inputmodeNone, inputmodeNumeric, inputmodeSearch, inputmodeTel, inputmodeText, inputmodeUrl, loadingEager, loadingLazy, minuteValue2Digit, minuteNumeric, modeCors, modeNoCors, modeSameOrigin, monthValue2Digit, monthLong, monthNarrow, monthNumeric, monthShort, numericAlways, numericAuto, orientationHorizontal, orientationVertical, placementBottom, placementBottomEnd, placementBottomStart, placementEnd, placementLeft, placementLeftEnd, placementLeftStart, placementRight, placementRightEnd, placementRightStart, placementStart, placementTop, placementTopEnd, placementTopStart, primaryEnd, primaryStart, resizeAuto, resizeNone, resizeVertical, secondValue2Digit, secondNumeric, selectionLeaf, selectionMultiple, selectionSingle, shapeCircle, shapeRounded, shapeSquare, sizeLarge, sizeMedium, sizeSmall, strategyAbsolute, strategyFixed, syncBoth, syncHeight, syncWidth, targetBlank_, targetParent_, targetSelf_, targetTop_, timeZoneNameLong, timeZoneNameShort, tooltipBottom, tooltipNone, tooltipTop, tooltipPlacementBottom, tooltipPlacementLeft, tooltipPlacementRight, tooltipPlacementTop, type_Button, type_Checkbox, type_Currency, type_Date, type_DatetimeLocal, type_Decimal, type_Email, type_Normal, type_Number, type_Password, type_Percent, type_Reset, type_Search, type_Submit, type_Tel, type_Text, type_Time, type_Url, unitBit, unitByte, variantDanger, variantDefault, variantNeutral, variantPrimary, variantSuccess, variantText, variantWarning, weekdayLong, weekdayNarrow, weekdayShort, yearValue2Digit, yearNumeric
    )

{-| The enum-value vocabulary: every token minted once (open row), plus the
library-wide union row per enum attribute, plus attribute-prefixed
portmanteaus (`variantFilled`, `shapeRounded`, …) for IDE discovery.
General setters close over the union; per-component setters narrow — both
are fed by these same tokens.

`Value` is re-exported here so annotating a token never requires an
`HtmlIr.Value` import.

@docs Value
@docs toString
@docs Activation, ArrowPlacement, AutoSize, Autocapitalize, Autocorrect, Countdown, CurrencyDisplay, Day, Display, Effect, Enterkeyhint, Era, ErrorCorrection, FlipFallbackStrategy, Format, Formenctype, Formmethod, Formtarget, Hour, HourFormat, Inputmode, Loading, Minute, Mode, Month, Numeric, Orientation, Placement, Primary, Resize, Second, Selection, Shape, Size, Strategy, Sync, Target, TimeZoneName, Tooltip, TooltipPlacement, Type, Unit, Variant, Weekday, Year
@docs activationFromString, activationValues, arrowPlacementFromString, arrowPlacementValues, autoSizeFromString, autoSizeValues, autocapitalizeFromString, autocapitalizeValues, autocorrectFromString, autocorrectValues, countdownFromString, countdownValues, currencyDisplayFromString, currencyDisplayValues, dayFromString, dayValues, displayFromString, displayValues, effect_FromString, effect_Values, enterkeyhintFromString, enterkeyhintValues, eraFromString, eraValues, errorCorrectionFromString, errorCorrectionValues, flipFallbackStrategyFromString, flipFallbackStrategyValues, formatFromString, formatValues, formenctypeFromString, formenctypeValues, formmethodFromString, formmethodValues, formtargetFromString, formtargetValues, hourFormatFromString, hourFormatValues, hourFromString, hourValues, inputmodeFromString, inputmodeValues, loadingFromString, loadingValues, minuteFromString, minuteValues, modeFromString, modeValues, monthFromString, monthValues, numericFromString, numericValues, orientationFromString, orientationValues, placementFromString, placementValues, primaryFromString, primaryValues, resizeFromString, resizeValues, secondFromString, secondValues, selectionFromString, selectionValues, shapeFromString, shapeValues, sizeFromString, sizeValues, strategyFromString, strategyValues, syncFromString, syncValues, targetFromString, targetValues, timeZoneNameFromString, timeZoneNameValues, tooltipFromString, tooltipPlacementFromString, tooltipPlacementValues, tooltipValues, type_FromString, type_Values, unitFromString, unitValues, variantFromString, variantValues, weekdayFromString, weekdayValues, yearFromString, yearValues
@docs value12, value2Digit, value24, h, l, m, q, blank_, parent_, self_, top_, absolute, always, anchor, applicationXWwwFormUrlencoded, auto, bestFit, bit, both, bottom, bottomEnd, bottomStart, button, byte, center, characters, checkbox, circle, code, cors, currency, danger, date, datetimeLocal, decimal, default, done, eager, email, end, enter, fixed, get, go, height, hex, horizontal, hsl, hsv, initial, large, lazy, leaf, left, leftEnd, leftStart, long, ltr, manual, medium, multipartFormData, multiple, name, narrow, narrowsymbol, neutral, next, noCors, none, normal, number, numeric, off, on, password, percent, post, previous, primary, pulse, reset, rgb, right, rightEnd, rightStart, rounded, rtl, sameOrigin, search, send, sentences, sheen, short, single, small, square, start, submit, success, symbol, tel, text, textPlain, time, top, topEnd, topStart, url, vertical, warning, width, words
@docs activationAuto, activationManual, arrowPlacementAnchor, arrowPlacementCenter, arrowPlacementEnd, arrowPlacementStart, autoSizeBoth, autoSizeHorizontal, autoSizeVertical, autocapitalizeCharacters, autocapitalizeNone, autocapitalizeOff, autocapitalizeOn, autocapitalizeSentences, autocapitalizeWords, autocorrectOff, autocorrectOn, countdownLtr, countdownRtl, currencyDisplayCode, currencyDisplayName, currencyDisplayNarrowsymbol, currencyDisplaySymbol, dayValue2Digit, dayNumeric, displayLong, displayNarrow, displayShort, effect_None, effect_Pulse, effect_Sheen, enterkeyhintDone, enterkeyhintEnter, enterkeyhintGo, enterkeyhintNext, enterkeyhintPrevious, enterkeyhintSearch, enterkeyhintSend, eraLong, eraNarrow, eraShort, errorCorrectionH, errorCorrectionL, errorCorrectionM, errorCorrectionQ, flipFallbackStrategyBestFit, flipFallbackStrategyInitial, formatHex, formatHsl, formatHsv, formatLong, formatNarrow, formatRgb, formatShort, formenctypeApplicationXWwwFormUrlencoded, formenctypeMultipartFormData, formenctypeTextPlain, formmethodGet, formmethodPost, formtargetBlank_, formtargetParent_, formtargetSelf_, formtargetTop_, hourValue2Digit, hourNumeric, hourFormatValue12, hourFormatValue24, hourFormatAuto, inputmodeDecimal, inputmodeEmail, inputmodeNone, inputmodeNumeric, inputmodeSearch, inputmodeTel, inputmodeText, inputmodeUrl, loadingEager, loadingLazy, minuteValue2Digit, minuteNumeric, modeCors, modeNoCors, modeSameOrigin, monthValue2Digit, monthLong, monthNarrow, monthNumeric, monthShort, numericAlways, numericAuto, orientationHorizontal, orientationVertical, placementBottom, placementBottomEnd, placementBottomStart, placementEnd, placementLeft, placementLeftEnd, placementLeftStart, placementRight, placementRightEnd, placementRightStart, placementStart, placementTop, placementTopEnd, placementTopStart, primaryEnd, primaryStart, resizeAuto, resizeNone, resizeVertical, secondValue2Digit, secondNumeric, selectionLeaf, selectionMultiple, selectionSingle, shapeCircle, shapeRounded, shapeSquare, sizeLarge, sizeMedium, sizeSmall, strategyAbsolute, strategyFixed, syncBoth, syncHeight, syncWidth, targetBlank_, targetParent_, targetSelf_, targetTop_, timeZoneNameLong, timeZoneNameShort, tooltipBottom, tooltipNone, tooltipTop, tooltipPlacementBottom, tooltipPlacementLeft, tooltipPlacementRight, tooltipPlacementTop, type_Button, type_Checkbox, type_Currency, type_Date, type_DatetimeLocal, type_Decimal, type_Email, type_Normal, type_Number, type_Password, type_Percent, type_Reset, type_Search, type_Submit, type_Tel, type_Text, type_Time, type_Url, unitBit, unitByte, variantDanger, variantDefault, variantNeutral, variantPrimary, variantSuccess, variantText, variantWarning, weekdayLong, weekdayNarrow, weekdayShort, yearValue2Digit, yearNumeric

-}

import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value


{-| The phantom-tagged enum token. Re-exported so callers never import `HtmlIr.Value` directly.
-}
type alias Value tags =
    HtmlIr.Value.Value tags


{-| The token's underlying string — the safe out-bound direction. Re-exported so callers never import `HtmlIr.Value` directly.
-}
toString : Value tags -> String
toString =
    HtmlIr.Value.toString


{-| The union row for `activation`.
-}
type alias Activation =
    { auto : Supported
    , manual : Supported
    }


{-| The union row for `arrowPlacement`.
-}
type alias ArrowPlacement =
    { anchor : Supported
    , center : Supported
    , end : Supported
    , start : Supported
    }


{-| The union row for `autoSize`.
-}
type alias AutoSize =
    { both : Supported
    , horizontal : Supported
    , vertical : Supported
    }


{-| The union row for `autocapitalize`.
-}
type alias Autocapitalize =
    { characters : Supported
    , none : Supported
    , off : Supported
    , on : Supported
    , sentences : Supported
    , words : Supported
    }


{-| The union row for `autocorrect`.
-}
type alias Autocorrect =
    { off : Supported
    , on : Supported
    }


{-| The union row for `countdown`.
-}
type alias Countdown =
    { ltr : Supported
    , rtl : Supported
    }


{-| The union row for `currencyDisplay`.
-}
type alias CurrencyDisplay =
    { code : Supported
    , name : Supported
    , narrowsymbol : Supported
    , symbol : Supported
    }


{-| The union row for `day`.
-}
type alias Day =
    { value2Digit : Supported
    , numeric : Supported
    }


{-| The union row for `display`.
-}
type alias Display =
    { long : Supported
    , narrow : Supported
    , short : Supported
    }


{-| The union row for `effect_`.
-}
type alias Effect =
    { none : Supported
    , pulse : Supported
    , sheen : Supported
    }


{-| The union row for `enterkeyhint`.
-}
type alias Enterkeyhint =
    { done : Supported
    , enter : Supported
    , go : Supported
    , next : Supported
    , previous : Supported
    , search : Supported
    , send : Supported
    }


{-| The union row for `era`.
-}
type alias Era =
    { long : Supported
    , narrow : Supported
    , short : Supported
    }


{-| The union row for `errorCorrection`.
-}
type alias ErrorCorrection =
    { h : Supported
    , l : Supported
    , m : Supported
    , q : Supported
    }


{-| The union row for `flipFallbackStrategy`.
-}
type alias FlipFallbackStrategy =
    { bestFit : Supported
    , initial : Supported
    }


{-| The union row for `format`.
-}
type alias Format =
    { hex : Supported
    , hsl : Supported
    , hsv : Supported
    , long : Supported
    , narrow : Supported
    , rgb : Supported
    , short : Supported
    }


{-| The union row for `formenctype`.
-}
type alias Formenctype =
    { applicationXWwwFormUrlencoded : Supported
    , multipartFormData : Supported
    , textPlain : Supported
    }


{-| The union row for `formmethod`.
-}
type alias Formmethod =
    { get : Supported
    , post : Supported
    }


{-| The union row for `formtarget`.
-}
type alias Formtarget =
    { blank_ : Supported
    , parent_ : Supported
    , self_ : Supported
    , top_ : Supported
    }


{-| The union row for `hour`.
-}
type alias Hour =
    { value2Digit : Supported
    , numeric : Supported
    }


{-| The union row for `hourFormat`.
-}
type alias HourFormat =
    { value12 : Supported
    , value24 : Supported
    , auto : Supported
    }


{-| The union row for `inputmode`.
-}
type alias Inputmode =
    { decimal : Supported
    , email : Supported
    , none : Supported
    , numeric : Supported
    , search : Supported
    , tel : Supported
    , text : Supported
    , url : Supported
    }


{-| The union row for `loading`.
-}
type alias Loading =
    { eager : Supported
    , lazy : Supported
    }


{-| The union row for `minute`.
-}
type alias Minute =
    { value2Digit : Supported
    , numeric : Supported
    }


{-| The union row for `mode`.
-}
type alias Mode =
    { cors : Supported
    , noCors : Supported
    , sameOrigin : Supported
    }


{-| The union row for `month`.
-}
type alias Month =
    { value2Digit : Supported
    , long : Supported
    , narrow : Supported
    , numeric : Supported
    , short : Supported
    }


{-| The union row for `numeric`.
-}
type alias Numeric =
    { always : Supported
    , auto : Supported
    }


{-| The union row for `orientation`.
-}
type alias Orientation =
    { horizontal : Supported
    , vertical : Supported
    }


{-| The union row for `placement`.
-}
type alias Placement =
    { bottom : Supported
    , bottomEnd : Supported
    , bottomStart : Supported
    , end : Supported
    , left : Supported
    , leftEnd : Supported
    , leftStart : Supported
    , right : Supported
    , rightEnd : Supported
    , rightStart : Supported
    , start : Supported
    , top : Supported
    , topEnd : Supported
    , topStart : Supported
    }


{-| The union row for `primary`.
-}
type alias Primary =
    { end : Supported
    , start : Supported
    }


{-| The union row for `resize`.
-}
type alias Resize =
    { auto : Supported
    , none : Supported
    , vertical : Supported
    }


{-| The union row for `second`.
-}
type alias Second =
    { value2Digit : Supported
    , numeric : Supported
    }


{-| The union row for `selection`.
-}
type alias Selection =
    { leaf : Supported
    , multiple : Supported
    , single : Supported
    }


{-| The union row for `shape`.
-}
type alias Shape =
    { circle : Supported
    , rounded : Supported
    , square : Supported
    }


{-| The union row for `size`.
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The union row for `strategy`.
-}
type alias Strategy =
    { absolute : Supported
    , fixed : Supported
    }


{-| The union row for `sync`.
-}
type alias Sync =
    { both : Supported
    , height : Supported
    , width : Supported
    }


{-| The union row for `target`.
-}
type alias Target =
    { blank_ : Supported
    , parent_ : Supported
    , self_ : Supported
    , top_ : Supported
    }


{-| The union row for `timeZoneName`.
-}
type alias TimeZoneName =
    { long : Supported
    , short : Supported
    }


{-| The union row for `tooltip`.
-}
type alias Tooltip =
    { bottom : Supported
    , none : Supported
    , top : Supported
    }


{-| The union row for `tooltipPlacement`.
-}
type alias TooltipPlacement =
    { bottom : Supported
    , left : Supported
    , right : Supported
    , top : Supported
    }


{-| The union row for `type_`.
-}
type alias Type =
    { button : Supported
    , checkbox : Supported
    , currency : Supported
    , date : Supported
    , datetimeLocal : Supported
    , decimal : Supported
    , email : Supported
    , normal : Supported
    , number : Supported
    , password : Supported
    , percent : Supported
    , reset : Supported
    , search : Supported
    , submit : Supported
    , tel : Supported
    , text : Supported
    , time : Supported
    , url : Supported
    }


{-| The union row for `unit`.
-}
type alias Unit =
    { bit : Supported
    , byte : Supported
    }


{-| The union row for `variant`.
-}
type alias Variant =
    { danger : Supported
    , default : Supported
    , neutral : Supported
    , primary : Supported
    , success : Supported
    , text : Supported
    , warning : Supported
    }


{-| The union row for `weekday`.
-}
type alias Weekday =
    { long : Supported
    , narrow : Supported
    , short : Supported
    }


{-| The union row for `year`.
-}
type alias Year =
    { value2Digit : Supported
    , numeric : Supported
    }


{-| Parse a `activation` value from the string it writes to the DOM. The inverse of `toString`.
-}
activationFromString : String -> Maybe (Value Activation)
activationFromString s =
    case s of
        "auto" ->
            Just auto

        "manual" ->
            Just manual

        _ ->
            Nothing


{-| Parse a `arrowPlacement` value from the string it writes to the DOM. The inverse of `toString`.
-}
arrowPlacementFromString : String -> Maybe (Value ArrowPlacement)
arrowPlacementFromString s =
    case s of
        "anchor" ->
            Just anchor

        "center" ->
            Just center

        "end" ->
            Just end

        "start" ->
            Just start

        _ ->
            Nothing


{-| Parse a `autoSize` value from the string it writes to the DOM. The inverse of `toString`.
-}
autoSizeFromString : String -> Maybe (Value AutoSize)
autoSizeFromString s =
    case s of
        "both" ->
            Just both

        "horizontal" ->
            Just horizontal

        "vertical" ->
            Just vertical

        _ ->
            Nothing


{-| Parse a `autocapitalize` value from the string it writes to the DOM. The inverse of `toString`.
-}
autocapitalizeFromString : String -> Maybe (Value Autocapitalize)
autocapitalizeFromString s =
    case s of
        "characters" ->
            Just characters

        "none" ->
            Just none

        "off" ->
            Just off

        "on" ->
            Just on

        "sentences" ->
            Just sentences

        "words" ->
            Just words

        _ ->
            Nothing


{-| Parse a `autocorrect` value from the string it writes to the DOM. The inverse of `toString`.
-}
autocorrectFromString : String -> Maybe (Value Autocorrect)
autocorrectFromString s =
    case s of
        "off" ->
            Just off

        "on" ->
            Just on

        _ ->
            Nothing


{-| Parse a `countdown` value from the string it writes to the DOM. The inverse of `toString`.
-}
countdownFromString : String -> Maybe (Value Countdown)
countdownFromString s =
    case s of
        "ltr" ->
            Just ltr

        "rtl" ->
            Just rtl

        _ ->
            Nothing


{-| Parse a `currencyDisplay` value from the string it writes to the DOM. The inverse of `toString`.
-}
currencyDisplayFromString : String -> Maybe (Value CurrencyDisplay)
currencyDisplayFromString s =
    case s of
        "code" ->
            Just code

        "name" ->
            Just name

        "narrowSymbol" ->
            Just narrowsymbol

        "symbol" ->
            Just symbol

        _ ->
            Nothing


{-| Parse a `day` value from the string it writes to the DOM. The inverse of `toString`.
-}
dayFromString : String -> Maybe (Value Day)
dayFromString s =
    case s of
        "2-digit" ->
            Just value2Digit

        "numeric" ->
            Just numeric

        _ ->
            Nothing


{-| Parse a `display` value from the string it writes to the DOM. The inverse of `toString`.
-}
displayFromString : String -> Maybe (Value Display)
displayFromString s =
    case s of
        "long" ->
            Just long

        "narrow" ->
            Just narrow

        "short" ->
            Just short

        _ ->
            Nothing


{-| Parse a `effect_` value from the string it writes to the DOM. The inverse of `toString`.
-}
effect_FromString : String -> Maybe (Value Effect)
effect_FromString s =
    case s of
        "none" ->
            Just none

        "pulse" ->
            Just pulse

        "sheen" ->
            Just sheen

        _ ->
            Nothing


{-| Parse a `enterkeyhint` value from the string it writes to the DOM. The inverse of `toString`.
-}
enterkeyhintFromString : String -> Maybe (Value Enterkeyhint)
enterkeyhintFromString s =
    case s of
        "done" ->
            Just done

        "enter" ->
            Just enter

        "go" ->
            Just go

        "next" ->
            Just next

        "previous" ->
            Just previous

        "search" ->
            Just search

        "send" ->
            Just send

        _ ->
            Nothing


{-| Parse a `era` value from the string it writes to the DOM. The inverse of `toString`.
-}
eraFromString : String -> Maybe (Value Era)
eraFromString s =
    case s of
        "long" ->
            Just long

        "narrow" ->
            Just narrow

        "short" ->
            Just short

        _ ->
            Nothing


{-| Parse a `errorCorrection` value from the string it writes to the DOM. The inverse of `toString`.
-}
errorCorrectionFromString : String -> Maybe (Value ErrorCorrection)
errorCorrectionFromString s =
    case s of
        "H" ->
            Just h

        "L" ->
            Just l

        "M" ->
            Just m

        "Q" ->
            Just q

        _ ->
            Nothing


{-| Parse a `flipFallbackStrategy` value from the string it writes to the DOM. The inverse of `toString`.
-}
flipFallbackStrategyFromString : String -> Maybe (Value FlipFallbackStrategy)
flipFallbackStrategyFromString s =
    case s of
        "best-fit" ->
            Just bestFit

        "initial" ->
            Just initial

        _ ->
            Nothing


{-| Parse a `format` value from the string it writes to the DOM. The inverse of `toString`.
-}
formatFromString : String -> Maybe (Value Format)
formatFromString s =
    case s of
        "hex" ->
            Just hex

        "hsl" ->
            Just hsl

        "hsv" ->
            Just hsv

        "long" ->
            Just long

        "narrow" ->
            Just narrow

        "rgb" ->
            Just rgb

        "short" ->
            Just short

        _ ->
            Nothing


{-| Parse a `formenctype` value from the string it writes to the DOM. The inverse of `toString`.
-}
formenctypeFromString : String -> Maybe (Value Formenctype)
formenctypeFromString s =
    case s of
        "application/x-www-form-urlencoded" ->
            Just applicationXWwwFormUrlencoded

        "multipart/form-data" ->
            Just multipartFormData

        "text/plain" ->
            Just textPlain

        _ ->
            Nothing


{-| Parse a `formmethod` value from the string it writes to the DOM. The inverse of `toString`.
-}
formmethodFromString : String -> Maybe (Value Formmethod)
formmethodFromString s =
    case s of
        "get" ->
            Just get

        "post" ->
            Just post

        _ ->
            Nothing


{-| Parse a `formtarget` value from the string it writes to the DOM. The inverse of `toString`.
-}
formtargetFromString : String -> Maybe (Value Formtarget)
formtargetFromString s =
    case s of
        "_blank" ->
            Just blank_

        "_parent" ->
            Just parent_

        "_self" ->
            Just self_

        "_top" ->
            Just top_

        _ ->
            Nothing


{-| Parse a `hour` value from the string it writes to the DOM. The inverse of `toString`.
-}
hourFromString : String -> Maybe (Value Hour)
hourFromString s =
    case s of
        "2-digit" ->
            Just value2Digit

        "numeric" ->
            Just numeric

        _ ->
            Nothing


{-| Parse a `hourFormat` value from the string it writes to the DOM. The inverse of `toString`.
-}
hourFormatFromString : String -> Maybe (Value HourFormat)
hourFormatFromString s =
    case s of
        "12" ->
            Just value12

        "24" ->
            Just value24

        "auto" ->
            Just auto

        _ ->
            Nothing


{-| Parse a `inputmode` value from the string it writes to the DOM. The inverse of `toString`.
-}
inputmodeFromString : String -> Maybe (Value Inputmode)
inputmodeFromString s =
    case s of
        "decimal" ->
            Just decimal

        "email" ->
            Just email

        "none" ->
            Just none

        "numeric" ->
            Just numeric

        "search" ->
            Just search

        "tel" ->
            Just tel

        "text" ->
            Just text

        "url" ->
            Just url

        _ ->
            Nothing


{-| Parse a `loading` value from the string it writes to the DOM. The inverse of `toString`.
-}
loadingFromString : String -> Maybe (Value Loading)
loadingFromString s =
    case s of
        "eager" ->
            Just eager

        "lazy" ->
            Just lazy

        _ ->
            Nothing


{-| Parse a `minute` value from the string it writes to the DOM. The inverse of `toString`.
-}
minuteFromString : String -> Maybe (Value Minute)
minuteFromString s =
    case s of
        "2-digit" ->
            Just value2Digit

        "numeric" ->
            Just numeric

        _ ->
            Nothing


{-| Parse a `mode` value from the string it writes to the DOM. The inverse of `toString`.
-}
modeFromString : String -> Maybe (Value Mode)
modeFromString s =
    case s of
        "cors" ->
            Just cors

        "no-cors" ->
            Just noCors

        "same-origin" ->
            Just sameOrigin

        _ ->
            Nothing


{-| Parse a `month` value from the string it writes to the DOM. The inverse of `toString`.
-}
monthFromString : String -> Maybe (Value Month)
monthFromString s =
    case s of
        "2-digit" ->
            Just value2Digit

        "long" ->
            Just long

        "narrow" ->
            Just narrow

        "numeric" ->
            Just numeric

        "short" ->
            Just short

        _ ->
            Nothing


{-| Parse a `numeric` value from the string it writes to the DOM. The inverse of `toString`.
-}
numericFromString : String -> Maybe (Value Numeric)
numericFromString s =
    case s of
        "always" ->
            Just always

        "auto" ->
            Just auto

        _ ->
            Nothing


{-| Parse a `orientation` value from the string it writes to the DOM. The inverse of `toString`.
-}
orientationFromString : String -> Maybe (Value Orientation)
orientationFromString s =
    case s of
        "horizontal" ->
            Just horizontal

        "vertical" ->
            Just vertical

        _ ->
            Nothing


{-| Parse a `placement` value from the string it writes to the DOM. The inverse of `toString`.
-}
placementFromString : String -> Maybe (Value Placement)
placementFromString s =
    case s of
        "bottom" ->
            Just bottom

        "bottom-end" ->
            Just bottomEnd

        "bottom-start" ->
            Just bottomStart

        "end" ->
            Just end

        "left" ->
            Just left

        "left-end" ->
            Just leftEnd

        "left-start" ->
            Just leftStart

        "right" ->
            Just right

        "right-end" ->
            Just rightEnd

        "right-start" ->
            Just rightStart

        "start" ->
            Just start

        "top" ->
            Just top

        "top-end" ->
            Just topEnd

        "top-start" ->
            Just topStart

        _ ->
            Nothing


{-| Parse a `primary` value from the string it writes to the DOM. The inverse of `toString`.
-}
primaryFromString : String -> Maybe (Value Primary)
primaryFromString s =
    case s of
        "end" ->
            Just end

        "start" ->
            Just start

        _ ->
            Nothing


{-| Parse a `resize` value from the string it writes to the DOM. The inverse of `toString`.
-}
resizeFromString : String -> Maybe (Value Resize)
resizeFromString s =
    case s of
        "auto" ->
            Just auto

        "none" ->
            Just none

        "vertical" ->
            Just vertical

        _ ->
            Nothing


{-| Parse a `second` value from the string it writes to the DOM. The inverse of `toString`.
-}
secondFromString : String -> Maybe (Value Second)
secondFromString s =
    case s of
        "2-digit" ->
            Just value2Digit

        "numeric" ->
            Just numeric

        _ ->
            Nothing


{-| Parse a `selection` value from the string it writes to the DOM. The inverse of `toString`.
-}
selectionFromString : String -> Maybe (Value Selection)
selectionFromString s =
    case s of
        "leaf" ->
            Just leaf

        "multiple" ->
            Just multiple

        "single" ->
            Just single

        _ ->
            Nothing


{-| Parse a `shape` value from the string it writes to the DOM. The inverse of `toString`.
-}
shapeFromString : String -> Maybe (Value Shape)
shapeFromString s =
    case s of
        "circle" ->
            Just circle

        "rounded" ->
            Just rounded

        "square" ->
            Just square

        _ ->
            Nothing


{-| Parse a `size` value from the string it writes to the DOM. The inverse of `toString`.
-}
sizeFromString : String -> Maybe (Value Size)
sizeFromString s =
    case s of
        "large" ->
            Just large

        "medium" ->
            Just medium

        "small" ->
            Just small

        _ ->
            Nothing


{-| Parse a `strategy` value from the string it writes to the DOM. The inverse of `toString`.
-}
strategyFromString : String -> Maybe (Value Strategy)
strategyFromString s =
    case s of
        "absolute" ->
            Just absolute

        "fixed" ->
            Just fixed

        _ ->
            Nothing


{-| Parse a `sync` value from the string it writes to the DOM. The inverse of `toString`.
-}
syncFromString : String -> Maybe (Value Sync)
syncFromString s =
    case s of
        "both" ->
            Just both

        "height" ->
            Just height

        "width" ->
            Just width

        _ ->
            Nothing


{-| Parse a `target` value from the string it writes to the DOM. The inverse of `toString`.
-}
targetFromString : String -> Maybe (Value Target)
targetFromString s =
    case s of
        "_blank" ->
            Just blank_

        "_parent" ->
            Just parent_

        "_self" ->
            Just self_

        "_top" ->
            Just top_

        _ ->
            Nothing


{-| Parse a `timeZoneName` value from the string it writes to the DOM. The inverse of `toString`.
-}
timeZoneNameFromString : String -> Maybe (Value TimeZoneName)
timeZoneNameFromString s =
    case s of
        "long" ->
            Just long

        "short" ->
            Just short

        _ ->
            Nothing


{-| Parse a `tooltip` value from the string it writes to the DOM. The inverse of `toString`.
-}
tooltipFromString : String -> Maybe (Value Tooltip)
tooltipFromString s =
    case s of
        "bottom" ->
            Just bottom

        "none" ->
            Just none

        "top" ->
            Just top

        _ ->
            Nothing


{-| Parse a `tooltipPlacement` value from the string it writes to the DOM. The inverse of `toString`.
-}
tooltipPlacementFromString : String -> Maybe (Value TooltipPlacement)
tooltipPlacementFromString s =
    case s of
        "bottom" ->
            Just bottom

        "left" ->
            Just left

        "right" ->
            Just right

        "top" ->
            Just top

        _ ->
            Nothing


{-| Parse a `type_` value from the string it writes to the DOM. The inverse of `toString`.
-}
type_FromString : String -> Maybe (Value Type)
type_FromString s =
    case s of
        "button" ->
            Just button

        "checkbox" ->
            Just checkbox

        "currency" ->
            Just currency

        "date" ->
            Just date

        "datetime-local" ->
            Just datetimeLocal

        "decimal" ->
            Just decimal

        "email" ->
            Just email

        "normal" ->
            Just normal

        "number" ->
            Just number

        "password" ->
            Just password

        "percent" ->
            Just percent

        "reset" ->
            Just reset

        "search" ->
            Just search

        "submit" ->
            Just submit

        "tel" ->
            Just tel

        "text" ->
            Just text

        "time" ->
            Just time

        "url" ->
            Just url

        _ ->
            Nothing


{-| Parse a `unit` value from the string it writes to the DOM. The inverse of `toString`.
-}
unitFromString : String -> Maybe (Value Unit)
unitFromString s =
    case s of
        "bit" ->
            Just bit

        "byte" ->
            Just byte

        _ ->
            Nothing


{-| Parse a `variant` value from the string it writes to the DOM. The inverse of `toString`.
-}
variantFromString : String -> Maybe (Value Variant)
variantFromString s =
    case s of
        "danger" ->
            Just danger

        "default" ->
            Just default

        "neutral" ->
            Just neutral

        "primary" ->
            Just primary

        "success" ->
            Just success

        "text" ->
            Just text

        "warning" ->
            Just warning

        _ ->
            Nothing


{-| Parse a `weekday` value from the string it writes to the DOM. The inverse of `toString`.
-}
weekdayFromString : String -> Maybe (Value Weekday)
weekdayFromString s =
    case s of
        "long" ->
            Just long

        "narrow" ->
            Just narrow

        "short" ->
            Just short

        _ ->
            Nothing


{-| Parse a `year` value from the string it writes to the DOM. The inverse of `toString`.
-}
yearFromString : String -> Maybe (Value Year)
yearFromString s =
    case s of
        "2-digit" ->
            Just value2Digit

        "numeric" ->
            Just numeric

        _ ->
            Nothing


{-| Every `activation` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
activationValues : List (Value Activation)
activationValues =
    [ auto, manual ]


{-| Every `arrowPlacement` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
arrowPlacementValues : List (Value ArrowPlacement)
arrowPlacementValues =
    [ anchor, center, end, start ]


{-| Every `autoSize` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
autoSizeValues : List (Value AutoSize)
autoSizeValues =
    [ both, horizontal, vertical ]


{-| Every `autocapitalize` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
autocapitalizeValues : List (Value Autocapitalize)
autocapitalizeValues =
    [ characters, none, off, on, sentences, words ]


{-| Every `autocorrect` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
autocorrectValues : List (Value Autocorrect)
autocorrectValues =
    [ off, on ]


{-| Every `countdown` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
countdownValues : List (Value Countdown)
countdownValues =
    [ ltr, rtl ]


{-| Every `currencyDisplay` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
currencyDisplayValues : List (Value CurrencyDisplay)
currencyDisplayValues =
    [ code, name, narrowsymbol, symbol ]


{-| Every `day` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
dayValues : List (Value Day)
dayValues =
    [ value2Digit, numeric ]


{-| Every `display` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
displayValues : List (Value Display)
displayValues =
    [ long, narrow, short ]


{-| Every `effect_` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
effect_Values : List (Value Effect)
effect_Values =
    [ none, pulse, sheen ]


{-| Every `enterkeyhint` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
enterkeyhintValues : List (Value Enterkeyhint)
enterkeyhintValues =
    [ done, enter, go, next, previous, search, send ]


{-| Every `era` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
eraValues : List (Value Era)
eraValues =
    [ long, narrow, short ]


{-| Every `errorCorrection` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
errorCorrectionValues : List (Value ErrorCorrection)
errorCorrectionValues =
    [ h, l, m, q ]


{-| Every `flipFallbackStrategy` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
flipFallbackStrategyValues : List (Value FlipFallbackStrategy)
flipFallbackStrategyValues =
    [ bestFit, initial ]


{-| Every `format` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
formatValues : List (Value Format)
formatValues =
    [ hex, hsl, hsv, long, narrow, rgb, short ]


{-| Every `formenctype` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
formenctypeValues : List (Value Formenctype)
formenctypeValues =
    [ applicationXWwwFormUrlencoded, multipartFormData, textPlain ]


{-| Every `formmethod` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
formmethodValues : List (Value Formmethod)
formmethodValues =
    [ get, post ]


{-| Every `formtarget` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
formtargetValues : List (Value Formtarget)
formtargetValues =
    [ blank_, parent_, self_, top_ ]


{-| Every `hour` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
hourValues : List (Value Hour)
hourValues =
    [ value2Digit, numeric ]


{-| Every `hourFormat` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
hourFormatValues : List (Value HourFormat)
hourFormatValues =
    [ value12, value24, auto ]


{-| Every `inputmode` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
inputmodeValues : List (Value Inputmode)
inputmodeValues =
    [ decimal, email, none, numeric, search, tel, text, url ]


{-| Every `loading` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
loadingValues : List (Value Loading)
loadingValues =
    [ eager, lazy ]


{-| Every `minute` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
minuteValues : List (Value Minute)
minuteValues =
    [ value2Digit, numeric ]


{-| Every `mode` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
modeValues : List (Value Mode)
modeValues =
    [ cors, noCors, sameOrigin ]


{-| Every `month` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
monthValues : List (Value Month)
monthValues =
    [ value2Digit, long, narrow, numeric, short ]


{-| Every `numeric` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
numericValues : List (Value Numeric)
numericValues =
    [ always, auto ]


{-| Every `orientation` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
orientationValues : List (Value Orientation)
orientationValues =
    [ horizontal, vertical ]


{-| Every `placement` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
placementValues : List (Value Placement)
placementValues =
    [ bottom, bottomEnd, bottomStart, end, left, leftEnd, leftStart, right, rightEnd, rightStart, start, top, topEnd, topStart ]


{-| Every `primary` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
primaryValues : List (Value Primary)
primaryValues =
    [ end, start ]


{-| Every `resize` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
resizeValues : List (Value Resize)
resizeValues =
    [ auto, none, vertical ]


{-| Every `second` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
secondValues : List (Value Second)
secondValues =
    [ value2Digit, numeric ]


{-| Every `selection` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
selectionValues : List (Value Selection)
selectionValues =
    [ leaf, multiple, single ]


{-| Every `shape` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
shapeValues : List (Value Shape)
shapeValues =
    [ circle, rounded, square ]


{-| Every `size` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
sizeValues : List (Value Size)
sizeValues =
    [ large, medium, small ]


{-| Every `strategy` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
strategyValues : List (Value Strategy)
strategyValues =
    [ absolute, fixed ]


{-| Every `sync` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
syncValues : List (Value Sync)
syncValues =
    [ both, height, width ]


{-| Every `target` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
targetValues : List (Value Target)
targetValues =
    [ blank_, parent_, self_, top_ ]


{-| Every `timeZoneName` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
timeZoneNameValues : List (Value TimeZoneName)
timeZoneNameValues =
    [ long, short ]


{-| Every `tooltip` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
tooltipValues : List (Value Tooltip)
tooltipValues =
    [ bottom, none, top ]


{-| Every `tooltipPlacement` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
tooltipPlacementValues : List (Value TooltipPlacement)
tooltipPlacementValues =
    [ bottom, left, right, top ]


{-| Every `type_` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
type_Values : List (Value Type)
type_Values =
    [ button, checkbox, currency, date, datetimeLocal, decimal, email, normal, number, password, percent, reset, search, submit, tel, text, time, url ]


{-| Every `unit` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
unitValues : List (Value Unit)
unitValues =
    [ bit, byte ]


{-| Every `variant` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
variantValues : List (Value Variant)
variantValues =
    [ danger, default, neutral, primary, success, text, warning ]


{-| Every `weekday` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
weekdayValues : List (Value Weekday)
weekdayValues =
    [ long, narrow, short ]


{-| Every `year` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
yearValues : List (Value Year)
yearValues =
    [ value2Digit, numeric ]


{-| The `12` token.
-}
value12 : Value { v | value12 : Supported }
value12 =
    Ir.token "12"


{-| The `2-digit` token.
-}
value2Digit : Value { v | value2Digit : Supported }
value2Digit =
    Ir.token "2-digit"


{-| The `24` token.
-}
value24 : Value { v | value24 : Supported }
value24 =
    Ir.token "24"


{-| The `H` token.
-}
h : Value { v | h : Supported }
h =
    Ir.token "H"


{-| The `L` token.
-}
l : Value { v | l : Supported }
l =
    Ir.token "L"


{-| The `M` token.
-}
m : Value { v | m : Supported }
m =
    Ir.token "M"


{-| The `Q` token.
-}
q : Value { v | q : Supported }
q =
    Ir.token "Q"


{-| The `_blank` token.
-}
blank_ : Value { v | blank_ : Supported }
blank_ =
    Ir.token "_blank"


{-| The `_parent` token.
-}
parent_ : Value { v | parent_ : Supported }
parent_ =
    Ir.token "_parent"


{-| The `_self` token.
-}
self_ : Value { v | self_ : Supported }
self_ =
    Ir.token "_self"


{-| The `_top` token.
-}
top_ : Value { v | top_ : Supported }
top_ =
    Ir.token "_top"


{-| The `absolute` token.
-}
absolute : Value { v | absolute : Supported }
absolute =
    Ir.token "absolute"


{-| The `always` token.
-}
always : Value { v | always : Supported }
always =
    Ir.token "always"


{-| The `anchor` token.
-}
anchor : Value { v | anchor : Supported }
anchor =
    Ir.token "anchor"


{-| The `application/x-www-form-urlencoded` token.
-}
applicationXWwwFormUrlencoded : Value { v | applicationXWwwFormUrlencoded : Supported }
applicationXWwwFormUrlencoded =
    Ir.token "application/x-www-form-urlencoded"


{-| The `auto` token.
-}
auto : Value { v | auto : Supported }
auto =
    Ir.token "auto"


{-| The `best-fit` token.
-}
bestFit : Value { v | bestFit : Supported }
bestFit =
    Ir.token "best-fit"


{-| The `bit` token.
-}
bit : Value { v | bit : Supported }
bit =
    Ir.token "bit"


{-| The `both` token.
-}
both : Value { v | both : Supported }
both =
    Ir.token "both"


{-| The `bottom` token.
-}
bottom : Value { v | bottom : Supported }
bottom =
    Ir.token "bottom"


{-| The `bottom-end` token.
-}
bottomEnd : Value { v | bottomEnd : Supported }
bottomEnd =
    Ir.token "bottom-end"


{-| The `bottom-start` token.
-}
bottomStart : Value { v | bottomStart : Supported }
bottomStart =
    Ir.token "bottom-start"


{-| The `button` token.
-}
button : Value { v | button : Supported }
button =
    Ir.token "button"


{-| The `byte` token.
-}
byte : Value { v | byte : Supported }
byte =
    Ir.token "byte"


{-| The `center` token.
-}
center : Value { v | center : Supported }
center =
    Ir.token "center"


{-| The `characters` token.
-}
characters : Value { v | characters : Supported }
characters =
    Ir.token "characters"


{-| The `checkbox` token.
-}
checkbox : Value { v | checkbox : Supported }
checkbox =
    Ir.token "checkbox"


{-| The `circle` token.
-}
circle : Value { v | circle : Supported }
circle =
    Ir.token "circle"


{-| The `code` token.
-}
code : Value { v | code : Supported }
code =
    Ir.token "code"


{-| The `cors` token.
-}
cors : Value { v | cors : Supported }
cors =
    Ir.token "cors"


{-| The `currency` token.
-}
currency : Value { v | currency : Supported }
currency =
    Ir.token "currency"


{-| The `danger` token.
-}
danger : Value { v | danger : Supported }
danger =
    Ir.token "danger"


{-| The `date` token.
-}
date : Value { v | date : Supported }
date =
    Ir.token "date"


{-| The `datetime-local` token.
-}
datetimeLocal : Value { v | datetimeLocal : Supported }
datetimeLocal =
    Ir.token "datetime-local"


{-| The `decimal` token.
-}
decimal : Value { v | decimal : Supported }
decimal =
    Ir.token "decimal"


{-| The `default` token.
-}
default : Value { v | default : Supported }
default =
    Ir.token "default"


{-| The `done` token.
-}
done : Value { v | done : Supported }
done =
    Ir.token "done"


{-| The `eager` token.
-}
eager : Value { v | eager : Supported }
eager =
    Ir.token "eager"


{-| The `email` token.
-}
email : Value { v | email : Supported }
email =
    Ir.token "email"


{-| The `end` token.
-}
end : Value { v | end : Supported }
end =
    Ir.token "end"


{-| The `enter` token.
-}
enter : Value { v | enter : Supported }
enter =
    Ir.token "enter"


{-| The `fixed` token.
-}
fixed : Value { v | fixed : Supported }
fixed =
    Ir.token "fixed"


{-| The `get` token.
-}
get : Value { v | get : Supported }
get =
    Ir.token "get"


{-| The `go` token.
-}
go : Value { v | go : Supported }
go =
    Ir.token "go"


{-| The `height` token.
-}
height : Value { v | height : Supported }
height =
    Ir.token "height"


{-| The `hex` token.
-}
hex : Value { v | hex : Supported }
hex =
    Ir.token "hex"


{-| The `horizontal` token.
-}
horizontal : Value { v | horizontal : Supported }
horizontal =
    Ir.token "horizontal"


{-| The `hsl` token.
-}
hsl : Value { v | hsl : Supported }
hsl =
    Ir.token "hsl"


{-| The `hsv` token.
-}
hsv : Value { v | hsv : Supported }
hsv =
    Ir.token "hsv"


{-| The `initial` token.
-}
initial : Value { v | initial : Supported }
initial =
    Ir.token "initial"


{-| The `large` token.
-}
large : Value { v | large : Supported }
large =
    Ir.token "large"


{-| The `lazy` token.
-}
lazy : Value { v | lazy : Supported }
lazy =
    Ir.token "lazy"


{-| The `leaf` token.
-}
leaf : Value { v | leaf : Supported }
leaf =
    Ir.token "leaf"


{-| The `left` token.
-}
left : Value { v | left : Supported }
left =
    Ir.token "left"


{-| The `left-end` token.
-}
leftEnd : Value { v | leftEnd : Supported }
leftEnd =
    Ir.token "left-end"


{-| The `left-start` token.
-}
leftStart : Value { v | leftStart : Supported }
leftStart =
    Ir.token "left-start"


{-| The `long` token.
-}
long : Value { v | long : Supported }
long =
    Ir.token "long"


{-| The `ltr` token.
-}
ltr : Value { v | ltr : Supported }
ltr =
    Ir.token "ltr"


{-| The `manual` token.
-}
manual : Value { v | manual : Supported }
manual =
    Ir.token "manual"


{-| The `medium` token.
-}
medium : Value { v | medium : Supported }
medium =
    Ir.token "medium"


{-| The `multipart/form-data` token.
-}
multipartFormData : Value { v | multipartFormData : Supported }
multipartFormData =
    Ir.token "multipart/form-data"


{-| The `multiple` token.
-}
multiple : Value { v | multiple : Supported }
multiple =
    Ir.token "multiple"


{-| The `name` token.
-}
name : Value { v | name : Supported }
name =
    Ir.token "name"


{-| The `narrow` token.
-}
narrow : Value { v | narrow : Supported }
narrow =
    Ir.token "narrow"


{-| The `narrowSymbol` token.
-}
narrowsymbol : Value { v | narrowsymbol : Supported }
narrowsymbol =
    Ir.token "narrowSymbol"


{-| The `neutral` token.
-}
neutral : Value { v | neutral : Supported }
neutral =
    Ir.token "neutral"


{-| The `next` token.
-}
next : Value { v | next : Supported }
next =
    Ir.token "next"


{-| The `no-cors` token.
-}
noCors : Value { v | noCors : Supported }
noCors =
    Ir.token "no-cors"


{-| The `none` token.
-}
none : Value { v | none : Supported }
none =
    Ir.token "none"


{-| The `normal` token.
-}
normal : Value { v | normal : Supported }
normal =
    Ir.token "normal"


{-| The `number` token.
-}
number : Value { v | number : Supported }
number =
    Ir.token "number"


{-| The `numeric` token.
-}
numeric : Value { v | numeric : Supported }
numeric =
    Ir.token "numeric"


{-| The `off` token.
-}
off : Value { v | off : Supported }
off =
    Ir.token "off"


{-| The `on` token.
-}
on : Value { v | on : Supported }
on =
    Ir.token "on"


{-| The `password` token.
-}
password : Value { v | password : Supported }
password =
    Ir.token "password"


{-| The `percent` token.
-}
percent : Value { v | percent : Supported }
percent =
    Ir.token "percent"


{-| The `post` token.
-}
post : Value { v | post : Supported }
post =
    Ir.token "post"


{-| The `previous` token.
-}
previous : Value { v | previous : Supported }
previous =
    Ir.token "previous"


{-| The `primary` token.
-}
primary : Value { v | primary : Supported }
primary =
    Ir.token "primary"


{-| The `pulse` token.
-}
pulse : Value { v | pulse : Supported }
pulse =
    Ir.token "pulse"


{-| The `reset` token.
-}
reset : Value { v | reset : Supported }
reset =
    Ir.token "reset"


{-| The `rgb` token.
-}
rgb : Value { v | rgb : Supported }
rgb =
    Ir.token "rgb"


{-| The `right` token.
-}
right : Value { v | right : Supported }
right =
    Ir.token "right"


{-| The `right-end` token.
-}
rightEnd : Value { v | rightEnd : Supported }
rightEnd =
    Ir.token "right-end"


{-| The `right-start` token.
-}
rightStart : Value { v | rightStart : Supported }
rightStart =
    Ir.token "right-start"


{-| The `rounded` token.
-}
rounded : Value { v | rounded : Supported }
rounded =
    Ir.token "rounded"


{-| The `rtl` token.
-}
rtl : Value { v | rtl : Supported }
rtl =
    Ir.token "rtl"


{-| The `same-origin` token.
-}
sameOrigin : Value { v | sameOrigin : Supported }
sameOrigin =
    Ir.token "same-origin"


{-| The `search` token.
-}
search : Value { v | search : Supported }
search =
    Ir.token "search"


{-| The `send` token.
-}
send : Value { v | send : Supported }
send =
    Ir.token "send"


{-| The `sentences` token.
-}
sentences : Value { v | sentences : Supported }
sentences =
    Ir.token "sentences"


{-| The `sheen` token.
-}
sheen : Value { v | sheen : Supported }
sheen =
    Ir.token "sheen"


{-| The `short` token.
-}
short : Value { v | short : Supported }
short =
    Ir.token "short"


{-| The `single` token.
-}
single : Value { v | single : Supported }
single =
    Ir.token "single"


{-| The `small` token.
-}
small : Value { v | small : Supported }
small =
    Ir.token "small"


{-| The `square` token.
-}
square : Value { v | square : Supported }
square =
    Ir.token "square"


{-| The `start` token.
-}
start : Value { v | start : Supported }
start =
    Ir.token "start"


{-| The `submit` token.
-}
submit : Value { v | submit : Supported }
submit =
    Ir.token "submit"


{-| The `success` token.
-}
success : Value { v | success : Supported }
success =
    Ir.token "success"


{-| The `symbol` token.
-}
symbol : Value { v | symbol : Supported }
symbol =
    Ir.token "symbol"


{-| The `tel` token.
-}
tel : Value { v | tel : Supported }
tel =
    Ir.token "tel"


{-| The `text` token.
-}
text : Value { v | text : Supported }
text =
    Ir.token "text"


{-| The `text/plain` token.
-}
textPlain : Value { v | textPlain : Supported }
textPlain =
    Ir.token "text/plain"


{-| The `time` token.
-}
time : Value { v | time : Supported }
time =
    Ir.token "time"


{-| The `top` token.
-}
top : Value { v | top : Supported }
top =
    Ir.token "top"


{-| The `top-end` token.
-}
topEnd : Value { v | topEnd : Supported }
topEnd =
    Ir.token "top-end"


{-| The `top-start` token.
-}
topStart : Value { v | topStart : Supported }
topStart =
    Ir.token "top-start"


{-| The `url` token.
-}
url : Value { v | url : Supported }
url =
    Ir.token "url"


{-| The `vertical` token.
-}
vertical : Value { v | vertical : Supported }
vertical =
    Ir.token "vertical"


{-| The `warning` token.
-}
warning : Value { v | warning : Supported }
warning =
    Ir.token "warning"


{-| The `width` token.
-}
width : Value { v | width : Supported }
width =
    Ir.token "width"


{-| The `words` token.
-}
words : Value { v | words : Supported }
words =
    Ir.token "words"


{-| The `auto` value of the `activation` enum — same open row as `auto`, prefixed for discovery.
-}
activationAuto : Value { v | auto : Supported }
activationAuto =
    Ir.token "auto"


{-| The `manual` value of the `activation` enum — same open row as `manual`, prefixed for discovery.
-}
activationManual : Value { v | manual : Supported }
activationManual =
    Ir.token "manual"


{-| The `anchor` value of the `arrowPlacement` enum — same open row as `anchor`, prefixed for discovery.
-}
arrowPlacementAnchor : Value { v | anchor : Supported }
arrowPlacementAnchor =
    Ir.token "anchor"


{-| The `center` value of the `arrowPlacement` enum — same open row as `center`, prefixed for discovery.
-}
arrowPlacementCenter : Value { v | center : Supported }
arrowPlacementCenter =
    Ir.token "center"


{-| The `end` value of the `arrowPlacement` enum — same open row as `end`, prefixed for discovery.
-}
arrowPlacementEnd : Value { v | end : Supported }
arrowPlacementEnd =
    Ir.token "end"


{-| The `start` value of the `arrowPlacement` enum — same open row as `start`, prefixed for discovery.
-}
arrowPlacementStart : Value { v | start : Supported }
arrowPlacementStart =
    Ir.token "start"


{-| The `both` value of the `autoSize` enum — same open row as `both`, prefixed for discovery.
-}
autoSizeBoth : Value { v | both : Supported }
autoSizeBoth =
    Ir.token "both"


{-| The `horizontal` value of the `autoSize` enum — same open row as `horizontal`, prefixed for discovery.
-}
autoSizeHorizontal : Value { v | horizontal : Supported }
autoSizeHorizontal =
    Ir.token "horizontal"


{-| The `vertical` value of the `autoSize` enum — same open row as `vertical`, prefixed for discovery.
-}
autoSizeVertical : Value { v | vertical : Supported }
autoSizeVertical =
    Ir.token "vertical"


{-| The `characters` value of the `autocapitalize` enum — same open row as `characters`, prefixed for discovery.
-}
autocapitalizeCharacters : Value { v | characters : Supported }
autocapitalizeCharacters =
    Ir.token "characters"


{-| The `none` value of the `autocapitalize` enum — same open row as `none`, prefixed for discovery.
-}
autocapitalizeNone : Value { v | none : Supported }
autocapitalizeNone =
    Ir.token "none"


{-| The `off` value of the `autocapitalize` enum — same open row as `off`, prefixed for discovery.
-}
autocapitalizeOff : Value { v | off : Supported }
autocapitalizeOff =
    Ir.token "off"


{-| The `on` value of the `autocapitalize` enum — same open row as `on`, prefixed for discovery.
-}
autocapitalizeOn : Value { v | on : Supported }
autocapitalizeOn =
    Ir.token "on"


{-| The `sentences` value of the `autocapitalize` enum — same open row as `sentences`, prefixed for discovery.
-}
autocapitalizeSentences : Value { v | sentences : Supported }
autocapitalizeSentences =
    Ir.token "sentences"


{-| The `words` value of the `autocapitalize` enum — same open row as `words`, prefixed for discovery.
-}
autocapitalizeWords : Value { v | words : Supported }
autocapitalizeWords =
    Ir.token "words"


{-| The `off` value of the `autocorrect` enum — same open row as `off`, prefixed for discovery.
-}
autocorrectOff : Value { v | off : Supported }
autocorrectOff =
    Ir.token "off"


{-| The `on` value of the `autocorrect` enum — same open row as `on`, prefixed for discovery.
-}
autocorrectOn : Value { v | on : Supported }
autocorrectOn =
    Ir.token "on"


{-| The `ltr` value of the `countdown` enum — same open row as `ltr`, prefixed for discovery.
-}
countdownLtr : Value { v | ltr : Supported }
countdownLtr =
    Ir.token "ltr"


{-| The `rtl` value of the `countdown` enum — same open row as `rtl`, prefixed for discovery.
-}
countdownRtl : Value { v | rtl : Supported }
countdownRtl =
    Ir.token "rtl"


{-| The `code` value of the `currencyDisplay` enum — same open row as `code`, prefixed for discovery.
-}
currencyDisplayCode : Value { v | code : Supported }
currencyDisplayCode =
    Ir.token "code"


{-| The `name` value of the `currencyDisplay` enum — same open row as `name`, prefixed for discovery.
-}
currencyDisplayName : Value { v | name : Supported }
currencyDisplayName =
    Ir.token "name"


{-| The `narrowSymbol` value of the `currencyDisplay` enum — same open row as `narrowsymbol`, prefixed for discovery.
-}
currencyDisplayNarrowsymbol : Value { v | narrowsymbol : Supported }
currencyDisplayNarrowsymbol =
    Ir.token "narrowSymbol"


{-| The `symbol` value of the `currencyDisplay` enum — same open row as `symbol`, prefixed for discovery.
-}
currencyDisplaySymbol : Value { v | symbol : Supported }
currencyDisplaySymbol =
    Ir.token "symbol"


{-| The `2-digit` value of the `day` enum — same open row as `value2Digit`, prefixed for discovery.
-}
dayValue2Digit : Value { v | value2Digit : Supported }
dayValue2Digit =
    Ir.token "2-digit"


{-| The `numeric` value of the `day` enum — same open row as `numeric`, prefixed for discovery.
-}
dayNumeric : Value { v | numeric : Supported }
dayNumeric =
    Ir.token "numeric"


{-| The `long` value of the `display` enum — same open row as `long`, prefixed for discovery.
-}
displayLong : Value { v | long : Supported }
displayLong =
    Ir.token "long"


{-| The `narrow` value of the `display` enum — same open row as `narrow`, prefixed for discovery.
-}
displayNarrow : Value { v | narrow : Supported }
displayNarrow =
    Ir.token "narrow"


{-| The `short` value of the `display` enum — same open row as `short`, prefixed for discovery.
-}
displayShort : Value { v | short : Supported }
displayShort =
    Ir.token "short"


{-| The `none` value of the `effect_` enum — same open row as `none`, prefixed for discovery.
-}
effect_None : Value { v | none : Supported }
effect_None =
    Ir.token "none"


{-| The `pulse` value of the `effect_` enum — same open row as `pulse`, prefixed for discovery.
-}
effect_Pulse : Value { v | pulse : Supported }
effect_Pulse =
    Ir.token "pulse"


{-| The `sheen` value of the `effect_` enum — same open row as `sheen`, prefixed for discovery.
-}
effect_Sheen : Value { v | sheen : Supported }
effect_Sheen =
    Ir.token "sheen"


{-| The `done` value of the `enterkeyhint` enum — same open row as `done`, prefixed for discovery.
-}
enterkeyhintDone : Value { v | done : Supported }
enterkeyhintDone =
    Ir.token "done"


{-| The `enter` value of the `enterkeyhint` enum — same open row as `enter`, prefixed for discovery.
-}
enterkeyhintEnter : Value { v | enter : Supported }
enterkeyhintEnter =
    Ir.token "enter"


{-| The `go` value of the `enterkeyhint` enum — same open row as `go`, prefixed for discovery.
-}
enterkeyhintGo : Value { v | go : Supported }
enterkeyhintGo =
    Ir.token "go"


{-| The `next` value of the `enterkeyhint` enum — same open row as `next`, prefixed for discovery.
-}
enterkeyhintNext : Value { v | next : Supported }
enterkeyhintNext =
    Ir.token "next"


{-| The `previous` value of the `enterkeyhint` enum — same open row as `previous`, prefixed for discovery.
-}
enterkeyhintPrevious : Value { v | previous : Supported }
enterkeyhintPrevious =
    Ir.token "previous"


{-| The `search` value of the `enterkeyhint` enum — same open row as `search`, prefixed for discovery.
-}
enterkeyhintSearch : Value { v | search : Supported }
enterkeyhintSearch =
    Ir.token "search"


{-| The `send` value of the `enterkeyhint` enum — same open row as `send`, prefixed for discovery.
-}
enterkeyhintSend : Value { v | send : Supported }
enterkeyhintSend =
    Ir.token "send"


{-| The `long` value of the `era` enum — same open row as `long`, prefixed for discovery.
-}
eraLong : Value { v | long : Supported }
eraLong =
    Ir.token "long"


{-| The `narrow` value of the `era` enum — same open row as `narrow`, prefixed for discovery.
-}
eraNarrow : Value { v | narrow : Supported }
eraNarrow =
    Ir.token "narrow"


{-| The `short` value of the `era` enum — same open row as `short`, prefixed for discovery.
-}
eraShort : Value { v | short : Supported }
eraShort =
    Ir.token "short"


{-| The `H` value of the `errorCorrection` enum — same open row as `h`, prefixed for discovery.
-}
errorCorrectionH : Value { v | h : Supported }
errorCorrectionH =
    Ir.token "H"


{-| The `L` value of the `errorCorrection` enum — same open row as `l`, prefixed for discovery.
-}
errorCorrectionL : Value { v | l : Supported }
errorCorrectionL =
    Ir.token "L"


{-| The `M` value of the `errorCorrection` enum — same open row as `m`, prefixed for discovery.
-}
errorCorrectionM : Value { v | m : Supported }
errorCorrectionM =
    Ir.token "M"


{-| The `Q` value of the `errorCorrection` enum — same open row as `q`, prefixed for discovery.
-}
errorCorrectionQ : Value { v | q : Supported }
errorCorrectionQ =
    Ir.token "Q"


{-| The `best-fit` value of the `flipFallbackStrategy` enum — same open row as `bestFit`, prefixed for discovery.
-}
flipFallbackStrategyBestFit : Value { v | bestFit : Supported }
flipFallbackStrategyBestFit =
    Ir.token "best-fit"


{-| The `initial` value of the `flipFallbackStrategy` enum — same open row as `initial`, prefixed for discovery.
-}
flipFallbackStrategyInitial : Value { v | initial : Supported }
flipFallbackStrategyInitial =
    Ir.token "initial"


{-| The `hex` value of the `format` enum — same open row as `hex`, prefixed for discovery.
-}
formatHex : Value { v | hex : Supported }
formatHex =
    Ir.token "hex"


{-| The `hsl` value of the `format` enum — same open row as `hsl`, prefixed for discovery.
-}
formatHsl : Value { v | hsl : Supported }
formatHsl =
    Ir.token "hsl"


{-| The `hsv` value of the `format` enum — same open row as `hsv`, prefixed for discovery.
-}
formatHsv : Value { v | hsv : Supported }
formatHsv =
    Ir.token "hsv"


{-| The `long` value of the `format` enum — same open row as `long`, prefixed for discovery.
-}
formatLong : Value { v | long : Supported }
formatLong =
    Ir.token "long"


{-| The `narrow` value of the `format` enum — same open row as `narrow`, prefixed for discovery.
-}
formatNarrow : Value { v | narrow : Supported }
formatNarrow =
    Ir.token "narrow"


{-| The `rgb` value of the `format` enum — same open row as `rgb`, prefixed for discovery.
-}
formatRgb : Value { v | rgb : Supported }
formatRgb =
    Ir.token "rgb"


{-| The `short` value of the `format` enum — same open row as `short`, prefixed for discovery.
-}
formatShort : Value { v | short : Supported }
formatShort =
    Ir.token "short"


{-| The `application/x-www-form-urlencoded` value of the `formenctype` enum — same open row as `applicationXWwwFormUrlencoded`, prefixed for discovery.
-}
formenctypeApplicationXWwwFormUrlencoded : Value { v | applicationXWwwFormUrlencoded : Supported }
formenctypeApplicationXWwwFormUrlencoded =
    Ir.token "application/x-www-form-urlencoded"


{-| The `multipart/form-data` value of the `formenctype` enum — same open row as `multipartFormData`, prefixed for discovery.
-}
formenctypeMultipartFormData : Value { v | multipartFormData : Supported }
formenctypeMultipartFormData =
    Ir.token "multipart/form-data"


{-| The `text/plain` value of the `formenctype` enum — same open row as `textPlain`, prefixed for discovery.
-}
formenctypeTextPlain : Value { v | textPlain : Supported }
formenctypeTextPlain =
    Ir.token "text/plain"


{-| The `get` value of the `formmethod` enum — same open row as `get`, prefixed for discovery.
-}
formmethodGet : Value { v | get : Supported }
formmethodGet =
    Ir.token "get"


{-| The `post` value of the `formmethod` enum — same open row as `post`, prefixed for discovery.
-}
formmethodPost : Value { v | post : Supported }
formmethodPost =
    Ir.token "post"


{-| The `_blank` value of the `formtarget` enum — same open row as `blank_`, prefixed for discovery.
-}
formtargetBlank_ : Value { v | blank_ : Supported }
formtargetBlank_ =
    Ir.token "_blank"


{-| The `_parent` value of the `formtarget` enum — same open row as `parent_`, prefixed for discovery.
-}
formtargetParent_ : Value { v | parent_ : Supported }
formtargetParent_ =
    Ir.token "_parent"


{-| The `_self` value of the `formtarget` enum — same open row as `self_`, prefixed for discovery.
-}
formtargetSelf_ : Value { v | self_ : Supported }
formtargetSelf_ =
    Ir.token "_self"


{-| The `_top` value of the `formtarget` enum — same open row as `top_`, prefixed for discovery.
-}
formtargetTop_ : Value { v | top_ : Supported }
formtargetTop_ =
    Ir.token "_top"


{-| The `2-digit` value of the `hour` enum — same open row as `value2Digit`, prefixed for discovery.
-}
hourValue2Digit : Value { v | value2Digit : Supported }
hourValue2Digit =
    Ir.token "2-digit"


{-| The `numeric` value of the `hour` enum — same open row as `numeric`, prefixed for discovery.
-}
hourNumeric : Value { v | numeric : Supported }
hourNumeric =
    Ir.token "numeric"


{-| The `12` value of the `hourFormat` enum — same open row as `value12`, prefixed for discovery.
-}
hourFormatValue12 : Value { v | value12 : Supported }
hourFormatValue12 =
    Ir.token "12"


{-| The `24` value of the `hourFormat` enum — same open row as `value24`, prefixed for discovery.
-}
hourFormatValue24 : Value { v | value24 : Supported }
hourFormatValue24 =
    Ir.token "24"


{-| The `auto` value of the `hourFormat` enum — same open row as `auto`, prefixed for discovery.
-}
hourFormatAuto : Value { v | auto : Supported }
hourFormatAuto =
    Ir.token "auto"


{-| The `decimal` value of the `inputmode` enum — same open row as `decimal`, prefixed for discovery.
-}
inputmodeDecimal : Value { v | decimal : Supported }
inputmodeDecimal =
    Ir.token "decimal"


{-| The `email` value of the `inputmode` enum — same open row as `email`, prefixed for discovery.
-}
inputmodeEmail : Value { v | email : Supported }
inputmodeEmail =
    Ir.token "email"


{-| The `none` value of the `inputmode` enum — same open row as `none`, prefixed for discovery.
-}
inputmodeNone : Value { v | none : Supported }
inputmodeNone =
    Ir.token "none"


{-| The `numeric` value of the `inputmode` enum — same open row as `numeric`, prefixed for discovery.
-}
inputmodeNumeric : Value { v | numeric : Supported }
inputmodeNumeric =
    Ir.token "numeric"


{-| The `search` value of the `inputmode` enum — same open row as `search`, prefixed for discovery.
-}
inputmodeSearch : Value { v | search : Supported }
inputmodeSearch =
    Ir.token "search"


{-| The `tel` value of the `inputmode` enum — same open row as `tel`, prefixed for discovery.
-}
inputmodeTel : Value { v | tel : Supported }
inputmodeTel =
    Ir.token "tel"


{-| The `text` value of the `inputmode` enum — same open row as `text`, prefixed for discovery.
-}
inputmodeText : Value { v | text : Supported }
inputmodeText =
    Ir.token "text"


{-| The `url` value of the `inputmode` enum — same open row as `url`, prefixed for discovery.
-}
inputmodeUrl : Value { v | url : Supported }
inputmodeUrl =
    Ir.token "url"


{-| The `eager` value of the `loading` enum — same open row as `eager`, prefixed for discovery.
-}
loadingEager : Value { v | eager : Supported }
loadingEager =
    Ir.token "eager"


{-| The `lazy` value of the `loading` enum — same open row as `lazy`, prefixed for discovery.
-}
loadingLazy : Value { v | lazy : Supported }
loadingLazy =
    Ir.token "lazy"


{-| The `2-digit` value of the `minute` enum — same open row as `value2Digit`, prefixed for discovery.
-}
minuteValue2Digit : Value { v | value2Digit : Supported }
minuteValue2Digit =
    Ir.token "2-digit"


{-| The `numeric` value of the `minute` enum — same open row as `numeric`, prefixed for discovery.
-}
minuteNumeric : Value { v | numeric : Supported }
minuteNumeric =
    Ir.token "numeric"


{-| The `cors` value of the `mode` enum — same open row as `cors`, prefixed for discovery.
-}
modeCors : Value { v | cors : Supported }
modeCors =
    Ir.token "cors"


{-| The `no-cors` value of the `mode` enum — same open row as `noCors`, prefixed for discovery.
-}
modeNoCors : Value { v | noCors : Supported }
modeNoCors =
    Ir.token "no-cors"


{-| The `same-origin` value of the `mode` enum — same open row as `sameOrigin`, prefixed for discovery.
-}
modeSameOrigin : Value { v | sameOrigin : Supported }
modeSameOrigin =
    Ir.token "same-origin"


{-| The `2-digit` value of the `month` enum — same open row as `value2Digit`, prefixed for discovery.
-}
monthValue2Digit : Value { v | value2Digit : Supported }
monthValue2Digit =
    Ir.token "2-digit"


{-| The `long` value of the `month` enum — same open row as `long`, prefixed for discovery.
-}
monthLong : Value { v | long : Supported }
monthLong =
    Ir.token "long"


{-| The `narrow` value of the `month` enum — same open row as `narrow`, prefixed for discovery.
-}
monthNarrow : Value { v | narrow : Supported }
monthNarrow =
    Ir.token "narrow"


{-| The `numeric` value of the `month` enum — same open row as `numeric`, prefixed for discovery.
-}
monthNumeric : Value { v | numeric : Supported }
monthNumeric =
    Ir.token "numeric"


{-| The `short` value of the `month` enum — same open row as `short`, prefixed for discovery.
-}
monthShort : Value { v | short : Supported }
monthShort =
    Ir.token "short"


{-| The `always` value of the `numeric` enum — same open row as `always`, prefixed for discovery.
-}
numericAlways : Value { v | always : Supported }
numericAlways =
    Ir.token "always"


{-| The `auto` value of the `numeric` enum — same open row as `auto`, prefixed for discovery.
-}
numericAuto : Value { v | auto : Supported }
numericAuto =
    Ir.token "auto"


{-| The `horizontal` value of the `orientation` enum — same open row as `horizontal`, prefixed for discovery.
-}
orientationHorizontal : Value { v | horizontal : Supported }
orientationHorizontal =
    Ir.token "horizontal"


{-| The `vertical` value of the `orientation` enum — same open row as `vertical`, prefixed for discovery.
-}
orientationVertical : Value { v | vertical : Supported }
orientationVertical =
    Ir.token "vertical"


{-| The `bottom` value of the `placement` enum — same open row as `bottom`, prefixed for discovery.
-}
placementBottom : Value { v | bottom : Supported }
placementBottom =
    Ir.token "bottom"


{-| The `bottom-end` value of the `placement` enum — same open row as `bottomEnd`, prefixed for discovery.
-}
placementBottomEnd : Value { v | bottomEnd : Supported }
placementBottomEnd =
    Ir.token "bottom-end"


{-| The `bottom-start` value of the `placement` enum — same open row as `bottomStart`, prefixed for discovery.
-}
placementBottomStart : Value { v | bottomStart : Supported }
placementBottomStart =
    Ir.token "bottom-start"


{-| The `end` value of the `placement` enum — same open row as `end`, prefixed for discovery.
-}
placementEnd : Value { v | end : Supported }
placementEnd =
    Ir.token "end"


{-| The `left` value of the `placement` enum — same open row as `left`, prefixed for discovery.
-}
placementLeft : Value { v | left : Supported }
placementLeft =
    Ir.token "left"


{-| The `left-end` value of the `placement` enum — same open row as `leftEnd`, prefixed for discovery.
-}
placementLeftEnd : Value { v | leftEnd : Supported }
placementLeftEnd =
    Ir.token "left-end"


{-| The `left-start` value of the `placement` enum — same open row as `leftStart`, prefixed for discovery.
-}
placementLeftStart : Value { v | leftStart : Supported }
placementLeftStart =
    Ir.token "left-start"


{-| The `right` value of the `placement` enum — same open row as `right`, prefixed for discovery.
-}
placementRight : Value { v | right : Supported }
placementRight =
    Ir.token "right"


{-| The `right-end` value of the `placement` enum — same open row as `rightEnd`, prefixed for discovery.
-}
placementRightEnd : Value { v | rightEnd : Supported }
placementRightEnd =
    Ir.token "right-end"


{-| The `right-start` value of the `placement` enum — same open row as `rightStart`, prefixed for discovery.
-}
placementRightStart : Value { v | rightStart : Supported }
placementRightStart =
    Ir.token "right-start"


{-| The `start` value of the `placement` enum — same open row as `start`, prefixed for discovery.
-}
placementStart : Value { v | start : Supported }
placementStart =
    Ir.token "start"


{-| The `top` value of the `placement` enum — same open row as `top`, prefixed for discovery.
-}
placementTop : Value { v | top : Supported }
placementTop =
    Ir.token "top"


{-| The `top-end` value of the `placement` enum — same open row as `topEnd`, prefixed for discovery.
-}
placementTopEnd : Value { v | topEnd : Supported }
placementTopEnd =
    Ir.token "top-end"


{-| The `top-start` value of the `placement` enum — same open row as `topStart`, prefixed for discovery.
-}
placementTopStart : Value { v | topStart : Supported }
placementTopStart =
    Ir.token "top-start"


{-| The `end` value of the `primary` enum — same open row as `end`, prefixed for discovery.
-}
primaryEnd : Value { v | end : Supported }
primaryEnd =
    Ir.token "end"


{-| The `start` value of the `primary` enum — same open row as `start`, prefixed for discovery.
-}
primaryStart : Value { v | start : Supported }
primaryStart =
    Ir.token "start"


{-| The `auto` value of the `resize` enum — same open row as `auto`, prefixed for discovery.
-}
resizeAuto : Value { v | auto : Supported }
resizeAuto =
    Ir.token "auto"


{-| The `none` value of the `resize` enum — same open row as `none`, prefixed for discovery.
-}
resizeNone : Value { v | none : Supported }
resizeNone =
    Ir.token "none"


{-| The `vertical` value of the `resize` enum — same open row as `vertical`, prefixed for discovery.
-}
resizeVertical : Value { v | vertical : Supported }
resizeVertical =
    Ir.token "vertical"


{-| The `2-digit` value of the `second` enum — same open row as `value2Digit`, prefixed for discovery.
-}
secondValue2Digit : Value { v | value2Digit : Supported }
secondValue2Digit =
    Ir.token "2-digit"


{-| The `numeric` value of the `second` enum — same open row as `numeric`, prefixed for discovery.
-}
secondNumeric : Value { v | numeric : Supported }
secondNumeric =
    Ir.token "numeric"


{-| The `leaf` value of the `selection` enum — same open row as `leaf`, prefixed for discovery.
-}
selectionLeaf : Value { v | leaf : Supported }
selectionLeaf =
    Ir.token "leaf"


{-| The `multiple` value of the `selection` enum — same open row as `multiple`, prefixed for discovery.
-}
selectionMultiple : Value { v | multiple : Supported }
selectionMultiple =
    Ir.token "multiple"


{-| The `single` value of the `selection` enum — same open row as `single`, prefixed for discovery.
-}
selectionSingle : Value { v | single : Supported }
selectionSingle =
    Ir.token "single"


{-| The `circle` value of the `shape` enum — same open row as `circle`, prefixed for discovery.
-}
shapeCircle : Value { v | circle : Supported }
shapeCircle =
    Ir.token "circle"


{-| The `rounded` value of the `shape` enum — same open row as `rounded`, prefixed for discovery.
-}
shapeRounded : Value { v | rounded : Supported }
shapeRounded =
    Ir.token "rounded"


{-| The `square` value of the `shape` enum — same open row as `square`, prefixed for discovery.
-}
shapeSquare : Value { v | square : Supported }
shapeSquare =
    Ir.token "square"


{-| The `large` value of the `size` enum — same open row as `large`, prefixed for discovery.
-}
sizeLarge : Value { v | large : Supported }
sizeLarge =
    Ir.token "large"


{-| The `medium` value of the `size` enum — same open row as `medium`, prefixed for discovery.
-}
sizeMedium : Value { v | medium : Supported }
sizeMedium =
    Ir.token "medium"


{-| The `small` value of the `size` enum — same open row as `small`, prefixed for discovery.
-}
sizeSmall : Value { v | small : Supported }
sizeSmall =
    Ir.token "small"


{-| The `absolute` value of the `strategy` enum — same open row as `absolute`, prefixed for discovery.
-}
strategyAbsolute : Value { v | absolute : Supported }
strategyAbsolute =
    Ir.token "absolute"


{-| The `fixed` value of the `strategy` enum — same open row as `fixed`, prefixed for discovery.
-}
strategyFixed : Value { v | fixed : Supported }
strategyFixed =
    Ir.token "fixed"


{-| The `both` value of the `sync` enum — same open row as `both`, prefixed for discovery.
-}
syncBoth : Value { v | both : Supported }
syncBoth =
    Ir.token "both"


{-| The `height` value of the `sync` enum — same open row as `height`, prefixed for discovery.
-}
syncHeight : Value { v | height : Supported }
syncHeight =
    Ir.token "height"


{-| The `width` value of the `sync` enum — same open row as `width`, prefixed for discovery.
-}
syncWidth : Value { v | width : Supported }
syncWidth =
    Ir.token "width"


{-| The `_blank` value of the `target` enum — same open row as `blank_`, prefixed for discovery.
-}
targetBlank_ : Value { v | blank_ : Supported }
targetBlank_ =
    Ir.token "_blank"


{-| The `_parent` value of the `target` enum — same open row as `parent_`, prefixed for discovery.
-}
targetParent_ : Value { v | parent_ : Supported }
targetParent_ =
    Ir.token "_parent"


{-| The `_self` value of the `target` enum — same open row as `self_`, prefixed for discovery.
-}
targetSelf_ : Value { v | self_ : Supported }
targetSelf_ =
    Ir.token "_self"


{-| The `_top` value of the `target` enum — same open row as `top_`, prefixed for discovery.
-}
targetTop_ : Value { v | top_ : Supported }
targetTop_ =
    Ir.token "_top"


{-| The `long` value of the `timeZoneName` enum — same open row as `long`, prefixed for discovery.
-}
timeZoneNameLong : Value { v | long : Supported }
timeZoneNameLong =
    Ir.token "long"


{-| The `short` value of the `timeZoneName` enum — same open row as `short`, prefixed for discovery.
-}
timeZoneNameShort : Value { v | short : Supported }
timeZoneNameShort =
    Ir.token "short"


{-| The `bottom` value of the `tooltip` enum — same open row as `bottom`, prefixed for discovery.
-}
tooltipBottom : Value { v | bottom : Supported }
tooltipBottom =
    Ir.token "bottom"


{-| The `none` value of the `tooltip` enum — same open row as `none`, prefixed for discovery.
-}
tooltipNone : Value { v | none : Supported }
tooltipNone =
    Ir.token "none"


{-| The `top` value of the `tooltip` enum — same open row as `top`, prefixed for discovery.
-}
tooltipTop : Value { v | top : Supported }
tooltipTop =
    Ir.token "top"


{-| The `bottom` value of the `tooltipPlacement` enum — same open row as `bottom`, prefixed for discovery.
-}
tooltipPlacementBottom : Value { v | bottom : Supported }
tooltipPlacementBottom =
    Ir.token "bottom"


{-| The `left` value of the `tooltipPlacement` enum — same open row as `left`, prefixed for discovery.
-}
tooltipPlacementLeft : Value { v | left : Supported }
tooltipPlacementLeft =
    Ir.token "left"


{-| The `right` value of the `tooltipPlacement` enum — same open row as `right`, prefixed for discovery.
-}
tooltipPlacementRight : Value { v | right : Supported }
tooltipPlacementRight =
    Ir.token "right"


{-| The `top` value of the `tooltipPlacement` enum — same open row as `top`, prefixed for discovery.
-}
tooltipPlacementTop : Value { v | top : Supported }
tooltipPlacementTop =
    Ir.token "top"


{-| The `button` value of the `type_` enum — same open row as `button`, prefixed for discovery.
-}
type_Button : Value { v | button : Supported }
type_Button =
    Ir.token "button"


{-| The `checkbox` value of the `type_` enum — same open row as `checkbox`, prefixed for discovery.
-}
type_Checkbox : Value { v | checkbox : Supported }
type_Checkbox =
    Ir.token "checkbox"


{-| The `currency` value of the `type_` enum — same open row as `currency`, prefixed for discovery.
-}
type_Currency : Value { v | currency : Supported }
type_Currency =
    Ir.token "currency"


{-| The `date` value of the `type_` enum — same open row as `date`, prefixed for discovery.
-}
type_Date : Value { v | date : Supported }
type_Date =
    Ir.token "date"


{-| The `datetime-local` value of the `type_` enum — same open row as `datetimeLocal`, prefixed for discovery.
-}
type_DatetimeLocal : Value { v | datetimeLocal : Supported }
type_DatetimeLocal =
    Ir.token "datetime-local"


{-| The `decimal` value of the `type_` enum — same open row as `decimal`, prefixed for discovery.
-}
type_Decimal : Value { v | decimal : Supported }
type_Decimal =
    Ir.token "decimal"


{-| The `email` value of the `type_` enum — same open row as `email`, prefixed for discovery.
-}
type_Email : Value { v | email : Supported }
type_Email =
    Ir.token "email"


{-| The `normal` value of the `type_` enum — same open row as `normal`, prefixed for discovery.
-}
type_Normal : Value { v | normal : Supported }
type_Normal =
    Ir.token "normal"


{-| The `number` value of the `type_` enum — same open row as `number`, prefixed for discovery.
-}
type_Number : Value { v | number : Supported }
type_Number =
    Ir.token "number"


{-| The `password` value of the `type_` enum — same open row as `password`, prefixed for discovery.
-}
type_Password : Value { v | password : Supported }
type_Password =
    Ir.token "password"


{-| The `percent` value of the `type_` enum — same open row as `percent`, prefixed for discovery.
-}
type_Percent : Value { v | percent : Supported }
type_Percent =
    Ir.token "percent"


{-| The `reset` value of the `type_` enum — same open row as `reset`, prefixed for discovery.
-}
type_Reset : Value { v | reset : Supported }
type_Reset =
    Ir.token "reset"


{-| The `search` value of the `type_` enum — same open row as `search`, prefixed for discovery.
-}
type_Search : Value { v | search : Supported }
type_Search =
    Ir.token "search"


{-| The `submit` value of the `type_` enum — same open row as `submit`, prefixed for discovery.
-}
type_Submit : Value { v | submit : Supported }
type_Submit =
    Ir.token "submit"


{-| The `tel` value of the `type_` enum — same open row as `tel`, prefixed for discovery.
-}
type_Tel : Value { v | tel : Supported }
type_Tel =
    Ir.token "tel"


{-| The `text` value of the `type_` enum — same open row as `text`, prefixed for discovery.
-}
type_Text : Value { v | text : Supported }
type_Text =
    Ir.token "text"


{-| The `time` value of the `type_` enum — same open row as `time`, prefixed for discovery.
-}
type_Time : Value { v | time : Supported }
type_Time =
    Ir.token "time"


{-| The `url` value of the `type_` enum — same open row as `url`, prefixed for discovery.
-}
type_Url : Value { v | url : Supported }
type_Url =
    Ir.token "url"


{-| The `bit` value of the `unit` enum — same open row as `bit`, prefixed for discovery.
-}
unitBit : Value { v | bit : Supported }
unitBit =
    Ir.token "bit"


{-| The `byte` value of the `unit` enum — same open row as `byte`, prefixed for discovery.
-}
unitByte : Value { v | byte : Supported }
unitByte =
    Ir.token "byte"


{-| The `danger` value of the `variant` enum — same open row as `danger`, prefixed for discovery.
-}
variantDanger : Value { v | danger : Supported }
variantDanger =
    Ir.token "danger"


{-| The `default` value of the `variant` enum — same open row as `default`, prefixed for discovery.
-}
variantDefault : Value { v | default : Supported }
variantDefault =
    Ir.token "default"


{-| The `neutral` value of the `variant` enum — same open row as `neutral`, prefixed for discovery.
-}
variantNeutral : Value { v | neutral : Supported }
variantNeutral =
    Ir.token "neutral"


{-| The `primary` value of the `variant` enum — same open row as `primary`, prefixed for discovery.
-}
variantPrimary : Value { v | primary : Supported }
variantPrimary =
    Ir.token "primary"


{-| The `success` value of the `variant` enum — same open row as `success`, prefixed for discovery.
-}
variantSuccess : Value { v | success : Supported }
variantSuccess =
    Ir.token "success"


{-| The `text` value of the `variant` enum — same open row as `text`, prefixed for discovery.
-}
variantText : Value { v | text : Supported }
variantText =
    Ir.token "text"


{-| The `warning` value of the `variant` enum — same open row as `warning`, prefixed for discovery.
-}
variantWarning : Value { v | warning : Supported }
variantWarning =
    Ir.token "warning"


{-| The `long` value of the `weekday` enum — same open row as `long`, prefixed for discovery.
-}
weekdayLong : Value { v | long : Supported }
weekdayLong =
    Ir.token "long"


{-| The `narrow` value of the `weekday` enum — same open row as `narrow`, prefixed for discovery.
-}
weekdayNarrow : Value { v | narrow : Supported }
weekdayNarrow =
    Ir.token "narrow"


{-| The `short` value of the `weekday` enum — same open row as `short`, prefixed for discovery.
-}
weekdayShort : Value { v | short : Supported }
weekdayShort =
    Ir.token "short"


{-| The `2-digit` value of the `year` enum — same open row as `value2Digit`, prefixed for discovery.
-}
yearValue2Digit : Value { v | value2Digit : Supported }
yearValue2Digit =
    Ir.token "2-digit"


{-| The `numeric` value of the `year` enum — same open row as `numeric`, prefixed for discovery.
-}
yearNumeric : Value { v | numeric : Supported }
yearNumeric =
    Ir.token "numeric"
