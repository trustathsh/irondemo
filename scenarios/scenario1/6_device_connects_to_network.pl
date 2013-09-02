#!/usr/bin/perl
#--------------------------------------
# name: 6_device_connects_to_network.pl
# version 0.1
# date 19-06-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

my $AR = '111:33';
my $ARMAC = 'aa:bb:cc:dd:ee:ff';
my $ARIP = '10.0.0.1';
my $PDP = 'pdp1';
my $USER = 'Bob';
my $DEVICE = 'device1';
my $TYPE = 'arbitrary';

$ENV{'IFMAP_USER'} = 'sensor';
$ENV{'IFMAP_PASS'} = 'sensor';

system("java -jar ifmapcli/ar-ip.jar update $AR $ARIP");
system("java -jar ifmapcli/ar-mac.jar update $AR  $ARMAC");
system("java -jar ifmapcli/auth-by.jar update $AR $PDP");
system("java -jar ifmapcli/auth-as.jar update $AR $USER");

# create device
system("java -jar ifmapcli/ar-dev.jar update $AR $DEVICE");

# create categories and features
system("java -jar ifmapcli/feature2.jar -i $DEVICE");

my $FEATURE_1 = 'smartphone.android.app:11.permission:0.Name';
my $VALUE_1 = 'RECEIVE_BOOT_COMPLETED';

my $FEATURE_2 = 'smartphone.android.app:11.permission:1.Name';
my $VALUE_2 = 'CAMERA';

my $FEATURE_3 = 'smartphone.android.app:11.permission:2.Name';
my $VALUE_3 = 'INTERNET';

system("java -jar ifmapcli/featureSingle.jar -d $DEVICE -i $FEATURE_1 -t $TYPE -v $VALUE_1 -u");
system("java -jar ifmapcli/featureSingle.jar -d $DEVICE -i $FEATURE_2 -t $TYPE -v $VALUE_2 -u");
system("java -jar ifmapcli/featureSingle.jar -d $DEVICE -i $FEATURE_3 -t $TYPE -v $VALUE_3 -u");