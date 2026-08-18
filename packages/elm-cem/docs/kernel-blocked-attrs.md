# Why `elm/virtual-dom` cannot express some attributes at all

The full rationale for `Attr.kernelBlockedReason : AttrSpec -> Maybe String`,
moved out of `codegen/Attr.elm`'s doc comment (finding 4, Theme 4 of the
2026-08-17 thermonuclear review — `Attr.elm` was ~55% load-bearing prose;
this block alone was ~125 lines). `kernelBlockedReason` still carries a short
summary and a link back here; read this file for the complete argument and
the kernel-source evidence behind each case.

`Nothing` means there IS a working path from Elm for the given attribute.

This is a DIFFERENT kind of "not emittable" from `ASkip`, and the distinction
is the whole point of a second predicate. `ASkip` is about the VALUE: a DOM
element reference or a callback has no Elm spelling, so no setter is
possible. This is about the NAME: the value is a perfectly ordinary string,
and the setter compiles and runs — it just does not do what it says, because
`elm/virtual-dom`'s kernel silently rewrites the name on the way to the DOM,
or the DOM ignores it at the point virtual-dom writes it.

A setter like that is worse than a missing one. `formaction "…"` type-checks,
renders, produces no error and no warning, and quietly emits
`data-formaction="…"` — a `<button formaction>` that does not override the
form's action. The bug is invisible from Elm and invisible in the generated
docs. So the policy is: do not advertise it. Every emitted surface omits it
(shared canonical, per-element re-export, builder pipe, `Attrs` capability
row, `Review/Facts` roster), the run REPORTS each omission on the info
channel, and the emitted `<Lib>.Attributes` docs carry a note naming the
kernel function responsible.

**Do not "restore the missing setter".** Every case below is a fact about
`elm/virtual-dom 1.0.5`, verified in
`~/.elm/0.19.1/packages/elm/virtual-dom/1.0.5/src/`, and none of them is
defeatable from Elm. If you need one of these attributes, the escape hatch is
a port or a custom element, not a setter here.

## The cases, and the kernel code that causes each

- **Any content attribute whose name matches `/^(on|formAction$)/i`.**
  `VirtualDom.attribute` (and `attributeNS`) runs its key through
  `Elm.Kernel.VirtualDom.noOnOrFormAction`, which is

      var _VirtualDom_RE_on_formAction = /^(on|formAction$)/i;

      function _VirtualDom_noOnOrFormAction(key) {
          return _VirtualDom_RE_on_formAction.test(key) ? 'data-' + key : key;
      }

  so the name reaching `setAttribute` is `data-` ++ name. This is Elm's XSS
  guard (an `on*` attribute is an inline event handler), and it is why the
  `on`-prefix test here is a GUARD rather than a special case for one name: no
  `on*` content attribute is in any manifest today, but a manifest refresh
  that adds one must not quietly ship a dead setter.

  Note how blunt that regex is. `^on` is a PREFIX with no boundary, so it
  also catches innocent names — `once`, `online`, `onward` would all render
  as `data-once` / `data-online` / `data-onward`. That is the kernel
  over-reaching, not this guard: those attributes really are unwritable from
  Elm, and reporting them is the only honest thing to do.

- **`formaction` specifically**, which is why the case above says "matches",
  not "starts with `on`". The regex's alternation is `(on|formAction$)` and
  the `i` flag applies to the whole pattern, so `^formAction$` matches the
  lowercase content-attribute spelling `formaction` that HTML actually uses.
  `Ir.attribute "formaction" url` renders `data-formaction="…"`.

  The property path is closed too, so there is no way around it:
  `VirtualDom.property` runs `noInnerHtmlOrFormAction`, which rewrites the
  exact key `formAction`; and the lowercase key `formaction` escapes that
  test only to become an inert JS expando — `<button>` has no `formaction`
  property, so nothing observes the write. There is NO working path from Elm
  for `formaction`, in either form.

- **`innerHTML` / `outerHTML` as PROPERTY keys.** `VirtualDom.property` runs

      function _VirtualDom_noInnerHtmlOrFormAction(key) {
          return key == 'innerHTML' || key == 'outerHTML' || key == 'formAction'
              ? 'data-' + key : key;
      }

  That test is case-SENSITIVE (`==`, not a regex), so the exact spellings are
  rewritten to `data-innerHTML` / `data-outerHTML`. A near-miss spelling like
  `innerHtml` slips past the test and then fails the other way: the
  element's property is `innerHTML`, so `innerHtml` is an inert expando. Both
  spellings are matched here, case-insensitively, because both have the same
  outcome — nothing reaches the DOM.

  Only the PROPERTY form is blocked. There is no `innerhtml` CONTENT
  attribute in HTML for the kernel to rewrite, so `Ir.attribute "innerhtml"`
  writes a meaningless-but-untouched attribute. That is a manifest problem,
  not a kernel one, and this predicate answers only for the kernel.

- **`is`, in either form.** Customized built-in elements are opted in at
  CREATION time — `document.createElement(tag, { is })` — and never
  afterwards. `_VirtualDom_render` creates every node with

      _VirtualDom_doc.createElement(vNode.__tag)

  (no options argument; the namespaced branch above it is
  `createElementNS(vNode.__namespace, vNode.__tag)`, also two-argument). So
  by the time any attribute or property fact is applied the element already
  exists as its plain built-in self, and neither `setAttribute("is", …)` nor
  an `is` property write can upgrade it. `is` has no IDL attribute either, so
  the property form is an inert expando.

  `is` is a WHATWG **global** attribute, which makes it the one case that
  collides with a coverage gate: `elm-typed-html`'s `scripts/check-whatwg.mjs`
  asserts all 29 globals are expressible. It stays in that config's
  `_globals` roster — the config faithfully describes HTML — and the gate
  carries an explicit kernel-blocked allowance naming this reason, plus a
  check that the omission actually happened.

## Why this OMITS rather than fails the run

The family's habit is fail-loud (`guardHomeAttrTypes`, `guardHomeAttrForms`,
the config-decode error). Those all describe an AUTHORING mistake with a
concrete fix the author can apply: retype the attribute, rename it, split
the home module, fix the config typo. Failing is right because the run
cannot produce a correct answer and the author can.

A kernel-blocked attribute is not that. The manifest is CORRECT —
`formaction` and `is` are real HTML, faithfully described — and the thing
that cannot express them is `elm/virtual-dom`. There is no edit to the
manifest or the config that resolves it, so failing would mean every
regeneration of a correct manifest aborts forever. That is the wrong answer
to "HTML has an attribute Elm cannot write".

So: omit, and REPORT. One deterministic note per omission on the same info
channel the K2/K3 collapse notes use, naming the element, the attribute and
the kernel function — because silence is the failure mode this generator
keeps having to stamp out (the `datetime` regression, the `AEnumMap`
degradation).
