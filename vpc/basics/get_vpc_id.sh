#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# Function to display usage information
usage() {
  echo "Usage: $0 <vpc-name>"
  echo "Example: $0 nacl-examples-vpc"
  exit 1
}

# Check if VPC name argument is provided
if [ -z "$1" ]; then
  echo "Error: VPC NAME not provided."
  usage
fi

# Set the VPC name as an environment variable
export VPC_NAME="$1"

# Get the VPC ID based on the VPC name
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=$VPC_NAME" \
  --query "Vpcs[0].VpcId" \
  --output text)

# Check if VPC ID is empty
if [ -z "$VPC_ID" ]; then
  echo "Error: No VPC found with the name '$VPC_NAME'."
  exit 1
fi

echo "VPC_ID: $VPC_ID"