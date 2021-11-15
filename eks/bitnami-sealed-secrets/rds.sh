#!/bin/bash

if [ ! -f ./RDS.env ]; then
  echo "Could not find ENV variables file for RDS. The file is missing: ./RDS.env"
  exit 1
fi

echo "First, deleting the old secret: readmine-rds-creds"
kubectl delete secret readmine-rds-creds || true

echo "Found RDS.env file, creating kubernetes secret: readmine-rds-creds"

source ./RDS.env

kubectl create namespace redmine

kubectl get ns

# If you want to create remove --dry-run

kubectl -n redmine create secret generic readmine-rds-creds \
  --dry-run=client \
  --from-literal=REDMINE_DB_MYSQL=${REDMINE_DB_MYSQL}  \
  --from-literal=REDMINE_DB_USERNAME=${REDMINE_DB_USERNAME} \
  --from-literal=REDMINE_DB_PASSWORD=${REDMINE_DB_PASSWORD}  \
  --from-literal=REDMINE_SECRET_KEY_BASE=${REDMINE_SECRET_KEY_BASE} \
  --from-literal=MYSQL_DATABASE=${MYSQL_DATABASE} \
  --output json