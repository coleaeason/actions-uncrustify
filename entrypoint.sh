#!/bin/bash
set -e

cd "$GITHUB_WORKSPACE"
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

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

echo $INPUT_CHECKSTD
echo $INPUT_CONFIGPATH
echo $CONFIG

EXIT_VAL=0

while read -r FILENAME; do
    RETURN_VAL=$(uncrustify --check "$CONFIG" -f "$FILENAME" -l CPP)
    if [[ "$RETURN_VAL" -gt "$EXIT_VAL" ]]; then
        EXIT_VAL=$RETURN_VAL
    fi

    if [[ -n "$INPUT_CHECKSTD" ]] && [[ "$INPUT_CHECKSTD" == "true" ]]; then
        # Counts occurrences of std:: that aren't in comments and have a leading space (except if it's inside pointer brackets, eg: <std::thing>)
        RETURN_VAL=$(sed -n '/^.*\/\/.*/!s/ std:://p; /^.* std::.*\/\//s/ std:://p; /^.*\<.*std::.*\>/s/std:://p;' "$FILENAME" | wc -l)
        if [[ "$RETURN_VAL" -gt "$EXIT_VAL" ]]; then
            EXIT_VAL=$RETURN_VAL
        fi
    fi
done < <(git diff --name-status --diff-filter=AM origin/master..."$BRANCH_NAME" -- '*.cpp' '*.h' '*.hpp' '*.cxx' | awk '{ print $2 }' )

if [[ "$EXIT_VAL" -gt 0 ]]; then
    echo "Style is wrong, run 'vssh ./style.sh' from your Mac, or just './style.sh' from your VM to fix it."
fi

exit "$EXIT_VAL"
