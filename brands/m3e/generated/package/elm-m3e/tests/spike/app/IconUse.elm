module IconUse exposing (customIcon, favourites, menuIcon)

{-| Compile-only spike for M3e.Icon names (standalone, self-contained).

Verifies:

  - A named icon (menu) renders via `icon` with empty attrs + kids.
  - The custom escape hatch compiles with an arbitrary string.
  - `Name` is a first-class value — it can be annotated and put in a list.
    This is what the previous one-function-per-icon surface could NOT express,
    and it is why the opaque-Name shape is not merely a size workaround (R-026).
  - No M3e.Component.Icon import needed — the module is self-contained (IR only).

-}

import HtmlIr.Element exposing (Element)
import M3e.Icon


{-| Named icon — must compile. Uses open-rowed type, no component dependency.
-}
menuIcon : Element produced admittedBy msg
menuIcon =
    M3e.Icon.icon M3e.Icon.menu [] []


{-| Custom escape hatch — must compile.
-}
customIcon : Element produced admittedBy msg
customIcon =
    M3e.Icon.icon (M3e.Icon.custom "foo") [] []


{-| Icon names are ordinary values — storable, listable, annotatable.
-}
favourites : List M3e.Icon.Name
favourites =
    [ M3e.Icon.menu, M3e.Icon.search, M3e.Icon.settings, M3e.Icon.custom "foo" ]
