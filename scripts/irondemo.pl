#!/usr/bin/perl
#--------------------------------------
# name: irondemo.pl
# version 0.2
# date 11-06-2013
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
use Getopt::Long;
use Pod::Usage;
use File::Path qw/remove_tree make_path/;

our $VERSION = '0.2';

#process commandline options
my %options;
Getopt::Long::Configure( 'gnu_getopt', 'auto_help', 'auto_version' );
GetOptions( \%options, 'clean', 'man' );

pod2usage( -exitval => 0, -verbose => 2 ) if $options{'man'};

#initialize files and paths
my (
	$config_file, $config_dir,  $resources_dir, $scenarios_dir,
	$project_dir, $scripts_dir, $sources_dir
);
$project_dir = File::Spec->rel2abs( File::Spec->updir, dirname(__FILE__) );
$scripts_dir   = File::Spec->catdir( $project_dir, 'scripts' );
$sources_dir   = File::Spec->catdir( $project_dir, 'sources' );
$scenarios_dir = File::Spec->catdir( $project_dir, 'scenarios' );
$resources_dir = File::Spec->catdir( $project_dir, 'resources' );
$config_dir    = File::Spec->catdir( $project_dir, 'config' );
$config_file = File::Spec->catfile( $config_dir, 'projects.yaml' );

mkdir($sources_dir)   unless ( -d $sources_dir );
mkdir($scenarios_dir) unless ( -d $scenarios_dir );

#read config file
my $config_fh;
open( $config_fh, '<', "$config_file" ) or die "Could not open config file $config_file: $! \n";
my $config = LoadFile($config_fh);

#close $config_fh;

#dispatch command
my $command = shift;
my @targets = @ARGV;

my %return;
if ( $command eq 'update' ) {
	%return = update_sources();
}
elsif ( $command eq 'build' ) {
	%return = build_sources();
}
elsif ( $command eq 'scenario' ) {
	%return = build_scenarios();
}
else {
	pod2usage(1);
}

for my $project ( keys %return ) {
	if ( $return{$project} != 0 ) {
		warn "ERROR! Retrieving sources of project " . $project . " failed! \n";
	}
	else {
		print "Retrieving sources of project " . $project . " succeedeed. \n";
	}
}

sub update_sources {

	#if no project was supplied on the commandline, let's update all of them
	if ( @targets < 1 ) {
		@targets = keys %$config;
	}

	for my $project (@targets) {
		unless ( $config->{$project} ) {
			warn "Sorry, dont know $project, skipping ... \n";
			next;
		}

		my $scm = $config->{$project}->{sources}->{scm};
		my $url = $config->{$project}->{sources}->{uri};
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
		@targets = keys %$config;
	}
	for my $project (@targets) {
		my @commands = @{ $config->{$project}->{build}->{commands} };

		print "\n\n";
		print "||||| Looking for source directory of: $project |||||\n";

		if ( -d File::Spec->catdir( $sources_dir, $project ) ) {
			print "Source directory found, building sources. \n";
			chdir( File::Spec->catdir( $sources_dir, $project ) )
			  or die "Could not change directory: $! \n";
			if ( $options{clean} ) {
				if ( $config->{$project}->{build}->{tool} =~ /mvn/ ) {
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
			if ( $config->{$id}->{binaries}->{path} ) {
				$build_dir =
				  File::Spec->catdir( $sources_dir, $id, $config->{$id}->{binaries}->{path} );
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

=cut
