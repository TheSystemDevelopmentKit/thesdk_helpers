#!/usr/bin/env bash

WORKDIR="$(pwd)"
BRANCH="v1.9_RC"
TARGET='master'
TAG="v1.9"

# Normal workflow
./configure
# change ssh submodule urls to git
if [ "$CICD" == "1" ]; then
    sed -i 's#\(url = \)\(git@\)\(.*\)\(:\)\(.*$\)#\1https://\3/\5#g' .gitmodules
fi
#Init the submodules as user would
#Currently fails on ssh cloned subsubmodules
${WORKDIR}/init_submodules.sh

# Test the dependency installation
# These are already in the buildimage
#./pip3userinstall.sh

SUBMODULES="$(sed -n '/\[submodule/p' .gitmodules | sed -n 's/.* \"\(.*\)\"]/\1/p' | xargs)"
UNDERDEVEL=""
for entity in ${SUBMODULES}; do 
    echo "In $entity:"
    cd ${WORKDIR}/${entity} 
    CURRENT="$(git rev-parse HEAD)"
    git checkout ${BRANCH} 2> /dev/null
    if [ "$?" == "0" ]; then
        git pull
        UPDATED="$(git rev-parse HEAD)"
        if [ "${UPDATED}" != "${CURRENT}" ]; then 
            UNDERDEVEL="${UNDERDEVEL} ${entity}"
        fi
    else
        echo "Branch ${BRANCH} does not exist for submodule ${entity}. No changes made."
    fi
    cd ${WORKDIR}
done

for entity in ${SUBMODULES}; do 
    echo "In $entity:"
    cd ${WORKDIR}/${entity} 
    git checkout ${TARGET} 2> /dev/null
    if [ "$?" == "0" ]; then
        git fetch origin ${BRANCH} \
            && git merge --no-commit FETCH_HEAD || $(echo "Merge failed in $entity" && exit 1)
        git commit -m"Merged ${BRANCH} for release ${TARGET}"
    else
        echo "Checkout failed in ${entity}"
        exit 1
    fi
    cd ${WORKDIR}
done



