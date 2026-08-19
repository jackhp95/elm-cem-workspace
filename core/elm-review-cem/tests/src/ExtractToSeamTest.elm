module ExtractToSeamTest exposing (all)

import ExtractToSeam exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| Config targeting `M3e.Unsafe.{recast,recastAll}` and
`M3e.Unsafe.Attributes.{recastAttr,recastAttrAll}`, lifting into the userland
`Recast` module.
-}
config :
    { recastModule : String
    , escapes : List ( String, List String )
    , allowedModules : List String
    }
config =
    { recastModule = "Recast"
    , escapes =
        [ ( "M3e.Unsafe", [ "recast", "recastAll" ] )
        , ( "M3e.Unsafe.Attributes", [ "recastAttr", "recastAttrAll" ] )
        ]
    , allowedModules = [ "Recast", "Native", "Layout" ]
    }


{-| A minimal `Recast` module (the destination). Has one placeholder declaration
so `declInsertAt` is non-Nothing (the rule inserts lifted fns after the last decl).
The `(..)` exposing means `needsExpose` is always false (exposingAll=True).
-}
recastModule : String
recastModule =
    """module Recast exposing (..)


placeholder : ()
placeholder =
    ()
"""


{-| A `Recast` module that already has one lifted helper — used for convergence
tests where Feature imports Recast and calls Recast.recastRecast (not M3e.Unsafe).
-}
recastModuleWithRecastRecast : String
recastModuleWithRecastRecast =
    """module Recast exposing (..)
import M3e.Unsafe


placeholder : ()
placeholder =
    ()


recastRecast el_ =
    M3e.Unsafe.recast el_
"""


{-| A minimal `M3e.Unsafe` module with the element-side escapes.
-}
m3eUnsafeModule : String
m3eUnsafeModule =
    """module M3e.Unsafe exposing (recast, recastAll)


recast : a -> b
recast x =
    Debug.todo "escape"


recastAll : List a -> List b
recastAll xs =
    Debug.todo "escape"
"""


{-| A minimal `M3e.Unsafe.Attributes` module with the attribute-side escapes.
-}
m3eUnsafeAttributesModule : String
m3eUnsafeAttributesModule =
    """module M3e.Unsafe.Attributes exposing (recastAttr, recastAttrAll)


recastAttr : a -> b
recastAttr x =
    Debug.todo "escape"


recastAttrAll : List a -> List b
recastAttrAll xs =
    Debug.todo "escape"
"""


{-| A header-only `Recast` module — the real first-adoption scaffold: a team
creates an empty destination and runs `--fix` to populate it. `declInsertAt`
has no declaration to anchor after, and (since there are no imports either)
`importInsertAt` falls back to the same location — this is the regression
case for the dropped-insertion bug.
-}
recastModuleEmpty : String
recastModuleEmpty =
    """module Recast exposing (..)
"""


