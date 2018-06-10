#!/bin/sh
set -e

mcrouter -p 5000 -f /etc/mcrouter/mcrouter.json &

exec consul-template \
    -log-level $GLUU_CT_LOG_LEVEL \
    -consul-addr $GLUU_KV_HOST:$GLUU_KV_PORT \
    -template "/opt/templates/mcrouter.json.ctmpl:/etc/mcrouter/mcrouter.json" \
    -wait 5s
