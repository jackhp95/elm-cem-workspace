module NoMissingComponentApiNamesTest exposing (all)

import NoMissingComponentApiNames exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NoMissingComponentApiNames"
        [ test "M3e.Component.Button exposing component (bare, no required content) — no error" <|
            \() ->
                """module M3e.Component.Button exposing
    ( component
    , Is, Attrs, Content
    , Shape, shape, Size, size
    )


component : List (Attrs -> Attrs) -> List Content -> Is
component attrs children =
    something
"""
                    |> Review.Test.run (rule { componentNamespace = [ "M3e", "Component" ] })
                    |> Review.Test.expectNoErrors
        , test "M3e.Component.Dialog exposing component (record-arg, required content) — no error" <|
            \() ->
                """module M3e.Component.Dialog exposing
    ( component
    , Is, Attrs, Content
    )


component : { headline : Content } -> List (Attrs -> Attrs) -> List Content -> Is
component required attrs children =
    something
"""
                    |> Review.Test.run (rule { componentNamespace = [ "M3e", "Component" ] })
                    |> Review.Test.expectNoErrors
        , test "missing component — reports the missing ctor" <|
            \() ->
                """module M3e.Component.Button exposing (Is, Attrs, shape)

shape v =
    something
"""
                    |> Review.Test.run (rule { componentNamespace = [ "M3e", "Component" ] })
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`M3e.Component.Button` does not expose its constructor `component`"
                            , details =
                                [ "Every component module must expose its constructor, `component` — the single standard constructor every component emits (bare when nothing's required, record-arg when something is)."
                                , "This is normally emitted by the generator; a missing name means the module was hand-edited or produced by a stale generator. Regenerate the bindings."
                                ]
                            , under = "M3e.Component.Button"
                            }
                        ]
        , test "stale pre-four-package name (view) without component — still reports component missing" <|
            \() ->
                """module M3e.Component.Button exposing (view, variant)

view attrs children =
    something

variant v =
    something
"""
                    |> Review.Test.run (rule { componentNamespace = [ "M3e", "Component" ] })
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`M3e.Component.Button` does not expose its constructor `component`"
                            , details =
                                [ "Every component module must expose its constructor, `component` — the single standard constructor every component emits (bare when nothing's required, record-arg when something is)."
                                , "This is normally emitted by the generator; a missing name means the module was hand-edited or produced by a stale generator. Regenerate the bindings."
                                ]
                            , under = "M3e.Component.Button"
                            }
                        ]
        , test "multiword module name (SplitButton) — still must expose component, not a derived name" <|
            \() ->
                """module M3e.Component.SplitButton exposing
    ( component
    , Is, Attrs
    )


component attrs children =
    something
"""
                    |> Review.Test.run (rule { componentNamespace = [ "M3e", "Component" ] })
                    |> Review.Test.expectNoErrors
        , test "R-025 merged shape: exposes component PLUS the Builder/AttrCaps/SlotCaps aliases — extras tolerated, no error" <|
            \() ->
                -- The merged monorepo Component exposes the R-025 aliases
                -- (Builder/AttrCaps/SlotCaps) in addition to Is/Attrs/component.
                -- This rule guards only that `component` is PRESENT; extra exposed
                -- names must never false-positive.
                """module M3e.Component.AssistChip exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, IconSlot, ChildAdmittedBy
    , Type, type_, Variant, variant
    )


component : List (Attrs -> Attrs) -> List Content -> Is
component attrs children =
    something
"""
                    |> Review.Test.run (rule { componentNamespace = [ "M3e", "Component" ] })
                    |> Review.Test.expectNoErrors
        , test "non-M3e.Component module missing component — out of scope, no error" <|
            \() ->
                """module Docs.Whatever exposing (thing)

thing =
    something
"""
                    |> Review.Test.run (rule { componentNamespace = [ "M3e", "Component" ] })
                    |> Review.Test.expectNoErrors
        ]
