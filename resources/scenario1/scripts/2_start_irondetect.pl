#!/usr/bin/perl
#--------------------------------------
# name: 2_start_irondetect.pl
# version 0.1
# date 19-08-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

my $project = 'irondetect-';
my $start_script = 'start.sh';

# get project dir
opendir(SOURCES, ".") || die "Could not open directory.";
my @project_dir = grep {/^$project/} readdir(SOURCES);

closedir(SOURCES) || die "Could not close directory.";;

if(@project_dir > 1){
  print "Warning, too mutch projekt with $project was found!\n";
  exit;
}elsif(@project_dir < 1){
  print "Warning, no projekt with $project was found!\n";
  exit;
}

# switch to project dir
if(chdir($project_dir[0]) != 1){
  print "[$0] ERROR: Projekt dir $project_dir[0] not exist\n";
  exit;
}

# run project in new console
my $pid = fork();

if($pid == 0){
  system('xterm -T ' . $project_dir[0] . ' -e ./'.$start_script);
}