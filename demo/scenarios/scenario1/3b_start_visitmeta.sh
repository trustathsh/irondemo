#!/bin/bash
#--------------------------------------
# name: init_scenario.sh
# version 0.1
# date 18-06-2013
# Trust@FHH
#--------------------------------------

# start VisITMeta
cd visitmeta*/
sh start-dataservice.sh &
sleep 7
sh start-visualization.sh
