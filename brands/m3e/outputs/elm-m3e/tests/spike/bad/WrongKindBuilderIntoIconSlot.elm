module WrongKindBuilderIntoIconSlot exposing (wrong)

{-| NEGATIVE probe: a `Button.Build` builder (kind `{ s | button : Brand }`)
passed into `Button.Build.withIcon`, which expects a builder whose kind admits
`Component.IconSlot` (`{ loadingIndicator : Brand, sharedIcon : Shared }`).

Must FAIL to compile — `{ s | button : Brand }` does not extend
`{ loadingIndicator : Brand, sharedIcon : Shared }`.

-}

import HtmlIr.Element exposing (Element)
import M3e exposing (text)
import M3e.Action exposing (onClick)
import M3e.Build exposing (ButtonIs)
import M3e.Build.Button as Button


type Msg
    = Save


wrong : Element (ButtonIs s) b Msg
wrong =
    Button.build { content = text "Save", action = onClick Save }
        |> Button.withIcon (Button.build { content = text "Nope", action = onClick Save })
        |> Button.toElement