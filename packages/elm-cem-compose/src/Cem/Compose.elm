module Cem.Compose exposing
    ( Model, init, Msg(..), update
    , Node, Child(..), AttrValue(..), AttrKind(..)
    , PathStep(..), Path, MenuKind(..)
    , nodeAt, factAt
    , componentOf, attrsOf, slotsOf
    , SlotAffordances, SlotChipInfo, slotChips
    , SlotOption(..), slotMenuOptions
    , AttrChipInfo, AttrChipKind(..), attrChips
    )

{-| A headless, type-directed editor for building a valid tree of custom
elements from a machine-readable component manifest (`Cem.Facts`).

This module renders nothing and has no side effects. It owns the tree,
path-addressed edit logic, and pure query functions; the consumer writes
every pixel.

@docs Model, init, Msg, update
@docs Node, Child, AttrValue, AttrKind
@docs PathStep, Path, MenuKind
@docs nodeAt, factAt
@docs componentOf, attrsOf, slotsOf
@docs SlotAffordances, SlotChipInfo, slotChips
@docs SlotOption, slotMenuOptions
@docs AttrChipInfo, AttrChipKind, attrChips

-}

import Cem.Facts exposing (Fact)
import Dict exposing (Dict)
import List.Extra


{-| One configured attribute value.

Numeric values carry raw entry text, not `Float`/`Int`: a user mid-typing
`"1."` or `"-"` would have the character eaten on every keystroke if the model
stored a parsed number. Parsing happens at the point of use, and an
unparseable value simply contributes no attribute.

`AttrFloat` and `AttrInt` are distinct despite both holding `String` because
codegen must emit `String.fromFloat` vs `String.fromInt` shapes.

-}
type AttrValue
    = AttrBool Bool
    | AttrString String
    | AttrFloat String
    | AttrInt String
    | AttrEnum String


{-| The shape of a non-enum attribute. Enum-ness is not a member: whether an
attribute is an enum is answered by whether its name appears in `fact.enums`.
-}
type AttrKind
    = BoolAttr
    | StringAttr
    | FloatAttr
    | IntAttr


{-| One element in the tree. Opaque: the slot-cardinality invariant is
maintained by `update`, so no consumer may construct a two-element non-multi
slot.
-}
type Node
    = Node
        { component : String
        , attrs : Dict String AttrValue
        , children : Dict String (List Child)
        }


{-| What occupies one position in a slot.

The variant is decided at CHOICE time — a slot advertises every mode its
`kinds` permit and the user picks one. It is not a fixed per-slot property.

-}
type Child
    = ChildNode Node
    | ChildText String
    | ChildIcon String


{-| One descent: into a named slot, at an index.
-}
type PathStep
    = IntoSlot String Int


{-| Read root-first. `[]` is the root node.
-}
type alias Path =
    List PathStep


{-| Which chip's menu is live.
-}
type MenuKind
    = AttrMenu String
    | SlotMenu String


{-| The whole editor state. `facts` is indexed by `Fact.component` because
every query does a lookup.
-}
type alias Model =
    { root : Node
    , facts : Dict String Fact
    , attrKinds : Dict String AttrKind
    , openMenu : Maybe ( Path, MenuKind )
    }


{-| `root` is the component name the empty tree starts at. If it is not among
`facts` the model is still constructed and every query on it returns empty.
-}
init :
    { facts : List Fact
    , attrKinds : Dict String AttrKind
    , root : String
    }
    -> Model
init config =
    { root = emptyNode config.root
    , facts =
        List.foldl (\f -> Dict.insert f.component f) Dict.empty config.facts
    , attrKinds = config.attrKinds
    , openMenu = Nothing
    }


emptyNode : String -> Node
emptyNode name =
    Node { component = name, attrs = Dict.empty, children = Dict.empty }



-- MESSAGES


{-| Every edit. No `Cmd`, no `Effect`: the core has no side effects.
-}
type Msg
    = SetAttr Path String AttrValue
    | ClearAttr Path String
    | OpenMenu Path MenuKind
    | CloseMenu
    | AddChild Path String String
    | AddTextChild Path String
    | AddIconChild Path String
    | SetChildContent Path String Int String
    | RemoveChild Path String Int


