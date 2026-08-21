module Generate.Phantom.Emit.Facts exposing (..)


import Attr
import Cem
import Char
import Dict
import Docs
import Elm
import Generate.Phantom.Model as M exposing (Brand, Comp, EnumSpec, KindField, Marker(..), ResolvedSlot, SlotContent(..))
import Json.Encode as Encode
import Naming

import Generate.Phantom.Emit.AttrsRow exposing (..)
import Generate.Phantom.Emit.Shared exposing (..)


-- REVIEW FACTS (the elm-review-cem contract, emitted from the phantom model)


factsModule : Brand -> Elm.File
factsModule brand =
    let
        lib =
            brand.lib

        str s =
            "\"" ++ s ++ "\""

        strList xs =
            "[ " ++ (xs |> List.map str |> String.join ", ") ++ " ]"

        pairList ps =
            "[ " ++ (ps |> List.map (\( a, b ) -> "( " ++ str a ++ ", " ++ str b ++ " )") |> String.join ", ") ++ " ]"

        enumPairs es =
            "[ "
                ++ (es
                        |> List.map (\e -> "( " ++ str e.elmName ++ ", " ++ strList (List.map (tokenIdentResolved brand) e.tokens) ++ " )")
                        |> String.join ", "
                   )
                ++ " ]"

        slotKindPairs comp =
            -- Permissive (kind-`any`) slots are OMITTED: an unlisted slot is
            -- unchecked by ValidSlotKind (listing "arbitrary" as a literal
            -- kind made everything a violation).
            "[ "
                ++ (comp.slots
                        |> List.filterMap
                            (\s ->
                                let
                                    -- The Cem.Facts contract speaks the CONFIG
                                    -- vocabulary: shared atoms are
                                    -- "shared:<role>", brand kinds are ctor
                                    -- names (field == ctor for private kinds).
                                    kindString f =
                                        case f.marker of
                                            MShared ->
                                                "shared:" ++ Naming.decapitalize (String.dropLeft 6 f.field)

                                            MBrand ->
                                                f.field
                                in
                                case s.content of
                                    Permissive ->
                                        Nothing

                                    SetContent set ->
                                        Just ( s.name, set.fields |> List.map kindString )

                                    Fields fs ->
                                        Just ( s.name, fs |> List.map kindString )
                            )
                        |> List.map (\( n, kinds ) -> "( " ++ str n ++ ", " ++ strList kinds ++ " )")
                        |> String.join ", "
                   )
                ++ " ]"

        facetsOf comp =
            "[ Standard"
                ++ (if not (List.isEmpty (comp.slots |> List.filter .required)) || comp.actionCaps /= Nothing then
                        ", Record"

                    else
                        ""
                   )
                ++ ", Build ]"

        factOf comp =
            let
                moduleName =
                    lib ++ ".Element." ++ (memberRef brand comp).module_

                attrRewrites =
                    (comp.attrs |> List.map (\a -> ( a.elmName, a.elmName )))
                        -- The `default*` companions are real setters on this component's
                        -- module, so elm-review's barrel/per-component rules have to see
                        -- them; an unlisted setter reads as "not an attr of this element".
                        ++ (companionsFor brand comp.propertyOnly comp.attrs |> List.map (\( _, n, _ ) -> ( n, n )))
                        -- …and so are the `_variants` setters.
                        ++ (variantsFor brand comp.attrs |> List.map (\( v, _ ) -> ( v.name, v.name )))
                        ++ (comp.events |> List.map (\e -> ( handlerName brand e, handlerName brand e )))

                namedSlots =
                    comp.slots |> List.filter (\s -> s.name /= "unnamed")
            in
            String.join "\n"
                [ "    { component = " ++ str comp.ctor
                , "    , module_ = " ++ str moduleName
                , "    , enums = " ++ enumPairs comp.enums
                , "    , requiredSlots = " ++ strList (comp.slots |> List.filter .required |> List.map .name)
                , "    , multiSlots = " ++ strList (comp.slots |> List.filter .multi |> List.map .name)
                , "    , attrRewrites = " ++ pairList attrRewrites
                , "    , slotRewrites = " ++ pairList (namedSlots |> List.map (\s -> ( s.name, Naming.camel s.name )))
                , "    , slotKinds = " ++ slotKindPairs comp
                , "    , slotUpgrades = []"
                , "    , groupConstructors = []"
                , "    , facets = " ++ facetsOf comp
                , "    , requiredAttrs = " ++ strList comp.requiredAttrs
                , "    , actionMap = " ++ pairList comp.actionMap
                , "    , usesAction = "
                    ++ (if comp.actionCaps /= Nothing then
                            "True"

                        else
                            "False"
                       )
                , "    }"
                ]
    in
    file [ lib, "Review", "Facts" ]
        (String.join "\n"
            [ "module " ++ lib ++ ".Review.Facts exposing (facts, globalAttributes, reExposedValueTokens)"
            , ""
            , "{-| GENERATED review facts for the elm-review-cem rules (phantom pipeline)."
            , ""
            , "@docs facts, globalAttributes, reExposedValueTokens"
            , ""
            , "-}"
            , ""
            , "import Cem.Facts exposing (Fact, Facet(..))"
            , ""
            , ""
            , "{-| Per-component facts."
            , "-}"
            , "facts : List Fact"
            , "facts ="
            , "    [ "
                ++ (brand.comps |> List.map factOf |> String.join "\n    , " |> String.dropLeft 4)
            , "    ]"
            , ""
            , ""
            , "{-| The document-wide attributes EVERY element of this brand admits — the"
            , "`_globals` roster."
            , ""
            , "Emitted for the escape-discipline rules, which may only suggest a typed"
            , "setter when the attribute's meaning is **element-independent**. A global"
            , "qualifies by definition; an element-specific attribute does not, because from"
            , "an escape call site `content` on a `<meta>` is indistinguishable from"
            , "`content` on a custom element that gives the name its own meaning."
            , ""
            , "-}"
            , "globalAttributes : List String"
            , "globalAttributes ="

            -- Both row shapes: `globalAttributes` answers "is this attribute's
            -- meaning element-INDEPENDENT?", which is the very property that
            -- justified opening the row. Reading `brand.globals` alone would
            -- silently shrink this roster the moment a brand opened an entry.
            , "    " ++ strList (allGlobals brand |> List.map .htmlName |> List.sort)
            , ""
            , ""
            , "{-| Kept for the PreferBarrel flatten class; inert on the phantom surface."
            , "-}"
            , "reExposedValueTokens : List String"
            , "reExposedValueTokens ="
            , "    []"
            , ""
            ]
        )



