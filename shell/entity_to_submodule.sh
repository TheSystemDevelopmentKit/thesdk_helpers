#!/bin/sh
# Extract files from existing Entity and push them to git submodule
# Optionally push the module
#
# Initially written by Marko Kosunen, marko.kosunen@aalto.fi, 19.12.2018

help_f()
{
cat << EOF
 entity_to_submodule  Release 1.0 (19.18.2018)
 Filter given Entity files new git project
 Written by Marko Pikkis Kosunen

 SYNOPSIS
   entity_to_submodule [OPTIONS]
 DESCRIPTION
   Filter given files to a new git branch

 OPTIONS

   -e
       Entity [string]: The name of the Entity directory to create.

   -P  Push. Default: do not push.

   -r
       Source TheSDK git repository URL in https or in ssh format

   -R
       Remote git TheSDK repository URL in https or in ssh format

   -s
       Source branch to filter from. Default: master

   -t
       Target branch. Default: master

   -w
       Working directory, Default: pwd

   -h
       Show this help.
EOF

}

SCRIPTPATH=$(cd `dirname $0` && pwd )

ENTITY=""
SOURCEREPO=""
TARGETREMOTE=""

PUSHING="0"
SOURCEBRANCH="master"
TARGETBRANCH="master"
WD=$(pwd)

CURRENTDIR=$(pwd)

while getopts e:p:Pr:R:s:t:w:h opt
do
  case "$opt" in
    e) ENTITY="${OPTARG}";;
    P) PUSHING="1";;
    r) SOURCEREPO="${OPTARG}";;
    R) TARGETREMOTE="${OPTARG}";;
    s) SOURCEBRANCH="${OPTARG}";;
    t) TARGETBRANCH="${OPTARG}";;
    w) WD="${OPTARG}";;
    h) help_f; exit 0;;
    \?) help_f; exit 0;;
  esac
done

if [ -z "$ENTITY" ]; then
    echo "Entity name not given"
    help_f
    exit 1
fi

if [ -z "$SOURCEREPO" ]; then
    echo "TheSDK Source repository not given"
    help_f
    exit 1
fi

if [ -z "$TARGETREMOTE" ]; then
    echo "Target remote repository not given"
    help_f
    exit 1
fi

if [ -d "${WD}/${ENTITY}" ]; then
    echo "Directory ${WD}/${ENTITY} exists, remove it first"
fi

cd $WD
git clone ${SOURCEREPO} ./${ENTITY}
cd ./${ENTITY}

git checkout "$SOURCEBRANCH"
git pull origin "$SOURCEBRANCH"

if [ ! -d "./Entities/${ENTITY}" ]; then
        echo "No Entities/${ENTITY} directory present -- Aborting"
        exit 1
    else
    git filter-branch --subdirectory-filter --prune-empty "Entities/${ENTITY}"
fi

git remote rm origin
git remote add origin "${TARGETREMOTE}"
if [ ! "${SOURCEBRANCH}" == "${TARGETBRANCH}" ]; then
    git branch -D ${TARGETBRANCH}
    git branch  ${TARGETBRANCH}
    git checkout ${TARGETBRANCH}
    git branch -D ${SOURCEBRANCH}
fi

git commit -m"Publish Entity as git module ${ENTITY}"

if [ "$PUSH" == "1" ]; then
    echo "Pushing to ${TARGETREMOTE}, branch ${TARGETBRANCH}"
    git push origin --set-upstream ${TARGETBRANCH}
    cd ${CURRENTDIR}
else
    cat << EOF

Everything set up for you to push.
If satisfied with the result, run

cd ${WD}/${ENTITY} && git push origin --set-upstream ${TARGETBRANCH}

Or re-run with option -P

EOF

cd ${CURRENTDIR}
fi

exit 0

