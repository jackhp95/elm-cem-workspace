module BlockedIsSetter exposing (broken)

{-| The same guard, on the per-component surface and on the other blocked
mechanism. `hz-blocked` declares an `is` attribute, and `Hz.Blocked` must expose
no setter for it.

`is` is not rewritten by any kernel guard — it is defeated one step earlier.
Customized built-in elements are opted in only at CREATION time, via
`document.createElement(tag, { is })`, and `_VirtualDom_render` creates every
node with `_VirtualDom_doc.createElement(vNode.__tag)` — no options argument. By
the time virtual-dom applies attribute facts the element already exists as its
plain built-in self, so `setAttribute("is", …)` cannot upgrade it. There is no
`is` IDL attribute either, so the property form is an inert expando.

MUST FAIL, as an unknown value.

-}

import HtmlIr.Attribute
import Hz.Blocked


broken : HtmlIr.Attribute.Attr Hz.Blocked.Attrs msg
broken =
    Hz.Blocked.is "my-custom-button"
