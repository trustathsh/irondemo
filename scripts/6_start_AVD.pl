#! /usr/bin/perl
#--------------------------------------
# name: start_AVD.sh
# version 0.1
# date 04-06-2013
# autor Trust@FHH
# Trust@FHH
#--------------------------------------

use strict;
use warnings;


my $pid = fork();

if($pid == 0){
  exec("/usr/local/android-sdk/tools/emulator -avd AVD");
}