#!/usr/bin/env bash
pnpm exec hexo clean && pnpm exec hexo generate
git worktree add .deploy gh-pages 2>/dev/null || git worktree add -B gh-pages .deploy
rsync -a --delete public/ .deploy/ && touch .deploy/.nojekyll
git -C .deploy add -A && git -C .deploy commit -m "deploy $(date -u +%FT%TZ)" || true && git -C .deploy push origin gh-pages


