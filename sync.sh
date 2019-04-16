#!/usr/bin/env bash

REMOTE="git@github.com:SimonBaeumer"
BRANCH="master"

git diff-index --quiet HEAD --
if [[ $? != 0 ]]; then
    echo "Need a clean HEAD to sync branches."
    exit 1
fi

for i in $(ls repos/); do
    SHA1=$(splitsh-lite --prefix=repos/repo01)

    git checkout "${SHA1}"
    git checkout -b "${i}"

    git remote add "${i}" "${REMOTE}"/"${i}"
    git push "${i}" "${i}":"${BRANCH}" --tags

    git checkout "${BRANCH}"
    git branch -D "${i}"
    git remote rm "${i}"
done


