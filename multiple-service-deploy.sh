#!/bin/bash

# Default values
WAIT_FOR_COMPLETION=false
FAIL_ON_NEW_LEAKS=false

# Parse the input arguments
TEMP=$(getopt -n "$0" -a -l "hostname:,username:,password:,openApiUrl:,gitHubToken:,basePath:,appId:,label:,wait-for-completion:,fail-on-new-leaks:,authenticationUrl1:,authenticationBody1:,authorizationHeaders1:,authenticationUrl2:,authenticationBody2:,authorizationHeaders2:" -- -- "$@")

[ $? -eq 0 ] || exit

eval set -- "$TEMP"

while [ $# -gt 0 ]; do
    case "$1" in
        --hostname) PERFAI_HOSTNAME="$2"; shift ;;
        --username) PERFAI_USERNAME="$2"; shift ;;
        --password) PERFAI_PASSWORD="$2"; shift ;;
        --openApiUrl) OPENAPI_URL="$2"; shift ;;
        --gitHubToken) PAT_TOKEN="$2"; shift ;;
        --basePath) BASE_PATH="$2"; shift ;;
        --appId) APP_ID="$2"; shift ;;
        --label) LABEL="$2"; shift ;;
        --wait-for-completion) WAIT_FOR_COMPLETION="$2"; shift ;;
        --fail-on-new-leaks) FAIL_ON_NEW_LEAKS="$2"; shift ;;
        --authenticationUrl1) AUTH_URL_1="$2"; shift ;;
        --authenticationBody1) AUTH_BODY_1="$2"; shift ;;
        --authorizationHeaders1) AUTH_HEADERS_1="$2"; shift ;;
        --authenticationUrl2) AUTH_URL_2="$2"; shift ;;
        --authenticationBody2) AUTH_BODY_2="$2"; shift ;;
        --authorizationHeaders2) AUTH_HEADERS_2="$2"; shift ;;
        --) shift ;;
    esac
    shift
done

if [ -z "$PERFAI_HOSTNAME" ]; then
    PERFAI_HOSTNAME="https://app.apiprivacy.com"
fi

### Step 1: Get Access Token ###
TOKEN_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/auth/token" \
--header "x-org-id: 6737a7c70ebb315038419eda" \
--header "Content-Type: application/json" \
--data-raw "{
    \"username\": \"${PERFAI_USERNAME}\",
    \"password\": \"${PERFAI_PASSWORD}\"
}")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.id_token')

if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" = "null" ]; then
    echo "Error: Could not retrieve access token"
    exit 1
fi

echo "Access Token retrieved successfully."

# Commit information
COMMIT_ID=${GITHUB_SHA}
COMMIT_DATE=$(date "+%F")
COMMIT_URL="https://github.com/${GITHUB_REPOSITORY}/commit/${COMMIT_ID}"

### Step 2: Schedule API Privacy Tests ###
RUN_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/api-catalog/apps/schedule-run-multiple" \
  -H "x-org-id: 6737a7c70ebb315038419eda" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "{
    \"appId\": \"${APP_ID}\",
    \"services\": [\"PRIVACY\",\"GOVERNANCE\",\"VERSION\",\"SECURITY\",\"RELEASE\",\"CONTRACT\"],
    \"label\": \"${LABEL}\",
    \"openApiUrl\": \"${OPENAPI_URL}\",
    \"basePath\": \"${BASE_PATH}\",
    \"testAccount1\": {
        \"authenticationUrl\": \"${AUTH_URL_1}\",
        \"authenticationBody\": \"${AUTH_BODY_1}\",
        \"authorizationHeaders\": \"${AUTH_HEADERS_1}\"
    },
    \"testAccount2\": {
        \"authenticationUrl\": \"${AUTH_URL_2}\",
        \"authenticationBody\": \"${AUTH_BODY_2}\",
        \"authorizationHeaders\": \"${AUTH_HEADERS_2}\"
    },
    \"buildDetails\": {
        \"commitId\": \"${COMMIT_ID}\",
        \"commitUrl\": \"${COMMIT_URL}\",
        \"commitUsername\": \"${GITHUB_ACTOR}\",
        \"commitDate\": \"${COMMIT_DATE}\",
        \"repoName\": \"${GITHUB_REPOSITORY}\"
    }
  }")

RUN_ID=$(echo "$RUN_RESPONSE" | jq -r '.runId')

if [ -z "$RUN_ID" ] || [ "$RUN_ID" = "null" ]; then
    echo "Failed to schedule API Privacy Tests."
    exit 1
fi

echo "Run ID is: $RUN_ID"

### Step 3: Wait for completion if needed ###
if [ "$WAIT_FOR_COMPLETION" == "false" ]; then
    echo "Waiting for API Privacy Tests to complete..."
    STATUS="PROCESSING"

    while [ "$STATUS" = "PROCESSING" ]; do
        STATUS_RESPONSE=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/api-catalog/apps/all_service_run_status?run_id=$RUN_ID" \
          -H "x-org-id: 6737a7c70ebb315038419eda" \
          -H "Authorization: Bearer $ACCESS_TOKEN")

        if [ -z "$STATUS_RESPONSE" ] || [ "$STATUS_RESPONSE" = "null" ]; then
            echo "Error: Received empty response from API."
            exit 1
        fi

        PRIVACY=$(echo "$STATUS_RESPONSE" | jq -r '.privacy')
        STATUS=$(echo "$PRIVACY" | jq -r '.status')

        # echo "Current Status: $STATUS"

        if [ "$STATUS" = "COMPLETED" ]; then
    echo "Run completed. Checking for issues..."

    NEW_ISSUES=$(echo "$PRIVACY" | jq -r '.newIssues[]?.label')

    # remove this
    echo "NEW_ISSUES: $NEW_ISSUES"
    # remove this
    if [ -n "$NEW_ISSUES" ]; then
        echo "New issues detected. Creating GitHub Issues..."

        for TITLE in $NEW_ISSUES; do
            echo "Creating GitHub Issue: $TITLE"

            ISSUE_BODY="Detected during API privacy testing.\n\nIssue: $TITLE\n\nAuto-created by CI/CD script."

            curl -s -X POST "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues" \
              -H "Authorization: token ${PAT_TOKEN}" \
              -H "Accept: application/vnd.github.v3+json" \
              -d "$(jq -n --arg title "$TITLE" --arg body "$ISSUE_BODY" '{title: $title, body: $body}')" \
              > /dev/null

            echo "Issue created: $TITLE"
        done

    else
        echo "No issues detected. Still creating dummy GitHub issue because it is required."

        TITLE="Dummy Issue Title - No actual issues detected."

        ISSUE_BODY="No issues were found during API privacy testing.\n\nAuto-created by CI/CD script."

        curl -s -X POST "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues" \
          -H "Authorization: token ${PAT_TOKEN}" \
          -H "Accept: application/vnd.github.v3+json" \
          -d "$(jq -n --arg title "$TITLE" --arg body "$ISSUE_BODY" '{title: $title, body: $body}')" \
          > /dev/null

        echo "Dummy Issue created: $TITLE"
    fi

        echo "Finished creating GitHub issues."

        elif [ "$STATUS" = "FAILED" ]; then
            echo "Error: API Privacy run failed."
            exit 1
    fi

    done

    echo "API Privacy Tests completed successfully."
else
    echo "Tests triggered. Not waiting for completion."
fi
