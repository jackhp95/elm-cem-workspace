module RequireSlotTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.RequireSlot exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| A component whose default slot is BOTH required and repeatable (required-multi): the
type system can't enforce it, so the rule must.
-}
facts : List Facts.Fact
facts =
    [ { component = "grid"
      , module_ = "M3e.Grid"
      , enums = []
      , requiredSlots = [ "default" ]
      , multiSlots = [ "default" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


shape4Facts : List Facts.Fact
shape4Facts =
    [ { component = "grid"
      , module_ = "M3e.Grid"
      , enums = []
      , requiredSlots = [ "default" ]
      , multiSlots = [ "default" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard, Record ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


{-| A component whose default slot is required but NOT repeatable (required-singular):
the constructor's required record already type-enforces it, so this rule intentionally
skips it — `buildIndex` intersects requiredSlots with multiSlots, leaving nothing here.
-}
requiredSingularFacts : List Facts.Fact
requiredSingularFacts =
    [ { component = "grid"
      , module_ = "M3e.Grid"
      , enums = []
      , requiredSlots = [ "default" ]
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


{-| A component with a required-multi DEFAULT slot AND a named `caption` slot.
Exercises the raw-default-child vs named-slot-setter discrimination: the default
slot is filled by raw children, not by the named `caption` setter.
-}
namedSlotFacts : List Facts.Fact
namedSlotFacts =
    [ { component = "gallery"
      , module_ = "M3e.Gallery"
      , enums = []
      , requiredSlots = [ "unnamed" ]
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = [ ( "unnamed", "child" ), ( "caption", "caption" ) ]
      , slotKinds = [ ( "unnamed", [] ), ( "caption", [ "text" ] ) ]
      , slotUpgrades = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


{-| REAL-SHAPED facts: `module_` carries the `.Component.` segment like the generated
`M3e.Review.Facts` (`"M3e.Component.Grid"`). A BARREL call (`M3e.grid`, resolved under
namespace `["M3e"]` → `siteKey = "M3e\0grid"`) only resolves against the barrel-alias
key `Cem.Internal.Facts.buildIndex` inserts. A private `factKey`-only index holds only
`"M3e.Component\0grid"` → barrel MISS → the rule is DEAD. The flat `M3e.Grid` fixtures
above cannot express this (flat `module_` ⇒ `factKey == siteKey`), which is why the
barrel bug hid behind green tests.
-}
realShapeFacts : List Facts.Fact
realShapeFacts =
    [ { component = "grid"
      , module_ = "M3e.Component.Grid"
      , enums = []
      , requiredSlots = [ "default" ]
      , multiSlots = [ "default" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


{-| REAL-SHAPED four-package facts for a component whose default slot is
required-multi: `M3e.Component.Select` (`requiredSlots = multiSlots = [ "unnamed" ]`,
no separate required-singular field). Mirrors the generated `component`:
`component required_ attrs children = H.select attrs (required_.content :: children)`
— i.e. the default slot's content is threaded through the LEADING record's
`content` field, not the trailing content list, even though it's required-multi
(not required-singular). This is the exact shape that produced the 27 false
`RequireSlot` errors in elm-m3e's `check:review` (slider/segmentedButton/select
call sites filled only through the record).
-}
elUnifiedFacts : List Facts.Fact
elUnifiedFacts =
    [ { component = "select"
      , module_ = "M3e.Component.Select"
      , enums = []
      , requiredSlots = [ "unnamed" ]
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


all : Test
all =
    describe "RequireSlot"
        [ test "accepts a required-multi default slot filled only through the leading record's `content` field (four-package `component`)" <|
            \() ->
                -- Regression for the false-positive this rule produced on real
                -- generated call sites: `M3e.select { content = ... } [] []` DOES
                -- fill the default slot — via the record, not the trailing list.
                """module A exposing (v)

import M3e exposing (select)
import M3e.Component.Option exposing (option)

v =
    select { content = option [] [] } [] []
"""
                    |> Review.Test.run (rule elUnifiedFacts)
                    |> Review.Test.expectNoErrors
        , test "still flags a required-multi default slot when BOTH the record's content and the trailing list are effectively empty of it" <|
            \() ->
                -- The record's `content` field is required by Elm's type system to be
                -- an Element, so it can never itself be "absent" the way the trailing
                -- list can — this test instead pins that resolving the record doesn't
                -- accidentally silence a genuinely-unfillable case: a dynamically-built
                -- record (unresolved) with an empty trailing list stays silent (opaque),
                -- not falsely green from assuming a record must exist.
                """module A exposing (v)

import M3e exposing (select)

v =
    select someDynamicRecord [] []
"""
                    |> Review.Test.run (rule elUnifiedFacts)
                    |> Review.Test.expectNoErrors
        , test "flags an unfilled required-multi slot on a BARREL call with real-shaped facts (module_ = M3e.Component.Grid)" <|
            \() ->
                -- Regression for the barrel-alias index bug. RED against a private
                -- `factKey`-only index (barrel call does not resolve → no error);
                -- GREEN once `buildIndex` derives from `Facts.buildIndex`.
                """module A exposing (v)

import M3e exposing (grid)

v =
    grid [] []
"""
                    |> Review.Test.run (rule realShapeFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Required slot `child` is not filled"
                            , details =
                                [ "This component needs at least one `child` in its content list, but none is present."
                                , "This is a repeatable required slot, so the type system doesn't enforce it — add the missing content."
                                ]
                            , under = "grid"
                            }
                            |> Review.Test.atExactly { start = { row = 6, column = 5 }, end = { row = 6, column = 9 } }
                        ]
        , test "flags a required-multi slot with an empty content list" <|
            \() ->
                """module A exposing (v)

import M3e exposing (grid)

v =
    grid [] []
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Required slot `child` is not filled"
                            , details =
                                [ "This component needs at least one `child` in its content list, but none is present."
                                , "This is a repeatable required slot, so the type system doesn't enforce it — add the missing content."
                                ]
                            , under = "grid"
                            }
                            |> Review.Test.atExactly { start = { row = 6, column = 5 }, end = { row = 6, column = 9 } }
                        ]
        , test "accepts a filled required slot" <|
            \() ->
                """module A exposing (v)

import M3e exposing (grid, child)

v =
    grid [] [ child a ]
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , test "recognises a raw default child (another component's view) as filling the default slot" <|
            \() ->
                -- The top-layer idiom: raw children live directly in the content
                -- list, NOT wrapped in an explicit `child` setter.
                """module A exposing (v)

import M3e exposing (grid)
import M3e.Thumb

v =
    grid [] [ M3e.Thumb.component [] [] ]
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , test "a raw default child alongside a named-slot setter fills the default slot" <|
            \() ->
                """module A exposing (v)

import M3e.Gallery
import M3e.Photo

v =
    M3e.Gallery.component [] [ M3e.Gallery.caption cap, M3e.Photo.component [] [] ]
"""
                    |> Review.Test.run (rule namedSlotFacts)
                    |> Review.Test.expectNoErrors
        , test "a content list with ONLY a named-slot setter still flags the empty default slot" <|
            \() ->
                """module A exposing (v)

import M3e.Gallery

v =
    M3e.Gallery.component [] [ M3e.Gallery.caption cap ]
"""
                    |> Review.Test.run (rule namedSlotFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Required slot `child` is not filled"
                            , details =
                                [ "This component needs at least one `child` in its content list, but none is present."
                                , "This is a repeatable required slot, so the type system doesn't enforce it — add the missing content."
                                ]
                            , under = "M3e.Gallery.component"
                            }
                        ]
        , test "stays silent when content is built dynamically (List.map)" <|
            \() ->
                """module A exposing (v)

import M3e exposing (grid, child)

v =
    grid [] (List.map child items)
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , test "flags a required-multi slot omission at Record call site" <|
            \() ->
                """module A exposing (v)

import M3e.Record.Grid

v =
    M3e.Record.Grid.component {} [] []
"""
                    |> Review.Test.run (rule shape4Facts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Required slot `child` is not filled"
                            , details =
                                [ "This component needs at least one `child` in its content list, but none is present."
                                , "This is a repeatable required slot, so the type system doesn't enforce it — add the missing content."
                                ]
                            , under = "M3e.Record.Grid.component"
                            }
                        ]
        , test "accepts a filled required-multi slot at Record call site" <|
            \() ->
                """module A exposing (v)

import M3e.Record.Grid
import M3e exposing (child)

v =
    M3e.Record.Grid.component {} [] [ child a ]
"""
                    |> Review.Test.run (rule shape4Facts)
                    |> Review.Test.expectNoErrors
        , test "traces through List.map at a Record call site and stays silent" <|
            \() ->
                """module A exposing (v)

import M3e.Record.Grid
import M3e exposing (child)

v =
    M3e.Record.Grid.component {} [] (List.map child items)
"""
                    |> Review.Test.run (rule shape4Facts)
                    |> Review.Test.expectNoErrors
        , test "does not flag a required slot that is not multi (type-enforced elsewhere)" <|
            \() ->
                -- required-singular: the constructor's required record already enforces
                -- presence, so this rule stays silent even with an empty content list.
                """module A exposing (v)

import M3e exposing (grid)

v =
    grid [] []
"""
                    |> Review.Test.run (rule requiredSingularFacts)
                    |> Review.Test.expectNoErrors
        , test "stays silent for a partially-applied constructor (not enough args)" <|
            \() ->
                -- `grid []` is not fully applied (no content list yet); the rule only
                -- checks calls with the content argument present (>= 2 args).
                """module A exposing (v)

import M3e exposing (grid)

v =
    grid []
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        ]
