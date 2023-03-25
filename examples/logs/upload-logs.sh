#!/bin/bash

# Simple script to upload logs - might use this with an s3 or gs sink
#
# ./upload-logs.sh <flow-id> <prefix> <files>...

set -eo pipefail

FLOW_ID="$1"
shift
PREFIX="$1"    # "$(date +'%Y%m%d')/$(hostname)"
shift

FLOW_URL="https://local.hexc.io/v1/flow/$FLOW_ID/upload"

for fin in $*; do
  echo "Uploading $fin"
  fname="$(basename "$fin")"
  fout="$fin"
  tmp=""

  # gzip to temp file before send
  if [[ "$fin" != "*.gz" ]]; then
    tmp="$(mktemp)"
    fout="$tmp"
    fname="${fname}.gz"
    gzip -c "$fin" > "$fout"
  fi

  curl -F "file=@$fout;filename=$fname;headers=\"Path:$PREFIX\"" $FLOW_URL

  if [ "$tmp" != "" ]; then
    rm "$tmp"
  fi
done
