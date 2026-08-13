module ExtractToSeamTest exposing (all)

import ExtractToSeam exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


config : { seamModule : String, allowedModules : List String }
config =
    { seamModule = "Seam", allowedModules = [ "Native", "Layout" ] }


{-| A tiny stand-in for `Html.Attributes` so `class` resolves to an imported
module (not a free variable) inside the test project.
-}
attrModule : String
attrModule =
    """module Attr exposing (class)


class : String -> Int
class _ =
    0
"""


{-| A tiny seam module with one primitive escape (`asAttribute`).
-}
seamModule : String
seamModule =
    """module Seam exposing (asAttribute)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x
"""


{-| Seam module that also exposes a second primitive (`token`) so an escape can
nest a `Seam.*` reference in its arguments (exercises self-ref de-qualification).
-}
seamModuleWithToken : String
seamModuleWithToken =
    """module Seam exposing (asAttribute, token)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


token : String -> String
token s =
    s
"""


{-| An external module the seam CAN import (it does not depend on `Seam`, so no
cycle) — exercises the import-carry bucket, aliased as `Value`.
-}
valuesModule : String
valuesModule =
    """module M3e.Values exposing (large)


large : String -> String
large s =
    s
"""


{-| A module that imports `Seam` — so `Seam` importing it back would be a cycle.
References to it must be threaded as arguments, not carried as an import.
-}
docModule : String
docModule =
    """module Doc exposing (render)

import Seam


render : String -> String
render s =
    s
"""


{-| A seam module exposing an `onClick`-style escape that takes a `msg`, so an
escape can capture a `Msg` constructor from the calling module.
-}
seamModuleWithOnClick : String
seamModuleWithOnClick =
    """module Seam exposing (asAttribute, onClick)


asAttribute : a -> a
asAttribute x =
    x


onClick : msg -> Int
onClick _ =
    0
"""


{-| A seam module with a top-level `section` helper, so a lifted escape whose
captured parameter is also named `section` would shadow it.
-}
seamModuleWithSection : String
seamModuleWithSection =
    """module Seam exposing (asAttribute, section)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


section : String -> String
section s =
    s
"""


{-| An external module the seam already imports (unaliased), used to exercise
requalification when a violating module refers to it under a different alias.
-}
extModule : String
extModule =
    """module Ext exposing (foo)


foo : String -> String
foo s =
    s
"""


seamModuleWithExt : String
seamModuleWithExt =
    """module Seam exposing (asAttribute)

import Ext


asAttribute : a -> a
asAttribute x =
    x
"""


{-| A module the seam already imports (unaliased) that exports a value whose bare
name also names a seam top-level, so an unqualified reference to it would rebind
to the seam's own definition once lifted.
-}
rawModule : String
rawModule =
    """module Raw exposing (attr)


attr : String -> String
attr s =
    s
"""


seamModuleWithAttr : String
seamModuleWithAttr =
    """module Seam exposing (asAttribute, attr)

import Raw


asAttribute : a -> a
asAttribute x =
    x


attr : String -> String
attr s =
    s
"""


