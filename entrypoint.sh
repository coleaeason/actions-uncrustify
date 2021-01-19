#!/bin/bash

# Exit on any error
set -e

cd "$GITHUB_WORKSPACE"
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
DEFAULT_BRANCH="master"

if [[ -n $INPUT_DEFAULTBRANCH ]]; then
    DEFAULT_BRANCH=$INPUT_DEFAULTBRANCH
fi

RED="\u001b[31m"
GREEN="\u001b[32m"
RESET="\u001b[0m"

# Maintain support for uncrustify's ENV variable if it's passed in 
# from the actions file. Otherwise the actions file could have the
# configPath argument set
if [[ -z $UNCRUSTIFY_CONFIG ]] && [[ -z $INPUT_CONFIGPATH ]]; then
    CONFIG=" -c /default.cfg"
elif [[ -z $UNCRUSTIFY_CONFIG ]] && [[ -n $INPUT_CONFIGPATH ]]; then
    CONFIG=" -c $INPUT_CONFIGPATH"
# If both are set, use the command line flag.
elif [[ -n $UNCRUSTIFY_CONFIG ]] && [[ -n $INPUT_CONFIGPATH ]]; then
    CONFIG=" -c $INPUT_CONFIGPATH"
elif [[ -n $UNCRUSTIFY_CONFIG ]] && [[ -z $INPUT_CONFIGPATH ]]; then
    CONFIG=""
else
    CONFIG=" -c /default.cfg"
fi

EXIT_VAL=0

while read -r FILENAME; do
    TMPFILE="${FILENAME}.tmp"
    # Failure is passed to stderr so we need to redirect that to grep so we can pretty print some useful output instead of the deafult
    # Success is passed to stdout, so we need to redirect that separately so we can capture either case.

    # Allow failures here so we can capture exit status
    set +e
    OUT=$(uncrustify --check${CONFIG} -f ${FILENAME} -l CPP 2>&1 | grep -e ^FAIL -e ^PASS | awk '{ print $2 }'; exit ${PIPESTATUS[0]})
    RETURN_VAL=$?

    # Stop allowing failures again
    set -e 

    if [[ $RETURN_VAL -gt 0 ]]; then
        echo -e "${RED}${OUT} failed style checks.${RESET}"
        uncrustify${CONFIG} -f ${FILENAME} -o ${TMPFILE} && colordiff -u ${FILENAME} ${TMPFILE}
        EXIT_VAL=$RETURN_VAL
    else
        echo -e "${GREEN}${OUT} passed style checks.${RESET}"
    fi
done < <(git diff --name-status --diff-filter=AM origin/${DEFAULT_BRANCH}...${BRANCH_NAME} -- '*.cpp' '*.h' '*.hpp' '*.cxx' | awk '{ print $2 }' )

exit $EXIT_VAL
