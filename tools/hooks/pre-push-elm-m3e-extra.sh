# --- elm-m3e-specific: build + commit docs/dist/ so Netlify serves the prebuilt static output ---
# Netlify is configured with `command = "true"` (no-op) and `publish = "dist/"`,
# so it serves the committed dist/ directly without any Elm build on its end.
# This trades large, churny diffs in git history for instant, reproducible
# deploys — explicitly accepted for a docs repo.
#
# SCOPE SAFETY: this stages ONLY docs/dist/ via pathspec. It never runs
# `git add -A`/`git add .`, so a developer's unrelated uncommitted edits are
# never swept into this commit.
#
# THE GIT-REF WRINKLE: git snapshots each ref's SHA *before* invoking this hook,
# so a commit created inside the hook is NOT included in the same push (verified
# empirically). We therefore push the advanced ref ourselves under the
# recursion guard (PREPUSH_GENERATED_SELF, set at the top of this file) and
# then exit non-zero to abort the outer push's now-stale transfer. The
# trailing "failed to push some refs" line git prints is cosmetic — the real
# work (your commits + dist) is already on origin. Cost of this design:
# `git push` returns non-zero on the run that commits dist. The upside is
# Jack's intent — one `git push`, no manual re-push.
#
# NON-INTERACTIVE / CI PUSHERS: the unavoidable non-zero exit reads as a hard
# failure to a scripted `git push`. Because a non-interactive push cannot serve
# a Netlify deploy anyway (PRs + production deploys are triggered by branch
# pushes, not CI `git push`), a non-interactive push (no TTY on stdout, or $CI
# is set) skips the dist build+commit and exits 0 cleanly.
# Force the commit+self-push with PREPUSH_FORCE_DIST_COMMIT=1 (exits non-zero).
#
# Additional escape hatch beyond the shared base's (git push --no-verify /
# SKIP_GATE=1 — both also skip this section, since it runs after the gate):
#   PREPUSH_FORCE_DIST_COMMIT=1 …   force the dist commit+self-push in a
#                                   non-interactive/CI context (exits non-zero by design)
#
# Uses $refs (captured once by the shared base above) and $remote_name
# (captured by this file's wrapper before the shared base ran).

if [ "${PREPUSH_FORCE_DIST_COMMIT:-}" != "1" ] && { [ -n "${CI:-}" ] || [ ! -t 1 ]; }; then
  echo "pre-push: non-interactive/CI push — skipping dist build+commit."
  echo "          Force with PREPUSH_FORCE_DIST_COMMIT=1 (exits non-zero by design)."
  exit 0
fi

echo "pre-push: building docs/dist/ via pnpm run build:ci ..."
pnpm --prefix "$repo_root/docs" run build:ci

# Stage ONLY docs/dist/ — never git add -A or any wider pathspec.
git add -- docs/dist 2>/dev/null || true

if git diff --cached --quiet -- docs/dist 2>/dev/null; then
  # Nothing in dist changed. Un-stage defensively, let the normal push proceed.
  git reset -q -- docs/dist 2>/dev/null || true
  echo "pre-push: docs/dist/ unchanged — no commit needed."
  exit 0
fi

# Only docs/dist/ is committed. Pass the pathspec to `git commit` as a
# belt-and-braces guarantee: even if the developer had OTHER changes pre-staged,
# only docs/dist/ ends up in this commit. --no-verify skips pre-commit hooks
# (a commit never re-fires pre-push; --no-verify here is safe and standard).
git commit -q --no-verify -m "chore(docs): prebuilt dist/ [skip ci]" -- docs/dist
new_sha=$(git rev-parse HEAD)
echo "pre-push: committed prebuilt dist/ -> $new_sha"

# Push the advanced ref ourselves (git already snapshotted the pre-commit SHA for
# the outer push, so the outer push would NOT carry this commit). Only the ref
# matching the current branch gets the dist commit — the tree the gate built.
cur=$(git symbolic-ref --quiet --short HEAD || echo "")
pushed_self=0
if [ -n "$cur" ]; then
  printf '%s\n' "$refs" | while read -r local_ref _local_sha remote_ref _remote_sha; do
    [ -z "$local_ref" ] && continue
    if [ "$local_ref" = "refs/heads/$cur" ]; then
      echo "pre-push: pushing dist commit on $cur ..."
      PREPUSH_GENERATED_SELF=1 git push "$remote_name" "$local_ref:$remote_ref"
    fi
  done
  pushed_self=1
fi

if [ "$pushed_self" = "1" ]; then
  echo ""
  echo "=================================================================="
  echo "pre-push: dist/ committed ($new_sha) and pushed."
  echo "          The trailing 'failed to push some refs' line below is"
  echo "          EXPECTED and benign: git's outer push used the pre-commit"
  echo "          ref snapshot, which is now stale. Everything (your commits"
  echo "          + prebuilt dist/) is already on origin. No re-push needed."
  echo "=================================================================="
  # Abort the outer push (its ref snapshot is stale; would get remote-rejected).
  exit 1
fi

# Detached HEAD or non-branch ref: committed but cannot reliably self-push.
echo ""
echo "pre-push: dist/ committed ($new_sha) but current ref is not a branch —"
echo "          could not auto-push. Re-run your push to send it."
exit 1
