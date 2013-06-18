#! /usr/bin/perl
#--------------------------------------
# name: delete_AVD.sh
# version 0.1
# date 04-06-2013
# autor Trust@FHH
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

exec("/usr/local/android-sdk/tools/android - delete avd -n AVD");