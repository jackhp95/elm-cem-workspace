# Compose IA Review — Hands-On Audit

**Date:** 2026-08-15
**Reviewer:** Claude (acting as IA/usability auditor)
**Feature under review:** `/components/compose` in `packages/elm-m3e/docs`, worktree `compose-poc` (`Route/Components/Compose.elm`)
**Method:** Ran the elm-pages dev server, drove the live page with Playwright (navigate/click/type/screenshot), built and manipulated a real tree for ~20 interactions. Screenshots referenced below live in `/Users/jhp/code/.tmp-compose-shots/` (not committed — grab them from that path if you want the visuals alongside this doc).

**Brief that prompted this:** "It's close, but the Information Architecture is bad, and the hierarchy is weird." This document names the specific problems behind that reaction.

---

## 0. tl;dr

The single biggest problem is **the "change component" and "add child" menus are the same shared, unfiltered, alphabetical dump of every component name in the whole library AND every documentation-example section title, with zero visual or structural distinction between the two.** A control whose entire job is "what should this become" surfaces ~300 flat, undifferentiated items including things like "Anatomy," "Sizes," "Usage," and two different items both literally labeled "Label Small." That is the hierarchy problem the commissioner felt — it's concentrated in the menus, not spread evenly across the UI.

The second biggest problem: **the chip "pressed" state is not a trustworthy signal that an edit was applied.** Selecting a value from an attribute menu and adding content via a slot menu both visually marked the corresponding chip as active/pressed, but neither the live preview nor the generated Elm code snippet changed. Right now the only way to confirm an edit actually took effect is to scroll to the code block at the bottom and read it — which defeats the purpose of a visual builder.

---

## 1. Specific problems observed (each tied to a concrete action)

### 1.1 The "Change component" menu is a 300-item flat list mixing types with doc-example titles
**Action:** Clicked the pencil ("Change component") icon on the root `list` card header (ref `e375`).
**Screenshot:** `02-change-component-menu.png`

The resulting `<m3e-menu>` (`#compose-component-menu-root`) contains, in order: `accordion`, `actionList`, `appBar`, **`Anatomy`**, **`Sizes`**, **`Sizes (2)`**, **`Centered`**, `assistChip`, `autocomplete`, `avatar`, **`Usage`**, `badge`, **`Sizes`** (again, a different one), `bottomSheet`, **`Choose a destination`**, `bottomSheetAction`, ... continuing for ~300 entries total, ending at `yearView`.

Every real, selectable component type (`appBar`, `avatar`, `badge`, ...) is interleaved with that component's doc-example section headings (`Anatomy`, `Usage`, `Sizes`, `Centered`, `Choose a destination`...). These example-title entries are **not other component types** — they're the same "load a realistic subtree" affordance the brief describes as a per-slot feature — yet here they appear as siblings of real component names in the control whose job is supposed to be "what type of component is this card." There is:
- no grouping/section header separating "components" from "examples"
- no visual weight difference (identical font, size, color for both kinds)
- no search/filter box, despite ~300 items
- no indication of which component an example title belongs to when scanning quickly (e.g. `Sizes` appears at least twice with no parent label visible in the flat list)

This is the concrete, observable form of "the hierarchy is weird": the menu structure doesn't reflect the actual conceptual hierarchy (component types vs. per-component examples vs. structural primitives) at all.

### 1.2 The same interleaving repeats in every per-slot "add child" menu — it's systemic, not a one-off
**Action:** Clicked the `leading` slot's add button on the first `listItem` card (ref `e452`), then the `overline` slot's add button (ref `e460`), then the `unnamed` slot's add button on the second `listItem` (ref `e589`).
**Screenshots:** `04-slot-add-menu-leading.png`, `05-overline-slot-menu.png`, `08-prefill-off-and-nested-menu.png`

- `leading` slot menu: `Text`, `Icon`, `avatar`, **`Usage`**, `heading`, **`Typescale variants and sizes`**
- `overline` slot menu: `Text`, `heading`, **`Typescale variants and sizes`**, **`Label Small`**, **`Emphasized typescale`**, **`Label Small (2)`**
- `unnamed` slot menu (second listItem, a totally different slot on a different card): `Text`, `heading`, **`Typescale variants and sizes`**, **`Label Small`**, **`Emphasized typescale`**, **`Label Small (2)`**

