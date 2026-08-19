module BlockedFormactionRow exposing (broken)

{-| The same guard proved as a ROW mismatch rather than a naming error, which is
the stronger of the two claims.

`BlockedFormactionSetter` fails because `Hz.Attributes.formaction` does not
exist — good, but a missing name is also what a typo produces. This probe
hand-rolls the setter the generator refuses to emit, with exactly the open
producer row the generator would have given it, and applies it to
`hz-blocked`'s CLOSED capability row. It fails because
`Hz.Component.Blocked.Attrs` has no `formaction` FIELD: the guard removed the capability,
not just the identifier, so no locally-defined lookalike can smuggle the
attribute back onto the element either.

The rendered result is why. `Ir.attribute "formaction"` reaches
`_VirtualDom_noOnOrFormAction`, whose `/^(on|formAction$)/i` matches under the
`i` flag, and the DOM gets `data-formaction` — a `<button>` that does not
override its form's action, silently.

MUST FAIL with a missing row field.

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Hz.Component.Blocked


{-| Exactly the shape `Emit.plainSetter` would have emitted for `formaction`.
-}
formaction : String -> Attr { c | formaction : Supported } msg
formaction =
    Ir.attribute "formaction"


broken : Attr Hz.Component.Blocked.Attrs msg
broken =
    formaction "/submit"
