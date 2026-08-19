module Cem.Internal.Lookup exposing (isCallTo)

{-| Shared module-qualified call-site check, used by the rules that need to
recognize "is this expression a call to `<expectedModule>.<expectedName>`"
(`MissingRequiredAttribute`, `RequireFabLabel`, `RequireFormFieldLabel`).

@docs isCallTo

-}

import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)


{-| `context` only needs a `lookup` field, so any rule's own `Context` record
works here unchanged.
-}
isCallTo : { a | lookup : ModuleNameLookupTable } -> List String -> String -> Node Expression -> Bool
isCallTo context expectedModule expectedName setterNode =
    case Node.value setterNode of
        Expression.FunctionOrValue _ name ->
            (name == expectedName)
                && (Lookup.moduleNameFor context.lookup setterNode == Just expectedModule)

        _ ->
            False