Three things stand out:
1. The pattern from 1.1 (structural primitives + real components + example titles, all flat) repeats at every slot, confirming this is the shared menu-building code, not an isolated bug.
2. Two menu items are both literally labeled **"Label Small"** with no distinguishing text (disambiguated only by an invisible `(2)` suffix a user must notice).
3. Most alarming: the `unnamed` slot menu on the **second, unrelated `listItem`** card showed **the exact same option set** as the `overline` slot menu I'd opened moments before on the **first** `listItem` card. `unnamed` on a list item should structurally accept different content than `overline` (a text-only slot) — seeing identical menus for two different slot roles suggests either a stale/leaked popover, or that slot-type constraints aren't actually being used to filter the menu contents. Either way, a user has no way to tell from the menu itself whether what they're being shown is actually valid for the slot they clicked.

### 1.3 Selecting a menu value doesn't reliably update the model — the chip lies about state
**Actions:** Selected `segmented` from the `variant` attribute menu (ref target `#compose-attr-menu-root-variant >> text=segmented`); selected `Text` from the `leading` slot menu; selected `Typescale variants and sizes` (an example) from the `overline` slot menu.
**Evidence:** After all three actions, the `variant` chip and the `leading`/`overline` slot chips all switched to a filled/`[pressed]` visual state — but the code panel at the bottom (`M3e.Html.list [] [ M3e.Html.listItem [] [ M3e.text "First item" ] , ... ]`) never changed: `variant`'s attribute list stayed `[]` and no `leading`/`overline` children appeared anywhere in the generated tree, before or after.

This means the chip's pressed/filled appearance — the *only* feedback a user gets in the card itself — is not a reliable signal that their edit was applied. The card UI and the "source of truth" code panel can silently diverge, and the only way to catch this is to read Elm syntax at the bottom of the page, which is a big ask for exactly the audience (people trying to visually explore the component library) this tool is for.

### 1.4 Visual nesting depth has only one signal (a border), which won't scale past 2 levels
**Screenshot:** `01-initial-list.png`
The root `list` card's bordered box wraps around its own Attributes/Slots row *and* its two `listItem` children — so containment-by-border does correctly say "these listItems belong to list." But there is no additional left-indent per nesting level: a child sits at essentially the same horizontal position as its parent's own content row. The only depth cue is an additional border rectangle. At the 2 levels I tested this was just barely readable; nothing in the layout suggests it would still be legible at 3–4 levels (e.g., a `card` containing a `list` containing `listItem`s each containing a nested `icon` and `chip`) — the boxes would visually stack without any indentation cue to say "this is one level deeper than that."

By contrast, **the generated Elm code snippet at the bottom does this correctly**: each nesting level gets its own `▸`-collapsible group with real indentation, so `M3e.Html.listItem` visibly sits one indent-step inside `M3e.Html.list`. The code panel is a better hierarchy visualization than the card tree it's supposedly a "simple" representation of, which is backwards for a tool whose whole premise is "look at the tree without reading code."

### 1.5 Slot chips look like "add" buttons even when they're already full, and don't distinguish "has content" from "empty"
**Screenshot:** `01-initial-list.png`
The root `list` card's `SLOTS` row shows one pill: a `+` icon, the text `unnamed`, and a count badge `2` — it is simultaneously styled as an "add" action (plus icon) and as a display of existing content (count badge), and it's the *only* slot, so there's no comparison point at the root. But on each `listItem` card, five slot chips sit side-by-side at equal visual weight: `leading`, `overline`, `supporting-text`, `trailing` (all empty, all showing a `+`) and `unnamed` (populated with 1 child, filled color, `+` icon still present, count badge `1`). A first-time scan of that row cannot tell "4 of these are empty, unused, optional decoration slots" from "1 of these already has your actual list-item text in it" without reading each label and counting badges — every slot, empty or full, gets the identical `+ name` treatment.

