module Util exposing (deduplicateBy)

{-| Small shared helpers used across the generator.

@docs deduplicateBy

-}

import Set


{-| Deduplicate a list by a key function, preserving first-seen order.

Uses a `Set` of seen keys, so it is O(n log n) rather than the O(n^2) of a
per-element linear scan — the generator dedups over every attribute/enum literal
manifest-wide, which is quadratic on large libraries (issue #27).

-}
deduplicateBy : (a -> comparable) -> List a -> List a
deduplicateBy keyFn list =
    let
        step item ( seen, result ) =
            let
                key =
                    keyFn item
            in
            if Set.member key seen then
                ( seen, result )

            else
                ( Set.insert key seen, item :: result )
    in
    list
        |> List.foldl step ( Set.empty, [] )
        |> Tuple.second
        |> List.reverse
