@@@ intro
The compiler holds a lot for you — kinds line up, and only real tokens exist. But it *deliberately* stays quiet about softer questions like "did you fill the slot this component needs?" on the standard surface, because forcing that on every call site would tax the easy path. Strictness here isn't all-or-nothing: **you start easy and turn it up where it's worth it** — project-wide with the linter, or per call site with a stricter surface.

A quick word on vocabulary, since it shows up below: a **surface** is one of a component's interchangeable call-shapes you'll map in full at [the surface map](/guide/the-layers), the **barrel** is the one-import `M3e` API, and a **component module** is a per-component import (`import M3e.Button`) with tighter, component-scoped types.

@@@ linter
A linter that knows your components reads the same component list the API was generated from, so it can flag things the types leave loose: an enum token that type-checked through the shared `M3e.Attributes.*` vocabulary but isn't valid for *this* component, a required content slot you left empty, or a child placed in a slot the container doesn't declare (`Cem.ValidSlotKind`). These are **linter-guaranteed, not compiler-guaranteed** — the linter is a separate pass, so it only protects you if you **run elm-review in CI**. Run there, it catches the soft misses the compiler waves through on purpose. (One caveat worth naming: `Cem.ValidSlotKind` is `Lenient` by default and can't resolve a child's kind through a `List.map` or a let-binding, so it's a strong net, not an absolute one.)

@@@ shapes
Stricter call-shapes, chosen per component. A component isn't one function shape; each ships several **surfaces**, and they all render the *same* button. They differ only in what you're allowed to leave out — they are **peers, not a ranking**, and you pick per call site:

@@@ recordAha
The standard-form Save button lets you forget its action — that's the easy path's cost. Switch the same button to the **required-record** form (`component`) and forgetting the action is no longer possible: leave it out and the build stops, because the record spells out the parts a button can't render without.

@@@ recap
- The compiler enforces **kinds and valid tokens**; it leaves softer checks loose on the standard surface on purpose.
- **Project-wide:** a linter that knows your components (invalid token for *this* component, empty required slot, foreign slot child) — **linter-guaranteed, so run elm-review in CI**.
- **Per call site:** three call-shapes — the standard form, required record, pipeline — **peers**, each promoting one check to a compile guarantee.
- **Next: [Accessibility you can't forget](/guide/accessible-by-construction) →** the one place strictness is not optional — an accessible name you cannot forget.
