#!/usr/bin/bash

PROG=bump.sh

USAGE="\
  Usage:
    $PROG <language_flag> (--ruby/-r/--js/-j)

  How to bump version:
    Use trigger-words in commit message (major/minor/patch)
    to let the script know how to change your current versioning.
    Short version of current commit and current version are stored
    inside the '.tags' file.
    If no trigger words used, then script will push current commit message
    without changing versioning, and rewrite only commit hash inside '.tags' file.

  Options:
    -j, --js                    JavaScript repo.
    -r, --ruby                  Ruby repo."

kite_func() {
    git config --global user.name "Kite Bot"
    git config --global user.email "kite-bot@heliostech.fr"
    git remote add authenticated-origin https://kite-bot:$GITHUB_API_KEY@github.com/${DRONE_REPO}
    git fetch authenticated-origin
}

scan_git() {
     if git log --oneline -n 1 HEAD | grep -qi 'patch'; then
         BUMP="patch"
     elif git log --oneline -n 1 HEAD | grep -qi 'minor'; then
         BUMP="minor"
     elif git log --oneline -n 1 HEAD | grep -qi 'major'; then
         BUMP="major"
     fi
     echo $BUMP
}

error() {
  echo -e "$1" >&2
  exit 1
}

usage_help() {
  error "$USAGE"
}

scan_language() {
    if [[ -n $BUMP ]]; then
        case "$1" in
            -r|--ruby)
                CMD="bump $BUMP"
                ;;
            -j|--js)
                CMD="yarn version --$BUMP"
                ;;
            *)
                usage_help
                ;;
            esac
    eval $CMD
    fi
}

scan_flag() {
    if [[ -n $BUMP ]]; then
         git tag $(cat VERSION)
    fi
}

kite_func
BUMP="$(scan_git)"
scan_language $1
git add .
scan_flag
git push authenticated-origin ${DRONE_BRANCH}
git push --tags authenticated-origin
echo -n "$(git rev-parse --short HEAD)," > .tags
echo $(git describe --tags $(git rev-list --tags --max-count=1)) >> .tags
