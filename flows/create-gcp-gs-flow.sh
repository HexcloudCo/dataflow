#!/bin/bash

set -eo pipefail

# This is just an example, fill in the vars as you need...
#
# The file transform is for a stream, you can omit it if you're only uploading
# files.

# take auth from file - it's a bit awkward to cut and paste...
AUTH="$(jq -c . gs-auth.json)"

curl -s -u $APIKEY: -X POST 'https://hexcloud.co/v1/flow/create' \
  -H 'Content-Type: application/json' \
  -d @- <<EOF
{
  "name": "My gs Flow",
  "transforms": [{
    "type": "file",
    "rotate": 60,
    "maxsize": 100000000,
    "compress": "gz",
    "filename": "<DATE>/foo-<DATETIME>.<FLOWID>.<PART>.log"
  }],
  "sinks": [{
    "type": "gs",
    "bucket": "test-bucket",
    "path": "foo/bar/",
    "auth": $AUTH
  }]
}
EOF
