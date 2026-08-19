module CtxSpoof exposing (broken)

{-| Cross-brand context privacy: MiniM3e's modal demands { modal : M3eCtx };
MiniNative's legendish closes { modal : NativeCtx } — same FIELD NAME,
different marker types. MUST FAIL (per-brand Ctx markers are load-bearing).
-}

import MiniM3e as M
import MiniNative as N


broken =
    M.modal [ N.legendish "I claim the modal context" ]
