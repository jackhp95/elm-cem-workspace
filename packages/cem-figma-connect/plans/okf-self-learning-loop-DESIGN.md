# M3E OKF self-learning loop — design (for reaction, not yet built)

Goal: when an agent hits friction with m3e (wrong tag/attr/slot, a fact it had
to be taught), that friction is captured and becomes an m3e-okf improvement —
without spraying auto-filed issues or losing the signal.

## Principle: capture is cheap + automatic; submission is gated + human-reviewed
Auto-filing issues from an agent's self-assessment is risky (noise, duplicates,
hallucinated "gaps" that already exist — exactly the mistake I nearly made:
"file docs for card slots" when they were already documented). So: **automate
capture, gate submission behind a human.**

## The loop (4 stages)

### 1. Capture — a friction ledger (append-only, local)
A tiny helper the agent (or a hook) appends to `~/.m3e-okf/friction-log.jsonl`:
```json
{"ts":"…","repo":"cem-figma-connect","component":"m3e-card","kind":"unknown-slot",
 "expected":"image goes where?","actual":"guessed default slot","resolved":"slot=header",
 "docHadIt":true,"skillInstalled":false}
```
Key fields: `docHadIt` (was it already documented?) and `skillInstalled` (was the
skill even available?). These two split "install/discoverability problem" from
"genuine content gap" — the distinction that matters most (this whole session was
the former). Capture is one line, no judgment, no network.

### 2. Triage — periodic, human-in-the-loop
A `review-frictions` skill/script reads the ledger, dedups (by component+kind),
and buckets:
- `skillInstalled:false` → **install/discoverability** signal (→ Issue 1 class).
- `docHadIt:false` → **genuine content gap** (→ a doc PR).
- `docHadIt:true & skillInstalled:true` → the doc exists but wasn't found/clear →
  **findability/wording** signal.
It prints a digest; the human picks which become issues/PRs.

### 3. Submit — gated `gh issue create`
Only after human OK. The script drafts the issue body from the ledger entries
(like the DRAFTS file), the human approves, then it files + records the issue
number back into the ledger (so the same friction isn't re-filed).

### 4. Refine — close the loop
Filed issues drive doc/skill PRs. When a doc is updated, the corresponding ledger
entries are marked `resolved-in: <commit>`. Next capture of the same friction is
suppressed (already resolved) unless it recurs post-fix (→ reopen signal).

## What NOT to do
- No fully-autonomous filing (step 3 is always human-gated).
- No "the agent thinks X is undocumented" issues without the `docHadIt:false`
  check — verify against the skill first (grep the component doc) before claiming a gap.
- No PII / repo-internal detail in the ledger beyond component + friction kind.

## Minimal first build (if approved)
- `friction log <json>` appender (10 lines).
- `friction review` digest (read ledger, dedup, bucket, print).
- Manual `gh issue create` from the digest (no auto-submit yet).
Defer the fully-automatic hook-driven capture until the manual loop proves useful.
