#!/bin/bash

# Create a google cloud bigquery dataset/table and service account with the
# proper permissions to access it. Outputs the auth for the flow into a file.
#
# See the corresponding scripts in flows for how to create the flow.

# https://cloud.google.com/sdk/docs/install

set -eo pipefail

PROJECT="$1"
DATASET="$2"
TABLE="$3"
SCHEMA="$4"  # a file

NAME="hex-df-$DATASET-$TABLE"
ROLE="$(echo $NAME | tr '-' '_')"

GCLOUD="gcloud --project=$PROJECT"
BQ="bq --project_id=$PROJECT"

$BQ mk ${DATASET}
$BQ mk --time_partitioning_field=ts --schema=$SCHEMA ${DATASET}.${TABLE}

$GCLOUD iam service-accounts create $NAME

$GCLOUD iam roles create $ROLE --permissions=bigquery.jobs.create,bigquery.jobs.get,bigquery.jobs.delete,bigquery.datasets.get,bigquery.tables.get,bigquery.tables.updateData

$BQ add-iam-policy-binding --member serviceAccount:$NAME@$PROJECT.iam.gserviceaccount.com --role=projects/$PROJECT/roles/$ROLE ${DATASET}.${TABLE}

# need to grant the service account on the dataset - this is kinda hoaky
$BQ show --format=prettyjson $DATASET | jq '.access += [{"role": "READER", "userByEmail": "'$NAME@$PROJECT.iam.gserviceaccount.com'"}]' > /tmp/$DATASET.json
$BQ update --source=/tmp/$DATASET.json $DATASET
rm /tmp/$DATASET.json

$GCLOUD iam service-accounts keys create "$NAME.json" --iam-account="$NAME@$PROJECT.iam.gserviceaccount.com"

echo "Success, here are the auth params: $(cat $NAME.json)"
