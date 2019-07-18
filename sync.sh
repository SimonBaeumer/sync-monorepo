#!/usr/bin/env bash
set -uo pipefail
# Usage: ./sync.sh master git@github.com:SimonBaeumer
# Create subtree splits from current branch and sync it with other repositories


REF_NAME=${1:-"master"}
REMOTE=${2:-""}
PROJECTS_PATH=${3:-""}
echo "Syncing ref ${REF_NAME}"

function detect_ref_type {
    git show-ref --verify --quiet "refs/heads/${REF_NAME}"
    if [[ $? == 0 ]]; then
        echo "branch"
        return 0
    fi

    git show-ref --verify --quiet "refs/tags/${REF_NAME}"
    if [[ $? == 0 ]]; then
        echo "tag"
        return 0
    fi

    echo "No valid ref given"
    exit 1
}

function sync_tag {
    TAG=$1
    PROJECT=$2
    git tag -l | grep "${TAG}" &>/dev/null
    if [ 0 -eq "$?" ] ; then
        echo "Temporary delete tag of mono-repo"
        git tag -d "${TAG}"
    fi

    git tag "${TAG}"

    echo "Push tags"
    git push "${project}" --tags

    echo "Removing created tag"
    git tag -d "${TAG}"
}

function create_split {
    PROJECTS_PATH=$1
    project=$2

    git remote rm "${project}" > /dev/null || true
	git branch -D "${project}" > /dev/null || true

    echo "Splitting ${PROJECTS_PATH}/${project}"
    SHA1=$(splitsh-lite --prefix="${PROJECTS_PATH}/${project}")

	echo "Check out ${SHA1}"
    git checkout "${SHA1}" > /dev/null

    echo "Creating branch ${project}"
    git checkout -b "${project}" > /dev/null
}

REF_TYPE=$(detect_ref_type)
echo "REF-TYPE is ${REF_TYPE}"

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
if [[ $? != "0" ]]; then
    echo "Need a clean HEAD to sync branches."
    exit 1
fi


echo "Scanning ${PROJECTS_PATH}"
for project in $(ls "${PROJECTS_PATH}"); do
	echo "##########################################"
	echo "#### Sync ${PROJECTS_PATH}/${project} ####"
	echo "##########################################"

    create_split "${PROJECTS_PATH}" "${project}"

    # Add project remote
	echo "Add remote ${REMOTE}/${project}"
    git remote add "${project}" "${REMOTE}/${project}"

    ls -la

    if [[ "${REF_TYPE}" == "tag" ]]; then
        sync_tag "${REF_NAME}" "${project}"
    fi

    if [[ "${REF_TYPE}" == "branch" ]]; then
        echo "Push to ${project}:${REF_NAME}"
        git push -f "${project}" "${project}:${REF_NAME}"
    fi

	echo "Reset git..."
    git checkout "${REF_NAME}"
    git branch -D "${project}"
    git remote rm "${project}"
done