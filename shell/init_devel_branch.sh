#!/usr/bin/env bash
#############################################################################
# Initialize all tracked submodules to the same devel branch as the main
# project if they do not have that devel branch
#
# Written by Marko Kosunen, marko.kosunen@aalto.fi, 20.11.2022
#############################################################################

help_f()
{
cat << EOF
init_devel_branch 1.0 (22.11.2022)
For initialization of TheSyDeKick development branhces
Written by Marko Pikkis Kosunen

SYNOPSIS
  init_devel_branhc.sh [OPTIONS]
DESCRIPTION
   Defines and runs tests for the submodules of thesdk_template

OPTIONS
  -b
     Branch of thesdk_template to create. Defaults to 'master',
     i.e creates master branch for all submodules if it does not exist.

  -c Run in CI/CD with this option. Currently not used

  -t
     STRING : Access token, currently not used
  -h
      Show this help.
EOF
}


WORKDIR=$(pwd)
CICD="0"
TOKEN=""
BRANCH="master"
while getopts b:ct:h opt
do
  case "$opt" in
    b) BRANCH="$OPTARG";;
    c) CICD="0";;
    t) TOKEN="$OPTARG";;
    h) help_f; exit 0;;
    \?) help_f;;
  esac
done
# Functions
function branchtest_local() {
    branch=$1
    # Local branches
    branchtest="$(git branch | sed -n 's/\(^. \)\(.*\)/\2/p' \
        | sed -n "/${branch}/p")"
    echo "$branchtest"
}
function branchtest_remote() {
    branch=$1
    # Remote branches
    branchtest="$(git branch -a \
        | sed -n 's#\(^. \)\(remotes.*/\)#\2#p' \
        | sed 's#remotes/.*/##g' \
        | sed -n "/${branch}/p")"
    echo "$branchtest"
}
function branchtest() {
    brach=$1
    if [ -z "$(branchtest_local ${BRANCH})" ]; then
        echo "$(branchtest_remote ${BRANCH})"
    else
        echo "$(branchtest_local ${BRANCH})"
    fi

}

# Tests
if [ ! -d "./Entities" ]; then
    echo "This script should be called in TheSyDeKick project root."
    echo " You re in ${WORKDIR}"
    exit 1
fi

if [ -z "${BRANCH}" ]; then
    echo "Branch not given"
    exit 1
fi


 # PID of the current shell
PID="$$"
# Handle all teh submodules in a single loop
MODULES="$WORKDIR"
MODULES+=" $(sed -n '/^SUBMODULES/,/^"/{//!p}' ./init_submodules.sh | xargs)"

# Logic: Loop through the modules and create development branches if they do not exist
# Do not push the toplevel, it is handled separately
UNDERDEVEL=""
for module in $MODULES; do
    echo "Operating on $module"
    cd $module
    if [ ! -z "$(branchtest_remote ${BRANCH})" ]; then
        echo "Remote branch ${BRANCH} exits, check out, update and initialize submodules"
        git checkout "$BRANCH"
        git pull || exit 1
        if [ -f "./init_submodules.sh" ]; then
            ./init_submodules.sh
        fi
    elif [ ! -z "$(branchtest_local ${BRANCH})" ]; then
        echo "Local branch ${BRANCH} exits, check out and initialize submodules"
        git checkout "$BRANCH" || exit 1
        if [ -f "./init_submodules.sh" ]; then
            ./init_submodules.sh
        fi
    else
        echo "Branch ${BRANCH} does not exits, create and check out, and initialize submodules"
        git checkout -b "$BRANCH" || exit 1
        if [ -f "./init_submodules.sh" ]; then
            ./init_submodules.sh
        fi
    fi
    # Add and push only submodules to UNDERDEVEL
    if [ "$module" != "${WORKDIR}" ]; then
        if [ ! -z "$(branchtest_remote ${BRANCH})" ]; then
            echo "Remote branch ${BRANCH} exits. Do you wish to push? [y|n]"
            read ANS
            if [ "$ANS" == "y" ]; then
                ANS=""
                git push
                UNDERDEVEL="${UNDERDEVEL} ${module}"
            fi
        else
            echo "Push local branch ${BRANCH} to remote. Is that what you wish? [y|n]"
            read ANS
            if [ "$ANS" == "y" ]; then
                ANS=""
                git push -u origin ${BRANCH}
                UNDERDEVEL="${UNDERDEVEL} ${module}"
            fi
        fi
    fi
    cd ${WORKDIR}
done

# Stage changes at the toplevel
if [ ! -z "${UNDERDEVEL}" ]; then
    cd ${WORKDIR}
    for entity in ${UNDERDEVEL}; do
        echo "Staging $entity"
        git add "${entity}"
    done

    echo "Committing changes"
    MSG=""
    COMMITMESSAGE="$(
    cat << EOF
Initializing development branch ${BRANCH} for

$(for entity in ${UNDERDEVEL}; do
    echo $entity
done)
EOF
)"
    echo "$COMMITMESSAGE"
    echo "Do you wish to commit? [y|n]"
    read ANS
    if [ "$ANS" == "y" ]; then
        git commit -m"$COMMITMESSAGE"
        ANS=""
        echo "Do you wish to push? [y|n]"
        read ANS
        if [ "$ANS" == "y" ]; then
            ANS=""
            if [ ! -z "$(branchtest_remote ${BRANCH})" ]; then
                git push
            else
                git push -u origin "${BRANCH}"
            fi
        fi
    fi
else
    echo "Development branches for all sumodules exist already."
fi
exit 0

