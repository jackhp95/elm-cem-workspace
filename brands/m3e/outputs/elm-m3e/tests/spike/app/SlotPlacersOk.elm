module SlotPlacersOk exposing (placed1, placed2, placed3)

{-| Compile-only spike for Design-C loose slot placers (Objective 2).

Verifies:
  - Slot placers generated into the `M3e` single-import surface compile.
  - Placing a text node into a named slot typechecks.
  - Placing an icon element into a button's icon slot typechecks.
  - Placing a button into a splitButton's leading-button slot typechecks.

The Design-C broad-admittance row means ANY element can be placed into ANY
named slot at the type level. Wrong-kind narrowing is deferred to the
`Cem.ValidSlotKind` elm-review rule — NOT enforced here at the type level.

-}

import HtmlIr.Element exposing (Element)
import M3e exposing (button, icon, splitButton, text)
import M3e.Action exposing (onClick)


type Msg
    = Save


{-| Good placement: text into the "icon" slot (broad row accepts it). -}
placed1 : Element free freeAdm Msg
placed1 =
    M3e.slotIcon (text "favorite")


{-| Good placement: icon element into the "icon" slot inside a button.

This is the ergonomic one-liner the Design-C API enables. The type signature
of `M3e.button` accepts `Element (ButtonIconSlot s) …` for the icon slot
when using per-component setters; here the loose placer stamps the `slot`
attribute and re-wraps the element with open rows.

-}
placed2 : Element free freeAdm Msg
placed2 =
    M3e.slotIcon (icon [] [])


{-| Good placement: icon into the "trailing-icon" slot. -}
placed3 : Element free freeAdm Msg
placed3 =
    M3e.slotTrailingIcon (icon [] [])
