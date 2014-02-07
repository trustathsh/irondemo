#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use File::Spec;
use YAML qw/LoadFile/;
use File::Copy;
use File::Copy::Recursive qw/dircopy/;
use Archive::Extract;
use Getopt::Long;
use Pod::Usage;
use File::Path qw/remove_tree make_path/;

use FindBin;
use lib "$FindBin::Bin/lib/TrustAtHsH-Irondemo/lib";
use TrustAtHsH::Irondemo;

#imports for developement
use Data::Dumper;

our $VERSION = '0.2';

#process commandline options
my %options;
Getopt::Long::Configure( 'gnu_getopt', 'auto_help', 'auto_version' );
GetOptions( \%options, 'clean', 'man', 'agenda=s', 'threadpool-size=i');

pod2usage( -exitval => 0, -verbose => 2 ) if $options{'man'};

#initialize files and paths
my (
	$projects_conf_file, $config_dir,  $resources_dir, $scenarios_dir,
	$project_dir, $scripts_dir, $sources_dir, $modules_conf_file,
);
$project_dir        = File::Spec->rel2abs( File::Spec->updir, dirname(__FILE__) );
$scripts_dir        = File::Spec->catdir( $project_dir, 'scripts' );
$sources_dir        = File::Spec->catdir( $project_dir, 'sources' );
$scenarios_dir      = File::Spec->catdir( $project_dir, 'scenarios' );
$resources_dir      = File::Spec->catdir( $project_dir, 'resources' );
$config_dir         = File::Spec->catdir( $project_dir, 'config' );
$projects_conf_file = File::Spec->catfile( $config_dir, 'projects.yaml' );
$modules_conf_file  = File::Spec->catfile( $config_dir, 'modules.yaml' );

mkdir($sources_dir)   unless ( -d $sources_dir );
mkdir($scenarios_dir) unless ( -d $scenarios_dir );

#read projects config file
my $projects_conf_fh;
open( $projects_conf_fh, '<', "$projects_conf_file" ) or die "Could not open config file $projects_conf_file: $! \n";
my $projects_config = LoadFile($projects_conf_fh);
close $projects_conf_fh;

#read modules config file
my $modules_conf_fh;
open( $modules_conf_fh, '<', "$modules_conf_file" ) or die "Could not open config file $modules_conf_file: $! \n";
my $modules_config = LoadFile($modules_conf_fh);
close $modules_conf_fh;


#dispatch command
my $command = shift;
my @targets = @ARGV;
pod2usage(1) unless defined $command;

my %return;
if    ( $command eq 'update' )       {
	%return = update_sources();
}
elsif ( $command eq 'build' )        {
	%return = build_sources();
}
elsif ( $command eq 'scenario' )     {
	%return = build_scenarios();
}
elsif ( $command eq 'run_scenario' ) {
	if ( @targets < 1) {
		die "ERROR! run_scenario must be called with at least one argument";
	}
	run_scenario();
}
else {
	pod2usage(1);
}

for my $project ( keys %return ) {
	if ( $return{$project} != 0 ) {
		warn "ERROR! Processing " . $project . " failed! \n";
	}
	else {
		print "Processing " . $project . " succeedeed. \n";
	}
}

sub update_sources {

	#if no project was supplied on the commandline, let's update all of them
	if ( @targets < 1 ) {
		@targets = keys %$projects_config;
	}

	for my $project (@targets) {
		unless ( $projects_config->{$project} ) {
			warn "Sorry, dont know $project, skipping ... \n";
			next;
		}

		my $scm = $projects_config->{$project}->{sources}->{scm};
		my $url = $projects_config->{$project}->{sources}->{uri};
		clean( File::Spec->catdir( $sources_dir, $project ) );

		print "\n\n";
		print "||||| Looking for source directory of: $project |||||\n";

		unless ( -d File::Spec->catdir( $sources_dir, $project ) ) {
			print "Source directory not found, checking out sources from $scm. \n";
			chdir($sources_dir) or die "Could not change directory: $! \n";
			if ( $scm =~ /git/ ) {
				$return{$project} = system("git clone $url");
			}
			elsif ( $scm =~ /svn/ ) {
				$return{$project} = system("svn co $url");
			}
			else {
				print "Unknown source control: $scm. Doing nothing. \n";
				$return{$project} = -1;
			}
		}
		else {
			print "Source directory found, updating sources from $scm. \n";
			chdir( File::Spec->catdir( $sources_dir, $project ) )
			  or die "Could not change directory: $! \n";
			if ( $scm =~ /git/ ) {
				$return{$project} = system("git pull");
			}
			elsif ( $scm =~ /svn/ ) {
				$return{$project} = system("svn up");
			}
			else {
				print "Unknown source control: $scm. Doing nothing. \n";
				$return{$project} = -1;
			}
		}
	}
	return %return;
}    #end update_sources

