#!/bin/bash -e

# We need to ensure this directory is writeable on start of the container
chmod -R 0777 /var/lib/grafana

exec /usr/bin/supervisord