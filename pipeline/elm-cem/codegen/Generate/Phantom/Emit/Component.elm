module Generate.Phantom.Emit.Component exposing (..)


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


-- PER-COMPONENT MODULE


{-| A component module's re-exportable surface — see `compSurface`'s doc
comment for the field-by-field meaning.
-}
type alias ComponentSurface =
    { exposing_ : List String
    , types : Dict.Dict String String
    , valueAnnotations : Dict.Dict String String
    }


{-| Everything `compModule` needs to assemble `<Lib>.Component.<Name>`'s
source text, AND everything `compSurface` (G3, generator-consolidation)
needs to describe that same module's re-exportable surface — computed ONCE
by `componentCore` and consumed by both, so they can never independently
drift (`compSurface` is not a re-derivation from rendered text; it reads the
exact same values `compModule` renders from). Fields ending in `Annotations`
pair each exposed VALUE name with its rendered type-signature text — the
data `Generate.Phantom.Emit.FamilyPackage` needs to copy an element's
annotation (with type refs re-prefixed) into a flat family module, ported
from gen-family-package.js's now-removed `parseModuleSurface` regex parser
(which had to re-derive this by reading the rendered `.elm` file back off
disk; here it is captured at the point of construction instead).
-}
type alias ComponentCore =
    { lib : String
    , unnamed : Maybe ResolvedSlot
    , namedSlots : List ResolvedSlot
    , contentAliases : List { alias_ : String, slotName : String, row : String }
    , exposeGroups : List (List String)
    , exposing_ : String
    , docs_ : String
    , imports : List String
    , aliasDecls : List String
    , elDecl : List String
    , componentAnnotation : String
    , hasEl : Bool
    , enumSetters : List String
    , enumSetterAnnotations : List ( String, String )
    , attrReExportNames : List String
    , attrReExports : List String
    , attrReExportNeedsValues : Bool
    , attrReExportAnnotations : List ( String, String )
    , eventReExports : List String
    , eventAnnotations : List ( String, String )
    , slotSetters : List String
    , slotSetterAnnotations : List ( String, String )
    , defaultChildSetter : List String
    , defaultChildAnnotation : Maybe ( String, String )
    , exampleDocLines : List String
    }


