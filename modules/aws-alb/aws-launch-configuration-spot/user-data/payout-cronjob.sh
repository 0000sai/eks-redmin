#!/bin/bash
# Maintainer <Muhammad Asim quickbooks2018@gmail.com>
# Update route53 record & Services
# OS AmazonLinux2
# Note: Role must be attached for ECR image pull/push ---> eureka-server role is setup
# https://docs.amazonaws.cn/en_us/codedeploy/latest/userguide/application-revisions-appspec-file.html



# Existing payout-cronjob-dev containers & Images Clean Up

docker rm -f $(docker ps -aq)

docker rmi -f $(docker images -aq)

# docker run and Image

# docker login
$(aws ecr get-login --no-include-email --region us-east-1)

# Downloading release-tag from S3
aws s3 cp s3://dukaanapp-prod-pipeline/payout-cronjob/release-tag .

PAYOUT_CRONJOB_PROD="latest"

export PAYOUT_CRONJOB_PROD

docker run --name payout-cronjob -h payout-cronjob.dukaanapp.pk --log-driver="awslogs" --log-opt awslogs-region="us-east-1" --log-opt awslogs-group="/dukaan/prod/payout-cronjob" --log-opt awslogs-stream="payout-cronjob" -e "SERVER_PORT=80" -p 80:80 -e "SPRING_PROFILES_ACTIVE=prod" -id 385789235361.dkr.ecr.us-east-1.amazonaws.com/dukaan/cronjob/payout:"$PAYOUT_CRONJOB_PROD"





# Route53 Section

localip=$(curl -fs http://169.254.169.254/latest/meta-data/local-ipv4)
hostedzoneid="Z04663546OQGIMS9MXLP"
file=/tmp/record.json

#  API Service

cat << EOF > $file
{
  "Comment": "Update the A record set",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "payout-cronjob.dukaanapp.pk",
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


# Create cronjob-setup to Setup a CronJob (For Different Timings & Triggers )

aws s3 cp s3://dukaanapp-prod-pipeline/payout-cronjob/payout-cronjob-prod.sh .

echo '
mode: "000644"
owner: root
group: root
content: |
    0 3 ? * MON * root chmod +x /root/payout-cronjob-prod/payout-cronjob-prod.sh && /root/payout-cronjob-prod/payout-cronjob-prod.sh

' > /etc/cron.d/cronjob-setup



# END