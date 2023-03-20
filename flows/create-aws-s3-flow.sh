#!/bin/bash

set -eo pipefail

# This is just an example, fill in the vars as you need...
#
# The file transform is for a stream, you can omit it if you're only uploading
# files.

curl -s -u $APIKEY: -X POST 'https://hexcloud.co/v1/flow/create' \
  -H 'Content-Type: application/json' \
  -d @- <<EOF
{
  "name": "My s3 Flow",
  "transforms": [{
    "type": "file",
    "rotate": 60,
    "maxsize": 100000000,
    "compress": "gz",
    "filename": "<DATE>/foo-<DATETIME>.<FLOWID>.<PART>.log"
  }],
  "sinks": [{
    "type": "s3",
    "bucket": "test-bucket",
    "path": "foo/bar/",
    "auth": {"region": "$REGION", "access_key": "$ACCESS_KEY", "secret_key": "$SECRET_KEY"}
  }]
}
EOF
