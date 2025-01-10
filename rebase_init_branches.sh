#!/usr/bin/env bash
set -euo pipefail

#
# This script rebases all init branches onto the main branch.
#

local_path=$(mktemp -d -t rebase-init-branches-XXXXX -p .)

gh repo clone https://github.com/Hapag-Lloyd/Repository-Template-Python.git "$local_path"
cd "$local_path"

git fetch --all

# for all init branches missing locally, create a local branch tracking the remote branch
git branch -r | grep "init-" | grep -v '\->' | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | while read -r remote; do
  echo "Checking $remote"
  local_branch=${remote#origin/}

  if git branch --list | grep "$local_branch"; then
    continue
  fi

  git branch --track "$local_branch" "$remote";
done

for branch in $(git branch --list "init-*"); do
  echo "Rebasing $branch onto origin/main"

  git checkout "$branch"
  git rebase origin/main
  git push --force
done