sub build_sources {

	#if no project was supplied on the commandline, let's build all of them
	if ( @targets < 1 ) {
		@targets = keys %$projects_config;
	}
	for my $project (@targets) {
		my @commands = @{ $projects_config->{$project}->{build}->{commands} };

		print "\n\n";
		print "||||| Looking for source directory of: $project |||||\n";

		if ( -d File::Spec->catdir( $sources_dir, $project ) ) {
			print "Source directory found, building sources. \n";
			chdir( File::Spec->catdir( $sources_dir, $project ) )
			  or die "Could not change directory: $! \n";
			if ( $options{clean} ) {
				if ( $projects_config->{$project}->{build}->{tool} =~ /mvn/ ) {
					system 'mvn clean';
				}
			}
			for my $command (@commands) {
				$return{$project} = system($command);
			}
		}
		else {
			print "Source directory not found, doing nothing. \n";
			$return{$project} = -1;
		}
	}
	return %return;
}    #end build_sources

sub build_scenarios {

	#iterate over the scenarios
	for my $scenario (@targets) {
		my (
			$scenario_config_fh, $scenario_config,        $scenario_config_file,
			$scenario_dir,       $scenario_resources_dir, $build_dir
		);
		$scenario_dir           = File::Spec->catdir( $scenarios_dir, $scenario );
		$scenario_resources_dir = File::Spec->catdir( $resources_dir, $scenario );
		$scenario_config_file = File::Spec->catfile( $config_dir, $scenario . '.yaml' );

		#read scenario configuration file
		unless ( open( $scenario_config_fh, '<', $scenario_config_file ) ) {
			warn
			  "Could not open config file for scenario $scenario in $scenario_config_file: $! \n";
			print "Skipping $scenario \n";
			next;
		}
		$scenario_config = LoadFile($scenario_config_fh);

		#remove old scenario dir if called with --clean
		clean($scenario_dir);

		#iterate over each project that is part of the scenario
		for my $project ( @{ $scenario_config->{projects} } ) {
			my $id = $project->{id};

			print "$id \n";

			#figure out which binary/archive to use
			if ( $projects_config->{$id}->{binaries}->{path} ) {
				$build_dir =
				  File::Spec->catdir( $sources_dir, $id, $projects_config->{$id}->{binaries}->{path} );
			}
			else {
				$build_dir = File::Spec->catdir( $sources_dir, $id, 'target' );
			}
			opendir( TARGET, $build_dir );
			my @archives = grep( /$id.*-bundle.zip$/, readdir(TARGET) );
			if ( @archives > 1 ) {
				print "Cannot figure out which archive to use. Candidates: @archives";
				next;
			}

			#copy/extract binary/archive to scenario dir
			my $archive = File::Spec->rel2abs( File::Spec->catfile( $build_dir, $archives[0] ) );
			my $ae = Archive::Extract->new( archive => $archive );
			$ae->extract( to => $scenario_dir );
			my $extract_path = $ae->extract_path;

			#copy and additional files to scenario dir
			if ( $project->{files} ) {
				for my $file ( @{ $project->{files} } ) {
					my $source = File::Spec->catfile( $scenario_resources_dir, $file->{source} );
					my $destination = File::Spec->catdir( $extract_path, $file->{destination} );
					copy( $source, $destination ) or die "Cannot copy $source to $destination: $!";
				}
			}
		}    #end projects for

		# copy scenario files
		if ( $scenario_config->{files} ) {
			for my $file ( @{ $scenario_config->{files} } ) {
				my $source = File::Spec->catfile( $scenario_resources_dir, $file->{source} );
				my $destination = File::Spec->catdir( $scenario_dir, $file->{destination} );
				copy( $source, $destination ) or die "Cannot copy $source to $destination: $!";
			}
		}

		# copy scenario dirs
		if ( $scenario_config->{directories} ) {
			for my $dir ( @{ $scenario_config->{directories} } ) {
				my $source = File::Spec->catdir( $scenario_resources_dir, $dir->{source} );
				my $destination =
				  File::Spec->catdir( $scenario_dir, $dir->{destination},
					basename( $dir->{source} ) );
				dircopy( $source, $destination ) or die "Cannot copy $source to $destination: $!";
			}
		}

		# execute scenario scripts
		if ( $scenario_config->{execute} ) {
			for my $executable ( @{ $scenario_config->{execute} } ) {
				system( File::Spec->catfile( $scenario_resources_dir, $executable ) );
			}
		}

	}    #end scenarios for
	return %return;
}    #end build_scenarios