componentCore : Brand -> Comp -> ComponentCore
componentCore brand comp =
    let
        lib =
            brand.lib

        unnamed =
            comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head

        namedSlots =
            comp.slots |> List.filter (\s -> s.name /= "unnamed")

        singularSlots =
            namedSlots |> List.filter (not << .multi)

        requiredSlots =
            comp.slots |> List.filter .required

        -- config `requiredAttrs` (kebab manifest names, e.g. `aria-label`) as
        -- ( elm record field, html attr name ) pairs. These become REQUIRED
        -- fields on the `component`/`build` record — an accessible name can't be
        -- omitted on an icon-only control (a11y by construction).
        reqAttrFields =
            comp.requiredAttrs |> List.map (\a -> ( Naming.camel a, a ))

        hasEl =
            not (List.isEmpty requiredSlots) || comp.actionCaps /= Nothing || not (List.isEmpty reqAttrFields)

        contentAlias : ResolvedSlot -> Maybe { alias_ : String, slotName : String, row : String }
        contentAlias s =
            case s.content of
                Fields fs ->
                    Just
                        { alias_ =
                            if s.name == "unnamed" then
                                "Content"

                            else
                                Naming.pascal s.name ++ "Slot"
                        , slotName = s.name
                        , row = kindRowCompact fs
                        }

                _ ->
                    Nothing

        contentAliases =
            comp.slots |> List.filterMap contentAlias

        contentTypeOf : ResolvedSlot -> String
        contentTypeOf s =
            case s.content of
                Permissive ->
                    "childAccepts"

                SetContent set ->
                    set.pascal

                Fields _ ->
                    if s.name == "unnamed" then
                        "Content"

                    else
                        Naming.pascal s.name ++ "Slot"

        childListType : ResolvedSlot -> String
        childListType s =
            "List (Element " ++ contentTypeOf s ++ " (ChildAdmittedBy childAdm) msg)"

        returnType =
            "Element (Is s) "
                ++ (case comp.admittedBy of
                        Just _ ->
                            "AdmittedBy"

                        Nothing ->
                            "admittedBy"
                   )
                ++ " msg"

        childrenSig =
            case unnamed of
                Just s ->
                    childListType s

                Nothing ->
                    "List (Element childAccepts (ChildAdmittedBy childAdm) msg)"

        setNames =
            comp.slots
                |> List.filterMap
                    (\s ->
                        case s.content of
                            SetContent set ->
                                Just set.pascal

                            _ ->
                                Nothing
                    )

        usesShared =
            comp.produces.marker
                == MShared
                || List.any (\a -> String.contains "Shared" a.row) contentAliases

        eventNames =
            comp.events |> List.map (handlerName brand)

        exposeGroups =
            [ [ "component" ]
            , [ "Is", "Attrs", "Builder", "AttrCaps", "SlotCaps" ]
                ++ List.map .alias_ contentAliases
                ++ [ "ChildAdmittedBy" ]
                ++ (case comp.admittedBy of
                        Just _ ->
                            [ "AdmittedBy" ]

                        Nothing ->
                            []
                   )
                ++ (case comp.actionCaps of
                        Just _ ->
                            [ "ActionCaps" ]

                        Nothing ->
                            []
                   )
            , comp.enums |> List.concatMap (\e -> [ e.aliasName, e.elmName ])
            , attrReExportNames ++ eventNames
            , (namedSlots |> List.map (\s -> Naming.camel s.name))
                ++ (case unnamed of
                        Just _ ->
                            [ "child" ]

                        Nothing ->
                            []
                   )
            ]

        exposing_ =
            exposeBlock exposeGroups

        docs_ =
            docsBlock exposeGroups

        kindImports =
            (([ "Available", "Brand", "Ctx", "Used" ]
                |> List.filter
                    (\m ->
                        m
                            /= "Brand"
                            || comp.produces.marker
                            == MBrand
                            || List.any (\a -> String.contains ": Brand" a.row) contentAliases
                    )
             )
                ++ setNames
            )
                |> List.sort

        irKindExposing =
            (if usesShared then
                [ "Shared", "Supported" ]

             else
                [ "Supported" ]
            )
                |> String.join ", "

        -- R4: alias the frequently-referenced imports to cut per-use bytes.
        -- `A` = <Lib>.Attributes, `Ev` = <Lib>.Events, `Ac` = <Lib>.Action,
        -- `B` = <Lib>.Forge.Internal (the shared builder forge), `El` =
        -- HtmlIr.Element, `Val` = HtmlIr.Value. The one-time header cost buys a
        -- shorter body on every setter/builder line.
        imports =
            List.concat
                [ [ "import HtmlIr.Attribute exposing (Attr)"
                  , "import HtmlIr.Element as El exposing (Element)"
                  , "import HtmlIr.Internal as Ir"
                  , "import HtmlIr.Kind exposing (" ++ irKindExposing ++ ")"
                  ]
                , if not (List.isEmpty comp.enums) || attrReExportNeedsValues then
                    -- `Val.toString` is called by this module's OWN enum setters.
                    [ "import HtmlIr.Value as Val exposing (Value)" ]

                  else if hasEnumGlobal brand then
                    -- Only the global pipes' SIGNATURES need `Value`; nothing here
                    -- calls `Val.toString` (the global setter in `<Lib>.Attributes`
                    -- does), so the alias is omitted rather than left dangling.
                    [ "import HtmlIr.Value exposing (Value)" ]

                  else
                    []
                , if attrReExportNeedsValues || hasEnumGlobal brand then
                    [ "import " ++ lib ++ ".Values" ]

                  else
                    []
                , if needsJsonEncodeImport brand comp.attrs then
                    [ "import Json.Encode" ]

                  else
                    []
                , [ "import " ++ lib ++ ".Attributes as A" ]
                , [ "import " ++ lib ++ ".Html as H" ]
                , [ "import " ++ lib ++ ".Internal.Types." ++ comp.name ]
                , if List.isEmpty eventNames then
                    []

                  else
                    [ "import " ++ lib ++ ".Events as Ev" ]
                , case comp.actionCaps of
                    Just _ ->
                        [ "import " ++ lib ++ ".Action as Ac" ]

                    Nothing ->
                        []
                , if List.isEmpty comp.eventOverrides then
                    []

                  else
                    [ "import Json.Decode" ]
                , [ "import " ++ lib ++ ".Kind exposing (" ++ String.join ", " kindImports ++ ")" ]
                ]
                |> List.sort

        isDoc =
            case comp.produces.marker of
                MShared ->
                    "The kind row `"
                        ++ comp.tag
                        ++ "` produces — the SHARED "
                        ++ Naming.camel (String.dropLeft 6 comp.produces.field)
                        ++ " atom kind, admissible\ninto any library's opted-in slot."

                MBrand ->
                    "The kind row `" ++ comp.tag ++ "` produces (open — composes into any slot naming it)."

        internalRef n =
            lib ++ ".Internal.Types." ++ comp.name ++ "." ++ n

        aliasDecls =
            [ doc isDoc
            , "type alias Is s ="
            , "    " ++ internalRef "Is" ++ " s"
            , ""
            , ""
            , doc "The closed attribute-capability row."
            , "type alias Attrs ="
            , "    " ++ internalRef "Attrs"
            ]
                ++ (contentAliases
                        |> List.concatMap
                            (\a ->
                                [ ""
                                , ""
                                , doc
                                    (if a.alias_ == "Content" then
                                        "The kinds the default slot admits."

                                     else
                                        "The kinds the `" ++ a.slotName ++ "` slot admits."
                                    )
                                , "type alias " ++ a.alias_ ++ " ="
                                , "    " ++ internalRef a.alias_
                                ]
                            )
                   )
                ++ [ ""
                   , ""
                   , doc "The context demand this container injects into each child's admittedBy row."
                   , "type alias ChildAdmittedBy childAdm ="
                   , "    " ++ internalRef "ChildAdmittedBy" ++ " childAdm"
                   ]
                ++ (case comp.admittedBy of
                        Just parents ->
                            let
                                parentTags =
                                    parents
                                        |> List.map
                                            (\p ->
                                                brand.comps
                                                    |> List.filter (\c -> c.ctor == p)
                                                    |> List.head
                                                    |> Maybe.map .tag
                                                    |> Maybe.withDefault p
                                            )
                                        |> List.map (\t -> "`" ++ t ++ "`")
                                        |> String.join ", "
                            in
                            [ ""
                            , ""
                            , doc
                                ("The CLOSED parent contexts this element is valid inside — `"
                                    ++ comp.tag
                                    ++ "` is\nonly writable as a direct child of "
                                    ++ parentTags
                                    ++ "."
                                )
                            , "type alias AdmittedBy ="
                            , "    " ++ internalRef "AdmittedBy"
                            ]

                        Nothing ->
                            []
                   )
                ++ (comp.enums
                        |> List.concatMap
                            (\e ->
                                [ ""
                                , ""
                                , doc ("The `" ++ e.elmName ++ "` values valid on this component (compile-tight narrowing).")
                                , "type alias " ++ e.aliasName ++ " ="
                                , "    " ++ internalRef e.aliasName
                                ]
                            )
                   )
                ++ (case comp.actionCaps of
                        Just caps ->
                            [ ""
                            , ""
                            , doc ("The behaviours this component's required action admits (see `" ++ lib ++ ".Action`).")
                            , "type alias ActionCaps ="
                            , "    " ++ internalRef "ActionCaps"
                            ]

                        Nothing ->
                            []
                   )
                ++ [ ""
                   , ""
                   , doc ("The narrowed pipe-builder this component's `" ++ lib ++ ".Build.<X>` module exposes.")
                   , "type alias Builder attrCaps slotCaps msg kind ="
                   , "    " ++ internalRef "Builder" ++ " attrCaps slotCaps msg kind"
                   , ""
                   , ""
                   , doc "The attribute capabilities this component's builder admits."
                   , "type alias AttrCaps ="
                   , "    " ++ internalRef "AttrCaps"
                   ]
                ++ (let
                        slotCapsBody =
                            capsRecord "Available" (singularSlots |> List.map (.name >> Naming.camel))
                    in
                    [ ""
                    , ""
                    , doc "The singular-slot capabilities this component's builder admits."
                    , "type alias SlotCaps ="
                    , "    "
                        ++ (if String.trim slotCapsBody == "{}" then
                                slotCapsBody

                            else
                                internalRef "SlotCaps"
                           )
                    ]
                   )

        viewDocText =
            case Maybe.map .content unnamed of
                Just Permissive ->
                    "Standard constructor: `[attributes] [children]`. The default slot is\nkind-permissive (`any`): children of any kind compose, but each child's OWN\nadmittedBy must still admit this context — a restricted-parent element is\nrejected here at compile time."

                Just (SetContent set) ->
                    "Standard constructor: `[attributes] [children]`. The default slot admits\nthe `" ++ set.name ++ "` kind set — see `" ++ lib ++ ".Kind." ++ set.pascal ++ "`."

                _ ->
                    "Standard constructor: `[attributes] [children]`."

        -- Hoisted OUT of `elDecl`'s own else-branch (still used only there for
        -- rendering) so `componentAnnotation` below can share the identical
        -- `reqRecord` value rather than re-deriving it — computed unconditionally
        -- (cheap; unused when `hasEl == False`).
        reqField s =
            ( if s.name == "unnamed" then
                "content"

              else
                Naming.camel s.name
            , "Element " ++ contentTypeOf s ++ " (ChildAdmittedBy childAdm) msg"
            )

        reqFields =
            (requiredSlots |> List.map reqField)
                ++ (reqAttrFields |> List.map (\( f, _ ) -> ( f, "String" )))
                ++ (case comp.actionCaps of
                        Just _ ->
                            [ ( "action", "Ac.Action ActionCaps msg" ) ]

                        Nothing ->
                            []
                   )

        reqRecord =
            "{ "
                ++ (reqFields |> List.map (\( n, t ) -> n ++ " : " ++ t) |> String.join "\n    , ")
                ++ " }"

        -- The exact annotation text `component` gets, shared verbatim between
        -- `elDecl`'s rendering and `compSurface`'s `valueAnnotations`.
        componentAnnotation =
            if hasEl then
                "    " ++ reqRecord ++ "\n    -> List (Attr Attrs msg)\n    -> " ++ childrenSig ++ "\n    -> " ++ returnType

            else
                "    List (Attr Attrs msg)\n    -> " ++ childrenSig ++ "\n    -> " ++ returnType

        -- The single per-component constructor, `component`. TWO ARITIES:
        --   * zero required fields  -> bare `component : attrs -> children -> Element`
        --     (formerly the `view` function),
        --   * >=1 required field    -> record-arg
        --     `component : { .. } -> attrs -> children -> Element`.
        -- Exactly one public function name per component either way.
        elDecl =
            if not hasEl then
                [ doc viewDocText, "component :" ]
                    ++ String.split "\n" componentAnnotation
                    ++ [ "component =", "    H." ++ comp.resolvedCtor ]

            else
                let
                    place s =
                        if s.name == "unnamed" then
                            case comp.actionCaps of
                                Just _ ->
                                    "actioned"

                                Nothing ->
                                    "required_.content"

                        else
                            "Ir.fromNode (Ir.addAttribute (Ir.attribute \"slot\" \"" ++ s.name ++ "\") (El.toNode required_." ++ Naming.camel s.name ++ "))"

                    consed =
                        requiredSlots
                            |> List.map place
                            |> List.foldr (\p acc -> p ++ " :: " ++ acc) "children"

                    -- required-attr setters, prepended to the attrs list so an
                    -- accessible name (etc.) is always stamped. Emitted inline
                    -- (`Ir.attribute "<html-name>"`) so the required-name
                    -- enforcement is self-contained — it does NOT depend on the
                    -- attr being exposed as a global/plain setter.
                    reqAttrsPrefix =
                        reqAttrFields
                            |> List.map (\( f, html ) -> "Ir.attribute \"" ++ html ++ "\" required_." ++ f ++ " :: ")
                            |> String.concat

                    body =
                        case comp.actionCaps of
                            Just _ ->
                                [ "component required_ attrs children ="
                                , "    let"
                                , "        actioned ="
                                , "            Ir.fromNode (" ++ "Ac.wrapContent required_.action (El.toNode required_.content))"
                                , "    in"
                                , "    H." ++ comp.resolvedCtor
                                , "        (" ++ reqAttrsPrefix ++ "Ac.toAttrs required_.action ++ attrs)"
                                , "        (" ++ consed ++ ")"
                                ]

                            Nothing ->
                                [ "component required_ attrs children ="
                                , "    H."
                                    ++ comp.resolvedCtor
                                    ++ " "
                                    ++ (if String.isEmpty reqAttrsPrefix then
                                            "attrs"

                                        else
                                            "(" ++ reqAttrsPrefix ++ "attrs)"
                                       )
                                    ++ " ("
                                    ++ consed
                                    ++ ")"
                                ]
                in
                ([ doc "Required-content (and action) constructor — omissions are unwritable."
                 , "component :"
                 ]
                    ++ String.split "\n" componentAnnotation
                )
                    ++ body

        enumSetterItems =
            comp.enums
                |> List.map
                    (\e ->
                        let
                            matchingAttr =
                                comp.attrs
                                    |> List.filter (\a -> a.elmName == e.elmName)
                                    |> List.head

                            htmlName =
                                matchingAttr
                                    |> Maybe.map .htmlName
                                    |> Maybe.withDefault e.elmName

                            docText =
                                matchingAttr
                                    |> Maybe.map Attr.docString
                                    |> Maybe.withDefault ("Set the `" ++ e.elmName ++ "` value.")

                            ann =
                                "Value " ++ e.aliasName ++ " -> Attr { c | " ++ e.elmName ++ " : Supported } msg"
                        in
                        { name = e.elmName
                        , ann = ann
                        , textLines =
                            [ ""
                            , ""
                            , doc docText
                            , e.elmName ++ " : " ++ ann
                            , e.elmName ++ " value_ ="
                            , "    Ir.attribute \"" ++ htmlName ++ "\" (Val.toString value_)"
                            ]
                        }
                    )

        enumSetters =
            enumSetterItems |> List.concatMap .textLines

        enumSetterAnnotations =
            enumSetterItems |> List.map (\i -> ( i.name, "    " ++ i.ann ))

        attrReExportResult =
            reExportBlock brand
                "A"
                (comp.ctor
                    :: (comp.enums |> List.map .elmName)
                    ++ (namedSlots |> List.map (\s -> Naming.camel s.name))
                )
                comp.propertyOnly
                comp.attrs

        attrReExportNames =
            attrReExportResult.names

        attrReExports =
            attrReExportResult.lines

        attrReExportNeedsValues =
            attrReExportResult.needsValues

        attrReExportAnnotations =
            attrReExportResult.annotations

        overrideFor evName =
            comp.eventOverrides |> List.filter (\o -> o.name == evName) |> List.head

        eventReExportItems =
            comp.events
                |> List.map
                    (\ev ->
                        let
                            n =
                                handlerName brand ev
                        in
                        case overrideFor ev.name of
                            Just o ->
                                let
                                    ( elmTy, dec ) =
                                        overrideTypes o.type_

                                    pathExpr =
                                        "[ " ++ (o.path |> List.map (\s -> "\"" ++ s ++ "\"") |> String.join ", ") ++ " ]"

                                    ann =
                                        "(" ++ elmTy ++ " -> msg) -> Attr { c | " ++ n ++ " : Supported } msg"
                                in
                                { name = n
                                , ann = ann
                                , textLines =
                                    [ ""
                                    , ""
                                    , doc ("Typed `" ++ ev.name ++ "` event: decodes `" ++ String.join "." o.path ++ "` as " ++ elmTy ++ ".")
                                    , n ++ " : " ++ ann
                                    , n ++ " toMsg ="
                                    , "    Ir.on \"" ++ ev.name ++ "\" (Json.Decode.map toMsg (Json.Decode.at " ++ pathExpr ++ " " ++ dec ++ "))"
                                    ]
                                }

                            Nothing ->
                                case ev.payload of
                                    Just payload ->
                                        -- A standard-payload annotation: re-export the
                                        -- payload-typed setter from the shared Events
                                        -- module, matching its `(payload -> msg)` shape.
                                        let
                                            ( elmTy, _ ) =
                                                payloadTypeAndDecoder payload

                                            ann =
                                                "(" ++ elmTy ++ " -> msg) -> Attr { c | " ++ n ++ " : Supported } msg"
                                        in
                                        { name = n
                                        , ann = ann
                                        , textLines =
                                            [ ""
                                            , ""
                                            , doc ("See `" ++ lib ++ ".Events." ++ n ++ "`.")
                                            , n ++ " : " ++ ann
                                            , n ++ " ="
                                            , "    Ev." ++ n
                                            ]
                                        }

                                    Nothing ->
                                        let
                                            ann =
                                                "msg -> Attr { c | " ++ n ++ " : Supported } msg"
                                        in
                                        { name = n
                                        , ann = ann
                                        , textLines =
                                            [ ""
                                            , ""
                                            , doc ("See `" ++ lib ++ ".Events." ++ n ++ "`.")
                                            , n ++ " : " ++ ann
                                            , n ++ " ="
                                            , "    Ev." ++ n
                                            ]
                                        }
                    )

        eventReExports =
            eventReExportItems |> List.concatMap .textLines

        eventAnnotations =
            eventReExportItems |> List.map (\i -> ( i.name, "    " ++ i.ann ))

        slotSetterItems =
            namedSlots
                |> List.map
                    (\s ->
                        let
                            ann =
                                "Element " ++ contentTypeOf s ++ " admittedBy msg -> Element free freeAdmittedBy msg"
                        in
                        { name = Naming.camel s.name
                        , ann = ann
                        , textLines =
                            [ ""
                            , ""
                            , doc
                                ("Place an element into the named `"
                                    ++ s.name
                                    ++ "` slot (input constrained to the\nslot's kinds; output row free so it composes into the child list)."
                                )
                            , Naming.camel s.name ++ " : " ++ ann
                            , Naming.camel s.name ++ " element ="
                            , "    Ir.fromNode (Ir.addAttribute (Ir.attribute \"slot\" \"" ++ s.name ++ "\") (El.toNode element))"
                            ]
                        }
                    )

        slotSetters =
            slotSetterItems |> List.concatMap .textLines

        slotSetterAnnotations =
            slotSetterItems |> List.map (\i -> ( i.name, "    " ++ i.ann ))

        -- Default-slot wrapper: the list-form sibling of the builder's `withChild`.
        -- Mirrors the named-slot wrappers' shape (input constrained to the default
        -- slot's kinds; output row freed so it composes into the child list), but
        -- adds no `slot` attribute — the default slot is the absence of one.
        defaultChildSetterItem =
            case unnamed of
                Just s ->
                    let
                        ann =
                            "Element " ++ contentTypeOf s ++ " admittedBy msg -> Element free freeAdmittedBy msg"
                    in
                    Just
                        { name = "child"
                        , ann = ann
                        , textLines =
                            [ ""
                            , ""
                            , doc "Place a pre-built element into the default (unnamed) slot (input\nconstrained to the slot's kinds; output row free so it composes into the\nchild list). The list-form sibling of the builder's `withChild`."
                            , "child : " ++ ann
                            , "child element ="
                            , "    Ir.fromNode (El.toNode element)"
                            ]
                        }

                Nothing ->
                    Nothing

        defaultChildSetter =
            defaultChildSetterItem |> Maybe.map .textLines |> Maybe.withDefault []

        defaultChildAnnotation =
            defaultChildSetterItem |> Maybe.map (\i -> ( i.name, "    " ++ i.ann ))

        -- Config-supplied `## Examples` section + opaque doc-metadata marker
        -- (`examples`/`docMeta` config keys — see `Docs.examplesSection`/
        -- `Docs.docMetaMarker`). Both render to "" when the component's config
        -- supplies neither, which is the common case, so the extra doc-comment
        -- line is omitted entirely rather than leaving a stray blank line on
        -- every component that has no examples.
        exampleDoc =
            Docs.examplesSection comp.examples ++ Docs.docMetaMarker comp.docMeta

        exampleDocLines =
            if String.isEmpty exampleDoc then
                []

            else
                [ exampleDoc ]
    in
    { lib = lib
    , unnamed = unnamed
    , namedSlots = namedSlots
    , contentAliases = contentAliases
    , exposeGroups = exposeGroups
    , exposing_ = exposing_
    , docs_ = docs_
    , imports = imports
    , aliasDecls = aliasDecls
    , elDecl = elDecl
    , componentAnnotation = componentAnnotation
    , hasEl = hasEl
    , enumSetters = enumSetters
    , enumSetterAnnotations = enumSetterAnnotations
    , attrReExportNames = attrReExportNames
    , attrReExports = attrReExports
    , attrReExportNeedsValues = attrReExportNeedsValues
    , attrReExportAnnotations = attrReExportAnnotations
    , eventReExports = eventReExports
    , eventAnnotations = eventAnnotations
    , slotSetters = slotSetters
    , slotSetterAnnotations = slotSetterAnnotations
    , defaultChildSetter = defaultChildSetter
    , defaultChildAnnotation = defaultChildAnnotation
    , exampleDocLines = exampleDocLines
    }


