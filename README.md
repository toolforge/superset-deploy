# if k8s isn't setup, start here
## from an openstack control node:
export OS_PROJECT_ID=superset
openstack coe cluster create superset --cluster-template k8s23 --master-count 1 --node-count 2


## from local:
`git clone https://github.com/kubernetes/cloud-provider-openstack.git`

cloud.conf:
```
[Global]
application-credential-id = ${APPLICATION_CRED_ID}
application-credential-secret = ${APPLICATION_CRED_SECRET}
domain-name = default
auth-url = https://openstack.eqiad1.wikimediacloud.org:25000/v3
tenant-id = superset
region = eqiad1-r
```

```
cd cloud-provider-openstack
base64 -w 0 ../cloud.conf ; echo
vim manifests/cinder-csi-plugin/csi-secret-cinderplugin.yaml # replace cloud.conf 64 with above
kubectl create -f manifests/cinder-csi-plugin/csi-secret-cinderplugin.yaml
kubectl -f manifests/cinder-csi-plugin/ apply
```

sc.yaml:
```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: cinder.csi.openstack.org
parameters:
  availability: nova
```

`kubectl apply -f sc.yaml`



# When k8s is setup, start here
To install run `deploy.sh install`
After that there is some configuration that is still run manually:

Login with your user and then modify the database to make yourself an admin
```
kubectl exec -it pod/superset-postgresql-0 -- bash
PGPASSWORD=superset psql -Usuperset
update ab_user_role set role_id=1 where id=(select id from ab_user where username='VRook (WMF)');
```

Create OAuth role:
copy Alpha role, then add:
can sql json on Superset
menu access on SQL Lab
all query access on all_query_access

`deploy.sh upgrade` # One has to run the upgrade, after finishing the manual steps

# To backup and restore the db:
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
Set AUTH_USER_REGISTRATION_ROLE to Admin
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
