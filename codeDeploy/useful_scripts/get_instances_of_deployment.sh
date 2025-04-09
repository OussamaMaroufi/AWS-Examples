
#!/usr/bin/env bash
# Get the instances of a deployment
if [ -z "$1" ]; then
  echo "Usage: $0 <deployment_id>"
  echo "Please provide the name of the app name."
  exit 1
fi

DEPLOYMENT_ID=$1
aws deploy list-deployment-instances \
  --deployment-id "$DEPLOYMENT_ID" \
  --query "instancesList[]" \
  --output table