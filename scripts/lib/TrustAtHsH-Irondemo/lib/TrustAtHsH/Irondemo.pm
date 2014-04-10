package TrustAtHsH::Irondemo;

use 5.006;
use strict;
use warnings;

use lib '..';
use TrustAtHsH::Irondemo::AgendaParser;
use TrustAtHsH::Irondemo::Executor;
use TrustAtHsH::Irondemo::ModuleFactory;
use TrustAtHsH::Irondemo::Config;
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
use Time::HiRes qw/time sleep/;

#for developement only
use Data::Dumper;

our $VERSION = '0.41';
my $VERBOSE  = 1;
my $log      = Log::Log4perl->get_logger();


### CONSTRUCTOR ###
# Purpose     : Constructor
# Returns     : Instance
# Parameters  : timescale          -> Number of seconds that an agenda tick takes
#               config_dir         -> Path to config directory
#               resources_dir      -> Path to resources directory
#               scenarios_dir      -> Path to scenarios (target) directory
#               scenarios_conf_dir -> Path to scenarios config directory 
#               sources_dir        -> Path to sources (target) directory
#               threadpool_size    -> Number of threads that Irondemo uses to execute agenda tasks
# Comments    :
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

	my $config = TrustAtHsH::Irondemo::Config->instance;
	
	$config->set_modules_config(
		$self->_read_yaml_file(
			File::Spec->catfile( $self->{config_dir}, 'modules.yaml' )
		)
	);
	$config->set_projects_config(
		$self->_read_yaml_file(
			File::Spec->catfile( $self->{config_dir}, 'projects.yaml' )
		)
	);
	
	return $self;
}


### INSTANCE_METHOD ###
# Purpose     : Retrieve list of projects supported by irondemo
# Returns     : List of all projects that appear in projects.conf
# Parameters  : None
# Comments    :
sub get_projects {
	my $self = shift;
	my $projects_config = TrustAtHsH::Irondemo::Config->instance->get_projects_config();

	return keys %{$projects_config};
}
	
### INSTANCE_METHOD ###
# Purpose     : Retrieve list of scenarios that are supported by irondemo
# Returns     : List of scenarios, i.e. the names of all *.yaml files in 
#               config/scenarios without the .yaml file ending
# Parameters  :
# Comments    : TODO error handling for readdir and opendir
sub get_scenarios {
	my $self               = shift;
	my $scenarios_conf_dir = $self->{scenarios_conf_dir};

	opendir( TARGET, $scenarios_conf_dir );
	my @scenarios = map { s/\.yaml$//; $_; } grep( /.*\.yaml/, readdir(TARGET) );

	return @scenarios;
}


### INSTANCE_METHOD ###
# Purpose     : Update the sources of a project
# Returns     : True value on success, false value on failure
# Parameters  : project_id -> id of the project to be updated
#               clear      -> existing source directory will be purged if set to a true value
# Comments    :
sub update_project {
	my $self         = shift;
	my $opts         = shift;
	my $project_id   = $opts->{project_id};
	my $sources_dir  = $self->{sources_dir};
	my $clean        = $opts->{clean};
	my $project_conf = TrustAtHsH::Irondemo::Config->instance->get_project_config( $project_id );
	croak("Sorry, dont know $project_id") unless defined $project_conf;
	my $return_val = 0;

	my $scm = $project_conf->{sources}->{scm};
	my $url = $project_conf->{sources}->{uri};

	$self->_remove_directory( File::Spec->catdir( $sources_dir, $project_id ) ) if $clean;

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
	} else {
		$log->debug("Source directory found, updating sources from $scm. \n");
		chdir( File::Spec->catdir( $sources_dir, $project_id ) )
		  or die "Could not change directory: $! \n";
		if ( $scm =~ /git/ ) {
			$return_val = system("git pull");
		} elsif ( $scm =~ /svn/ ) {
			$return_val = system("svn up");
		} else {
			$log->debug("Unknown source control: $scm. Doing nothing. \n");
			$return_val = -1;
		}
	}
	return $return_val;
}


### INSTANCE_METHOD ###
# Purpose     : Build/compile the sources of a project
# Returns     : True value on success, false value on failure
# Parameters  : project_id -> id of the project to be built
#               clean      -> will attempt to make a clean rebuilt if set to a true value
# Comments    :
sub build_project {
	my $self         = shift;
	my $opts         = shift;
	my $clean        = $opts->{clean};
	my $project_id   = $opts->{project_id};
	my $sources_dir  = $self->{sources_dir};
	my $project_conf = TrustAtHsH::Irondemo::Config->instance->get_project_config( $project_id );
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


### INSTANCE_METHOD ###
# Purpose     : Construct the given the scenario by copying/extracting the necessary files as 
#               specified in the scenario's config
# Returns     : True value on success, false value on failure
# Parameters  :
# Comments    : TODO: Extended logging
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
	my $return_val    = 1;
	my $build_dir;
	

	#clear scenario directory if called with 'clean'
	$self->_remove_directory($scenario_dir) if $clean;

	#make sure scenario dir exists
	if ( -d $scenario_dir ) {
		$log->info("Scenario dir $scenario_dir exists. Doing nothing.");
		return 0;
	} else {
		mkdir($scenario_dir);
	}

	#iterate over each project that is part of the scenario
	for my $project ( @{ $scenario_conf->{projects} } ) {
		my $project_id   = $project->{id};
		my $project_conf = TrustAtHsH::Irondemo::Config->instance->get_project_config( $project_id );
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
				$return_val &= dircopy( $source, $destination );
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
					$return_val &= move( $ae->extract_path, $rename_to );
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
				$return_val &= copy( $source, $destination );
			}
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
			$return_val &= copy( $source, $destination ) or die "Cannot copy $source to $destination: $!";
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
			$return_val &= dircopy( $source, $destination ) or die "Cannot copy $source to $destination: $!";
		}
	}

	# execute scenario scripts
	if ( $scenario_conf->{execute} ) {
		for my $executable ( @{ $scenario_conf->{execute} } ) {
			if ( system( File::Spec->catfile( $scenario_resources_dir, $executable ) ) == 0 ) {
				$return_val &= 1;
			} else {
				$return_val = 0;
			}
		}
	}

	return $return_val;
}


