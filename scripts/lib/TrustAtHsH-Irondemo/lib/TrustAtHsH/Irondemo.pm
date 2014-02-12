package TrustAtHsH::Irondemo;

use 5.006;
use strict;
use warnings;

use lib '..';
use TrustAtHsH::Irondemo::AgendaParser;
use TrustAtHsH::Irondemo::Executor;
use TrustAtHsH::Irondemo::ModuleFactory;
use File::Basename;
use Archive::Extract;
use Try::Tiny;
use Carp;
use Log::Log4perl qw(:easy);
use Storable qw(dclone);
use YAML qw/LoadFile/;
use File::Path qw/remove_tree make_path/;
use File::Spec;
use File::Copy;
use File::Copy::Recursive qw/dircopy/;

#for developement only
use Data::Dumper;

our $VERSION = '0.01';
my $VERBOSE = 1;
my $log     = Log::Log4perl->get_logger();

sub new {
	my $class = shift;
	my $args  = shift;
	my $self  = {};

	bless $self, $class;

	$self->_init_logging();
	$self->{timescale} = 1;
	while ( my ( $key, $value ) = each %$args ) {
		$self->{$key} = $value;
	}

	$self->{modules_conf} = $self->_read_yaml_file(
		File::Spec->catfile( $self->{config_dir}, 'modules.yaml' )
	);

	$self->{projects_conf} = $self->_read_yaml_file(
		File::Spec->catfile( $self->{config_dir}, 'projects.yaml' )
	);

	return $self;
}

sub get_projects {
	my $self = shift;

	return keys %{ $self->{projects_conf} };
}

