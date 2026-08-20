@@@ intro
Accessibility here is built into the shape of the components, not bolted on as a checklist at the end. The clearest case: a control with no visible text. Our settings panel needs a small **help** button that's just an icon. A sighted user sees a "?"; a screen-reader user needs a name to read. So that name is **required** — and the accessible-name attributes (`Aria.label`, `labelledby`, `describedby`) are first-class setters on every component, right where you'd reach for them.

@@@ labeled
Add the help button *with* its accessible name and it's fine — this renders, and it announces itself as "Help":

@@@ nameless
Now drop the name. Since the `el`-unification, an icon button's accessible name isn't a linter-checked attribute anymore — `ariaLabel` is a **required record field** on `IconButton.component` itself, the same required-record mechanism that makes forgetting a Button's `action` impossible (see [the strictness dial](/guide/strictness)). Try to omit it and the build stops — the message below is the compiler's real output:

@@@ wiring
This is "accessible by construction" in practice: the requirement lives in the component's own required-record shape, so `elm make` refuses the unlabeled control instead of a human having to remember. It is a **compiler** guarantee now — no elm-review run required, no CI step to forget to wire up. And when a control has a visible label — like the text fields we build next — the label and input are wired from one shared id, so you never hand-type a matching `for`/`id` pair.

@@@ recap
- An icon-only control has no visible text, so its **accessible name is required**.
- `ariaLabel` is a **required record field** on `IconButton.component` — omitting it is a **compile error**, not a lint finding, so there's no CI step to forget.
- Visible labels are **wired to their input for you** from one shared id — no hand-typed `for`/`id`.
- **Next: [Composition, not injection](/guide/composition-text-field) →** build a text field that doesn't exist as a component — by composition.
