#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stared executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
       echo -e "$2 ... $R FAILED $N"
       exit 1
    else
       echo -e "$2 ... $G success $N"
    fi      
}

if [ $ID -ne 0 ]
then
   echo -e "$R ERROR: please run this with root access $N"
   exit 1 # you can give other than 0
else
   echo "you are root user"
fi    

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE

VALIDATE $? "installing remi release"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE

VALIDATE $? "enabling redis"

dnf install redis -y &>> $LOGFILE

VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE

VALIDATE $? "allowing remote connections"

systemctl enable redis &>> $LOGFILE

VALIDATE $? "enabled redis"

systemctl start redis &>> $LOGFILE

VALIDATE $? "start redis"


