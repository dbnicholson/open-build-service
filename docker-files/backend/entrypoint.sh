#!/bin/bash

set -e

sed -e "s,@SRCSERVER_HOST@,${SRCSERVER_HOST},g" \
    -e "s,@REPSERVER_HOST@,${REPSERVER_HOST},g" \
    /usr/lib/obs/server/BSConfig.pm.in > /usr/lib/obs/server/BSConfig.pm

exec "$@"
