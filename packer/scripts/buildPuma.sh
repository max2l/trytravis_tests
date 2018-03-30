#!/bin/sh

apt update
apt install -y git

cd /usr/local
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

mv /tmp/puma.service /etc/systemd/system/puma.service
systemctl enable puma.service

if [ $? -ne 0 ]
then
  echo "CRITICAL: puma.service is not enable!"
  exit 1
else
  echo "OK: puma.service was enabled"
fi

