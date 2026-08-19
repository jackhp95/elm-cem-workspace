module ImportValues exposing (broken)

{-| Tries to import Br.Values, which should not exist (K6: barren has no enums).
MUST FAIL.
-}

import Br.Values


broken : Br.Values.Variant
broken =
    -- This should fail because Br.Values doesn't exist.
    error "unreachable"