all : Test
all =
    describe "ExtractToSeam"
        [ test "lifts a closed escape into the seam module and rewrites the call site" <|
            \() ->
                [ """module Feature exposing (v)

import Attr exposing (class)
import Seam


v =
    Seam.asAttribute (class "flex-auto")
"""
                , seamModule
                , attrModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.flexAuto`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `flexAuto` and rewrites this call site to `Seam.flexAuto`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (class \"flex-auto\")"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import Attr exposing (class)
import Seam


v =
    Seam.flexAuto
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, flexAuto)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


flexAuto =
    asAttribute (class "flex-auto")
""" )
                                    ]
                            ]
                          )
                        ]
        , test "de-duplicates identical escapes into one lifted function reused by both call sites" <|
            \() ->
                [ """module Feature exposing (a, b)

import Attr exposing (class)
import Seam


a =
    Seam.asAttribute (class "flex-auto")


b =
    Seam.asAttribute (class "flex-auto")
"""
                , seamModule
                , attrModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.flexAuto`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `flexAuto` and rewrites this call site to `Seam.flexAuto`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (class \"flex-auto\")"
                                }
                                |> Review.Test.atExactly { start = { row = 8, column = 5 }, end = { row = 8, column = 41 } }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (a, b)

import Attr exposing (class)
import Seam


a =
    Seam.flexAuto


b =
    Seam.flexAuto
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, flexAuto)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


flexAuto =
    asAttribute (class "flex-auto")
""" )
                                    ]
                            ]
                          )
                        ]
        , test "gives distinct escapes distinct deterministically-named functions" <|
            \() ->
                [ """module Feature exposing (a, b)

import Attr exposing (class)
import Seam


a =
    Seam.asAttribute (class "flex-auto")


b =
    Seam.asAttribute (class "grid-row")
"""
                , seamModule
                , attrModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.flexAuto`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `flexAuto` and rewrites this call site to `Seam.flexAuto`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (class \"flex-auto\")"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (a, b)

import Attr exposing (class)
import Seam


a =
    Seam.flexAuto


b =
    Seam.asAttribute (class "grid-row")
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, flexAuto)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


flexAuto =
    asAttribute (class "flex-auto")
""" )
                                    ]
                            , Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.gridRow`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `gridRow` and rewrites this call site to `Seam.gridRow`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (class \"grid-row\")"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (a, b)

import Attr exposing (class)
import Seam


a =
    Seam.asAttribute (class "flex-auto")


b =
    Seam.gridRow
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, gridRow)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


gridRow =
    asAttribute (class "grid-row")
""" )
                                    ]
                            ]
                          )
                        ]
        , test "parameterizes a captured free variable and threads it at the call site" <|
            \() ->
                [ """module Feature exposing (v)

import Attr exposing (class)
import Seam


v n =
    Seam.asAttribute (class ("col-" ++ n))
"""
                , seamModule
                , attrModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.col`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `col` and rewrites this call site to `Seam.col`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (class (\"col-\" ++ n))"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import Attr exposing (class)
import Seam


v n =
    Seam.col n
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, col)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


col n =
    asAttribute (class ("col-" ++ n))
""" )
                                    ]
                            ]
                          )
                        ]
        , test "converges: already-lifted closed and parameterized seam calls are not re-extracted" <|
            \() ->
                [ """module Feature exposing (v, w)

import Seam


v =
    Seam.flexAuto


w n =
    Seam.col n
"""
                , """module Seam exposing (asAttribute, col, flexAuto)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


flexAuto =
    asAttribute (class "flex-auto")


col n =
    asAttribute (class ("col-" ++ n))
"""
                , attrModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectNoErrors
        , test "does not touch a Seam.* call inside an allowed module" <|
            \() ->
                [ """module Native exposing (v)

import Attr exposing (class)
import Seam


v =
    Seam.asAttribute (class "flex-auto")
"""
                , seamModule
                , attrModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectNoErrors
        , test "reports a fixless error for a point-free seam reference" <|
            \() ->
                [ """module Feature exposing (v)

import Seam


v xs =
    List.map Seam.asElement xs
"""
                , """module Seam exposing (asElement)


asElement : a -> a
asElement x =
    x
"""
                , attrModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asElement` is used point-free and cannot be auto-extracted"
                                , details =
                                    [ "This is a bare (point-free) reference to a seam function rather than an applied escape expression, so there is nothing self-contained to lift."
                                    , "Refactor it into an applied escape, or lift the surrounding expression into the seam module by hand."
                                    ]
                                , under = "Seam.asElement"
                                }
                            ]
                          )
                        ]
        , test "de-qualifies a nested Seam.* reference in the lifted body (self bucket)" <|
            \() ->
                [ """module Feature exposing (v)

import Seam


v =
    Seam.asAttribute (Seam.token "flex-auto")
"""
                , seamModuleWithToken
                , attrModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.flexAuto`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `flexAuto` and rewrites this call site to `Seam.flexAuto`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (Seam.token \"flex-auto\")"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import Seam


v =
    Seam.flexAuto
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, token, flexAuto)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


token : String -> String
token s =
    s


flexAuto =
    asAttribute (token "flex-auto")
""" )
                                    ]
                            ]
                          )
                        ]
        , test "carries an importable external reference as a new seam import (import bucket)" <|
            \() ->
                [ """module Feature exposing (v)

import M3e.Values as Value
import Seam


v =
    Seam.asAttribute (Value.large "card")
"""
                , seamModule
                , attrModule
                , valuesModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.card`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `card` and rewrites this call site to `Seam.card`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (Value.large \"card\")"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import M3e.Values as Value
import Seam


v =
    Seam.card
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, card)

import Attr exposing (class)
import M3e.Values as Value


asAttribute : a -> a
asAttribute x =
    x


card =
    asAttribute (Value.large "card")
""" )
                                    ]
                            ]
                          )
                        ]
        , test "threads a cyclic reference as a parameter passed at the call site (thread bucket)" <|
            \() ->
                [ """module Feature exposing (v)

import Doc
import Seam


v =
    Seam.asAttribute (Doc.render "hero")
"""
                , seamModule
                , attrModule
                , docModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.hero`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `hero` and rewrites this call site to `Seam.hero`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (Doc.render \"hero\")"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import Doc
import Seam


v =
    Seam.hero Doc.render
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, hero)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


hero docRender =
    asAttribute (docRender "hero")
""" )
                                    ]
                            ]
                          )
                        ]
        , test "de-duplicates by the rewritten body: two self-ref call sites share one lifted function" <|
            \() ->
                [ """module Feature exposing (a, b)

import Seam


a =
    Seam.asAttribute (Seam.token "flex-auto")


b =
    Seam.asAttribute (Seam.token "flex-auto")
"""
                , seamModuleWithToken
                , attrModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.flexAuto`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `flexAuto` and rewrites this call site to `Seam.flexAuto`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (Seam.token \"flex-auto\")"
                                }
                                |> Review.Test.atExactly { start = { row = 7, column = 5 }, end = { row = 7, column = 46 } }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (a, b)

import Seam


a =
    Seam.flexAuto


b =
    Seam.flexAuto
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, token, flexAuto)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


token : String -> String
token s =
    s


flexAuto =
    asAttribute (token "flex-auto")
""" )
                                    ]
                            ]
                          )
                        ]
        , test "converges: an already-lifted self-ref body is not re-extracted" <|
            \() ->
                [ """module Feature exposing (a, b)

import Seam


a =
    Seam.flexAuto


b =
    Seam.flexAuto
"""
                , """module Seam exposing (asAttribute, token, flexAuto)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


token : String -> String
token s =
    s


flexAuto =
    asAttribute (token "flex-auto")
"""
                , attrModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectNoErrors
        , test "threads an uppercase local constructor as a slugified parameter" <|
            \() ->
                [ """module Feature exposing (v)

import Seam


type Msg
    = Toggle


v : Int
v =
    Seam.onClick Toggle
"""
                , seamModuleWithOnClick
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.onClick` escape can be lifted into `Seam.seamOnClick`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `seamOnClick` and rewrites this call site to `Seam.seamOnClick`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.onClick Toggle"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import Seam


type Msg
    = Toggle


v : Int
v =
    Seam.seamOnClick Toggle
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, onClick, seamOnClick)


asAttribute : a -> a
asAttribute x =
    x


onClick : msg -> Int
onClick _ =
    0


seamOnClick toggle =
    onClick toggle
""" )
                                    ]
                            ]
                          )
                        ]
        , test "threads a constructor applied to free-var args, keeping the args as free vars" <|
            \() ->
                [ """module Feature exposing (v)

import Seam


type Msg
    = Select Int String


v index label =
    Seam.onClick (Select index label)
"""
                , seamModuleWithOnClick
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.onClick` escape can be lifted into `Seam.seamOnClick`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `seamOnClick` and rewrites this call site to `Seam.seamOnClick`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.onClick (Select index label)"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import Seam


type Msg
    = Select Int String


v index label =
    Seam.seamOnClick index label Select
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, onClick, seamOnClick)


asAttribute : a -> a
asAttribute x =
    x


onClick : msg -> Int
onClick _ =
    0


seamOnClick index label select =
    onClick (select index label)
""" )
                                    ]
                            ]
                          )
                        ]
        , test "renames a captured parameter that would shadow an existing seam top-level" <|
            \() ->
                [ """module Feature exposing (v)

import Attr exposing (class)
import Seam


v section =
    Seam.asAttribute (class section)
"""
                , seamModuleWithSection
                , attrModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.seamAsAttribute`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `seamAsAttribute` and rewrites this call site to `Seam.seamAsAttribute`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (class section)"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import Attr exposing (class)
import Seam


v section =
    Seam.seamAsAttribute section
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, section, seamAsAttribute)

import Attr exposing (class)


asAttribute : a -> a
asAttribute x =
    x


section : String -> String
section s =
    s


seamAsAttribute section_ =
    asAttribute (class section_)
""" )
                                    ]
                            ]
                          )
                        ]
        , test "requalifies a reference whose module the seam imports under a different alias" <|
            \() ->
                [ """module Feature exposing (v)

import Ext as X
import Seam


v =
    Seam.asAttribute (X.foo "bar")
"""
                , seamModuleWithExt
                , extModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.bar`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `bar` and rewrites this call site to `Seam.bar`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (X.foo \"bar\")"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import Ext as X
import Seam


v =
    Seam.bar
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, bar)

import Ext


asAttribute : a -> a
asAttribute x =
    x


bar =
    asAttribute (Ext.foo "bar")
""" )
                                    ]
                            ]
                          )
                        ]
        , test "keeps a reference whose module the seam already imports under the same qualifier" <|
            \() ->
                [ """module Feature exposing (v)

import Ext
import Seam


v =
    Seam.asAttribute (Ext.foo "bar")
"""
                , seamModuleWithExt
                , extModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.bar`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `bar` and rewrites this call site to `Seam.bar`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (Ext.foo \"bar\")"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import Ext
import Seam


v =
    Seam.bar
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, bar)

import Ext


asAttribute : a -> a
asAttribute x =
    x


bar =
    asAttribute (Ext.foo "bar")
""" )
                                    ]
                            ]
                          )
                        ]
        , test "re-qualifies an unqualified imported value that would rebind to a seam top-level" <|
            \() ->
                [ """module Feature exposing (v)

import Raw exposing (attr)
import Seam


v =
    Seam.asAttribute (attr "hi")
"""
                , seamModuleWithAttr
                , rawModule
                ]
                    |> Review.Test.runOnModules (rule config)
                    |> Review.Test.expectErrorsForModules
                        [ ( "Feature"
                          , [ Review.Test.error
                                { message = "`Seam.asAttribute` escape can be lifted into `Seam.hi`"
                                , details =
                                    [ "This `Seam.*` escape discards a type guarantee in a module that is not allowed to use the seam. The fix lifts it into `Seam` as `hi` and rewrites this call site to `Seam.hi`."
                                    , "Naming and de-duplication are deterministic, so re-running `--fix` converges: identical escapes share one lifted function, and an already-lifted `Seam` function is never re-extracted."
                                    ]
                                , under = "Seam.asAttribute (attr \"hi\")"
                                }
                                |> Review.Test.shouldFixFiles
                                    [ ( "Feature", """module Feature exposing (v)

import Raw exposing (attr)
import Seam


v =
    Seam.hi
""" )
                                    , ( "Seam", """module Seam exposing (asAttribute, attr, hi)

import Raw


asAttribute : a -> a
asAttribute x =
    x


attr : String -> String
attr s =
    s


hi =
    asAttribute (Raw.attr "hi")
""" )
                                    ]
                            ]
                          )
                        ]
        ]
