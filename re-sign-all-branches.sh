#!/bin/bash
set -e

# Global config
git config --global user.name "Quantum-Cipher"
git config --global user.email "cipherpunk@eternum369.com"
git config --global commit.gpgsign true
git config --global user.signingkey 48289F8DA7BA4C0F4BE8369A45BA2344CCAD2EB9

# Branch list
branches=(
  "main"
  "chore/gpg-autosign-check"
  "chore/gpg-signed-test"
  "chore/sentinel-scaffold"
  "feat/ipquery-guardian-v1"
)

for branch in "${branches[@]}"; do
  echo "🔥 Rewriting commits on $branch ..."
  git checkout "$branch"
  git rebase -r --root --exec 'git commit --amend --no-edit --reset-author -S'
  git push -f origin "$branch"
done

echo "✅ All branches re-signed, re-authored, and force-pushed with Quantum-Cipher + GPG verification!"
