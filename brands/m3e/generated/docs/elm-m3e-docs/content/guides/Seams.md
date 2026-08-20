@@@ intro
Everything you write on top of the library is **userland** — your own code. Most of it needs no escape at all: standard HTML is already typed (`TypedHtml.div`, `TypedHtml.label`, …), and "custom" content usually just fills a component's *typed slot*. A **seam** isn't something you build — it's the *practice* of reaching for the library's own fenced escapes, `M3e.Unsafe` and `M3e.Unsafe.Attributes`, instead of improvising a way around the type system. They ship in one lint-guarded place so every real crossing is loud, named, and greppable — no userland adapter module required. This page shows the two things worth telling apart: a genuine escape (`modelViewer`, below) and typed code that only looks like one (`twoColumn`, `linkNav`).

@@@ userland
Start with what is **not** a seam. A two-column layout is standard HTML, and standard HTML is typed — a `TypedHtml.div` with a class attribute. Naming it in one userland producer keeps the class string in one place, but there is no escape here and nothing for the linter to fence. Reaching for `M3e.Unsafe.fromHtml` to build this would be the mistake: it drags plain typed markup through an escape door it never needed to walk through — the compiler already gives you `TypedHtml.div` for free.

@@@ realSeam
Now a **real** seam. `<model-viewer>` is a third-party web component — the typed tree has no producer for it, so building it means genuinely stepping outside: `M3e.Unsafe.customElement` forges the custom tag and `M3e.Unsafe.Attributes.customAttribute` sets its bespoke attributes. This is what the seam is *for*. Because it lives in one named userland producer, the escape is contained, greppable, and lint-fenced — you stepped outside on purpose, in one auditable place, instead of calling `M3e.Unsafe.customElement` inline wherever a `<model-viewer>` happens to show up.

@@@ slotSeam
Most "custom" content needs no escape at all — it fills the *typed slots* a component declares. A nav-menu item's `label` slot accepts the `text` **and** `link` kinds, so a nav item can be an ordinary `<a href>` with no raw HTML at the call site: `TypedHtml.a` produces the `link` kind, so it drops into the slot directly — no seam, no door, no break-glass `recast`. The slot's phantom row admits exactly the kinds the design system declared for it.

@@@ crossBrand
Slots that mean *"arbitrary content goes here"* say so in a vocabulary **both libraries speak**. `M3e.Component.AppBar.trailing` declares the two WHATWG content categories, `shared:flow` and `shared:phrasing`, and `TypedHtml.div` produces `sharedFlow` — so a native wrapper drops straight into an M3e slot with no escape at all.

The important half is what *stays* checked. `M3e.Unsafe.recast` would also have got the div in, by throwing away every row on the way; this keeps them. The div still has to be legal where it sits, and its children still have to be legal inside a div. You didn't buy admission by going blind.

@@@ oneWay
**The other direction is a designed limit, not a gap to route around.** An M3e component will not go inside a native container whose content model is enumerated — `<span>`, `<p>`, `<h1>`, `<li>`, `<td>`:

The reason is the same rule that makes slots work at all: a producer's named kinds must be a **subset** of the slot's. `M3e.heading` names `heading` so that `AppBar.title` can tell a heading from a card — and that same field is what `SpanContent` has no name for. Erasing it would let M3e components into native containers *and* let a Card into a Menu. You can have a component discriminated by its own design system, or admitted by a foreign library's enumerated slots. Not both.

In practice it rarely bites, and there are three honest answers before you reach for an escape:

1. **Use a flow container.** `TypedHtml.div`, `section`, `article`, `header`, `footer`, `main_`, `nav`, `form`, `figure`, `aside`, `details`, `dialog` and 20-odd others take any children at all. Wrapping a component in a `<div>` is not a workaround — it is what the content model already says.
2. **Check the slot first.** Text and icons cross both ways as shared atoms, so `M3e.text` and `M3e.icon` sit inside native phrasing content directly.
3. **`M3e.Unsafe.recast`** for the case where the design system is genuinely wrong — a specific, recurring crossing gets a small named function built on `recast`, kept next to the feature that needs it. Loud, named and lint-fenced — which is the point of this page.

Two smaller residues, for completeness: a bare `<img>` or `<area>` keeps a per-tag kind (so `<picture>` and `<map>` stay exact) and needs a wrapper to enter an M3e slot; and `<dl>`/`<option>` accept any flow content rather than the narrower set the spec names.

@@@ payoff
That is the whole discipline: **type everything you can, seam only what you must, and keep the seams in one place.** Layout and text are typed producers. Slots take typed kinds. The genuine escapes — a custom element, raw `Html` via `fromHtml`, or the break-glass `recast` when the design system is truly wrong for a case — are named, lint-fenced, and already live in one place: `M3e.Unsafe` and `M3e.Unsafe.Attributes`. Your job is narrower than it used to be — call them from a small, named producer (like `modelViewer` above) instead of inline at every call site. You escaped the types where you had to and **kept** the guarantees everywhere else, because every real escape is loud, contained, and greppable.

@@@ recap
- A **seam** isn't something you build — it's the *practice* of reaching for the library's fenced escapes (a custom element, raw `Html`, a `recast`) instead of improvising around the type system.
- Most userland is **not** a seam: standard HTML is typed (`TypedHtml`), and custom content usually fills a **typed slot** — no escape needed.
- The genuine escapes go through the library's one fenced door for userland — `M3e.Unsafe` (`fromHtml`/`fromNode`/`recast`/`recastAll`/`customElement`) and `M3e.Unsafe.Attributes` (`fromHtmlAttribute`/`customAttribute`) — named once so every use is auditable.
- **Next: [The tooling refactors for you](/guide/tooling-refactors) →** the linter doesn't just flag escapes — it extracts and rewrites them *for* you.
