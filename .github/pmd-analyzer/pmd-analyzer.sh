# shellcheck shell=sh
echo "#### starting the PMD Check file..."
echo '::echo::on'

# Check whether to use latest version of PMD
LATEST_TAG="$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/pmd/pmd/releases/latest | jq --raw-output '.tag_name')"
PMD_VERSION="${LATEST_TAG#"pmd_releases/"}"

# Download PMD
wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F"${PMD_VERSION}"/pmd-bin-"${PMD_VERSION}".zip
unzip pmd-bin-"${PMD_VERSION}".zip

# Now either run the full analysis or files changed based on the settings defined
if [ "$ANALYSE_ALL_CODE" == 'true' ]; then
    echo "#### Analyzing all code..."
    pmd-bin-"${PMD_VERSION}"/bin/run.sh pmd -d "$FILE_PATH" -R "$RULES_PATH" --fail-on-violation false -f csv > pmd-raw-output.csv
else
    echo "#### Analyzing part of the code..."
    if [ "$ACTION_EVENT_NAME" == 'pull_request' ]; then
        # Now to determine whether to get the files changed from a git diff or using the files changed in a GitHub Pull Request
        # Both options will generate a CSV file first with the files changed
        if [ "$FILE_DIFF_TYPE" == 'git' ]; then
            git diff --name-only --diff-filter=d origin/"$CURRENT_CODE"..origin/"${CHANGED_CODE#"refs/heads/"}" | paste -s -d "," >> diff-file.csv
        else
            curl -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${AUTH_TOKEN}" https://api.github.com/repos/"$REPO_NAME"/pulls/"$PR_NUMBER"/files | jq --raw-output '.[] .filename' | paste -s -d "," >> diff-file.csv
        fi
    else
        # We  always do a git diff
        git diff --name-only --diff-filter=d "$CURRENT_CODE".."$CHANGED_CODE" | paste -s -d "," >> diff-file.csv
    fi

    # Run the analysis
    pmd-bin-"${PMD_VERSION}"/bin/run.sh pmd --file-list diff-file.csv -R "$RULES_PATH" --fail-on-violation false -f csv > pmd-raw-output.csv
fi


# Loop through each rule and see if an error should be thrown
echo "#### Reviewing the results"
echo "::set-output name=errors-found::false"

# Counting the errors
priority2=0
priority3=0
priority4=0
priority5=0

# Column info:
# "Problem","Package","File","Priority","Line","Description","Rule set","Rule"
while IFS="," read -r Problem_col Package_col File_col Priority_col Line_col Description_col Rule_Set_col Rule_col
do
    echo "Problem: $Problem_col"
    echo "Package: $Package_col"
    echo "File: $File_col"
    echo "Priority: $Priority_col"
    echo "Line: $Line_col"
    echo "Description: $Description_col"
    echo "Rule Set: $Rule_Set_col"
    echo "Rule: $Rule_col"

    # Priority 1 causes errors
    if [ "$Priority_col" == '"1"' ]; then
        echo "#### Priority 1 error found"
        echo "::error file="$File_col",line="$Line_col",title="$Rule_col"::"$Description_col""
        echo "#### Priority 1 errors fail the job"
        echo "::set-output name=errors-found::true"
        exit 1
    fi

    # Priority 2 causes warnings
    if [ "$Priority_col" == '"2"' ]; then
        echo "#### Priority 2 warning found"
        echo "::warning file="$File_col",line="$Line_col",title="$Rule_col"::"$Description_col""
        echo "::set-output name=errors-found::true"
        let "priority2++"
        echo "$priority2 priority 2 errors total"
    fi

    # Priority 3 causes warnings
    if [ "$Priority_col" == '"3"' ]; then
        echo "#### Priority 3 warning found"
        echo "::warning file="$File_col",line="$Line_col",title="$Rule_col"::"$Description_col""
        echo "::set-output name=errors-found::true"
        let "priority3++"
        echo "$priority3 priority 2 errors total"
    fi

    # Priority 4 causes notification only
    if [ "$Priority_col" == '"4"' ]; then
        echo "#### Priority 4 notice found"
        echo "::notice file="$File_col",line="$Line_col",title="$Rule_col"::"$Description_col""
        echo "::set-output name=errors-found::true"
        let "priority4++"
        echo "$priority4 priority 2 errors total"
    fi

    # Priority 5 causes notification only
    if [ "$Priority_col" == '"5"' ]; then
        echo "#### Priority 5 notice found"
        echo "::notice file="$File_col",line="$Line_col",title="$Rule_col"::"$Description_col""
        echo "::set-output name=errors-found::true"
        let "priority5++"
        echo "$priority5 priority 2 errors total"
    fi

    # extra space to separate the results
    echo ""

done <<< "$(cat pmd-raw-output.csv)"

# If the action requested a comment, then set the outputs
if [ "$POST_COMMENT" == 'true' ]; then
    warnings=$(( $priority2 + $priority3 ))
    notifications=$(( $priority4 + $priority5 ))
    NEWLINE=$'\n'

    message="$warnings PMD Warnings and $notifications PMD Notifications: "

    echo "Total Warnings and Notifications"
    echo "::set-output name=error-detail::$message"
    echo "::set-output name=error-priority-2::$priority2"
    echo "::set-output name=error-priority-3::$priority3"
fi

# Set the correct file location for the report
cat pmd-raw-output.csv > pmd-file-locations-output.csv