sub get_scenarios {
	my $self               = shift;
	my $scenarios_conf_dir = $self->{scenarios_conf_dir};

	opendir( TARGET, $scenarios_conf_dir );
	my @scenarios = map { s/\.yaml$//; $_; } grep( /.*\.yaml/, readdir(TARGET) );

	return @scenarios;
}

sub update_project {
	my $self         = shift;
	my $project_id   = shift;
	my $sources_dir  = $self->{sources_dir};
	my $project_conf = $self->{projects_conf}->{$project_id};
	croak("Sorry, dont know $project_id") unless defined $project_conf;
	my $return_val;

	my $scm = $project_conf->{sources}->{scm};
	my $url = $project_conf->{sources}->{uri};

	#clean( File::Spec->catdir( $sources_dir, $project ) );

	$log->debug("Looking for source directory of: $project_id");

	unless ( -d File::Spec->catdir( $sources_dir, $project_id ) ) {
		$log->debug("Source directory not found, checking out sources from $scm. \n");
		chdir($sources_dir) or die "Could not change directory: $! \n";
		if ( $scm =~ /git/ ) {
			$return_val = system("git clone $url");
		}
		elsif ( $scm =~ /svn/ ) {
			$return_val = system("svn co $url");
		} else {
			$log->debug("Unknown source control: $scm. Doing nothing. \n");
			$return_val = -1;
		}
	}
	else {
		$log->debug("Source directory found, updating sources from $scm. \n");
		chdir( File::Spec->catdir( $sources_dir, $project_id ) )
		  or die "Could not change directory: $! \n";
		if ( $scm =~ /git/ ) {
			$return_val = system("git pull");
		}
		elsif ( $scm =~ /svn/ ) {
			$return_val = system("svn up");
		} else {
			$log->debug("Unknown source control: $scm. Doing nothing. \n");
			$return_val = -1;
		}
	}
}

sub build_project {
	my $self         = shift;
	my $opts         = shift;
	my $clean        = $opts->{clean};
	my $project_id   = $opts->{project_id};
	my $sources_dir  = $self->{sources_dir};
	my $project_conf = $self->{projects_conf}->{$project_id};
	my @commands     = @{ $project_conf->{build}->{commands} };
	croak("Sorry, dont know $project_id") unless defined $project_conf;
	my $return_val = 0;

	$log->debug("Looking for source directory of: $project_id");

	if ( -d File::Spec->catdir( $sources_dir, $project_id ) ) {
		$log->debug("Source directory found, building sources");
		chdir( File::Spec->catdir( $sources_dir, $project_id ) )
			or die "Could not change directory: $! \n";
		if ($clean) {
			if ( $project_conf->{build}->{tool} =~ /mvn/ ) {
				$return_val |= system('mvn clean');
			}
		}
		for my $command (@commands) {
			$return_val |= system($command);
		}
	} else {
		$log->debug("Source directory not found, doing nothing. \n");
		$return_val = -1;
	}
	return $return_val;
}

sub build_scenario {
	my $self                   = shift;
	my $opts                   = shift;
	my $scenario               = $opts->{scenario};
	my $clean                  = $opts->{clean};
	my $scenarios_conf_dir     = $self->{scenarios_conf_dir};
	my $scenarios_dir          = $self->{scenarios_dir};
	my $resources_dir          = $self->{resources_dir};
	my $sources_dir            = $self->{sources_dir};
	my $scenario_dir           = File::Spec->catdir( $scenarios_dir, $scenario );
	my $scenario_resources_dir = File::Spec->catdir( $resources_dir, $scenario );
	my $scenario_conf =
	  $self->_read_yaml_file( File::Spec->catdir( $scenarios_conf_dir, $scenario . '.yaml' ) );
	my $projects_conf = $self->{projects_conf};
	my ( $build_dir, $return_val );

	#clear scenario directory if called with 'clean'
	_clear_directory($scenario_dir) if $clean;

	#make sure scenario dir exists
	mkdir($scenario_dir) unless ( -d $scenario_dir );

	#iterate over each project that is part of the scenario
	for my $project ( @{ $scenario_conf->{projects} } ) {
		my $project_id   = $project->{id};
		my $project_conf = $projects_conf->{$project_id};
		my $project_dir  = File::Spec->catdir( $sources_dir, $project_id );

		#copy all directories
		if ( defined $project_conf->{binaries}->{directories} ) {
			my @directories = @{ $project_conf->{binaries}->{directories} };
			for my $directory (@directories) {
				my $source = File::Spec->catdir( $project_dir, $directory->{source}->{path} );
				if ( defined $directory->{source}->{match} ) {
					opendir( SOURCE, $source );
					my @match = grep( /$directory->{source}->{match}/, readdir(SOURCE) );
					$source = File::Spec->catdir( $source, $match[0] );
				}
				my $destination = File::Spec->catdir(
					$scenario_dir,
					$directory->{destination}->{path}
				);
				if ( defined $directory->{destination}->{rename} ) {
					$destination = File::Spec->catdir(
						$destination,
						$directory->{destination}->{rename}
					);
				} else {
					$destination = File::Spec->catdir(
						$destination,
						basename( $directory->{source}->{path} )
					);
				}
				dircopy( $source, $destination );
			}
		}

		#copy/extract all archives)
		if ( defined $project_conf->{binaries}->{archives} ) {
			my @archives = @{ $project_conf->{binaries}->{archives} };
			for my $archive (@archives) {
				my $source = File::Spec->catdir( $project_dir, $archive->{source}->{path} );
				if ( defined $archive->{source}->{match} ) {
					opendir( SOURCE, $source );
					my @match = grep( /$archive->{source}->{match}/, readdir(SOURCE) );
					$source = File::Spec->catdir( $source, $match[0] );
				}
				my $destination = File::Spec->catdir(
					$scenario_dir,
					$archive->{destination}->{path}
				);
				my $ae = Archive::Extract->new( archive => $source );
				$ae->extract( to => $destination );
				if ( defined $archive->{destination}->{rename} ) {
					my $rename_to = File::Spec->catdir(
						$scenario_dir,
						$archive->{destination}->{rename}
					);
					move( $ae->extract_path, $rename_to );
				}
			}
		}

		#copy all files
		if ( defined $project_conf->{binaries}->{files} ) {
			my @files = @{ $project_conf->{binaries}->{files} };
			for my $file (@files) {
				my $source = File::Spec->catdir( $project_dir, $file->{source}->{path} );
				if ( defined $file->{source}->{match} ) {
					opendir( SOURCE, $source );
					my @match = grep( /$file->{source}->{match}/, readdir(SOURCE) );
					$source = File::Spec->catdir( $source, $match[0] );
				}
				my $destination = File::Spec->catdir(
					$scenario_dir,
					$file->{destination}->{path}
				);
				if ( defined $file->{destination}->{rename} ) {
					$destination =
					  File::Spec->catdir( $destination, $file->{destination}->{rename} );
				}
				copy( $source, $destination );
			}
		}

		# copy scenario files
		if ( $scenario_conf->{files} ) {
			for my $file ( @{ $scenario_conf->{files} } ) {
				my $source = File::Spec->catfile( $scenario_resources_dir, $file->{source} );
				my $destination = File::Spec->catdir( 
					$scenario_dir, $file->{destination},
					basename( $file->{source} ),
				);
				copy( $source, $destination ) or die "Cannot copy $source to $destination: $!";
			}
		}

		# copy scenario dirs
		if ( $scenario_conf->{directories} ) {
			for my $dir ( @{ $scenario_conf->{directories} } ) {
				my $source = File::Spec->catdir( $scenario_resources_dir, $dir->{source} );
				my $destination = File::Spec->catdir( 
					$scenario_dir, $dir->{destination},
					basename( $dir->{source} ) 
				);
				dircopy( $source, $destination ) or die "Cannot copy $source to $destination: $!";
			}
		}

		# execute scenario scripts
		if ( $scenario_conf->{execute} ) {
			for my $executable ( @{ $scenario_conf->{execute} } ) {
				system( File::Spec->catfile( $scenario_resources_dir, $executable ) );
			}
		}
	}
}

sub run_scenario {
	my $self           = shift;
	my $opts           = shift;
	my $agenda         = $opts->{agenda};
	my $scenario       = $opts->{scenario};
	my $agenda_path    = File::Spec->catfile( $self->{scenarios_dir}, $scenario, $agenda );
	my $modules_config = $self->{modules_conf};
	my $timescale      = $opts->{timescale} || $self->{timescale};
	my %modules_aliases;

	while ( my ( $module, $params ) = each %$modules_config ) {
		my $alias = $params->{alias};
		$modules_aliases{$alias} = $module if defined $alias;
	}

	$log->debug("Calling AgendaParser ...");
	my @data = TrustAtHsH::Irondemo::AgendaParser->new( { path => $agenda_path, } )->get_actions();

	# group the actions by time
	my %groupedActions;
	for my $action (@data) {
		my $time = $action->{time};
		if ( defined $groupedActions{$time} ) {
			push @{ $groupedActions{$time} }, $action;
		}
		else {
			$groupedActions{$time} = [$action];
		}
	}

	my $executor =
	  TrustAtHsH::Irondemo::Executor->new( { threadpool_size => $opts->{threadpool_size} } );

	my $currentTime = 0;
	while (%groupedActions) {
		my @jobs;
		if ( defined $groupedActions{$currentTime} ) {
			my @currentActions = @{ $groupedActions{$currentTime} };
			my $actionCount    = @currentActions;
			$log->info( "Executing " . $actionCount . " actions at $currentTime" );

			# execute actions for this timestamp
			for my $action (@currentActions) {
				my $action_name;
				my $action_args;
				my $module_object;

				if ( defined $modules_aliases{ $action->{action} } ) {
					$action_name = $modules_aliases{ $action->{action} };
				} else {
					$action_name = $action->{action};
				}
				if (   defined $modules_config->{$action_name}
					&& defined $modules_config->{$action_name}->{config} )
				{
					$action_args = dclone( $modules_config->{$action_name}->{config} );
				}
				while ( my ( $key, $value ) = each %{ $action->{'args'} } ) {
					$action_args->{$key} = $action->{args}->{$key};
				}
				try {
					$module_object =
					  TrustAtHsH::Irondemo::ModuleFactory->loadModule( $action_name, $action_args );
					push @jobs, $module_object;
				}
				catch {
					$log->info("Module $action_name failed to load");
				};
			}
			delete $groupedActions{$currentTime};
			try {
				$executor->run_concurrent(@jobs);
			}
			catch {
				$log->info("Some modules failed to execute");
			};
			my $elements  = @jobs;
			my $processed = 0;
			while ( $processed < $elements ) {
				my $result = $executor->get_result_queue()->dequeue();
				if ( $result->{result} ) {
					$log->info(
						"Thread " . $result->{tid} .
						" reports SUCCESS executing " . $result->{module}
					);
				} else {
					$log->info(
						"Thread " . $result->{tid} .
						" reports FAILURE executing " .
						$result->{module}
					);
				}
				$processed++;
			}
			$log->info("All done for $currentTime");
		} else {
			$log->info("Nothing to do at $currentTime ...sleeping...");
		}
		sleep($timescale);
		$currentTime++;
	}
}

sub _read_yaml_file {
	my $self      = shift;
	my $yaml_path = shift;
	my ( $yaml, $yaml_fh );

	$log->debug("Reading $yaml_path");
	open( $yaml_fh, '<', "$yaml_path" ) or die "Could not open config file $yaml_path: $! \n";
	$yaml = LoadFile($yaml_fh);
	close $$yaml_fh;
	return $yaml;
}

sub _init_logging {
	my $self = shift;

	my $format;
	if ($VERBOSE) {
		$format = '%d %M: %m{chomp} %n';
	}
	else {
		$format = '%m{chomp} %n';
	}

	#	"%F "
	Log::Log4perl->easy_init(
		{
			file   => 'STDERR',
			layout => '[irondemo] %p: ' . $format,
			level  => $DEBUG,
		}
	);
}

sub _clear_directory {
	my $self = shift;
	my $dir  = shift;

	$log->debug("Wiping contents of $dir");
	if ( -d $dir ) {
		remove_tree( $dir, { keep_root => '0', safe => '0' } );
		make_path($dir);
	}
}

=head1 NAME

TrustAtHsH::Irondemo - The great new TrustAtHsH::Irondemo!

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use TrustAtHsH::Irondemo;

    my $foo = TrustAtHsH::Irondemo->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

=head1 AUTHOR

Trust@HsH, C<< <trust at f4-i.fh-hannover.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-trustathsh-irondemo at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=TrustAtHsH-Irondemo>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc TrustAtHsH::Irondemo


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=TrustAtHsH-Irondemo>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/TrustAtHsH-Irondemo>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/TrustAtHsH-Irondemo>

=item * Search CPAN

L<http://search.cpan.org/dist/TrustAtHsH-Irondemo/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Trust@HsH.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    L<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


=cut

1;    # End of TrustAtHsH::Irondemo
