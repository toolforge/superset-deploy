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
To install run `install.sh`
After that there is some configuration that is still run manually:

Login with your user and then modify the database to make yourself an admin
```
kubectl exec -it pod/superset-postgresql-0 -- bash
PGPASSWORD=superset psql -Usuperset
update ab_user_role set role_id=1 where id=(select id from ab_user where username='VRook (WMF)');
```

The gamma role needs two permissions added:
all database access on all_database_access
can sql json on Superset
can my queries on SqlLab
menu access on SQL Lab

^^ actually we need to figure out how to add sql_lab role to all users


# To backup and restore the db:
```
kubectl exec -it pod/superset-postgresql-0 -- bash
pg_dump --username=superset superset -F t > /tmp/db.tar
password=superset
kubectl cp default/superset-postgresql-0:tmp/db.tar ./db.tar
kubectl cp ./db.tar default/superset-postgresql-0:tmp/db.tar
kubectl exec -it pod/superset-postgresql-0 -- bash
pg_restore -c -U superset -F t -d superset /tmp/db.tar
```


The DB list was generated in Quarry by BStorm (WMF) running:
(https://quarry.wmcloud.org/query/53805)
select dbname from wiki;
against meta_p

We may want to run this again on installs or daily? DBs may not be added quickly enough for automation to be really needed, as a ticket can be opened to add a new DB as well.
