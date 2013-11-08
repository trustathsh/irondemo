#!/usr/bin/perl
#--------------------------------------
# name: build_scenarios.pl
# version 0.12
# date 11-08-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;
use File::Basename;
use File::Spec;
use YAML qw/LoadFile/;
use File::Copy;
use File::Copy::Recursive qw/dircopy/;
use Archive::Extract;

my ($scenario, $project_dir, $scenario_dir, $sources_dir, $resources_dir, $config_dir, $config_file);

usage() if @ARGV < 1;

$scenario = $ARGV[0];

$project_dir   = File::Spec->rel2abs(File::Spec->updir, dirname(__FILE__));
$scenario_dir  = File::Spec->catdir($project_dir, File::Spec->catdir('scenarios', $scenario));
$sources_dir   = File::Spec->catdir($project_dir, 'sources');
$resources_dir = File::Spec->catdir($project_dir, 'resources', $scenario);
$config_dir    = File::Spec->catdir($project_dir, 'config');
$config_file   = $scenario . '.yaml';

my $project_configurations = load_configuration('projects.yaml');
my $config = load_configuration($config_file);

for my $project (@{$config->{projects}}) {
	my $id = $project->{id};

	my $build_dir; 
	if ($project_configurations->{$id}->{binaries}->{path}) {
		$build_dir = File::Spec->catdir($sources_dir, $id, $project_configurations->{$id}->{binaries}->{path});
	} else {
		$build_dir = File::Spec->catdir($sources_dir, $id, 'target');
	}
	
	print "$build_dir \n";
	
	opendir(TARGET, $build_dir);
	my @archives = grep(/$id.*-bundle.zip$/, readdir(TARGET));
	if (@archives > 1) {
		print "Cannot figure out which archive to use. Candidates: @archives";
		next;
	}
	my $archive = File::Spec->rel2abs(File::Spec->catfile($build_dir, $archives[0]));
	my $ae = Archive::Extract->new(archive => $archive);
	$ae->extract( to => $scenario_dir );
	my $extract_path = $ae->extract_path;

	if ($project->{files}) {
		for my $file (@{$project->{files}}) {
			my $source =      File::Spec->catfile($resources_dir, $file->{source});
			my $destination = File::Spec->catdir($extract_path, $file->{destination});
			copy($source, $destination) or die "Cannot copy $source to $destination: $!";
		}
	}
}

if ($config->{files}) {
	for my $file (@{$config->{files}}) {
		my $source =      File::Spec->catfile($resources_dir, $file->{source});
		my $destination = File::Spec->catdir($scenario_dir, $file->{destination});
		copy($source, $destination) or die "Cannot copy $source to $destination: $!";
	}
}

if ($config->{directories}) {
	for my $dir (@{$config->{directories}}) {
		my $source =      File::Spec->catdir($resources_dir, $dir->{source});
		my $destination = File::Spec->catdir($scenario_dir, $dir->{destination}, basename($dir->{source}));
		dircopy($source, $destination) or die "Cannot copy $source to $destination: $!";
	}
}

if ($config->{execute}) {
	for my $executable (@{$config->{execute}}) {
		system (File::Spec->catfile($resources_dir, $executable));
	}
}

sub usage {
	die "usage: $0 <scenario> \n";
}

sub load_configuration {
	my $file = shift;
	my $project_dir   = File::Spec->rel2abs(File::Spec->updir, dirname(__FILE__));
	my $config_file   = File::Spec->catfile($project_dir, 'config', $file);
	open my $config_fh, '<', $config_file or die "Cannot open config file: $!";
	return LoadFile($config_fh);
}
