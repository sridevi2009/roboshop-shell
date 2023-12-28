#!/bin/bash

AMI=ami-03265a0778a880afb
SGI=sg-0f01b9f5bb3c8f55b
INSTANCES=("mongodb" "mysql" "redis" "cart" "catalogue" "user" "shipping" "payment" "dispatch" "rabbitmq" "web")
ZONE_ID=Z01257041SG6EO358I2TX
DOMAIN_NAME="gopisri.cloud"

for i in "${INSTANCES[@]}"
do
   if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
   then
     INSTANCE_TYPE="t3.small"
   else
       INSTANCE_TYPE="t2.micro"
   fi     
     
   IP_ADDRESS=$(aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE --security-group-ids sg-0f01b9f5bb3c8f55b --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
   echo "$i: $IP_ADDRESS"
   aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch "
  {
    "Comment": "Testing creating a record set"
    ,"Changes": [{
      "Action"              : "CREATE"
      ,"ResourceRecordSet"  : {
        "Name"              : "$i.$DOMAIN_NAME"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "$IP_ADDRESS"
        }]
      }
    }]
  }
  '
   




done



