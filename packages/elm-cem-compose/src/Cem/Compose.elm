module Cem.Compose exposing
    ( Model, init, Msg(..), update
    , Node, Child(..), AttrValue(..), AttrKind(..)
    , PathStep(..), Path, MenuKind(..)
    , nodeAt, factAt
    , componentOf, attrsOf, slotsOf
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
            if Dict.member component model.facts then
                edit path (insertChild model slot (ChildNode (emptyNode component))) model

            else
                closeMenu model

        AddTextChild path slot ->
            edit path (insertChild model slot (ChildText "")) model

        AddIconChild path slot ->
            edit path (insertChild model slot (ChildIcon "star")) model

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
