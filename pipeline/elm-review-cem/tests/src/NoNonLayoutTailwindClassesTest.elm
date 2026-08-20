module NoNonLayoutTailwindClassesTest exposing (all)

import NoNonLayoutTailwindClasses exposing (rule)
import Review.Rule exposing (Rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| A small synthetic manifest — enough real names to exercise the
membership-vs-prefix-guess distinction without dragging in a real brand's
2000+ entry generated list. Mirrors the shape of `tailwind-m3e-web`'s
`generated/utilities.json` → `M3eUtilityNames.names`.
-}
testTokenNames : List String
testTokenNames =
    [ "m3e-content-pane-container-color-surface-container-low"
    , "m3e-avatar-size"
    , "m3e-card-padding"
    , "m3e-filled-card-container-color-primary-container"
    ]


baseConfig :
    List String
    ->
        { classModules : List (List String)
        , proprietaryPrefixes : List String
        , tokenUtilities : Maybe NoNonLayoutTailwindClasses.TokenUtilityBridge
        , allowedModules : List String
        , guidance :
            { proprietary : List String
            , styling : List String
            , deadUtility : List String
            }
        }
baseConfig allowedModules =
    { classModules =
        [ [ "Html", "Attributes" ]
        , [ "TypedHtml", "Attributes" ]
        , [ "M3e", "Attributes" ]
        , [ "Svg", "Attributes" ]
        ]
    , proprietaryPrefixes = [ "ds-", "t-" ]
    , tokenUtilities = Just { prefix = "m3e-", names = testTokenNames }
    , allowedModules = allowedModules
    , guidance =
        { proprietary = [ "Use a typed design-system slot/role binding, or a real utility class, instead." ]
        , styling = [ "Reach for the component that already owns this surface instead of repainting it." ]
        , deadUtility = [ "Check the manifest for the correct spelling, or file a component gap if the utility should exist." ]
        }
    }


testRule : List String -> Rule
testRule allowedModules =
    rule (baseConfig allowedModules)


proprietaryMessage : String
proprietaryMessage =
    "Proprietary CSS class — ships no CSS"


stylingMessage : String
stylingMessage =
    "Non-layout CSS class — styling must come from a design-system component"


deadUtilityMessage : String
deadUtilityMessage =
    "Unknown `m3e-*` utility — ships no CSS"


{-| The rule names the offending tokens in its details, so the expected details
depend on the input. These builders keep the tests readable.
-}
proprietaryDetails : String -> List String
proprietaryDetails offending =
    [ "`ds-*` / `t-*` classes are project-proprietary tokens that are not part of this design system and ship no CSS, so they render nothing."
    , "Offending: " ++ offending
    , "Use a typed design-system slot/role binding, or a real utility class, instead."
    ]


deadUtilityDetails : String -> List String
deadUtilityDetails offending =
    [ "This class is spelled like one of the generated `m3e-*` component-token utilities, but it is not one of them, so it ships no CSS and renders nothing."
    , "Offending: " ++ offending
    , "Check the manifest for the correct spelling, or file a component gap if the utility should exist."
    ]


stylingDetails : String -> List String
stylingDetails offending =
    [ "Tailwind is for LAYOUT only. Colour, background, border, radius, elevation/shadow and typography must come from a design-system component, not a utility class."
    , "Offending: " ++ offending
    , "Reach for the component that already owns this surface instead of repainting it."
    , "Layout utilities (`flex`, `grid-cols-2`, `gap-4`, `w-full`, `p-4`, `z-20`, …) stay. So do the generated `m3e-*` token utilities, which set a component's own documented custom properties."
    ]


expectDeadUtility : String -> String -> Test.Test
expectDeadUtility name classes =
    test name <|
        \() ->
            typedHtmlModule classes
                |> Review.Test.run (testRule [])
                |> Review.Test.expectErrors
                    [ Review.Test.error
                        { message = deadUtilityMessage
                        , details = deadUtilityDetails classes
                        , under = "\"" ++ classes ++ "\""
                        }
                    ]


