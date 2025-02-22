#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# Function to display usage information
usage() {
  echo "Usage: $0 <file_path> <bucket_name> [s3_key]"
  echo "Example: $0 /path/to/myfile.txt my-bucket-name folder/subfolder/myfile.txt"
  exit 1
}

# Check if file path and bucket name arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Error: File path or bucket name not provided."
  usage
fi

# Assign arguments to variables
FILE_PATH="$1"
BUCKET_NAME="$2"
S3_KEY="${3:-$(basename "$FILE_PATH")}" # Use file name as S3 key if not provided

# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File '$FILE_PATH' does not exist."
  exit 1
fi

# Check if the bucket exists
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "Error: Bucket '$BUCKET_NAME' does not exist or you do not have permission to access it."
  exit 1
fi

# Upload the file to the S3 bucket
echo "Uploading file '$FILE_PATH' to bucket '$BUCKET_NAME' with key '$S3_KEY'..."
aws s3 cp "$FILE_PATH" "s3://$BUCKET_NAME/$S3_KEY"

# Check if the upload was successful
if [ $? -eq 0 ]; then
  echo "File '$FILE_PATH' uploaded successfully to 's3://$BUCKET_NAME/$S3_KEY'."
else
  echo "Error: Failed to upload file '$FILE_PATH' to bucket '$BUCKET_NAME'."
  exit 1
fi