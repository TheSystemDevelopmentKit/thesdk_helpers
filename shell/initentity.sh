#!/bin/sh
#############################################################################
# This is a templete generator for TheSDK entities. 
# It will genarate a template directory structure for a Entity
# including functional buffer models for matlab and python
# 
# Created by Marko Kosunen on 01.09.2017
#############################################################################
##Function to display help with -h argument and to control 
##The configuration from the command line
help_f()
{
cat << EOF
 INITENTITY Release 1.1 (06.09.2018)
 Templete generator for TheSDK entities
 Written by Marko Pikkis Kosunen

 SYNOPSIS
   initentity [OPTIONS] [ENTITY]
 DESCRIPTION
   Produces template directory structure for a Entity

 OPTIONS
   -h
       Show this help.
EOF
}

gitadd()
{
    CFILE=$1
    GA=$2
    if [ "${GA}" == "1" ]; then
        echo "Adding ${CFILE} to git"    
        git add  ${CFILE}    
    fi
}

GITADD="0"
while getopts h opt
do
  case "$opt" in
    h) help_f; exit 0;;
    \?) help_f; exit 0;;
  esac
  shift
done

#The name of the entity
NAME=$1
FNAME=`basename "$NAME"`
TEMPLATEREMOTE="git@github.com:TheSystemDevelopmentKit/inverter.git"

if [ ! -d "$NAME" ]; then
    git clone ${TEMPLATEREMOTE} ${NAME}
    cd ${NAME}
    git mv ./inverter ${NAME}
    git mv ./@inverter ./@${NAME}
    git mv ./sv/inverter.sv ./sv/${NAME}.sv
    git remote remove origin
    git remote add origin git@github.com:TheSDK-blocks/${NAME}.git

    for file in $(grep -rn inverter * | awk -F : '{print $1}' | uniq | xargs); do
        sed -i "s/inverter/${NAME}/g" ${file}
        git add  ${file}
    done
    git commit -m"Renamed inverter to ${NAME} and relocated origin to git@github.com:TheSDK-blocks/${NAME}.git"

else
    echo "Entity exists!!"
    exit 0
fi

exit 0

