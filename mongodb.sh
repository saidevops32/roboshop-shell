#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

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

cp mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "COPIED MONGODB REPO"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "installing mongo db"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "enabling mongo db"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "starting mongo db"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "remote access to mongo db"

systemctl restart mongod

VALIDATE $? "restarting mongo db"


