#!/usr/bin/env bash
#############################################################################
# Relesase script for TheSyDeKick thesdk_template
# USE WITH EXTREME CAUTION
# Intended operation: This does the release. It.
#    Goes through the submodules
#
#    Checks if the given releacce candidate branch exists and pulls it
#
#    For each of the submodules where the release_candidate branch exists, 
#    it merges it to given target and commits the changes.
#
#    For EVERY submodule, it provides a new release tag
#
#    Adds every submodule and commits them
#
#    Pushes results to release candidate branch of the master project.
# Written by Marko Kosunen, marko.kosunen@aalto.fi, 18.9.2022
#############################################################################

help_f()
{
cat << EOF    
test_and_release Release 1.0 (18.09.2022)
For testing and releasing TheSyDeKick releases
Written by Marko Pikkis Kosunen

SYNOPSIS
  test_and_release.sh [OPTIONS]
DESCRIPTION

   Intended operation: 
      This script does the release:  

      1) Goes through the submodules
  
      2) Checks if the given release candidate branch exists and pulls it
  
      3) For each of the submodules where the release_candidate branch exists, 
      it merges it to given target and commits the changes.
  
      4) For EVERY submodule, it provides a new release tag
  
      5) Adds every submodule and commits them
  
      6) Pushes results to release candidate branch of the master project.

OPTIONS
  -b 
     Release candidate branch to release

  -t
     STRING : Tag of the release

  -T 
     STRING: Target branch of the release

  -h
      Show this help.
EOF
}


WORKDIR="$(pwd)"
RC_BRANCH=""
TARGET=""
TAG=""
ANS=""
while getopts b:t:T:h opt
do
  case "$opt" in
    b) RC_BRANCH="$OPTARG";;
    t) TAG="$OPTARG";;
    T) TARGET="$OPTARG";;
    h) help_f; exit 0;;
    \?) help_f;;
  esac
done
if [ ! -d "./Entities" ]; then
    echo "This script should be called in TheSyDeKick project root."
    echo " You re in ${WORKDIR}"
    exit 1
fi

if [ -z "${RC_BRANCH}" ]; then
    echo "Branch not given"
    exit 1
fi

if [ -z "${TAG}" ]; then
    echo "TAG not given"
    exit 1
fi

if [ -z "${TARGET}" ]; then
    echo "Target not given"
    exit 1
fi


# Execute the submodule initialization as in normal workflow
./configure
${WORKDIR}/init_submodules.sh

# Most likely these are already installed
#./pip3userinstall.sh

# Go through all submodule in .gitmodules and pick those that have the given release candidate branch.
SUBMODULES="$(sed -n '/\[submodule/p' .gitmodules | sed -n 's/.* \"\(.*\)\"]/\1/p' | xargs)"
UNDERDEVEL=""
for entity in ${SUBMODULES}; do 
    echo "In $entity:"
    cd ${WORKDIR}/${entity} 
    CURRENT="$(git rev-parse HEAD)"
    git checkout ${RC_BRANCH} 2> /dev/null
    if [ "$?" == "0" ]; then
        git pull
        UPDATED="$(git rev-parse HEAD)"
        UNDERDEVEL="${UNDERDEVEL} ${entity}"
    else
        echo "Branch ${RC_BRANCH} does not exist for submodule ${entity}. No changes made."
    fi
    cd ${WORKDIR}
done

# Merge release candidates
cat << EOF
I will now go through the following entities and merge branch ${RC_BRANCH} to branch ${TARGET}
$( for entity in ${UNDERDEVEL}; do
echo ${entity}
done)
EOF
read -p "Is this what you want [y|n]" ANS
if [ ${ANS} != "y" ]; then
    echo "Aborting"
    exit 1
fi

