#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# Function to display usage information
usage() {
  echo "Usage: $0 <region> <bucket_name>"
  echo "Example: $0 us-east-1 my-unique-bucket-name"
  exit 1
}

# Check if both region and bucket name arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Error: Region or bucket name not provided."
  usage
fi

# Assign arguments to variables
REGION="$1"
BUCKET_NAME="$2"

# Validate bucket name (S3 naming rules)
if ! [[ "$BUCKET_NAME" =~ ^[a-z0-9.-]{3,63}$ ]]; then
  echo "Error: Invalid bucket name. Bucket names must be 3-63 characters long, contain only lowercase letters, numbers, dots, and hyphens."
  exit 1
fi

# Check if the bucket already exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$REGION" 2>/dev/null; then
  echo "Error: Bucket '$BUCKET_NAME' already exists in region '$REGION'."
  exit 1
fi

# Create the S3 bucket
echo "Creating bucket '$BUCKET_NAME' in region: $REGION..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

# Check if the bucket was created successfully
#$? is a special variable in bash that holds the exit status of the last command executed.
#In Unix-like systems, an exit status of 0 typically means the command was successful, 
#while a non-zero value (e.g., 1, 2, etc.) indicates an error or failure.
if [ $? -eq 0 ]; then
  echo "Bucket '$BUCKET_NAME' created successfully in region '$REGION'."
else
  echo "Error: Failed to create bucket '$BUCKET_NAME' in region '$REGION'."
  exit 1
fi