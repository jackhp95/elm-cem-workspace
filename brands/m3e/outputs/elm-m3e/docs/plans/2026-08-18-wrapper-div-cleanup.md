# Wrapper-div cleanup: cards, tabs, compose indentation

- **Date:** 2026-08-18
- **Author:** Opus 4.8 (gauntlet worker, worktree `fix-netlify-deploy-not-picked-up`)
- **Trigger:** Jack reviewed the freshly-deployed live site and flagged three concrete
  markup smells, plus a general heuristic ("sibling-less div = probably unwrappable").
- **Scope:** `packages/elm-m3e/docs/src/Doc.elm`, `Doc/Usage.elm`,
  `app/Route/Components/Name_.elm`, `app/Route/Components/Compose.elm`. All verified
  against the live rendered DOM (`https://elm-m3e.netlify.app`) via Paseo browser
  automation, not just source reading.

---

## 0. Verified facts

| Claim | Verified how | Result |
| --- | --- | --- |
| `m3e-card`'s `slot="content"` gets free padding from `CardToken.padding` (margin on `slot[name="content"]` in the shadow DOM); the *default* (unnamed) slot does not | Read `@m3e/web@2.7.6`'s compiled `dist/card.js` directly | **True.** `codeBlock`/`identicalSurfaceNote` pass children into the default slot (no `Card.content` wrapper), which is *why* they hand-paint `p-4` externally. |
| The `overflow-x-auto p-4` wrapper appears widely on the live site | `document.querySelectorAll('div.overflow-x-auto.p-4')` on `/components/card/` | **29 instances on one page alone**, all `div.overflow-x-auto.p-4 > m3e-card` (single child, no siblings). |
| Tabs sit outside the card/panel they control | `document.querySelectorAll('m3e-tabs')` parent structure on `/components/card/` | **True.** `div.space-y-3 > [P, M3E-CARD, M3E-TABS, SLIDE-PANELS]` — four flat siblings, no shared surface between the tab strip and the code panel it switches. Screenshot confirms: tabs render as bare underlined text floating in the gap between two separate bordered boxes. |
| `compose-child compose-depth-1 pl-6` — is the `pl-6` redundant | Screenshot of `/components/compose/` with a depth-1 child expanded | The depth-1 child is *already* a fully bordered/padded card (`listItem`) inside the parent `list` card — the border alone reads as "this is nested." The extra `pl-6` stacks a second nesting cue (indent) on top of the first (border), which is arguably one cue too many. **Judgment call, not a clear-cut bug** — see §3. |
| `apiGroup`/`typesBlock` in `Route/Components/Name_.elm` already use `Card.content` correctly | Read source directly | **True** — only `apiSection`'s tab strip (not the group cards themselves) has the sibling-tabs problem. |

---

## 1. Fix A — `codeBlock` / `identicalSurfaceNote`: drop the hand-painted `overflow-x-auto p-4` wrapper

**File:** `packages/elm-m3e/docs/src/Doc.elm`

Current (`codeBlock`, ~line 98):
```elm
codeBlock : Lang -> String -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy msg
codeBlock lang s =
    TypedHtml.div [ TA.class "overflow-x-auto p-4" ]
        [ M3e.card [ M3e.Attributes.variant Value.filled ]
            [ M3e.Unsafe.fromHtml (Fold.viewWith (highlightLine lang) trimmed) ]
        ]
```

Proposed:
```elm
codeBlock : Lang -> String -> Element (M3e.Component.Card.Is s) admittedBy msg
codeBlock lang s =
    M3e.card [ M3e.Attributes.variant Value.filled ]
        [ M3e.Component.Card.content
            (TypedHtml.div [ TA.class "overflow-x-auto" ]
                [ M3e.Unsafe.fromHtml (Fold.viewWith (highlightLine lang) trimmed) ]
            )
        ]
```

- Padding comes free from the `content` slot's own CSS — no hand-rolled `p-4`.
- `overflow-x-auto` moves to a small inner div wrapping *only* the scrollable text, so
  the card's own border/corners stay put and only the code scrolls — same visual
  result, one fewer layout-only class on a manually-placed div.
