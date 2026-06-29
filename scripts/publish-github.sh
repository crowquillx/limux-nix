#!/usr/bin/env bash
set -euo pipefail

repo="crowquillx/limux-nix"
remote="git@github.com:${repo}.git"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Initializing git repository..."
  git init -b main
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$remote"
fi

if curl -fsS "https://api.github.com/repos/${repo}" >/dev/null 2>&1; then
  echo "GitHub repository already exists: https://github.com/${repo}"
else
  echo "Creating GitHub repository ${repo}..."
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    gh repo create "$repo" --public --source=. --remote=origin --push
    exit 0
  fi

  cat <<EOF
Could not create the GitHub repository automatically.

Create it manually, then push:

  1. Open https://github.com/new?name=limux-nix
  2. Create a public repository (no README/license — this repo has them)
  3. Run: git push -u origin main

Or authenticate gh and re-run this script:

  gh auth login
  ./scripts/publish-github.sh
EOF
  exit 1
fi

current_branch="$(git branch --show-current)"
git push -u origin "${current_branch:-main}"

echo "Published to https://github.com/${repo}"
