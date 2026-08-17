module M3e.Coerce exposing (asButton, asPhrasing)

{-| Config-blessed brand crossings — the one loud, greppable re-kind concept.
Each function is declared in config (`_coerce`) and reviewed there; nothing
else in the library moves an element between kinds.

@docs asButton, asPhrasing

-}

import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import M3e.Kind exposing (Brand, Shared)


{-| A Chip admitted where a button kind is expected.
-}
asButton :
    Element { k | chip : Brand } admittedBy msg
    -> Element { s | button : Brand } admittedBy2 msg
asButton element =
    Ir.fromNode (HtmlIr.Element.toNode element)


{-| A AssistChip admitted where a shared:phrasing kind is expected.
-}
asPhrasing :
    Element { k | assistChip : Brand } admittedBy msg
    -> Element { s | sharedPhrasing : Shared } admittedBy2 msg
asPhrasing element =
    Ir.fromNode (HtmlIr.Element.toNode element)
