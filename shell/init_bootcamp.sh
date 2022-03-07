#!/usr/bin/env bash
#############################################################################
# This is a templete generator for TheSyDeKick bootcamp
# Genarates a set of educational Gitlab issues for a person identified by
# username. Bootcamp is executed by closing the issues.
# 
# Created by Marko Kosunen on 01.04.2019
#############################################################################

##Function to display help with -h argument and to control 
##The configuration from the command line
help_f()
{
cat << EOF
 INIT_BOOTCAMP Release 1.0 (1.4.2021)
 Genarates a set of educational Gitlab issues for a person identified by
 username. Bootcamp is executed by closing the issues.

 To use this command you must have the project set up at a GitLab repository for which 
 the bootcamp issues are filed, and management permissions with an access tojen for that 
 project.

 SYNOPSIS
   init_bootcamp [OPTIONS] 
 DESCRIPTION
   Produces template directory structure for a Entity

 OPTIONS
   -i
       List of usernames on which the issues are assigned  
   -p
       Project name
   -u  
       Gitlab server root URL. 
   -t  
       Access token to GitLab "STRING"
   -h
       Show this help.
Example:
./init_bootcamp.sh -u "https://bubba.ecdl.hut.fi:81 -p "cloneof_theSydekicktetemplate" -t "kasdjfhdummytokenakd" -i "dummyuser"
EOF
}
API="api/v4/projects?search="

while getopts i:p:u:t:h opt
do
  case "$opt" in
    i) USERNAMES="${OPTARG}";;
    p) PROJECT="${OPTARG}";;
    u) URL="${OPTARG}";;
    t) TOKEN="${OPTARG}";;
    h) help_f; exit 0;;
    \?) help_f; exit 0;;
  esac
done

PROJECT_ID="$(curl --silent --insecure --request GET \
    --header "PRIVATE-TOKEN:${TOKEN}" \
    "${URL}/${API}${PROJECT}" \
    | sed -n 's/\([\[]{"id":\)\([0-9]*\)\(,.*\)/\2/p')"

get_issueid()
{
echo "$(curl --silent --insecure --request GET \
    --header "PRIVATE-TOKEN:${TOKEN}" \
    "${URL}/api/v4/issues?assignee_username=${UNAME}&in=title" \
    | sed -n 's/\([\[]{"id":\)\([0-9]*\)\(,.*\)/\2/p')"
}

# Functions to create issues
# Warning these use global variables
get_userid()
{
echo "$(curl --silent --insecure --request GET \
    --header "PRIVATE-TOKEN:${TOKEN}" \
    "${URL}/api/v4/users?username=${UNAME}" \
    | sed -n 's/\([\[]{"id":\)\([0-9]*\)\(,.*\)/\2/p')"
}

create_issue()
{
curl --insecure --request POST \
    --header "PRIVATE-TOKEN:${TOKEN}" \
    "${URL}/api/v4/projects/${PROJECT_ID}/issues?title=${TITLE}&description=${DESCRIPTION}&assignee_ids=${ASSIGNEE_IDS}"
}

get_issueid()
{
MATCH="$1"
echo "$(curl --silent --insecure --request GET --header "PRIVATE-TOKEN:${TOKEN}" \
    "${URL}/api/v4/issues?assignee_username=${UNAME}&state=opened&in=title&search=${MATCH}" \
    | sed -n 's/\([{]"id":.[0-9]\)/\n\1/gp' \
    | sed -n "/${MATCH}/p" \
    | sed -n 's/\(^.*"iid":\)\(.[0-9]\)\(.*$\)/\2/p')"
}
# The actual issues

# Preparations
part0()
{
TITLE="$(echo $(
cat << EOF
${UNAME} -  Introduction to TheSyDeKick-Part-0
EOF
) | sed -e 's/\s/%20/g' -e 's/#/%23/g'
)"

DESCRIPTION="$(echo $(
cat << EOF
Go to a proper location in a file system, and create a directory named as your username.

This is your project working directory.
EOF
) | sed -e 's/\s/%20/g' -e 's/#/%23/g'
)"

create_issue

}

# Issue 1
part1()
{
TITLE="$(echo $(
cat << EOF
${UNAME} - Introduction to TheSyDeKick-Part-1 
EOF
) | sed -e 's/\s/%20/g' -e 's/#/%23/g'
)"

DESCRIPTION="$(echo $(
cat << EOF
After closing  #${PREVIID} , go to the working directory and clone this project there. Then go to tutorial presented at https://github.com/TheSystemDevelopmentKit/TheSyDeKick_tutorial/blob/master/pdffiles/TheSyDeKick_tutorial.pdf
EOF
) | sed -e 's/\s/%20/g' -e 's/#/%23/g'
)"

create_issue
}

# Issue 2
part2()
{
TITLE="$(echo $(
cat << EOF
${UNAME} - Introduction to TheSyDeKick-Part-2 
EOF
) | sed -e 's/\s/%20/g' -e 's/#/%23/g'
)"

DESCRIPTION="$(echo $(
cat << EOF
After closing #${PREVIID} , Read through the README.md and try out the inverter simulations with various models. Study the inverter code a bit. That gives some idea how TheSyDeKick supports multiple simulators and the formalism of IO and execution constructs.
EOF
) | sed -e 's/\s/%20/g' -e 's/#/%23/g'
)"

create_issue
}

# Issue 3
part3()
{
TITLE="$(echo $(
cat << EOF
${UNAME} - Introduction to TheSyDeKick-Part-3 
EOF
) | sed -e 's/\s/%20/g' -e 's/#/%23/g'
)"

DESCRIPTION="$(echo $(
cat << EOF
After closing #${PREVIID} , study the structure of Entities/register_template and execute the simulation of it, both in interactive and non-interactive mode. Study also the structure of controller.py

This is the basis of the TheSyDeKick rtl verifications.

EOF
) | sed -e 's/\s/%20/g' -e 's/#/%23/g'
)"

create_issue
}


# Loop to create issues

for UNAME in ${USERNAMES}; do
    ASSIGNEE_IDS="$(get_userid)"
    ISSUESCRIPTS=(part0 part1 part2 part3)
        for index in ${!ISSUESCRIPTS[@]}; do
            TSTSTRING="$(echo "${ISSUESCRIPTS[$index]}" | sed -e 's/part/Part/' -e 's/[0-9]/-&/')"
            CURRID="$(get_issueid "${TSTSTRING}")"
            if [ "${index}" -gt 0 ]; then
               PSTRING="$(echo "${ISSUESCRIPTS[$(($index-1))]}" | sed -e 's/part/Part/' -e 's/[0-9]/-&/')"
               PREVIID="$(get_issueid "${PSTRING}")"
               echo $PREVIID
            fi

        if [ -z "$CURRID" ]; then
            # Title is defined by script
            ${ISSUESCRIPTS[$index]}
            echo "Creating issue ${TITLE}"
        else 
            echo "Open issue for ${TSTSTRING} exists, not creating a new one."
        fi
    done
done

exit 0

