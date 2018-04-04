#!/bin/sh

gcloud beta compute --project "valued-clarity-198010" instances create "packer-puma-server" --zone "us-east1-b" --machine-type "f1-micro" --subnet "default" --maintenance-policy "MIGRATE" --service-account "500525456160-compute@developer.gserviceaccount.com" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --min-cpu-platform "Automatic" --tags "puma-server" --image "reddit-puma-1521712375" --image-project "valued-clarity-198010" --boot-disk-size "10" --boot-disk-type "pd-standard" --boot-disk-device-name "packer-puma-server"

gcloud compute --project=valued-clarity-198010 firewall-rules create default-puma-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server