{-| Render `<Lib>.Component.<Name>` — thin assembly over `componentCore`'s
shared computation; every field referenced below is EXACTLY what the
pre-refactor `compModule` computed inline (see `componentCore`), so this is
a pure relocation, not a behavior change.
-}
compModule : Brand -> Comp -> Elm.File
compModule brand comp =
    let
        core =
            componentCore brand comp
    in
    file [ core.lib, "Element", comp.name ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ core.lib ++ ".Element." ++ comp.name ++ " exposing"
                  , core.exposing_
                  , ""
                  , "{-| The `" ++ comp.tag ++ "` component — strict per-component surface."
                  , ""
                  , comp.description
                  , ""
                  , core.docs_
                  ]
                , core.exampleDocLines
                , [ ""
                  , "-}"
                  , ""
                  ]
                , core.imports
                , [ "", "" ]
                , core.aliasDecls
                , [ "", "" ]
                , core.elDecl
                , core.enumSetters
                , core.attrReExports
                , core.eventReExports
                , core.slotSetters
                , core.defaultChildSetter
                , [ "" ]
                ]
            )
        )


{-| The re-exportable surface of `<Lib>.Component.<Name>`, for
`Generate.Phantom.Emit.FamilyPackage`'s flat family modules (G3,
generator-consolidation) to re-export ADDITIVELY without ever reading
`compModule`'s rendered text back — derived from the SAME `componentCore`
computation `compModule` renders from, so the two can never drift.

  - `exposing_` — every name this component module exposes, in module-header
    order (types and values interleaved exactly as `compModule` declares
    them).
  - `types` — each exposed Capitalized name's type-alias parameter string
    (`""` when the alias takes none, e.g. `"s"` for `Is s`, `"childAdm"` for
    `ChildAdmittedBy childAdm`, `"attrCaps slotCaps msg kind"` for
    `Builder ...`) — the SAME literal parameter lists `componentCore`'s
    `aliasDecls` renders, restated here as data rather than parsed back out
    of that rendered text.
  - `valueAnnotations` — each exposed lowercase name's exact rendered type
    signature (multi-line for `component`'s required-record arity; single
    -line, `"    "`-indented for everything else — matching the shape
    `gen-family-package.js`'s `parseModuleSurface` used to extract from
    rendered text via regex, now captured directly at construction).

