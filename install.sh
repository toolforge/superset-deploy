#!/bin/bash

helm repo add superset https://apache.github.io/superset

source secrets.sh

envsubst < dbs.yaml-template > dbs.yaml
envsubst < values.yaml-template > values.yaml

helm install superset superset/superset -f values.yaml -f dbs.yaml
