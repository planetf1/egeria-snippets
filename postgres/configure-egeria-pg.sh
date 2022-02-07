#!/bin/sh

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

# Script will be run by k8s as part of our initialization job.
# Assumed here - platform up & responding to REST api, plus Kafka is available

# Note - expect to port this to python, aligned with our notebook configuration
# - this will facilitate error handling (vs very verbose scripting). Groovy an alternative
# Initial a version a script to get the basics working

# Set up defaults if environment doesn't override

# TODO - configure storage - graph vs inmem

: "${EGERIA_ENDPOINT:=https://localhost:9443}"
: "${KAFKA_ENDPOINT:=localhost:9092}"
: "${EGERIA_USER:=garygeeke}"
: "${EGERIA_COHORT:=cohort}"
: "${EGERIA_SERVER:=mdsrv}"
: "${VIEW_SERVER:=viewsrv}"
: "${INT_SERVER:=intsrv}"
: "${PG_USER:=USER}"
: "${PG_PASS:=PASS}"
: "${PG_URL:=jdbc:postgresql://localhost:5432/employees}"

# Any extra flags for curl, ie --verbose
EXTRA_FLAGS=""

echo '-- Environment variables --'
env
echo '-- End of Environment variables --'

echo -e '\n-- Configuring platform with requires servers'
# Set the URL root
echo -e '\n\n > Setting server URL root:\n'
curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/server-url-root?url=${EGERIA_ENDPOINT}"

# Setup the event bus
echo -e '\n\n > Setting up event bus:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/event-bus" \
  --data '{"producer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"}, "consumer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"} }'

# Enable all the access services (we will adjust this later)
echo -e '\n\n > Enabling all access servces:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/access-services?serviceMode=ENABLED"

# Use a local graph repo
echo -e '\n\n > Use local graph repo:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/local-repository/mode/local-graph-repository"

# Configure the cohort membership
echo -e '\n\n > configuring cohort membership:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/cohorts/${EGERIA_COHORT}"

# Start up the server
echo -e '\n\n > Starting the server:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST --max-time 900 \
                "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/instance"

# --- Now the view server

# Set the URL root
echo -e '\n\n > Setting view server URL root:\n'
curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/server-url-root?url=${EGERIA_ENDPOINT}"

# Setup the event bus
echo -e '\n\n > Setting up event bus:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/event-bus" \
  --data '{"producer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"}, "consumer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"} }'

# Set as view server
echo -e '\n\n > Set as view server:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/server-type?typeName=View%20Server"

# Setup a default audit log
echo -e '\n\n > setup default audit log:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/audit-log-destinations/default"


# Configure the view server cohort membership
#echo -e '\n\n > configuring cohort membership:\n'

#curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST \
#  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/cohorts/${EGERIA_COHORT}"

# Configure the view services
echo -e '\n\n > Setting up Glossary Author:\n'

 curl -f -k ${EXTRA_FLAGS} --basic admin:admin \
   --header "Content-Type: application/json" \
   "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/view-services/glossary-author" \
   --data @- <<EOF
{
  "class": "ViewServiceConfig",
  "omagserverPlatformRootURL": "${EGERIA_ENDPOINT}",
  "omagserverName" : "${EGERIA_SERVER}"
}
EOF

echo -e '\n\n > Setting up TEX:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/view-services/tex" \
  --data @- <<EOF
{
  "class":"IntegrationViewServiceConfig",
  "viewServiceAdminClass":"org.odpi.openmetadata.viewservices.tex.admin.TexViewAdmin",
  "viewServiceFullName":"Type Explorer",
  "viewServiceOperationalStatus":"ENABLED",
  "omagserverPlatformRootURL": "UNUSED",
  "omagserverName" : "UNUSED",
  "resourceEndpoints" : [
    {
      "class"              : "ResourceEndpointConfig",
      "resourceCategory"   : "Platform",
      "description"        : "Platform",
      "platformName"       : "platform",
      "platformRootURL"    : "${EGERIA_ENDPOINT}"
    },
    {
      "class"              : "ResourceEndpointConfig",
      "resourceCategory"   : "Server",
      "serverInstanceName" : "${EGERIA_SERVER}",
      "description"        : "Server",
      "platformName"       : "platform",
      "serverName"         : "${EGERIA_SERVER}"
    }
  ]
}
EOF

echo -e '\n\n > Setting up REX:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/view-services/rex" \
  --data @- <<EOF
{
  "class":"IntegrationViewServiceConfig",
  "viewServiceAdminClass":"org.odpi.openmetadata.viewservices.rex.admin.RexViewAdmin",
  "viewServiceFullName":"Repository Explorer",
  "viewServiceOperationalStatus":"ENABLED",
  "omagserverPlatformRootURL": "UNUSED",
  "omagserverName" : "UNUSED",
  "resourceEndpoints" : [
    {
              "class"              : "ResourceEndpointConfig",
        "resourceCategory"   : "Platform",
        "description"        : "Platform",
        "platformName"       : "platform",
        "platformRootURL"    : "${EGERIA_ENDPOINT}"
    },
                  {
        "class"              : "ResourceEndpointConfig",
        "resourceCategory"   : "Server",
        "serverInstanceName" : "${EGERIA_SERVER}",
        "description"        : "Server",
        "platformName"       : "platform",
        "serverName"         : "${EGERIA_SERVER}"
    }
  ]
}
EOF

