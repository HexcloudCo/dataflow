#!/bin/bash

# Create a google cloud gcs bucket and service account with the proper
# permissions to access it. Outputs the auth for the flow into a file.

# https://cloud.google.com/sdk/docs/install

set -eo pipefail

PROJECT="$1"
REGION="$2"
BUCKET="$3"

NAME="hexcloud-dataflow-$BUCKET"
ROLE="$(echo $NAME | tr '-' '_')"

GCLOUD="gcloud --project=$PROJECT"

$GCLOUD storage buckets create gs://$BUCKET --location=$REGION

$GCLOUD iam service-accounts create $NAME

$GCLOUD iam roles create $ROLE --permissions=storage.objects.create,storage.objects.list,storage.objects.delete

$GCLOUD storage buckets add-iam-policy-binding --member serviceAccount:$NAME@$PROJECT.iam.gserviceaccount.com --role=projects/$PROJECT/roles/$ROLE gs://$BUCKET

$GCLOUD iam service-accounts keys create "$NAME.json" --iam-account="$NAME@$PROJECT.iam.gserviceaccount.com"

echo "Success, here are the auth params: $(cat $NAME.json)"
