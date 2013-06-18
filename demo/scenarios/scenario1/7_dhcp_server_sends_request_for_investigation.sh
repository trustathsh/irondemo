#! /usr/bin/bash
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
QUALIFIER=vulnerability-scan

export IFMAP_USER=dhcp
export IFMAP_PASS=dhcp

java -jar req-inv.jar update $DEVICE $ARIP $QUALIFIER