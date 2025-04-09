#!/bin/bash

# AWS AMI Creation Script
# Description: Creates an AMI from a running EC2 instance with tags
# Usage: ./create-ami.sh INSTANCE_ID AMI_NAME [DESCRIPTION] [NO_REBOOT]

set -euo pipefail

# Check for required arguments $# number of arguments
if [ $# -lt 2 ]; then
  echo "Usage: $0 INSTANCE_ID AMI_NAME [DESCRIPTION] [NO_REBOOT=true/false]"
  exit 1
fi

INSTANCE_ID=$1
AMI_NAME=$2
DESCRIPTION=${3:-"AMI created from instance $INSTANCE_ID"}
NO_REBOOT=${4:-"false"}

# Validate NO_REBOOT is true/false
if [[ "$NO_REBOOT" != "true" && "$NO_REBOOT" != "false" ]]; then
  echo "NO_REBOOT must be 'true' or 'false'"
  exit 1
fi

# AWS CLI check
# command -v aws: Checks if the aws command exists.
# &> /dev/null: Redirects both standard output and standard error to null,
#  effectively silencing any output.
if ! command -v aws &> /dev/null; then
  echo "AWS CLI not found. Please install it first."
  exit 1
#   The `exit 1` command in the script is used to terminate the script with a non-zero exit status, specifically `1`. A non-zero exit status indicates an error or failure. 
fi

# Log function
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Get instance metadata
INSTANCE_NAME=$(aws ec2 describe-tags \
  --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" \
  --query "Tags[0].Value" \
  --output text || echo "unknown")

log "Starting AMI creation for instance: $INSTANCE_ID ($INSTANCE_NAME)"

# Create AMI
AMI_ID=$(aws ec2 create-image \
  --instance-id "$INSTANCE_ID" \
  --name "$AMI_NAME" \
  --description "$DESCRIPTION" \
  --query "ImageId" \
  --output text)

log "AMI creation started with ID: $AMI_ID"
log "Monitoring AMI creation status..."

# Wait for AMI to be available
while true; do
  AMI_STATE=$(aws ec2 describe-images \
    --image-ids "$AMI_ID" \
    --query "Images[0].State" \
    --output text)
  
  case "$AMI_STATE" in
    "pending")
      sleep 30
      ;;
    "available")
      log "AMI $AMI_ID is now available"
      break
      ;;
    *)
      log "Error: AMI creation failed with state $AMI_STATE"
      exit 1
      ;;
  esac
done

# Copy tags from instance to AMI
log "Copying tags from instance to AMI..."
aws ec2 describe-tags \
  --filters "Name=resource-id,Values=$INSTANCE_ID" \
  | jq -r '.Tags[] | "\(.Key)=\(.Value)"' \
  | while read -r TAG; do
      KEY=$(echo "$TAG" | cut -d'=' -f1)
      VALUE=$(echo "$TAG" | cut -d'=' -f2)
      aws ec2 create-tags \
        --resources "$AMI_ID" \
        --tags "Key=$KEY,Value=$VALUE"
    done

log "AMI creation complete!"
echo "AMI ID: $AMI_ID"
echo "Name: $AMI_NAME"
echo "Source Instance: $INSTANCE_ID ($INSTANCE_NAME)"
echo "No Reboot: $NO_REBOOT"