#!/usr/bin/env bash
#############################################################################
# This is a documentation initialization script for TheSyDeKick
# Primarily doc initiallization is performed by fooba template.
# This script can be used for entities not having documentaion initiated.
# 
# Created by Marko Kosunen on 19.10.2019
#############################################################################
##Function to display help with -h argument and to control 
##The configuration from the command line
help_f()
{
cat << EOF
 INITDOC Release 1.0 (19.10.2019)
 Documentation initialization for TheSyDeKick entities
 Written by Marko Pikkis Kosunen

 SYNOPSIS
   initentity [OPTIONS] [ENTITY]
 DESCRIPTION
   Produces documentation template directory structure for a Entity.
   

 OPTIONS
   -h
       Show this help.
EOF
}

while getopts h opt
do
  case "$opt" in
    h) help_f; exit 0;;
    \?) help_f; exit 0;;
  esac
  shift
done

#The name of the entity
ENTITYPATH=$1
NAME=$(basename ${ENTITYPATH})
DIR=$(realpath $(dirname ${ENTITYPATH}))

RNDSTR=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n1) 
NAMELEN=$(echo -n ${NAME} | wc -c)
TEMPNAME=${NAME}_${RNDSTR}
TEMPLATEREMOTE="git@github.com:TheSystemDevelopmentKit/inverter.git"

if [ ! -d "$TEMPNAME" ]; then
    git clone ${TEMPLATEREMOTE} ${TEMPNAME}
fi

if [ ! -d "${NAME}/doc" ]; then
    mv ${TEMPNAME}/doc ${DIR}/${NAME}/
    cd ${DIR}/${NAME}/doc
    for file in $(grep -rn inverter * | awk -F : '{print $1}' | uniq | xargs); do
       sed -i "s/inverter/${NAME}/g" ${file}
    done 
else
    echo "Documentation exists"
    exit 0
fi

# Generate Documentation template
cd ${DIR}/${NAME}/${NAME}
TESTSTRING=$(head -n1 __init__.py | grep '"""')

if [ -z ${TESTSTRING} ]; then
    echo "No Docstring. Generating the default."
    mv __init__.py __init__.py.${RNDSTR}
    cat << EOF > __init__.py
"""
$(for i in $(seq 1 ${NAMELEN}); do
    echo -n "="
    done
)
$(tr [:lower:] [:upper:] <<< ${NAME:0:1})${NAME:1}
$(for i in $(seq 1 $NAMELEN); do
    echo -n "="
    done
)
Documentation initialized with thesdk_helpers/shell/initdoc.sh.

Current docstring documentation style is Numpy
https://numpydoc.readthedocs.io/en/latest/format.html

This text here is to remind you that documentation is imortant.
However, you may find it out the even the documentation of this
entity may be outdated and incomplete. Regardless of that, every day
and in every way we are getting better and better :).
 
Created by your_name_here, email, $(date +%Y%m%d).

"""
EOF
    cat __init__.py.${RNDSTR} >> __init__.py
    git add __init__.py
    rm __init__.py.${RNDSTR}
    cd ${DIR}/${NAME}/doc
    FILES="\
    ./Makefile \
    ./source/conf.py \
    ./source/index.rst \
    ./source/_static/.gitignore \
    ./source/_templates/.gitignore \
    "
    # Add documentation to git
    for file in $FILES; do
        git add ${file}
    done
    git commit -m"Initialized documentation"

else
    echo "Docstring already exists."
    exit 0
fi

cat << EOF

To generate HTML documentation:

cd  ${DIR}/${NAME}/doc && make html

Remember to add this in some form to your Entity's Makefile configuration.
EOF


cd ${DIR}/..
rm -rf ${TEMPNAME}

exit 0

