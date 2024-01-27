#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

MONGODB_HOST=mongodb.saidev.online

echo "script started excuting $TIMESTAMP" &>> LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
         echo -e "$2 is .. $R failed $N"
         exit 1
    else
         echo -e "$2 iS.. $G success $N"  
    fi  
}

if [ $ID -ne 0 ]
then
     echo -e "error : you are not a root user $R become root user $N"
     exit 1
else
     echo "you are a root user"
fi  

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabling node.js"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "ENABLING node.js" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "INSTALING node.js" 

id roboshop
if [ $? -ne 0 ]
then
   useradd roboshop 
   VALIDATE $? "ROBOSHOP USER CRESTION"
else 
   echo -e "$G roboshop user already exist skipping $N"
fi  

mkdir -p /app &>> $LOGFILE

VALIDATE $? "CREATING DIRECTORY" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "DOWNLOADING CATALOGUE" 

cd /app &>> $LOGFILE

VALIDATE $? "CHANGING DIRECTORY" 

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "UNZIPPING DIRECTORY" 

cd /app &>> $LOGFILE

VALIDATE $? "CHANGING DIRECTORY" 

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Coping catalogue.sevice file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reloading" 

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabling cataogue" 

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting cataogue" 

cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Coping mongodb.repo file" 

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "instaling mongodb shell" 

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE 

VALIDATE $? "loading schema" 