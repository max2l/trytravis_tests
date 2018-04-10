#!/bin/sh

INVETRORY_FILE="inventory.json"
BIN_GCLOUD='/usr/bin/gcloud'
### Example OUTPUT
### reddit-app	10.132.0.3
###
gcloud --format="value(name, networkInterfaces[0].networkIP)" compute instances list

case $@ in
     --list)
          cat $INVETRORY_FILE
          ;;
     --host*)
          echo "{}"
          ;;
     *)   echo "For using the script you need to defining argument. Example:"
          basename "$0 [--list|--host]"

          ;;
esac