-}
compSurface : Brand -> Comp -> ComponentSurface
compSurface brand comp =
    let
        core =
            componentCore brand comp

        types =
            ([ ( "Is", "s" )
             , ( "Attrs", "" )
             , ( "Builder", "attrCaps slotCaps msg kind" )
             , ( "AttrCaps", "" )
             , ( "SlotCaps", "" )
             , ( "ChildAdmittedBy", "childAdm" )
             ]
                ++ (core.contentAliases |> List.map (\a -> ( a.alias_, "" )))
                ++ (case comp.admittedBy of
                        Just _ ->
                            [ ( "AdmittedBy", "" ) ]

                        Nothing ->
                            []
                   )
                ++ (case comp.actionCaps of
                        Just _ ->
                            [ ( "ActionCaps", "" ) ]

                        Nothing ->
                            []
                   )
                ++ (comp.enums |> List.map (\e -> ( e.aliasName, "" )))
            )
                |> Dict.fromList

        valueAnnotations =
            ( "component", core.componentAnnotation )
                :: core.enumSetterAnnotations
                ++ core.attrReExportAnnotations
                ++ core.eventAnnotations
                ++ core.slotSetterAnnotations
                ++ (core.defaultChildAnnotation |> Maybe.map List.singleton |> Maybe.withDefault [])
                |> Dict.fromList
    in
    { exposing_ = List.concat core.exposeGroups
    , types = types
    , valueAnnotations = valueAnnotations
    }


