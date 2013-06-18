#! /usr/bin/perl
#--------------------------------------
# name: install_Ironcontrol.sh
# version 0.1
# date 04-06-2013
# autor Trust@FHH
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

exec("/usr/local/android-sdk/platform-tools/adb install ../resources/Ironcontrol.apk");
