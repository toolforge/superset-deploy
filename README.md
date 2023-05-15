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
```
kubectl exec -it pod/superset-postgresql-0 -- bash
pg_dump --username=superset superset -F t > /tmp/db.tar
password=superset
kubectl cp default/superset-postgresql-0:tmp/db.tar ./db.tar
kubectl cp ./db.tar default/superset-postgresql-0:tmp/db.tar
kubectl exec -it pod/superset-postgresql-0 -- bash
pg_restore -c -U superset -F t -d superset /tmp/db.tar
```
