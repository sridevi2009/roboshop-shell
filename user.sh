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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabling current nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enabling nodejs" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installing nodejs:18"

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop 
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y skipping $N"
fi

mkdir -p /app

VALIDATE $? "creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "downloading user application"

cd /app 

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "loading user data into mongodb"


