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
FEATURE=vulnerability-scan-result.vulnerability.port
TYPE=qualified
VALUE=22

export IFMAP_USER=sensor
export IFMAP_PASS=sensor

java -jar featureSingle.jar -d $DEVICE -i $FEATURE -t $TYPE -v $VALUE -u