### Deploy
## from the superset bastion node:
cd terraform
terraform init
terraform apply -var datacenter="<codfw1dev|eqiad1>"

if a new database was created update currentDb and oldDB values in ansible/vars/eqiad1.yaml

# When k8s is setup, start here
To install run `deploy.sh <codfw1dev|eqiad1> [migrate]`

## Disaster recovery deploy
after deploy.sh Create OAuth role:
all query access on all_query_access

# To migrate the db:
`deploy.sh <codfw1dev|eqiad1> migrate`

# manual db backup and restore:
in Horizon create a new trove database:
Volume Size: 8
Datastore: mysql 5.7.29
Flavor: g3.cores2.ram4.disk20
Initial Databases: superset
Initial Admin User: superset
```
mysqldump -h <original db hostname> -u superset -p superset > superset.backup
mysql -u superset -h <new db hostname> -p superset < superset.backup
# update values.yaml-template with new hostname
bash deploy.sh upgrade
```

# Upgrade notes
The OAuth role won't update on an upgrade. However the Alpha role and sql_lab roles (Of which OAuth is largely the union of) may change. Looking for differences between OAuth and the union of Alpha and sql_lab roles may be the solution to new permissions problems.


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
