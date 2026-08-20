@@@ intro
Everything so far had you *reading* the tooling's output — a compile error, a lint message. This chapter flips it: the linter **writes code for you**. It knows your components (it reads the same manifest the API was generated from), so it can not only flag a problem but apply the fix. Here are the two moves that matter.

@@@ extract
**One — it removes the escapes you never needed.** You inline a raw escape in a feature module — a stray `class` on an element. The linter flags it *and names the typed setter that already covers it*: it reads the same component manifest the API was generated from, so it knows `class` has one. Run the autofix and the call site is rewritten to that setter. The escape doesn't move somewhere tidier — it stops existing. Before:

@@@ convert
**Two — it converts your codebase to one approved form.** Pin a canonical form and run the autofix; every call site is rewritten to it. This is real: these docs pin the one-import **barrel** form (`preferBarrel`, in `review/src/ReviewConfig.elm`), and the linter rewrote every per-component call site to it automatically. Before and after, from an actual autofix run:

@@@ pipeline
Anything the target form can't express doesn't vanish — it falls out as **residue routed through a seam**, and the seam-boundary check flags that on the next pass. So the rules interplay as a pipeline: *convert → residue → flag → extract*. You didn't refactor; the linter did, and it converges. Discipline is maintained **for** you.

@@@ recap
- The linter **applies fixes**, not just warnings — it knows your components.
- It **removes escapes the typed layer already covers** — naming the setter and rewriting the call site for you, so the escape is gone rather than relocated.
- It **converts your codebase to one approved form**; residue routes through seams and gets flagged next pass.
- **Next: [Troubleshooting](/guide/troubleshooting) →** when something does go wrong, how to read and rescue it.
