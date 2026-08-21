module NoFamilyMemberDriftTest exposing (all)

import NoFamilyMemberDrift exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


config : { componentNamespace : List String, familyNamespace : List String, families : List NoFamilyMemberDrift.Family }
config =
    { componentNamespace = [ "M3e", "Element" ]
    , familyNamespace = [ "M3e", "Component" ]
    , families =
        [ { family = "Chip", members = [ "Chip", "AssistChip", "FilterChip" ] }
        , { family = "NavMenu", members = [ "NavMenu", "NavMenuItem" ] }
        ]
    }


all : Test
all =
    describe "NoFamilyMemberDrift"
        [ test "family module importing exactly its declared members — no error" <|
            \() ->
                """module M3e.Component.Chip exposing (chip, assist, filter)

import M3e.Element.AssistChip as Assist_
import M3e.Element.Chip as Chip_
import M3e.Element.FilterChip as Filter_


chip =
    Chip_.component


assist =
    Assist_.component


filter =
    Filter_.component
"""
                    |> Review.Test.run (rule config)
                    |> Review.Test.expectNoErrors
        , test "component missing from family — declared member never imported" <|
            \() ->
                """module M3e.Component.Chip exposing (chip, assist)

import M3e.Element.AssistChip as Assist_
import M3e.Element.Chip as Chip_


chip =
    Chip_.component


assist =
    Assist_.component
"""
                    |> Review.Test.run (rule config)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Family `Chip` does not import component `FilterChip`"
                            , details =
                                [ "The family config declares `FilterChip` a member of the `Chip` family, but this module has no `import ...Element.FilterChip`."
                                , "Either the family module is stale (regenerate it from the family config) or the config still lists a component this family no longer includes (fix the config)."
                                ]
                            , under = "M3e.Component.Chip"
                            }
                        ]
        , test "family referencing a dead/unlisted component — imports a component config doesn't declare" <|
            \() ->
                """module M3e.Component.NavMenu exposing (navMenu, item, group)

import M3e.Element.NavMenu as NavMenu_
import M3e.Element.NavMenuItem as Item_
import M3e.Element.NavMenuItemGroup as Group_


navMenu =
    NavMenu_.component


item =
    Item_.component


group =
    Group_.component
"""
                    |> Review.Test.run (rule config)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Family `NavMenu` imports component `NavMenuItemGroup`, which is not a declared member"
                            , details =
                                [ "This module imports `NavMenuItemGroup`, but the family config's `NavMenu` entry does not list it as a member."
                                , "Either the import is stale (the component was dropped from this family — remove the import) or the family config is missing this member (add it)."
                                ]
                            , under = "import M3e.Element.NavMenuItemGroup as Group_"
                            }
                        ]
        , test "family module with no matching config entry — out of scope, no error" <|
            \() ->
                """module M3e.Component.Unknown exposing (thing)

import M3e.Element.SomethingElse as SomethingElse_


thing =
    SomethingElse_.component
"""
                    |> Review.Test.run (rule config)
                    |> Review.Test.expectNoErrors
        , test "non-family module — out of scope, no error" <|
            \() ->
                """module M3e.Element.Chip exposing (component)

component attrs children =
    something
"""
                    |> Review.Test.run (rule config)
                    |> Review.Test.expectNoErrors
        ]
