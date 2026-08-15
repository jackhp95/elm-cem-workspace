module Doc.Slider exposing (slidingPanels)

{-| A reusable **sliding-panel** helper for the docs app.

Given the 0-based index of the active panel and an ordered list of already-rendered
panels, `slidingPanels` mounts **all** panels side-by-side in a horizontal flex
track and translates the track by `activeIndex * 100%` so the active panel sits in
a clipping viewport while its neighbours are pushed off-screen. Switching the active
index re-drives the `transform`, and a CSS `transition` on the track animates the
slide (disabled under `prefers-reduced-motion` in `style.css`).

The viewport is the `<slide-panels>` custom element (`docs/../js/slide-panels.js`),
which uses a `ResizeObserver` on the active panel to keep the viewport's height in
lock-step with the active surface — so a short panel leaves no empty space and a
tall one is never clipped, and the height follows fold open/close. If
that element never upgrades, the viewport falls back to `height: auto` and still
shows the active panel correctly (the Elm-driven `transform` still applies).

The helper is deliberately generic (no knowledge of the API-surface `Layer` type),
so every tab UI in the docs can reuse the one implementation.

@docs slidingPanels

-}

import M3e exposing (Attr, Element)
import M3e.Kind
import M3e.Unsafe
import M3e.Unsafe.Attributes
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes as TA
import TypedHtml.Component.Grouping


{-| Mount `panels` in a sliding track, showing the one at `activeIndex`.

`activeIndex` is clamped to a valid position. A degenerate track (0 or 1 panel)
renders the single panel plainly — no viewport/track wrapper — so the slider only
appears when there is actually something to slide between.

-}
slidingPanels : Int -> List (Element childAccepts (TypedHtml.Component.Grouping.DivChildAdmittedBy childAdm) msg) -> Element (TypedHtml.Component.Grouping.DivIs r) freeAdm msg
slidingPanels activeIndex panels =
    case panels of
        [] ->
            TypedHtml.div [] []

        [ only ] ->
            -- Plain passthrough (a bare wrapper, no viewport/track): a single panel
            -- has nothing to slide against. The wrapper re-opens the phantom row so
            -- the one panel drops into any context the slider itself would.
            TypedHtml.div [] [ only ]

        _ ->
            let
                count : Int
                count =
                    List.length panels

                idx : Int
                idx =
                    clamp 0 (count - 1) activeIndex

                track : Element (TypedHtml.Component.Grouping.DivIs k) trackAdm msg
                track =
                    TypedHtml.div
                        [ TA.class "sp-track"
                        , TA.style "transform" ("translateX(-" ++ String.fromInt (idx * 100) ++ "%)")
                        ]
                        (List.indexedMap (panel idx) panels)
            in
            M3e.Unsafe.customElement "slide-panels"
                [ TA.class "sp-viewport"
                , M3e.Unsafe.Attributes.customAttribute "active-index" (String.fromInt idx)
                ]
                [ track ]


{-| One panel wrapper: inactive panels get `aria-hidden="true"` and `inert`.
-}
panel : Int -> Int -> Element childAccepts (TypedHtml.Component.Grouping.DivChildAdmittedBy childAdm) msg -> Element (TypedHtml.Component.Grouping.DivIs k) freeAdm msg
panel activeIndex i child =
    let
        inactive : Bool
        inactive =
            i /= activeIndex

        attrs : List (Attr { c | class : M3e.Kind.Supported, inert : M3e.Kind.Supported } msg)
        attrs =
            TA.class "sp-panel"
                :: Aria.hidden
                    (if inactive then
                        Aria.true

                     else
                        Aria.false
                    )
                :: (if inactive then
                        [ TA.inert True ]

                    else
                        []
                   )
    in
    TypedHtml.div attrs [ child ]
