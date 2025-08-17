#!/usr/bin/env bash

set -euo pipefail

# Configuration
BRANCH="${1:-gh-pages}"
REMOTE="${REMOTE:-origin}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKTREE_DIR="${ROOT_DIR}/.deploy"

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm is required. Please install pnpm: https://pnpm.io/installation" >&2
  exit 1
fi

echo "==> Installing deps (if needed)"
pnpm install --frozen-lockfile=false

echo "==> Cleaning and generating site"
pnpm exec hexo clean
pnpm exec hexo generate

echo "==> Preparing worktree for branch '${BRANCH}'"
if [ -d "${WORKTREE_DIR}" ]; then
  git worktree remove --force "${WORKTREE_DIR}" || rm -rf "${WORKTREE_DIR}"
fi

git fetch "${REMOTE}" --prune

if git ls-remote --exit-code --heads "${REMOTE}" "${BRANCH}" >/dev/null 2>&1; then
  git worktree add -B "${BRANCH}" "${WORKTREE_DIR}" "${REMOTE}/${BRANCH}"
else
  git worktree add -B "${BRANCH}" "${WORKTREE_DIR}"
fi

echo "==> Syncing generated files to worktree"
rsync -av --delete --exclude '.git' "${ROOT_DIR}/public/" "${WORKTREE_DIR}/"
touch "${WORKTREE_DIR}/.nojekyll"

echo "==> Committing and pushing to '${BRANCH}'"
pushd "${WORKTREE_DIR}" >/dev/null
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "deploy: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
  git push "${REMOTE}" "${BRANCH}"
  echo "==> Deployed to $(git remote get-url ${REMOTE}) on branch '${BRANCH}'"
else
  echo "No changes to deploy."
fi
popd >/dev/null

echo "Done. If not already, set GitHub Pages source to branch '${BRANCH}' (root)."


