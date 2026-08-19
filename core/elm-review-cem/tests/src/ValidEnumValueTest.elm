module ValidEnumValueTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.ValidEnumValue exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| Facts for portmanteau tests: Button (variant: filled/outlined) + Theme (variant:
rainbow/filled). The global token set for `variant` = [filled, outlined, rainbow].
So `variantRainbow` is a known portmanteau, valid on Theme but not on Button.
-}
portmanteauFacts : List Facts.Fact
portmanteauFacts =
    [ { component = "button"
      , module_ = "M3e.Button"
      , enums = [ ( "variant", [ "filled", "outlined" ] ) ]
      , requiredSlots = []
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
    , { component = "theme"
      , module_ = "M3e.Theme"
      , enums = [ ( "variant", [ "rainbow", "filled" ] ) ]
      , requiredSlots = []
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


{-| A tiny hand-written facts table: a Button whose `variant` accepts only filled/outlined.
-}
facts : List Facts.Fact
facts =
    [ { component = "button"
      , module_ = "M3e.Button"
      , enums = [ ( "variant", [ "filled", "outlined" ] ) ]
      , requiredSlots = []
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


shape4Facts : List Facts.Fact
shape4Facts =
    [ { component = "button"
      , module_ = "M3e.Button"
      , enums = [ ( "variant", [ "filled", "outlined" ] ) ]
      , requiredSlots = []
      , multiSlots = []
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


{-| Two libraries' facts concatenated, exactly as the dogfood apps do
(`M3e.Review.Facts.facts ++ TypedHtml.Review.Facts.facts`). Before per-namespace
grouping, `rootParts` took only the FIRST fact's namespace (`M3e`), so the
`Tui`-namespace fact here was silently ignored and its violations never flagged.
-}
multiFacts : List Facts.Fact
multiFacts =
    facts
        ++ [ { component = "chip"
             , module_ = "Tui.Chip"
             , enums = [ ( "size", [ "small", "large" ] ) ]
             , requiredSlots = []
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


{-| Facts shaped like REAL generated output (`M3e.Component.<Name>`, WITH the
`.Component.` segment) rather than the flat `M3e.Button` fixtures above. The
flat fixtures made `factKey == siteKey` for a loose barrel call, which hid a
bug where the rule's OWN private index (keyed only on `factKey`) never matched
a barrel `siteKey` — the rule silently no-op'd on the entire `M3e.*` loose
barrel surface. `Cem.ValidEnumValue.buildIndex` must reuse the canonical
`Cem.Internal.Facts.buildIndex`, which inserts a barrel-alias key alongside
`factKey` for exactly this shape. See WS-D diagnosis.
-}
barrelFacts : List Facts.Fact
barrelFacts =
    [ { component = "button"
      , module_ = "M3e.Component.Button"
      , enums = [ ( "variant", [ "filled", "outlined" ] ) ]
      , requiredSlots = []
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
    , { component = "theme"
      , module_ = "M3e.Component.Theme"
      , enums = [ ( "variant", [ "rainbow", "filled" ] ) ]
      , requiredSlots = []
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


message : String
message =
    "`circular` is not a valid value for this component"


all : Test
all =
    describe "ValidEnumValue"
        [ test "flags a barrel enum setter given a token the component rejects" <|
            \() ->
                """module A exposing (v)

import M3e exposing (button, variant)
import M3e.Token as Value

v =
    button [ variant Value.circular ] []
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details =
                                [ "This component's enum only accepts: filled, outlined."
                                , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                ]
                            , under = "Value.circular"
                            }
                        ]
        , test "accepts a token the component supports" <|
            \() ->
                """module A exposing (v)

import M3e exposing (button, variant)
import M3e.Token as Value

v =
    button [ variant Value.filled ] []
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , test "ignores components with no facts" <|
            \() ->
                """module A exposing (v)

import M3e exposing (widget, variant)
import M3e.Token as Value

v =
    widget [ variant Value.circular ] []
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , test "handles the component-module strict form (M3e.Button.component)" <|
            \() ->
                """module A exposing (v)

import M3e.Button as Button
import M3e.Token as Value

v =
    Button.component [ Button.variant Value.circular ] []
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details =
                                [ "This component's enum only accepts: filled, outlined."
                                , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                ]
                            , under = "Value.circular"
                            }
                        ]
        , test "flags an invalid enum token at a Record call site" <|
            \() ->
                """module A exposing (v)

import M3e.Record.Button
import M3e.Token as Value

v =
    M3e.Record.Button.component {} [ M3e.Record.Button.variant Value.circular ] []
"""
                    |> Review.Test.run (rule shape4Facts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details =
                                [ "This component's enum only accepts: filled, outlined."
                                , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                ]
                            , under = "Value.circular"
                            }
                        ]
        , test "accepts a valid enum token at a Record call site" <|
            \() ->
                """module A exposing (v)

import M3e.Record.Button
import M3e.Token as Value

v =
    M3e.Record.Button.component {} [ M3e.Record.Button.variant Value.filled ] []
"""
                    |> Review.Test.run (rule shape4Facts)
                    |> Review.Test.expectNoErrors
        , test "does not flag an enum-setter-shaped expression in the content list (#90)" <|
            \() ->
                -- `variant Value.circular` appearing in the CONTENT (last) arg is a
                -- child, not an attribute setter; only the attribute args are checked.
                """module A exposing (v)

import M3e exposing (button, variant)
import M3e.Token as Value

v =
    button [] [ variant Value.circular ]
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , test "does not flag a let-bound (non-inline) enum setter — documented false negative" <|
            \() ->
                -- The rule only recognizes an INLINE `<setter> <token>` application as a
                -- setter element. A let-bound setter appears in the attr list as a bare
                -- variable (`setInvalid`), which `tracedList` returns as-is without
                -- expanding it against scope, so `checkSetter` never matches and the
                -- invalid `circular` token slips through. This pins that boundary.
                """module A exposing (v)

import M3e exposing (button, variant)
import M3e.Token as Value

v =
    let
        setInvalid =
            variant Value.circular
    in
    button [ setInvalid ] []
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , describe "per-namespace facts (concatenated libraries)"
            [ test "flags a bad enum in the SECOND library's namespace (previously ignored)" <|
                \() ->
                    """module A exposing (v)

import Tui exposing (chip, size)
import Tui.Token as Value

v =
    chip [ size Value.huge ] []
"""
                        |> Review.Test.run (rule multiFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`huge` is not a valid value for this component"
                                , details =
                                    [ "This component's enum only accepts: small, large."
                                    , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                    ]
                                , under = "Value.huge"
                                }
                            ]
            , test "flags bad enums in BOTH namespaces in one module" <|
                \() ->
                    """module A exposing (v, w)

import M3e exposing (button, variant)
import M3e.Token as M3eToken
import Tui exposing (chip, size)
import Tui.Token as TuiToken

v =
    button [ variant M3eToken.circular ] []

w =
    chip [ size TuiToken.huge ] []
"""
                        |> Review.Test.run (rule multiFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = message
                                , details =
                                    [ "This component's enum only accepts: filled, outlined."
                                    , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                    ]
                                , under = "M3eToken.circular"
                                }
                            , Review.Test.error
                                { message = "`huge` is not a valid value for this component"
                                , details =
                                    [ "This component's enum only accepts: small, large."
                                    , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                    ]
                                , under = "TuiToken.huge"
                                }
                            ]
            ]
        , describe "portmanteau enum attributes"
            [ test "regression: barrel.button [ variant circular ] is still flagged (classic two-node form)" <|
                \() ->
                    -- The classic `attr token` form must still work after the portmanteau extension.
                    """module A exposing (v)

import M3e exposing (button, variant)
import M3e.Token as Value

v =
    button [ variant Value.circular ] []
"""
                        |> Review.Test.run (rule portmanteauFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`circular` is not a valid value for this component"
                                , details =
                                    [ "This component's enum only accepts: filled, outlined."
                                    , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                    ]
                                , under = "Value.circular"
                                }
                            ]
            , test "flags a portmanteau attr whose value is not valid for this component" <|
                \() ->
                    -- Button does not accept `rainbow`; `variantRainbow` is a portmanteau
                    -- for (variant, rainbow) which IS in the global token set (Theme has it)
                    -- but NOT in Button's accepted tokens.
                    """module A exposing (v)

import M3e exposing (button)
import M3e.Attributes as MA

v =
    button [ MA.variantRainbow ] []
"""
                        |> Review.Test.run (rule portmanteauFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`rainbow` is not a valid `variant` value for this component"
                                , details =
                                    [ "This component's `variant` enum only accepts: filled, outlined."
                                    , "The portmanteau attribute `variantRainbow` bakes in a value this component does not support. Use a portmanteau the component accepts, or the component-module's strict setter."
                                    ]
                                , under = "MA.variantRainbow"
                                }
                            ]
            , test "accepts a portmanteau attr whose value IS valid for this component" <|
                \() ->
                    -- Theme accepts `rainbow`; `variantRainbow` is valid on Theme.
                    """module A exposing (v)

import M3e exposing (theme)
import M3e.Attributes as MA

v =
    theme [ MA.variantRainbow ] []
"""
                        |> Review.Test.run (rule portmanteauFacts)
                        |> Review.Test.expectNoErrors
            , test "accepts a portmanteau whose token is in this component's valid set" <|
                \() ->
                    -- Both Button and Theme accept `filled`; `variantFilled` is valid on either.
                    """module A exposing (v)

import M3e exposing (button)
import M3e.Attributes as MA

v =
    button [ MA.variantFilled ] []
"""
                        |> Review.Test.run (rule portmanteauFacts)
                        |> Review.Test.expectNoErrors
            , test "does not flag a bare identifier from an unrelated module (no false positive)" <|
                \() ->
                    -- `variantRainbow` from a user module (`My.Helpers`) is NOT under
                    -- the M3e namespace, so the rule must not flag it even if the name
                    -- looks like a portmanteau.
                    """module A exposing (v)

import M3e exposing (button)
import My.Helpers exposing (variantRainbow)

v =
    button [ variantRainbow ] []
"""
                        |> Review.Test.run (rule portmanteauFacts)
                        |> Review.Test.expectNoErrors
            , test "does not flag a portmanteau identifier in the content (last) arg (#90 analogue)" <|
                \() ->
                    -- A portmanteau appearing in the CONTENT list (last arg) is a child,
                    -- not an attribute setter; only attr args are checked.
                    """module A exposing (v)

import M3e exposing (button)
import M3e.Attributes as MA

v =
    button [] [ MA.variantRainbow ]
"""
                        |> Review.Test.run (rule portmanteauFacts)
                        |> Review.Test.expectNoErrors
            ]
        , describe "barrel-alias index (WS-D regression: M3e.Component.* fact + loose M3e.* barrel call)"
            [ test "flags a barrel call's classic two-node enum setter when the fact lives under an intermediate namespace segment" <|
                \() ->
                    -- Fails against the old private index (keyed only on `factKey =
                    -- "M3e.Component button"`) because the barrel call site resolves
                    -- to `siteKey = "M3e button"`, which was never in the index.
                    """module A exposing (v)

import M3e exposing (button, variant)
import M3e.Values as Value

v =
    button [ variant Value.circular ] []
"""
                        |> Review.Test.run (rule barrelFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = message
                                , details =
                                    [ "This component's enum only accepts: filled, outlined."
                                    , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                    ]
                                , under = "Value.circular"
                                }
                            ]
            , test "flags a barrel call's portmanteau enum attr when the fact lives under an intermediate namespace segment" <|
                \() ->
                    -- Button (nested under M3e.Component.Button) does not accept `rainbow`;
                    -- `variantRainbow` is a portmanteau in the global token set (Theme has
                    -- it) but not in Button's accepted tokens. Same barrel-alias gap as
                    -- above, for the portmanteau resolution path.
                    """module A exposing (v)

import M3e exposing (button)
import M3e.Attributes as MA

v =
    button [ MA.variantRainbow ] []
"""
                        |> Review.Test.run (rule barrelFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`rainbow` is not a valid `variant` value for this component"
                                , details =
                                    [ "This component's `variant` enum only accepts: filled, outlined."
                                    , "The portmanteau attribute `variantRainbow` bakes in a value this component does not support. Use a portmanteau the component accepts, or the component-module's strict setter."
                                    ]
                                , under = "MA.variantRainbow"
                                }
                            ]
            ]
        ]
