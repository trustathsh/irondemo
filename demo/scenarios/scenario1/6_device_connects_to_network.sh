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

export IFMAP_USER=sensor
export IFMAP_PASS=sensor

# create device
java -jar ar-dev.jar update $AR $DEVICE

# create categories and features
java -jar feature2.jar -i $DEVICE

FEATURE=smartphone.android.app.permission.granted

VALUE_1=android.permission.RECEIVE_BOOT_COMPLETED
VALUE_2=android.permission.CAMERA
VALUE_3=android.permission.INTERNET

java -jar featureSingle.jar -d $DEVICE -i $FEATURE -t $TYPE -v $VALUE_1 -u
java -jar featureSingle.jar -d $DEVICE -i $FEATURE -t $TYPE -v $VALUE_2 -u
java -jar featureSingle.jar -d $DEVICE -i $FEATURE -t $TYPE -v $VALUE_3 -u
