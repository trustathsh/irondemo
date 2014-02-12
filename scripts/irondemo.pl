#!/usr/bin/perl

use strict;
use warnings;
use File::Spec;
use Getopt::Long;
use File::Basename;
use Pod::Usage;

use FindBin;
use lib "$FindBin::Bin/lib/TrustAtHsH-Irondemo/lib";
use TrustAtHsH::Irondemo;

use Data::Dumper;

our $VERSION = '0.2';

#process commandline options
my %options;
Getopt::Long::Configure( 'gnu_getopt', 'auto_help', 'auto_version' );
GetOptions( \%options, 'clean', 'man', 'agenda=s', 'threadpool-size=i', 'timescale=i');

pod2usage( -exitval => 0, -verbose => 2 ) if $options{'man'};

#initialize files and paths
my (
	$config_dir,  $resources_dir, $scenarios_dir,
	$project_dir, $sources_dir, $scenarios_conf_dir,
);

$project_dir        = File::Spec->rel2abs( File::Spec->updir, dirname(__FILE__) );
$sources_dir        = File::Spec->catdir( $project_dir, 'sources' );
$scenarios_dir      = File::Spec->catdir( $project_dir, 'scenarios' );
$resources_dir      = File::Spec->catdir( $project_dir, 'resources' );
$config_dir         = File::Spec->catdir( $project_dir, 'config' );
$scenarios_conf_dir = File::Spec->catdir( $config_dir, 'scenarios');

mkdir($sources_dir)   unless ( -d $sources_dir );
mkdir($scenarios_dir) unless ( -d $scenarios_dir );

#dispatch command
my $command = shift;
my @targets = @ARGV;
pod2usage(1) unless defined $command;


my $irondemo = TrustAtHsH::Irondemo->new({
	resources_dir      => $resources_dir,
	scenarios_dir      => $scenarios_dir,
	scenarios_conf_dir => $scenarios_conf_dir,
	sources_dir        => $sources_dir,
	config_dir         => $config_dir,
	threadpool_size    => $options{threadpool_size},
	timescale          => $options{timescale},
});

if    ( $command eq 'update' )       {
	exit( update_sources( @targets ) );
}
elsif ( $command eq 'build' )        {
	build_sources(@targets);
}
elsif ( $command eq 'scenario' )     {
	build_scenarios(@targets);
}
elsif ( $command eq 'run_scenario' ) {
	if ( @targets != 1) {
		die "ERROR! run_scenario must be called with one argument";
	}
	run_scenario(@targets);
} else {
	pod2usage(1);
}

sub update_sources {
	my @projects = @_;
	my $return_val = 0;

	if ( @projects < 1 ) {
		@projects = $irondemo->get_projects();
	}	
	for my $project (@projects) {
		$return_val |= $irondemo->update_project({
			project_id => $project,
			clean      => $options{clean},
		});
	}
	
	return $return_val;
}

sub build_sources {
	my @projects = @_;
	my $return_val = 0;

	if ( @projects < 1 ) {
		@projects = $irondemo->get_projects();
	}
	for my $project ( @projects ) {
		$return_val |= $irondemo->build_project({
			project_id => $project,
			clean      => $options{clean},
		});
	}
	
	return $return_val;
}

sub build_scenarios {
	my @scenarios = @_;
	my $return_val = 0;
	
	if ( @scenarios < 1 ) {
		@scenarios = $irondemo->get_scenarios();
	}
	for my $scenario ( @scenarios ) {
		$return_val |= $irondemo->build_scenario({
			scenario => $scenario,
			clean    => $options{clean}
		});
	}
	
	return $return_val;
}

sub run_scenario {
	my $scenario   = shift;
	my $return_val = 0;
	my $agenda     = $options{agenda} || 'agenda.txt';
	
	print "$agenda \n";
	$return_val = $irondemo->run_scenario({
		scenario => $scenario,
		agenda   => $agenda,
	});
	
	return $return_val;
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
