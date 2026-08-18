module Cem.Internal.ListExtra exposing (dedupeByName)

{-| Small list helpers shared by the rules that dedupe named entries
(`SingularAttribute`, `SingularSlot`).

@docs dedupeByName

-}


{-| Keep only the first `( name, _ )` entry for each distinct name, preserving
order.
-}
dedupeByName : List ( String, a ) -> List ( String, a )
dedupeByName =
    List.foldl
        (\(( name, _ ) as item) acc ->
            if List.any (\( n, _ ) -> n == name) acc then
                acc

            else
                acc ++ [ item ]
        )
        []
