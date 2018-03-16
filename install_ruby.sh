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
exit 0
