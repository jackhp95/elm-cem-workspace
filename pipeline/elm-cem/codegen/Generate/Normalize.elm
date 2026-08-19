module Generate.Normalize exposing (applySyntheticAttrs, applyTypeOverrides, dropNamelessMembers, mergeComponentsByTagName, normalizeAttrTypes)

import Attr
import Cem
import Dict
import Generate.SharedAttrs exposing (componentModuleName)
import Generate.Types exposing (Config, LibraryInfo)
import Util exposing (deduplicateBy)


{-| Drop attributes/events/slots with empty names once, at the boundary, so the
emit and doc paths don't each have to re-filter them. (A nameless slot is the
default slot, which is addressed via children, not a `slot=""` attribute.)
-}
dropNamelessMembers : Cem.Declaration -> Cem.Declaration
dropNamelessMembers decl =
    let
        named getName =
            List.filter (\x -> not (String.isEmpty (getName x)))
    in
    { decl
        | attributes = named .name decl.attributes
        , events = named .name decl.events
        , slots = named .name decl.slots
    }


{-| Merge two components with the same tagName into one, combining their attributes, events, slots
-}
mergeComponents : Cem.Declaration -> Cem.Declaration -> Cem.Declaration
mergeComponents comp1 comp2 =
    { comp1
        | attributes = deduplicateBy .name (comp1.attributes ++ comp2.attributes)
        , events = deduplicateBy .name (comp1.events ++ comp2.events)
        , slots = deduplicateBy .name (comp1.slots ++ comp2.slots)
        , description =
            case ( comp1.description, comp2.description ) of
                ( Just desc1, Just desc2 ) ->
                    if String.length desc1 > String.length desc2 then
                        Just desc1

                    else
                        Just desc2

                ( Just desc, Nothing ) ->
                    Just desc

                ( Nothing, Just desc ) ->
                    Just desc

                ( Nothing, Nothing ) ->
                    Nothing
    }


{-| Stamp config-supplied type overrides (R12) onto the matching attributes so
every downstream `Attr.fromCem` — per-component AND shared-vocab AND value-token
paths alike — classifies them the overridden way, from ONE injection point. The
override is keyed by component MODULE name (as the rest of `_config` is) and, per
component, by the attribute's manifest name (kebab, e.g. `disable-pagination`),
mirroring `requiredAttrs`. Components/attributes with no override are untouched, so
this is a no-op for any manifest whose config omits `attrTypes` (library-agnostic).
-}
applyTypeOverrides : LibraryInfo -> Config -> List Cem.Declaration -> List Cem.Declaration
applyTypeOverrides libraryInfo config components =
    let
        overridesFor : Cem.Declaration -> List ( String, Cem.AttrTypeOverride )
        overridesFor component =
            Dict.get (componentModuleName libraryInfo component) config
                |> Maybe.map .attrTypes
                |> Maybe.withDefault []

        stamp : List ( String, Cem.AttrTypeOverride ) -> Cem.Attribute -> Cem.Attribute
        stamp overrides attribute =
            case
                overrides
                    |> List.filter (\( name, _ ) -> name == attribute.name)
                    |> List.head
            of
                Just ( _, override ) ->
                    { attribute | typeOverride = Just override }

                Nothing ->
                    attribute
    in
    components
        |> List.map
            (\component ->
                case overridesFor component of
                    [] ->
                        component

                    overrides ->
                        { component | attributes = List.map (stamp overrides) component.attributes }
            )


