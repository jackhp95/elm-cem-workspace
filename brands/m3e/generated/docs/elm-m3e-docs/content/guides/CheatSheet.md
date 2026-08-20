@@@ intro
Look-up tables for the ideas the [Guide](/guide) teaches. Come back here; keep the chapters for the story.

@@@ layers
From [the surface map](/guide/the-layers). A component is one typed value; the surfaces are peer call-shapes, and `M3e.Html.*` / the escapes are how you loosen or leave the typed tree.

| Surface | What it is | You reach for it |
| --- | --- | --- |
| **barrel / `component`** | The standard form — typed, slot-safe, composes into other components. | Almost always — the default. |
| **`component` (required record)** | Same value; the compiler demands the required parts. | The 29 components with a required record, when you must not forget it. |
| **`build` + `toElement`** | Same value via a pipe; one-only setters unwritable twice. | Conditional or order-free construction. |
| **`M3e.Html.*` (loose)** | The open-rowed producer — no slot/attr checking, still in the IR. Not plain HTML. | Opting out of the strict rows on purpose. |
| **`M3e.Unsafe`** | Escapes: `recast` (kind crossing) / `fromHtml` (raw `Html`). Loud, greppable, lint-flagged. | Leaving the typed tree when nothing else fits. |

@@@ barrelVsSpecific
A second axis, orthogonal to the surfaces: *which import you reach through*. Same output either way; the [reference](/guide/reference) documents both.

| Import | Statement | You get |
| --- | --- | --- |
| **barrel** | `import M3e` | One import for every component's `component` form, plus `text` and `toHtml`. Pair it with the shared `M3e.Attributes` / `M3e.Values` / `M3e.Events` vocabulary (library-wide unions, lint-checked). |
| **component module** | `import M3e.Button` | Component-scoped types and setters — a token or slot child wrong for *this* component won't compile; also where the required-record `component` form / `build` live. |

@@@ shapes
From [the strictness dial](/guide/strictness). All three render the *same* component; they differ only in what you may leave out. **Peers, not a ranking.**

@@@ dial
The compiler always checks that kinds line up and only real tokens exist. Everything softer is opt-in, two ways — turn on either, or both:

| You add | How | Caught |
| --- | --- | --- |
| Invalid token for *this* component · empty required slot · foreign slot child · missing accessible name | run the **linter** in CI | project-wide |
| Required parts can't be forgotten | the **required-record** form | per call site |
| A one-only setter can't be written twice | the **pipeline** form | per call site |

@@@ seams
From [your own seam](/guide/seams). Everything is a typed `Element` from `M3e.*` / `TypedHtml.*`, composed directly — you never import `HtmlIr` (the barrel re-exports `M3e.Element` / `M3e.Attr` and `M3e.mapMsg`). To bring in something *foreign*, there is exactly one loud, greppable, lint-fenced escape surface, shipped with the library itself:

| Escape | What it gives you |
| --- | --- |
| **`<Brand>.Unsafe`** / **`.Unsafe.Attributes`** | `fromHtml` / `fromHtmlAttribute` lift raw `Html`; `recast` / `recastAttr` re-kind to free rows so anything drops into any slot; `customElement` / `customAttribute` forge a tag or attribute the library has no producer for. Fenced by `NoUnsafeImportOutsideAllowed`. |

Underneath, `Unsafe` is built on the raw forge `HtmlIr.Internal` (`fromNode`, `node` / `attribute` / `property` / `on`, `lazy`..`lazy8`) — but that forge is fenced to the library's own generated code by `NoInternalImportOutsideAllowed`; application code has no reason to import it.

A "seam" isn't a library feature — it's the *practice* of corralling those escapes into one greppable place, a small named producer next to the code that needs it. Anywhere else a raw escape is flagged, and the linter offers to lift it into an escape for you.
