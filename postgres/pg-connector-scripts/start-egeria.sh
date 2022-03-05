#!/bin/sh

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

: "${VIEW_SERVER:=viewsrv}"
: "${VER:=3.5}"
: "${DEBUG:=-Ddebug -Dorg.springframework.web.servlet.mvc.method.annotation=DEBUG -Dserver.tomcat.basedir=/tmp -Dserver.tomcat.accesslog.enabled=true -Dserver.tomcat.accesslog.buffered=false -Dlogging.level.org.springframework.web.client.RestTemplate=DEBUG -Djdk.httpclient.HttpClient.log=requests}"
# Must include server/lib - add other connector dirs as needed
: "${LIBS:=$HOME/pg,$HOME/src/egeria-database-connectors/egeria-connector-postgres/build/libs,server/lib}"
: "${LOGDIR:=$HOME/logs}"
: "${ASSEMBLY_DIR:=/Users/jonesn/src/egeria/egeria-release-3.5/open-metadata-distribution/open-metadata-assemblies/target/egeria-$VER-distribution/egeria-omag-$VER}"

mkdir -p ${LOGDIR}
cd ${ASSEMBLY_DIR}
java ${DEBUG} -Dloader.path=${LIBS} -jar server/server-chassis-spring-${VER}.jar 2>&1 | tee ${LOGDIR}/egeria-`date +%Y%m%d%H%M%S`-postgres.log