{-| Every structural message applies `updateAt` and then clears `openMenu` —
selecting a value dismisses its menu.
-}
update : Msg -> Model -> Model
update msg model =
    case msg of
        OpenMenu path kind ->
            { model | openMenu = Just ( path, kind ) }

        CloseMenu ->
            { model | openMenu = Nothing }

        SetAttr path name value ->
            edit path (setAttr name value) model

        ClearAttr path name ->
            edit path (removeAttr name) model

        AddChild path slot component ->
            addIfAfforded path slot (\a -> List.member component a.components) (ChildNode (emptyNode component)) model

        AddTextChild path slot ->
            addIfAfforded path slot .text (ChildText "") model

        AddIconChild path slot ->
            addIfAfforded path slot .icon (ChildIcon "star") model

        SetChildContent path slot index text ->
            edit path (setChildContent slot index text) model

        RemoveChild path slot index ->
            edit path (removeChild slot index) model


{-| Apply a node transform at a path and dismiss any open menu.
-}
edit : Path -> (Node -> Node) -> Model -> Model
edit path f model =
    { model | root = updateAt path f model.root, openMenu = Nothing }


closeMenu : Model -> Model
closeMenu model =
    { model | openMenu = Nothing }


{-| Insert a child only if the slot's affordances permit that kind. This is the
other half of "no menu ever offers an option that produces no effect": what the
menu does not offer, the core does not do.
-}
addIfAfforded : Path -> String -> (SlotAffordances -> Bool) -> Child -> Model -> Model
addIfAfforded path slot permitted child model =
    case affordancesAt path slot model of
        Just affordances ->
            if permitted affordances then
                edit path (insertChild model slot child) model

            else
                closeMenu model

        Nothing ->
            closeMenu model


setAttr : String -> AttrValue -> Node -> Node
setAttr name value (Node n) =
    Node { n | attrs = Dict.insert name value n.attrs }


removeAttr : String -> Node -> Node
removeAttr name (Node n) =
    Node { n | attrs = Dict.remove name n.attrs }


{-| Append on a multi slot; replace on every other slot. This cap is a model
invariant, not a convention — which is why `Node` is opaque.
-}
insertChild : Model -> String -> Child -> Node -> Node
insertChild model slot child ((Node n) as node) =
    let
        isMulti =
            Dict.get n.component model.facts
                |> Maybe.map (\f -> List.member slot f.multiSlots)
                |> Maybe.withDefault False

        existing =
            Dict.get slot n.children |> Maybe.withDefault []
    in
    Node
        { n
            | children =
                Dict.insert slot
                    (if isMulti then
                        existing ++ [ child ]

                     else
                        [ child ]
                    )
                    n.children
        }


setChildContent : String -> Int -> String -> Node -> Node
setChildContent slot index text ((Node n) as node) =
    case Dict.get slot n.children of
        Nothing ->
            node

        Just children ->
            case List.Extra.getAt index children of
                Just (ChildText _) ->
                    Node { n | children = Dict.insert slot (List.Extra.setAt index (ChildText text) children) n.children }

                Just (ChildIcon _) ->
                    Node { n | children = Dict.insert slot (List.Extra.setAt index (ChildIcon text) children) n.children }

                _ ->
                    node


removeChild : String -> Int -> Node -> Node
removeChild slot index ((Node n) as node) =
    case Dict.get slot n.children of
        Nothing ->
            node

        Just children ->
            if index < 0 || index >= List.length children then
                node

            else
                Node { n | children = Dict.insert slot (List.Extra.removeAt index children) n.children }


{-| The single recursive locator. Descends only through `ChildNode`; a step
landing on text/icon content, an out-of-range index, or an unknown slot is a
no-op returning the tree unchanged. Compose never crashes on a stale path.
-}
updateAt : Path -> (Node -> Node) -> Node -> Node
updateAt path f ((Node n) as node) =
    case path of
        [] ->
            f node

        (IntoSlot slot index) :: rest ->
            case Dict.get slot n.children of
                Nothing ->
                    node

                Just children ->
                    case List.Extra.getAt index children of
                        Just (ChildNode child) ->
                            Node
                                { n
                                    | children =
                                        Dict.insert slot
                                            (List.Extra.setAt index (ChildNode (updateAt rest f child)) children)
                                            n.children
                                }

                        _ ->
                            node



