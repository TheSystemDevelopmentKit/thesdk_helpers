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


# Token we use for push is given as the first argument
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

if [ -z "${BRANCH}" ]; then
    echo "Branch not given"
    exit 1
fi

#if [ -z "$TOKEN" ]; then
#    echo "Token must be provided for CI/CD"
#    exit 1
#fi

PID="$$"
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
#If not in CICD, we will make a test clone.
if [ "$CICD" != "1" ]; then
    WORKDIR=$(pwd)
    if [ -z "$(branchtest ${BRANCH})" ]; then
        echo "Branch ${BRANCH} does not exits, creating from the current and checkout"
        git branch ${BRANCH} && git checkout ${BRANCH} || exit 1
    else
        echo "Branch ${BRANCH} exits, check out, update and initialize submodules"
        git checkout "$BRANCH" 
        if [ ! -z "$(branchtest_remote ${BRANCH})" ]; then
            git pull || exit 1
        fi
        ./init_submodules.sh
    fi
else
    echo "CICD currently not supported"
    #git config --global --add safe.directory /__w/thesdk_template/thesdk_template
    #WORKDIR=$(pwd)
fi

# Loop through the submodules
SUBMODULES="$(sed -n '/^SUBMODULES/,/^"/{//!p}' ./init_submodules.sh | xargs)"
UNDERDEVEL=""
for module in $SUBMODULES; do
    echo "Operating on $module"
    cd $module
    if [ -z "$(branchtest ${BRANCH})" ]; then
        echo "Branch ${BRANCH} does not exits, creating from the current and checkout"
        git branch ${BRANCH} && git checkout ${BRANCH} || exit 1
    else
        echo "Branch ${BRANCH} exits, check out and update"
        git checkout "$BRANCH" || exit 1
        if [ ! -z "$(branchtest_remote ${BRANCH})" ]; then
            git pull || exit 1
        else
            echo "Remote branch ${BRANCH} does not exist. Do you wish to push [y|n]"
            read ANS
            if [ "$ANS" == "y" ]; then
                git push -u origin "${BRANCH}"
                ANS=""
                UNDERDEVEL="${UNDERDEVEL} ${module}"
            fi
        fi
    fi
    cd ${WORKDIR}
done

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
    #if [ ${CICD} == "1" ]; then 
    #    git config --global user.name "ecdbot"
    #    git config --global user.email "${GITHUB_ACTOR}@noreply.github.com"
    #    git remote set-url origin "https://x-access-token:${TOKEN}@github.com/TheSystemDevelopmentKit/thesdk_template.git"
    #fi
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

