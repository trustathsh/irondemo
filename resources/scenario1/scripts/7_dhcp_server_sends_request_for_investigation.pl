#!/usr/bin/perl
#--------------------------------------
# name: 7_dhcp_server_sends_request_for_investigation.pl
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
my $QUALIFIER = 'vulnerability-scan';
my $DEVICE = 'device1';

$ENV{'IFMAP_USER'} = 'dhcp';
$ENV{'IFMAP_PASS'} = 'dhcp';

system("java -jar ifmapcli/req-inv.jar update $DEVICE $ARIP $QUALIFIER");