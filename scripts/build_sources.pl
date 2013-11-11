#!/usr/bin/perl
#--------------------------------------
# name: build_sources.pl
# version 0.12
# date 11-08-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;
use File::Basename;
use File::Spec;
use YAML qw/LoadFile/;
use Getopt::Long;

#global vars
my ($config_fh, $project_directory, $scripts_directory, $sources_directory, $config_directory, $config_file);
my %return;

#commandline options
my ($clean, $help);

GetOptions ('clean' => \$clean, 'help' => \$help);

usage() if $help;

$project_directory = File::Spec->rel2abs(File::Spec->updir, dirname(__FILE__));
$scripts_directory = File::Spec->catdir($project_directory, 'scripts');
$sources_directory = File::Spec->catdir($project_directory, 'sources');
$config_directory  = File::Spec->catdir($project_directory, 'config');
$config_file       = File::Spec->catfile($config_directory, 'projects.yaml');

open($config_fh, '<', "$config_file") or die "Could not open config file $config_file: $! \n";

my $config = LoadFile($config_fh);

for my $project (keys %$config) {
	my @commands = @{$config->{$project}->{build}->{commands}};
	
	print "\n\n";
	print "||||| Looking for source directory of: $project |||||\n";
	
	if (-d File::Spec->catdir($sources_directory, $project)) {
		print "Source directory found, building sources. \n";
		chdir(File::Spec->catdir($sources_directory, $project)) or die "Could not change directory: $! \n";
		if ($clean) {
			if ($config->{$project}->{build}->{tool} =~ /mvn/) {
				system 'mvn clean';
			}
		}
		for my $command (@commands){
			$return{$project} = system($command);
		}
	} else {
		print "Source directory not found, doing nothing. \n";
		$return{$project} = -1
	}
}
close $config_fh;


for my $project (keys %return) {
	if($return{$project} != 0){
		warn "ERROR! Build of project " . $project . " failed! \n";
	} else {
		print "Build of project " . $project . " succeedeed. \n";
	}
}

sub usage {
	die "usage: $0 [project] \n";
}