#!/bin/bash

set -eo pipefail

# This is just an example, fill in the vars as you need...
#
# See the corresponding scripts in sinks for help in creating the cloud
# resources.

# take auth from file - it's a bit awkward to cut and paste...
AUTH="$(jq -c . gs-auth.json)"
SCHEMA="$(jq -c . table-schema.json)"

curl -s -u $APIKEY: -X POST 'https://hexcloud.co/v1/flow/create' \
  -H 'Content-Type: application/json' \
  -d @- <<EOF
{
  "name": "My bigquery Flow",
  "sinks": [{
    "type": "bigquery",
    "dataset": "my_dataset",
    "table": "my_table",
    "schema": $SCHEMA,
    "auth": $AUTH
  }]
}
EOF
