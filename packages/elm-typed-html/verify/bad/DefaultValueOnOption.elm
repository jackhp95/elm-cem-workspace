module DefaultValueOnOption exposing (broken)

{-| A home module re-exports only the companions its OWN members earn. MUST FAIL.

`_controlled` scopes `value`'s PROPERTY form to `<input>`, the one element whose live
value diverges from the content attribute. `<option>` is not in that scope, so
`TypedHtml.Select.value` writes the `value` CONTENT attribute directly — which is what
`<option>` wants and what HTML calls it. There is no `HTMLOptionElement.defaultValue`
to mirror, so the `Select` home emits no `defaultValue`; a second setter beside `value`
for the one fact would be pure misdirection about which of the two is live.

The name-only roster this replaces minted `defaultValue` on all seven elements
declaring a `value` attribute, including the six HTML gives no such IDL attribute.

Deliberately narrower than it looks, and worth being precise about, because
`TypedHtml.Attributes.defaultValue` DOES exist and DOES claim the `value` row — so
`At.defaultValue "a"` on an `<option>` compiles. That is the loose surface behaving as
documented: one open producer per name, admitted by every element whose row carries the
field, and on a REFLECTING `<option>` an `Ir.attribute "value"` write is right whichever
of the two names you reached for. What this case pins is the STRICT surface, the
per-element home module, which is where the library states what each element actually
has. `TypedHtml.Input.defaultValue` is there (see verify/src/Good.elm) — `<input>` is
the element with the live/default split. `TypedHtml.Select.defaultValue` is not.

-}

import TypedHtml.Select as Select


broken =
    Select.option [ Select.defaultValue "a" ] []
