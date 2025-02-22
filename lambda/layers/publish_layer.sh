#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# Function to display usage information
usage() {
  echo "Usage: $0 <layer_name> <s3_bucket> <s3_key> <compatible_runtimes>"
  echo "Example: $0 my-layer my-bucket layers/my-layer.zip python3.8,python3.9"
  exit 1
}

# Check if all required arguments are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
  echo "Error: Missing arguments."
  usage
fi

# Assign arguments to variables
LAYER_NAME="$1"
S3_BUCKET="$2"
S3_KEY="$3"
COMPATIBLE_RUNTIMES="$4"

# Validate compatible runtimes format (comma-separated)
if ! [[ "$COMPATIBLE_RUNTIMES" =~ ^[a-zA-Z0-9.,]+$ ]]; then
  echo "Error: Invalid compatible runtimes format. Use comma-separated values (e.g., python3.8,python3.9)."
  exit 1
fi

# Publish the Lambda layer
echo "Publishing Lambda layer '$LAYER_NAME' from S3 bucket '$S3_BUCKET' with key '$S3_KEY'..."
LAYER_VERSION_ARN=$(aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --description "Layer published from S3" \
  --content "S3Bucket=$S3_BUCKET,S3Key=$S3_KEY" \
  --compatible-runtimes $COMPATIBLE_RUNTIMES \
  --query 'LayerVersionArn' \
  --output text)

# Check if the layer was published successfully
if [ $? -eq 0 ]; then
  echo "Lambda layer '$LAYER_NAME' published successfully."
  echo "Layer Version ARN: $LAYER_VERSION_ARN"
else
  echo "Error: Failed to publish Lambda layer '$LAYER_NAME'."
  exit 1
fi