module TypedHtml.Attributes exposing
    ( accesskey, autocapitalize, autocorrect, autofocus, class, contenteditable, draggable, enterkeyhint, id, inert, inputmode, itemid, itemprop, itemref, itemscope, itemtype, nonce, popover, slot, spellcheck, style, translate, writingsuggestions, dir, hidden, lang, tabindex, title, classList, styleList
    , abbr, accept, acceptCharset, action, allow, allowfullscreen, alpha, alt, async, autocomplete, autoplay, checked, cite, color, cols, colspan, commandfor, content, controls, coords, data, datetime, default, defer, dirname, disabled, download, for, form, formnovalidate, formtarget, headers, height, high, href, hreflang, imagesizes, imagesrcset, integrity, ismap, label, list, loop, low, max, maxlength, media, min, minlength, multiple, muted, name, nomodule, novalidate, open, optimum, pattern, ping, placeholder, playsinline, popovertarget, poster, readonly, rel, required, reversed, rows, rowspan, selected, shadowrootclonable, shadowrootcustomelementregistry, shadowrootdelegatesfocus, shadowrootserializable, size, sizes, span, src, srcdoc, srclang, srcset, start, step, target, type_, usemap, value, valueNumeric, valueOrdinal, width
    , defaultChecked, defaultMuted, defaultSelected, defaultValue
    , coordsAsInts, stepAsNumber, valueAsNumber
    , blocking, charset, closedby, colorspace, crossorigin, decoding, enctype, fetchpriority, formenctype, formmethod, httpEquiv, kind, loading, method, popovertargetaction, preload, referrerpolicy, sandbox, scope, shadowrootmode, shadowrootslotassignment, shape, wrap
    , blockingRender, charsetUtf8, closedbyAny, closedbyCloserequest, closedbyNone, colorspaceDisplayP3, colorspaceLimitedSrgb, crossoriginValue, crossoriginAnonymous, crossoriginUseCredentials, decodingAsync, decodingAuto, decodingSync, enctypeApplicationXWwwFormUrlencoded, enctypeMultipartFormData, enctypeTextPlain, fetchpriorityAuto, fetchpriorityHigh, fetchpriorityLow, formenctypeApplicationXWwwFormUrlencoded, formenctypeMultipartFormData, formenctypeTextPlain, formmethodDialog, formmethodGet, formmethodPost, httpEquivContentSecurityPolicy, httpEquivContentType, httpEquivDefaultStyle, httpEquivRefresh, httpEquivXUaCompatible, kindCaptions, kindChapters, kindDescriptions, kindMetadata, kindSubtitles, loadingEager, loadingLazy, methodDialog, methodGet, methodPost, popovertargetactionHide, popovertargetactionShow, popovertargetactionToggle, preloadValue, preloadAuto, preloadMetadata, preloadNone, referrerpolicyValue, referrerpolicyNoReferrer, referrerpolicyNoReferrerWhenDowngrade, referrerpolicyOrigin, referrerpolicyOriginWhenCrossOrigin, referrerpolicySameOrigin, referrerpolicyStrictOrigin, referrerpolicyStrictOriginWhenCrossOrigin, referrerpolicyUnsafeUrl, sandboxAllowDownloads, sandboxAllowForms, sandboxAllowModals, sandboxAllowOrientationLock, sandboxAllowPointerLock, sandboxAllowPopups, sandboxAllowPopupsToEscapeSandbox, sandboxAllowPresentation, sandboxAllowSameOrigin, sandboxAllowScripts, sandboxAllowTopNavigation, sandboxAllowTopNavigationByUserActivation, sandboxAllowTopNavigationToCustomProtocols, scopeCol, scopeColgroup, scopeRow, scopeRowgroup, shadowrootmodeClosed, shadowrootmodeOpen, shadowrootslotassignmentManual, shadowrootslotassignmentNamed, shapeCircle, shapeDefault, shapePoly, shapeRect, wrapHard, wrapSoft
    )

