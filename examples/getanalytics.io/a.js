function HexcloudAnalytics(userConfig) {
  function _send_to_server(payload) {
    payload['app'] = userConfig['app'];

    // some cleanup
    payload['sentAt'] = payload['meta']['ts'] / 1000;
    payload['requestId'] = payload['meta']['rid'];
    delete payload['meta'];

    if (userConfig['debug']) {
      console.info(payload);
    }

    var xhr = new XMLHttpRequest();
    var url = 'https://hexcloud.co/v1/flow/' + userConfig['flow_id'] + '/stream';
    xhr.open('POST', url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify(payload));
  }

  return {
    name: 'hexcloud-analytics-plugin',
    initialize: ({ config }) => {
      // console.info(config);
    },
    page: ({ payload }) => {
      _send_to_server(payload);
    },
    track: ({ payload }) => {
      _send_to_server(payload);
    },
    identify: ({ payload }) => {
      _send_to_server(payload);
    },
    loaded: () => {
      return true;
    }
  }
}

function HAInit(app, flow_id, debug) {
  if (debug === undefined) {
    debug = false;
  }

  const analytics = _analytics.init({
    app: app,
    debug: debug,
    version: 1,
    plugins: [
      HexcloudAnalytics({'app':app, 'flow_id': flow_id, 'debug': debug})
    ]
  })

  return analytics;
}
