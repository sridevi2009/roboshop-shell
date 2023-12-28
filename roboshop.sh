#!/bin/bash

AMI=ami-03265a0778a880afb
SGI=sg-0f01b9f5bb3c8f55b
INSTANCES=("mongodb" "mysql" "redis" "cart" "catalogue" "user" "shipping" "payment" "dispatch" "rabbitmq" "web")

for i in "${INSTANCES[@]}"
do
   echo "instace is: $i"
   if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
   then
     INSTANCES_TYPE="t3.small"
   else
       INSTANCE_TYPE="t2.micro"
   fi     
     
     aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE --security-group-ids sg-0f01b9f5bb3c8f55b --tag-specifications "ResourceType=instance,Tags=[{Key=Name,value=$i}]"

done


