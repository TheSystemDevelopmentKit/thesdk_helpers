#Collection of helper scripts for TheSDK

## Shell directory id for unix shell scripts
###Example of entity\_to\_submodule.sh

ENTITY="f2\_decimator"
SOURCEREPO="git@bwrcrepo.eecs.berkeley.edu:fader2/fader2\_TheSDK.git"
TARGETREMOTE="git@bwrcrepo.eecs.berkeley.edu:dsp-blocks/thesdk-entities/${ENTITY}.git"
SOURCEBRANCH="fader2\_2019"
./thesdk\_helpers/shell/entity\_to\_submodule.sh -e "$ENTITY" -r "$SOURCEREPO" -R "$TARGETREMOTE" -s "$SOURCEBRANCH"

## thesdk\_helpers directory is for python modules