{-| Inject config-supplied SYNTHETIC attributes (issue #38) onto the matching
components as ordinary `Cem.Attribute` entries, so every downstream path —
classification (per-component setter + phantom capability
row), the shared vocab, and the `Token`/`Value` emitters alike — treats them like
any real CEM attribute, from ONE injection point (mirroring `applyTypeOverrides`).

Each synthetic attr carries an `elmNameOverride` so its Elm-facing setter /
capability name can differ from its HTML name (e.g. `tocIgnore` vs
`m3e-toc-ignore`), and a `typeOverride` so its classified type is forced from
config rather than a CEM `type.text` it does not have. Keyed by component MODULE
name, as the rest of `_config` is. Components with no `syntheticAttrs` are
untouched, so this is a no-op for any manifest whose config omits it
(library-agnostic).

A synthetic attr whose HTML name collides with a real declared attribute is
dropped (the real one wins) rather than producing a duplicate setter.

-}
applySyntheticAttrs : LibraryInfo -> Config -> List Cem.Declaration -> List Cem.Declaration
applySyntheticAttrs libraryInfo config components =
    let
        syntheticsFor component =
            Dict.get (componentModuleName libraryInfo component) config
                |> Maybe.map .syntheticAttrs
                |> Maybe.withDefault []

        toAttribute synthetic =
            { name = synthetic.htmlName
            , description = synthetic.description
            , type_ = Nothing
            , default = Nothing
            , fieldName = Nothing
            , typeOverride = Just synthetic.type_
            , elmNameOverride = Just synthetic.elmName
            , global = False
            }
    in
    components
        |> List.map
            (\component ->
                case syntheticsFor component of
                    [] ->
                        component

                    synthetics ->
                        let
                            declaredNames =
                                List.map .name component.attributes

                            injected =
                                synthetics
                                    |> List.filter (\s -> not (List.member s.htmlName declaredNames))
                                    |> List.map toAttribute
                        in
                        { component | attributes = component.attributes ++ injected }
            )


{-| Merge components that have the same tagName but different names (e.g., PickerBase and Picker both with sp-picker)
This combines their attributes, events, slots, etc. into a single component definition.
-}
mergeComponentsByTagName : List Cem.Declaration -> List Cem.Declaration
mergeComponentsByTagName components =
    components
        |> List.foldl
            (\component acc ->
                case component.tagName of
                    Nothing ->
                        component :: acc

                    Just tagName ->
                        -- Merge key is (tagName, NAME): true duplicates (the
                        -- same class re-listed) merge; DISTINCT declarations
                        -- sharing a tag survive — that is the R2 split
                        -- mechanism (source vs pictureSource on tag "source").
                        case List.partition (\existing -> existing.tagName == Just tagName && existing.name == component.name) acc of
                            ( [], others ) ->
                                component :: others

                            ( existing :: _, others ) ->
                                mergeComponents existing component :: others
            )
            []


{-| Fill in attribute types the CEM left null (`type_ = Nothing`) by inheriting the
type of the same-named attribute where OTHER components declare it — but only when
every non-null declaration of that name classifies identically. This repairs
boolean attributes like `open` (m3e-dialog) and `required` (m3e-radio) that most
components declare `type: boolean` while a few leave untyped; without it the
untyped ones degrade to a `String` setter with HTML presence semantics, so
`open "false"` still renders open (issue elm-m3e#95). Names with no typed sibling
or with conflicting sibling types are left untouched (→ `String`, unchanged).
-}
normalizeAttrTypes : List Cem.Declaration -> List Cem.Declaration
normalizeAttrTypes components =
    let
        typedOccurrences : Dict.Dict String (List Cem.TypeInfo)
        typedOccurrences =
            components
                |> List.concatMap .attributes
                |> List.filterMap (\a -> Maybe.map (\t -> ( a.name, t )) a.type_)
                |> List.foldl
                    (\( n, t ) acc -> Dict.update n (\m -> Just (t :: Maybe.withDefault [] m)) acc)
                    Dict.empty

        inherited : Dict.Dict String Cem.TypeInfo
        inherited =
            typedOccurrences
                |> Dict.toList
                |> List.filterMap
                    (\( n, tis ) ->
                        case tis of
                            first :: rest ->
                                if List.all (\ti -> Attr.classifyText ti.text == Attr.classifyText first.text) rest then
                                    Just ( n, first )

                                else
                                    Nothing

                            [] ->
                                Nothing
                    )
                |> Dict.fromList

        fill : Cem.Attribute -> Cem.Attribute
        fill a =
            case a.type_ of
                Just _ ->
                    a

                Nothing ->
                    { a | type_ = Dict.get a.name inherited }
    in
    List.map (\c -> { c | attributes = List.map fill c.attributes }) components
