#!/bin/bash
export PGPASSWORD="superset"
pg_dump --username=superset superset -F t > /tmp/db.tar
