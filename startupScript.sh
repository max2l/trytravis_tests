#!/bin/sh

apt update
apt install -y ruby-full ruby-bundler build-essential

if [ $? -eq 0 ]
then
  echo "OK: Command for instaling finished without errors"
else
  echo "CRITICAL: Command for installing is not complete!"
  exit 1
fi

ruby -v

if [ $? -ne 0 ]
then
  echo "CRITICAL: Ruby is not installed!"
  exit 1  
fi

bundle -v

if [ $? -ne 0 ]
then
  echo "CRITICAL: Command bundle working is not correct!"
  exit 1  
fi
echo "OK: Ruby is installed"

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'

apt update
apt install -y mongodb-org

if [ $? -eq 0 ]
then
  echo "OK: Command for instaling mongodb finished without errors"
else
  echo "CRITICAL: Command for installing is not complete!"
  exit 1
fi

systemctl start mongod

if [ $? -ne 0 ]
then
  echo "CRITICAL: MongoDB is not started!"
  exit 1  
fi

systemctl enable mongod
echo "OK: MongoDB is installed and is started"

git clone -b monolith https://github.com/express42/reddit.git
cd 
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
su - appuser -c "cd $DIRECTORY && puma -d"
ps aux |grep -v grep | grep -q puma

if [ $? -eq 0 ]
then
  echo "Application is working"
  exit 0
else
  echo "Application is not working!"
  exit 1
fi
