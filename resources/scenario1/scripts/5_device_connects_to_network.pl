#!/usr/bin/perl
#--------------------------------------
# name: device_connects_to_network.pl
# version 0.12
# date 11-08-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;
use File::Spec;
use File::Basename;

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

my $AR = '111:33';
my $ARMAC = 'aa:bb:cc:dd:ee:ff';
my $ARIP = '10.0.0.1';
my $PDP = 'pdp1';
my $USER = 'Bob';
my $DEVICE = 'device1';
my $TYPE = 'arbitrary';

$ENV{'IFMAP_USER'} = 'sensor';
$ENV{'IFMAP_PASS'} = 'sensor';

# create device
system("java -jar ar-dev.jar update $AR $DEVICE");

# create categories and features
system("java -jar feature2.jar -i $DEVICE");

my $FEATURE_1 = 'smartphone.android.app:11.permission:0.Name';
my $VALUE_1 = 'RECEIVE_BOOT_COMPLETED';

my $FEATURE_2 = 'smartphone.android.app:11.permission:1.Name';
my $VALUE_2 = 'CAMERA';

my $FEATURE_3 = 'smartphone.android.app:11.permission:2.Name';
my $VALUE_3 = 'INTERNET';

system("java -jar featureSingle.jar -d $DEVICE -i $FEATURE_1 -t $TYPE -v $VALUE_1 -u");
system("java -jar featureSingle.jar -d $DEVICE -i $FEATURE_2 -t $TYPE -v $VALUE_2 -u");
system("java -jar featureSingle.jar -d $DEVICE -i $FEATURE_3 -t $TYPE -v $VALUE_3 -u");