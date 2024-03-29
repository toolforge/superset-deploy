### Deploy
## from the superset bastion node:
cd tofu
tofu init
tofu apply -var datacenter="<codfw1dev|eqiad1>"

# When k8s is setup, start here
To install run `deploy.sh <codfw1dev|eqiad1>`

## Disaster recovery deploy
after deploy.sh Create OAuth role:
all query access on all_query_access

# To migrate the db:
```
export KUBECONFIG=<path/to/old/kubeconfig>
kubectl exec -it pod/superset-postgresql-0 -- bash
pg_dump --username=superset superset -F t > /tmp/db.tar

kubectl cp default/superset-postgresql-0:tmp/db.tar ./db.tar
export KUBECONFIG=<path/to/new/kubeconfig>
kubectl cp ./db.tar default/superset-postgresql-0:tmp/db.tar
kubectl exec -it pod/superset-postgresql-0 -- bash
pg_restore -c -U superset -F t -d superset /tmp/db.tar
```

# DB backups
Should be found in superset-bastion.superset.eqiad1.wikimedia.cloud:/home/rook/db-backup-superset/

# Upgrade notes
The OAuth role won't update on an upgrade. However the Alpha role and sql_lab roles may change. If a permissions problem manifests following an upgrade, looking for differences between the current and former Alpha and sql_lab roles may show a permission that can be added to OAuth to solve the issue.


# Minikube
You can run superset in minikube. Currently requires some fussing with files. Currently tested on minikube v1.26.1 k8s 1.23.15
```
cp values.yaml-template values.yaml
```
in values.yaml edit client_id to be 13067ed55ce2a4633af67dfffead4cb3 and client_secret to be 7079a6a2894554f2575fc173814713fcee498716
```
                'client_id':'13067ed55ce2a4633af67dfffead4cb3',
                'client_secret':'7079a6a2894554f2575fc173814713fcee498716',
```
Remove the SQLALCHEMY_DATABASE_URI at the end of the file
```
minikube addons enable ingress
helm repo add superset https://apache.github.io/superset
helm install superset superset/superset -f values.yaml --version 0.10.0
kubectl apply -f minikube-ingress.yaml
```
In your /etc/hosts file set the output of `minikube ip` to superset.local
https://superset.local/
Should now give you access.
TODO: make this an automatic install. Ansible templating would make this nicer