for entity in ${UNDERDEVEL}; do 
    echo "In $entity:"
    cd ${WORKDIR}/${entity} 
    echo "Check out ${TARGET}"
    git checkout ${TARGET} 2> /dev/null
    git pull origin ${TARGET}
    if [ "$?" == "0" ]; then
        echo "Fetching and merging ${RC_BRANCH} to ${TARGET}"
        git fetch origin ${RC_BRANCH} \
            && git merge --no-commit FETCH_HEAD || $(echo "Merge failed in $entity" && exit 1)
        read -p "Commit [y|n]" ANS
        if [ ${ANS} == "y" ]; then
            git commit --allow-empty -m"Merged ${RC_BRANCH} for release ${TAG}"
        fi

    else
        echo "Checkout failed in ${entity}"
        exit 1
    fi
    cd ${WORKDIR}
done

# Tag
cat << EOF
I will now go through the following entities and add tag ${TAG} to current commit of ${TARGET}.
$( for entity in ${SUBMODULES}; do
echo ${entity}
done)
EOF
read -p "Is this what you want [y|n]" ANS
if [ ${ANS} != "y" ]; then
    echo "Aborting"
    exit 1
fi

for entity in ${SUBMODULES}; do 
    echo "In $entity:"
    cd ${WORKDIR}/${entity} 
    echo "Check out ${TARGET}"
    git checkout ${TARGET} 2> /dev/null
    if [ "$?" == "0" ]; then
        read -p "Tag [y|n]" ANS
        if [ ${ANS} == "y" ]; then
            git tag -a ${TAG} -m"Release ${TAG}"
        fi
    else
        echo "Failed in ${entity}"
        exit 1
    fi
    cd ${WORKDIR}
done

# Push tags
cat << EOF
I will now go through the following entities and push the branch ${TARGET}
and tag ${TAG} to origin.

$( for entity in ${SUBMODULES}; do
echo ${entity}
done)
EOF

read -p "Is this what you want [y|n]" ANS
if [ ${ANS} != "y" ]; then
    echo "Aborting"
    exit 1
fi

for entity in ${SUBMODULES}; do 
    echo "In $entity:"
    cd ${WORKDIR}/${entity} 
    echo "Check out ${TARGET}"
    git checkout ${TARGET} 2> /dev/null
    if [ "$?" == "0" ]; then
        read -p "Push [y|n]" ANS
        if [ ${ANS} == "y" ]; then
            echo "Pushing"
            git push origin ${TARGET} && git push --tags
        fi
    else
        echo "Checkout failed in ${entity}"
        exit 1
    fi
    cd ${WORKDIR}
done

# Delete release candidate branches
cat << EOF
I will now go through the following entities and delete the branch ${RC_BRANCH} from the origin.

$( for entity in ${SUBMODULES}; do
echo ${entity}
done)
EOF

read -p "Is this what you want [y|n]" ANS
if [ ${ANS} != "y" ]; then
    echo "Aborting"
    exit 1
fi

for entity in ${SUBMODULES}; do 
    echo "In $entity:"
    cd ${WORKDIR}/${entity} 
    echo "Check out ${TARGET}"
    git checkout ${TARGET} 2> /dev/null
    if [ "$?" == "0" ]; then
        read -p "Delete branch ${RC_BRANCH} from remote [y|n]" ANS
        if [ ${ANS} == "y" ]; then
            echo "Deleting ${RC_BRANCH} from remote"
            git push --delete origin ${RC_BRANCH}
        else
            echo "Not deleting"
        fi
    else
        echo "Checkout failed in ${entity}"
        exit 1
    fi
    cd ${WORKDIR}
done

# Git adds at the toplevel
cat << EOF
I will now go through the following entities and add them to current branch.

$( for entity in ${SUBMODULES}; do
echo ${entity}
done)
EOF

for entity in ${SUBMODULES}; do 
    echo "Adding $entity:"
    git add ${entity} 
done

cd ${WORKDIR}
echo "Committing changes"
read -p "Is this what you want [y|n]" ANS
if [ ${ANS} != "y" ]; then
    echo "Aborting"
    exit 1
fi

git commit --allow-empty -m"Submodules released from ${RC_BRANCH} to ${TARGET} with ${TAG}"

echo "Release performed, you still need to merge the the master project"
exit 0

