#!/usr/bin/perl
#--------------------------------------
# name: build_sources.pl
# version 0.11
# date 11-06-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;
use File::Basename;
use File::Spec;

my ($config_fh, $project_directory, $scripts_directory, $sources_directory, $config_directory, $config_file);
my %return;

$project_directory = File::Spec->rel2abs(File::Spec->updir, dirname(__FILE__));
$scripts_directory = File::Spec->catdir($project_directory, 'scripts');
$sources_directory = File::Spec->catdir($project_directory, 'sources');
$config_directory  = File::Spec->catdir($project_directory, 'config');
$config_file       = File::Spec->catfile($config_directory, 'build.conf');

open($config_fh, '<', "$config_file") or die "Could not open config file $config_file: $! \n";

while(<$config_fh>){
	next if /^#/;
	
	my @commands = split(/;/,$_);
	my $project = shift @commands;
	
	print "\n\n";
	print "||||| Looking for source directory of: $project |||||\n";
	
	if (-d File::Spec->catdir($sources_directory, $project)) {
		print "Source directory found, building sources. \n";
		chdir(File::Spec->catdir($sources_directory, $project)) or die "Could not change directory: $! \n";
		for (@commands){
			$return{$project} = system($_);
		}
	} else {
		print "Source directory not found, doing nothing. \n";
		$return{$project} = -1
	}
}
close $config_fh;


for my $project (keys %return) {
	if($return{$project} != 0){
		warn "WARNING! Build of project " . $project . " failed! \n";
	} else {
		print "Build of project " . $project . " succedeed. \n";
	}
}
