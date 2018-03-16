#!/bin/sh

apt update
apt install -y 

git clone -b monolith https://github.com/express42/reddit.git
if [ $? -ne 0 ]
then
  echo "CRITICAL: GIT repository is not clone!"
  exit 1  
fi

cd reddit 
bundle install
if [ $? -ne 0 ]
then
  echo "CRITICAL: Project is not build or is not install!"
  exit 1  
fi

echo "Starting application"

DIRECTORY=`pwd`
su - appuser -c "puma -d"
ps aux |grep -v grep | grep -q puma

if [ $? -eq 0 ]
then
  echo "Application is working"
  exit 0
else
  echo "Application is not working!"
  exit 1
fi