{-| Wrap a class string in a `TypedHtml.Attributes` call site — the form the
overwhelming majority of a consumer's classes resolve through.
-}
typedHtmlModule : String -> String
typedHtmlModule classes =
    """module A exposing (view)
import TypedHtml as TH
import TypedHtml.Attributes as TA
view = TH.div [ TA.class \"""" ++ classes ++ """" ] []
"""


expectStyling : String -> String -> Test.Test
expectStyling name classes =
    test name <|
        \() ->
            typedHtmlModule classes
                |> Review.Test.run (testRule [])
                |> Review.Test.expectErrors
                    [ Review.Test.error
                        { message = stylingMessage
                        , details = stylingDetails classes
                        , under = "\"" ++ classes ++ "\""
                        }
                    ]


expectAllowed : String -> String -> Test.Test
expectAllowed name classes =
    test name <|
        \() ->
            typedHtmlModule classes
                |> Review.Test.run (testRule [])
                |> Review.Test.expectNoErrors


all : Test
all =
    describe "NoNonLayoutTailwindClasses"
        [ describe "proprietary tokens"
            [ test "flags Attr.class \"ds-…\"" <|
                \() ->
                    """module A exposing (view)
import Html
import Html.Attributes as Attr
view = Html.div [ Attr.class "ds-card-media" ] []
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = proprietaryMessage
                                , details = proprietaryDetails "ds-card-media"
                                , under = "\"ds-card-media\""
                                }
                            ]
            , test "flags a t- theme token" <|
                \() ->
                    """module A exposing (view)
import Html
import Html.Attributes as Attr
view = Html.div [ Attr.class "t-primary" ] []
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = proprietaryMessage
                                , details = proprietaryDetails "t-primary"
                                , under = "\"t-primary\""
                                }
                            ]
            , test "flags a withClass setter carrying a ds- class" <|
                \() ->
                    """module A exposing (view)
import Ui.Shape
view = Ui.Shape.withClass "ds-w-16"
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = proprietaryMessage
                                , details = proprietaryDetails "ds-w-16"
                                , under = "\"ds-w-16\""
                                }
                            ]
            , test "flags a ds- class buried among layout classes in one string" <|
                \() ->
                    """module A exposing (view)
import Html
import Html.Attributes as Attr
view = Html.div [ Attr.class "flex ds-card items-center" ] []
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = proprietaryMessage
                                , details = proprietaryDetails "ds-card"
                                , under = "\"flex ds-card items-center\""
                                }
                            ]
            , test "flags a ds- token inside classList" <|
                \() ->
                    """module A exposing (view)
import Html
import Html.Attributes as Attr
view active = Html.div [ Attr.classList [ ( "ds-active", active ) ] ] []
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = proprietaryMessage
                                , details = proprietaryDetails "ds-active"
                                , under = "\"ds-active\""
                                }
                            ]
            , test "passes class names that merely contain ds/t mid-token" <|
                \() ->
                    """module A exposing (view)
