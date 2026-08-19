module UtilTest exposing (suite)

{-| Tests for Util.deduplicateBy — behaviour must be identical to the previous
O(n^2) implementation (first-seen order preserved, dedup by key), issue #27.
-}

import Expect
import Fuzz
import Test exposing (Test, describe, fuzz, test)
import Util


{-| Reference implementation: the straightforward, obviously-correct dedup by key
preserving first-seen order. The optimized Util.deduplicateBy must match it.
-}
reference : (a -> comparable) -> List a -> List a
reference keyFn list =
    List.foldl
        (\item acc ->
            if List.any (\existing -> keyFn existing == keyFn item) acc then
                acc

            else
                acc ++ [ item ]
        )
        []
        list


suite : Test
suite =
    describe "Util.deduplicateBy"
        [ test "empty list" <|
            \_ -> Util.deduplicateBy identity [] |> Expect.equal []
        , test "no duplicates keeps order" <|
            \_ -> Util.deduplicateBy identity [ 3, 1, 2 ] |> Expect.equal [ 3, 1, 2 ]
        , test "keeps the first occurrence of each key" <|
            \_ -> Util.deduplicateBy identity [ 1, 2, 1, 3, 2 ] |> Expect.equal [ 1, 2, 3 ]
        , test "dedup by a key function keeps the first record per key" <|
            \_ ->
                [ ( "a", 1 ), ( "b", 2 ), ( "a", 3 ) ]
                    |> Util.deduplicateBy Tuple.first
                    |> Expect.equal [ ( "a", 1 ), ( "b", 2 ) ]
        , fuzz (Fuzz.list Fuzz.int) "matches the reference implementation on ints" <|
            \xs -> Util.deduplicateBy identity xs |> Expect.equal (reference identity xs)
        , fuzz (Fuzz.list (Fuzz.intRange 0 5)) "matches reference on a small key domain (many collisions)" <|
            \xs ->
                Util.deduplicateBy (\n -> modBy 3 n) xs
                    |> Expect.equal (reference (\n -> modBy 3 n) xs)
        ]
