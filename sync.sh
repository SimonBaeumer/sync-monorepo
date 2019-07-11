#!/usr/bin/env bash
set -euo pipefail
# Usage: ./sync.sh master git@github.com:SimonBaeumer
# Create subtree splits from current branch and sync it with other repositories


BRANCH=${1:-"master"}
REMOTE=${2:-""}
PROJECTS_PATH=${3:-""}
echo "Syncing branch ${BRANCH}"

git show-ref --verify "refs/heads/${BRANCH}"

# Check if is given
if [[ -z "${REMOTE}" ]]; then
    echo "Missing remote to sync to..."
    exit 1
fi

# Check if path to synced projects exists
if [[ -z "${PROJECTS_PATH}" ]]; then
    echo "Missing path to projects..."
    exit 1
fi

# Check if HEAD is clean
git diff-index --quiet HEAD --
if [[ $? != 0 ]]; then
    echo "Need a clean HEAD to sync branches."
    exit 1
fi

echo "Scanning ${PROJECTS_PATH}"
for project in $(ls "${PROJECTS_PATH}"); do
    echo "Syncing ${PROJECTS_PATH}/${project}"
    SHA1=$(splitsh-lite --prefix=${PROJECTS_PATH}/"${project}")

    git checkout "${SHA1}"
    git checkout -b "${project}"

    git remote add "${project}" "${REMOTE}"/"${project}"
    git push "${project}" "${project}":"${BRANCH}" --tags

    git checkout "${BRANCH}"
    git branch -D "${project}"
    git remote rm "${project}"
done
