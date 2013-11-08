#!/usr/bin/perl
#--------------------------------------
# name: 8_device_opens_port.pl
# version 0.1
# date 26-06-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

my $AR = '111:33';
my $ARMAC = 'aa:bb:cc:dd:ee:ff';
my $ARIP = '10.0.0.1';
my $PDP = 'pdp1';
my $USER = 'Bob';
my $FEATURE = 'vulnerability-scan-result.vulnerability.port';
my $TYPE = 'arbitrary';
my $VALUE = '22';
my $DEVICE = 'device1';

$ENV{'IFMAP_USER'} = 'ironvas';
$ENV{'IFMAP_PASS'} = 'ironvas';

system("java -jar ifmapcli/featureSingle.jar -d $DEVICE -i $FEATURE -t $TYPE -v $VALUE -u");