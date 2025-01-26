#!/usr/bin/env bash

# Exit immediately if any command failsy
# AMI are tied to a specific region
# AMIs are stored in Amazon S3 buckets within a specific region, so they are not automatically available across regions
# Exit immediately if any command fails
set -e

# Function to display usage information
usage() {
  echo "Usage: $0 <region>"
  echo "Example: $0 eu-west-3"
  exit 1
}

# Check if region argument is provided
if [ -z "$1" ]; then
  echo "Error: Region not provided."
  usage
fi

# Set the region from the argument
REGION="$1"

# Get the latest Amazon Linux 2 AMI ID
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].ImageId" \
  --region "$REGION" \
  --output text
)

# Check if AMI ID is empty
if [ -z "$AMI_ID" ]; then
  echo "Error: No AMI found for Amazon Linux 2 in region $REGION."
  exit 1
fi

echo "AMI_ID: $AMI_ID"