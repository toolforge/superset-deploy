#!/bin/bash

set -e

/usr/local/bin/kubectl cp ./pg_dump.sh default/superset-postgresql-0:/tmp/pg_dump.sh
/usr/local/bin/kubectl exec -it pod/superset-postgresql-0 -- bash /tmp/pg_dump.sh
/usr/local/bin/kubectl cp default/superset-postgresql-0:tmp/db.tar ./superset-db-backup

mv ./superset-db-backup.4 ./superset-db-backup.5
mv ./superset-db-backup.3 ./superset-db-backup.4
mv ./superset-db-backup.2 ./superset-db-backup.3
mv ./superset-db-backup.1 ./superset-db-backup.2
mv ./superset-db-backup ./superset-db-backup.1
