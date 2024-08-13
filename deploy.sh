#!/bin/bash

set -e

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

if ! command -v kubectl ; then
  echo "please install kubectl"
  exit 1
fi

if ! command -v helm ; then
  echo "please install helm"
  exit 1
fi

python3 -m venv .venv/deploy
source .venv/deploy/bin/activate
pip install ansible==8.1.0 kubernetes==26.1.0 PyMySQL==1.1.0
# install helm diff. Needed to keep helm module idempotent
helm plugin install https://github.com/databus23/helm-diff || true
# update kubernetes.core. This path will likely need updated with bastion os upgrades.
ansible-galaxy collection install -U kubernetes.core -p ./.venv/deploy/lib/python3.11/site-packages/ansible_collections

cd tofu
tofu init
tofu apply -var datacenter=${datacenter} # -auto-approve
export KUBECONFIG=$(pwd)/kube.config

cd ../ansible
ansible-playbook superset-deploy.yaml --extra-vars "datacenter=${datacenter}"
