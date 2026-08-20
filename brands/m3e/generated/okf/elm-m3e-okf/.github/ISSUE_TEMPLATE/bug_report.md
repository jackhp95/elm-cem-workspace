---
name: Bug report
about: The skill is wrong, out of date, or a build check misbehaves
title: "[bug] "
labels: bug
---

## What happened

{{Clear description. If the skill led an agent to emit wrong markup, say which
component card or concept page, and what was wrong (bad tag / attribute / slot / enum
/ default / citation).}}

## Minimal reproduction

{{The smallest markup snippet or the exact card/page section that reproduces it.
"The skill is wrong somewhere" without specifics will be closed with a request for a
concrete example.}}

## Expected vs actual

- **Expected:** {{what the CEM / upstream actually says}}
- **Actual:** {{what the skill says}}

## Environment

- Commit / pinned `@m3e/web` SHA (from `data/sources.json`): {{…}}
- Node version: {{…}}
- Which output: {{component card / concept page / example markup / build script}}

## If a build check failed

{{Paste the command you ran (`npm test`, `npm run check:skill`, etc.) and its output.}}
