#!/bin/bash
BIN_USERADD=`/usr/bin/which useradd`
$BIN_USERADD -d /opt/storm -s /bin/bash storm