### INSTANCE_METHOD ###
# Purpose     : Run a scenario
# Returns     : True value on success, false value on failure
# Parameters  : agenda  -> relative (to scenario base dir) path to agenda file
#               scenario-> the scenario to work with
# Comments    :
sub run_scenario {
	my $self           = shift;
	my $opts           = shift;
	my $agenda         = $opts->{agenda};
	my $scenario       = $opts->{scenario};
	my $agenda_path    = File::Spec->catfile( $self->{scenarios_dir}, $scenario, $agenda );
	my $modules_config = TrustAtHsH::Irondemo::Config->instance->get_modules_config;
	my $timescale      = $opts->{timescale} || $self->{timescale};
	my $return_val     = 1;
	my %modules_aliases;
	my @data;
	
	TrustAtHsH::Irondemo::Config->instance->set_current_scenario_dir(
		File::Spec->catfile( $self->{scenarios_dir}, $scenario )
	);

	while ( my ( $module, $params ) = each %$modules_config ) {
		my $alias = $params->{alias};
		$modules_aliases{$alias} = $module if defined $alias;
	}

	$log->debug("Calling AgendaParser ...");
	try {
		@data =
			TrustAtHsH::Irondemo::AgendaParser->new( { path => $agenda_path, } )->get_actions();
	} catch {
		$log->error("Parsing of $agenda_path failed ... aborting");
		croak("Parsing of $agenda_path failed ... aborting");
	};

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
	while ( %groupedActions ) {
		my @jobs;
		if ( defined $groupedActions{$currentTime} ) {
			my $execution_start = time;
			my @current_actions = @{ $groupedActions{$currentTime} };
			my $action_count    = @current_actions;
			$log->info( "Executing " . $action_count . " actions at $currentTime" );

			# execute actions for this timestamp
			for my $action (@current_actions) {
				my $action_name;
				my $action_args;
				my $module_object;

				if ( defined $modules_aliases{ $action->{action} } ) {
					$action_name = $modules_aliases{ $action->{action} };
				} else {
					$action_name = $action->{action};
				}
				if ( defined $modules_config->{$action_name}
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
				} catch {
					$log->warn("Module $action_name failed to load");
				};
			}
			delete $groupedActions{$currentTime};
			try {
				$executor->run_concurrent(@jobs);
			} catch {
				$log->warn("Some modules failed to execute");
				$return_val = 0;
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
					$log->warn(
						"Thread " . $result->{tid} .
						" reports FAILURE executing " .
						$result->{module}
					);
				}
				$return_val &= $result;
				$processed++;
			}
			$log->info("All done for $currentTime");
			my $execution_elapsed = time - $execution_start;
			if ( $execution_elapsed <= 1 ) {
				sleep($timescale - $execution_elapsed);
			} else {
				$log->warn("Last execution took $execution_elapsed seconds," .
				" timescale is $timescale seconds.");
			}
		} else {
			$log->info("Nothing to do at $currentTime ...sleeping...");
			sleep($timescale);
		}
		$currentTime++;
	}
	return $return_val;
}


### INTERNAL_UTILITY ###
# Purpose     : Open and read a yaml file
# Returns     : HashRef that contains the yaml file's structure
# Parameters  : Path to a yaml file
# Comments    : TODO proper error handling/logging
sub _read_yaml_file {
	my $self      = shift;
	my $yaml_path = shift;
	my ( $yaml, $yaml_fh );

	$log->debug("Reading $yaml_path");
	open( $yaml_fh, '<', "$yaml_path" ) or die "Could not open config file $yaml_path: $! \n";
	$yaml = LoadFile($yaml_fh);
	close $yaml_fh;
	return $yaml;
}


### INTERNAL_UTILITY ###
# Purpose     : Initialize and configure the Log4perl logger
# Returns     : Nothing
# Parameters  : None
# Comments    :
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


### INTERNAL_UTILITY ###
# Purpose     : Remove all the contents of a directory recursively
# Returns     : Nothing
# Parameters  : Path to directory that needs wiping
# Comments    : TODO proper error handling
sub _clear_directory {
	my $self = shift;
	my $dir  = shift;

	$log->debug("Wiping contents of $dir");
	if ( -d $dir ) {
		remove_tree( $dir, { keep_root => '0', safe => '0' } );
		make_path($dir);
	}
}


### INTERNAL_UTILITY ###
# Purpose     : Remove a directory recursively
# Returns     : Nothing
# Parameters  : Path to directory to
# Comments    : TODO proper error handling
sub _remove_directory {
	my $self = shift;
	my $dir  = shift;
	
	$log->debug("Removing $dir");
	if ( -d $dir ) {
		remove_tree( $dir, { keep_root => '0', safe => '0' } );
	}
}

=head1 NAME

TrustAtHsH::Irondemo - The great new TrustAtHsH::Irondemo!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use TrustAtHsH::Irondemo;

    my $foo = TrustAtHsH::Irondemo->new();

=head1 SUBROUTINES/METHODS

=head2 new

=head2 get_projects

=head2 get_scenarios

=head2 update_project

=head2 build_project

=head2 build_scenario

=head2 run_scenario

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
