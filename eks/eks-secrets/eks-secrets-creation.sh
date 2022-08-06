#!/bin/bash

# AWS Secret Manager for RDS
if [ ! -f ./redmine.env ]; then
  echo "File not found .env"
  exit 1
fi

echo "First, deleting the old secret: -credentials"

kubectl -n redmine delete secrets redmine-db-mysql || true

kubectl -n redmine delete secrets mysql-database || true

kubectl -n redmine delete secrets rds-admin || true

kubectl -n redmine delete secrets redmine-db-password  || true

kubectl -n redmine delete secrets redmine-secret-key || true


echo "file found, creating kubernetes secret: -credentials"

source ./redmine.env

kubectl -n redmine create secret generic redmine-db-mysql --from-literal=REDMINE_DB_MYSQL=${REDMINE_DB_MYSQL} # Rds Endpoint

kubectl -n redmine create secret generic mysql-database --from-literal=MYSQL_DATABASE=${MYSQL_DATABASE} # DB Name

kubectl -n redmine create secret generic rds-admin --from-literal=REDMINE_DB_USERNAME=${REDMINE_DB_USERNAME} # Rds Admin

kubectl -n redmine create secret generic redmine-db-password --from-literal=REDMINE_DB_PASSWORD=${REDMINE_DB_PASSWORD} # Rds root

kubectl -n redmine create secret generic redmine-secret-key --from-literal=REDMINE_SECRET_KEY_BASE=${REDMINE_SECRET_KEY_BASE}

# End
