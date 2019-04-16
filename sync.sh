#!/usr/bin/env bash

REMOTE="git@github.com:SimonBaeumer"
BRANCH="master"

git diff-index --quiet HEAD --
if [[ $? != 0 ]]; then
    echo "Need a clean HEAD to sync branches."
    exit 1
fi

for project in $(ls repos/); do
    echo "Syncing ${project}"
    SHA1=$(splitsh-lite --prefix=repos/"${project}")

    git checkout "${SHA1}"
    git checkout -b "${project}"

    git remote add "${project}" "${REMOTE}"/"${project}"
    git push "${project}" "${project}":"${BRANCH}" --tags

    git checkout "${BRANCH}"
    git branch -D "${project}"
    git remote rm "${project}"
done


