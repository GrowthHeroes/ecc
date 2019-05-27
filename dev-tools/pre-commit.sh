#!/bin/sh

echo 'Start git pre-commit'
# Select only triggers or classes that have Diffs to Prettify
FILES=$(git diff --name-only --diff-filter=ACM "*.trigger" "*.cls" | sed 's| |\\ |g')
[ -z "$FILES" ] && exit 0

# Prettify all selected files
echo "$FILES" | xargs ./node_modules/.bin/prettier --write "sfdx-source/ecc/main/default/**/*.{trigger,cls}"

# Add back the modified/prettified files to staging
echo "$FILES" | xargs git add

exit 0