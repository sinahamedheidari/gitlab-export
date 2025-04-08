#!/bin/bash

##Constants
GROUP_ID=GILAB-GROUP-ID
PRIVATE_TOKEN="PRIVATE-TOKEN"
GITLAB_ADDRESS="GITLAB-URL"
PROJECT_LIST_LENGTH=0 #Default
RECORD_PER_PAGE=100 #Default
EXPORT_DIR_PATH="BACKUP-PATH"

## Get Total project count of a group
TOTAL_PROJECT_COUNT=$(curl --silent --head --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "$GITLAB_ADDRESS/api/v4/groups/$GROUP_ID/projects?include_subgroups=true"|grep "X-Total:"|awk '{print $2}'|tr -d '\r')
echo "Total project count: $TOTAL_PROJECT_COUNT"

##Fetch Project List
echo "Feching Project List..."
## PROJECT_LIST Items: ("PATH_WITH_NAMESPACES,PROJECT_ID,WEB_URL")
PROJECT_LIST=()
PAGE_NO=1
while [[ $PROJECT_LIST_LENGTH < $TOTAL_PROJECT_COUNT ]];
do
    PROJECT_LIST+=($(curl --silent --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "$GITLAB_ADDRESS/api/v4/groups/$GROUP_ID/projects?include_subgroups=true&per_page=$RECORD_PER_PAGE&page=$PAGE_NO"|jq '.[]|"\(.path_with_namespace),\(.id),\(.web_url)"'|tr -d '"'))
    PROJECT_LIST_LENGTH="${#PROJECT_LIST[@]}"
    ((PAGE_NO++))
    echo "Fetched $PROJECT_LIST_LENGTH"
    sleep 1
done

##Run export command and download projects
for item in "${PROJECT_LIST[@]}"; do
    # Split the item into separate variables
    IFS=',' read -r P_PATH P_ID P_WEB_URL <<< "$item"

    # Send export request
    curl --silent --request POST "$GITLAB_ADDRESS/api/v4/projects/$P_ID/export" --header "PRIVATE-TOKEN: $PRIVATE_TOKEN"
    echo ""

    # Check wheteher export is finished or not
    EXPORT_STATUS=""
    while [[ "$EXPORT_STATUS" != 'finished' ]];
    do
        EXPORT_STATUS=$(curl --silent --request GET "$GITLAB_ADDRESS/api/v4/projects/$P_ID/export" --header "PRIVATE-TOKEN: $PRIVATE_TOKEN"|jq .export_status|tr -d '\r'|tr -d '"')
        echo $EXPORT_STATUS
        sleep 1
    done

    # Download export
    echo $P_ID
    EXPORT_FILE_NAME="${P_PATH//\//_}"
    curl --request GET "$GITLAB_ADDRESS/api/v4/projects/$P_ID/export/download" --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" -o $EXPORT_DIR_PATH/$EXPORT_FILE_NAME.tar.gz
    # curl --remote-name --remote-header-name --request GET "$GITLAB_ADDRESS/api/v4/projects/$P_ID/export/download" --header "PRIVATE-TOKEN: $PRIVATE_TOKEN"
    sleep 30

done