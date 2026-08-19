module BlockedFormactionSetter exposing (broken)

{-| Proves the KERNEL-BLOCKED guard: `hz-blocked` DECLARES a `formaction`
attribute, and the shared vocabulary must still have no setter for it.

`formaction` is real HTML and the manifest is right to declare it. What cannot
express it is `elm/virtual-dom`: `_VirtualDom_RE_on_formAction` is
`/^(on|formAction$)/i`, and the `i` flag makes `^formAction$` match HTML's
lowercase spelling, so `_VirtualDom_noOnOrFormAction` rewrites the key and
`Ir.attribute "formaction" url` renders `data-formaction="…"`. The property path
is closed too — `_VirtualDom_noInnerHtmlOrFormAction` rewrites the exact key
`formAction`, and the lowercase key is an expando `<button>` never observes.

So a `formaction` setter would type-check, render, raise nothing, and set the
wrong attribute. This probe fails as an UNKNOWN VALUE, which is the whole point:
the name must not exist. MUST FAIL.

If you are here because you were about to add `formaction` back — read
`Attr.kernelBlockedReason` in the generator first. There is no working path from
Elm; use a port or a custom element.

-}

import HtmlIr.Attribute
import Hz.Attributes
import Hz.Component.Blocked


broken : HtmlIr.Attribute.Attr Hz.Component.Blocked.Attrs msg
broken =
    Hz.Attributes.formaction "/submit"
