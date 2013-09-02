#!/usr/bin/perl
#--------------------------------------
# name: 4_publish_some_metadata.pl
# version 0.1
# date 26-08-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

my $AR = '111:33';
my $ARMAC = 'aa:bb:cc:dd:ee:ff';
my $ARIP = '10.0.0.1';
my $PDP = 'pdp1';
my $USER = 'Bob';

$ENV{'IFMAP_USER'} = 'pdp';
$ENV{'IFMAP_PASS'} = 'pdp';

system("java -jar ifmapcli/ar-ip.jar update $AR $ARIP");
system("java -jar ifmapcli/ar-mac.jar update $AR $ARMAC");
system("java -jar ifmapcli/auth-by.jar update $AR $PDP");
system("java -jar ifmapcli/auth-as.jar update $AR $USER");