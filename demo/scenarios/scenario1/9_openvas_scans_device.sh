#!/bin/bash
#--------------------------------------
# name: init_scenario.sh
# version 0.1
# date 18-06-2013
# Trust@FHH
#--------------------------------------

AR=access-request1
ARMAC=aa:bb:cc:dd:ee:ff
ARIP=10.0.0.1
PDP=pdp1
USER=Bob
EVENTNAME="port open"

export IFMAP_USER=ironvas
export IFMAP_PASS=ironvas

java -jar ifmapcli/event.jar update -i ip -v $ARIP -n $EVENTNAME