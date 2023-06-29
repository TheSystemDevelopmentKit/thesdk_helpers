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
 INITENTITY Release 1.2 (16.01.2020)
 Templete generator for TheSDK entities
 Written by Marko Pikkis Kosunen

 SYNOPSIS
   initentity [OPTIONS] [ENTITY]
 DESCRIPTION
   Produces template directory structure for a Entity

 OPTIONS
   -i  
       Create the entity using inverter entity as a template
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
INVERTER="0"
while getopts hi opt
do
  case "$opt" in
    i) INVERTER="1";;
    h) help_f; exit 0;;
    \?) help_f; exit 0;;
  esac
  shift
done

#The name of the entity
NAME=$1
FNAME=`basename "$NAME"`
if [ "${INVERTER}" == "1" ]; then
    TEMPLATEREMOTE="git@github.com:TheSystemDevelopmentKit/inverter.git"
    if [ ! -d "$NAME" ]; then
        git clone ${TEMPLATEREMOTE} ${NAME} \
        && cd ${NAME} \
        && git mv ./inverter ${NAME}
        STATUS=$?
        # Old cleanups of matlab directories
        if [ -d "./@inverter" ]; then
            git rm -r ./@inverter
            rm -rf ./@inverter
        fi
        if [ ${STATUS} == "0" ]; then
            git mv ./sv/inverter.sv ./sv/${NAME}.sv  \
                && git mv ./vhdl/inverter.vhd ./vhdl/${NAME}.vhd \
                && git mv ./spice/inverter.cir ./spice/${NAME}.cir  \
                && git remote remove origin \
                && git remote add origin git@github.com:TheSDK-blocks/${NAME}.git

            for file in $(grep -rn inverter * | awk -F : '{print $1}' | uniq | xargs); do
                sed -i "s/inverter/${NAME}/g" ${file}
                sed -i "s/Inverter/${NAME}/g" ${file}
                git add  ${file}
            done
            git commit -m"Renamed inverter to ${NAME} and relocated origin to git@github.com:TheSDK-blocks/${NAME}.git"
        else
            echo "Initialization failed!"
            exit 1
        fi
    else
        echo "Entity exists!!"
        exit 0
    fi

else
    TEMPLATEREMOTE="git@github.com:TheSystemDevelopmentKit/tutorial_entity.git"
    if [ ! -d "$NAME" ]; then
        git clone ${TEMPLATEREMOTE} ${NAME} \
        && cd ${NAME} \
        && git mv ./myentity ${NAME} \
        && git mv ./sv/myentity.sv ./sv/${NAME}.sv \
        && git mv ./vhdl/myentity.vhd ./vhdl/${NAME}.vhd \
        && git mv ./spice/myentity.cir ./spice/${NAME}.cir  \
        && git remote remove origin \
        && git remote add origin git@github.com:TheSDK-blocks/${NAME}.git
        STATUS=$?

        if [ ${STATUS} == "0" ]; then
            for file in $(grep -rn myentity * | awk -F : '{print $1}' | uniq | xargs); do
                sed -i "s/myentity/${NAME}/g" ${file}
                sed -i "s/My Entity/${NAME}/g" ${file}
                git add  ${file}
            done
            git commit -m"Renamed myentity to ${NAME} and relocated origin to git@github.com:TheSDK-blocks/${NAME}.git"
        else
            echo "Initialization failed!"
            exit 1
        fi
    else
        echo "Entity exists!!"
        exit 0
    fi
fi

exit 0