import Html
import Html.Attributes as Attr
view = Html.div [ Attr.class "cards tools grid-ds" ] []
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectNoErrors
            ]
        , describe "class-bearing modules beyond Html.Attributes"
            [ expectStyling "resolves TypedHtml.Attributes.class" "bg-surface"
            , test "resolves M3e.Attributes.class" <|
                \() ->
                    """module A exposing (view)
import M3e
import M3e.Attributes as MA
view = M3e.card [ MA.class "rounded-lg" ] []
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = stylingMessage
                                , details = stylingDetails "rounded-lg"
                                , under = "\"rounded-lg\""
                                }
                            ]
            , test "resolves Svg.Attributes.class" <|
                \() ->
                    """module A exposing (view)
import Svg
import Svg.Attributes as SvgAttr
view = Svg.circle [ SvgAttr.class "fill-primary" ] []
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = stylingMessage
                                , details = stylingDetails "fill-primary"
                                , under = "\"fill-primary\""
                                }
                            ]
            , test "ignores a class function from an unrelated module" <|
                \() ->
                    """module A exposing (view)
import Csv
view = Csv.class "bg-surface"
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectNoErrors
            ]
        , describe "styling: background and colour"
            [ expectStyling "background role token" "bg-surface-container-high"
            , expectStyling "arbitrary hex background" "bg-[#4285F4]"
            , expectStyling "text colour role" "text-on-surface-variant"
            , expectStyling "literal text colour" "text-white"
            , expectStyling "gradient stop" "from-primary"
            ]
        , describe "styling: border, radius, elevation"
            [ expectStyling "bare border" "border"
            , expectStyling "border colour" "border-outline-variant"
            , expectStyling "border side under a responsive variant" "md:border-r"
            , expectStyling "m3 corner token" "rounded-md-corner-large"
            , expectStyling "plain radius" "rounded-full"
            , expectStyling "elevation under a focus variant" "focus:shadow-md-level2"
            , expectStyling "inset-shadow is elevation, not the inset- layout family" "inset-shadow-sm"
            , expectStyling "inset-ring is elevation, not the inset- layout family" "inset-ring-2"
            , expectStyling "ring" "ring-2"
            ]
        , describe "styling: typography"
            [ expectStyling "type scale" "text-body-lg"
            , expectStyling "type size" "text-4xl"
            , expectStyling "font family" "font-mono"
            , expectStyling "letter spacing" "tracking-wide"
            , expectStyling "line height" "leading-tight"
            , expectStyling "text transform" "uppercase"
            , expectStyling "decoration under a hover variant" "hover:underline"
            , expectStyling "list marker" "list-disc"
            ]
        , describe "styling: paint on non-text surfaces"
            [ expectStyling "svg fill" "fill-current"
            , expectStyling "svg stroke" "stroke-primary"
            , expectStyling "filter" "blur-sm"
            , expectStyling "blend mode" "mix-blend-multiply"
            , expectStyling "arbitrary property that is not a token utility" "[color:red]"
            ]
        , describe "allowed: layout"
            [ expectAllowed "flex row" "flex items-center gap-2"
            , expectAllowed "grid with responsive variants" "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3"
            , expectAllowed "sizing" "w-full h-dvh min-h-0 max-w-2xl size-full"
            , expectAllowed "padding and margin" "p-4 px-2 mt-8 -mx-4 mx-auto"
            , expectAllowed "logical margins" "ms-7 -me-7 pe-2 ps-4"
            , expectAllowed "position and stacking" "relative absolute fixed sticky inset-x-0 top-2 z-50"
            , expectAllowed "overflow and flow" "overflow-hidden overflow-y-auto whitespace-pre-line truncate"
            , expectAllowed "display" "hidden md:flex contents block inline-flex"
            , expectAllowed "spacing rhythm" "space-y-4 space-y-1.5 gap-0.5"
            , expectAllowed "flex children" "flex-1 flex-col flex-wrap shrink-0 flex-auto"
            , expectAllowed "text alignment is layout, not typography" "text-left text-center"
            , expectAllowed "text wrapping is layout, not typography" "text-nowrap text-balance"
            , expectAllowed "scroll and snap" "snap-x snap-mandatory snap-start scroll-mt-6"
            , expectAllowed "transform and motion" "translate-y-2 rotate-45 transition duration-200 ease-out"
            , expectAllowed "interaction" "cursor-pointer pointer-events-none select-none"
            , expectAllowed "accessibility" "sr-only focus:not-sr-only"
            , expectAllowed "opacity is visibility, not paint" "opacity-0 hover:opacity-90"
            , expectAllowed "grid column span" "lg:col-span-2 xl:grid-cols-4"
            , expectAllowed "negative under a responsive variant" "sm:-mx-8"
            , expectAllowed "child and pseudo variants over layout" "*:me-11 first:mt-0 [&>*]:pointer-events-auto"
            ]
        , describe "allowed: the sanctioned token-utility bridge"
            [ expectAllowed "generated component token utility" "m3e-content-pane-container-color-surface-container-low"
            , expectAllowed "generated token utility with an arbitrary value" "m3e-avatar-size-[2rem] m3e-card-padding-[0.625rem]"
            , expectAllowed "arbitrary custom property behind a pseudo variant" "[:not([selected])]:[--m3e-nav-rail-icon-button-inset:auto]"
            ]
        , describe "allowed: classes that are not Tailwind utilities at all"
            [ expectAllowed "project semantic hooks" "compose-slot-panel compose-attr-group"
            , expectAllowed "test and brand selectors" "primary-nav-drawer tangram-mark cv-auto"
            ]
        , describe "mixed strings"
            [ test "reports styling once, naming every offending token, and leaves layout alone" <|
                \() ->
                    typedHtmlModule "flex items-center gap-2 bg-surface rounded-lg text-body-md"
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = stylingMessage
                                , details = stylingDetails "bg-surface, rounded-lg, text-body-md"
                                , under = "\"flex items-center gap-2 bg-surface rounded-lg text-body-md\""
                                }
                            ]
            , test "reports proprietary and styling as separate errors" <|
                \() ->
                    typedHtmlModule "ds-card bg-surface"
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = proprietaryMessage
                                , details = proprietaryDetails "ds-card"
                                , under = "\"ds-card bg-surface\""
                                }
                            , Review.Test.error
                                { message = stylingMessage
                                , details = stylingDetails "bg-surface"
                                , under = "\"ds-card bg-surface\""
                                }
                            ]
            , expectAllowed "empty class string" ""
            ]
        , describe "token utilities are checked against the REAL manifest, not a prefix guess"
            [ expectAllowed "a real utility with an arbitrary value" "m3e-card-padding-[0.625rem]"
            , expectAllowed "a real utility with a token value" "m3e-filled-card-container-color-primary-container"
            , expectAllowed "a real utility used bare, with no value suffix" "m3e-card-padding"
            , expectDeadUtility "a MADE-UP utility is caught" "m3e-totally-fake-thing"
            , expectDeadUtility "a TYPO in a real utility is caught" "m3e-crd-padding-4"
            , expectDeadUtility "a real utility name with a typo'd suffix boundary is caught" "m3e-card-paddingx-4"
            , expectAllowed "the arbitrary-property escape still passes" "[--m3e-nav-rail-icon-button-inset:auto]"
            ]
        , describe "when no token-utility bridge is configured"
            [ test "a class shaped like a bridge name is just an unknown token — allowed" <|
                \() ->
                    """module A exposing (view)
