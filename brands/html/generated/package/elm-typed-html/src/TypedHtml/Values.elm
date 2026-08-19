module TypedHtml.Values exposing
    ( Value
    , toString
    , Autocapitalize, Autocorrect, Blocking, Charset, Closedby, Colorspace, Contenteditable, Crossorigin, Decoding, Dir, Draggable, Enctype, Enterkeyhint, Fetchpriority, Formenctype, Formmethod, Hidden, HttpEquiv, Inputmode, Kind, Loading, Method, Popover, Popovertargetaction, Preload, Referrerpolicy, Sandbox, Scope, Shadowrootmode, Shadowrootslotassignment, Shape, Spellcheck, Translate, Wrap, Writingsuggestions
    , autocapitalizeFromString, autocapitalizeValues, autocorrectFromString, autocorrectValues, blockingFromString, blockingValues, charsetFromString, charsetValues, closedbyFromString, closedbyValues, colorspaceFromString, colorspaceValues, contenteditableFromString, contenteditableValues, crossoriginFromString, crossoriginValues, decodingFromString, decodingValues, dirFromString, dirValues, draggableFromString, draggableValues, enctypeFromString, enctypeValues, enterkeyhintFromString, enterkeyhintValues, fetchpriorityFromString, fetchpriorityValues, formenctypeFromString, formenctypeValues, formmethodFromString, formmethodValues, hiddenFromString, hiddenValues, httpEquivFromString, httpEquivValues, inputmodeFromString, inputmodeValues, kindFromString, kindValues, loadingFromString, loadingValues, methodFromString, methodValues, popoverFromString, popoverValues, popovertargetactionFromString, popovertargetactionValues, preloadFromString, preloadValues, referrerpolicyFromString, referrerpolicyValues, sandboxFromString, sandboxValues, scopeFromString, scopeValues, shadowrootmodeFromString, shadowrootmodeValues, shadowrootslotassignmentFromString, shadowrootslotassignmentValues, shapeFromString, shapeValues, spellcheckFromString, spellcheckValues, translateFromString, translateValues, wrapFromString, wrapValues, writingsuggestionsFromString, writingsuggestionsValues
    , value, allowDownloads, allowForms, allowModals, allowOrientationLock, allowPointerLock, allowPopups, allowPopupsToEscapeSandbox, allowPresentation, allowSameOrigin, allowScripts, allowTopNavigation, allowTopNavigationByUserActivation, allowTopNavigationToCustomProtocols, anonymous, any, applicationXWwwFormUrlencoded, async, auto, captions, chapters, characters, circle, closed, closerequest, col, colgroup, contentSecurityPolicy, contentType, decimal, default, defaultStyle, descriptions, dialog, displayP3, done, eager, email, enter, false, get, go, hard, hidden, hide, high, hint, lazy, limitedSrgb, low, ltr, manual, metadata, multipartFormData, named, next, no, noReferrer, noReferrerWhenDowngrade, none, numeric, off, on, open, origin, originWhenCrossOrigin, plaintextOnly, poly, post, previous, rect, refresh, render, row, rowgroup, rtl, sameOrigin, search, send, sentences, show, soft, strictOrigin, strictOriginWhenCrossOrigin, subtitles, sync, tel, text, textPlain, toggle, true, unsafeUrl, untilFound, url, useCredentials, utf8, words, xUaCompatible, yes
    , autocapitalizeCharacters, autocapitalizeNone, autocapitalizeOff, autocapitalizeSentences, autocapitalizeWords, autocorrectOff, autocorrectOn, blockingRender, charsetUtf8, closedbyAny, closedbyCloserequest, closedbyNone, colorspaceDisplayP3, colorspaceLimitedSrgb, contenteditableFalse, contenteditablePlaintextOnly, contenteditableTrue, crossoriginValue, crossoriginAnonymous, crossoriginUseCredentials, decodingAsync, decodingAuto, decodingSync, dirAuto, dirLtr, dirRtl, draggableFalse, draggableTrue, enctypeApplicationXWwwFormUrlencoded, enctypeMultipartFormData, enctypeTextPlain, enterkeyhintDone, enterkeyhintEnter, enterkeyhintGo, enterkeyhintNext, enterkeyhintPrevious, enterkeyhintSearch, enterkeyhintSend, fetchpriorityAuto, fetchpriorityHigh, fetchpriorityLow, formenctypeApplicationXWwwFormUrlencoded, formenctypeMultipartFormData, formenctypeTextPlain, formmethodDialog, formmethodGet, formmethodPost, hiddenHidden, hiddenUntilFound, httpEquivContentSecurityPolicy, httpEquivContentType, httpEquivDefaultStyle, httpEquivRefresh, httpEquivXUaCompatible, inputmodeDecimal, inputmodeEmail, inputmodeNone, inputmodeNumeric, inputmodeSearch, inputmodeTel, inputmodeText, inputmodeUrl, kindCaptions, kindChapters, kindDescriptions, kindMetadata, kindSubtitles, loadingEager, loadingLazy, methodDialog, methodGet, methodPost, popoverAuto, popoverHint, popoverManual, popovertargetactionHide, popovertargetactionShow, popovertargetactionToggle, preloadValue, preloadAuto, preloadMetadata, preloadNone, referrerpolicyValue, referrerpolicyNoReferrer, referrerpolicyNoReferrerWhenDowngrade, referrerpolicyOrigin, referrerpolicyOriginWhenCrossOrigin, referrerpolicySameOrigin, referrerpolicyStrictOrigin, referrerpolicyStrictOriginWhenCrossOrigin, referrerpolicyUnsafeUrl, sandboxAllowDownloads, sandboxAllowForms, sandboxAllowModals, sandboxAllowOrientationLock, sandboxAllowPointerLock, sandboxAllowPopups, sandboxAllowPopupsToEscapeSandbox, sandboxAllowPresentation, sandboxAllowSameOrigin, sandboxAllowScripts, sandboxAllowTopNavigation, sandboxAllowTopNavigationByUserActivation, sandboxAllowTopNavigationToCustomProtocols, scopeCol, scopeColgroup, scopeRow, scopeRowgroup, shadowrootmodeClosed, shadowrootmodeOpen, shadowrootslotassignmentManual, shadowrootslotassignmentNamed, shapeCircle, shapeDefault, shapePoly, shapeRect, spellcheckFalse, spellcheckTrue, translateNo, translateYes, wrapHard, wrapSoft, writingsuggestionsFalse, writingsuggestionsTrue
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
@docs Autocapitalize, Autocorrect, Blocking, Charset, Closedby, Colorspace, Contenteditable, Crossorigin, Decoding, Dir, Draggable, Enctype, Enterkeyhint, Fetchpriority, Formenctype, Formmethod, Hidden, HttpEquiv, Inputmode, Kind, Loading, Method, Popover, Popovertargetaction, Preload, Referrerpolicy, Sandbox, Scope, Shadowrootmode, Shadowrootslotassignment, Shape, Spellcheck, Translate, Wrap, Writingsuggestions
@docs autocapitalizeFromString, autocapitalizeValues, autocorrectFromString, autocorrectValues, blockingFromString, blockingValues, charsetFromString, charsetValues, closedbyFromString, closedbyValues, colorspaceFromString, colorspaceValues, contenteditableFromString, contenteditableValues, crossoriginFromString, crossoriginValues, decodingFromString, decodingValues, dirFromString, dirValues, draggableFromString, draggableValues, enctypeFromString, enctypeValues, enterkeyhintFromString, enterkeyhintValues, fetchpriorityFromString, fetchpriorityValues, formenctypeFromString, formenctypeValues, formmethodFromString, formmethodValues, hiddenFromString, hiddenValues, httpEquivFromString, httpEquivValues, inputmodeFromString, inputmodeValues, kindFromString, kindValues, loadingFromString, loadingValues, methodFromString, methodValues, popoverFromString, popoverValues, popovertargetactionFromString, popovertargetactionValues, preloadFromString, preloadValues, referrerpolicyFromString, referrerpolicyValues, sandboxFromString, sandboxValues, scopeFromString, scopeValues, shadowrootmodeFromString, shadowrootmodeValues, shadowrootslotassignmentFromString, shadowrootslotassignmentValues, shapeFromString, shapeValues, spellcheckFromString, spellcheckValues, translateFromString, translateValues, wrapFromString, wrapValues, writingsuggestionsFromString, writingsuggestionsValues
@docs value, allowDownloads, allowForms, allowModals, allowOrientationLock, allowPointerLock, allowPopups, allowPopupsToEscapeSandbox, allowPresentation, allowSameOrigin, allowScripts, allowTopNavigation, allowTopNavigationByUserActivation, allowTopNavigationToCustomProtocols, anonymous, any, applicationXWwwFormUrlencoded, async, auto, captions, chapters, characters, circle, closed, closerequest, col, colgroup, contentSecurityPolicy, contentType, decimal, default, defaultStyle, descriptions, dialog, displayP3, done, eager, email, enter, false, get, go, hard, hidden, hide, high, hint, lazy, limitedSrgb, low, ltr, manual, metadata, multipartFormData, named, next, no, noReferrer, noReferrerWhenDowngrade, none, numeric, off, on, open, origin, originWhenCrossOrigin, plaintextOnly, poly, post, previous, rect, refresh, render, row, rowgroup, rtl, sameOrigin, search, send, sentences, show, soft, strictOrigin, strictOriginWhenCrossOrigin, subtitles, sync, tel, text, textPlain, toggle, true, unsafeUrl, untilFound, url, useCredentials, utf8, words, xUaCompatible, yes
@docs autocapitalizeCharacters, autocapitalizeNone, autocapitalizeOff, autocapitalizeSentences, autocapitalizeWords, autocorrectOff, autocorrectOn, blockingRender, charsetUtf8, closedbyAny, closedbyCloserequest, closedbyNone, colorspaceDisplayP3, colorspaceLimitedSrgb, contenteditableFalse, contenteditablePlaintextOnly, contenteditableTrue, crossoriginValue, crossoriginAnonymous, crossoriginUseCredentials, decodingAsync, decodingAuto, decodingSync, dirAuto, dirLtr, dirRtl, draggableFalse, draggableTrue, enctypeApplicationXWwwFormUrlencoded, enctypeMultipartFormData, enctypeTextPlain, enterkeyhintDone, enterkeyhintEnter, enterkeyhintGo, enterkeyhintNext, enterkeyhintPrevious, enterkeyhintSearch, enterkeyhintSend, fetchpriorityAuto, fetchpriorityHigh, fetchpriorityLow, formenctypeApplicationXWwwFormUrlencoded, formenctypeMultipartFormData, formenctypeTextPlain, formmethodDialog, formmethodGet, formmethodPost, hiddenHidden, hiddenUntilFound, httpEquivContentSecurityPolicy, httpEquivContentType, httpEquivDefaultStyle, httpEquivRefresh, httpEquivXUaCompatible, inputmodeDecimal, inputmodeEmail, inputmodeNone, inputmodeNumeric, inputmodeSearch, inputmodeTel, inputmodeText, inputmodeUrl, kindCaptions, kindChapters, kindDescriptions, kindMetadata, kindSubtitles, loadingEager, loadingLazy, methodDialog, methodGet, methodPost, popoverAuto, popoverHint, popoverManual, popovertargetactionHide, popovertargetactionShow, popovertargetactionToggle, preloadValue, preloadAuto, preloadMetadata, preloadNone, referrerpolicyValue, referrerpolicyNoReferrer, referrerpolicyNoReferrerWhenDowngrade, referrerpolicyOrigin, referrerpolicyOriginWhenCrossOrigin, referrerpolicySameOrigin, referrerpolicyStrictOrigin, referrerpolicyStrictOriginWhenCrossOrigin, referrerpolicyUnsafeUrl, sandboxAllowDownloads, sandboxAllowForms, sandboxAllowModals, sandboxAllowOrientationLock, sandboxAllowPointerLock, sandboxAllowPopups, sandboxAllowPopupsToEscapeSandbox, sandboxAllowPresentation, sandboxAllowSameOrigin, sandboxAllowScripts, sandboxAllowTopNavigation, sandboxAllowTopNavigationByUserActivation, sandboxAllowTopNavigationToCustomProtocols, scopeCol, scopeColgroup, scopeRow, scopeRowgroup, shadowrootmodeClosed, shadowrootmodeOpen, shadowrootslotassignmentManual, shadowrootslotassignmentNamed, shapeCircle, shapeDefault, shapePoly, shapeRect, spellcheckFalse, spellcheckTrue, translateNo, translateYes, wrapHard, wrapSoft, writingsuggestionsFalse, writingsuggestionsTrue

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


{-| The union row for `autocapitalize`.
-}
type alias Autocapitalize =
    { characters : Supported
    , none : Supported
    , off : Supported
    , sentences : Supported
    , words : Supported
    }


{-| The union row for `autocorrect`.
-}
type alias Autocorrect =
    { off : Supported
    , on : Supported
    }


{-| The union row for `blocking`.
-}
type alias Blocking =
    { render : Supported
    }


{-| The union row for `charset`.
-}
type alias Charset =
    { utf8 : Supported
    }


{-| The union row for `closedby`.
-}
type alias Closedby =
    { any : Supported
    , closerequest : Supported
    , none : Supported
    }


{-| The union row for `colorspace`.
-}
type alias Colorspace =
    { displayP3 : Supported
    , limitedSrgb : Supported
    }


{-| The union row for `contenteditable`.
-}
type alias Contenteditable =
    { false : Supported
    , plaintextOnly : Supported
    , true : Supported
    }


{-| The union row for `crossorigin`.
-}
type alias Crossorigin =
    { value : Supported
    , anonymous : Supported
    , useCredentials : Supported
    }


{-| The union row for `decoding`.
-}
type alias Decoding =
    { async : Supported
    , auto : Supported
    , sync : Supported
    }


{-| The union row for `dir`.
-}
type alias Dir =
    { auto : Supported
    , ltr : Supported
    , rtl : Supported
    }


{-| The union row for `draggable`.
-}
type alias Draggable =
    { false : Supported
    , true : Supported
    }


{-| The union row for `enctype`.
-}
type alias Enctype =
    { applicationXWwwFormUrlencoded : Supported
    , multipartFormData : Supported
    , textPlain : Supported
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


{-| The union row for `fetchpriority`.
-}
type alias Fetchpriority =
    { auto : Supported
    , high : Supported
    , low : Supported
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
    { dialog : Supported
    , get : Supported
    , post : Supported
    }


{-| The union row for `hidden`.
-}
type alias Hidden =
    { hidden : Supported
    , untilFound : Supported
    }


{-| The union row for `httpEquiv`.
-}
type alias HttpEquiv =
    { contentSecurityPolicy : Supported
    , contentType : Supported
    , defaultStyle : Supported
    , refresh : Supported
    , xUaCompatible : Supported
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


{-| The union row for `kind`.
-}
type alias Kind =
    { captions : Supported
    , chapters : Supported
    , descriptions : Supported
    , metadata : Supported
    , subtitles : Supported
    }


{-| The union row for `loading`.
-}
type alias Loading =
    { eager : Supported
    , lazy : Supported
    }


{-| The union row for `method`.
-}
type alias Method =
    { dialog : Supported
    , get : Supported
    , post : Supported
    }


{-| The union row for `popover`.
-}
type alias Popover =
    { auto : Supported
    , hint : Supported
    , manual : Supported
    }


{-| The union row for `popovertargetaction`.
-}
type alias Popovertargetaction =
    { hide : Supported
    , show : Supported
    , toggle : Supported
    }


{-| The union row for `preload`.
-}
type alias Preload =
    { value : Supported
    , auto : Supported
    , metadata : Supported
    , none : Supported
    }


{-| The union row for `referrerpolicy`.
-}
type alias Referrerpolicy =
    { value : Supported
    , noReferrer : Supported
    , noReferrerWhenDowngrade : Supported
    , origin : Supported
    , originWhenCrossOrigin : Supported
    , sameOrigin : Supported
    , strictOrigin : Supported
    , strictOriginWhenCrossOrigin : Supported
    , unsafeUrl : Supported
    }


{-| The union row for `sandbox`.
-}
type alias Sandbox =
    { allowDownloads : Supported
    , allowForms : Supported
    , allowModals : Supported
    , allowOrientationLock : Supported
    , allowPointerLock : Supported
    , allowPopups : Supported
    , allowPopupsToEscapeSandbox : Supported
    , allowPresentation : Supported
    , allowSameOrigin : Supported
    , allowScripts : Supported
    , allowTopNavigation : Supported
    , allowTopNavigationByUserActivation : Supported
    , allowTopNavigationToCustomProtocols : Supported
    }


{-| The union row for `scope`.
-}
type alias Scope =
    { col : Supported
    , colgroup : Supported
    , row : Supported
    , rowgroup : Supported
    }


{-| The union row for `shadowrootmode`.
-}
type alias Shadowrootmode =
    { closed : Supported
    , open : Supported
    }


{-| The union row for `shadowrootslotassignment`.
-}
type alias Shadowrootslotassignment =
    { manual : Supported
    , named : Supported
    }


{-| The union row for `shape`.
-}
type alias Shape =
    { circle : Supported
    , default : Supported
    , poly : Supported
    , rect : Supported
    }


{-| The union row for `spellcheck`.
-}
type alias Spellcheck =
    { false : Supported
    , true : Supported
    }


{-| The union row for `translate`.
-}
type alias Translate =
    { no : Supported
    , yes : Supported
    }


{-| The union row for `wrap`.
-}
type alias Wrap =
    { hard : Supported
    , soft : Supported
    }


{-| The union row for `writingsuggestions`.
-}
type alias Writingsuggestions =
    { false : Supported
    , true : Supported
    }


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


{-| Parse a `blocking` value from the string it writes to the DOM. The inverse of `toString`.
-}
blockingFromString : String -> Maybe (Value Blocking)
blockingFromString s =
    case s of
        "render" ->
            Just render

        _ ->
            Nothing


{-| Parse a `charset` value from the string it writes to the DOM. The inverse of `toString`.
-}
charsetFromString : String -> Maybe (Value Charset)
charsetFromString s =
    case s of
        "utf-8" ->
            Just utf8

        _ ->
            Nothing


{-| Parse a `closedby` value from the string it writes to the DOM. The inverse of `toString`.
-}
closedbyFromString : String -> Maybe (Value Closedby)
closedbyFromString s =
    case s of
        "any" ->
            Just any

        "closerequest" ->
            Just closerequest

        "none" ->
            Just none

        _ ->
            Nothing


{-| Parse a `colorspace` value from the string it writes to the DOM. The inverse of `toString`.
-}
colorspaceFromString : String -> Maybe (Value Colorspace)
colorspaceFromString s =
    case s of
        "display-p3" ->
            Just displayP3

        "limited-srgb" ->
            Just limitedSrgb

        _ ->
            Nothing


{-| Parse a `contenteditable` value from the string it writes to the DOM. The inverse of `toString`.
-}
contenteditableFromString : String -> Maybe (Value Contenteditable)
contenteditableFromString s =
    case s of
        "false" ->
            Just false

        "plaintext-only" ->
            Just plaintextOnly

        "true" ->
            Just true

        _ ->
            Nothing


{-| Parse a `crossorigin` value from the string it writes to the DOM. The inverse of `toString`.
-}
crossoriginFromString : String -> Maybe (Value Crossorigin)
crossoriginFromString s =
    case s of
        "" ->
            Just value

        "anonymous" ->
            Just anonymous

        "use-credentials" ->
            Just useCredentials

        _ ->
            Nothing


{-| Parse a `decoding` value from the string it writes to the DOM. The inverse of `toString`.
-}
decodingFromString : String -> Maybe (Value Decoding)
decodingFromString s =
    case s of
        "async" ->
            Just async

        "auto" ->
            Just auto

        "sync" ->
            Just sync

        _ ->
            Nothing


{-| Parse a `dir` value from the string it writes to the DOM. The inverse of `toString`.
-}
dirFromString : String -> Maybe (Value Dir)
dirFromString s =
    case s of
        "auto" ->
            Just auto

        "ltr" ->
            Just ltr

        "rtl" ->
            Just rtl

        _ ->
            Nothing


{-| Parse a `draggable` value from the string it writes to the DOM. The inverse of `toString`.
-}
draggableFromString : String -> Maybe (Value Draggable)
draggableFromString s =
    case s of
        "false" ->
            Just false

        "true" ->
            Just true

        _ ->
            Nothing


{-| Parse a `enctype` value from the string it writes to the DOM. The inverse of `toString`.
-}
enctypeFromString : String -> Maybe (Value Enctype)
enctypeFromString s =
    case s of
        "application/x-www-form-urlencoded" ->
            Just applicationXWwwFormUrlencoded

        "multipart/form-data" ->
            Just multipartFormData

        "text/plain" ->
            Just textPlain

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


{-| Parse a `fetchpriority` value from the string it writes to the DOM. The inverse of `toString`.
-}
fetchpriorityFromString : String -> Maybe (Value Fetchpriority)
fetchpriorityFromString s =
    case s of
        "auto" ->
            Just auto

        "high" ->
            Just high

        "low" ->
            Just low

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
        "dialog" ->
            Just dialog

        "get" ->
            Just get

        "post" ->
            Just post

        _ ->
            Nothing


{-| Parse a `hidden` value from the string it writes to the DOM. The inverse of `toString`.
-}
hiddenFromString : String -> Maybe (Value Hidden)
hiddenFromString s =
    case s of
        "hidden" ->
            Just hidden

        "until-found" ->
            Just untilFound

        _ ->
            Nothing


{-| Parse a `httpEquiv` value from the string it writes to the DOM. The inverse of `toString`.
-}
httpEquivFromString : String -> Maybe (Value HttpEquiv)
httpEquivFromString s =
    case s of
        "content-security-policy" ->
            Just contentSecurityPolicy

        "content-type" ->
            Just contentType

        "default-style" ->
            Just defaultStyle

        "refresh" ->
            Just refresh

        "x-ua-compatible" ->
            Just xUaCompatible

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


{-| Parse a `kind` value from the string it writes to the DOM. The inverse of `toString`.
-}
kindFromString : String -> Maybe (Value Kind)
kindFromString s =
    case s of
        "captions" ->
            Just captions

        "chapters" ->
            Just chapters

        "descriptions" ->
            Just descriptions

        "metadata" ->
            Just metadata

        "subtitles" ->
            Just subtitles

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


{-| Parse a `method` value from the string it writes to the DOM. The inverse of `toString`.
-}
methodFromString : String -> Maybe (Value Method)
methodFromString s =
    case s of
        "dialog" ->
            Just dialog

        "get" ->
            Just get

        "post" ->
            Just post

        _ ->
            Nothing


{-| Parse a `popover` value from the string it writes to the DOM. The inverse of `toString`.
-}
popoverFromString : String -> Maybe (Value Popover)
popoverFromString s =
    case s of
        "auto" ->
            Just auto

        "hint" ->
            Just hint

        "manual" ->
            Just manual

        _ ->
            Nothing


{-| Parse a `popovertargetaction` value from the string it writes to the DOM. The inverse of `toString`.
-}
popovertargetactionFromString : String -> Maybe (Value Popovertargetaction)
popovertargetactionFromString s =
    case s of
        "hide" ->
            Just hide

        "show" ->
            Just show

        "toggle" ->
            Just toggle

        _ ->
            Nothing


{-| Parse a `preload` value from the string it writes to the DOM. The inverse of `toString`.
-}
preloadFromString : String -> Maybe (Value Preload)
preloadFromString s =
    case s of
        "" ->
            Just value

        "auto" ->
            Just auto

        "metadata" ->
            Just metadata

        "none" ->
            Just none

        _ ->
            Nothing


{-| Parse a `referrerpolicy` value from the string it writes to the DOM. The inverse of `toString`.
-}
referrerpolicyFromString : String -> Maybe (Value Referrerpolicy)
referrerpolicyFromString s =
    case s of
        "" ->
            Just value

        "no-referrer" ->
            Just noReferrer

        "no-referrer-when-downgrade" ->
            Just noReferrerWhenDowngrade

        "origin" ->
            Just origin

        "origin-when-cross-origin" ->
            Just originWhenCrossOrigin

        "same-origin" ->
            Just sameOrigin

        "strict-origin" ->
            Just strictOrigin

        "strict-origin-when-cross-origin" ->
            Just strictOriginWhenCrossOrigin

        "unsafe-url" ->
            Just unsafeUrl

        _ ->
            Nothing


{-| Parse a `sandbox` value from the string it writes to the DOM. The inverse of `toString`.
-}
sandboxFromString : String -> Maybe (Value Sandbox)
sandboxFromString s =
    case s of
        "allow-downloads" ->
            Just allowDownloads

        "allow-forms" ->
            Just allowForms

        "allow-modals" ->
            Just allowModals

        "allow-orientation-lock" ->
            Just allowOrientationLock

        "allow-pointer-lock" ->
            Just allowPointerLock

        "allow-popups" ->
            Just allowPopups

        "allow-popups-to-escape-sandbox" ->
            Just allowPopupsToEscapeSandbox

        "allow-presentation" ->
            Just allowPresentation

        "allow-same-origin" ->
            Just allowSameOrigin

        "allow-scripts" ->
            Just allowScripts

        "allow-top-navigation" ->
            Just allowTopNavigation

        "allow-top-navigation-by-user-activation" ->
            Just allowTopNavigationByUserActivation

        "allow-top-navigation-to-custom-protocols" ->
            Just allowTopNavigationToCustomProtocols

        _ ->
            Nothing


{-| Parse a `scope` value from the string it writes to the DOM. The inverse of `toString`.
-}
scopeFromString : String -> Maybe (Value Scope)
scopeFromString s =
    case s of
        "col" ->
            Just col

        "colgroup" ->
            Just colgroup

        "row" ->
            Just row

        "rowgroup" ->
            Just rowgroup

        _ ->
            Nothing


{-| Parse a `shadowrootmode` value from the string it writes to the DOM. The inverse of `toString`.
-}
shadowrootmodeFromString : String -> Maybe (Value Shadowrootmode)
shadowrootmodeFromString s =
    case s of
        "closed" ->
            Just closed

        "open" ->
            Just open

        _ ->
            Nothing


{-| Parse a `shadowrootslotassignment` value from the string it writes to the DOM. The inverse of `toString`.
-}
shadowrootslotassignmentFromString : String -> Maybe (Value Shadowrootslotassignment)
shadowrootslotassignmentFromString s =
    case s of
        "manual" ->
            Just manual

        "named" ->
            Just named

        _ ->
            Nothing


{-| Parse a `shape` value from the string it writes to the DOM. The inverse of `toString`.
-}
shapeFromString : String -> Maybe (Value Shape)
shapeFromString s =
    case s of
        "circle" ->
            Just circle

        "default" ->
            Just default

        "poly" ->
            Just poly

        "rect" ->
            Just rect

        _ ->
            Nothing


{-| Parse a `spellcheck` value from the string it writes to the DOM. The inverse of `toString`.
-}
spellcheckFromString : String -> Maybe (Value Spellcheck)
spellcheckFromString s =
    case s of
        "false" ->
            Just false

        "true" ->
            Just true

        _ ->
            Nothing


{-| Parse a `translate` value from the string it writes to the DOM. The inverse of `toString`.
-}
translateFromString : String -> Maybe (Value Translate)
translateFromString s =
    case s of
        "no" ->
            Just no

        "yes" ->
            Just yes

        _ ->
            Nothing


{-| Parse a `wrap` value from the string it writes to the DOM. The inverse of `toString`.
-}
wrapFromString : String -> Maybe (Value Wrap)
wrapFromString s =
    case s of
        "hard" ->
            Just hard

        "soft" ->
            Just soft

        _ ->
            Nothing


{-| Parse a `writingsuggestions` value from the string it writes to the DOM. The inverse of `toString`.
-}
writingsuggestionsFromString : String -> Maybe (Value Writingsuggestions)
writingsuggestionsFromString s =
    case s of
        "false" ->
            Just false

        "true" ->
            Just true

        _ ->
            Nothing


{-| Every `autocapitalize` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
autocapitalizeValues : List (Value Autocapitalize)
autocapitalizeValues =
    [ characters, none, off, sentences, words ]


{-| Every `autocorrect` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
autocorrectValues : List (Value Autocorrect)
autocorrectValues =
    [ off, on ]


{-| Every `blocking` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
blockingValues : List (Value Blocking)
blockingValues =
    [ render ]


{-| Every `charset` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
charsetValues : List (Value Charset)
charsetValues =
    [ utf8 ]


{-| Every `closedby` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
closedbyValues : List (Value Closedby)
closedbyValues =
    [ any, closerequest, none ]


{-| Every `colorspace` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
colorspaceValues : List (Value Colorspace)
colorspaceValues =
    [ displayP3, limitedSrgb ]


{-| Every `contenteditable` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
contenteditableValues : List (Value Contenteditable)
contenteditableValues =
    [ false, plaintextOnly, true ]


{-| Every `crossorigin` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
crossoriginValues : List (Value Crossorigin)
crossoriginValues =
    [ value, anonymous, useCredentials ]


{-| Every `decoding` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
decodingValues : List (Value Decoding)
decodingValues =
    [ async, auto, sync ]


{-| Every `dir` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
dirValues : List (Value Dir)
dirValues =
    [ auto, ltr, rtl ]


{-| Every `draggable` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
draggableValues : List (Value Draggable)
draggableValues =
    [ false, true ]


{-| Every `enctype` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
enctypeValues : List (Value Enctype)
enctypeValues =
    [ applicationXWwwFormUrlencoded, multipartFormData, textPlain ]


{-| Every `enterkeyhint` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
enterkeyhintValues : List (Value Enterkeyhint)
enterkeyhintValues =
    [ done, enter, go, next, previous, search, send ]


{-| Every `fetchpriority` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
fetchpriorityValues : List (Value Fetchpriority)
fetchpriorityValues =
    [ auto, high, low ]


{-| Every `formenctype` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
formenctypeValues : List (Value Formenctype)
formenctypeValues =
    [ applicationXWwwFormUrlencoded, multipartFormData, textPlain ]


{-| Every `formmethod` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
formmethodValues : List (Value Formmethod)
formmethodValues =
    [ dialog, get, post ]


{-| Every `hidden` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
hiddenValues : List (Value Hidden)
hiddenValues =
    [ hidden, untilFound ]


{-| Every `httpEquiv` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
httpEquivValues : List (Value HttpEquiv)
httpEquivValues =
    [ contentSecurityPolicy, contentType, defaultStyle, refresh, xUaCompatible ]


{-| Every `inputmode` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
inputmodeValues : List (Value Inputmode)
inputmodeValues =
    [ decimal, email, none, numeric, search, tel, text, url ]


{-| Every `kind` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
kindValues : List (Value Kind)
kindValues =
    [ captions, chapters, descriptions, metadata, subtitles ]


{-| Every `loading` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
loadingValues : List (Value Loading)
loadingValues =
    [ eager, lazy ]


{-| Every `method` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
methodValues : List (Value Method)
methodValues =
    [ dialog, get, post ]


{-| Every `popover` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
popoverValues : List (Value Popover)
popoverValues =
    [ auto, hint, manual ]


{-| Every `popovertargetaction` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
popovertargetactionValues : List (Value Popovertargetaction)
popovertargetactionValues =
    [ hide, show, toggle ]


{-| Every `preload` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
preloadValues : List (Value Preload)
preloadValues =
    [ value, auto, metadata, none ]


{-| Every `referrerpolicy` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
referrerpolicyValues : List (Value Referrerpolicy)
referrerpolicyValues =
    [ value, noReferrer, noReferrerWhenDowngrade, origin, originWhenCrossOrigin, sameOrigin, strictOrigin, strictOriginWhenCrossOrigin, unsafeUrl ]


{-| Every `sandbox` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
sandboxValues : List (Value Sandbox)
sandboxValues =
    [ allowDownloads, allowForms, allowModals, allowOrientationLock, allowPointerLock, allowPopups, allowPopupsToEscapeSandbox, allowPresentation, allowSameOrigin, allowScripts, allowTopNavigation, allowTopNavigationByUserActivation, allowTopNavigationToCustomProtocols ]


{-| Every `scope` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
scopeValues : List (Value Scope)
scopeValues =
    [ col, colgroup, row, rowgroup ]


{-| Every `shadowrootmode` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
shadowrootmodeValues : List (Value Shadowrootmode)
shadowrootmodeValues =
    [ closed, open ]


{-| Every `shadowrootslotassignment` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
shadowrootslotassignmentValues : List (Value Shadowrootslotassignment)
shadowrootslotassignmentValues =
    [ manual, named ]


{-| Every `shape` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
shapeValues : List (Value Shape)
shapeValues =
    [ circle, default, poly, rect ]


{-| Every `spellcheck` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
spellcheckValues : List (Value Spellcheck)
spellcheckValues =
    [ false, true ]


{-| Every `translate` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
translateValues : List (Value Translate)
translateValues =
    [ no, yes ]


{-| Every `wrap` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
wrapValues : List (Value Wrap)
wrapValues =
    [ hard, soft ]


{-| Every `writingsuggestions` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
writingsuggestionsValues : List (Value Writingsuggestions)
writingsuggestionsValues =
    [ false, true ]


{-| The \`\` token.
-}
value : Value { v | value : Supported }
value =
    Ir.token ""


{-| The `allow-downloads` token.
-}
allowDownloads : Value { v | allowDownloads : Supported }
allowDownloads =
    Ir.token "allow-downloads"


{-| The `allow-forms` token.
-}
allowForms : Value { v | allowForms : Supported }
allowForms =
    Ir.token "allow-forms"


{-| The `allow-modals` token.
-}
allowModals : Value { v | allowModals : Supported }
allowModals =
    Ir.token "allow-modals"


{-| The `allow-orientation-lock` token.
-}
allowOrientationLock : Value { v | allowOrientationLock : Supported }
allowOrientationLock =
    Ir.token "allow-orientation-lock"


{-| The `allow-pointer-lock` token.
-}
allowPointerLock : Value { v | allowPointerLock : Supported }
allowPointerLock =
    Ir.token "allow-pointer-lock"


{-| The `allow-popups` token.
-}
allowPopups : Value { v | allowPopups : Supported }
allowPopups =
    Ir.token "allow-popups"


{-| The `allow-popups-to-escape-sandbox` token.
-}
allowPopupsToEscapeSandbox : Value { v | allowPopupsToEscapeSandbox : Supported }
allowPopupsToEscapeSandbox =
    Ir.token "allow-popups-to-escape-sandbox"


{-| The `allow-presentation` token.
-}
allowPresentation : Value { v | allowPresentation : Supported }
allowPresentation =
    Ir.token "allow-presentation"


{-| The `allow-same-origin` token.
-}
allowSameOrigin : Value { v | allowSameOrigin : Supported }
allowSameOrigin =
    Ir.token "allow-same-origin"


{-| The `allow-scripts` token.
-}
allowScripts : Value { v | allowScripts : Supported }
allowScripts =
    Ir.token "allow-scripts"


{-| The `allow-top-navigation` token.
-}
allowTopNavigation : Value { v | allowTopNavigation : Supported }
allowTopNavigation =
    Ir.token "allow-top-navigation"


{-| The `allow-top-navigation-by-user-activation` token.
-}
allowTopNavigationByUserActivation : Value { v | allowTopNavigationByUserActivation : Supported }
allowTopNavigationByUserActivation =
    Ir.token "allow-top-navigation-by-user-activation"


{-| The `allow-top-navigation-to-custom-protocols` token.
-}
allowTopNavigationToCustomProtocols : Value { v | allowTopNavigationToCustomProtocols : Supported }
allowTopNavigationToCustomProtocols =
    Ir.token "allow-top-navigation-to-custom-protocols"


{-| The `anonymous` token.
-}
anonymous : Value { v | anonymous : Supported }
anonymous =
    Ir.token "anonymous"


{-| The `any` token.
-}
any : Value { v | any : Supported }
any =
    Ir.token "any"


{-| The `application/x-www-form-urlencoded` token.
-}
applicationXWwwFormUrlencoded : Value { v | applicationXWwwFormUrlencoded : Supported }
applicationXWwwFormUrlencoded =
    Ir.token "application/x-www-form-urlencoded"


{-| The `async` token.
-}
async : Value { v | async : Supported }
async =
    Ir.token "async"


{-| The `auto` token.
-}
auto : Value { v | auto : Supported }
auto =
    Ir.token "auto"


{-| The `captions` token.
-}
captions : Value { v | captions : Supported }
captions =
    Ir.token "captions"


{-| The `chapters` token.
-}
chapters : Value { v | chapters : Supported }
chapters =
    Ir.token "chapters"


{-| The `characters` token.
-}
characters : Value { v | characters : Supported }
characters =
    Ir.token "characters"


{-| The `circle` token.
-}
circle : Value { v | circle : Supported }
circle =
    Ir.token "circle"


{-| The `closed` token.
-}
closed : Value { v | closed : Supported }
closed =
    Ir.token "closed"


{-| The `closerequest` token.
-}
closerequest : Value { v | closerequest : Supported }
closerequest =
    Ir.token "closerequest"


{-| The `col` token.
-}
col : Value { v | col : Supported }
col =
    Ir.token "col"


{-| The `colgroup` token.
-}
colgroup : Value { v | colgroup : Supported }
colgroup =
    Ir.token "colgroup"


{-| The `content-security-policy` token.
-}
contentSecurityPolicy : Value { v | contentSecurityPolicy : Supported }
contentSecurityPolicy =
    Ir.token "content-security-policy"


{-| The `content-type` token.
-}
contentType : Value { v | contentType : Supported }
contentType =
    Ir.token "content-type"


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


{-| The `default-style` token.
-}
defaultStyle : Value { v | defaultStyle : Supported }
defaultStyle =
    Ir.token "default-style"


{-| The `descriptions` token.
-}
descriptions : Value { v | descriptions : Supported }
descriptions =
    Ir.token "descriptions"


{-| The `dialog` token.
-}
dialog : Value { v | dialog : Supported }
dialog =
    Ir.token "dialog"


{-| The `display-p3` token.
-}
displayP3 : Value { v | displayP3 : Supported }
displayP3 =
    Ir.token "display-p3"


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


{-| The `enter` token.
-}
enter : Value { v | enter : Supported }
enter =
    Ir.token "enter"


{-| The `false` token.
-}
false : Value { v | false : Supported }
false =
    Ir.token "false"


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


{-| The `hard` token.
-}
hard : Value { v | hard : Supported }
hard =
    Ir.token "hard"


{-| The `hidden` token.
-}
hidden : Value { v | hidden : Supported }
hidden =
    Ir.token "hidden"


{-| The `hide` token.
-}
hide : Value { v | hide : Supported }
hide =
    Ir.token "hide"


{-| The `high` token.
-}
high : Value { v | high : Supported }
high =
    Ir.token "high"


{-| The `hint` token.
-}
hint : Value { v | hint : Supported }
hint =
    Ir.token "hint"


{-| The `lazy` token.
-}
lazy : Value { v | lazy : Supported }
lazy =
    Ir.token "lazy"


{-| The `limited-srgb` token.
-}
limitedSrgb : Value { v | limitedSrgb : Supported }
limitedSrgb =
    Ir.token "limited-srgb"


{-| The `low` token.
-}
low : Value { v | low : Supported }
low =
    Ir.token "low"


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


{-| The `metadata` token.
-}
metadata : Value { v | metadata : Supported }
metadata =
    Ir.token "metadata"


{-| The `multipart/form-data` token.
-}
multipartFormData : Value { v | multipartFormData : Supported }
multipartFormData =
    Ir.token "multipart/form-data"


{-| The `named` token.
-}
named : Value { v | named : Supported }
named =
    Ir.token "named"


{-| The `next` token.
-}
next : Value { v | next : Supported }
next =
    Ir.token "next"


{-| The `no` token.
-}
no : Value { v | no : Supported }
no =
    Ir.token "no"


{-| The `no-referrer` token.
-}
noReferrer : Value { v | noReferrer : Supported }
noReferrer =
    Ir.token "no-referrer"


{-| The `no-referrer-when-downgrade` token.
-}
noReferrerWhenDowngrade : Value { v | noReferrerWhenDowngrade : Supported }
noReferrerWhenDowngrade =
    Ir.token "no-referrer-when-downgrade"


{-| The `none` token.
-}
none : Value { v | none : Supported }
none =
    Ir.token "none"


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


{-| The `open` token.
-}
open : Value { v | open : Supported }
open =
    Ir.token "open"


{-| The `origin` token.
-}
origin : Value { v | origin : Supported }
origin =
    Ir.token "origin"


{-| The `origin-when-cross-origin` token.
-}
originWhenCrossOrigin : Value { v | originWhenCrossOrigin : Supported }
originWhenCrossOrigin =
    Ir.token "origin-when-cross-origin"


{-| The `plaintext-only` token.
-}
plaintextOnly : Value { v | plaintextOnly : Supported }
plaintextOnly =
    Ir.token "plaintext-only"


{-| The `poly` token.
-}
poly : Value { v | poly : Supported }
poly =
    Ir.token "poly"


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


{-| The `rect` token.
-}
rect : Value { v | rect : Supported }
rect =
    Ir.token "rect"


{-| The `refresh` token.
-}
refresh : Value { v | refresh : Supported }
refresh =
    Ir.token "refresh"


{-| The `render` token.
-}
render : Value { v | render : Supported }
render =
    Ir.token "render"


{-| The `row` token.
-}
row : Value { v | row : Supported }
row =
    Ir.token "row"


{-| The `rowgroup` token.
-}
rowgroup : Value { v | rowgroup : Supported }
rowgroup =
    Ir.token "rowgroup"


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


{-| The `show` token.
-}
show : Value { v | show : Supported }
show =
    Ir.token "show"


{-| The `soft` token.
-}
soft : Value { v | soft : Supported }
soft =
    Ir.token "soft"


{-| The `strict-origin` token.
-}
strictOrigin : Value { v | strictOrigin : Supported }
strictOrigin =
    Ir.token "strict-origin"


{-| The `strict-origin-when-cross-origin` token.
-}
strictOriginWhenCrossOrigin : Value { v | strictOriginWhenCrossOrigin : Supported }
strictOriginWhenCrossOrigin =
    Ir.token "strict-origin-when-cross-origin"


{-| The `subtitles` token.
-}
subtitles : Value { v | subtitles : Supported }
subtitles =
    Ir.token "subtitles"


{-| The `sync` token.
-}
sync : Value { v | sync : Supported }
sync =
    Ir.token "sync"


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


{-| The `toggle` token.
-}
toggle : Value { v | toggle : Supported }
toggle =
    Ir.token "toggle"


{-| The `true` token.
-}
true : Value { v | true : Supported }
true =
    Ir.token "true"


{-| The `unsafe-url` token.
-}
unsafeUrl : Value { v | unsafeUrl : Supported }
unsafeUrl =
    Ir.token "unsafe-url"


{-| The `until-found` token.
-}
untilFound : Value { v | untilFound : Supported }
untilFound =
    Ir.token "until-found"


{-| The `url` token.
-}
url : Value { v | url : Supported }
url =
    Ir.token "url"


{-| The `use-credentials` token.
-}
useCredentials : Value { v | useCredentials : Supported }
useCredentials =
    Ir.token "use-credentials"


{-| The `utf-8` token.
-}
utf8 : Value { v | utf8 : Supported }
utf8 =
    Ir.token "utf-8"


{-| The `words` token.
-}
words : Value { v | words : Supported }
words =
    Ir.token "words"


{-| The `x-ua-compatible` token.
-}
xUaCompatible : Value { v | xUaCompatible : Supported }
xUaCompatible =
    Ir.token "x-ua-compatible"


{-| The `yes` token.
-}
yes : Value { v | yes : Supported }
yes =
    Ir.token "yes"


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


{-| The `render` value of the `blocking` enum — same open row as `render`, prefixed for discovery.
-}
blockingRender : Value { v | render : Supported }
blockingRender =
    Ir.token "render"


{-| The `utf-8` value of the `charset` enum — same open row as `utf8`, prefixed for discovery.
-}
charsetUtf8 : Value { v | utf8 : Supported }
charsetUtf8 =
    Ir.token "utf-8"


{-| The `any` value of the `closedby` enum — same open row as `any`, prefixed for discovery.
-}
closedbyAny : Value { v | any : Supported }
closedbyAny =
    Ir.token "any"


{-| The `closerequest` value of the `closedby` enum — same open row as `closerequest`, prefixed for discovery.
-}
closedbyCloserequest : Value { v | closerequest : Supported }
closedbyCloserequest =
    Ir.token "closerequest"


{-| The `none` value of the `closedby` enum — same open row as `none`, prefixed for discovery.
-}
closedbyNone : Value { v | none : Supported }
closedbyNone =
    Ir.token "none"


{-| The `display-p3` value of the `colorspace` enum — same open row as `displayP3`, prefixed for discovery.
-}
colorspaceDisplayP3 : Value { v | displayP3 : Supported }
colorspaceDisplayP3 =
    Ir.token "display-p3"


{-| The `limited-srgb` value of the `colorspace` enum — same open row as `limitedSrgb`, prefixed for discovery.
-}
colorspaceLimitedSrgb : Value { v | limitedSrgb : Supported }
colorspaceLimitedSrgb =
    Ir.token "limited-srgb"


{-| The `false` value of the `contenteditable` enum — same open row as `false`, prefixed for discovery.
-}
contenteditableFalse : Value { v | false : Supported }
contenteditableFalse =
    Ir.token "false"


{-| The `plaintext-only` value of the `contenteditable` enum — same open row as `plaintextOnly`, prefixed for discovery.
-}
contenteditablePlaintextOnly : Value { v | plaintextOnly : Supported }
contenteditablePlaintextOnly =
    Ir.token "plaintext-only"


{-| The `true` value of the `contenteditable` enum — same open row as `true`, prefixed for discovery.
-}
contenteditableTrue : Value { v | true : Supported }
contenteditableTrue =
    Ir.token "true"


{-| The \``value of the`crossorigin`enum — same open row as`value\`, prefixed for discovery.
-}
crossoriginValue : Value { v | value : Supported }
crossoriginValue =
    Ir.token ""


{-| The `anonymous` value of the `crossorigin` enum — same open row as `anonymous`, prefixed for discovery.
-}
crossoriginAnonymous : Value { v | anonymous : Supported }
crossoriginAnonymous =
    Ir.token "anonymous"


{-| The `use-credentials` value of the `crossorigin` enum — same open row as `useCredentials`, prefixed for discovery.
-}
crossoriginUseCredentials : Value { v | useCredentials : Supported }
crossoriginUseCredentials =
    Ir.token "use-credentials"


{-| The `async` value of the `decoding` enum — same open row as `async`, prefixed for discovery.
-}
decodingAsync : Value { v | async : Supported }
decodingAsync =
    Ir.token "async"


{-| The `auto` value of the `decoding` enum — same open row as `auto`, prefixed for discovery.
-}
decodingAuto : Value { v | auto : Supported }
decodingAuto =
    Ir.token "auto"


{-| The `sync` value of the `decoding` enum — same open row as `sync`, prefixed for discovery.
-}
decodingSync : Value { v | sync : Supported }
decodingSync =
    Ir.token "sync"


{-| The `auto` value of the `dir` enum — same open row as `auto`, prefixed for discovery.
-}
dirAuto : Value { v | auto : Supported }
dirAuto =
    Ir.token "auto"


{-| The `ltr` value of the `dir` enum — same open row as `ltr`, prefixed for discovery.
-}
dirLtr : Value { v | ltr : Supported }
dirLtr =
    Ir.token "ltr"


{-| The `rtl` value of the `dir` enum — same open row as `rtl`, prefixed for discovery.
-}
dirRtl : Value { v | rtl : Supported }
dirRtl =
    Ir.token "rtl"


{-| The `false` value of the `draggable` enum — same open row as `false`, prefixed for discovery.
-}
draggableFalse : Value { v | false : Supported }
draggableFalse =
    Ir.token "false"


{-| The `true` value of the `draggable` enum — same open row as `true`, prefixed for discovery.
-}
draggableTrue : Value { v | true : Supported }
draggableTrue =
    Ir.token "true"


{-| The `application/x-www-form-urlencoded` value of the `enctype` enum — same open row as `applicationXWwwFormUrlencoded`, prefixed for discovery.
-}
enctypeApplicationXWwwFormUrlencoded : Value { v | applicationXWwwFormUrlencoded : Supported }
enctypeApplicationXWwwFormUrlencoded =
    Ir.token "application/x-www-form-urlencoded"


{-| The `multipart/form-data` value of the `enctype` enum — same open row as `multipartFormData`, prefixed for discovery.
-}
enctypeMultipartFormData : Value { v | multipartFormData : Supported }
enctypeMultipartFormData =
    Ir.token "multipart/form-data"


{-| The `text/plain` value of the `enctype` enum — same open row as `textPlain`, prefixed for discovery.
-}
enctypeTextPlain : Value { v | textPlain : Supported }
enctypeTextPlain =
    Ir.token "text/plain"


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


{-| The `auto` value of the `fetchpriority` enum — same open row as `auto`, prefixed for discovery.
-}
fetchpriorityAuto : Value { v | auto : Supported }
fetchpriorityAuto =
    Ir.token "auto"


{-| The `high` value of the `fetchpriority` enum — same open row as `high`, prefixed for discovery.
-}
fetchpriorityHigh : Value { v | high : Supported }
fetchpriorityHigh =
    Ir.token "high"


{-| The `low` value of the `fetchpriority` enum — same open row as `low`, prefixed for discovery.
-}
fetchpriorityLow : Value { v | low : Supported }
fetchpriorityLow =
    Ir.token "low"


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


{-| The `dialog` value of the `formmethod` enum — same open row as `dialog`, prefixed for discovery.
-}
formmethodDialog : Value { v | dialog : Supported }
formmethodDialog =
    Ir.token "dialog"


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


{-| The `hidden` value of the `hidden` enum — same open row as `hidden`, prefixed for discovery.
-}
hiddenHidden : Value { v | hidden : Supported }
hiddenHidden =
    Ir.token "hidden"


{-| The `until-found` value of the `hidden` enum — same open row as `untilFound`, prefixed for discovery.
-}
hiddenUntilFound : Value { v | untilFound : Supported }
hiddenUntilFound =
    Ir.token "until-found"


{-| The `content-security-policy` value of the `httpEquiv` enum — same open row as `contentSecurityPolicy`, prefixed for discovery.
-}
httpEquivContentSecurityPolicy : Value { v | contentSecurityPolicy : Supported }
httpEquivContentSecurityPolicy =
    Ir.token "content-security-policy"


{-| The `content-type` value of the `httpEquiv` enum — same open row as `contentType`, prefixed for discovery.
-}
httpEquivContentType : Value { v | contentType : Supported }
httpEquivContentType =
    Ir.token "content-type"


{-| The `default-style` value of the `httpEquiv` enum — same open row as `defaultStyle`, prefixed for discovery.
-}
httpEquivDefaultStyle : Value { v | defaultStyle : Supported }
httpEquivDefaultStyle =
    Ir.token "default-style"


{-| The `refresh` value of the `httpEquiv` enum — same open row as `refresh`, prefixed for discovery.
-}
httpEquivRefresh : Value { v | refresh : Supported }
httpEquivRefresh =
    Ir.token "refresh"


{-| The `x-ua-compatible` value of the `httpEquiv` enum — same open row as `xUaCompatible`, prefixed for discovery.
-}
httpEquivXUaCompatible : Value { v | xUaCompatible : Supported }
httpEquivXUaCompatible =
    Ir.token "x-ua-compatible"


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


{-| The `captions` value of the `kind` enum — same open row as `captions`, prefixed for discovery.
-}
kindCaptions : Value { v | captions : Supported }
kindCaptions =
    Ir.token "captions"


{-| The `chapters` value of the `kind` enum — same open row as `chapters`, prefixed for discovery.
-}
kindChapters : Value { v | chapters : Supported }
kindChapters =
    Ir.token "chapters"


{-| The `descriptions` value of the `kind` enum — same open row as `descriptions`, prefixed for discovery.
-}
kindDescriptions : Value { v | descriptions : Supported }
kindDescriptions =
    Ir.token "descriptions"


{-| The `metadata` value of the `kind` enum — same open row as `metadata`, prefixed for discovery.
-}
kindMetadata : Value { v | metadata : Supported }
kindMetadata =
    Ir.token "metadata"


{-| The `subtitles` value of the `kind` enum — same open row as `subtitles`, prefixed for discovery.
-}
kindSubtitles : Value { v | subtitles : Supported }
kindSubtitles =
    Ir.token "subtitles"


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


{-| The `dialog` value of the `method` enum — same open row as `dialog`, prefixed for discovery.
-}
methodDialog : Value { v | dialog : Supported }
methodDialog =
    Ir.token "dialog"


{-| The `get` value of the `method` enum — same open row as `get`, prefixed for discovery.
-}
methodGet : Value { v | get : Supported }
methodGet =
    Ir.token "get"


{-| The `post` value of the `method` enum — same open row as `post`, prefixed for discovery.
-}
methodPost : Value { v | post : Supported }
methodPost =
    Ir.token "post"


{-| The `auto` value of the `popover` enum — same open row as `auto`, prefixed for discovery.
-}
popoverAuto : Value { v | auto : Supported }
popoverAuto =
    Ir.token "auto"


{-| The `hint` value of the `popover` enum — same open row as `hint`, prefixed for discovery.
-}
popoverHint : Value { v | hint : Supported }
popoverHint =
    Ir.token "hint"


{-| The `manual` value of the `popover` enum — same open row as `manual`, prefixed for discovery.
-}
popoverManual : Value { v | manual : Supported }
popoverManual =
    Ir.token "manual"


{-| The `hide` value of the `popovertargetaction` enum — same open row as `hide`, prefixed for discovery.
-}
popovertargetactionHide : Value { v | hide : Supported }
popovertargetactionHide =
    Ir.token "hide"


{-| The `show` value of the `popovertargetaction` enum — same open row as `show`, prefixed for discovery.
-}
popovertargetactionShow : Value { v | show : Supported }
popovertargetactionShow =
    Ir.token "show"


{-| The `toggle` value of the `popovertargetaction` enum — same open row as `toggle`, prefixed for discovery.
-}
popovertargetactionToggle : Value { v | toggle : Supported }
popovertargetactionToggle =
    Ir.token "toggle"


{-| The \``value of the`preload`enum — same open row as`value\`, prefixed for discovery.
-}
preloadValue : Value { v | value : Supported }
preloadValue =
    Ir.token ""


{-| The `auto` value of the `preload` enum — same open row as `auto`, prefixed for discovery.
-}
preloadAuto : Value { v | auto : Supported }
preloadAuto =
    Ir.token "auto"


{-| The `metadata` value of the `preload` enum — same open row as `metadata`, prefixed for discovery.
-}
preloadMetadata : Value { v | metadata : Supported }
preloadMetadata =
    Ir.token "metadata"


{-| The `none` value of the `preload` enum — same open row as `none`, prefixed for discovery.
-}
preloadNone : Value { v | none : Supported }
preloadNone =
    Ir.token "none"


{-| The \``value of the`referrerpolicy`enum — same open row as`value\`, prefixed for discovery.
-}
referrerpolicyValue : Value { v | value : Supported }
referrerpolicyValue =
    Ir.token ""


{-| The `no-referrer` value of the `referrerpolicy` enum — same open row as `noReferrer`, prefixed for discovery.
-}
referrerpolicyNoReferrer : Value { v | noReferrer : Supported }
referrerpolicyNoReferrer =
    Ir.token "no-referrer"


{-| The `no-referrer-when-downgrade` value of the `referrerpolicy` enum — same open row as `noReferrerWhenDowngrade`, prefixed for discovery.
-}
referrerpolicyNoReferrerWhenDowngrade : Value { v | noReferrerWhenDowngrade : Supported }
referrerpolicyNoReferrerWhenDowngrade =
    Ir.token "no-referrer-when-downgrade"


{-| The `origin` value of the `referrerpolicy` enum — same open row as `origin`, prefixed for discovery.
-}
referrerpolicyOrigin : Value { v | origin : Supported }
referrerpolicyOrigin =
    Ir.token "origin"


{-| The `origin-when-cross-origin` value of the `referrerpolicy` enum — same open row as `originWhenCrossOrigin`, prefixed for discovery.
-}
referrerpolicyOriginWhenCrossOrigin : Value { v | originWhenCrossOrigin : Supported }
referrerpolicyOriginWhenCrossOrigin =
    Ir.token "origin-when-cross-origin"


{-| The `same-origin` value of the `referrerpolicy` enum — same open row as `sameOrigin`, prefixed for discovery.
-}
referrerpolicySameOrigin : Value { v | sameOrigin : Supported }
referrerpolicySameOrigin =
    Ir.token "same-origin"


{-| The `strict-origin` value of the `referrerpolicy` enum — same open row as `strictOrigin`, prefixed for discovery.
-}
referrerpolicyStrictOrigin : Value { v | strictOrigin : Supported }
referrerpolicyStrictOrigin =
    Ir.token "strict-origin"


{-| The `strict-origin-when-cross-origin` value of the `referrerpolicy` enum — same open row as `strictOriginWhenCrossOrigin`, prefixed for discovery.
-}
referrerpolicyStrictOriginWhenCrossOrigin : Value { v | strictOriginWhenCrossOrigin : Supported }
referrerpolicyStrictOriginWhenCrossOrigin =
    Ir.token "strict-origin-when-cross-origin"


{-| The `unsafe-url` value of the `referrerpolicy` enum — same open row as `unsafeUrl`, prefixed for discovery.
-}
referrerpolicyUnsafeUrl : Value { v | unsafeUrl : Supported }
referrerpolicyUnsafeUrl =
    Ir.token "unsafe-url"


{-| The `allow-downloads` value of the `sandbox` enum — same open row as `allowDownloads`, prefixed for discovery.
-}
sandboxAllowDownloads : Value { v | allowDownloads : Supported }
sandboxAllowDownloads =
    Ir.token "allow-downloads"


{-| The `allow-forms` value of the `sandbox` enum — same open row as `allowForms`, prefixed for discovery.
-}
sandboxAllowForms : Value { v | allowForms : Supported }
sandboxAllowForms =
    Ir.token "allow-forms"


{-| The `allow-modals` value of the `sandbox` enum — same open row as `allowModals`, prefixed for discovery.
-}
sandboxAllowModals : Value { v | allowModals : Supported }
sandboxAllowModals =
    Ir.token "allow-modals"


{-| The `allow-orientation-lock` value of the `sandbox` enum — same open row as `allowOrientationLock`, prefixed for discovery.
-}
sandboxAllowOrientationLock : Value { v | allowOrientationLock : Supported }
sandboxAllowOrientationLock =
    Ir.token "allow-orientation-lock"


{-| The `allow-pointer-lock` value of the `sandbox` enum — same open row as `allowPointerLock`, prefixed for discovery.
-}
sandboxAllowPointerLock : Value { v | allowPointerLock : Supported }
sandboxAllowPointerLock =
    Ir.token "allow-pointer-lock"


{-| The `allow-popups` value of the `sandbox` enum — same open row as `allowPopups`, prefixed for discovery.
-}
sandboxAllowPopups : Value { v | allowPopups : Supported }
sandboxAllowPopups =
    Ir.token "allow-popups"


{-| The `allow-popups-to-escape-sandbox` value of the `sandbox` enum — same open row as `allowPopupsToEscapeSandbox`, prefixed for discovery.
-}
sandboxAllowPopupsToEscapeSandbox : Value { v | allowPopupsToEscapeSandbox : Supported }
sandboxAllowPopupsToEscapeSandbox =
    Ir.token "allow-popups-to-escape-sandbox"


{-| The `allow-presentation` value of the `sandbox` enum — same open row as `allowPresentation`, prefixed for discovery.
-}
sandboxAllowPresentation : Value { v | allowPresentation : Supported }
sandboxAllowPresentation =
    Ir.token "allow-presentation"


{-| The `allow-same-origin` value of the `sandbox` enum — same open row as `allowSameOrigin`, prefixed for discovery.
-}
sandboxAllowSameOrigin : Value { v | allowSameOrigin : Supported }
sandboxAllowSameOrigin =
    Ir.token "allow-same-origin"


{-| The `allow-scripts` value of the `sandbox` enum — same open row as `allowScripts`, prefixed for discovery.
-}
sandboxAllowScripts : Value { v | allowScripts : Supported }
sandboxAllowScripts =
    Ir.token "allow-scripts"


{-| The `allow-top-navigation` value of the `sandbox` enum — same open row as `allowTopNavigation`, prefixed for discovery.
-}
sandboxAllowTopNavigation : Value { v | allowTopNavigation : Supported }
sandboxAllowTopNavigation =
    Ir.token "allow-top-navigation"


{-| The `allow-top-navigation-by-user-activation` value of the `sandbox` enum — same open row as `allowTopNavigationByUserActivation`, prefixed for discovery.
-}
sandboxAllowTopNavigationByUserActivation : Value { v | allowTopNavigationByUserActivation : Supported }
sandboxAllowTopNavigationByUserActivation =
    Ir.token "allow-top-navigation-by-user-activation"


{-| The `allow-top-navigation-to-custom-protocols` value of the `sandbox` enum — same open row as `allowTopNavigationToCustomProtocols`, prefixed for discovery.
-}
sandboxAllowTopNavigationToCustomProtocols : Value { v | allowTopNavigationToCustomProtocols : Supported }
sandboxAllowTopNavigationToCustomProtocols =
    Ir.token "allow-top-navigation-to-custom-protocols"


{-| The `col` value of the `scope` enum — same open row as `col`, prefixed for discovery.
-}
scopeCol : Value { v | col : Supported }
scopeCol =
    Ir.token "col"


{-| The `colgroup` value of the `scope` enum — same open row as `colgroup`, prefixed for discovery.
-}
scopeColgroup : Value { v | colgroup : Supported }
scopeColgroup =
    Ir.token "colgroup"


{-| The `row` value of the `scope` enum — same open row as `row`, prefixed for discovery.
-}
scopeRow : Value { v | row : Supported }
scopeRow =
    Ir.token "row"


{-| The `rowgroup` value of the `scope` enum — same open row as `rowgroup`, prefixed for discovery.
-}
scopeRowgroup : Value { v | rowgroup : Supported }
scopeRowgroup =
    Ir.token "rowgroup"


{-| The `closed` value of the `shadowrootmode` enum — same open row as `closed`, prefixed for discovery.
-}
shadowrootmodeClosed : Value { v | closed : Supported }
shadowrootmodeClosed =
    Ir.token "closed"


{-| The `open` value of the `shadowrootmode` enum — same open row as `open`, prefixed for discovery.
-}
shadowrootmodeOpen : Value { v | open : Supported }
shadowrootmodeOpen =
    Ir.token "open"


{-| The `manual` value of the `shadowrootslotassignment` enum — same open row as `manual`, prefixed for discovery.
-}
shadowrootslotassignmentManual : Value { v | manual : Supported }
shadowrootslotassignmentManual =
    Ir.token "manual"


{-| The `named` value of the `shadowrootslotassignment` enum — same open row as `named`, prefixed for discovery.
-}
shadowrootslotassignmentNamed : Value { v | named : Supported }
shadowrootslotassignmentNamed =
    Ir.token "named"


{-| The `circle` value of the `shape` enum — same open row as `circle`, prefixed for discovery.
-}
shapeCircle : Value { v | circle : Supported }
shapeCircle =
    Ir.token "circle"


{-| The `default` value of the `shape` enum — same open row as `default`, prefixed for discovery.
-}
shapeDefault : Value { v | default : Supported }
shapeDefault =
    Ir.token "default"


{-| The `poly` value of the `shape` enum — same open row as `poly`, prefixed for discovery.
-}
shapePoly : Value { v | poly : Supported }
shapePoly =
    Ir.token "poly"


{-| The `rect` value of the `shape` enum — same open row as `rect`, prefixed for discovery.
-}
shapeRect : Value { v | rect : Supported }
shapeRect =
    Ir.token "rect"


{-| The `false` value of the `spellcheck` enum — same open row as `false`, prefixed for discovery.
-}
spellcheckFalse : Value { v | false : Supported }
spellcheckFalse =
    Ir.token "false"


{-| The `true` value of the `spellcheck` enum — same open row as `true`, prefixed for discovery.
-}
spellcheckTrue : Value { v | true : Supported }
spellcheckTrue =
    Ir.token "true"


{-| The `no` value of the `translate` enum — same open row as `no`, prefixed for discovery.
-}
translateNo : Value { v | no : Supported }
translateNo =
    Ir.token "no"


{-| The `yes` value of the `translate` enum — same open row as `yes`, prefixed for discovery.
-}
translateYes : Value { v | yes : Supported }
translateYes =
    Ir.token "yes"


{-| The `hard` value of the `wrap` enum — same open row as `hard`, prefixed for discovery.
-}
wrapHard : Value { v | hard : Supported }
wrapHard =
    Ir.token "hard"


{-| The `soft` value of the `wrap` enum — same open row as `soft`, prefixed for discovery.
-}
wrapSoft : Value { v | soft : Supported }
wrapSoft =
    Ir.token "soft"


{-| The `false` value of the `writingsuggestions` enum — same open row as `false`, prefixed for discovery.
-}
writingsuggestionsFalse : Value { v | false : Supported }
writingsuggestionsFalse =
    Ir.token "false"


{-| The `true` value of the `writingsuggestions` enum — same open row as `true`, prefixed for discovery.
-}
writingsuggestionsTrue : Value { v | true : Supported }
writingsuggestionsTrue =
    Ir.token "true"
