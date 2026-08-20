@@@ intro
Here's the promise that started this: **put the wrong thing in the wrong place and the *build* stops — not the browser.** Two plain ideas do all the work.

Every piece of content carries an invisible tag for its **kind** — the category it is: an icon, some text, a button. And every **slot** — a labeled place a component puts content — declares which kinds it will accept. Line those up and it compiles. Mismatch them and it doesn't.

@@@ valid
Give the Save button a leading icon. The button has an `icon` slot, and that slot accepts icon-kind content. `M3e.icon` is icon-kind, so it drops right in — this renders:

@@@ broken
Now do it wrong on purpose. The `icon` slot accepts only icon-kind content — put a **chip** in there instead and the build refuses. This is the real output of `elm make`, not a screenshot we wrote:

@@@ readError
Read it the plain way: *"this is a chip; the icon slot only takes icons."* The compiler even guesses your intent — *maybe chip should be icon?* You never shipped a broken button, because it was never a value you could build. The same guard covers variants: a variant that doesn't exist isn't a name you can type — only the real tokens (`M3e.Attributes.variant Value.filled`, `M3e.Attributes.variant Value.outlined`, …) exist at all.

**The browser never sees the mistake — the compiler does.**

One boundary to be precise about: this hard, compile-time guard is what the *type system* gives you — a wrong-kind child in a named slot, or a token that doesn't exist. The component-agnostic slot setters (`M3e.slotLeading`, …) accept the *union* of every component's kinds, so placing a child in a slot the container doesn't declare is caught not by the compiler but by an elm-review rule (`Cem.ValidSlotKind`) — which you run in CI. The next chapter is the dial for exactly this: what the compiler holds versus what the linter holds.

@@@ recap
- Every piece carries a **kind**; every **slot** declares the kinds it accepts.
- A mismatch is a **compile error** — the wrong UI is never a value you can build.
- The error names the culprit in plain terms and often guesses the fix.
- **Next: [The strictness dial](/guide/strictness) →** the compiler leaves some checks loose on purpose — here's the dial that turns them back up.
