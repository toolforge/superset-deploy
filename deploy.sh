#!/bin/bash

set -e
datacenter='eqiad1'


if ! command -v kubectl ; then
  echo "please install kubectl"
  exit 1
fi

if ! command -v terraform ; then
  echo "please install terraform"
  exit 1
fi

python3 -m venv .venv/deploy
source .venv/deploy/bin/activate
pip install ansible==8.1.0 kubernetes==26.1.0

cd terraform
terraform init
terraform apply -var datacenter=${datacenter}  # -auto-approve
export KUBECONFIG=$(pwd)/kube.config

cd ../ansible
ansible-playbook superset-deploy.yaml --extra-vars "datacenter=${datacenter}"