all : Test
all =
    describe "ExtractToSeam (retargeted to M3e.Unsafe recast escapes)"
        [ test "lifts a simple M3e.Unsafe.recast call into Recast and rewrites the call site" <|
            \() ->
                [ """module Feature exposing (v)

import M3e.Unsafe


v el_ =
    M3e.Unsafe.recast el_
"""
                , recastModule
                , m3eUnsafeModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`M3e.Unsafe.recast` escape can be lifted into `Recast.recastRecast`"
                                , details =
                                    [ "This `M3e.Unsafe.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Recast` as `recastRecast` and rewrites this call site to `Recast.recastRecast`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Recast` function is never re-extracted."
                                    ]
                                , under = "M3e.Unsafe.recast el_"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import M3e.Unsafe
import Recast


v el_ =
    Recast.recastRecast el_
""" )
                                    , ( "Recast", """module Recast exposing (..)
import M3e.Unsafe


placeholder : ()
placeholder =
    ()


recastRecast el_ =
    M3e.Unsafe.recast el_
""" )
                                    ]
                            ]
                          )
                        ]
        , test "lifts M3e.Unsafe.recastAll into Recast" <|
            \() ->
                [ """module Feature exposing (v)

import M3e.Unsafe


v xs =
    M3e.Unsafe.recastAll xs
"""
                , recastModule
                , m3eUnsafeModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`M3e.Unsafe.recastAll` escape can be lifted into `Recast.recastRecastAll`"
                                , details =
                                    [ "This `M3e.Unsafe.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Recast` as `recastRecastAll` and rewrites this call site to `Recast.recastRecastAll`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Recast` function is never re-extracted."
                                    ]
                                , under = "M3e.Unsafe.recastAll xs"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import M3e.Unsafe
import Recast


v xs =
    Recast.recastRecastAll xs
""" )
                                    , ( "Recast", """module Recast exposing (..)
import M3e.Unsafe


placeholder : ()
placeholder =
    ()


recastRecastAll xs =
    M3e.Unsafe.recastAll xs
""" )
                                    ]
                            ]
                          )
                        ]
        , test "lifts M3e.Unsafe.Attributes.recastAttr into Recast" <|
            \() ->
                [ """module Feature exposing (v)

import M3e.Unsafe.Attributes


v a =
    M3e.Unsafe.Attributes.recastAttr a
"""
                , recastModule
                , m3eUnsafeAttributesModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`M3e.Unsafe.Attributes.recastAttr` escape can be lifted into `Recast.recastRecastAttr`"
                                , details =
                                    [ "This `M3e.Unsafe.Attributes.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Recast` as `recastRecastAttr` and rewrites this call site to `Recast.recastRecastAttr`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Recast` function is never re-extracted."
                                    ]
                                , under = "M3e.Unsafe.Attributes.recastAttr a"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import M3e.Unsafe.Attributes
import Recast


v a =
    Recast.recastRecastAttr a
""" )
                                    , ( "Recast", """module Recast exposing (..)
import M3e.Unsafe.Attributes


placeholder : ()
placeholder =
    ()


recastRecastAttr a =
    M3e.Unsafe.Attributes.recastAttr a
""" )
                                    ]
                            ]
                          )
                        ]
        , test "lifts M3e.Unsafe.Attributes.recastAttrAll into Recast" <|
            \() ->
                [ """module Feature exposing (v)

import M3e.Unsafe.Attributes


v attrs =
    M3e.Unsafe.Attributes.recastAttrAll attrs
"""
                , recastModule
                , m3eUnsafeAttributesModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`M3e.Unsafe.Attributes.recastAttrAll` escape can be lifted into `Recast.recastRecastAttrAll`"
                                , details =
                                    [ "This `M3e.Unsafe.Attributes.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Recast` as `recastRecastAttrAll` and rewrites this call site to `Recast.recastRecastAttrAll`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Recast` function is never re-extracted."
                                    ]
                                , under = "M3e.Unsafe.Attributes.recastAttrAll attrs"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import M3e.Unsafe.Attributes
import Recast


v attrs =
    Recast.recastRecastAttrAll attrs
""" )
                                    , ( "Recast", """module Recast exposing (..)
import M3e.Unsafe.Attributes


placeholder : ()
placeholder =
    ()


recastRecastAttrAll attrs =
    M3e.Unsafe.Attributes.recastAttrAll attrs
""" )
                                    ]
                            ]
                          )
                        ]
        , test "arg-threading: captured local becomes a parameter threaded at the call site" <|
            \() ->
                [ """module Feature exposing (v)

import M3e.Unsafe


v chip_ =
    M3e.Unsafe.recast chip_
"""
                , recastModule
                , m3eUnsafeModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`M3e.Unsafe.recast` escape can be lifted into `Recast.recastRecast`"
                                , details =
                                    [ "This `M3e.Unsafe.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Recast` as `recastRecast` and rewrites this call site to `Recast.recastRecast`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Recast` function is never re-extracted."
                                    ]
                                , under = "M3e.Unsafe.recast chip_"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import M3e.Unsafe
import Recast


v chip_ =
    Recast.recastRecast chip_
""" )
                                    , ( "Recast", """module Recast exposing (..)
import M3e.Unsafe


placeholder : ()
placeholder =
    ()


recastRecast chip_ =
    M3e.Unsafe.recast chip_
""" )
                                    ]
                            ]
                          )
                        ]
        , test "convergence: a call already using Recast.recastRecast is not re-extracted" <|
            \() ->
                [ """module Feature exposing (v)

import Recast


v el_ =
    Recast.recastRecast el_
"""
                , recastModuleWithRecastRecast
                , m3eUnsafeModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectNoErrors
        , test "does not fire inside an allowed module (Native)" <|
            \() ->
                [ """module Native exposing (v)

import M3e.Unsafe


v el_ =
    M3e.Unsafe.recast el_
"""
                , recastModule
                , m3eUnsafeModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectNoErrors
        , test "does not fire inside an allowed module (Layout)" <|
            \() ->
                [ """module Layout.Core exposing (v)

import M3e.Unsafe


v el_ =
    M3e.Unsafe.recast el_
"""
                , recastModule
                , m3eUnsafeModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectNoErrors
        , test "convergence (call site): Feature calling Recast.recastRecast is not re-extracted" <|
            -- After a --fix pass, Feature calls Recast.recastRecast (not M3e.Unsafe.recast).
            -- Recast is in allowedModules, so Feature is no longer gated — no error.
            \() ->
                [ """module Feature exposing (v)

import Recast


v el_ =
    Recast.recastRecast el_
"""
                , recastModuleWithRecastRecast
                , m3eUnsafeModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectNoErrors
        , test "punted fixless: point-free List.map M3e.Unsafe.recast → plain error, no fix" <|
            \() ->
                [ """module Feature exposing (v)

import M3e.Unsafe


v xs =
    List.map M3e.Unsafe.recast xs
"""
                , recastModule
                , m3eUnsafeModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`M3e.Unsafe.recast` is used point-free and cannot be auto-extracted"
                                , details =
                                    [ "This is a bare (point-free) reference to an escape function rather than an applied escape expression, so there is nothing self-contained to lift."
                                    , "Refactor it into an applied escape, or lift the surrounding expression into the recast module by hand."
                                    ]
                                , under = "M3e.Unsafe.recast"
                                }
                            ]
                          )
                        ]
        , test "punted fixless: lambda capture inside the escape → plain error, no fix" <|
            \() ->
                [ """module Feature exposing (v)

import M3e.Unsafe


v items =
    M3e.Unsafe.recast (List.map (\\x -> x) items)
"""
                , recastModule
                , m3eUnsafeModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`M3e.Unsafe.recast` escape cannot be auto-extracted"
                                , details =
                                    [ "This escape captures a value bound by a let/case/lambda/record-update inside the escape, so `ExtractToSeam` will not emit a fix that could be wrong."
                                    , "Lift it into the recast module by hand (as a named function taking the captured values as arguments), then use it here."
                                    ]
                                , under = "M3e.Unsafe.recast (List.map (\\x -> x) items)"
                                }
                            ]
                          )
                        ]
        , test "de-duplicates identical escapes: two call sites share one lifted function" <|
            \() ->
                [ """module Feature exposing (a, b)

import M3e.Unsafe


a el_ =
    M3e.Unsafe.recast el_


b el_ =
    M3e.Unsafe.recast el_
"""
                , recastModule
                , m3eUnsafeModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`M3e.Unsafe.recast` escape can be lifted into `Recast.recastRecast`"
                                , details =
                                    [ "This `M3e.Unsafe.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Recast` as `recastRecast` and rewrites this call site to `Recast.recastRecast`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Recast` function is never re-extracted."
                                    ]
                                , under = "M3e.Unsafe.recast el_"
                                }
                                |> Review.Test.atExactly { start = { row = 7, column = 5 }, end = { row = 7, column = 26 } }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (a, b)

import M3e.Unsafe
import Recast


a el_ =
    Recast.recastRecast el_


b el_ =
    Recast.recastRecast el_
""" )
                                    , ( "Recast", """module Recast exposing (..)
import M3e.Unsafe


placeholder : ()
placeholder =
    ()


recastRecast el_ =
    M3e.Unsafe.recast el_
""" )
                                    ]
                            ]
                          )
                        ]
        , test "no duplicate import: call-site already imports Recast" <|
            -- If the call-site module already has `import Recast`, the fix must NOT
            -- add a second one (guard: callSiteAlreadyImportsRecast = True).
            \() ->
                [ """module Feature exposing (v)

import M3e.Unsafe
import Recast


v el_ =
    M3e.Unsafe.recast el_
"""
                , recastModule
                , m3eUnsafeModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`M3e.Unsafe.recast` escape can be lifted into `Recast.recastRecast`"
                                , details =
                                    [ "This `M3e.Unsafe.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Recast` as `recastRecast` and rewrites this call site to `Recast.recastRecast`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Recast` function is never re-extracted."
                                    ]
                                , under = "M3e.Unsafe.recast el_"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import M3e.Unsafe
import Recast


v el_ =
    Recast.recastRecast el_
""" )
                                    , ( "Recast", """module Recast exposing (..)
import M3e.Unsafe


placeholder : ()
placeholder =
    ()


recastRecast el_ =
    M3e.Unsafe.recast el_
""" )
                                    ]
                            ]
                          )
                        ]
        , test "empty destination (first adoption): element-side escape lifts into a header-only Recast module" <|
            \() ->
                [ """module Feature exposing (v)

import M3e.Unsafe


v el_ =
    M3e.Unsafe.recast el_
"""
                , recastModuleEmpty
                , m3eUnsafeModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`M3e.Unsafe.recast` escape can be lifted into `Recast.recastRecast`"
                                , details =
                                    [ "This `M3e.Unsafe.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Recast` as `recastRecast` and rewrites this call site to `Recast.recastRecast`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Recast` function is never re-extracted."
                                    ]
                                , under = "M3e.Unsafe.recast el_"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import M3e.Unsafe
import Recast


v el_ =
    Recast.recastRecast el_
""" )
                                    , ( "Recast", """module Recast exposing (..)
import M3e.Unsafe


recastRecast el_ =
    M3e.Unsafe.recast el_
""" )
                                    ]
                            ]
                          )
                        ]
        , test "empty destination (first adoption): attribute-side escape lifts into a header-only Recast module" <|
            \() ->
                [ """module Feature exposing (v)

import M3e.Unsafe.Attributes


v a =
    M3e.Unsafe.Attributes.recastAttr a
"""
                , recastModuleEmpty
                , m3eUnsafeAttributesModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`M3e.Unsafe.Attributes.recastAttr` escape can be lifted into `Recast.recastRecastAttr`"
                                , details =
                                    [ "This `M3e.Unsafe.Attributes.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Recast` as `recastRecastAttr` and rewrites this call site to `Recast.recastRecastAttr`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Recast` function is never re-extracted."
                                    ]
                                , under = "M3e.Unsafe.Attributes.recastAttr a"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import M3e.Unsafe.Attributes
import Recast


v a =
    Recast.recastRecastAttr a
""" )
                                    , ( "Recast", """module Recast exposing (..)
import M3e.Unsafe.Attributes


recastRecastAttr a =
    M3e.Unsafe.Attributes.recastAttr a
""" )
                                    ]
                            ]
                          )
                        ]
        ]
