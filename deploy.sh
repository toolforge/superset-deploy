#!/bin/bash

if [ -z "${1}" ]
then
    echo "usage:"
    echo "${0} <install|upgrade>"
    exit
fi

helm repo add superset https://apache.github.io/superset

source secrets.sh

envsubst < dbs.yaml-template > dbs.yaml
envsubst < values.yaml-template > values.yaml

helm ${1} superset superset/superset -f values.yaml -f dbs.yaml --version 0.10.0