import TypedHtml as TH
import TypedHtml.Attributes as TA
view = TH.div [ TA.class "m3e-card-padding" ] []
"""
                        |> Review.Test.run
                            (rule
                                { classModules = [ [ "TypedHtml", "Attributes" ] ]
                                , proprietaryPrefixes = [ "ds-", "t-" ]
                                , tokenUtilities = Nothing
                                , allowedModules = []
                                , guidance = { proprietary = [], styling = [], deadUtility = [] }
                                }
                            )
                        |> Review.Test.expectNoErrors
            , test "a bridge-shaped arbitrary property is treated as ordinary styling" <|
                \() ->
                    """module A exposing (view)
import TypedHtml as TH
import TypedHtml.Attributes as TA
view = TH.div [ TA.class "[--m3e-nav-rail-icon-button-inset:auto]" ] []
"""
                        |> Review.Test.run
                            (rule
                                { classModules = [ [ "TypedHtml", "Attributes" ] ]
                                , proprietaryPrefixes = [ "ds-", "t-" ]
                                , tokenUtilities = Nothing
                                , allowedModules = []
                                , guidance = { proprietary = [], styling = [], deadUtility = [] }
                                }
                            )
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = stylingMessage
                                , details =
                                    [ "Tailwind is for LAYOUT only. Colour, background, border, radius, elevation/shadow and typography must come from a design-system component, not a utility class."
                                    , "Offending: [--m3e-nav-rail-icon-button-inset:auto]"
                                    , "Layout utilities (`flex`, `grid-cols-2`, `gap-4`, `w-full`, `p-4`, `z-20`, …) stay."
                                    ]
                                , under = "\"[--m3e-nav-rail-icon-button-inset:auto]\""
                                }
                            ]
            ]
        , describe "the seam fence (allowedModules)"
            [ test "a styling class OUTSIDE the designated module is still caught" <|
                \() ->
                    """module Route.Page exposing (view)
import TypedHtml as TH
import TypedHtml.Attributes as TA
view = TH.div [ TA.class "bg-surface-container" ] []
"""
                        |> Review.Test.run (testRule [ "Seam" ])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = stylingMessage
                                , details = stylingDetails "bg-surface-container"
                                , under = "\"bg-surface-container\""
                                }
                            ]
            , test "the SAME usage inside the designated module is not flagged" <|
                \() ->
                    """module Seam exposing (mutedPanel)