- The original comment worried about `overflow-x-auto` on the card itself forcing
  `overflow-y: auto` and tripping the state-layer-bleed scrollbar bug — but that bug is
  specific to *live m3e component* previews (`rawPreview`/`showcase`), not syntax-
  highlighted text. Text has no state-layer bleed, so the concern doesn't transfer.
- Same treatment for `identicalSurfaceNote` (same file, ~line 379), which explicitly
  says in its own doc comment that it copies `codeBlock`'s wrapper.

**Blast radius:** `codeBlock`'s return kind changes from `DivIs` to `Card.Is`. The
comment on the current code says this kind is "pinned verbatim across 42 call sites" —
but that count is call sites that *use* the value (mostly inside heterogeneous
`List (Element ...)` literals, which Elm infers structurally and need no edits), not
42 places that redeclare the type. The actual signatures that explicitly re-expose
`DivIs` and directly return `codeBlock`'s result (e.g. `codeFor` in `Doc/Usage.elm`)
need their signature updated too — the compiler will find every one exhaustively.
Recommend just doing it and following the compiler, rather than pre-auditing all 42.

---

## 2. Fix B — `exampleBlock`: nest the tab strip and code panel inside one card

**File:** `packages/elm-m3e/docs/src/Doc/Usage.elm`

Current (~line 201):
```elm
exampleBlock activeSurface ex =
    TypedHtml.div [ TA.class "space-y-3" ]
        [ TypedHtml.p [ TA.class "max-w-2xl" ] [ M3e.text ex.title ]
        , Doc.showcase (Doc.rawPreview ex.html)   -- live-demo card
        , surfaceTabs surface ex                   -- tabs: SIBLING, not contained
        , Doc.Slider.slidingPanels ... (codeFor ...)  -- code: SIBLING
        ]
```

Proposed — keep the live-demo showcase card as-is (it's a separate, correctly-scoped
concern: "here's what it looks like"), but fuse the tab strip + code panels into one
card using the card's own documented anatomy (`Card.header` + `Card.content` — the
exact pattern shown on `/components/card/`'s own "Anatomy" example):

```elm
exampleBlock activeSurface ex =
    TypedHtml.div [ TA.class "space-y-3" ]
        [ TypedHtml.p [ TA.class "max-w-2xl" ] [ M3e.text ex.title ]
        , Doc.showcase (Doc.rawPreview ex.html)
        , M3e.card []
            [ M3e.Component.Card.header (surfaceTabs surface ex)
            , M3e.Component.Card.content
                (Doc.Slider.slidingPanels
                    (activeIndexFor surface ex)
                    (List.map (\( _, l ) -> codeFor l ex) (surfacesFor ex))
                )
            ]
        ]
```

Each panel (`codeFor`) already renders its own `codeBlock` card (Fix A). This produces
a card-in-card: outer unstyled/default-variant card framing "tabs above, code below"
as one visual unit, inner filled card for the code surface itself — the same nesting
`typesBlock`/`apiGroup` already use elsewhere on the same page (outlined label card
containing a filled member-row list). Needs a visual check once built (screenshot
before merging) since "card directly touching card" corner-radius interplay is worth
eyeballing, not just reasoning about.

`tabStrip`'s doc comment already notes `M3e.tabs` self-scrolls horizontally and
deliberately has no `overflow-x-auto` wrapper — nothing to change there.

---

## 3. Judgment calls — resolved

Jack's decisions (2026-08-18): Fix A + Fix B — implement now. §3a (apiSection) — same
treatment as Fix B (one wrapping card). §3b (Compose `pl-6`) — drop entirely. §3c
(elm-review rule) — scope as a separate follow-up task, not part of this cleanup.

Original options kept below for context.

### 3a. `apiSection`'s tab strip (`Route/Components/Name_.elm`, ~line 247)