{-| Emit the unexposed internal-types module (`M3e.Internal.Types.<Component>`).
Contains the heavy record-row type definitions currently inline in `compModule`.
This module is NOT in any package's `exposed-modules`, so its types appear as
short qualified references in docs.json rather than expanded record rows.

The empty-row skip rule: trivial aliases (empty `{}`) are NOT moved here —
kept inline in the component module to avoid a net-negative savings.
-}
internalTypesModule : Brand -> Comp -> Elm.File
internalTypesModule brand comp =
    let
        lib =
            brand.lib

        unnamed =
            comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head

        namedSlots =
            comp.slots |> List.filter (\s -> s.name /= "unnamed")

        singularSlots =
            namedSlots |> List.filter (not << .multi)

        contentAlias : ResolvedSlot -> Maybe { alias_ : String, slotName : String, row : String }
        contentAlias s =
            case s.content of
                Fields fs ->
                    Just
                        { alias_ =
                            if s.name == "unnamed" then
                                "Content"

                            else
                                Naming.pascal s.name ++ "Slot"
                        , slotName = s.name
                        , row = kindRowCompact fs
                        }

                _ ->
                    Nothing

        contentAliases =
            comp.slots |> List.filterMap contentAlias

        kindImports =
            ([ "Available", "Brand", "Ctx", "Used" ]
                |> List.filter
                    (\m ->
                        m
                            /= "Brand"
                            || comp.produces.marker
                            == MBrand
                            || List.any (\a -> String.contains ": Brand" a.row) contentAliases
                    )
            )
                ++ (comp.slots
                        |> List.filterMap
                            (\s ->
                                case s.content of
                                    SetContent set ->
                                        Just set.pascal

                                    _ ->
                                        Nothing
                            )
                   )
                |> List.sort

        usesShared =
            comp.produces.marker
                == MShared
                || List.any (\a -> String.contains "Shared" a.row) contentAliases

        needsValueImport =
            not (List.isEmpty comp.enums) || (comp.attrs |> List.any (\a -> isEnumSpec a)) || hasEnumGlobal brand

        imports =
            List.concat
                [ [ "import HtmlIr.Kind exposing (" ++ (if usesShared then "Shared, Supported" else "Supported") ++ ")" ]
                , [ "import " ++ lib ++ ".Kind exposing (" ++ String.join ", " kindImports ++ ")" ]
                , if needsValueImport then
                    [ "import HtmlIr.Value as Val exposing (Value)" ]

                  else
                    []
                , [ "import " ++ lib ++ ".Forge.Internal as B" ]
                ]

        slotCapsBody =
            capsRecord "Available" (singularSlots |> List.map (.name >> Naming.camel))

        isEmptyBody body =
            String.trim body == "{}"

        aliasDefs =
            [ ""
            , "type alias Is s ="
            , "    { s | " ++ comp.produces.field ++ " : " ++ markerName comp.produces.marker ++ " }"
            , ""
            , ""
            , "type alias Attrs ="
            , "    " ++ supportedRow (attrsFields brand comp)
            ]
                ++ (contentAliases
                        |> List.concatMap
                            (\a ->
                                [ ""
                                , ""
                                , "type alias " ++ a.alias_ ++ " ="
                                , "    " ++ a.row
                                ]
                            )
                   )
                ++ [ ""
                   , ""
                   , "type alias ChildAdmittedBy childAdm ="
                   , "    { childAdm | " ++ comp.ctor ++ " : Ctx }"
                   ]
                ++ (case comp.admittedBy of
                        Just parents ->
                            [ ""
                            , ""
                            , "type alias AdmittedBy ="
                            , "    { " ++ (parents |> List.map (\p -> p ++ " : Ctx") |> String.join ", ") ++ " }"
                            ]

                        Nothing ->
                            []
                   )
                ++ (comp.enums
                        |> List.concatMap
                            (\e ->
                                [ ""
                                , ""
                                , "type alias " ++ e.aliasName ++ " ="
                                , "    " ++ supportedRow (e.tokens |> List.map (tokenIdentResolved brand))
                                ]
                            )
                   )
                ++ (case comp.actionCaps of
                        Just caps ->
                            [ ""
                            , ""
                            , "type alias ActionCaps ="
                            , "    " ++ supportedRow (caps |> List.map Naming.safeField |> List.sort)
                            ]

                        Nothing ->
                            []
                   )
                ++ [ ""
                   , ""
                   , "type alias Builder attrCaps slotCaps msg s ="
                   , "    B.Builder Attrs attrCaps slotCaps (Is s) msg"
                   , ""
                   , ""
                   , "type alias AttrCaps ="
                   , "    " ++ capsRecord "Available" (attrsFields brand comp)
                   ]
                ++ (if isEmptyBody slotCapsBody then
                        []

                    else
                        [ ""
                        , ""
                        , "type alias SlotCaps ="
                        , "    " ++ slotCapsBody
                        ]
                   )

        -- Barrel-in-core (design §3.2a): these type definitions live in the `core`
        -- tier and are re-exported by both the `M3e` barrel (core) AND the strict
        -- `M3e.Component.<C>` surfaces (elements) — so `core` must publicly expose
        -- them for the cross-package (elements → core) re-export to resolve. A
        -- published package module cannot use `exposing (..)`, so enumerate the
        -- exposed names by scanning `aliasDefs` (kept DRY — cannot drift from the
        -- definitions above; the module contains only these type aliases).
        typeAliasName line =
            if String.startsWith "type alias " line then
                line
                    |> String.dropLeft (String.length "type alias ")
                    |> String.words
                    |> List.head

            else
                Nothing

        exposedNames =
            aliasDefs |> List.filterMap typeAliasName

        -- A published module must document every exposed declaration (elm make
        -- --docs enforces both `@docs` coverage AND a doc comment on each). Inject
        -- a one-line doc comment directly above every `type alias` (kept DRY off
        -- the same lines the exposing list is derived from).
        documentedAliasDefs =
            aliasDefs
                |> List.concatMap
                    (\line ->
                        case typeAliasName line of
                            Just nm ->
                                [ "{-| The `" ++ nm ++ "` type row for " ++ comp.name ++ " (generated). -}", line ]

                            Nothing ->
                                [ line ]
                    )
    in
    file [ lib, "Internal", "Types", comp.name ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ lib ++ ".Internal.Types." ++ comp.name ++ " exposing (" ++ String.join ", " exposedNames ++ ")"
                  , ""
                  , "{-| Type definitions for " ++ comp.name ++ ". The canonical home of this"
                  , "component's `Attrs`/`Is`/`Content`/… rows: the `" ++ lib ++ "` barrel and the strict"
                  , "`" ++ lib ++ ".Element." ++ comp.name ++ "` surface both re-export these, so they live in"
                  , "the shared `core` tier (design §3.2a)."
                  , ""
                  , "@docs " ++ String.join ", " exposedNames
                  , "-}"
                  , ""
                  ]
                , imports
                , [ ""
                  , ""
                  ]
                , documentedAliasDefs
                , [ "" ]
                ]
            )
        )


