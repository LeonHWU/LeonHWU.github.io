#!/usr/bin/env bash

# Clean and generate static files
pnpm exec hexo clean
pnpm exec hexo generate

# Copy files to root directory and add .nojekyll
cp -r public/* .
touch .nojekyll

# Add, commit and push to main branch
git add .
git commit -m "deploy $(date -u +%FT%TZ)"
git push origin main