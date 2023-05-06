#!/bin/bash

# Exit on any error and show execution of all commands for debugging if something goes wrong
set -e

cd "$GITHUB_WORKSPACE"

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

if [[ -z $INCLUDE_REGEX ]]; then
    INCLUDE_REGEX='^.*\.((((c|C)(c|pp|xx|\+\+)?$)|((h|H)h?(pp|xx|\+\+)?$)))$'
fi

# All files improperly formatted will be printed to the output.
MODIFIED_FILE_FILENAMES=$(find . -name .git -prune -o -regextype posix-egrep -regex "$INCLUDE_REGEX" -print)

for FILENAME in $MODIFIED_FILE_FILENAMES; do
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
done

exit $EXIT_VAL
