#! /usr/bin/perl
#--------------------------------------
# name: create_new_AVD.sh
# version 0.1
# date 04-06-2013
# autor Trust@FHH
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

exec("/usr/local/android-sdk/tools/android create avd -n AVD -t 1 --abi x86 -c 16M");