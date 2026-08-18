module Cem.Internal.ListExtra exposing (countBy, dedupeByName)

{-| Small list helpers shared by the rules that dedupe named entries
(`SingularAttribute`, `SingularSlot`).

@docs countBy, dedupeByName

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


{-| Count how many `( name, _ )` entries match the given name.
-}
countBy : String -> List ( String, a ) -> Int
countBy name =
    List.filter (\( n, _ ) -> n == name) >> List.length
