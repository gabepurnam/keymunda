#!/bin/bash


if [[ -z "${KEYCLOAK_HOST}" ]]; then
    echo "You need to provide a value for KEYCLOAK_HOST"
    exit 1
fi

sudo -E /camunda/conf/java-cert-importer.sh ${KEYCLOAK_HOST} 443

exec /camunda/camunda.sh
