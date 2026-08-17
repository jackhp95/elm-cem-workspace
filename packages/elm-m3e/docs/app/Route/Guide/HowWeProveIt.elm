module Route.Guide.HowWeProveIt exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/how-we-prove-it`): earned trust. Every example in
these docs starts as real component markup, is converted across forms,
compiled, rendered back to HTML, and diffed against the original. Where it drifts
or leans on an escape, that's a measured signal we track, not something hidden.
That's why you can copy any example here and trust it. The meta-chapter — no new
running-example beat.

Every figure on this page is derived at build time from the SAME source the
[`/guide/roundtrip`](/guide/roundtrip) report renders: `data/roundtrip-report.json`. Nothing
here is hand-typed, so the guide and the report can never drift apart. We headline
the **top** form (`M3e.Button.component` — the typed, slot-safe layer the guide
teaches first); the full per-form table lives on `/guide/roundtrip`.

-}

import BackendTask exposing (BackendTask)
import BackendTask.File
import Doc
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Json.Decode as Decode
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


{-| The headline form's round-trip breakdown, computed at build time from
`data/roundtrip-report.json` so this chapter and `/guide/roundtrip` share one source.

  - `total` — examples in the corpus (matches `/guide/roundtrip`'s denominator).
  - `converted` — of those, how many this API could express at all.
  - `cleanIdentity` — converted and round-tripped byte-for-byte.
  - `allowedAlias` — round-tripped with cosmetic-only deviations (functionally
    identical output; e.g. an added `role="group"`). Counted, not hidden.
  - `functionalDrift` — a real, functional mismatch. This is the number that
    must stay honest.

-}
type alias Data =
    { total : Int
    , converted : Int
    , cleanIdentity : Int
    , allowedAlias : Int
    , functionalDrift : Int
    }


type alias ActionData =
    {}


{-| The surface we headline: `M3e.Button.component` — the standard form the guide
teaches first. Its per-surface aggregate is the one we render into the report.
(The `perSurface` JSON keys this aggregate `"top"` — a data-file key, not a
"layer"; the vocabulary is [the surface map](/guide/the-layers).)
-}
headlineSurface : String
headlineSurface =
    "top"


{-| Decode one surface's aggregate from `perSurface` into the four honest
buckets. `clean identity` = strict matches; `allowed alias` = functional matches
that were not strict matches (cosmetic-only); `functional drift` = functional
deviations.
-}
dataDecoder : Decode.Decoder Data
dataDecoder =
    Decode.at [ "perSurface", headlineSurface ]
        (Decode.map5
            (\total converted strictMatched funcMatched funcDeviated ->
                { total = total
                , converted = converted
                , cleanIdentity = strictMatched
                , allowedAlias = funcMatched - strictMatched
                , functionalDrift = funcDeviated
                }
            )
            (Decode.field "total" Decode.int)
            (Decode.field "converted" Decode.int)
            (Decode.field "roundtripMatched" Decode.int)
            (Decode.field "roundtripFunctionalMatched" Decode.int)
            (Decode.field "roundtripFunctionalDeviated" Decode.int)
        )


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.File.jsonFile dataDecoder "data/roundtrip-report.json"
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "Every example in these docs is converted across forms, rendered back to HTML, and diffed against the original — so you can copy any of them and trust it."
        , locale = Nothing
        , title = "How we prove it · elm-m3e"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    View.fromElement "How we prove it"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "How we prove it"
                    , TypedHtml.div [ TA.class "max-w-2xl text-on-surface-variant" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown loop
                    , Doc.codeBlock Doc.NoLang (report app.data)
                    , TypedHtml.div [ TA.class "max-w-2xl text-on-surface-variant" ] [ Doc.markdown reportNote ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown alias ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown (honest app.data) ]
                , Doc.recapBox (recap app.data)
                ]
            ]
        )


intro : String
intro =
    """You've followed a lot of examples. Here's why you can trust them: they aren't hand-waved. Every example in these docs is checked by machine against the real components — the same check that guards the library itself."""


loop : String
loop =
    """The loop is simple. Each example starts as real component markup. It's converted to every layer/form — the standard top, the strict shapes, the raw floor — and each version is compiled. Then it's rendered **back** to HTML and diffed against the original markup it came from. If a form can't reproduce the original, or reproduces it only by leaning on an escape, that's a *measured* number we track — not something we bury. The corpus is the same one the [round-trip report](/guide/roundtrip) scores; the figures below are read straight out of that report at build time. Here's the **top** form — the `M3e.*` this guide teaches:"""


{-| The ASCII report, filled in from build-time data. The four lines always sum to
`total`: cleanIdentity + allowedAlias + functionalDrift + (total − converted).
-}
report : Data -> String
report d =
    let
        n : Int -> String
        n =
            String.fromInt

        notConverted : Int
        notConverted =
            d.total - d.converted
    in
    "round-trip (top form): "
        ++ n d.total
        ++ " examples checked\n"
        ++ "  · clean identity ......... "
        ++ n d.cleanIdentity
        ++ "   (rendered back byte-for-byte)\n"
        ++ "  · allowed alias .......... "
        ++ n d.allowedAlias
        ++ "   (cosmetic-only; same output)\n"
        ++ "  · not expressible here ... "
        ++ n notConverted
        ++ "   (needs another form)\n"
        ++ "  · unexpected drift ....... "
        ++ n d.functionalDrift
        ++ "   (real functional mismatch)"


reportNote : String
reportNote =
    """Those four buckets sum to the whole corpus. The denominator (the total above) is the **same count of examples the [round-trip report](/guide/roundtrip) uses** — one example is one HTML snippet, checked once per form. Other forms express more or fewer of them and drift by different amounts; the report has the full table. We headline `top` because it's the form the guide leads with, not because it's the best-scoring."""


{-| Chapter body: what an "allowed alias" is, with a concrete worked example
pulled straight from the report so the distinction can't be hand-waved.
-}
alias : String
alias =
    """**What counts as an "allowed alias"?** Not everything that comes back different is drift. When we render an example back to HTML, some differences are *cosmetic*: the browser or the component's own template adds an attribute that doesn't change what the component *does* or *shows*. We record those, mark them cosmetic, and set them aside from the honest-drift count.

Here's a real one from the run. The **Autocomplete** example (`Autocomplete/8`) is authored without an ARIA role on its option list. When m3e renders it back, the component adds `role="group"` itself:

```
- <div class="options">…</div>          (authored)
+ <div class="options" role="group">…</div>   (round-tripped)
```

The output is functionally identical — same element, same children, same behavior; the platform just annotated it. That's an **allowed alias**: counted in the `allowed alias` line, never in `unexpected drift`. Contrast it with a *functional* deviation — a dropped `filter="starts-with"` attribute that actually changes matching behavior. That one lands in `unexpected drift`, in red, at the top of the [round-trip report](/guide/roundtrip)."""


{-| The honest close, wired to the real drift number so it can never overclaim.
-}
honest : Data -> String
honest d =
    let
        driftClause : String
        driftClause =
            if d.functionalDrift == 0 then
                "On this run the standard surface reproduced every convertible example with **zero unexpected drift** — every difference was a counted, cosmetic alias."

            else
                "On this run the standard surface has **"
                    ++ String.fromInt d.functionalDrift
                    ++ " example(s) of unexpected drift** — real functional mismatches, shown in red at the top of the [round-trip report](/guide/roundtrip). We don't paper over them; we rank them first."
    in
    """The number that matters is the last line: **unexpected drift.** """
        ++ driftClause
        ++ """ Where a value takes a known, allowed shape-change on the way back — a slot setter that round-trips to an equivalent name, an ARIA role the platform adds — it's counted and labeled, not hidden. That honesty is the point: the docs don't claim perfection, they *measure* faithfulness and show the measurement. So when you copy an example from any page here, you're copying code that was rendered back to HTML and checked against the real component. It works because it was proven to — and if it ever stops, the [report](/guide/roundtrip) says so before you find out the hard way."""


recap : Data -> String
recap d =
    let
        driftLine : String
        driftLine =
            if d.functionalDrift == 0 then
                "**0 unexpected drift** on the standard surface"

            else
                "**"
                    ++ String.fromInt d.functionalDrift
                    ++ " unexpected drift** on the standard surface — tracked, ranked first, never hidden"
    in
    """- Every example is converted across forms, **rendered back to HTML, and diffed** against the original.
- Drift and escapes are **measured and tracked**, not hidden — this run: """
        ++ driftLine
        ++ """.
- That's why you can **copy any example here and trust it**.
- You've finished the Guide — you can build a real Material 3 UI where invalid states don't compile, and you know exactly what to do when you need to break the rules."""
