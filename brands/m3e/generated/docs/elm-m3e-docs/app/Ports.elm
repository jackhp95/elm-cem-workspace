port module Ports exposing (onOpenSearchRequested)

{-| Client-side ports for the docs app. Wired to the browser in `index.ts`.

@docs onOpenSearchRequested

-}


{-| Fired when the user presses Cmd/Ctrl+K anywhere in the app. `index.ts`
registers a real `document.addEventListener("keydown", ...)` and calls
`event.preventDefault()` before sending on this port -- Chrome and Edge bind
that shortcut to focusing the address bar, and `Browser.Events.onKeyDown`
cannot call `preventDefault` (it only decodes event data), so without this
port our shortcut would fire ALONGSIDE the browser's, not instead of it.
-}
port onOpenSearchRequested : (() -> msg) -> Sub msg
