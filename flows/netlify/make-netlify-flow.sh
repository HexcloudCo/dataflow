#!/bin/bash

set -eo pipefail

APIKEY="$1"
S3_AUTH="$(jq -c . $2)"
GS_AUTH="$(jq -c . $3)"
BQ_AUTH="$(jq -c . $4)"
BQ_SCHEMA="$(jq -c . $5)"

HOST="hexcloud.co"

curl -s -u $APIKEY: "https://$HOST/v1/flow/create" \
  -H 'Content-Type: application/json' \
  -d @- <<EOF
{
  "name": "Netlify Log Drain Flow",
  "transforms": [{
    "type": "file",
    "rotate": 60,
    "maxsize": 100000000,
    "compress": "gz",
    "filename": "<DATE>/netlify-<DATETIME>.<FLOWID>.<PART>.log"
  }],
  "sinks": [{
    "type": "s3",
    "bucket": "your-s3-bucket",
    "path": "netlify/",
    "auth": $S3_AUTH
  }, {
    "type": "gs",
    "bucket": "your-gs-bucket",
    "path": "netlify/",
    "auth": $GS_AUTH
  }, {
    "type": "bigquery",
    "dataset": "test",
    "table": "netlify",
    "schema": $BQ_SCHEMA,
    "auth": $BQ_AUTH
  }]
}
EOF
