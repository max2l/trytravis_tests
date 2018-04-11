#!/bin/sh

INVETRORY_FILE="inventory.json"

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

