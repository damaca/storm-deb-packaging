#!/bin/bash
mkdir /var/run/storm
# Set permissions on directories
/bin/chown -R storm:storm /var/log/storm /opt/storm /var/run/storm
