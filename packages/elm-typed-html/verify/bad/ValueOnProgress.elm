module ValueOnProgress exposing (broken)

{-| The crash, made a COMPILE error. MUST FAIL.

`TypedHtml.Attributes.value` is the live DOM-property form. That is correct for
`<input>`, which is what it is overwhelmingly used for, and it is the only form that
keeps tracking a controlled input once the dirty-value flag is set (issue #41).

`HTMLProgressElement.value` is a RESTRICTED IDL `double`, and Web IDL rejects a
non-finite double with a TypeError. Verified in a real browser:

    progress.value = "abc"    -->  TypeError: The provided double value is non-finite.
    progress.value = "1e999"  -->  TypeError  (overflows to Infinity)
    progress.value = "70"     -->  OK

virtual-dom applies property facts inside `_VirtualDom_applyFacts`, i.e. DURING PATCH,
so that TypeError does not stay inside one node: it aborts the patch. Measured in a real
Elm app, with a `<progress>` bound to the model and patched from a valid value to an
invalid one — the sibling text-node patch applied, the progress patch did not, and the
exception escaped the animation-frame draw callback. Elm re-scheduled the frame and it
re-threw: ~60 uncaught TypeErrors per second, indefinitely, on a page that was sitting
completely idle. No Elm runtime error, no crash screen, a permanently stale DOM and a
burning core. An unbounded spin, not a one-off.

Scoping `_controlled`'s `value` to `<input>` fixed `TypedHtml.Text.value`. It could not
fix THIS call, because `TypedHtml.Attributes` is a loose surface: every setter there is
an open producer admitted by every element whose row carries the field, so as long as
`<progress>` kept a `value` capability it kept admitting the property write.

So `<progress>` does not keep it. `ProgressAttrs` has `valueNumeric : Supported` and no
`value` field at all — see verify/src/Good.elm for the call that DOES compile,
`At.valueNumeric 0.6`, which writes the content attribute through `String.fromFloat` and
therefore cannot produce a non-finite string in the first place.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.progress [ At.value "abc" ] []
