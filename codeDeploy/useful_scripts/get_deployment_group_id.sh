#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Usage: $0 <app-name>"
  echo "Please provide the name of the app name."
  exit 1
fi
if [ -z "$2" ]; then
  echo "Usage: $0 <deployment-group-name>"
  echo "Please provide the name of the deployment group."
  exit 1
fi

APP_NAME=$1
DEPLOYMENT_GROUP_ID=$2


aws deploy get-deployment-group \
    --application-name $APP_NAME \
    --deployment-group-name $DEPLOYMENT_GROUP_ID \
    --query "deploymentGroupInfo.deploymentGroupId" --output text
