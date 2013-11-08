#!/usr/bin/perl
#--------------------------------------
# name: 3a_start_irongui.pl
# version 0.1
# date 19-08-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

# get project dir
opendir(SOURCES, ".") || die "Could not open directory.";

my $project = "irongui-";
my @project_dir = grep {/^$project/} readdir(SOURCES);

closedir(SOURCES) || die "Could not close directory.";;

if(@project_dir > 1){
  print "Warning, too mutch projekt with $project was found!\n";
  exit;
}elsif(@project_dir < 1){
  print "Warning, no projekt with $project was found!\n";
  exit;
}

# run project
if(chdir($project_dir[0]) != 1){
  print "ERROR: Projekt dir $project_dir[0] not exist\n";
  exit;
}

my $pid = fork();

if($pid == 0){
  system('./start.sh');
}