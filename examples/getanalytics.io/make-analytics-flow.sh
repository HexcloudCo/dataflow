#!/bin/bash

set -eo pipefail

# See sinks/gcp/gcp-bigquery-table.sh and gcp-gs-bucket.sh

APIKEY="$1"
GS_AUTH="$(jq -c . $2)"
BQ_AUTH="$(jq -c . $3)"
BQ_SCHEMA="$(jq -c . $4)"

curl -s -u $APIKEY: "https://hexcloud.co/v1/flow/create" \
  -H 'Content-Type: application/json' \
  -d @- <<EOF
{
  "name": "Analytics",
  "transforms": [{
    "type": "augment",
    "fields": {
      "receivedAt": "ts",
      "headers": "headers",
      "ip": "ip"
    }
  }, {
    "type": "file",
    "rotate": 60,
    "maxsize": 100000000,
    "compress": "gz",
    "filename": "<DATE>/event-<DATETIME>.<FLOWID>.<PART>.log"
  }],
  "sinks": [{
    "type": "gs",
    "bucket": "gs-bucket",
    "path": "some/path/",
    "auth": $GS_AUTH
  }, {
    "type": "bigquery",
    "dataset": "your-dataset",
    "table": "analytics",
    "schema": $BQ_SCHEMA,
    "auth": $BQ_AUTH
  }]
}
EOF
