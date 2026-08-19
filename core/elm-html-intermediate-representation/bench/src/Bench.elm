port module Bench exposing (main)

{-| Cost of the `class` / `style` merge, measured against the pre-merge shape.

`merged` walks the REAL path (`Ir.node` → `Ir.toHtml`), so a regression in the
fold shows up here. `legacy` is a local reimplementation of the representation
this replaced — one opaque `VirtualDom.Attribute` per `Attr`, `List.map` to
unwrap, styles pre-joined by the setter, and `Html.Attributes.style "" ""` as
the false-boolean no-op. It exists only as a reference point.

Both paths are measured through `VirtualDom.node`, so the denominator includes
the work elm itself does per node (`_VirtualDom_organizeFacts`).

Findings this harness produced, kept here so they are not re-litigated:

  - Storing EVERY attribute structurally and rebuilding it in the fold cost
    2.2–2.4×. Keeping non-mergeable facts pre-built (`FReady`) is what makes
    the merge affordable.
  - A pre-scan that skips accumulation when a node has no duplicate
    `class`/`style` is SLOWER than always merging — measured both with an
    allocating scan and an allocation-free one. Do not reintroduce it.
  - An assoc list beat `Dict` for style declarations at realistic counts, and
    keeps first-appearance order (which a `Dict` would not).

-}

import Html.Attributes
import HtmlIr.Internal as Ir
import VirtualDom



-- LEGACY: the representation this replaced


type Legacy msg
    = Legacy (VirtualDom.Attribute msg)


{-| The old `Node`, reproduced so the comparison isolates the change and does
not also charge the merged path for the tree layer both shapes share. The old
`Tag` held finished attributes; the new one holds unmerged facts.
-}
type LegacyNode msg
    = LegacyTag String (List (VirtualDom.Attribute msg)) (List (LegacyNode msg))


lAttr : String -> String -> Legacy msg
lAttr name value =
    Legacy (Html.Attributes.attribute name value)


lStyle : List ( String, String ) -> Legacy msg
lStyle declarations =
    lAttr "style" (String.join ";" (List.map (\( k, v ) -> k ++ ":" ++ v) declarations))


lNone : Legacy msg
lNone =
    Legacy (Html.Attributes.style "" "")


legacyNode : List (Legacy msg) -> VirtualDom.Node msg
legacyNode attrs =
    legacyToHtml (LegacyTag "div" (List.map (\(Legacy a) -> a) attrs) [])


legacyToHtml : LegacyNode msg -> VirtualDom.Node msg
legacyToHtml (LegacyTag tag attrs children) =
    VirtualDom.node tag attrs (List.map legacyToHtml children)



-- MERGED: the real path


mergedNode : List (Ir.Attr c msg) -> VirtualDom.Node msg
mergedNode attrs =
    Ir.toHtml (Ir.node "div" attrs [])



-- SHAPES
-- `i` varies one value per iteration so nothing can be hoisted out of the loop.


smallL : Int -> List (Legacy msg)
smallL i =
    [ lAttr "id" (idFor i), lAttr "class" "row" ]


smallM : Int -> List (Ir.Attr c msg)
smallM i =
    [ Ir.attribute "id" (idFor i), Ir.attribute "class" "row" ]


typicalL : Int -> List (Legacy msg)
typicalL i =
    [ lAttr "id" (idFor i)
    , lAttr "class" "m3e-button"
    , lAttr "type" "button"
    , lAttr "aria-label" "Save"
    , lAttr "tabindex" "0"
    , lStyle [ ( "color", "red" ) ]
    ]


typicalM : Int -> List (Ir.Attr c msg)
typicalM i =
    [ Ir.attribute "id" (idFor i)
    , Ir.attribute "class" "m3e-button"
    , Ir.attribute "type" "button"
    , Ir.attribute "aria-label" "Save"
    , Ir.attribute "tabindex" "0"
    , Ir.styles [ ( "color", "red" ) ]
    ]


