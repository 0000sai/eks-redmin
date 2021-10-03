#!/bin/bash
# Maintainer <Muhammad Asim quickbooks2018@gmail.com>
# Update route53 record & Services
# OS AmazonLinux2
# Note: Role must be attached for ECR image pull/push


# docker run and Image

# docker login
$(aws ecr get-login --no-include-email --region us-east-1)


# Kuzzle Setup

# Downloading release-tag from S3
aws s3 cp s3://dukaanapp-prod-pipeline/kuzzle/release-tag .


KUZZLE_TAG=`cat release-tag`

export KUZZLE_TAG

# docker network create --driver bridge --subnet=172.18.0.0/16 kuzzle --attachable

# https://docs.docker.com/engine/reference/commandline/network_create/

# https://stackoverflow.com/questions/27937185/assign-static-ip-to-docker-container

# --ip=172.18.0.22


# Route53 Section
localip=$(curl -fs http://169.254.169.254/latest/meta-data/local-ipv4)
hostedzoneid="Z04663546OQGIMS9MXLP"
file=/tmp/record.json


#  Kuzzle Server-3

cat << EOF > $file
{
  "Comment": "Update the A record set",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "kuzzle3.dukaanapp.pk",
        "Type": "A",
        "TTL": 10,
        "ResourceRecords": [
          {
            "Value": "$localip"
          }
        ]
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets --hosted-zone-id $hostedzoneid --change-batch file://$file

# Docker Run
docker run --name kuzzle -h kuzzle3.dukaanapp.pk --network="host" -e kuzzle_services__storageEngine__client__node="https://elasticsearch-cluster-production.dukaanapp.pk" -e kuzzle_services__internalCache__node__host="redis.edmq2l.ng.0001.use1.cache.amazonaws.com" -e kuzzle_services__memoryStorage__node__host="redis.edmq2l.ng.0001.use1.cache.amazonaws.com" -e kuzzle_server__protocols__mqtt__enabled="true" -e NODE_ENV="production" --cap-add SYS_PTRACE --log-driver="awslogs" --log-opt awslogs-region="us-east-1" --log-opt awslogs-group="/dukaan/prod/kuzzle" --log-opt awslogs-stream="kuzzle" --restart unless-stopped -id 385789235361.dkr.ecr.us-east-1.amazonaws.com/dukaan/kuzzle:${KUZZLE_TAG}


# https://kuzzle.dukaanapp.pk/cluster/_status

# ALB Health Checks  # ---> ASK TO ENABLE ANONYMOUS HEALTH CHECK   --->  /_healthCheck


# END