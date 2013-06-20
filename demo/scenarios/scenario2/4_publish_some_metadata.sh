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

export IFMAP_USER=pdp
export IFMAP_PASS=pdp

java -jar ifmapcli/ar-ip.jar update $AR $ARIP
java -jar ifmapcli/ar-mac.jar update $AR $ARMAC
java -jar ifmapcli/auth-by.jar update $AR $PDP
java -jar ifmapcli/auth-as.jar update $AR $USER
