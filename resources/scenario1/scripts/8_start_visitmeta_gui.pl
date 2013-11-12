#!/usr/bin/perl
#--------------------------------------
# name: start_visitmeta_gui.pl
# version 0.12
# date 11-08-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;
use File::Spec;
use File::Basename;


my $project = 'visitmeta';
my $start_script = 'start.sh';

my $scenario_dir = File::Spec->rel2abs(File::Spec->updir, dirname(__FILE__));

opendir(SCENARIO, $scenario_dir)
	or die "Could not open directory $scenario_dir: $! \n";
	
my @dirs = grep {/^$project-/} readdir(SCENARIO);

unless (@dirs == 1){
  die "ERROR, cannot find directory for $project!\n";
}

my $iron_dir = File::Spec->catdir($scenario_dir, $dirs[0]);
chdir($iron_dir) or die "Cannot change to $iron_dir: $!";

my $os = $^O;
if ($os eq 'linux' or $os eq 'darwin') {
	my $start_script = File::Spec->catfile($iron_dir, 'start-visualization.sh');
	system($start_script);
} elsif ($os eq 'MSWin32') {
	my $start_script = File::Spec->catfile($iron_dir, 'start-visualization.bat');
	system($start_script);
}