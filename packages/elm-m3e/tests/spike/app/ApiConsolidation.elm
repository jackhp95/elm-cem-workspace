module ApiConsolidation exposing (saveButton, card, annotationGate)

{-| Compile-only spike for the canonical zero-conversion builder API (plan §3.5B).

Direction (a): THE canonical snippet — builder → slot, no `.toElement`.
Direction (b): child builder → container builder pipeline, no `.toElement` on child.
Annotation-only: naming a component's phantom type with only the slim import.

-}

import HtmlIr.Element exposing (Element)
import M3e exposing (text)
import M3e.Action exposing (onClick)
import M3e.Build exposing (ButtonIs, CardIs)
import M3e.Build.Button as Button
import M3e.Build.Card as Card
import M3e.Build.Icon as Icon
import M3e.Values as Value


type Msg
    = Save
    | Ok


{-| Direction (a): THE canonical zero-conversion snippet (locked 2026-08-10).

    Builder → slot, no `.toElement` on the nested icon.
    ONE terminal `Button.Build.toElement`.
    Only `Button.Build` / `Icon.Build` imports — no `M3e.Button`/`M3e.Icon`.

-}
saveButton : Element (ButtonIs s) admittedBy Msg
saveButton =
    Button.build { content = text "Save", action = onClick Save }
        |> Button.withIcon (Icon.build |> Icon.withName "home")
        |> Button.toElement


{-| Direction (b): child builder → container builder pipeline, no `.toElement` on child.

    A built Button flows into a Card slot with zero unwrap.
    Proper per-component narrow value.

-}
card : Element (CardIs s) admittedBy Msg
card =
    Card.build
        |> Card.withContent
            (Button.build { content = text "Ok", action = onClick Ok }
                |> Button.withVariant Value.filled
            )
        |> Card.toElement


{-| Annotation-only: slim import to name a type.

    Imports only `M3e.Build` (not `M3e.Button` or `M3e.Button.Build`)
    for the `ButtonIs`/`CardIs` phantoms.

-}
annotationGate : List (Element (ButtonIs s) admittedBy Msg)
annotationGate =
    [ saveButton ]