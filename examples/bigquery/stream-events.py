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
