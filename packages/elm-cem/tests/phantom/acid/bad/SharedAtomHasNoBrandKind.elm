module SharedAtomHasNoBrandKind exposing (broken)

{-| Half two of the CROSSING THEOREM. MUST FAIL.

`Mini.Icon` declares `"kind": "shared:icon"`, so it produces
`Is s = { s | sharedIcon : Shared }` — and NOTHING else. That is what lets it into
`Mini.Button`'s `icon` slot, and into any foreign brand's slot that names the same
atom (see `Good.elm`).

The price is stated below: there is no `icon : Mini.Kind.Brand` field left, so no
slot in this brand — or any brand — can say "an icon of MINE and nothing else".
The row a discriminating slot would have to write is `{ icon : Mini.Kind.Brand }`,
and this file writes exactly that. It does not type-check, and it cannot be made
to: adding the brand field back is precisely what would break
`Good.elm`'s `Mini.Button.icon (Mini.icon [] [ Mini.text "star" ])`, because
adding a field to a producer makes it fit FEWER slots, not more.

So the two halves are one fact. The field that lets a component leave its brand is
the same field that stops its own brand discriminating it — which is why the
crossing theorem is a property of the encoding rather than a gap in the config.

The sanctioned answers, none of which change this: a kind-permissive container
(`Mini.Surface`, `"kinds": ["any"]`), a shared atom on both sides (this file's
subject), or a declared loud crossing (`Mini.Coerce.asButton`, config `_coerce`).

-}

import HtmlIr.Element exposing (Element)
import Mini
import Mini.Kind


broken : Element { icon : Mini.Kind.Brand } admittedBy msg
broken =
    Mini.icon [] [ Mini.text "star" ]
