@@@ intro
You've built real things on this API. Before we lean on it any harder, one question: can you trust it? Two facts make the answer yes — and they're also what makes everything later in this guide possible.

@@@ generated
**You don't type the API by hand — a generator writes it.** The component library ships a *manifest* — a machine-readable list of every component, its attributes, and its slots. A generator turns that manifest, together with one hand-authored file (`config/slots.json`, which records slot kinds and required attributes the manifest doesn't carry), into the typed Elm you import. The names, the attributes, the slots you'll learn are the components' own — not a per-component wrapper someone hand-maintains and forgets to update.

That does mean the API isn't *fully* automatic: when a new version of the components ships, you regenerate, and any component the manifest adds that `config/slots.json` doesn't yet cover falls back to loose `any` slots until the config is updated. So the API stays in step by a regen you run — not on its own — and because an uncovered component surfaces as loose `any` slots, that gap is visible in the generated output rather than silent.

@@@ inspectable
**A component isn't opaque HTML — it's inspectable data.** `M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]` doesn't produce HTML on the spot. It builds a small value the library can *read*: it knows this is a button, that it's filled, that its content is the text "Save". Your whole page stays as this readable data right up until one conversion — `M3e.toNode` — at your app's root, which turns the entire tree into HTML exactly once.

Because the library can inspect what you built *before* it becomes HTML, it can enforce rules a plain HTML wrapper never could — the next chapters are all cashing in on this one fact.

@@@ recap
- The Elm API is **generated from the components' published manifest + a hand-authored `config/slots.json`** — you regenerate on each upstream release; anything the config doesn't cover yet surfaces as loose `any` slots.
- A component is **inspectable data** the library reads, then turns into HTML **once, at the root** (`M3e.toNode`).
- That's why the library can catch mistakes the browser never sees.
- **Next: [The surface map](/guide/the-layers) →** the same button, shown through each of its interchangeable surfaces — and the loud escapes for leaving the typed tree.