echo -e '\n\n > Setting up DINO:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/view-services/dino" \
  --data @- <<EOF
{
  "class":"IntegrationViewServiceConfig",
  "viewServiceAdminClass":"org.odpi.openmetadata.viewservices.dino.admin.DinoViewAdmin",
  "viewServiceFullName":"Dino",
  "viewServiceOperationalStatus":"ENABLED",
  "omagserverPlatformRootURL": "UNUSED",
  "omagserverName" : "UNUSED",
  "resourceEndpoints" : [
    {
        "class"              : "ResourceEndpointConfig",
        "resourceCategory"   : "Platform",
        "description"        : "Platform",
        "platformName"       : "platform",
        "platformRootURL"    : "${EGERIA_ENDPOINT}"
    },
    {
        "class"              : "ResourceEndpointConfig",
        "resourceCategory"   : "Server",
        "serverInstanceName" : "${EGERIA_SERVER}",
        "description"        : "Server",
        "platformName"       : "platform",
        "serverName"         : "${EGERIA_SERVER}"
    },
    {
        "class"              : "ResourceEndpointConfig",
        "resourceCategory"   : "Server",
        "serverInstanceName" : "${VIEW_SERVER}",
        "description"        : "Server",
        "platformName"       : "platform",
        "serverName"         : "${VIEW_SERVER}"
    }
  ]
}
EOF

echo -e '\n\n > Setting up Server Author:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/view-services/server-author" \
  --data @- <<EOF
{
    "class":"IntegrationViewServiceConfig",
    "viewServiceAdminClass":"org.odpi.openmetadata.viewservices.serverauthor.admin.ServerAuthorViewAdmin",
    "viewFullServiceName":"ServerAuthor",
    "viewServiceOperationalStatus":"ENABLED",
    "omagserverPlatformRootURL": "${EGERIA_ENDPOINT}",
    "resourceEndpoints" : [
        {
           "class"              : "ResourceEndpointConfig",
           "resourceCategory"   : "Platform",
           "description"        : "Platform",
           "platformName"       : "platform",
           "platformRootURL"    : "${EGERIA_ENDPOINT}"
        }
    ]
}
EOF

# Start up the view server
echo -e '\n\n > Starting the view server:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST --max-time 900 \
                "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/instance"

# Setup the integration server

echo -e '\n\n > Setting server URL root:\n'
curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${INT_SERVER}/server-url-root?url=${EGERIA_ENDPOINT}"


echo -e '\n\n > configuring Postgres integration:\n'

curl -f -k -i ${EXTRA_FLAGS} --basic admin:admin -X POST "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${INT_SERVER}/integration-services/database-integrator" \
  --header 'Content-Type: application/json' \
  --data @- << EOF
  {
    "class": "IntegrationServiceRequestBody",
    "omagserverPlatformRootURL": "${EGERIA_ENDPOINT}",
    "omagserverName" : "${EGERIA_SERVER}",
    "integrationConnectorConfigs" :
    [
      {
        "class": "IntegrationConnectorConfig",
        "connectorName": "postgresql",
        "connectorUserId": "${EGERIA_USER}",
        "connection":
        {
          "class": "Connection",
          "userId": "${PG_USER}",
          "clearPassword": "${PG_PASS}",
          "connectorType":
          {
            "class": "ConnectorType",
            "connectorProviderClassName": "org.odpi.openmetadata.adapters.connectors.integration.postgres.PostgresDatabaseProvider"
          },
          "endpoint":
          {
            "class": "Endpoint",
            "address": "${PG_URL}"
          },
          "recognizedConfigurationProperties": [
            "url",
            "ssl"
          ],
          "configurationProperties":
          {
            "url": "${PG_URL}",
            "ssl": "false"
          }
        },
        "metadataSourceQualifiedName": "postgreshostserver",
        "refreshTimeInterval": "3456",
        "usesBlockingCalls": "false",
        "permittedSynchronization": "FROM_THIRD_PARTY"
      }
    ]
  }
EOF

# Setup a default audit log
echo -e '\n\n > setup default audit log:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${INT_SERVER}/audit-log-destinations/default"

# Start up the server
echo -e '\n\n > Starting the server:\n'

curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X POST --max-time 900 \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${INT_SERVER}/instance"

echo '\n\n -> Dumping out server config'

if [ -x "$(command -v jsonpp)" ]
then
  FORMAT=1
fi

for server in  ${VIEW_SERVER} ${EGERIA_SERVER} ${INT_SERVER}
do
  echo "\n\n -> ${server}"
  if [ $FORMAT -eq 1 ]
  then
    curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X GET \
      "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${server}/instance/configuration" | jsonpp
  else
      curl -f -k ${EXTRA_FLAGS} --basic admin:admin -X GET \
      "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${server}/instance/configuration"
  fi
done

echo '\n\n-- End of configuration'
