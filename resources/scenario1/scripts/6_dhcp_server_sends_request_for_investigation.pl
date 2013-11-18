#!/usr/bin/perl
#--------------------------------------
# name: dhcp_server_sends_request_for_investigation.pl
# version 0.12
# date 26-06-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;
use File::Spec;
use File::Basename;

my $AR = '111:33';
my $ARMAC = 'aa:bb:cc:dd:ee:ff';
my $ARIP = '10.0.0.1';
my $PDP = 'pdp1';
my $USER = 'Bob';
my $QUALIFIER = 'vulnerability-scan';
my $DEVICE = 'device1';

$ENV{'IFMAP_USER'} = 'dhcp';
$ENV{'IFMAP_PASS'} = 'dhcp';

my $project = 'ifmapcli-distribution';
my $scenario_dir = File::Spec->rel2abs(File::Spec->updir, dirname(__FILE__));

opendir(SCENARIO, $scenario_dir)
	or die "Could not open directory $scenario_dir: $! \n";
	
my @dirs = grep {/^$project/} readdir(SCENARIO);

unless (@dirs == 1){
  die "ERROR, cannot find directory for $project!\n";
}

my $ifmapcli_dir = File::Spec->catdir($scenario_dir, $dirs[0]);
chdir($ifmapcli_dir) or die "Could not open directory $ifmapcli_dir: $! \n";

system("java -jar req-inv.jar update $DEVICE $ARIP $QUALIFIER");