{-| The canonical shared attribute vocabulary. Every setter is an open
producer (`{ c | attr : Supported }`); each element's closed `Attrs` row
decides admittance. Enum setters here close over the library-wide UNION of
values — cross-component misuse is caught by elm-review; reach for the
per-component setters (`TypedHtml.<Component>.<attr>`) for compile-tight narrowing.

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
  - `is` — `is` is inert: a customized built-in element must be opted in at creation time via `document.createElement(tag, { is })`, and `_VirtualDom_render` calls `_VirtualDom_doc.createElement(vNode.__tag)` with no options argument, so the element already exists as its plain built-in self before any fact is applied. There is no `is` IDL attribute either, so the property form is an inert expando.

@docs accesskey, autocapitalize, autocorrect, autofocus, class, contenteditable, draggable, enterkeyhint, id, inert, inputmode, itemid, itemprop, itemref, itemscope, itemtype, nonce, popover, slot, spellcheck, style, translate, writingsuggestions, dir, hidden, lang, tabindex, title, classList, styleList
@docs abbr, accept, acceptCharset, action, allow, allowfullscreen, alpha, alt, async, autocomplete, autoplay, checked, cite, color, cols, colspan, commandfor, content, controls, coords, data, datetime, default, defer, dirname, disabled, download, for, form, formnovalidate, formtarget, headers, height, high, href, hreflang, imagesizes, imagesrcset, integrity, ismap, label, list, loop, low, max, maxlength, media, min, minlength, multiple, muted, name, nomodule, novalidate, open, optimum, pattern, ping, placeholder, playsinline, popovertarget, poster, readonly, rel, required, reversed, rows, rowspan, selected, shadowrootclonable, shadowrootcustomelementregistry, shadowrootdelegatesfocus, shadowrootserializable, size, sizes, span, src, srcdoc, srclang, srcset, start, step, target, type_, usemap, value, valueNumeric, valueOrdinal, width
@docs defaultChecked, defaultMuted, defaultSelected, defaultValue
@docs coordsAsInts, stepAsNumber, valueAsNumber
@docs blocking, charset, closedby, colorspace, crossorigin, decoding, enctype, fetchpriority, formenctype, formmethod, httpEquiv, kind, loading, method, popovertargetaction, preload, referrerpolicy, sandbox, scope, shadowrootmode, shadowrootslotassignment, shape, wrap
@docs blockingRender, charsetUtf8, closedbyAny, closedbyCloserequest, closedbyNone, colorspaceDisplayP3, colorspaceLimitedSrgb, crossoriginValue, crossoriginAnonymous, crossoriginUseCredentials, decodingAsync, decodingAuto, decodingSync, enctypeApplicationXWwwFormUrlencoded, enctypeMultipartFormData, enctypeTextPlain, fetchpriorityAuto, fetchpriorityHigh, fetchpriorityLow, formenctypeApplicationXWwwFormUrlencoded, formenctypeMultipartFormData, formenctypeTextPlain, formmethodDialog, formmethodGet, formmethodPost, httpEquivContentSecurityPolicy, httpEquivContentType, httpEquivDefaultStyle, httpEquivRefresh, httpEquivXUaCompatible, kindCaptions, kindChapters, kindDescriptions, kindMetadata, kindSubtitles, loadingEager, loadingLazy, methodDialog, methodGet, methodPost, popovertargetactionHide, popovertargetactionShow, popovertargetactionToggle, preloadValue, preloadAuto, preloadMetadata, preloadNone, referrerpolicyValue, referrerpolicyNoReferrer, referrerpolicyNoReferrerWhenDowngrade, referrerpolicyOrigin, referrerpolicyOriginWhenCrossOrigin, referrerpolicySameOrigin, referrerpolicyStrictOrigin, referrerpolicyStrictOriginWhenCrossOrigin, referrerpolicyUnsafeUrl, sandboxAllowDownloads, sandboxAllowForms, sandboxAllowModals, sandboxAllowOrientationLock, sandboxAllowPointerLock, sandboxAllowPopups, sandboxAllowPopupsToEscapeSandbox, sandboxAllowPresentation, sandboxAllowSameOrigin, sandboxAllowScripts, sandboxAllowTopNavigation, sandboxAllowTopNavigationByUserActivation, sandboxAllowTopNavigationToCustomProtocols, scopeCol, scopeColgroup, scopeRow, scopeRowgroup, shadowrootmodeClosed, shadowrootmodeOpen, shadowrootslotassignmentManual, shadowrootslotassignmentNamed, shapeCircle, shapeDefault, shapePoly, shapeRect, wrapHard, wrapSoft

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import TypedHtml.Values


{-| The global `accesskey` attribute.
-}
accesskey : String -> Attr { c | accesskey : Supported } msg
accesskey =
    Ir.attribute "accesskey"


{-| The global `autocapitalize` attribute.
-}
autocapitalize : Value TypedHtml.Values.Autocapitalize -> Attr { c | autocapitalize : Supported } msg
autocapitalize value_ =
    Ir.attribute "autocapitalize" (HtmlIr.Value.toString value_)


{-| The global `autocorrect` attribute.
-}
autocorrect : Value TypedHtml.Values.Autocorrect -> Attr { c | autocorrect : Supported } msg
autocorrect value_ =
    Ir.attribute "autocorrect" (HtmlIr.Value.toString value_)


{-| The global `autofocus` attribute.
-}
autofocus : Bool -> Attr { c | autofocus : Supported } msg
autofocus value_ =
    if value_ then
        Ir.attribute "autofocus" ""

    else
        Ir.none


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


{-| The global `contenteditable` attribute.
-}
contenteditable : Value TypedHtml.Values.Contenteditable -> Attr { c | contenteditable : Supported } msg
contenteditable value_ =
    Ir.attribute "contenteditable" (HtmlIr.Value.toString value_)


{-| The global `draggable` attribute.
-}
draggable : Value TypedHtml.Values.Draggable -> Attr { c | draggable : Supported } msg
draggable value_ =
    Ir.attribute "draggable" (HtmlIr.Value.toString value_)


{-| The global `enterkeyhint` attribute.
-}
enterkeyhint : Value TypedHtml.Values.Enterkeyhint -> Attr { c | enterkeyhint : Supported } msg
enterkeyhint value_ =
    Ir.attribute "enterkeyhint" (HtmlIr.Value.toString value_)


{-| The global `id` attribute.
-}
id : String -> Attr { c | id : Supported } msg
id =
    Ir.attribute "id"


{-| The global `inert` attribute.
-}
inert : Bool -> Attr { c | inert : Supported } msg
inert value_ =
    if value_ then
        Ir.attribute "inert" ""

    else
        Ir.none


{-| The global `inputmode` attribute.
-}
inputmode : Value TypedHtml.Values.Inputmode -> Attr { c | inputmode : Supported } msg
inputmode value_ =
    Ir.attribute "inputmode" (HtmlIr.Value.toString value_)


{-| The global `itemid` attribute.
-}
itemid : String -> Attr { c | itemid : Supported } msg
itemid =
    Ir.attribute "itemid"


{-| The global `itemprop` attribute.
-}
itemprop : String -> Attr { c | itemprop : Supported } msg
itemprop =
    Ir.attribute "itemprop"


{-| The global `itemref` attribute.
-}
itemref : String -> Attr { c | itemref : Supported } msg
itemref =
    Ir.attribute "itemref"


{-| The global `itemscope` attribute.
-}
itemscope : Bool -> Attr { c | itemscope : Supported } msg
itemscope value_ =
    if value_ then
        Ir.attribute "itemscope" ""

    else
        Ir.none


{-| The global `itemtype` attribute.
-}
itemtype : String -> Attr { c | itemtype : Supported } msg
itemtype =
    Ir.attribute "itemtype"


{-| The global `nonce` attribute.
-}
nonce : String -> Attr { c | nonce : Supported } msg
nonce =
    Ir.attribute "nonce"


{-| The global `popover` attribute.
-}
popover : Value TypedHtml.Values.Popover -> Attr { c | popover : Supported } msg
popover value_ =
    Ir.attribute "popover" (HtmlIr.Value.toString value_)


{-| The global `slot` attribute (named-slot placement by hand).
-}
slot : String -> Attr { c | slot : Supported } msg
slot =
    Ir.attribute "slot"


{-| The global `spellcheck` attribute.
-}
spellcheck : Value TypedHtml.Values.Spellcheck -> Attr { c | spellcheck : Supported } msg
spellcheck value_ =
    Ir.attribute "spellcheck" (HtmlIr.Value.toString value_)


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


{-| The global `translate` attribute.
-}
translate : Value TypedHtml.Values.Translate -> Attr { c | translate : Supported } msg
translate value_ =
    Ir.attribute "translate" (HtmlIr.Value.toString value_)


{-| The global `writingsuggestions` attribute.
-}
writingsuggestions : Value TypedHtml.Values.Writingsuggestions -> Attr { c | writingsuggestions : Supported } msg
writingsuggestions value_ =
    Ir.attribute "writingsuggestions" (HtmlIr.Value.toString value_)


{-| The global `dir` attribute.
-}
dir : Value TypedHtml.Values.Dir -> Attr c msg
dir value_ =
    Ir.attribute "dir" (HtmlIr.Value.toString value_)


{-| The global `hidden` attribute.
-}
hidden : Value TypedHtml.Values.Hidden -> Attr c msg
hidden value_ =
    Ir.attribute "hidden" (HtmlIr.Value.toString value_)


{-| The global `lang` attribute.
-}
lang : String -> Attr c msg
lang =
    Ir.attribute "lang"


{-| The global `tabindex` attribute.
-}
tabindex : Int -> Attr c msg
tabindex value_ =
    Ir.attribute "tabindex" (String.fromInt value_)


{-| The global `title` attribute.
-}
title : String -> Attr c msg
title =
    Ir.attribute "title"


{-| Alternative label to use for the header cell when referencing the cell in other contexts
-}
abbr : String -> Attr { c | abbr : Supported } msg
abbr =
    Ir.attribute "abbr"


{-| Hint for expected file type in file upload controls
-}
accept : String -> Attr { c | accept : Supported } msg
accept =
    Ir.attribute "accept"


{-| Character encodings to use for form submission
-}
acceptCharset : String -> Attr { c | acceptCharset : Supported } msg
acceptCharset =
    Ir.attribute "accept-charset"


{-| URL to use for form submission
-}
action : String -> Attr { c | action : Supported } msg
action =
    Ir.attribute "action"


{-| Permissions policy to be applied to the iframe's contents
-}
allow : String -> Attr { c | allow : Supported } msg
allow =
    Ir.attribute "allow"


{-| Whether to allow the iframe's contents to use requestFullscreen()
-}
allowfullscreen : Bool -> Attr { c | allowfullscreen : Supported } msg
allowfullscreen value_ =
    if value_ then
        Ir.attribute "allowfullscreen" ""

    else
        Ir.none


{-| Allow the color's alpha component to be set
-}
alpha : Bool -> Attr { c | alpha : Supported } msg
alpha value_ =
    if value_ then
        Ir.attribute "alpha" ""

    else
        Ir.none


{-| Replacement text for use when images are not available
-}
alt : String -> Attr { c | alt : Supported } msg
alt =
    Ir.attribute "alt"


{-| Execute script when available, without blocking while fetching
-}
async : Bool -> Attr { c | async : Supported } msg
async value_ =
    if value_ then
        Ir.attribute "async" ""

    else
        Ir.none


{-| Default setting for autofill feature for controls in the form
-}
autocomplete : String -> Attr { c | autocomplete : Supported } msg
autocomplete =
    Ir.attribute "autocomplete"


{-| Hint that the media resource can be started automatically when the page is loaded
-}
autoplay : Bool -> Attr { c | autoplay : Supported } msg
autoplay value_ =
    if value_ then
        Ir.attribute "autoplay" ""

    else
        Ir.none


{-| Whether the control is checked

Sets the LIVE DOM property `checked`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultChecked`.

-}
checked : Bool -> Attr { c | checked : Supported } msg
checked value_ =
    Ir.property "checked" (Json.Encode.bool value_)


{-| Link to the source of the quotation or more information about the edit
-}
cite : String -> Attr { c | cite : Supported } msg
cite =
    Ir.attribute "cite"


{-| Color to use when customizing a site's icon (for rel="mask-icon")
-}
color : String -> Attr { c | color : Supported } msg
color =
    Ir.attribute "color"


{-| Maximum number of characters per line
-}
cols : Int -> Attr { c | cols : Supported } msg
cols value_ =
    Ir.attribute "cols" (String.fromInt value_)


{-| Number of columns that the cell is to span
-}
colspan : Int -> Attr { c | colspan : Supported } msg
colspan value_ =
    Ir.attribute "colspan" (String.fromInt value_)


{-| Targets another element to be invoked.
-}
commandfor : String -> Attr { c | commandfor : Supported } msg
commandfor =
    Ir.attribute "commandfor"


{-| Value of the element
-}
content : String -> Attr { c | content : Supported } msg
content =
    Ir.attribute "content"


{-| Show user agent controls
-}
controls : Bool -> Attr { c | controls : Supported } msg
controls value_ =
    if value_ then
        Ir.attribute "controls" ""

    else
        Ir.none


{-| Coordinates for the shape to be created in an image map. A COMMA-SEPARATED LIST of integers (`0,0,82,126`), so no single number is ever a valid value; `coordsAsInts` builds one from a `List Int`.
-}
coords : String -> Attr { c | coords : Supported } msg
coords =
    Ir.attribute "coords"


{-| Address of the resource
-}
data : String -> Attr { c | data : Supported } msg
data =
    Ir.attribute "data"


{-| Date and (optionally) time of the change
-}
datetime : String -> Attr { c | datetime : Supported } msg
datetime =
    Ir.attribute "datetime"


{-| Enable the track if no other text track is more suitable
-}
default : Bool -> Attr { c | default : Supported } msg
default value_ =
    if value_ then
        Ir.attribute "default" ""

    else
        Ir.none


{-| Defer script execution
-}
defer : Bool -> Attr { c | defer : Supported } msg
defer value_ =
    if value_ then
        Ir.attribute "defer" ""

    else
        Ir.none


{-| Name of form control to use for sending the element's directionality in form submission
-}
dirname : String -> Attr { c | dirname : Supported } msg
dirname =
    Ir.attribute "dirname"


{-| Whether the form control is disabled
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled value_ =
    if value_ then
        Ir.attribute "disabled" ""

    else
        Ir.none


{-| Whether to download the resource instead of navigating to it, and its filename if so
-}
download : String -> Attr { c | download : Supported } msg
download =
    Ir.attribute "download"


{-| Associate the label with form control
-}
for : String -> Attr { c | for : Supported } msg
for =
    Ir.attribute "for"


{-| Associates the element with a form element
-}
form : String -> Attr { c | form : Supported } msg
form =
    Ir.attribute "form"


{-| Bypass form control validation for form submission
-}
formnovalidate : Bool -> Attr { c | formnovalidate : Supported } msg
formnovalidate value_ =
    if value_ then
        Ir.attribute "formnovalidate" ""

    else
        Ir.none


{-| Navigable for form submission
-}
formtarget : String -> Attr { c | formtarget : Supported } msg
formtarget =
    Ir.attribute "formtarget"


{-| The header cells for this cell
-}
headers : String -> Attr { c | headers : Supported } msg
headers =
    Ir.attribute "headers"


{-| Vertical dimension
-}
height : Int -> Attr { c | height : Supported } msg
height value_ =
    Ir.attribute "height" (String.fromInt value_)


{-| Low limit of high range
-}
high : Float -> Attr { c | high : Supported } msg
high value_ =
    Ir.attribute "high" (String.fromFloat value_)


{-| Address of the hyperlink
-}
href : String -> Attr { c | href : Supported } msg
href =
    Ir.attribute "href"


{-| Language of the linked resource
-}
hreflang : String -> Attr { c | hreflang : Supported } msg
hreflang =
    Ir.attribute "hreflang"


{-| Image sizes for different page layouts (for rel="preload")
-}
imagesizes : String -> Attr { c | imagesizes : Supported } msg
imagesizes =
    Ir.attribute "imagesizes"


{-| Images to use in different situations, e.g., high-resolution displays, small monitors, etc. (for rel="preload")
-}
imagesrcset : String -> Attr { c | imagesrcset : Supported } msg
imagesrcset =
    Ir.attribute "imagesrcset"


{-| Integrity metadata used in Subresource Integrity checks [SRI]
-}
integrity : String -> Attr { c | integrity : Supported } msg
integrity =
    Ir.attribute "integrity"


{-| Whether the image is a server-side image map
-}
ismap : Bool -> Attr { c | ismap : Supported } msg
ismap value_ =
    if value_ then
        Ir.attribute "ismap" ""

    else
        Ir.none


{-| User-visible label
-}
label : String -> Attr { c | label : Supported } msg
label =
    Ir.attribute "label"


{-| List of autocomplete options
-}
list : String -> Attr { c | list : Supported } msg
list =
    Ir.attribute "list"


{-| Whether to loop the media resource
-}
loop : Bool -> Attr { c | loop : Supported } msg
loop value_ =
    if value_ then
        Ir.attribute "loop" ""

    else
        Ir.none


{-| High limit of low range
-}
low : Float -> Attr { c | low : Supported } msg
low value_ =
    Ir.attribute "low" (String.fromFloat value_)


{-| Maximum value
-}
max : String -> Attr { c | max : Supported } msg
max =
    Ir.attribute "max"


{-| Maximum length of value
-}
maxlength : Int -> Attr { c | maxlength : Supported } msg
maxlength value_ =
    Ir.attribute "maxlength" (String.fromInt value_)


{-| Applicable media
-}
media : String -> Attr { c | media : Supported } msg
media =
    Ir.attribute "media"


{-| Minimum value
-}
min : String -> Attr { c | min : Supported } msg
min =
    Ir.attribute "min"


{-| Minimum length of value
-}
minlength : Int -> Attr { c | minlength : Supported } msg
minlength value_ =
    Ir.attribute "minlength" (String.fromInt value_)


{-| Whether to allow multiple values
-}
multiple : Bool -> Attr { c | multiple : Supported } msg
multiple value_ =
    if value_ then
        Ir.attribute "multiple" ""

    else
        Ir.none


{-| Whether to mute the media resource by default

Sets the LIVE DOM property `muted`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultMuted`.

CAVEAT — this setter cannot RESYNC. `elm/virtual-dom` only re-forces an unchanged controlled property for the names `value` and `checked`; `muted` is compared by identity, so re-rendering the same model value after the user has changed it through the element's own UI will NOT push it back to the DOM. Keep the model in sync with a `volumechange` handler.

-}
muted : Bool -> Attr { c | muted : Supported } msg
muted value_ =
    Ir.property "muted" (Json.Encode.bool value_)


{-| Name of the element to use for form submission and in the form.elements API
-}
name : String -> Attr { c | name : Supported } msg
name =
    Ir.attribute "name"


{-| Prevents execution in user agents that support module scripts
-}
nomodule : Bool -> Attr { c | nomodule : Supported } msg
nomodule value_ =
    if value_ then
        Ir.attribute "nomodule" ""

    else
        Ir.none


{-| Bypass form control validation for form submission
-}
novalidate : Bool -> Attr { c | novalidate : Supported } msg
novalidate value_ =
    if value_ then
        Ir.attribute "novalidate" ""

    else
        Ir.none


{-| Whether the details are visible
-}
open : Bool -> Attr { c | open : Supported } msg
open value_ =
    if value_ then
        Ir.attribute "open" ""

    else
        Ir.none


{-| Optimum value in gauge
-}
optimum : Float -> Attr { c | optimum : Supported } msg
optimum value_ =
    Ir.attribute "optimum" (String.fromFloat value_)


{-| Pattern to be matched by the form control's value
-}
pattern : String -> Attr { c | pattern : Supported } msg
pattern =
    Ir.attribute "pattern"


{-| URLs to ping
-}
ping : String -> Attr { c | ping : Supported } msg
ping =
    Ir.attribute "ping"


{-| User-visible label to be placed within the form control
-}
placeholder : String -> Attr { c | placeholder : Supported } msg
placeholder =
    Ir.attribute "placeholder"


{-| Encourage the user agent to display video content within the element's playback area
-}
playsinline : Bool -> Attr { c | playsinline : Supported } msg
playsinline value_ =
    if value_ then
        Ir.attribute "playsinline" ""

    else
        Ir.none


{-| Targets a popover element to toggle, show, or hide
-}
popovertarget : String -> Attr { c | popovertarget : Supported } msg
popovertarget =
    Ir.attribute "popovertarget"


{-| Poster frame to show prior to video playback
-}
poster : String -> Attr { c | poster : Supported } msg
poster =
    Ir.attribute "poster"


{-| Affects willValidate, plus any behavior added by the custom element author
-}
readonly : Bool -> Attr { c | readonly : Supported } msg
readonly value_ =
    if value_ then
        Ir.attribute "readonly" ""

    else
        Ir.none


{-| Relationship between the location in the document containing the hyperlink and the destination resource
-}
rel : String -> Attr { c | rel : Supported } msg
rel =
    Ir.attribute "rel"


{-| Whether the control is required for form submission
-}
required : Bool -> Attr { c | required : Supported } msg
required value_ =
    if value_ then
        Ir.attribute "required" ""

    else
        Ir.none


{-| Number the list backwards
-}
reversed : Bool -> Attr { c | reversed : Supported } msg
reversed value_ =
    if value_ then
        Ir.attribute "reversed" ""

    else
        Ir.none


{-| Number of lines to show
-}
rows : Int -> Attr { c | rows : Supported } msg
rows value_ =
    Ir.attribute "rows" (String.fromInt value_)


{-| Number of rows that the cell is to span
-}
rowspan : Int -> Attr { c | rowspan : Supported } msg
rowspan value_ =
    Ir.attribute "rowspan" (String.fromInt value_)


{-| Whether the option is selected by default

Sets the LIVE DOM property `selected`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultSelected`.

CAVEAT — this setter cannot RESYNC. `elm/virtual-dom` only re-forces an unchanged controlled property for the names `value` and `checked`; `selected` is compared by identity, so re-rendering the same model value after the user has changed it through the element's own UI will NOT push it back to the DOM. Keep the model in sync with a `change` handler.

-}
selected : Bool -> Attr { c | selected : Supported } msg
selected value_ =
    Ir.property "selected" (Json.Encode.bool value_)


{-| Sets clonable on a declarative shadow root
-}
shadowrootclonable : Bool -> Attr { c | shadowrootclonable : Supported } msg
shadowrootclonable value_ =
    if value_ then
        Ir.attribute "shadowrootclonable" ""

    else
        Ir.none


{-| Enables declarative shadow roots to indicate they will use a custom element registry
-}
shadowrootcustomelementregistry : Bool -> Attr { c | shadowrootcustomelementregistry : Supported } msg
shadowrootcustomelementregistry value_ =
    if value_ then
        Ir.attribute "shadowrootcustomelementregistry" ""

    else
        Ir.none


{-| Sets delegates focus on a declarative shadow root
-}
shadowrootdelegatesfocus : Bool -> Attr { c | shadowrootdelegatesfocus : Supported } msg
shadowrootdelegatesfocus value_ =
    if value_ then
        Ir.attribute "shadowrootdelegatesfocus" ""

    else
        Ir.none


{-| Sets serializable on a declarative shadow root
-}
shadowrootserializable : Bool -> Attr { c | shadowrootserializable : Supported } msg
shadowrootserializable value_ =
    if value_ then
        Ir.attribute "shadowrootserializable" ""

    else
        Ir.none


{-| Size of the control
-}
size : Int -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (String.fromInt value_)


{-| Image sizes for different page layouts
-}
sizes : String -> Attr { c | sizes : Supported } msg
sizes =
    Ir.attribute "sizes"


{-| Number of columns spanned by the element
-}
span : Int -> Attr { c | span : Supported } msg
span value_ =
    Ir.attribute "span" (String.fromInt value_)


{-| Address of the resource
-}
src : String -> Attr { c | src : Supported } msg
src =
    Ir.attribute "src"


{-| A document to render in the iframe
-}
srcdoc : String -> Attr { c | srcdoc : Supported } msg
srcdoc =
    Ir.attribute "srcdoc"


{-| Language of the text track
-}
srclang : String -> Attr { c | srclang : Supported } msg
srclang =
    Ir.attribute "srclang"


{-| Images to use in different situations, e.g., high-resolution displays, small monitors, etc.
-}
srcset : String -> Attr { c | srcset : Supported } msg
srcset =
    Ir.attribute "srcset"


{-| Starting value of the list
-}
start : Int -> Attr { c | start : Supported } msg
start value_ =
    Ir.attribute "start" (String.fromInt value_)


{-| Granularity to be matched by the form control's value. A valid floating-point number OR the keyword `any` (which disables step-matching), so this cannot be a `Float`; `stepAsNumber` takes one when the keyword is not wanted.
-}
step : String -> Attr { c | step : Supported } msg
step =
    Ir.attribute "step"


{-| Navigable for hyperlink navigation
-}
target : String -> Attr { c | target : Supported } msg
target =
    Ir.attribute "target"


{-| Type of button: submit (default), reset, or button
-}
type_ : String -> Attr { c | type_ : Supported } msg
type_ =
    Ir.attribute "type"


{-| Name of image map to use
-}
usemap : String -> Attr { c | usemap : Supported } msg
usemap =
    Ir.attribute "usemap"


{-| Value to be used for form submission

Sets the LIVE DOM property `value`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultValue`.

-}
value : String -> Attr { c | value : Supported } msg
value value_ =
    Ir.property "value" (Json.Encode.string value_)


{-| Current value of the element
-}
valueNumeric : Float -> Attr { c | valueNumeric : Supported } msg
valueNumeric value_ =
    Ir.attribute "value" (String.fromFloat value_)


{-| Ordinal value of the list item
-}
valueOrdinal : Int -> Attr { c | valueOrdinal : Supported } msg
valueOrdinal value_ =
    Ir.attribute "value" (String.fromInt value_)


{-| Horizontal dimension
-}
width : Int -> Attr { c | width : Supported } msg
width value_ =
    Ir.attribute "width" (String.fromInt value_)


{-| Set the `checked` CONTENT attribute — the element's DEFAULT/initial `checked`, mirroring HTML's own `defaultChecked` IDL attribute. Unlike `checked` (which writes the live DOM property) this one SERIALIZES: it is what server-rendered markup and `outerHTML` show, and it is what a form reset restores to.
-}
defaultChecked : Bool -> Attr { c | checked : Supported } msg
defaultChecked value_ =
    if value_ then
        Ir.attribute "checked" ""

    else
        Ir.none


{-| Set the `muted` CONTENT attribute — the element's DEFAULT/initial `muted`, mirroring HTML's own `defaultMuted` IDL attribute. Unlike `muted` (which writes the live DOM property) this one SERIALIZES: it is what server-rendered markup and `outerHTML` show, and it is what a form reset restores to. Pair it with `muted` for the live state; see that setter's resync caveat.
-}
defaultMuted : Bool -> Attr { c | muted : Supported } msg
defaultMuted value_ =
    if value_ then
        Ir.attribute "muted" ""

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


{-| Set the `coords` attribute from a list of integers, joined with `,`. An ergonomic alternative to `coords`, which keeps the spec-correct `String` type; this one cannot express every legal value, so reach for `coords` when you need one it cannot. Both claim the same capability, mirroring HTML's own `value` / `valueAsNumber` split.
-}
coordsAsInts : List Int -> Attr { c | coords : Supported } msg
coordsAsInts value_ =
    Ir.attribute "coords" (String.join "," (List.map String.fromInt value_))


{-| Set the `step` attribute from a number. An ergonomic alternative to `step`, which keeps the spec-correct `String` type; this one cannot express every legal value, so reach for `step` when you need one it cannot. Both claim the same capability, mirroring HTML's own `value` / `valueAsNumber` split.
-}
stepAsNumber : Float -> Attr { c | step : Supported } msg
stepAsNumber value_ =
    Ir.attribute "step" (String.fromFloat value_)


{-| Set the `value` attribute from a number. An ergonomic alternative to `value`, which keeps the spec-correct `String` type; this one cannot express every legal value, so reach for `value` when you need one it cannot. Both claim the same capability, mirroring HTML's own `value` / `valueAsNumber` split.
-}
valueAsNumber : Float -> Attr { c | value : Supported } msg
valueAsNumber value_ =
    Ir.property "value" (Json.Encode.string (String.fromFloat value_))


{-| Whether the element is potentially render-blocking
-}
blocking : Value TypedHtml.Values.Blocking -> Attr { c | blocking : Supported } msg
blocking value_ =
    Ir.attribute "blocking" (HtmlIr.Value.toString value_)


{-| Character encoding declaration
-}
charset : Value TypedHtml.Values.Charset -> Attr { c | charset : Supported } msg
charset value_ =
    Ir.attribute "charset" (HtmlIr.Value.toString value_)


{-| Which user actions will close the dialog
-}
closedby : Value TypedHtml.Values.Closedby -> Attr { c | closedby : Supported } msg
closedby value_ =
    Ir.attribute "closedby" (HtmlIr.Value.toString value_)


{-| The color space of the serialized color
-}
colorspace : Value TypedHtml.Values.Colorspace -> Attr { c | colorspace : Supported } msg
colorspace value_ =
    Ir.attribute "colorspace" (HtmlIr.Value.toString value_)


{-| How the element handles crossorigin requests
-}
crossorigin : Value TypedHtml.Values.Crossorigin -> Attr { c | crossorigin : Supported } msg
crossorigin value_ =
    Ir.attribute "crossorigin" (HtmlIr.Value.toString value_)


{-| Decoding hint to use when processing this image for presentation
-}
decoding : Value TypedHtml.Values.Decoding -> Attr { c | decoding : Supported } msg
decoding value_ =
    Ir.attribute "decoding" (HtmlIr.Value.toString value_)


{-| Entry list encoding type to use for form submission
-}
enctype : Value TypedHtml.Values.Enctype -> Attr { c | enctype : Supported } msg
enctype value_ =
    Ir.attribute "enctype" (HtmlIr.Value.toString value_)


{-| Sets the priority for fetches initiated by the element
-}
fetchpriority : Value TypedHtml.Values.Fetchpriority -> Attr { c | fetchpriority : Supported } msg
fetchpriority value_ =
    Ir.attribute "fetchpriority" (HtmlIr.Value.toString value_)


{-| Entry list encoding type to use for form submission
-}
formenctype : Value TypedHtml.Values.Formenctype -> Attr { c | formenctype : Supported } msg
formenctype value_ =
    Ir.attribute "formenctype" (HtmlIr.Value.toString value_)


{-| Variant to use for form submission
-}
formmethod : Value TypedHtml.Values.Formmethod -> Attr { c | formmethod : Supported } msg
formmethod value_ =
    Ir.attribute "formmethod" (HtmlIr.Value.toString value_)


{-| Pragma directive
-}
httpEquiv : Value TypedHtml.Values.HttpEquiv -> Attr { c | httpEquiv : Supported } msg
httpEquiv value_ =
    Ir.attribute "http-equiv" (HtmlIr.Value.toString value_)


{-| The type of text track
-}
kind : Value TypedHtml.Values.Kind -> Attr { c | kind : Supported } msg
kind value_ =
    Ir.attribute "kind" (HtmlIr.Value.toString value_)


{-| Used when determining loading deferral
-}
loading : Value TypedHtml.Values.Loading -> Attr { c | loading : Supported } msg
loading value_ =
    Ir.attribute "loading" (HtmlIr.Value.toString value_)


{-| Variant to use for form submission
-}
method : Value TypedHtml.Values.Method -> Attr { c | method : Supported } msg
method value_ =
    Ir.attribute "method" (HtmlIr.Value.toString value_)


{-| Indicates whether a targeted popover element is to be toggled, shown, or hidden
-}
popovertargetaction : Value TypedHtml.Values.Popovertargetaction -> Attr { c | popovertargetaction : Supported } msg
popovertargetaction value_ =
    Ir.attribute "popovertargetaction" (HtmlIr.Value.toString value_)


{-| Hints how much buffering the media resource will likely need
-}
preload : Value TypedHtml.Values.Preload -> Attr { c | preload : Supported } msg
preload value_ =
    Ir.attribute "preload" (HtmlIr.Value.toString value_)


{-| Referrer policy for fetches initiated by the element
-}
referrerpolicy : Value TypedHtml.Values.Referrerpolicy -> Attr { c | referrerpolicy : Supported } msg
referrerpolicy value_ =
    Ir.attribute "referrerpolicy" (HtmlIr.Value.toString value_)


{-| Security rules for nested content
-}
sandbox : Value TypedHtml.Values.Sandbox -> Attr { c | sandbox : Supported } msg
sandbox value_ =
    Ir.attribute "sandbox" (HtmlIr.Value.toString value_)


{-| Specifies which cells the header cell applies to
-}
scope : Value TypedHtml.Values.Scope -> Attr { c | scope : Supported } msg
scope value_ =
    Ir.attribute "scope" (HtmlIr.Value.toString value_)


{-| Enables streaming declarative shadow roots
-}
shadowrootmode : Value TypedHtml.Values.Shadowrootmode -> Attr { c | shadowrootmode : Supported } msg
shadowrootmode value_ =
    Ir.attribute "shadowrootmode" (HtmlIr.Value.toString value_)


{-| Sets slot assignment on a declarative shadow root
-}
shadowrootslotassignment : Value TypedHtml.Values.Shadowrootslotassignment -> Attr { c | shadowrootslotassignment : Supported } msg
shadowrootslotassignment value_ =
    Ir.attribute "shadowrootslotassignment" (HtmlIr.Value.toString value_)


{-| The kind of shape to be created in an image map
-}
shape : Value TypedHtml.Values.Shape -> Attr { c | shape : Supported } msg
shape value_ =
    Ir.attribute "shape" (HtmlIr.Value.toString value_)


{-| How the value of the form control is to be wrapped for form submission
-}
wrap : Value TypedHtml.Values.Wrap -> Attr { c | wrap : Supported } msg
wrap value_ =
    Ir.attribute "wrap" (HtmlIr.Value.toString value_)


{-| Set the `blocking` attribute to `"render"`. Portmanteau of `blocking` + `render` — for IDE discovery and single-import ergonomics.
-}
blockingRender : Attr { c | blocking : Supported } msg
blockingRender =
    Ir.attribute "blocking" "render"


{-| Set the `charset` attribute to `"utf-8"`. Portmanteau of `charset` + `utf-8` — for IDE discovery and single-import ergonomics.
-}
charsetUtf8 : Attr { c | charset : Supported } msg
charsetUtf8 =
    Ir.attribute "charset" "utf-8"


{-| Set the `closedby` attribute to `"any"`. Portmanteau of `closedby` + `any` — for IDE discovery and single-import ergonomics.
-}
closedbyAny : Attr { c | closedby : Supported } msg
closedbyAny =
    Ir.attribute "closedby" "any"


{-| Set the `closedby` attribute to `"closerequest"`. Portmanteau of `closedby` + `closerequest` — for IDE discovery and single-import ergonomics.
-}
closedbyCloserequest : Attr { c | closedby : Supported } msg
closedbyCloserequest =
    Ir.attribute "closedby" "closerequest"


{-| Set the `closedby` attribute to `"none"`. Portmanteau of `closedby` + `none` — for IDE discovery and single-import ergonomics.
-}
closedbyNone : Attr { c | closedby : Supported } msg
closedbyNone =
    Ir.attribute "closedby" "none"


{-| Set the `colorspace` attribute to `"display-p3"`. Portmanteau of `colorspace` + `display-p3` — for IDE discovery and single-import ergonomics.
-}
colorspaceDisplayP3 : Attr { c | colorspace : Supported } msg
colorspaceDisplayP3 =
    Ir.attribute "colorspace" "display-p3"


{-| Set the `colorspace` attribute to `"limited-srgb"`. Portmanteau of `colorspace` + `limited-srgb` — for IDE discovery and single-import ergonomics.
-}
colorspaceLimitedSrgb : Attr { c | colorspace : Supported } msg
colorspaceLimitedSrgb =
    Ir.attribute "colorspace" "limited-srgb"


{-| Set the `crossorigin` attribute to `""`. Portmanteau of `crossorigin` + \`\` — for IDE discovery and single-import ergonomics.
-}
crossoriginValue : Attr { c | crossorigin : Supported } msg
crossoriginValue =
    Ir.attribute "crossorigin" ""


{-| Set the `crossorigin` attribute to `"anonymous"`. Portmanteau of `crossorigin` + `anonymous` — for IDE discovery and single-import ergonomics.
-}
crossoriginAnonymous : Attr { c | crossorigin : Supported } msg
crossoriginAnonymous =
    Ir.attribute "crossorigin" "anonymous"


{-| Set the `crossorigin` attribute to `"use-credentials"`. Portmanteau of `crossorigin` + `use-credentials` — for IDE discovery and single-import ergonomics.
-}
crossoriginUseCredentials : Attr { c | crossorigin : Supported } msg
crossoriginUseCredentials =
    Ir.attribute "crossorigin" "use-credentials"


{-| Set the `decoding` attribute to `"async"`. Portmanteau of `decoding` + `async` — for IDE discovery and single-import ergonomics.
-}
decodingAsync : Attr { c | decoding : Supported } msg
decodingAsync =
    Ir.attribute "decoding" "async"


{-| Set the `decoding` attribute to `"auto"`. Portmanteau of `decoding` + `auto` — for IDE discovery and single-import ergonomics.
-}
decodingAuto : Attr { c | decoding : Supported } msg
decodingAuto =
    Ir.attribute "decoding" "auto"


{-| Set the `decoding` attribute to `"sync"`. Portmanteau of `decoding` + `sync` — for IDE discovery and single-import ergonomics.
-}
decodingSync : Attr { c | decoding : Supported } msg
decodingSync =
    Ir.attribute "decoding" "sync"


{-| Set the `enctype` attribute to `"application/x-www-form-urlencoded"`. Portmanteau of `enctype` + `application/x-www-form-urlencoded` — for IDE discovery and single-import ergonomics.
-}
enctypeApplicationXWwwFormUrlencoded : Attr { c | enctype : Supported } msg
enctypeApplicationXWwwFormUrlencoded =
    Ir.attribute "enctype" "application/x-www-form-urlencoded"


{-| Set the `enctype` attribute to `"multipart/form-data"`. Portmanteau of `enctype` + `multipart/form-data` — for IDE discovery and single-import ergonomics.
-}
enctypeMultipartFormData : Attr { c | enctype : Supported } msg
enctypeMultipartFormData =
    Ir.attribute "enctype" "multipart/form-data"


{-| Set the `enctype` attribute to `"text/plain"`. Portmanteau of `enctype` + `text/plain` — for IDE discovery and single-import ergonomics.
-}
enctypeTextPlain : Attr { c | enctype : Supported } msg
enctypeTextPlain =
    Ir.attribute "enctype" "text/plain"


{-| Set the `fetchpriority` attribute to `"auto"`. Portmanteau of `fetchpriority` + `auto` — for IDE discovery and single-import ergonomics.
-}
fetchpriorityAuto : Attr { c | fetchpriority : Supported } msg
fetchpriorityAuto =
    Ir.attribute "fetchpriority" "auto"


{-| Set the `fetchpriority` attribute to `"high"`. Portmanteau of `fetchpriority` + `high` — for IDE discovery and single-import ergonomics.
-}
fetchpriorityHigh : Attr { c | fetchpriority : Supported } msg
fetchpriorityHigh =
    Ir.attribute "fetchpriority" "high"


{-| Set the `fetchpriority` attribute to `"low"`. Portmanteau of `fetchpriority` + `low` — for IDE discovery and single-import ergonomics.
-}
fetchpriorityLow : Attr { c | fetchpriority : Supported } msg
fetchpriorityLow =
    Ir.attribute "fetchpriority" "low"


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


{-| Set the `formmethod` attribute to `"dialog"`. Portmanteau of `formmethod` + `dialog` — for IDE discovery and single-import ergonomics.
-}
formmethodDialog : Attr { c | formmethod : Supported } msg
formmethodDialog =
    Ir.attribute "formmethod" "dialog"


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


{-| Set the `http-equiv` attribute to `"content-security-policy"`. Portmanteau of `httpEquiv` + `content-security-policy` — for IDE discovery and single-import ergonomics.
-}
httpEquivContentSecurityPolicy : Attr { c | httpEquiv : Supported } msg
httpEquivContentSecurityPolicy =
    Ir.attribute "http-equiv" "content-security-policy"


{-| Set the `http-equiv` attribute to `"content-type"`. Portmanteau of `httpEquiv` + `content-type` — for IDE discovery and single-import ergonomics.
-}
httpEquivContentType : Attr { c | httpEquiv : Supported } msg
httpEquivContentType =
    Ir.attribute "http-equiv" "content-type"


{-| Set the `http-equiv` attribute to `"default-style"`. Portmanteau of `httpEquiv` + `default-style` — for IDE discovery and single-import ergonomics.
-}
httpEquivDefaultStyle : Attr { c | httpEquiv : Supported } msg
httpEquivDefaultStyle =
    Ir.attribute "http-equiv" "default-style"


{-| Set the `http-equiv` attribute to `"refresh"`. Portmanteau of `httpEquiv` + `refresh` — for IDE discovery and single-import ergonomics.
-}
httpEquivRefresh : Attr { c | httpEquiv : Supported } msg
httpEquivRefresh =
    Ir.attribute "http-equiv" "refresh"


{-| Set the `http-equiv` attribute to `"x-ua-compatible"`. Portmanteau of `httpEquiv` + `x-ua-compatible` — for IDE discovery and single-import ergonomics.
-}
httpEquivXUaCompatible : Attr { c | httpEquiv : Supported } msg
httpEquivXUaCompatible =
    Ir.attribute "http-equiv" "x-ua-compatible"


{-| Set the `kind` attribute to `"captions"`. Portmanteau of `kind` + `captions` — for IDE discovery and single-import ergonomics.
-}
kindCaptions : Attr { c | kind : Supported } msg
kindCaptions =
    Ir.attribute "kind" "captions"


{-| Set the `kind` attribute to `"chapters"`. Portmanteau of `kind` + `chapters` — for IDE discovery and single-import ergonomics.
-}
kindChapters : Attr { c | kind : Supported } msg
kindChapters =
    Ir.attribute "kind" "chapters"


{-| Set the `kind` attribute to `"descriptions"`. Portmanteau of `kind` + `descriptions` — for IDE discovery and single-import ergonomics.
-}
kindDescriptions : Attr { c | kind : Supported } msg
kindDescriptions =
    Ir.attribute "kind" "descriptions"


{-| Set the `kind` attribute to `"metadata"`. Portmanteau of `kind` + `metadata` — for IDE discovery and single-import ergonomics.
-}
kindMetadata : Attr { c | kind : Supported } msg
kindMetadata =
    Ir.attribute "kind" "metadata"


{-| Set the `kind` attribute to `"subtitles"`. Portmanteau of `kind` + `subtitles` — for IDE discovery and single-import ergonomics.
-}
kindSubtitles : Attr { c | kind : Supported } msg
kindSubtitles =
    Ir.attribute "kind" "subtitles"


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


{-| Set the `method` attribute to `"dialog"`. Portmanteau of `method` + `dialog` — for IDE discovery and single-import ergonomics.
-}
methodDialog : Attr { c | method : Supported } msg
methodDialog =
    Ir.attribute "method" "dialog"


{-| Set the `method` attribute to `"get"`. Portmanteau of `method` + `get` — for IDE discovery and single-import ergonomics.
-}
methodGet : Attr { c | method : Supported } msg
methodGet =
    Ir.attribute "method" "get"


{-| Set the `method` attribute to `"post"`. Portmanteau of `method` + `post` — for IDE discovery and single-import ergonomics.
-}
methodPost : Attr { c | method : Supported } msg
methodPost =
    Ir.attribute "method" "post"


{-| Set the `popovertargetaction` attribute to `"hide"`. Portmanteau of `popovertargetaction` + `hide` — for IDE discovery and single-import ergonomics.
-}
popovertargetactionHide : Attr { c | popovertargetaction : Supported } msg
popovertargetactionHide =
    Ir.attribute "popovertargetaction" "hide"


{-| Set the `popovertargetaction` attribute to `"show"`. Portmanteau of `popovertargetaction` + `show` — for IDE discovery and single-import ergonomics.
-}
popovertargetactionShow : Attr { c | popovertargetaction : Supported } msg
popovertargetactionShow =
    Ir.attribute "popovertargetaction" "show"


{-| Set the `popovertargetaction` attribute to `"toggle"`. Portmanteau of `popovertargetaction` + `toggle` — for IDE discovery and single-import ergonomics.
-}
popovertargetactionToggle : Attr { c | popovertargetaction : Supported } msg
popovertargetactionToggle =
    Ir.attribute "popovertargetaction" "toggle"


{-| Set the `preload` attribute to `""`. Portmanteau of `preload` + \`\` — for IDE discovery and single-import ergonomics.
-}
preloadValue : Attr { c | preload : Supported } msg
preloadValue =
    Ir.attribute "preload" ""


{-| Set the `preload` attribute to `"auto"`. Portmanteau of `preload` + `auto` — for IDE discovery and single-import ergonomics.
-}
preloadAuto : Attr { c | preload : Supported } msg
preloadAuto =
    Ir.attribute "preload" "auto"


{-| Set the `preload` attribute to `"metadata"`. Portmanteau of `preload` + `metadata` — for IDE discovery and single-import ergonomics.
-}
preloadMetadata : Attr { c | preload : Supported } msg
preloadMetadata =
    Ir.attribute "preload" "metadata"


{-| Set the `preload` attribute to `"none"`. Portmanteau of `preload` + `none` — for IDE discovery and single-import ergonomics.
-}
preloadNone : Attr { c | preload : Supported } msg
preloadNone =
    Ir.attribute "preload" "none"


{-| Set the `referrerpolicy` attribute to `""`. Portmanteau of `referrerpolicy` + \`\` — for IDE discovery and single-import ergonomics.
-}
referrerpolicyValue : Attr { c | referrerpolicy : Supported } msg
referrerpolicyValue =
    Ir.attribute "referrerpolicy" ""


{-| Set the `referrerpolicy` attribute to `"no-referrer"`. Portmanteau of `referrerpolicy` + `no-referrer` — for IDE discovery and single-import ergonomics.
-}
referrerpolicyNoReferrer : Attr { c | referrerpolicy : Supported } msg
referrerpolicyNoReferrer =
    Ir.attribute "referrerpolicy" "no-referrer"


{-| Set the `referrerpolicy` attribute to `"no-referrer-when-downgrade"`. Portmanteau of `referrerpolicy` + `no-referrer-when-downgrade` — for IDE discovery and single-import ergonomics.
-}
referrerpolicyNoReferrerWhenDowngrade : Attr { c | referrerpolicy : Supported } msg
referrerpolicyNoReferrerWhenDowngrade =
    Ir.attribute "referrerpolicy" "no-referrer-when-downgrade"


{-| Set the `referrerpolicy` attribute to `"origin"`. Portmanteau of `referrerpolicy` + `origin` — for IDE discovery and single-import ergonomics.
-}
referrerpolicyOrigin : Attr { c | referrerpolicy : Supported } msg
referrerpolicyOrigin =
    Ir.attribute "referrerpolicy" "origin"


{-| Set the `referrerpolicy` attribute to `"origin-when-cross-origin"`. Portmanteau of `referrerpolicy` + `origin-when-cross-origin` — for IDE discovery and single-import ergonomics.
-}
referrerpolicyOriginWhenCrossOrigin : Attr { c | referrerpolicy : Supported } msg
referrerpolicyOriginWhenCrossOrigin =
    Ir.attribute "referrerpolicy" "origin-when-cross-origin"


{-| Set the `referrerpolicy` attribute to `"same-origin"`. Portmanteau of `referrerpolicy` + `same-origin` — for IDE discovery and single-import ergonomics.
-}
referrerpolicySameOrigin : Attr { c | referrerpolicy : Supported } msg
referrerpolicySameOrigin =
    Ir.attribute "referrerpolicy" "same-origin"


{-| Set the `referrerpolicy` attribute to `"strict-origin"`. Portmanteau of `referrerpolicy` + `strict-origin` — for IDE discovery and single-import ergonomics.
-}
referrerpolicyStrictOrigin : Attr { c | referrerpolicy : Supported } msg
referrerpolicyStrictOrigin =
    Ir.attribute "referrerpolicy" "strict-origin"


{-| Set the `referrerpolicy` attribute to `"strict-origin-when-cross-origin"`. Portmanteau of `referrerpolicy` + `strict-origin-when-cross-origin` — for IDE discovery and single-import ergonomics.
-}
referrerpolicyStrictOriginWhenCrossOrigin : Attr { c | referrerpolicy : Supported } msg
referrerpolicyStrictOriginWhenCrossOrigin =
    Ir.attribute "referrerpolicy" "strict-origin-when-cross-origin"


{-| Set the `referrerpolicy` attribute to `"unsafe-url"`. Portmanteau of `referrerpolicy` + `unsafe-url` — for IDE discovery and single-import ergonomics.
-}
referrerpolicyUnsafeUrl : Attr { c | referrerpolicy : Supported } msg
referrerpolicyUnsafeUrl =
    Ir.attribute "referrerpolicy" "unsafe-url"


{-| Set the `sandbox` attribute to `"allow-downloads"`. Portmanteau of `sandbox` + `allow-downloads` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowDownloads : Attr { c | sandbox : Supported } msg
sandboxAllowDownloads =
    Ir.attribute "sandbox" "allow-downloads"


{-| Set the `sandbox` attribute to `"allow-forms"`. Portmanteau of `sandbox` + `allow-forms` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowForms : Attr { c | sandbox : Supported } msg
sandboxAllowForms =
    Ir.attribute "sandbox" "allow-forms"


{-| Set the `sandbox` attribute to `"allow-modals"`. Portmanteau of `sandbox` + `allow-modals` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowModals : Attr { c | sandbox : Supported } msg
sandboxAllowModals =
    Ir.attribute "sandbox" "allow-modals"


{-| Set the `sandbox` attribute to `"allow-orientation-lock"`. Portmanteau of `sandbox` + `allow-orientation-lock` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowOrientationLock : Attr { c | sandbox : Supported } msg
sandboxAllowOrientationLock =
    Ir.attribute "sandbox" "allow-orientation-lock"


{-| Set the `sandbox` attribute to `"allow-pointer-lock"`. Portmanteau of `sandbox` + `allow-pointer-lock` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowPointerLock : Attr { c | sandbox : Supported } msg
sandboxAllowPointerLock =
    Ir.attribute "sandbox" "allow-pointer-lock"


{-| Set the `sandbox` attribute to `"allow-popups"`. Portmanteau of `sandbox` + `allow-popups` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowPopups : Attr { c | sandbox : Supported } msg
sandboxAllowPopups =
    Ir.attribute "sandbox" "allow-popups"


{-| Set the `sandbox` attribute to `"allow-popups-to-escape-sandbox"`. Portmanteau of `sandbox` + `allow-popups-to-escape-sandbox` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowPopupsToEscapeSandbox : Attr { c | sandbox : Supported } msg
sandboxAllowPopupsToEscapeSandbox =
    Ir.attribute "sandbox" "allow-popups-to-escape-sandbox"


{-| Set the `sandbox` attribute to `"allow-presentation"`. Portmanteau of `sandbox` + `allow-presentation` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowPresentation : Attr { c | sandbox : Supported } msg
sandboxAllowPresentation =
    Ir.attribute "sandbox" "allow-presentation"


{-| Set the `sandbox` attribute to `"allow-same-origin"`. Portmanteau of `sandbox` + `allow-same-origin` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowSameOrigin : Attr { c | sandbox : Supported } msg
sandboxAllowSameOrigin =
    Ir.attribute "sandbox" "allow-same-origin"


{-| Set the `sandbox` attribute to `"allow-scripts"`. Portmanteau of `sandbox` + `allow-scripts` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowScripts : Attr { c | sandbox : Supported } msg
sandboxAllowScripts =
    Ir.attribute "sandbox" "allow-scripts"


{-| Set the `sandbox` attribute to `"allow-top-navigation"`. Portmanteau of `sandbox` + `allow-top-navigation` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowTopNavigation : Attr { c | sandbox : Supported } msg
sandboxAllowTopNavigation =
    Ir.attribute "sandbox" "allow-top-navigation"


{-| Set the `sandbox` attribute to `"allow-top-navigation-by-user-activation"`. Portmanteau of `sandbox` + `allow-top-navigation-by-user-activation` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowTopNavigationByUserActivation : Attr { c | sandbox : Supported } msg
sandboxAllowTopNavigationByUserActivation =
    Ir.attribute "sandbox" "allow-top-navigation-by-user-activation"


{-| Set the `sandbox` attribute to `"allow-top-navigation-to-custom-protocols"`. Portmanteau of `sandbox` + `allow-top-navigation-to-custom-protocols` — for IDE discovery and single-import ergonomics.
-}
sandboxAllowTopNavigationToCustomProtocols : Attr { c | sandbox : Supported } msg
sandboxAllowTopNavigationToCustomProtocols =
    Ir.attribute "sandbox" "allow-top-navigation-to-custom-protocols"


{-| Set the `scope` attribute to `"col"`. Portmanteau of `scope` + `col` — for IDE discovery and single-import ergonomics.
-}
scopeCol : Attr { c | scope : Supported } msg
scopeCol =
    Ir.attribute "scope" "col"


{-| Set the `scope` attribute to `"colgroup"`. Portmanteau of `scope` + `colgroup` — for IDE discovery and single-import ergonomics.
-}
scopeColgroup : Attr { c | scope : Supported } msg
scopeColgroup =
    Ir.attribute "scope" "colgroup"


{-| Set the `scope` attribute to `"row"`. Portmanteau of `scope` + `row` — for IDE discovery and single-import ergonomics.
-}
scopeRow : Attr { c | scope : Supported } msg
scopeRow =
    Ir.attribute "scope" "row"


{-| Set the `scope` attribute to `"rowgroup"`. Portmanteau of `scope` + `rowgroup` — for IDE discovery and single-import ergonomics.
-}
scopeRowgroup : Attr { c | scope : Supported } msg
scopeRowgroup =
    Ir.attribute "scope" "rowgroup"


{-| Set the `shadowrootmode` attribute to `"closed"`. Portmanteau of `shadowrootmode` + `closed` — for IDE discovery and single-import ergonomics.
-}
shadowrootmodeClosed : Attr { c | shadowrootmode : Supported } msg
shadowrootmodeClosed =
    Ir.attribute "shadowrootmode" "closed"


{-| Set the `shadowrootmode` attribute to `"open"`. Portmanteau of `shadowrootmode` + `open` — for IDE discovery and single-import ergonomics.
-}
shadowrootmodeOpen : Attr { c | shadowrootmode : Supported } msg
shadowrootmodeOpen =
    Ir.attribute "shadowrootmode" "open"


{-| Set the `shadowrootslotassignment` attribute to `"manual"`. Portmanteau of `shadowrootslotassignment` + `manual` — for IDE discovery and single-import ergonomics.
-}
shadowrootslotassignmentManual : Attr { c | shadowrootslotassignment : Supported } msg
shadowrootslotassignmentManual =
    Ir.attribute "shadowrootslotassignment" "manual"


{-| Set the `shadowrootslotassignment` attribute to `"named"`. Portmanteau of `shadowrootslotassignment` + `named` — for IDE discovery and single-import ergonomics.
-}
shadowrootslotassignmentNamed : Attr { c | shadowrootslotassignment : Supported } msg
shadowrootslotassignmentNamed =
    Ir.attribute "shadowrootslotassignment" "named"


{-| Set the `shape` attribute to `"circle"`. Portmanteau of `shape` + `circle` — for IDE discovery and single-import ergonomics.
-}
shapeCircle : Attr { c | shape : Supported } msg
shapeCircle =
    Ir.attribute "shape" "circle"


{-| Set the `shape` attribute to `"default"`. Portmanteau of `shape` + `default` — for IDE discovery and single-import ergonomics.
-}
shapeDefault : Attr { c | shape : Supported } msg
shapeDefault =
    Ir.attribute "shape" "default"


{-| Set the `shape` attribute to `"poly"`. Portmanteau of `shape` + `poly` — for IDE discovery and single-import ergonomics.
-}
shapePoly : Attr { c | shape : Supported } msg
shapePoly =
    Ir.attribute "shape" "poly"


{-| Set the `shape` attribute to `"rect"`. Portmanteau of `shape` + `rect` — for IDE discovery and single-import ergonomics.
-}
shapeRect : Attr { c | shape : Supported } msg
shapeRect =
    Ir.attribute "shape" "rect"


{-| Set the `wrap` attribute to `"hard"`. Portmanteau of `wrap` + `hard` — for IDE discovery and single-import ergonomics.
-}
wrapHard : Attr { c | wrap : Supported } msg
wrapHard =
    Ir.attribute "wrap" "hard"


{-| Set the `wrap` attribute to `"soft"`. Portmanteau of `wrap` + `soft` — for IDE discovery and single-import ergonomics.
-}
wrapSoft : Attr { c | wrap : Supported } msg
wrapSoft =
    Ir.attribute "wrap" "soft"
