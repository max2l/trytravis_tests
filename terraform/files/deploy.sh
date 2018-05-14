#!/bin/bash
set -e

sudo wget -O /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
sudo chmod +x /usr/local/bin/gitlab-runner
curl -sSL https://get.docker.com/ | sh
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
sudo /usr/local/bin/gitlab-runner register \
  --non-interactive \
  --url "http://35.195.94.193/" \
  --registration-token "dEsoJefiXvRX4txkoQHs" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "docker-runner" \
  --tag-list "linux,xenial,ubuntu,docker" \
  --run-untagged \
  --locked="false"

