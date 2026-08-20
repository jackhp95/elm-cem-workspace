@@@ intro
One thesis organizes this whole library: **a component is a single typed value, and the correct way is also the easy way.** There is no ladder of safety to climb down. What looks like "levels" is really two independent choices — *which surface* you write the value through, and *whether* you step outside the typed tree at all. This chapter is the map of both.

@@@ layers
Every component ships a handful of interchangeable **surfaces** — different call *shapes* for the same value. They are **peers, not a ranking**: pick whichever reads best at a given call site, and they all produce the identical, slottable element. Reach *past* the components only to **escape** the typed tree, and escapes are always a loud, named step — never an accident.

@@@ sameButton
Here is the running Save button, written through the barrel — the surface you'll reach for by default. It's a value that composes into a card, a list, anywhere a button belongs. Every surface below produces this *same* value with the same guarantees; they differ only in ergonomics (how much you may leave out, how you set one-only options). The escapes at the bottom are the only calls that give up the typed value — that's the whole reason they're loud.

@@@ tell
There's a simple tell that you escaped when you didn't need to: **if you're hand-writing raw HTML (`M3e.Unsafe.fromHtml`, a bare `M3e.Unsafe.customElement`) for something the library already ships as a component, you reached too far.** The typed component already carries the tag, the slots, and the tokens — spelling them out by hand throws that away. Escapes exist for what the library genuinely can't express; reaching for one otherwise is the mistake.

@@@ recap
- A component is **one typed value**, written through interchangeable **surfaces** (barrel, `component`, `build`) — **peers, not a ranking**.
- `M3e.Html.*` is the **loose** producer: opt out of strict phantom rows while staying in the IR (it is *not* plain HTML).
- You leave the typed tree only through loud, named **escapes**: `M3e.Unsafe` / `M3e.Unsafe.Attributes` (`fromHtml`, `fromNode`, `recast`, `customElement`, …) — shipped with the library, built on the raw forge `HtmlIr.Internal` that application code never touches directly. There is no second, config-blessed kind-crossing module — a specific, recurring crossing is a small named function built on `recast`.
- The tell that you over-escaped: **hand-writing raw HTML the library already ships as a component.**
- **Next: [Your own seam](/guide/seams) →** when you *do* need to step outside, do it through one of the sanctioned escapes.