### 1.6 Attributes vs. Slots — the single most important distinction in the tool — is signaled only by a tiny caption and one icon
**Screenshot:** `01-initial-list.png`
`ATTRIBUTES` and `SLOTS` are rendered as small, low-contrast, all-caps micro-labels to the left of otherwise near-identical pill/chip rows. The only in-chip differentiator is that slot chips carry a `+` icon and attribute chips don't. Attributes (scalar property, click → small value menu, e.g. `segmented`/`standard`) and slots (potentially a whole nested subtree, click → menu that can spawn new child cards) are extremely different in *consequence* — one sets a string, the other can grow the tree by an arbitrary number of nested components — yet the visual system treats them as near-peers differing only by a small icon glyph in the pill.

### 1.7 The live preview has no visual identity as "the preview"
**Screenshot:** `01-initial-list.png`
"First item" / "Second item" render as two bare, unstyled text lines directly under the "Prefill examples" toggle, with no border, background, label, or "Preview" heading distinguishing them from ordinary page copy. Combined with 1.3 (edits not always propagating), a first-time user has two independent reasons to distrust or simply not notice this region: it doesn't look like a live output, and even when it is one, it doesn't reliably update.

### 1.8 Root card asymmetry (no Move/Remove) is never explained
Non-root cards (`listItem`) have Move up / Move down / Remove controls; the root `list` card has neither (correctly — you can't remove or reorder the root of your own tree). This is the *right* behavior, but nothing in the UI tells the user why the root card looks structurally different from its children — it's a silent rule to be inferred, on top of everything else being inferred (1.5, 1.6).

### 1.9 Collapse control looked like a no-op
**Action:** Clicked "Collapse" on the first `listItem` card (ref `e411`).
**Screenshot:** `07-collapsed-card.png`
After the click, the card's Attributes/Slots/Text content was still fully rendered and the chevron still pointed the same direction. I did not dig into why (could be a genuine bug, could be that this environment's screenshot missed a transition) — flagging it as observed, not root-caused, since diagnosing implementation bugs is outside this audit's scope. Worth a quick sanity check by the implementer regardless, since if it *is* broken, it compounds 1.4 (no way to manage visual complexity at depth) by removing the one tool meant to hide it.

---

## 2. What actually worked well — keep these

- **The attribute value menu is exactly right-sized.** The `variant` menu (`segmented` / `standard`) is a small, tightly-scoped popover with only the legitimate choices for that specific attribute (screenshot `03-attribute-chip-menu.png`). This is a direct, useful contrast to 1.1/1.2: the team clearly *can* build a correctly-scoped menu — the discipline just wasn't applied to the shared component-picker/slot-filler menus. Whatever pattern generates this small menu should be the template the big menus get refactored toward (grouped, filtered, one concern per menu).
- **The generated code panel's nesting is legible and correct.** Collapsible `▸` groups with real indentation per level correctly encode parent/child relationships (section 1.4). This should arguably inform how the card tree itself represents depth, rather than being treated as a secondary/output-only artifact.
- **Move up/down disabling is correct and unsurprising.** "Move up" is properly disabled on the first child, "Move down" properly disabled on the last child, on both `listItem` cards. Boundary-aware disabling like this is good instinct and should be preserved wherever reordering exists.
- **The core workflow shape is right.** Pick a root type → configure attributes → fill slots with text/icon/nested-component/example → see a live render + code — this is a sound conceptual model for a type-directed tree builder, and the underlying capability set (real usage examples as one-click subtrees, per-attribute enum/bool/text/number menus, live custom-element preview) is genuinely valuable. The rework needed here is almost entirely presentation, labeling, grouping, and feedback — not the feature set itself.
- **Prefill toggle correctly scoped to new content.** Switching "Prefill examples" off did not retroactively blank out already-populated fields (`First item`/`Second item` stayed put) — it only affects content added going forward, which is the least-surprising behavior and should stay that way.

---

## 3. Proposed reorganization

