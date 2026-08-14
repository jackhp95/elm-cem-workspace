module IconUse exposing (menuIcon, customIcon)

{-| Compile-only spike for M3e.Icon element helpers (standalone, self-contained).

Verifies:
  - A named icon helper (menu) compiles with empty attrs + kids.
  - The custom escape hatch compiles with an arbitrary string.
  - No M3e.Component.Icon import needed — the module is self-contained (IR only).

-}

import HtmlIr.Element exposing (Element)
import M3e.Icon


{-| Named icon helper — must compile. Uses open-rowed type, no component dependency. -}
menuIcon : Element produced admittedBy msg
menuIcon =
    M3e.Icon.menu [] []


{-| Custom escape hatch — must compile. -}
customIcon : Element produced admittedBy msg
customIcon =
    M3e.Icon.custom "foo" [] []
