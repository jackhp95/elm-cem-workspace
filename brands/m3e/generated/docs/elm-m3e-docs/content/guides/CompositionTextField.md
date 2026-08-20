@@@ intro
The settings panel needs text fields. Reach for `M3e.TextField` and… there isn't one — and there doesn't need to be. A text field is not a special component; it's a few typed pieces **composed**. That's the whole point of this chapter: you build things bigger than one component by clicking small typed parts together, and the guarantees you've met so far come along for the ride.

@@@ composed
Here's the Email field. A **form field** holds two things: a native `<label>` and a typed native `<input>`. They're wired into one accessible control by a single shared id — `"email-field"` appears once on the label slot and once on the input slot, and the library stamps the matching `for`/`id` for you. This is the label wiring from [accessibility you can't forget](/guide/accessible-by-construction), paying off exactly where you'd want it:

@@@ native
Two things make this safe. First, **native HTML is first-class and typed.** `TypedHtml.input` is a real `<input>`, but its attributes are closed to the ones an input actually permits — `type_`, `placeholder`, `name`, `value`, `checked`… An input has no `href`, so `TypedHtml.input [ TypedHtml.Attributes.href "/x" ]` is a **compile error**, not a raw-HTML escape hatch. You get the exact tag you asked for, with the exact attributes it's allowed.

Second, **the library never injects.** It assembles the pieces you wrote — it doesn't secretly wrap, reorder, or add structure around your content. What you write is what renders. A search field is the same move with a different input `type_`; once you can compose one field, you can compose any of them.

@@@ recap
- There's no `M3e.TextField` — a field is **composed**: form field + typed native `<input>` + a label wired by one shared id.
- **Native HTML is typed**: an `<input>` with an `href` doesn't compile.
- The library **assembles, never injects** — what you write is what renders.
- **Next: [Generated & inspectable](/guide/generated-and-inspectable) →** you've built real things on this API; now see why you can trust it — it's generated, and inspectable data underneath.
