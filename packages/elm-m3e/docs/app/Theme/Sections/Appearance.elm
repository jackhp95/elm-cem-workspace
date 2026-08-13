module Theme.Sections.Appearance exposing (view)

import M3e exposing (Element)
import M3e.Kind
import M3e.Values as Value exposing (Value)
import Theme exposing (Msg(..))
import TypedHtml
import TypedHtml.Attributes
import TypedHtml.Grouping


view : Theme.Model -> Element (TypedHtml.Grouping.DivIs s) admittedBy Msg
view model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-3" ]
        [ contrastSegmented model
        , motionSegmented model
        , densitySegmented model
        ]


{-| Ported from the app-level Shared.elm's `contrastSegmented` (as it existed
before Task 14 removes it from that file) — same rendering logic, retargeted
from `Shared.Model` to `Theme.Model` (same field name, `contrast`, no rename
needed) and from `Shared.Msg`'s `SetContrast` to this module's own
`Theme.SetContrast` (already matching name).
-}
contrastSegmented : Theme.Model -> Element { s | segmentedButton : M3e.Kind.Brand } admittedBy Msg
contrastSegmented model =
    Theme.segmented
        (Value.contrastValues
            |> List.sortBy contrastOrder
            |> List.map (\v -> ( Theme.capitalize (Value.toString v), model.contrast == v, SetContrast v ))
        )


{-| Display order — ascending intensity, which alphabetical order does not
give. Ported verbatim from Shared.elm's `contrastOrder`.
-}
contrastOrder : Value Value.Contrast -> Int
contrastOrder v =
    case Value.toString v of
        "standard" ->
            0

        "medium" ->
            1

        "high" ->
            2

        _ ->
            3


{-| NEW — not ported, since the app-level Shared.elm never had a Motion
control. Follows the exact same pattern as `contrastSegmented` above:
`Value.motionValues` already exists (`src/M3e/Values.elm`, confirmed
`[ expressive, standard ]`), so no new `Value` module work is needed, only
this segmented-control call site.
-}
motionSegmented : Theme.Model -> Element { s | segmentedButton : M3e.Kind.Brand } admittedBy Msg
motionSegmented model =
    Theme.segmented
        (Value.motionValues
            |> List.map (\v -> ( Theme.capitalize (Value.toString v), model.motion == v, SetMotion v ))
        )


{-| Ported from Shared.elm's `densitySegmented` — mechanism (Tailwind
arbitrary-class on `<m3e-theme>`, via `densityClass`) is UNCHANGED; only its
LOCATION moves here. `densityClass` itself stays wherever `<m3e-theme>` is
rendered (the app-level Shared.elm's `view`, applied to the theme host
element, not this section's markup) — this function just fires
`SetDensity`, it doesn't compute the class.
-}
densitySegmented : Theme.Model -> Element { s | segmentedButton : M3e.Kind.Brand } admittedBy Msg
densitySegmented model =
    Theme.segmented
        [ ( "0", model.density == 0, SetDensity 0 )
        , ( "-1", model.density == -1, SetDensity -1 )
        , ( "-2", model.density == -2, SetDensity -2 )
        , ( "-3", model.density == -3, SetDensity -3 )
        ]
