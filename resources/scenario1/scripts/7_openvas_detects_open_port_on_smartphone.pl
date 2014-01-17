#!/usr/bin/perl
#--------------------------------------
# name: openvas_detects_open_port_on_smartphone.pl
# version 0.13
# date 17-01-2014
# Trust@HsH
#--------------------------------------

use strict;
use warnings;
use File::Spec;
use File::Basename;

my $AR = '111:33';
my $ARMAC = 'aa:bb:cc:dd:ee:ff';
my $ARIP = '10.0.0.1';
my $PDP = 'freeradius-pdp';
my $USER = 'Bob';
my $FEATURE = 'vulnerability-scan-result.vulnerability.port';
my $TYPE = 'arbitrary';
my $VALUE = '22';
my $DEVICE = 'android-smartphone';

$ENV{'IFMAP_USER'} = 'ironvas';
$ENV{'IFMAP_PASS'} = 'ironvas';

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

system("java -jar featureSingle.jar -d $DEVICE -i $FEATURE -t $TYPE -v $VALUE -u");
