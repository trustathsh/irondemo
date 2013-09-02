#!/usr/bin/perl
#--------------------------------------
# name: uninstall_Ironcontrol.pl
# version 0.1
# date 04-06-2013
# autor Trust@FHH
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

exec("/usr/local/android-sdk/platform-tools/adb uninstall de.hshannover.inform.trust.ifmapj.ironcontrol");