-- NAVIGATION


{-| `Nothing` for any path that does not resolve to a `ChildNode`.
-}
nodeAt : Path -> Model -> Maybe Node
nodeAt path model =
    nodeAtHelp path model.root


nodeAtHelp : Path -> Node -> Maybe Node
nodeAtHelp path ((Node n) as node) =
    case path of
        [] ->
            Just node

        (IntoSlot slot index) :: rest ->
            Dict.get slot n.children
                |> Maybe.andThen (List.Extra.getAt index)
                |> Maybe.andThen
                    (\child ->
                        case child of
                            ChildNode inner ->
                                nodeAtHelp rest inner

                            _ ->
                                Nothing
                    )


{-| `nodeAt` then a `facts` lookup. `Nothing` if either step fails.
-}
factAt : Path -> Model -> Maybe Fact
factAt path model =
    nodeAt path model
        |> Maybe.andThen (\node -> Dict.get (componentOf node) model.facts)



-- ACCESSORS


{-| The component noun this node was built from.
-}
componentOf : Node -> String
componentOf (Node n) =
    n.component


{-| Sorted association list, so two equal trees produce byte-identical
generated code.
-}
attrsOf : Node -> List ( String, AttrValue )
attrsOf (Node n) =
    Dict.toList n.attrs


{-| Only slots that currently hold children, sorted. A fold that needs the
full declared slot set asks `slotChips`.
-}
slotsOf : Node -> List ( String, List Child )
slotsOf (Node n) =
    Dict.toList n.children |> List.filter (\( _, cs ) -> not (List.isEmpty cs))



-- SLOTS


{-| Every content mode a slot permits — not the highest-precedence one.

The three are independent: a slot may afford all of them, exactly one, or
none. This replaces the winner-takes-all classification the prototype used,
under which a slot naming both text and components collapsed to text and the
components became unreachable.

-}
type alias SlotAffordances =
    { text : Bool
    , icon : Bool
    , components : List String
    }


{-| One slot chip. `max` is `Nothing` for a multi slot, `Just 1` otherwise —
the machine-readable form of the replace-not-append invariant.
-}
type alias SlotChipInfo =
    { name : String
    , required : Bool
    , affordances : SlotAffordances
    , filled : Int
    , max : Maybe Int
    }


{-| The kind tokens that mean "this slot takes text".

`"shared:flow"` and `"shared:phrasing"` are HTML content categories. The
prototype's rule did not name them at all, so they fell through to its
component branch — a latent bug, fixed here.

-}
textKinds : List String
textKinds =
    [ "html", "shared:text", "shared:link", "shared:flow", "shared:phrasing" ]


iconKind : String
iconKind =
    "shared:icon"


kindsFor : Fact -> String -> List String
kindsFor fact slot =
    fact.slotKinds
        |> List.filter (\( name, _ ) -> name == slot)
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault []


affordancesFor : Model -> Fact -> String -> SlotAffordances
affordancesFor model fact slot =
    let
        kinds =
            kindsFor fact slot
    in
    { text = List.isEmpty kinds || List.any (\k -> List.member k textKinds) kinds
    , icon = List.member iconKind kinds
    , components =
        kinds
            |> List.filter (\k -> not (String.contains ":" k))
            |> List.filter (\k -> Dict.member k model.facts)
            |> List.Extra.unique
    }


{-| The declared slot set: required slots first in `requiredSlots` order, then
the rest alphabetically, deduplicated.
-}
slotNames : Fact -> List String
slotNames fact =
    let
        required =
            List.Extra.unique fact.requiredSlots

        rest =
            (fact.multiSlots ++ List.map Tuple.first fact.slotKinds)
                |> List.filter (\s -> not (List.member s required))
                |> List.Extra.unique
                |> List.sort
    in
    required ++ rest


