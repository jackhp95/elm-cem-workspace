@@@ intro
A scannable field guide to the failures you'll actually hit, each as **cause → symptom → fix**. Skim for your symptom; every message here is real output.

@@@ kindMismatch
### A slot won't accept your child

**Cause:** you put content of the wrong *kind* in a slot. **Symptom:** a type error naming the slot, with a record field that "doesn't match." **Fix:** give the slot the kind it accepts — the compiler usually guesses it for you (*"Maybe chip should be icon?"*).

@@@ m3eInNativeSlot
### A native element won't accept an M3e component

**Cause:** you put an M3e component inside a native element whose content model is *enumerated* — `<span>`, `<p>`, `<h1>`, `<li>`, `<td>`. Those admit HTML content categories (`sharedFlow` / `sharedPhrasing`) plus shared atoms, and an M3e component names its own brand kind so that its own slots can tell it apart. **Symptom:** a mismatch between `<Tag>Content` and a row that has absorbed your component's kind. **Fix:** use a flow container — `TypedHtml.div`, `section`, `header`, `nav`, `form` and ~20 more take any children at all. This is a designed limit, not a gap; the [seams guide](/guide/seams) explains why erasing the brand kind would also let a Card into a Menu. The reverse direction *does* work: native HTML goes into any M3e slot declaring `shared:flow` / `shared:phrasing`.

@@@ deadClass
### A class renders nothing

**Cause:** you wrote a proprietary design-system class (`ds-…` / `t-…`) that ships no CSS in this system, so it silently does nothing. **Symptom:** no error, no style — the element renders bare. **Fix:** the linter flags these dead classes; use a real style token or a seam instead. This is a correctness check, not a style opinion — the class simply has no effect.

@@@ looseEnum
### An enum token type-checks but is rejected

**Cause:** the shared `M3e.Attributes.*` vocabulary closes over the library-wide *union* of enum values, so a token that's real for *some* component type-checks even on one that doesn't support it. **Symptom:** it compiles, but the linter flags it. **Fix:** use one of the component's real tokens — or reach for the per-component setter (`M3e.Button.variant`), where only that component's tokens exist as names and the mistake can't compile in the first place.

@@@ missingName
### A control has no accessible name

**Cause:** an icon-only control with no visible text and no `aria-label`. **Symptom:** it compiles, but the linter refuses it. **Fix:** add the accessible name — `Aria.label "…"`.

@@@ greenLint
### "The linter is clean but the app won't compile"

**Cause:** you're treating the linter as the build. It isn't. The linter catches the *soft* misses the compiler leaves loose on purpose; it does not replace the compiler. **Symptom:** `elm-review` passes, `elm make` fails. **Fix:** a real `elm make` is the authority — read its error (the earlier entries here are all `elm make` output). **A green linter is not a green build.**

@@@ recap
- **Kind mismatch:** give the slot the kind it accepts; the compiler often guesses the fix.
- **Dead class / rejected token / missing name:** the linter catches what types leave loose — read its message.
- **A green linter is not a green build** — `elm make` is the authority.
- **Next: [How we prove it](/guide/how-we-prove-it) →** why you can trust every example in these docs.

