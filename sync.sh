#!/usr/bin/env bash
set -euo pipefail
# Usage: ./sync.sh master git@github.com:SimonBaeumer
# Create subtree splits from current branch and sync it with other repositories


BRANCH=${1:-"master"}
REMOTE=${2:-""}
PROJECTS_PATH=${3:-""}
TAG=${4:-""}
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
EXIT_CODE=$(git diff-index --quiet HEAD -- && echo $?)
if [[ "${EXIT_CODE}" != "0" ]]; then
    echo "Need a clean HEAD to sync branches."
    exit 1
fi

# Delete tag if it already exists
git tag -l | grep "${TAG}" &>/dev/null
if [ 0 -eq "$?" ] ; then
    echo "Temporary delete tag of mono-repo"
    git tag -d "${TAG}"
fi

echo "Scanning ${PROJECTS_PATH}"
for project in $(ls "${PROJECTS_PATH}"); do
	echo "##########################################"
	echo "#### Sync ${PROJECTS_PATH}/${project} ####"
	echo "##########################################"

	git remote rm "${project}" > /dev/null || true
	git branch -D "${project}" > /dev/null || true

    echo "Splitting ${PROJECTS_PATH}/${project}"
    SHA1=$(splitsh-lite --prefix="${PROJECTS_PATH}/${project}")

	echo "Check out ${SHA1}"
    git checkout "${SHA1}" > /dev/null

    echo "Creating branch ${project}"
    git checkout -b "${project}" > /dev/null

	echo "Add remote ${REMOTE}/${project}"
    git remote add "${project}" "${REMOTE}/${project}"

    ls -la

    if [[ "${TAG}" != "" ]]; then
        git tag -a "${TAG}" -m "${TAG}"
    fi

    echo "Push to ${project}:${BRANCH}"
    git push -f "${project}" "${project}:${BRANCH}" --follow-tags

	echo "Reset git..."
    git checkout "${BRANCH}"
    git branch -D "${project}"
    git remote rm "${project}"
done