{-| The case the merge exists for: 3 class facts and 2 style facts. Note the
legacy path does NOT produce the same DOM here — it emits three `class`
attributes the kernel accumulates and two `style` attributes of which one is
silently lost. That is the bug being fixed; the timing is still comparable.
-}
heavyL : Int -> List (Legacy msg)
heavyL i =
    [ lAttr "id" (idFor i)
    , lAttr "class" "m3e-button"
    , lAttr "class" "m3e-button--filled"
    , lAttr "class" (variantFor i)
    , lAttr "type" "button"
    , lAttr "aria-label" "Save"
    , lAttr "aria-describedby" "hint"
    , lAttr "tabindex" "0"
    , lAttr "data-testid" "save"
    , lStyle [ ( "color", "red" ), ( "--m3e-x", "1" ) ]
    , lStyle [ ( "color", "blue" ), ( "padding", "4px" ) ]
    , lAttr "role" "button"
    ]


heavyM : Int -> List (Ir.Attr c msg)
heavyM i =
    [ Ir.attribute "id" (idFor i)
    , Ir.attribute "class" "m3e-button"
    , Ir.attribute "class" "m3e-button--filled"
    , Ir.attribute "class" (variantFor i)
    , Ir.attribute "type" "button"
    , Ir.attribute "aria-label" "Save"
    , Ir.attribute "aria-describedby" "hint"
    , Ir.attribute "tabindex" "0"
    , Ir.attribute "data-testid" "save"
    , Ir.styles [ ( "color", "red" ), ( "--m3e-x", "1" ) ]
    , Ir.styles [ ( "color", "blue" ), ( "padding", "4px" ) ]
    , Ir.attribute "role" "button"
    ]


{-| Half the attributes are `False` booleans. `Ir.none` drops them outright
where the legacy no-op carried an inert style fact all the way into the vdom —
so the fold is partly paid for by facts it never has to handle. The saving on
the DIFF path (fewer facts to compare every render) is not captured here.
-}
boolsL : Int -> List (Legacy msg)
boolsL i =
    [ lAttr "id" (idFor i)
    , lAttr "class" "field"
    , lNone
    , lNone
    , lNone
    , lNone
    , lAttr "name" "email"
    , lAttr "type" "email"
    ]


boolsM : Int -> List (Ir.Attr c msg)
boolsM i =
    [ Ir.attribute "id" (idFor i)
    , Ir.attribute "class" "field"
    , Ir.none
    , Ir.none
    , Ir.none
    , Ir.none
    , Ir.attribute "name" "email"
    , Ir.attribute "type" "email"
    ]


idFor : Int -> String
idFor i =
    if modBy 2 i == 0 then
        "node-a"

    else
        "node-b"


variantFor : Int -> String
variantFor i =
    if modBy 2 i == 0 then
        "is-active"

    else
        "is-idle"



-- HARNESS


{-| The accumulator retains the constructed node so V8 cannot elide the work.
-}
loop : Int -> (Int -> VirtualDom.Node msg) -> ( Int, Maybe (VirtualDom.Node msg) ) -> Int
loop n build ( acc, keep ) =
    if n <= 0 then
        acc
            + (case keep of
                Just _ ->
                    0

                Nothing ->
                    1
              )

    else
        loop (n - 1) build ( acc + 1, Just (build n) )


work : String -> Int -> Int
work name iters =
    let
        run build =
            loop iters build ( 0, Nothing )
    in
    case name of
        "small/legacy" ->
            run (smallL >> legacyNode)

        "small/merged" ->
            run (smallM >> mergedNode)

        "typical/legacy" ->
            run (typicalL >> legacyNode)

        "typical/merged" ->
            run (typicalM >> mergedNode)

        "heavy/legacy" ->
            run (heavyL >> legacyNode)

        "heavy/merged" ->
            run (heavyM >> mergedNode)

        "bools/legacy" ->
            run (boolsL >> legacyNode)

        "bools/merged" ->
            run (boolsM >> mergedNode)

        _ ->
            -1


port request : (( String, Int ) -> msg) -> Sub msg


port result : Int -> Cmd msg


main : Program () () ( String, Int )
main =
    Platform.worker
        { init = \_ -> ( (), Cmd.none )
        , update = \( name, iters ) _ -> ( (), result (work name iters) )
        , subscriptions = \_ -> request identity
        }
