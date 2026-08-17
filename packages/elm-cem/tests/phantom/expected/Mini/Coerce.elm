module Mini.Coerce exposing (asButton)

{-| Config-blessed brand crossings — the one loud, greppable re-kind concept.
Each function is declared in config (`_coerce`) and reviewed there; nothing
else in the library moves an element between kinds.

@docs asButton

-}

import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import Mini.Kind exposing (Brand)


{-| A Chip admitted where a button kind is expected.
-}
asButton :
    Element { k | chip : Brand } admittedBy msg
    -> Element { s | button : Brand } admittedBy2 msg
asButton element =
    Ir.fromNode (HtmlIr.Element.toNode element)
