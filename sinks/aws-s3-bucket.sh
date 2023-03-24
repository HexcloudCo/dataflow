#!/bin/bash

# Create and aws s3 bucket and iam user with the proper permissions to access
# it. Outputs the auth for a flow.
#
# See the corresponding scripts in flows for how to create the flow.

# sudo apt install awscli
# brew install awscli

set -eo pipefail

PROFILE="$1"
REGION="$2"
BUCKET="$3"

NAME="hex-df-$BUCKET"

# create bucket
aws --profile=$PROFILE --region=$REGION s3 mb s3://$BUCKET

# create user and access key
aws --profile=$PROFILE --region=$REGION iam create-user --user-name=$NAME
AK="$(aws --profile=$PROFILE --region=$REGION iam create-access-key --output=json --user-name=$NAME)"

# create policy and attach to user - we request PubObject and ListBucket on the given bucket
POLICY='{"Version": "2012-10-17", "Statement": [{"Effect": "Allow", "Action": ["s3:PutObject", "s3:ListBucket"], "Resource": ["arn:aws:s3:::'$BUCKET'", "arn:aws:s3:::*/*"]}]}'
POL="$(aws --profile=$PROFILE --region=$REGION iam create-policy --output=json --policy-name=$NAME --policy-document="$POLICY")"
ARN="$(echo $POL | jq -r .Policy.Arn)"
aws --profile=$PROFILE --region=$REGION iam attach-user-policy --user-name=$NAME --policy-arn=$ARN

AKID="$(echo $AK | jq -r .AccessKey.AccessKeyId)"
SK="$(echo $AK | jq -r .AccessKey.SecretAccessKey)"

echo "Success, here are the auth params: {\"region\": \"$REGION\", \"access_key\": \"$AKID\", \"secret_key\": \"$SK\"}"
