#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# Function to display usage information
usage() {
  echo "Usage: $0 <bucket_name>"
  echo "Example: $0 my-bucket-name"
  exit 1
}

# Check if bucket name argument is provided
if [ -z "$1" ]; then
  echo "Error: Bucket name not provided."
  usage
fi

# Assign bucket name to a variable
BUCKET_NAME="$1"

# Check if the bucket exists
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "Error: Bucket '$BUCKET_NAME' does not exist or you do not have permission to access it."
  exit 1
fi

# Empty the bucket (delete all objects and versions)
echo "Emptying bucket '$BUCKET_NAME'..."
aws s3 rm "s3://$BUCKET_NAME" --recursive --quiet
aws s3api delete-objects \
  --bucket "$BUCKET_NAME" \
  --delete "$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json --query '{Objects: Versions[].{Key: Key, VersionId: VersionId}}')" \
  --quiet

# Delete the bucket
echo "Deleting bucket '$BUCKET_NAME'..."
aws s3api delete-bucket --bucket "$BUCKET_NAME"

# Check if the bucket was deleted successfully
if [ $? -eq 0 ]; then
  echo "Bucket '$BUCKET_NAME' deleted successfully."
else
  echo "Error: Failed to delete bucket '$BUCKET_NAME'."
  exit 1
fi