{-| One entry per slot the node's `Fact` declares. Empty for an unresolvable
path.
-}
slotChips : Path -> Model -> List SlotChipInfo
slotChips path model =
    case ( nodeAt path model, factAt path model ) of
        ( Just node, Just fact ) ->
            slotNames fact
                |> List.map
                    (\slot ->
                        { name = slot
                        , required = List.member slot fact.requiredSlots
                        , affordances = affordancesFor model fact slot
                        , filled = childrenIn slot node |> List.length
                        , max =
                            if List.member slot fact.multiSlots then
                                Nothing

                            else
                                Just 1
                        }
                    )

        _ ->
            []


childrenIn : String -> Node -> List Child
childrenIn slot (Node n) =
    Dict.get slot n.children |> Maybe.withDefault []


{-| One way to fill a slot. Each maps to exactly one message:
`OptionText` → `AddTextChild`, `OptionIcon` → `AddIconChild`,
`OptionComponent n` → `AddChild … n`.
-}
type SlotOption
    = OptionText
    | OptionIcon
    | OptionComponent String


{-| The full menu for a slot: every valid way to fill it, in one list.

Order is fixed so the menu does not reshuffle between renders — text and icon
first (the cheap, terminal choices), then the component list (the branch into
recursion). Returns `[]` only when the slot affords nothing at all.

No option in this list is ever a no-op.

-}
slotMenuOptions : Path -> String -> Model -> List SlotOption
slotMenuOptions path slot model =
    affordancesAt path slot model
        |> Maybe.map optionsOf
        |> Maybe.withDefault []


affordancesAt : Path -> String -> Model -> Maybe SlotAffordances
affordancesAt path slot model =
    slotChips path model
        |> List.filter (\c -> c.name == slot)
        |> List.head
        |> Maybe.map .affordances


optionsOf : SlotAffordances -> List SlotOption
optionsOf a =
    List.concat
        [ if a.text then
            [ OptionText ]

          else
            []
        , if a.icon then
            [ OptionIcon ]

          else
            []
        , List.map OptionComponent a.components
        ]



-- ATTRIBUTES


{-| Whether a chip is an enum (and its legal tokens) or a plain typed value.

`kind` is carried on the chip because the consumer cannot render one without
it — an enum chip's label shows the current token, a boolean chip is a toggle,
a string chip opens a text field.

-}
type AttrChipKind
    = EnumChip (List String)
    | PlainChip AttrKind


{-| One configurable attribute. `isSet` is `True` exactly when the attribute
has an entry in the node's `attrs`. An unset attribute contributes nothing to
the preview and nothing to the generated code.
-}
type alias AttrChipInfo =
    { name : String
    , kind : AttrChipKind
    , isSet : Bool
    , currentValue : Maybe AttrValue
    }


{-| Enum chips in the `Fact`'s own order, then plain chips deduplicated and
sorted. `attrRewrites` maps barrel setter name to per-component setter name and
the same per-component name can be reached from more than one barrel entry, so
deduplication is required, not cosmetic.

A name absent from both `fact.enums` and `Model.attrKinds` is not offered at
all — which is how event setters are excluded.

-}
attrChips : Path -> Model -> List AttrChipInfo
attrChips path model =
    case ( nodeAt path model, factAt path model ) of
        ( Just node, Just fact ) ->
            let
                current name =
                    currentAttr name node

                enumNames =
                    List.map Tuple.first fact.enums

                enumChips =
                    fact.enums
                        |> List.map
                            (\( name, tokens ) ->
                                { name = name
                                , kind = EnumChip tokens
                                , isSet = current name /= Nothing
                                , currentValue = current name
                                }
                            )

                plainChips =
                    fact.attrRewrites
                        |> List.map Tuple.second
                        |> List.filter (\name -> not (List.member name enumNames))
                        |> List.Extra.unique
                        |> List.sort
                        |> List.filterMap
                            (\name ->
                                Dict.get name model.attrKinds
                                    |> Maybe.map
                                        (\kind ->
                                            { name = name
                                            , kind = PlainChip kind
                                            , isSet = current name /= Nothing
                                            , currentValue = current name
                                            }
                                        )
                            )
            in
            enumChips ++ plainChips

        _ ->
            []


currentAttr : String -> Node -> Maybe AttrValue
currentAttr name (Node n) =
    Dict.get name n.attrs
