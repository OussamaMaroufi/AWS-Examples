#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# Function to display usage information
usage() {
  echo "Usage: $0 <region>"
  echo "Example: $0 us-east-1"
  exit 1
}

# Check if region argument is provided
if [ -z "$1" ]; then
  echo "Error: Region not provided."
  usage
fi

# Set the region as an environment variable
export REGION="$1"

# Create a default VPC in the specified region
echo "Creating default VPC in region: $REGION..."
VPC_ID=$(aws ec2 create-default-vpc --output text --query Vpc.VpcId --region "$REGION" || {
  echo "Error: Failed to create default VPC in region $REGION."
  exit 1
})

# Check if VPC creation was successful
if [ -z "$VPC_ID" ]; then
  echo "Error: VPC ID is empty. VPC creation might have failed."
  exit 1
fi

echo "Default VPC created successfully!"
echo "VPC ID: $VPC_ID"

# Wait for the VPC to be fully available
# In AWS, the aws ec2 wait command is used to pause script execution until a specific condition is met.
# This is particularly useful when you need to wait for a resource (like a VPC) to reach a certain state (e.g., available) before proceeding with the next steps in your script.
echo "Waiting for VPC to be available..."
aws ec2 wait vpc-available --vpc-ids "$VPC_ID" --region "$REGION"

# Enable DNS hostnames for the VPC
echo "Enabling DNS hostnames for VPC: $VPC_ID..."
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames "{\"Value\":true}" --region "$REGION" || {
  echo "Error: Failed to enable DNS hostnames for VPC: $VPC_ID."
  exit 1
}

echo "DNS hostnames enabled for VPC: $VPC_ID."

# Output the VPC details
echo "VPC Details:"
aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --region "$REGION" --output table