sub run_scenario {
	for my $scenario (@targets) {
		my (
			$scenario_config_fh, $scenario_config,        $scenario_config_file,
			$scenario_dir,       $scenario_resources_dir, $build_dir
		);
		$scenario_dir           = File::Spec->catdir( $scenarios_dir, $scenario );
		$scenario_resources_dir = File::Spec->catdir( $resources_dir, $scenario );
		$scenario_config_file = File::Spec->catfile( $config_dir, $scenario . '.yaml' );
		
		my $agenda = $options{'agenda'} || 'agenda.txt';
		TrustAtHsH::Irondemo->run_agenda({
			'agenda_path'    => File::Spec->catfile($scenario_dir, $agenda),
			'modules_config' => $modules_config,
			'threadpool_size' => $options{'threadpool-size'},
		});
	}
}

sub clean {
	my $dir = shift;
	if ( $options{clean} and -d $dir ) {
		remove_tree( $dir, { keep_root => '0', safe => '0' } );
		make_path($dir);
	}
}

=head1 NAME

irondemo

=head1 SYNOPSIS

irondemo.pl [options] <update|build|scenario> [targets]

	Options:
	-?, -help         print this message
	--man             print long manual
	--clean           remove (old) target before execution

=head1 OPTIONS

=over 10

=item B<?,--help>

Prints a brief help message and exits.

=item B<--clean>

Removes the (old) target before execution.

=item B<--man>

Prints this manpage.

=back

=head1 DESCRIPTION

B<irondemo> builds different scenarios/demo environments for the iron* software suite, various IF-MAP tools developed by the Trust@FHH research group at Hochschule Hannover (Hannover University of Applied Sciences and Arts).

B<NOTE:> This is an alpha-release - might still contain a couple of bugs.

=head1 AUTHORS

Developed by the Trust@HSH research group (see http://trust.f4.hs-hannover.de/). Use trust@f4-i.fh-hannover.de to get in touch.

=head2 Main contributors:

=over 8

=item Marcel Reichenbach

=item Thomas Rossow

=back

=head1 LICENSE

=====================================================
  _____                _     ____  _   _       _   _
 |_   _|_ __ _   _ ___| |_  / __ \| | | | ___ | | | |
   | | | '__| | | / __| __|/ / _` | |_| |/ __|| |_| |
   | | | |  | |_| \__ \ |_| | (_| |  _  |\__ \|  _  |
   |_| |_|   \__,_|___/\__|\ \__,_|_| |_||___/|_| |_|
                            \____/

=====================================================

Hochschule Hannover
(University of Applied Sciences and Arts, Hannover)
Faculty IV, Dept. of Computer Science
Ricklinger Stadtweg 118, 30459 Hannover, Germany

Email: trust@f4-i.fh-hannover.de
Website: http://trust.f4.hs-hannover.de/

This file is part of irondemo, implemented by the Trust@HsH
research group at the Hochschule Hannover.


Copyright (C) 2013,2014 Trust@HSH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut
