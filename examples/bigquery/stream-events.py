#!/usr/bin/env python3

# this example emits a bigquery schema and streams json events to a stream (see
# flows/create-gcp-gs-flow.sh)
#
# In GCP, you'll create a table using this schema and a periodic data transfer
# that loads the gs files into a bigquery table.

import json
import sys
import time
import uuid
import random

import requests

flow_id = sys.argv[1]

# BigQuery schema - we add the common properties and the polymorphic properties
# to the same table making the optional fields nullable
fields = [
    {'name': 'id', 'type': 'string', 'mode': 'required'},
    {'name': 'type', 'type': 'string', 'mode': 'required'},
    {'name': 'ts', 'type': 'timestamp', 'mode': 'required'},
    {'name': 'properties', 'type': 'string', 'mode': 'nullable'},

    # metric
    {'name': 'metric', 'type': 'string', 'mode': 'nullable'},
    {'name': 'value', 'type': 'integer', 'mode': 'nullable'},
    
    # log
    {'name': 'msg', 'type': 'string', 'mode': 'nullable'},
    
    # event
    {'name': 'app', 'type': 'string', 'mode': 'nullable'},
    {'name': 'event', 'type': 'string', 'mode': 'nullable'},
]

print(json.dumps(fields, indent=2))

while 1:
    x = random.randint(0, 1000)
    evt = {
        'id': str(uuid.uuid4()),
        'type': random.choice(['log', 'event', 'metric']),
        'ts' : time.time(),
        'properties': {
            'x': x,
        },
    }

    if evt['type'] == 'metric':
        evt['name'] = 'blah'
        evt['value'] = x
    elif evt['type'] == 'log':
        evt['msg'] = f'Some log data {x}'
    elif evt['type'] == 'event':
        evt['app'] = random.choice(['appA', 'appB', 'appC'])
        evt['event'] = f'clicked a button {x}'

    # encode sub-objects as json strings and using json_extract in bq
    evt['properties'] = json.dumps(evt['properties'])

    print(json.dumps(evt))
    r = requests.post(f'https://hexcloud.co/v1/flow/{flow_id}/stream', json=evt)
    assert r.ok, r.content

    time.sleep(1)
