# Phantom-type acid probes

The library's whole claim is that **invalid compositions do not compile**. These
probes are the evidence. They run as the `acid` stage of `npm run check:cem`
(→ `elm-cem gate` → `elm-cem acid`).

## Convention

Set by [`elm-cem/bin/acid.js`](../../../elm-cem/bin/acid.js). Every `.elm` file
under `tests/acid/` is a probe:

| Location | Polarity | Requirement |
|---|---|---|
| `app/*.elm` | POSITIVE | MUST compile |
| `bad/*.elm` | NEGATIVE | MUST fail to compile |

(A basename starting with `Negative` is also treated as negative; this repo uses
the `bad/` directory form.)

The harness builds a scratch application, stages the generated `src/` plus the
family foundation onto its `source-directories`, flattens every probe into one
`probes/` directory, and compiles each probe **in isolation**. Module names must
therefore be unique across the whole tree, and there is no `elm.json` here — the
harness writes its own.

## Running

```sh
npm run check:cem                     # gate: drift + registry + acid
IR_SRC="$PWD/docs/vendor/elm-foundation" \
  node ../elm-cem/bin/elm-cem.js acid # acid alone
```

`IR_SRC` matters. `elm-cem acid` stages exactly two trees: the brand's `src/`
and whatever `IR_SRC` resolves to, which defaults to the sibling
`elm-html-intermediate-representation/src`. That default has no `TypedHtml.*`,
and two probes here are about the **cross-library seam**, so they need it.
`docs/vendor/elm-foundation/` is the committed, drift-checked copy of both
`HtmlIr.*` and `TypedHtml.*` that the docs app and CI already compile against,
so pointing `IR_SRC` at it stages the real family foundation rather than a
stand-in. `package.json` sets this for `check:cem`.

If `IR_SRC` is ever wrong, `app/NativeIntoM3eSlot.elm` fails to compile and the
gate goes red — the suite cannot quietly decay into negatives that "pass"
because an import went missing.

## What each probe pins

### Positive — must compile

| Probe | Invariant |
|---|---|
| `app/Good.elm` | The real composition: slot admittance the right way round, shared atoms, value narrowing, the blessed `M3e.Coerce` crossing, the write-once builder used correctly, and the single `toHtml` exit. |
| `app/NativeIntoM3eSlot.elm` | **The RC5 direction.** `TypedHtml.div` (produces `sharedFlow`) enters `M3e.AppBar.trailing`, which names the shared content categories — with no escape. And `M3e.text` / `M3e.icon`, the shared atoms, sit inside `TypedHtml.span`. A regeneration that re-closed those rows breaks this. |

### Negative — must fail

| Probe | Invariant |
|---|---|
| `bad/BadgeIntoAppBarTrailing.elm` | Slot kind admittance, brand kind: `TrailingSlot` does not name `badge`. |
| `bad/TextIntoAppBarTrailing.elm` | Slot kind admittance, shared kind: `TrailingSlot` does not name `sharedText` even though `TitleSlot` does. Guards RC5 against the cheap fix of sprinkling every shared kind onto every opted-in slot. |
| `bad/M3eHeadingIntoNativeSpan.elm` | **The documented one-way limit.** An M3e component does not enter a native container whose content model is enumerated. `/guide/seams` and `/guide/troubleshooting` state this as designed behaviour. |
| `bad/ButtonIntoHeadingContent.elm` | A restrictive default slot rejects a foreign brand kind — the claim `docs/composition.md` §1 makes. |
| `bad/BadgeAttrOnAppBar.elm` | The closed attribute-capability row, a separate mechanism from the kind rows. |
| `bad/AppBarSizeOutOfRange.elm` | Per-component value narrowing: tokens are minted open, components close the set. |
| `bad/TitleSlotWrittenTwice.elm` | The pipe-builder's write-once capability row (`Available` → `Used`). |
| `bad/AssistChipRequiredContentWrongKind.elm` | Required content is typed, not merely present. |

## Adding a probe

A negative probe that fails for the wrong reason — a typo, a missing import, an
unrelated type error — is worse than no probe, because it looks like coverage.
So, for each new `bad/` probe:

1. Read the actual compiler error and confirm it is the phantom-row mismatch you
   intended, not an incidental one.
2. Make the minimal repair that should make it legal (swap the rejected kind for
   one the slot *does* name, not "delete the line"), re-run acid, and confirm the
   stage now reports `NEGATIVE probe compiled but must be rejected`.
3. Restore it.

Step 2 is what proves the probe is load-bearing. Each docstring here names the
positive counterpart that makes the same call site legal, so the repair is
obvious to whoever comes next.
