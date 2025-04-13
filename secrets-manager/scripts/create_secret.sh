#!/bin/bash

# AWS Secret Creator Script
# Usage: ./create-secret.sh <region> <secret-name> <secret-value>

# Check if all required parameters are provided
if [ "$#" -ne 3 ]; then
    echo "Error: Invalid number of arguments"
    echo "Usage: $0 <region> <secret-name> <secret-value>"
    exit 1
fi

REGION=$1
SECRET_NAME=$2
SECRET_VALUE=$3

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it first."
    exit 1
fi
# The command -v command checks if aws is available in the system's PATH (i.e., whether the AWS CLI is installed and accessible).

# If aws is installed, this command returns the path to the AWS CLI executable (e.g., /usr/local/bin/aws).

# If not, it returns nothing (a non-zero exit status).

# > → Redirects output (stdout)

# 2> → Redirects errors (stderr)

# &> → Redirects both stdout and stderr (shortcut for > /dev/null 2>&1)
# Create the secret
aws secretsmanager create-secret \
    --name "$SECRET_NAME" \
    --secret-string "$SECRET_VALUE" \
    --region "$REGION"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Secret '$SECRET_NAME' created successfully in region $REGION"
else
    echo "Error: Failed to create secret '$SECRET_NAME'"
    exit 1
fi