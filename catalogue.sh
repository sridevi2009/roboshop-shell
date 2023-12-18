#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stared executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
       echo -e "$2 ... $R FAILED $N"
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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabling current nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enabling nodejs" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installing nodejs:18"

useradd roboshop 

VALIDATE $? "creating roboshop"

mkdir /app

VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "downloading catalogue application"

cd /app

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping catalogue"

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue service file"

systemctl daemon-reload  &>> $LOGFILE

VALIDATE $? "catalogue daemon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting  catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "loading catalogue data into mongodb"
