module RealFactsShapeTest exposing (all)

{-| Rule-agnostic guards that the facts-index machinery works on data shaped like
REAL generated facts (the `RealFactsFixture` verbatim snapshot), plus two
rule-level checks that a BARREL call resolves against the real-shaped facts.

This is the invariant the barrel-alias bug violated four times: a component fact
whose `module_` is `"M3e.Component.<X>"` must be reachable from a barrel call site
(`M3e.<x>`, whose `siteKey` is `"M3e\u{0000}<x>"`), and the ONLY index construction
that guarantees this is `Cem.Internal.Facts.buildIndex` (it inserts the barrel-alias
key alongside the `factKey`). A rule that rolls a private `factKey`-only index fails
these checks on real-shaped facts while passing flat-fixture unit tests.

Also tests the GENERIC intermediate-segment guard: a fact whose `module_` uses a
NEW synthetic intermediate segment (`"Layout"`, never previously in the allowlist)
must ALSO get a barrel-alias key. This is the specific regression class fixed in
the `p3-barrel-segment-guard` branch — a hardcoded allowlist would miss it.

@docs all

-}

import Cem.Internal.Facts as Facts
import Cem.RequireSlot
import Cem.SingularSlot
import Dict
import Expect
import RealFactsFixture
import Review.Test
import Test exposing (Test, describe, test)


{-| The null-separated barrel-alias key a barrel call site resolves to.
-}
barrelKey : String -> String
barrelKey noun =
    "M3e\u{0000}" ++ noun


{-| The null-separated per-component `factKey`.
-}
componentKey : String -> String
componentKey noun =
    "M3e.Component\u{0000}" ++ noun


all : Test
all =
    describe "RealFactsShape (verbatim generated-facts snapshot)"
        [ test "canonical buildIndex carries the barrel-alias key for every real .Component. fact" <|
            \() ->
                let
                    keys =
                        Facts.buildIndex RealFactsFixture.facts |> Dict.keys

                    required =
                        [ barrelKey "accordion"
                        , barrelKey "appBar"
                        , barrelKey "button"
                        , componentKey "accordion"
                        , componentKey "appBar"
                        , componentKey "button"
                        ]
                in
                required
                    |> List.filter (\k -> not (List.member k keys))
                    |> Expect.equalLists []
        , test "RequireSlot fires on a BARREL call against verbatim real accordion facts (required-multi default slot)" <|
            \() ->
                -- accordion: requiredSlots ∩ multiSlots = ["unnamed"] → setter "child".
                -- A private factKey-only index would MISS the barrel siteKey and stay dead.
                """module A exposing (v)

import M3e exposing (accordion)

v =
    accordion [] []
"""
                    |> Review.Test.run (Cem.RequireSlot.rule RealFactsFixture.facts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Required slot `child` is not filled"
                            , details =
                                [ "This component needs at least one `child` in its content list, but none is present."
                                , "This is a repeatable required slot, so the type system doesn't enforce it — add the missing content."
                                ]
                            , under = "accordion"
                            }
                            |> Review.Test.atExactly { start = { row = 6, column = 5 }, end = { row = 6, column = 14 } }
                        ]
        , test "SingularSlot fires on a BARREL call against verbatim real appBar facts (title is singular)" <|
            \() ->
                -- appBar multiSlots = ["leading","trailing"]; `title` is NOT multi, so a
                -- repeated `title` is a bug the rule must flag — via the barrel alias.
                """module A exposing (v)

import M3e exposing (appBar, title)

v =
    appBar [] [ title a, title b ]
"""
                    |> Review.Test.run (Cem.SingularSlot.rule RealFactsFixture.facts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Singular slot `title` is filled more than once"
                            , details =
                                [ "This slot renders a single element, but it's set multiple times here — the extra will silently win or be dropped."
                                , "Keep one, or (if this component genuinely repeats the slot) it should be in the multi set — check the component's slot config."
                                ]
                            , under = "title a"
                            }
                        ]
        , describe "generic intermediate-segment guard (p3-barrel-segment-guard regression)"
            [ test "buildIndex carries barrel-alias key for a SYNTHETIC .Layout. fact (not in old Component/Build allowlist)" <|
                \() ->
                    -- This test FAILS against the old hardcoded barrelNamespaceParts
                    -- (which only recognised "Component" and "Build") and PASSES after
                    -- the generic fix. The barrel-alias key "M3e\u{0000}card" must exist
                    -- so that a barrel call site (module M3e, noun "card") resolves.
                    let
                        index =
                            Facts.buildIndex RealFactsFixture.syntheticLayoutFacts

                        keys =
                            Dict.keys index
                    in
                    Expect.equalLists []
                        (List.filter (\k -> not (List.member k keys))
                            [ "M3e.Layout\u{0000}card" -- canonical factKey
                            , "M3e\u{0000}card" -- barrel-alias key — MISSING before the fix
                            ]
                        )
            , test "namespaces includes barrel root [M3e] for a SYNTHETIC .Layout. fact" <|
                \() ->
                    -- namespaces must return both ["M3e","Layout"] and ["M3e"] so
                    -- callSite resolution can match a barrel call (module = M3e).
                    let
                        ns =
                            Facts.namespaces RealFactsFixture.syntheticLayoutFacts
                    in
                    Expect.equalLists []
                        (List.filter (\n -> not (List.member n ns))
                            [ [ "M3e", "Layout" ]
                            , [ "M3e" ]
                            ]
                        )
            ]
        ]
