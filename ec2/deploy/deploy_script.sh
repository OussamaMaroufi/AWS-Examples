#!/usr/bin/env bash


STACK_NAME="aws-ec2-deploy"

# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/cloudformation/deploy/index.html
aws cloudformation deploy \
--template-file template.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--no-execute-changeset \
--region eu-west-3 \
--stack-name $STACK_NAME