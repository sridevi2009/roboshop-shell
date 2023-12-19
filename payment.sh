#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.gopisri.cloud

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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "installing gcc "

useradd roboshop &>> $LOGFILE

VALIDATE $? "creating user"

mkdir /app &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "downloading payment"

cd /app 

unzip -o /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "unzipping payment"

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "copying payment service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "payment daemon reload"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "enabling payment"

systemctl start payment &>> $LOGFILE
 
VALIDATE $? "starting payment"