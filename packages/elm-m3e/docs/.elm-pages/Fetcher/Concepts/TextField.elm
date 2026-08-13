module Fetcher.Concepts.TextField exposing (submit)

{-| -}

import Bytes exposing (Bytes)
import Bytes.Decode
import Http
import Pages.Fetcher
import Route.Concepts.TextField


submit :
    (Result Http.Error Route.Concepts.TextField.ActionData -> msg)
    ->
        { fields : List ( String, String )
        , headers : List ( String, String )
        }
    -> Pages.Fetcher.Fetcher msg
submit toMsg options =
    { decoder =
        \bytesResult ->
            bytesResult
                |> Result.andThen
                    (\okBytes ->
                        okBytes
                            |> Bytes.Decode.decode Route.Concepts.TextField.w3_decode_ActionData
                            |> Result.fromMaybe (Http.BadBody "Couldn't decode bytes.")
                    )
                |> toMsg
    , fields = options.fields
    , headers = ("elm-pages-action-only", "true") :: options.headers
        , url = [ [ "concepts" ], [ "text-field" ], [ "content.dat" ] ] |> List.concat |> String.join "/" |> Just
    }
    |> Pages.Fetcher.Fetcher
