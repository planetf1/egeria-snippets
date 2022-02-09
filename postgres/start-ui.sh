#!/bin/sh

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

: "${VIEW_SERVER:=viewsrv}"
: "${LOGDIR:=$HOME/logs}"

mkdir -p $LOGDIR

: "${UIDIR:=/Users/jonesn/src/egeria-react-ui}"

export EGERIA_PRESENTATIONSERVER_SERVER_pg="{\"remoteServerName\":\"$VIEW_SERVER\",\"remoteURL\":\"https://localhost:9443\"}"
cd $UIDIR/cra-server
npm run prod 2>&1 | tee ${LOGDIR}/egeria-`date +%Y%m%d%H%M%S`-ui.log