Structurally different from Fix B: `apiTabStrip` doesn't control *one* code panel, it
controls *which layer's members populate several separate `apiGroup` cards*
(Constructor / Attributes / Slots / Events / Other — each its own outlined card).
Fusing tabs + all group-cards into one wrapping card means nesting outlined cards
inside another card, which may look heavier than the Usage-example case. Options:
1. Same treatment as Fix B — one wrapping card, `Card.header` = tabs, `Card.content` =
   a plain div holding the group cards.
2. Leave `apiTabStrip` as a sibling but visually anchor it differently (e.g.
   `M3e.contentPane` instead of a bare div) so it's *contained* without literally
   nesting card-in-card five times over.
3. Leave as-is — this section already reads reasonably well since each group is its
   own labelled card; the "tabs float above unrelated cards" complaint may apply less
   here than to the single-code-panel Usage case.

### 3b. Compose `pl-6` depth indent (`Route/Components/Compose.elm`, ~line 1497)

Per §0, this isn't a clear "needless wrapper" the way the `p-4` div is — the div itself
carries load-bearing `compose-depth-N` classes a Playwright test asserts on
(`docs/tests-browser/compose.spec.ts` per family.json's authorized-extra list), so the
div can't just be deleted. The open question is narrower: is the `pl-6` *visual*
indent redundant now that each nested child already renders inside its own bordered
card? Options:
1. Drop `pl-6` entirely — trust the card border as the sole nesting cue.
2. Shrink it (e.g. `pl-2`) — a little breathing room without a full 24px stack per
   level.
3. Keep it — deep compose trees (3-4 levels) may still benefit from the indent once
   cards stack, even if a single level looks redundant in isolation.

Recommend a before/after screenshot at 2-3 levels of nesting before deciding — this is
a taste call that's cheap to check visually and expensive to guess blind.

### 3c. elm-review rule for "sibling-less wrapper div"

Jack asked whether this pattern is worth an elm-review rule. Checked
`packages/elm-review-cem`'s existing 11 rules for precedent — none currently lint
`Html`/`TypedHtml` structure; the closest analog is `NoNonLayoutTailwindClasses`,
which handles a similar "needs judgment, not just AST shape" problem via an allowlist.

The real difficulty: a rule can't know from the AST alone whether a single-child div is
CSS-load-bearing (flex/grid item, positioning context, scroll container, a test hook
like `compose-depth-N`) or genuinely redundant. A blind "flag every `div [] [ x ]`"
rule would have cried wolf on `Doc.message`, `Doc.elmSignature`, and the Compose
depth-tracking div in this very audit — all single-child, all legitimate.

Feasible middle ground: a **warning-level** rule flagging `TypedHtml.div` calls whose
class list contains *only* padding/spacing utilities (no `flex`, `grid`, `overflow-*`,
`absolute`/`relative`, or a project-recognized data-attribute prefix like
`compose-*`/`sp-*`) **and** whose single child has no siblings — i.e. the exact shape
Fix A was. This would have caught `codeBlock`'s `overflow-x-auto p-4` div... except
that div also has `overflow-x-auto`, which the heuristic above would need to
special-case (a plain overflow wrapper is sometimes legitimate, as `preBlock` shows).
Given the false-positive risk, suggest treating this as a **separate follow-up task**
(possibly its own plan doc) rather than bundling it into this cleanup — happy to scope
it next if you want it.

---

## 4. Sequencing

1. Fix A (`Doc.elm`) — mechanical, low-risk, compiler-verified blast radius.
2. Fix B (`Doc/Usage.elm`) — needs a visual check (screenshot) before calling it done.
3. 3a/3b — pick an option (or say "surprise me") and they're quick follow-ons to A/B.
4. 3c — separate task, only if wanted.
5. Regenerate `dist/` (`pnpm run build:ci`) and re-run `tools/publish-mirror.mjs
   elm-m3e --push --yes-i-am-sure` to actually ship it, per the deploy pipeline fixed
   earlier this session — a code fix alone does not reach the live site.
