#!/bin/bash
set -e
CONFIG_PATH="/data/options.json"

# Get standard home assistant config for the coordinates
curl -X GET \
    -H "x-ha-access: $HASSIO_TOKEN" \
    -H "Content-Type: application/json" \
    -o "/data/config.json" \
    http://hassio/homeassistant/api/config
	
jq -s '.[0] * .[1]' /data/config.json $CONFIG_PATH > $CONFIG_PATH

mustache $CONFIG_PATH /openvpn-monitor/server.mustache > ./openvpn-monitor.conf

cat ./openvpn-monitor.conf

exec "$@"