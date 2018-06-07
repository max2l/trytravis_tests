#!/bin/sh -xe
cd ..
for instance in worker-0 worker-1 worker-2; do
  gcloud compute ssh ${instance} --command /root/install_Soft_to_Worker_Nodes.sh
done
cd -

