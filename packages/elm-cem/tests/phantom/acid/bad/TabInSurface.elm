module TabInSurface exposing (broken)

{-| PURE row-2 failure: surface is kind-permissive, so the tab's KIND is
admitted — but tab's closed AdmittedBy { tabs } excludes the surface context.
MUST FAIL.
-}

import Mini


broken =
    Mini.surface [] [ Mini.tab [] [ Mini.text "stray" ] ]
