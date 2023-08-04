#!/bin/bash

set -e

migrate='false'

if [ "${1}" = 'eqiad1' ]
then
  datacenter=${1}
elif [ "${1}" = 'codfw1dev' ]
then
  datacenter=${1}
else
  echo "Please enter datacenter."
  echo "Usage:"
  echo "${0} <eqiad1|codfw1dev>"
  exit
fi

if [ "${2}" = 'migrate' ]
then
  migrate='true'
fi


if ! command -v kubectl ; then
  echo "please install kubectl"
  exit 1
fi

if ! command -v helm ; then
  echo "please install helm"
  exit 1
fi

if ! command -v mysqldump ; then
  echo "please install mariadb-client"
  exit 1
fi

python3 -m venv .venv/deploy
source .venv/deploy/bin/activate
pip install ansible==8.1.0 kubernetes==26.1.0 PyMySQL==1.1.0

export KUBECONFIG=$(pwd)/terraform/kube.config

cd ansible
ansible-playbook superset-deploy.yaml --extra-vars "datacenter=${datacenter}"

if [ "${migrate}" = 'true' ]
then
  echo "migrating!"
  ansible-playbook db-migrate.yaml --extra-vars "datacenter=${datacenter}"
fi
