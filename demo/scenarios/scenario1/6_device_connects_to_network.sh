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
DEVICE=device1
TYPE=arbitrary

export IFMAP_USER=sensor
export IFMAP_PASS=sensor

# create device
java -jar ar-dev.jar update $AR $DEVICE

# create categories and features
java -jar feature2.jar -i $DEVICE

FEATURE_1=smartphone.android.app:11.permission:0.Name
VALUE_1=RECEIVE_BOOT_COMPLETED

FEATURE_2=smartphone.android.app:11.permission:1.Name
VALUE_2=CAMERA

FEATURE_3=smartphone.android.app:11.permission:2.Name
VALUE_3=INTERNET

java -jar ifmapcli/featureSingle.jar -d $DEVICE -i $FEATURE_1 -t $TYPE -v $VALUE_1 -u
java -jar ifmapcli/featureSingle.jar -d $DEVICE -i $FEATURE_2 -t $TYPE -v $VALUE_2 -u
java -jar ifmapcli/featureSingle.jar -d $DEVICE -i $FEATURE_3 -t $TYPE -v $VALUE_3 -u
