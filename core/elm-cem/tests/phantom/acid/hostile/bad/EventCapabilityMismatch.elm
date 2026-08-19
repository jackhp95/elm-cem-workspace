module EventCapabilityMismatch exposing (broken)

{-| Proves K4 event disambiguation: the Hz.ErrorOnly component admits ONLY
`onHzError` (brand-prefixed event), NOT `onError` (native event).

This probe tries to apply `Hz.Events.onError` (which requires
`{ c | onError : Supported }`) to Hz.ErrorOnly's capability row, which only
includes `{ onHzError : Supported }`. Type mismatch on the row — not a naming
error or unknown identifier. MUST FAIL at compile time with a row-field error.
-}

import HtmlIr.Attribute
import Hz.Component.ErrorOnly
import Hz.Events


type Msg
    = ErrorHappened


broken : Msg -> HtmlIr.Attribute.Attr (Hz.Component.ErrorOnly.Attrs) Msg
broken msg =
    -- Hz.ErrorOnly.Attrs only admits { onHzError : Supported }, not onError.
    -- Hz.Events.onError requires { c | onError : Supported }.
    -- This type mismatch (row field missing) proves the two events are distinct.
    Hz.Events.onError msg