{-| Emit the per-component builder module (`M3e.<Component>.Build`). Each
builder module encapsulates the builder pattern for one component: seeds
(`build`), builder-accepting slot placers/pipes, and attr pipes re-exported
from the component module. The `accepts` phantom is pinned to `(Component.Is s)`,
so `toElement` produces `Element (Component.Is s) admittedBy msg`.
-}
compBuildModule : Brand -> Comp -> Elm.File
compBuildModule brand comp =
    let
        lib =
            brand.lib

        unnamed =
            comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head

        namedSlots =
            comp.slots |> List.filter (\s -> s.name /= "unnamed")

        singularSlots =
            namedSlots |> List.filter (not << .multi)

        variadicSlots =
            namedSlots |> List.filter .multi

        requiredSlots =
            comp.slots |> List.filter .required

        reqAttrFields =
            comp.requiredAttrs |> List.map (\a -> ( Naming.camel a, a ))

        hasEl =
            not (List.isEmpty requiredSlots) || comp.actionCaps /= Nothing || not (List.isEmpty reqAttrFields)

        eventNames =
            comp.events |> List.map (handlerName brand)

        overrideFor evName =
            comp.eventOverrides |> List.filter (\o -> o.name == evName) |> List.head

        contentAlias : ResolvedSlot -> Maybe { alias_ : String, slotName : String, row : String }
        contentAlias s =
            case s.content of
                Fields fs ->
                    Just
                        { alias_ =
                            if s.name == "unnamed" then
                                "Content"

                            else
                                Naming.pascal s.name ++ "Slot"
                        , slotName = s.name
                        , row = kindRowCompact fs
                        }

                _ ->
                    Nothing

        contentAliases =
            comp.slots |> List.filterMap contentAlias

        contentTypeOf : ResolvedSlot -> String
        contentTypeOf s =
            case s.content of
                Permissive ->
                    "childAccepts"

                SetContent set ->
                    set.pascal

                Fields _ ->
                    if s.name == "unnamed" then
                        "Component.Content"

                    else
                        "Component." ++ Naming.pascal s.name ++ "Slot"

        returnType =
            "Element ("
                ++ lib
                ++ "."
                ++ comp.name
                ++ ".Is s) "
                ++ (case comp.admittedBy of
                        Just _ ->
                            "(" ++ lib ++ "." ++ comp.name ++ ".AdmittedBy)"

                        Nothing ->
                            "admittedBy"
                   )
                ++ " msg"

        -- K5: full top-level namespace from the component module, used so
        -- slot pipe naming matches what the component module used (avoids
        -- a spurious conflict where one module renames and the other doesn't).
        attrPipeNames =
            attrsFields brand comp |> List.map (\f -> "with" ++ Naming.pascal f)

        compTopLevelNamespace =
            List.concat
                [ [ comp.resolvedCtor ]
                , comp.attrs |> List.map .elmName
                , attrPipeNames
                , comp.events |> List.map (handlerName brand)
                ]

        slotPipeNameOf s =
            let
                plain =
                    "with" ++ Naming.pascal s.name
            in
            if List.member plain compTopLevelNamespace then
                plain ++ "Slot"

            else
                plain

        slotPlacerNames =
            namedSlots |> List.map (\s -> Naming.camel s.name)

        singularSlotPipeNames =
            singularSlots |> List.map slotPipeNameOf

        variadicSlotPipeNames =
            variadicSlots |> List.map slotPipeNameOf

        contentAliasNames =
            contentAliases |> List.map .alias_

        -- Builder-relevant type aliases to expose
        typeAliasExposeNames =
            [ "Builder", "AttrCaps", "SlotCaps", "Is" ]
                ++ contentAliasNames
                ++ [ "ChildAdmittedBy" ]
                ++ (case comp.admittedBy of
                        Just _ ->
                            [ "AdmittedBy" ]

                        Nothing ->
                            []
                   )
                ++ (case comp.actionCaps of
                        Just _ ->
                            [ "ActionCaps" ]

                        Nothing ->
                            []
                   )

        internalRef n =
            "Component." ++ n

        -- Re-export component's content type aliases
        contentAliasReExports =
            contentAliases
                |> List.concatMap
                    (\a ->
                        [ ""
                        , ""
                        , "{-| -}"
                        , "type alias " ++ a.alias_ ++ " ="
                        , "    " ++ internalRef a.alias_
                        ]
                    )

        contentAliasDocs =
            contentAliases
                |> List.concatMap
                    (\a ->
                        [ ""
                        , "@docs " ++ a.alias_
                        ]
                    )

        exposeGroups =
            [ [ "build", "toElement" ]
            , typeAliasExposeNames
            , attrPipeNames
            , slotPlacerNames
            , singularSlotPipeNames
                ++ variadicSlotPipeNames
                ++ (case unnamed of
                        Just _ ->
                            [ "withChild" ]

                        Nothing ->
                            []
                   )
            ]

        exposing_ =
            exposeBlock exposeGroups

        docs_ =
            docsBlock exposeGroups

        buildDecl =
            if hasEl then
                let
                    seedChildren =
                        requiredSlots
                            |> List.map
                                (\s ->
                                    if s.name == "unnamed" then
                                        "El.toNode required_.content"

                                    else
                                        "El.toNode (Component." ++ Naming.camel s.name ++ " required_." ++ Naming.camel s.name ++ ")"
                                )

                    seedAttrs =
                        case comp.actionCaps of
                            Just _ ->
                                "Ac.toAttrs required_.action"

                            Nothing ->
                                if List.isEmpty reqAttrFields then
                                    "[]"

                                else
                                    "[ "
                                        ++ (reqAttrFields |> List.map (\( f, html ) -> "Ir.attribute \"" ++ html ++ "\" required_." ++ f) |> String.join ", ")
                                        ++ " ]"

                    seedChildren_ =
                        case comp.actionCaps of
                            Just _ ->
                                seedChildren
                                    |> List.map
                                        (\s ->
                                            if s == "El.toNode required_.content" then
                                                "Ac.wrapContent required_.action (El.toNode required_.content)"

                                            else
                                                s
                                        )

                            Nothing ->
                                seedChildren

                    reqFields =
                        (requiredSlots
                            |> List.map
                                (\s ->
                                    ( if s.name == "unnamed" then
                                        "content"

                                      else
                                        Naming.camel s.name
                                    , "Element (" ++ contentTypeOf s ++ ") (" ++ "Component.ChildAdmittedBy childAdm) msg"
                                    )
                                )
                        )
                            ++ (reqAttrFields |> List.map (\( f, _ ) -> ( f, "String" )))
                            ++ (case comp.actionCaps of
                                    Just _ ->
                                        [ ( "action", "Ac.Action (Component.ActionCaps) msg" ) ]

                                    Nothing ->
                                        []
                               )
                in
                [ ""
                , ""
                , "{-| -}"
                , "build :"
                , "    { "
                    ++ (reqFields |> List.map (\( n, t ) -> n ++ " : " ++ t) |> String.join "\n    , ")
                    ++ " }"
                , "    -> Builder AttrCaps SlotCaps msg kind"
                , "build required_ ="
                , "    B.init \"" ++ comp.tag ++ "\" (" ++ seedAttrs ++ ") [ " ++ String.join ", " seedChildren_ ++ " ]"
                ]

            else
                [ ""
                , ""
                , "{-| -}"
                , "build : Builder AttrCaps SlotCaps msg kind"
                , "build ="
                , "    B.init \"" ++ comp.tag ++ "\" [] []"
                ]

        -- Slot placers: builder-accepting versions of the component's slot setters.
        -- Each takes a B.Builder, calls B.toElement internally, then delegates to
        -- the component's slot placer. Constrains `accepts` to the slot's content
        -- type for a better error message (the error points at the call site).
        slotPlacers =
            namedSlots
                |> List.concatMap
                    (\s ->
                        [ ""
                        , ""
                        , "{-| -}"
                        , Naming.camel s.name ++ " :"
                        , "    B.Builder childRow childAttrCaps childSlotCaps (" ++ contentTypeOf s ++ ") msg"
                        , "    -> Element free freeAdmittedBy msg"
                        , Naming.camel s.name ++ " builder ="
                        , "    " ++ "Component." ++ Naming.camel s.name ++ " (B.toElement builder)"
                        ]
                    )

        -- Slot pipes: builder-accepting versions that consume slot capabilities.
        singularSlotPipes =
            singularSlots
                |> List.concatMap
                    (\s ->
                        let
                            n =
                                slotPipeNameOf s
                        in
                        [ ""
                        , ""
                        , "{-| -}"
                        , n ++ " :"
                        , "    B.Builder childRow childAttrCaps childSlotCaps (" ++ contentTypeOf s ++ ") msg"
                        , "    -> Builder attrCaps { s | " ++ Naming.camel s.name ++ " : Available } msg kind"
                        , "    -> Builder attrCaps { s | " ++ Naming.camel s.name ++ " : Used } msg kind"
                        , n ++ " slotBuilder builder_ ="
                        , "    B.withChild (El.toNode (" ++ "Component." ++ Naming.camel s.name ++ " (B.toElement slotBuilder))) builder_"
                        ]
                    )

        variadicSlotPipes =
            variadicSlots
                |> List.concatMap
                    (\s ->
                        let
                            n =
                                slotPipeNameOf s
                        in
                        [ ""
                        , ""
                        , "{-| -}"
                        , n ++ " :"
                        , "    B.Builder childRow childAttrCaps childSlotCaps (" ++ contentTypeOf s ++ ") msg"
                        , "    -> Builder attrCaps slotCaps msg kind"
                        , "    -> Builder attrCaps slotCaps msg kind"
                        , n ++ " slotBuilder builder_ ="
                        , "    B.withChild (El.toNode (" ++ "Component." ++ Naming.camel s.name ++ " (B.toElement slotBuilder))) builder_"
                        ]
                    )

        -- Default child pipe (builder-accepting, universally quantified accepts)
        childPipe =
            case unnamed of
                Just s ->
                    [ ""
                    , ""
                    , "{-| -}"
                    , "withChild :"
                    , "    B.Builder childRow childAttrCaps childSlotCaps accepts msg"
                    , "    -> Builder attrCaps slotCaps msg kind"
                    , "    -> Builder attrCaps slotCaps msg kind"
                    , "withChild childBuilder builder_ ="
                    , "    B.withChild (El.toNode (B.toElement childBuilder)) builder_"
                    ]

                Nothing ->
                    []

        -- R2/R3: each `withX` is a thin `B.withAttribute` wrapper; the
        -- phantom-row transition lives in the signature.
        pipeFor : String -> String -> String -> List String
        pipeFor capField inputSig applied =
            pipeForParams capField
                inputSig
                (if String.isEmpty inputSig then
                    []

                 else
                    [ "value_" ]
                )
                applied

        -- Explicit parameter names, because not every setter is unary: `style`
        -- takes a property AND a value (the elm/html 0.19 shape).
        pipeForParams : String -> String -> List String -> String -> List String
        pipeForParams capField inputSig params applied =
            let
                n =
                    "with" ++ Naming.pascal capField
            in
            [ ""
            , ""
            , "{-| -}"
            , n ++ " : " ++ inputSig ++ "Builder { a | " ++ capField ++ " : Available } slotCaps msg kind -> Builder { a | " ++ capField ++ " : Used } slotCaps msg kind"
            , n
                ++ (if List.isEmpty params then
                        " ="

                    else
                        " " ++ String.join " " params ++ " ="
                   )
            , "    B.withAttribute (" ++ applied ++ ")"
            ]

        attrPipes =
            (brand.globals
                |> List.map
                    (\g ->
                        if g.elmName == "style" then
                            -- The one non-unary global (the elm/html 0.19 shape),
                            -- so it cannot go through `pipeFor`.
                            pipeForParams "style" "String -> String -> " [ "property", "value_" ] "A.style property value_"

                        else
                            pipeFor g.capName (globalSetterInputType brand g ++ " -> ") ("A." ++ g.elmName ++ " value_")
                    )
            )
                ++ (comp.attrs
                        |> List.map
                            (\a ->
                                case ( isEnumSpec a, unionFor brand a.elmName ) of
                                    ( True, _ ) ->
                                        -- Component-local enum: delegate to the component's
                                        -- own setter (which holds the right Value row).
                                        pipeFor a.capName ("Value Component." ++ Naming.pascal a.elmName ++ " -> ") ("Component." ++ a.elmName ++ " value_")

                                    ( _, Just _ ) ->
                                        -- Enum ELSEWHERE but plain on this member: inline
                                        -- the member's own setter rather than delegating.
                                        pipeFor a.capName (setterInputType a ++ " -> ") (setterExpr a)

                                    ( _, Nothing ) ->
                                        if divergesFromCanonical brand a then
                                            -- Type OR form divergence: inline rather than
                                            -- delegating to `A.<attr>`, which would write
                                            -- the canonical's kind of fact.
                                            pipeFor a.capName (setterInputType a ++ " -> ") (setterExpr a)

                                        else
                                            pipeFor a.capName (setterInputType a ++ " -> ") ("A." ++ a.elmName ++ " value_")
                            )
                   )
                ++ (comp.events
                        |> List.map
                            (\ev ->
                                case overrideFor ev.name of
                                    Just o ->
                                        let
                                            ( elmTy, _ ) =
                                                overrideTypes o.type_
                                        in
                                        -- Override handler lives in the Component module.
                                        pipeFor (handlerName brand ev) ("(" ++ elmTy ++ " -> msg) -> ") ("Component." ++ handlerName brand ev ++ " value_")

                                    Nothing ->
                                        case ev.payload of
                                            Just payload ->
                                                let
                                                    ( elmTy, _ ) =
                                                        payloadTypeAndDecoder payload
                                                in
                                                pipeFor (handlerName brand ev) ("(" ++ elmTy ++ " -> msg) -> ") ("Ev." ++ handlerName brand ev ++ " value_")

                                            Nothing ->
                                                pipeFor (handlerName brand ev) "msg -> " ("Ev." ++ handlerName brand ev ++ " value_")
                            )
                   )
                |> List.concat

        kindImports =
            ([ "Available", "Brand", "Ctx", "Used" ]
                |> List.filter
                    (\m ->
                        m
                            /= "Brand"
                            || comp.produces.marker
                            == MBrand
                            || List.any (\a -> String.contains ": Brand" a.row) contentAliases
                    )
            )
                ++ (comp.slots
                        |> List.filterMap
                            (\s ->
                                case s.content of
                                    SetContent set ->
                                        Just set.pascal

                                    _ ->
                                        Nothing
                            )
                   )
                |> List.sort

        usesShared =
            comp.produces.marker
                == MShared
                || List.any (\a -> String.contains "Shared" a.row) contentAliases

        irKindExposing =
            (if usesShared then
                [ "Shared", "Supported" ]

             else
                [ "Supported" ]
            )
                |> String.join ", "

        needsValuesImport =
            not (List.isEmpty comp.enums)
                || hasEnumGlobal brand
                || (comp.attrs |> List.any (\a -> isEnumSpec a))

        imports =
            List.concat
                [ [ "import HtmlIr.Element as El exposing (Element)"
                  , "import HtmlIr.Internal as Ir"
                  , "import HtmlIr.Kind exposing (" ++ irKindExposing ++ ")"
                  ]
                , if not (List.isEmpty comp.enums) || hasEnumGlobal brand then
                    [ "import HtmlIr.Value as Val exposing (Value)" ]

                  else
                    []
                , if needsValuesImport then
                    [ "import " ++ lib ++ ".Values" ]

                  else
                    []
                , [ "import " ++ lib ++ ".Attributes as A" ]
                , [ "import " ++ lib ++ ".Forge.Internal as B" ]
                , if List.isEmpty eventNames then
                    []

                  else
                    [ "import " ++ lib ++ ".Events as Ev" ]
                , if needsJsonEncodeImport brand comp.attrs then
                    [ "import Json.Encode" ]

                  else
                    []
                , [ "import " ++ lib ++ ".Kind exposing (" ++ String.join ", " kindImports ++ ")" ]
                , [ "import " ++ lib ++ ".Element." ++ comp.name ++ " as Component" ]
                ]
                ++ (case comp.actionCaps of
                        Just _ ->
                            [ "import " ++ lib ++ ".Action as Ac" ]

                        Nothing ->
                            []
                   )
                |> List.sort

        isDoc =
            if comp.transparent then
                "The kind this element produces is transparent — it inherits its parent's kind."

            else
                "The kind this element produces — a `Brand` that marks the phantom row."

        kindReturnType =
            "Element (Component.Is kind) "
                ++ (case comp.admittedBy of
                        Just _ ->
                            "(Component.AdmittedBy)"

                        Nothing ->
                            "admittedBy"
                   )
                ++ " msg"
    in
    file [ lib, "Build", comp.name ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ lib ++ ".Build." ++ comp.name ++ " exposing"
                  , exposing_
                  , ""
                  , "{-|"
                  , docs_
                  , "-}"
                  , ""
                  ]
                , imports
                , [ ""
                  , ""
                  , "{-| -}"
                  , "type alias Is s ="
                  , "    " ++ internalRef "Is" ++ " s"
                  , ""
                  , ""
                  , "{-| -}"
                  , "type alias Builder attrCaps slotCaps msg kind ="
                  , "    " ++ internalRef "Builder" ++ " attrCaps slotCaps msg kind"
                  , ""
                  , ""
                  , "{-| -}"
                  , "type alias AttrCaps ="
                  , "    " ++ internalRef "AttrCaps"
                  , ""
                  , ""
                  ]
                    ++ (let
                            slotCapsBody =
                                capsRecord "Available" (singularSlots |> List.map (.name >> Naming.camel))
                        in
                        if String.trim slotCapsBody == "{}" then
                            [ "{-| -}"
                            , "type alias SlotCaps ="
                            , "    " ++ slotCapsBody
                            ]

                        else
                            [ "{-| -}"
                            , "type alias SlotCaps ="
                            , "    " ++ internalRef "SlotCaps"
                            ]
                       )
                    ++ [ ""
                       , ""
                       , "{-| -}"
                       , "type alias ChildAdmittedBy childAdm ="
                       , "    " ++ internalRef "ChildAdmittedBy" ++ " childAdm"
                       ]
                     ++ (case comp.admittedBy of
                            Just _ ->
                                [ ""
                                , ""
                                , "{-| -}"
                                , "type alias AdmittedBy ="
                                , "    " ++ internalRef "AdmittedBy"
                                ]

                            Nothing ->
                                []
                       )
                     ++ (case comp.actionCaps of
                            Just _ ->
                                [ ""
                                , ""
                                , "{-| -}"
                                , "type alias ActionCaps ="
                                , "    " ++ internalRef "ActionCaps"
                                ]

                            Nothing ->
                                []
                       )
                    ++ contentAliasReExports
                    ++ buildDecl
                    ++ [ ""
                       , ""
                       , "{-| -}"
                       , "toElement : Builder attrCaps slotCaps msg kind -> " ++ kindReturnType
                       , "toElement ="
                       , "    B.toElement"
                       ]
                    ++ slotPlacers
                    ++ singularSlotPipes
                    ++ variadicSlotPipes
                    ++ childPipe
                    ++ attrPipes
                    ++ [ "" ]
                ]
            )
        )




{-| The input type a GLOBAL's setter takes, spelled for a module that reaches the
setter through `<Lib>.Attributes` (a builder pipe, a re-export).

Scalars follow `setterInputType`; an ENUM global resolves to its brand-wide
`<Lib>.Values` row — unlike a per-component enum, whose row alias is declared
locally in the component module, a global's row has exactly one home.

The `Nothing` arm is unreachable: `Model.resolveWith` puts an `EnumSpec` into
`Brand.unions` for every enum global, so an enum global always has a row.

-}
globalSetterInputType : Brand -> Attr.AttrSpec -> String
globalSetterInputType brand g =
    case ( isEnumSpec g, unionFor brand g.elmName ) of
        ( True, Just union ) ->
            "Value " ++ brand.lib ++ ".Values." ++ union.aliasName

        _ ->
            setterInputType g



