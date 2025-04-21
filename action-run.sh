#!/bin/bash

# Default values
WAIT_FOR_COMPLETION=false
FAIL_ON_NEW_LEAKS=false

# Parse the input arguments
TEMP=$(getopt -n "$0" -a -l "hostname:,username:,password:,openApiUrl:,basePath:,appId:,label:,wait-for-completion:,fail-on-new-leaks:,authenticationUrl1:,authenticationBody1:,authorizationHeaders1:,authenticationUrl2:,authenticationBody2:,authorizationHeaders2:" -- -- "$@")

[ $? -eq 0 ] || exit

eval set -- "$TEMP"

while [ $# -gt 0 ]
do
    case "$1" in
        --hostname) PERFAI_HOSTNAME="$2"; shift;;
        --username) PERFAI_USERNAME="$2"; shift;;
        --password) PERFAI_PASSWORD="$2"; shift;;
        --openApiUrl) OPENAPI_URL="$2"; shift;;
        --basePath) BASE_PATH="$2"; shift;;        
        --appId) APP_ID="$2"; shift;;
        --label) LABEL="$2"; shift;;
        --wait-for-completion) WAIT_FOR_COMPLETION="$2"; shift;;
        --fail-on-new-leaks) FAIL_ON_NEW_LEAKS="$2"; shift;;
        --authenticationUrl1) AUTH_URL_1="$2"; shift;;
        --authenticationBody1) AUTH_BODY_1="$2"; shift;;
        --authorizationHeaders1) AUTH_HEADERS_1="$2"; shift;;
        --authenticationUrl2) AUTH_URL_2="$2"; shift;;
        --authenticationBody2) AUTH_BODY_2="$2"; shift;;
        --authorizationHeaders2) AUTH_HEADERS_2="$2"; shift;;
        --) shift ;;
    esac
    shift;
done

echo " "

if [ "$PERFAI_HOSTNAME" = "" ];
then
PERFAI_HOSTNAME="https://app.apiprivacy.com"
fi

### Step 1: Print Access Token ###
TOKEN_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/auth/token" \
--header "Content-Type: application/json" \
--data-raw "{
    \"username\": \"${PERFAI_USERNAME}\",
    \"password\": \"${PERFAI_PASSWORD}\"
}")

ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.id_token')

if [ -z "$ACCESS_TOKEN" ]; then
    echo "Error: Could not retrieve access token"
    exit 1
fi

echo "Access Token is: $ACCESS_TOKEN"
echo " "

# Get commit information
COMMIT_ID=${GITHUB_SHA}
COMMIT_DATE=$(date "+%F")
COMMIT_URL="https://github.com/${GITHUB_REPOSITORY}/commit/${COMMIT_ID}"
#COMMENT="${{ github.event.head_commit.message }}"  # Fetch commit message

# Print commit information to confirm
# echo "Commit ID: $COMMIT_ID"
# echo "Commit Date: $COMMIT_DATE"
# echo "Commit URL: $COMMIT_URL"
#echo "Commit Message: $COMMENT"

### Step 2: Schedule API Privacy Tests ###
RUN_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/api-catalog/apps/schedule-run-multiple" \
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
        \"repoName\": \"${GITHUB_REPOSITORY}\",
        \"comment\": \"${COMMENT}\"
    }
  }"
)

#echo "Run Response: $RUN_RESPONSE"

### RUN_ID Prints ###
RUN_ID=$(echo "$RUN_RESPONSE" | jq -r '.runId')


# Output Run Response ###
echo " "
echo "Run Response: $RUN_RESPONSE"
echo " "
echo "Run ID is: $RUN_ID"

# Check if RUN_ID is null or empty
if [ -z "$RUN_ID" ] || [ "$RUN_ID" == "null" ]; then
    echo "API Privacy Tests triggered. Run ID: $RUN_ID. Exiting without waiting for completion."
    exit 1
fi

# Check if ACCESS_TOKEN is null or emtpy
if [ "$ACCESS_TOKEN" == "null" ]; then
    echo "Error: Could not retrieve access token"
    exit 1
fi

### Step 3: Check the wait-for-completion flag ###
if [ "$WAIT_FOR_COMPLETION" == "false" ]; then
    echo "Waiting for API Privacy Tests to complete..."

    STATUS="PROCESSING"

    ### Step 4: Poll the status of the AI run until completion ###
    while [[ "$STATUS" == "PROCESSING" ]]; do
        
        # Check the status of the API Privacy Tests
        STATUS_RESPONSE=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/api-catalog/apps/all_service_run_status?run_id=$RUN_ID" \
          --header "Authorization: Bearer $ACCESS_TOKEN")    

      # Handle empty or null STATUS_RESPONSE
        if [ -z "$STATUS_RESPONSE" ] || [ "$STATUS_RESPONSE" == "null" ]; then
            echo "Error: Received empty response from the API."
            exit 1
        fi
       
       # echo $STATUS_RESPONSE
    
        # Extract fields with default values to handle null cas
        PRIVACY=$(echo "$STATUS_RESPONSE" | jq -r '.privacy')
        SECURITY=$(echo "$STATUS_RESPONSE" | jq -r '.security')
        GOVERNANCE=$(echo "$STATUS_RESPONSE" | jq -r '.governance')
        VERSION=$(echo "$STATUS_RESPONSE" | jq -r '.version')
        RELEASE=$(echo "$STATUS_RESPONSE" | jq -r '.release')
        CONTRACT=$(echo "$STATUS_RESPONSE" | jq -r '.contract')
        
        # Set STATUS to "PROCESSING" if PRIVACY status is null or empty
        STATUS=$(echo "$PRIVACY" | jq -r '.status')

        # echo "status: $STATUS"
        # echo " "
        
        # Check if STATUS is completed and handle issues
        if  [ "$STATUS" == "COMPLETED"  ]; then

            NEW_ISSUES=$(echo "$STATUS_RESPONSE" | jq -r '.privacy.newIssues[]')
            NEW_ISSUES_DETECTED=$(echo "$STATUS_RESPONSE" | jq -r '.privacy.newIssuesDetected')
          
            echo " "
            echo "AI Running Status: $STATUS"

            if [ -z "$NEW_ISSUES" ] ||  [ "$NEW_ISSUES" == null ]; then
              echo "No new issues detected. Build passed."
          else
              echo "Build failed with new issues." 
              echo "Complete Privacy Status: $PRIVACY"
              echo "Complete Security Status: $SECURITY"
              echo "Complete Governance Status $GOVERNANCE"
              echo "Complete Version Status: $VERSION"
              echo "Complete Release Status: $RELEASE"
              echo "Complete Contract Status: $CONTRACT"
            exit 1
         fi
    fi 

   # echo "AI Running Status: $STATUS"

    # If the AI run fails, exit with an error
    if [[ "$STATUS" == "FAILED" ]]; then
      echo "Error: API Privacy failed for Run ID $RUN_ID"
      exit 1
    fi
  done
    
    # Once the status is no longer "in_progress", assume it completed
  echo "API Privacy Tests for API ID $APP_ID has completed successfully!"
else
  echo "API Privacy Tests triggered. Run ID: $RUN_ID. Exiting without waiting for completion."
  exit 1  
fi