### 3.1 Split "change component" into two separate, purpose-built controls
Stop reusing one flat menu for both "swap this card's type" and "load an example subtree." They are different actions with different consequences (one replaces the card's identity and discards incompatible attrs/children; the other appends/replaces a slot's contents) and deserve different entry points:
- **"Change component" (pencil icon)** → opens a menu containing *only* real, selectable component types, grouped by the existing left-nav categories (the same categories already used in the "Components" sidebar — App Bar, Autocomplete, Avatar, Badge, ... — so users reuse a mental model they've already built from browsing the docs) and filterable by a search box at the top, given there are ~300 entries. No example titles anywhere in this menu.
- **"Add child" (the `+` on a slot chip)** → opens a menu with three fixed, always-present, visually distinct top options (**Text**, **Icon**, **Nest a component…**) followed by, *only if real usage examples exist for this slot's accepted type*, a clearly headed subsection — e.g. a divider or caption reading "Load an example" — listing example titles **qualified by their source component** (e.g. "Avatar — Usage" instead of a bare "Usage") so duplicate/ambiguous names like "Label Small" become "Heading — Label Small" / "Heading — Label Small (2)" and are actually distinguishable.

This directly fixes 1.1 and 1.2: the menu a user opens to answer "what is this" only ever contains answers to that question; the menu they open to answer "what goes inside this slot" clearly separates the three structural primitives from the (optional, clearly labeled) example shortcuts.

### 3.2 Make the Attributes/Slots distinction structural, not just iconographic
Give `ATTRIBUTES` and `SLOTS` real visual separation instead of two label captions over similar pill rows: a subtle background tint or left-border color coding one row group vs the other, and reserve the filled/dark chip style *exclusively* for "this has content" (see 3.3) so pill color stops being overloaded. The `+` icon should only appear on genuinely empty slots — a slot with content should look categorically different (e.g., no `+`, just the name and count, at heavier visual weight) from one still awaiting its first child. This fixes 1.5 and 1.6 together: attributes and slots become visually distinct row *kinds*, and within slots, "has content" and "still empty" become visually distinct chip *kinds*.

### 3.3 Fix or re-scope the pressed-state feedback problem before anything else ships
Before any menu-structure rework matters, the selection-doesn't-update-the-model issue (1.3) needs to be resolved or at minimum diagnosed by the implementer — a visual builder where the visual layer can silently drift from the actual output is a correctness problem wearing an IA costume. If it turns out to be a genuine functional bug (not a display-only issue), it should block sign-off on this feature independent of the IA rework, since no amount of relabeling menus fixes "the tool told me my edit worked and it didn't."

### 3.4 Make nesting depth read at a glance, borrowing from the code panel's own solution
Add a per-level left indent (a fixed increment, e.g. 16–24px) to child cards in addition to the existing border-per-card, the same way the code panel already indents each `▸` group correctly. Optionally add a thin vertical connector line down the left edge of a slot's children (a common tree-view convention) so "these three cards are all children of that one slot" is visible without having to trace nested borders. This fixes 1.4 by giving the card tree the same legibility the code panel already has, so the two representations agree once again.

### 3.5 Give the live preview a visible frame and label
Wrap the rendered preview in a labeled container ("Live preview" heading, subtle card/border, maybe a light background) that visually matches the seriousness of the thing it represents, so it reads as an output region rather than incidental page text. Combined with 3.3, this also gives users an obvious, well-labeled place to look to confirm an edit actually landed, instead of scrolling to the raw Elm code.

### 3.6 Add a one-line explanatory caption near the root card the first time a user lands on Compose
A single sentence — e.g. "The root card can't be reordered or removed; use the sidebar to start over with a different root component" — resolves 1.8 without adding UI chrome, and could be dismissible/localStorage-persisted so it doesn't nag returning users.

---

## 4. Suggested priority order for an implementer

1. **3.3** (verify/fix pressed-state ≠ applied-state) — correctness gate, blocks trusting anything else.
2. **3.1** (split change-component vs. add-child menus, remove example-title pollution from the type picker) — this is the literal "IA is bad" complaint; highest leverage single fix.
3. **3.2** (attribute/slot visual separation, "has content" vs "empty" chip states) — second-highest leverage, fixes the "hierarchy is weird" feeling within a single card.
4. **3.4** (indentation/connector lines for nesting depth) — matters increasingly at 3+ levels; worth doing before the tool is used on more complex components (cards, dialogs, drawers).
5. **3.5, 3.6** — polish, done last.
