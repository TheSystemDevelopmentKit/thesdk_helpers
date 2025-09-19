#!/usr/bin/env bash
#############################################################################
# This is the script to install TheSyDeKick dependencies for the user
#
# Created by Marko Kosunen, 2017
#############################################################################
##Function to display help with -h argument and to control
##The configuration from the command line
help_f()
{
cat << EOF
 PIP3USERINSTALL Release 1.0 (16.01.2020)
 TheSyDeKick dependency installer
 Written by Marko Pikkis Kosunen

 SYNOPSIS
   pip3userinstall.sh [OPTIONS]
 DESCRIPTION
   Installs required Python packages locally to users ~/.local
 OPTIONS
   -u
       Upgrade also the existing packages.
       Default: just install the missing ones.
   -V  Do system wide installation. Works also in virtual environment.
   -h
       Show this help.
EOF
}
THISDIR="$(cd $(dirname $0) && pwd)"
PIP="pip3 install"
VENV="0"
UPGRADE=""
while getopts uhV opt
do
  case "$opt" in
    u) UPGRADE="--upgrade";;
    h) help_f; exit 0;;
    \?) help_f; exit 0;;
  esac
  shift
done

if [ ! -z ${VIRTUAL_ENV+x} ]; then
   $PIP $UPGRADE -r ${THISDIR}/requirements.txt  || exit 1
else
   $PIP $UPGRADE --user -r ${THISDIR}/requirements.txt || exit 1
fi

exit 0

