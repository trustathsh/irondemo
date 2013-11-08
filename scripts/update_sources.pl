#!/usr/bin/perl
#--------------------------------------
# name: update_sources.pl
# version 0.12
# date 11-06-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;
use File::Basename;
use File::Spec;
use YAML qw/LoadFile/;

my ($config_fh, $config_file, $config_directory, $project_directory, $scripts_directory, $sources_directory);
my (%return);

$project_directory = File::Spec->rel2abs(File::Spec->updir, dirname(__FILE__));
$scripts_directory = File::Spec->catdir($project_directory, 'scripts');
$sources_directory = File::Spec->catdir($project_directory, 'sources');
$config_directory  = File::Spec->catdir($project_directory, 'config');
$config_file       = File::Spec->catfile($config_directory, 'projects.yaml');

mkdir($sources_directory) unless (-d $sources_directory); 

open($config_fh, '<', "$config_file") or die "Could not open config file $config_file: $! \n";

my $config = LoadFile($config_fh);

for my $project (keys %$config) {
	my $scm = $config->{$project}->{sources}->{scm};
	my $url = $config->{$project}->{sources}->{uri};

	print "\n\n";
	print "||||| Looking for source directory of: $project |||||\n";

	unless (-d File::Spec->catdir($sources_directory, $project)) {
		print "Source directory not found, checking out sources from $scm. \n";
		chdir($sources_directory) or die "Could not change directory: $! \n";
		if ($scm =~ /git/) {
			$return{$project} = system("git clone $url");
		} elsif ($scm =~ /svn/) {
			$return{$project} = system("svn co $url");
		} else {
			print "Unknown source control: $scm. Doing nothing. \n";
			$return{$project} = -1;			
		}
	} else {
		print "Source directory found, updating sources from $scm. \n";
		chdir(File::Spec->catdir($sources_directory, $project)) or die "Could not change directory: $! \n";
		if ($scm =~ /git/) {
			$return{$project} = system("git pull");
		} elsif ($scm =~ /svn/) {
			$return{$project} = system("svn up");
		} else {
			print "Unknown source control: $scm. Doing nothing. \n";
			$return{$project} = -1;
		}
	}
}
close $config_fh;

for my $project (keys %return) {
	if($return{$project} != 0){
		warn "ERROR! Retrieving sources of project " . $project . " failed! \n";
	} else {
		print "Retrieving sources of project " . $project . " succedeed. \n";
	}
}
