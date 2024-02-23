#!/bin/bash

set -ex
# Set GitHub token
TOKEN=$1

# Owner and repository
OWNER="poornima-krishnasamy"
REPO="wordpressapp"
ISSUE_NUMBER=$2

# Fetch issue body
ISSUE_BODY=$(curl -s -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$OWNER/$REPO/issues/$ISSUE_NUMBER" | jq -r .body)

# Regular expression pattern to match issue sections
SECTION_REGEX="##\s*(.*?):(.*?)##\s*|"

# Iterate through each section in the issue body
while [[ $ISSUE_BODY =~ $SECTION_REGEX ]]; do
    # Extract section title and content
    TITLE="${BASH_REMATCH[1]}"
    CONTENT="${BASH_REMATCH[2]}"

    # Trim leading and trailing whitespace
    TITLE="$(echo -e "$TITLE" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    CONTENT="$(echo -e "$CONTENT" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    # Skip empty sections
    if [[ -z $TITLE || -z $CONTENT ]]; then
        continue
    fi

    # Create the issue

    GITHUB_ISSUES=$(gh issue list --repo ministryofjustice/cloud-platform --state all --search "in:title \"$TITLE\"" --limit 50 --json title | jq -r "[ .[] | select(.title == \"$TITLE\") ] | length")

    # if no issues yet, create one
    if (( $(echo "0 == $GITHUB_ISSUES" | bc -l) )); then
      echo "No issue found for $TITLE, creating one..."
      gh issue create --title "$TITLE" --body "$BODY" --repo ministryofjustice/cloud-platform
    else
      echo "Issue already exists for $TITLE, skipping..."
    fi

    # RESPONSE=$(curl -s -X POST \
    #     -H "Authorization: token $TOKEN" \
    #     -H "Accept: application/vnd.github.v3+json" \
    #     -d "{\"title\":\"$TITLE\",\"body\":\"$CONTENT\"}" \
    #     "https://api.github.com/repos/$OWNER/$REPO/issues")

    # # Check if issue creation was successful
    # if [[ $(echo "$RESPONSE" | jq -r .id) ]]; then
    #     echo "Issue '$TITLE' created successfully"
    # else
    #     echo "Error creating issue '$TITLE': $(echo "$RESPONSE" | jq -r .message)"
    # fi

    # Remove processed section from issue body
    ISSUE_BODY=${ISSUE_BODY#*"${BASH_REMATCH[0]}"}
done
