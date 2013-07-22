#!/bin/bash
#--------------------------------------
# name: init_scenario.sh
# version 0.1
# date 18-06-2013
# Trust@FHH
#--------------------------------------

AR=111:33
ARMAC=aa:bb:cc:dd:ee:ff
ARIP=10.0.0.1
PDP=pdp1
USER=Bob
FEATURE=vulnerability-scan-result.vulnerability.port
TYPE=arbitrary
VALUE=22
DEVICE=device1

export IFMAP_USER=ironvas
export IFMAP_PASS=ironvas

java -jar ifmapcli/featureSingle.jar -d $DEVICE -i $FEATURE -t $TYPE -v $VALUE -u