import TypedHtml as TH
import TypedHtml.Attributes as TA
mutedPanel = TH.div [ TA.class "bg-surface-container" ] []
"""
                        |> Review.Test.run (testRule [ "Seam" ])
                        |> Review.Test.expectNoErrors
            , test "the fence covers modules nested under the seam, at a dot boundary" <|
                \() ->
                    """module Seam.Surface exposing (panel)
import TypedHtml as TH
import TypedHtml.Attributes as TA
panel = TH.div [ TA.class "rounded-lg text-on-surface-variant" ] []
"""
                        |> Review.Test.run (testRule [ "Seam" ])
                        |> Review.Test.expectNoErrors
            , test "a module merely PREFIXED like the seam is NOT inside it" <|
                \() ->
                    """module Seamless exposing (view)
import TypedHtml as TH
import TypedHtml.Attributes as TA
view = TH.div [ TA.class "bg-surface" ] []
"""
                        |> Review.Test.run (testRule [ "Seam" ])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = stylingMessage
                                , details = stylingDetails "bg-surface"
                                , under = "\"bg-surface\""
                                }
                            ]
            , test "an empty allow-list makes the rule unconditional — nowhere is exempt" <|
                \() ->
                    """module Seam exposing (mutedPanel)
import TypedHtml as TH
import TypedHtml.Attributes as TA
mutedPanel = TH.div [ TA.class "bg-surface-container" ] []
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = stylingMessage
                                , details = stylingDetails "bg-surface-container"
                                , under = "\"bg-surface-container\""
                                }
                            ]
            , test "layout classes inside the seam are still fine (no false positives either way)" <|
                \() ->
                    """module Seam exposing (row)
import TypedHtml as TH
import TypedHtml.Attributes as TA
row = TH.div [ TA.class "flex items-center gap-2" ] []
"""
                        |> Review.Test.run (testRule [ "Seam" ])
                        |> Review.Test.expectNoErrors
            ]
        , describe "non-literal class arguments"
            [ test "finds a painting class concatenated onto a computed part" <|
                \() ->
                    """module A exposing (view)
import TypedHtml as TH
import TypedHtml.Attributes as TA
view bodyCls = TH.span [ TA.class (bodyCls ++ " text-on-surface-variant") ] []
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = stylingMessage
                                , details = stylingDetails "text-on-surface-variant"
                                , under = "\" text-on-surface-variant\""
                                }
                            ]
            , test "finds a painting class on the left of a concatenation" <|
                \() ->
                    """module A exposing (view)
import TypedHtml as TH
import TypedHtml.Attributes as TA
view shadow = TH.div [ TA.class ("bg-surface-container-high p-4 " ++ shadow) ] []
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = stylingMessage
                                , details = stylingDetails "bg-surface-container-high"
                                , under = "\"bg-surface-container-high p-4 \""
                                }
                            ]
            , test "checks both branches of an if" <|
                \() ->
                    """module A exposing (view)
import TypedHtml as TH
import TypedHtml.Attributes as TA
view selected = TH.div [ TA.class (if selected then "bg-surface-container" else "flex gap-2") ] []
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = stylingMessage
                                , details = stylingDetails "bg-surface-container"
                                , under = "\"bg-surface-container\""
                                }
                            ]
            , test "checks every branch of a case" <|
                \() ->
                    """module A exposing (view)
import TypedHtml as TH
import TypedHtml.Attributes as TA
view kind =
    TH.div
        [ TA.class
            (case kind of
                1 -> "flex"
                _ -> "rounded-lg"
            )
        ]
        []
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = stylingMessage
                                , details = stylingDetails "rounded-lg"
                                , under = "\"rounded-lg\""
                                }
                            ]
            , test "a fully computed class is invisible — the documented limit" <|
                \() ->
                    """module A exposing (view)
import TypedHtml as TH
import TypedHtml.Attributes as TA
view density = TH.div [ TA.class (densityClass density) ] []
densityClass d = "bg-surface"
"""
                        |> Review.Test.run (testRule [])
                        |> Review.Test.expectNoErrors
            ]
        ]
