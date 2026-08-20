@@@ intro
This guide builds one real thing — an account settings panel — a small step at a time, and every step teaches the idea behind it. Start here: get a single component on screen. Everything after this builds on it.

@@@ body
Every component is a typed Elm value. Import the one-import `M3e` barrel, build a value in the shape `M3e.<name> [ attributes ] [ children ]`, and hand it to `M3e.toNode` at your app's root. Here is the start of our panel: an outlined card, a title, and a **Save** button.

Look at the shape. Attributes like `M3e.Attributes.variant Value.filled` go in the first list; content goes in the second. That is the whole API — one import, one shape, every component.

(One thing to notice: a component with no required pieces is a loose producer on the barrel (`M3e.card`), but a component whose constructor takes required fields — the heading's `content`, the button's `content` and `action` — is written through its record-form smart constructor `M3e.Component.<name>.component` on its own module, not the barrel. A component's **slot setters** live on that module too — `M3e.Component.Card.header`, not `M3e.header` — because each one is typed to the kinds that slot admits. That is why the `M3e.Component.*` modules are imported alongside the barrel here.)

@@@ recap
- Every component is `M3e.<name> [ attributes ] [ children ]`, from the one-import `M3e` barrel.
- `M3e.toNode` renders your composed value at your app's root.
- **Next: [Invalid states don't compile](/guide/invalid-states) →** we compose the *wrong* thing on purpose — and watch the compiler refuse it.
