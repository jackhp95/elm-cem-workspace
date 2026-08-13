# Design-review regression corpus

Seven seeded design violations in elm-m3e view code. Each is a snippet a review MUST
catch, with the intent, the fix, and the knowledge-base page. This is the reproducible
eval set for `reviewing-m3e-designs`; a passing review flags at least items 1–5.

---

## V1 — FAB for a secondary/destructive action

```elm
-- On a settings screen: a FAB wired to "Delete account".
Fab.view
    { content = M3e.icon [ M3e.attrName "delete" ] [], action = Action.onClick DeleteAccount }
    [ Fab.variant Value.error ] []
```

**Wrong:** a FAB is the single most important *constructive* action on a screen; a
destructive/secondary action does not belong there.
**Fix:** a text/outlined `M3e.button` (or a menu item), destructive styling reserved and
confirmed. **Anti-pattern:** `fab-for-non-primary-actions`.

## V2 — Dialog for non-blocking info

```elm
-- A "Saved!" confirmation shown as a modal dialog the user must dismiss.
M3e.dialog [ M3e.attrOpen model.justSaved ]
    [ M3e.dialogSlotHeadline (Kit.text "Saved")
    , Kit.text "Your changes were saved."
    ]
```

**Wrong:** a dialog blocks; a transient success message should not.
**Fix:** an `M3e.Snackbar` (transient) or inline status text.
**Anti-pattern:** `dialog-for-non-blocking-info`.

## V3 — Chip set used for single mutually-exclusive choice

```elm
-- Picking ONE theme (Light/Dark/System) with a set of assist chips.
Native.div "flex gap-2"
    (List.map (\t -> AssistChip.view { content = Kit.text t } [] []) [ "Light", "Dark", "System" ])
```

**Wrong:** a chip set (esp. assist chips) doesn't express single-select semantics; nothing
reads "one of these is chosen". This is exactly the Settings theme row.
**Fix:** a `Radio` group sharing one `M3e.attrName "theme"` (or a `SegmentedButton`), as
`docs/app/Route/Examples/Settings.elm`'s `themeRow` does.
**Knowledge base:** `components/chips`, `components/radio-group`, `components/segmented-button`.

## V4 — Color-only state signaling

```elm
-- The selected row is distinguished ONLY by a colored background.
M3e.listItem [ Surface.asAttribute (if selected then Surface.primary else Surface.surface) ]
    [ Kit.text label ]
```

**Wrong:** selection conveyed by color alone fails for color-blind users and low-contrast
conditions.
**Fix:** pair the surface change with a non-color cue — a leading check icon,
`M3e.attrSelected`, or `aria-selected` — and use a *surface* role
(`surfaceContainer`), not `primary`, for a selected row.
**Anti-pattern:** `color-only-state-signaling`.

## V5 — Too many emphasis levels

```elm
-- Every line in a card uses emphasized/headline type.
Layout.colWith "flex flex-col gap-1"
    [ Kit.headline Value.large [ Kit.onSurface ] [ Kit.text "Weekly report" ]
    , Kit.headline Value.medium [ Kit.onSurface ] [ Kit.text "Revenue up 4%" ]
    , Kit.headline Value.small [ Kit.onSurface ] [ Kit.text "Details below" ]
    ]
```

**Wrong:** when everything is emphasized, nothing leads; the hierarchy collapses.
**Fix:** one leading element (a single headline), the rest as `title`/`body` at
`onSurfaceVariant`. Emphasis marks the moment that leads, one channel at a time.
**Knowledge base:** `expressive/emphasized-type`, `expressive/applying-expressive`,
`anti-patterns/too-many-emphasis-levels`.

## V6 — Over-expressive motion in a dense workflow

```elm
-- Spring/expressive motion applied app-wide, including a dense mail list.
Theme.view [ Theme.withMotion Theme.MotionExpressive ] [ mailInboxTable ]
```

**Wrong:** physics/spring motion on a high-frequency dense surface (a mail list, a data
table) is fatiguing and slows scanning.
**Fix:** `Theme.MotionStandard` for functional transitions on dense surfaces; reserve
`MotionExpressive` for key, low-frequency moments (a hero, a celebratory confirm).
**Anti-pattern:** `over-expressive-motion-in-dense-workflows`.

## V7 — Nameless icon-only control (a11y + design)

```elm
M3e.iconButton [] [ M3e.icon [ M3e.attrName "arrow_back" ] [] ]
```

**Wrong:** an icon-only control with no accessible name announces nothing; also the
pattern `elm-review`'s `missingRequiredAttribute` refuses in CI.
**Fix:** `M3e.iconButton [ M3e.ariaLabel "Back" ] [ … ]`.
**Cross-skill:** making-m3e-accessible; knowledge base `foundations/accessibility`.

---

### How to score a review

A competent review of a screen containing these MUST flag V1–V5 (component-choice and
expressive-discipline violations) with the intended fix and the naming of the
anti-pattern. V6–V7 are the stretch items (motion discipline and the a11y overlap). A
review that only reports the `elm-review` output and misses the component-choice
violations has failed the design pass.
