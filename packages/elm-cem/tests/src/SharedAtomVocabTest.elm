module SharedAtomVocabTest exposing (suite)

{-| The closed `shared:` vocabulary, checked at the LAST possible moment — the
byte-writing boundary.

`Generate.Phantom.Model.resolveWith` already rejects an unlisted `shared:<role>`
in config vocabulary, which is where a config author wants to hear about it. This
suite covers the other end: a `Shared`-marked row field that reaches
`Generate.Phantom.Emit.files` by any route at all. A `Shared` field is the one
thing in this system that unifies ACROSS package boundaries, so its spelling is a
contract between brands that never see each other's source; an unlisted spelling
is a private kind wearing cross-library clothes, and it fails silently — the
brand compiles, publishes, and simply never matches anything.

The resolution-time check enumerates the routes it knows (`_atoms`, a component's
`kind`, a slot's `kinds`). This one enumerates nothing: it
walks what the emitter is about to WRITE. That is why it is worth having twice —
a future emitter path that synthesises a field name cannot slip past a check
positioned at the output.

Each case builds a real `Brand` through `Model.resolve` and then poisons exactly
one field, because a hand-rolled `Brand` literal would drift from the real record
and prove nothing about the pipeline.

-}

import Cem
import Expect
import Generate.Config exposing (extractComponents)
import Generate.Phantom.Emit as Emit
import Generate.Phantom.Model as M exposing (Marker(..), SlotContent(..))
import Json.Decode as D
import Test exposing (Test, describe, test)


cemJson : String
cemJson =
    """
    { "schemaVersion": "1.0.0",
      "modules": [ { "kind": "javascript-module", "path": "src/index.js", "declarations": [
        { "kind": "class", "name": "Card", "tagName": "tv-card", "customElement": true,
          "description": "A container with one shared-atom slot.",
          "members": [], "events": [], "cssProperties": [], "cssParts": [], "cssStates": [],
          "slots": [ { "name": "body", "description": "The body" } ],
          "attributes": [ { "name": "label", "type": { "text": "string" } } ] } ] } ] }
    """


configJson : String
configJson =
    """
    { "_config":
        { "_phantom": true
        , "_brand": "Tv"
        , "_atoms": { "text": {} }
        , "Card": { "admits": { "body": { "kinds": [ "shared:text" ], "multi": true } } }
        }
    }
    """


{-| A real resolved brand: one component, one shared-atom slot, one atom.
-}
resolved : Result (List String) M.Brand
resolved =
    case ( D.decodeString Cem.manifestDecoder cemJson, D.decodeString D.value configJson ) of
        ( Ok manifest, Ok flags ) ->
            M.resolve "Tv" "tv-" flags (extractComponents [] manifest)

        ( Err e, _ ) ->
            Err [ "fixture CEM did not decode: " ++ D.errorToString e ]

        ( _, Err e ) ->
            Err [ "fixture config did not decode: " ++ D.errorToString e ]


{-| Emit the brand under `f` and return the guard's errors (empty = clean).
A resolution failure is reported as itself, so a broken fixture cannot masquerade
as a passing guard.
-}
emitErrors : (M.Brand -> M.Brand) -> List String
emitErrors f =
    case resolved of
        Err es ->
            List.map (\e -> "RESOLVE: " ++ e) es

        Ok brand ->
            case Emit.files (f brand) of
                Ok _ ->
                    []

                Err es ->
                    es


{-| Rename every `Shared`-marked slot field to `sharedTxet` — a spelling no other
brand will ever name.
-}
poisonSlotField : M.Brand -> M.Brand
poisonSlotField brand =
    let
        rename f =
            if f.marker == MShared then
                { f | field = "sharedTxet" }

            else
                f

        onSlot s =
            case s.content of
                Fields fs ->
                    { s | content = Fields (List.map rename fs) }

                _ ->
                    s
    in
    { brand | comps = List.map (\c -> { c | slots = List.map onSlot c.slots }) brand.comps }


mentions : String -> List String -> Bool
mentions needle =
    List.any (String.contains needle)


suite : Test
suite =
    describe "shared-atom vocabulary (emission guard)"
        [ test "the fixture brand resolves and emits cleanly" <|
            \_ ->
                emitErrors identity |> Expect.equal []
        , test "an unlisted Shared slot field is refused at emission" <|
            \_ ->
                emitErrors poisonSlotField
                    |> mentions "sharedTxet"
                    |> Expect.equal True
        , test "an unlisted Shared producer kind is refused at emission" <|
            \_ ->
                emitErrors
                    (\b ->
                        { b
                            | comps =
                                List.map (\c -> { c | produces = { field = "sharedGlyph", marker = MShared } }) b.comps
                        }
                    )
                    |> mentions "sharedGlyph"
                    |> Expect.equal True
        , test "an unlisted atom role is refused at emission" <|
            \_ ->
                emitErrors (\b -> { b | atoms = [ "txet" ] })
                    |> mentions "shared:txet"
                    |> Expect.equal True
        , test "the refusal names the whole legal vocabulary, so the fix needs no source dive" <|
            \_ ->
                emitErrors poisonSlotField
                    |> mentions "shared:phrasing"
                    |> Expect.equal True
        , test "a listed Shared field emits without complaint" <|
            \_ ->
                emitErrors
                    (\b ->
                        { b
                            | comps =
                                List.map (\c -> { c | produces = { field = "sharedIcon", marker = MShared } }) b.comps
                        }
                    )
                    |> Expect.equal []
        ]
