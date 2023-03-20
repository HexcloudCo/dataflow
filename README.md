# Hexcloud Dataflow

Dataflow is a service and api that allows you to more easily ship your data to
the cloud. Using the api you create "flows" which allow you to stream and
upload files, transform that data, and ultimately place it in the cloud for use
by other systems or archival.

## Use-cases

The primary initial use-case is uploading data to cloud storage where it can be
consumed by other systems. People doing operations, devops, or data engineering
can use it for data warehousing, archival, analytics, and log ingestion.

Eventually we will support more types of sinks - potentially including:

- Cloud Storage (s3, gcs, azure, etc)
- Dropbox, Box, Google Drive, Google sheets
- BigQuery, Redshift, various data warehouses
- Analytics - [analytics](https://getanalytics.io/), Segment, Mixpanel, Domo, Amplitude, Hubspot, etc
- Chat - Slack, xmpp, Zulip, etc

And transforms and formats:

- De/compression (gz, xz, bzip2)
- json / jsonl / csv

Suggestions on additions welcome [https://hexcloud.co/contact](Contact)

## API

Authentication uses an api-key over http basic auth - the api-key is the
username with no password. It is required for creating and getting flow
metadata, but optional for uploading or streaming data to the flow - the url or
flow-id proxies as the secret to simplify uploading data. Any http client that
supports basic auth can be used, using curl it would look like:

```bash
$ curl -u <api-key>: https://hexcloud.co/v1/flow
```

### API Summary:

List flows:
```
GET /v1/flow
{
  "data": [
    {
      "id": "fJJSnseETbPF",
      "created": "2023-03-19T19:24:33.655945Z",
      "updated": "2023-03-19T19:24:33.655945Z",
      "deleted": null,
      "name": "My First Flow",
      "user_id": "u1qmQL5Zu21J",
      "transforms": [
           ...
      ],
      "sinks": [
        ...
      ]
    }
  ]
```

Get flow by id:
```
GET /v1/flow/fJJSnseETbPF
{
  "id": "fJJSnseETbPF",
  "created": "2023-03-19T19:24:33.655945Z",
  "updated": "2023-03-19T19:24:33.655945Z",
  "deleted": null,
  "name": "My First Flow",
  "user_id": "u1qmQL5Zu21J",
  "transforms": [
    ...
  ],
  "sinks": [
    ...
  ]
}
```

Create a flow [example](https://github.com/HexcloudCo/dataflow/blob/main/flows/create-aws-s3-flow.sh):
```
POST /v1/flow/create
{
  "name": "My Flow",
  "transforms": [               # optional
    ...
  ],
  "sinks": [
    ...
  ],
}
```

And there are two endpoints for uploading data:
```
POST /v1/flow/<flow-id>/upload
```

Supports
[multipart/form-data](https://medium.com/@danishkhan.jamia/upload-data-using-multipart-16b54866f5bf)
encoding. Multiple files can be uploaded in a single request and certain
attributes such as name and path can be overridden. A single post can currently
be up to 2GB in size.

For example, using curl, this is simply:
```bash
curl -F 'file=@foo.txt' \
     -F 'file=@bar.txt;filename=othername.txt;headers="Path:store/at/alternate/path/"' \
     https://hexcloud.co/v1/flow/<flow-id>/upload
```

Alternately, stream data (POST limited to 1MB):
```bash
POST /v1/flow/<flow-id>/stream

curl --data-binary $'this is some log data\nand another line' \
  https://hexcloud.co/v1/flow/<flow-id>/stream
```

Streams are buffered at the server and periodically rotated and uploaded to a
sink using the "file" transform:
```
"transforms": [{
  "type": "file",
  "rotate": 60,                 # create a new file every 60 minutes
  "maxsize": 1000000,           # create a new file part every ~megabyte
  "compress": "gz",             # gzip compress before upload

  "filename": "<DATE>/foo-<DATETIME>.<FLOWID>.<PART>.log"
                                # the output filename relative to sink
                                # path optionally including additional
                                # <DATE> path
}]
```
