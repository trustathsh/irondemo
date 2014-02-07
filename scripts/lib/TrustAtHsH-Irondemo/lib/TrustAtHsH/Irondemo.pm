package TrustAtHsH::Irondemo;

use 5.006;
use strict;
use warnings;

use lib '..';
use TrustAtHsH::Irondemo::AgendaParser;
use TrustAtHsH::Irondemo::Executor;
use TrustAtHsH::Irondemo::ModuleFactory;
use Try::Tiny;
use Log::Log4perl qw(:easy);
use Storable qw(dclone);

#for developement only
use Data::Dumper;

=head1 NAME

TrustAtHsH::Irondemo - The great new TrustAtHsH::Irondemo!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
my $VERBOSE  = 1;
my $log      = Log::Log4perl->get_logger();

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

sub _init_logging {
	
	my $format;
	if ($VERBOSE) {
		$format = '%d %M: %m{chomp} %n';
	} else {
		$format = '%m{chomp} %n';
	}
	#	"%F "
	Log::Log4perl->easy_init({
		file     => 'STDERR',
		layout   => '[irondemo] %p: ' . $format, 
		level    => $INFO,
	});
}

sub run_agenda {
	my $class           = shift;
	my $opts            = shift;
	my $agenda_path     = $opts->{'agenda_path'};
	my $modules_config  = $opts->{'modules_config'};
	my $timescale       = $opts->{'timescale'} || 1;
	my %modules_aliases;
	
	while ( my ($module, $params) = each %$modules_config ) {
		my $alias = $params->{'alias'};
		$modules_aliases{$alias} = $module if defined $alias;
	}
	
	_init_logging();

	$log->debug("Calling AgendaParser ...");
	my @data = TrustAtHsH::Irondemo::AgendaParser->new({
		'path' => $agenda_path,
	})->getActions();

	# group the actions by time
	my %groupedActions;
	for my $action (@data) {
		my $time = $action->{'time'};
		if (defined $groupedActions{$time}) {
			push @{$groupedActions{$time}}, $action;
		} else {
			$groupedActions{$time} = [$action];
		}
	}

	my $executor = TrustAtHsH::Irondemo::Executor->new({
		'threadpool_size' => $opts->{'threadpool_size'}
	});

	my $currentTime = 0;
	while (%groupedActions) {
		my @jobs;
		if (defined $groupedActions{$currentTime}) {
			my @currentActions = @{$groupedActions{$currentTime}};
			my $actionCount = @currentActions;
			$log->info("Executing ".$actionCount." actions at $currentTime");

			# execute actions for this timestamp
			for my $action (@currentActions) {
				my $action_name;
				my $action_args;
				my $module_object;

				if ( defined $modules_aliases{$action->{'action'}} ) {
					$action_name = $modules_aliases{$action->{'action'}};
				} else {
					$action_name = $action->{'action'};
				}
				if ( defined $modules_config->{$action_name} && defined $modules_config->{$action_name}->{'config'} ) {
					$action_args = dclone($modules_config->{$action_name}->{config});
				}
				while ( my ($key, $value) = each %{$action->{'args'}} ) {
					$action_args->{$key} = $action->{'args'}->{$key};
				};
				try {
					$module_object = TrustAtHsH::Irondemo::ModuleFactory->loadModule($action_name, $action_args); 
					push @jobs, $module_object;
				} catch {
					$log->info("Module $ $action_name failed to load");
				};
			}
			delete $groupedActions{$currentTime};
			try {
				$executor->run_concurrent(@jobs);
			} catch {
				$log->info("Some modules failed to execute");
			};
			my $elements = @jobs;
			my $processed  = 0;
			while ( $processed < $elements ) {
				my $result = $executor->get_result_queue()->dequeue();
				if ($result->{'result'}) {
					$log->info("Thread " . $result->{'tid'} . " reports SUCCESS executing " . $result->{'module'});
				} else {
					$log->info("Thread " . $result->{'tid'} . " reports FAILURE executing " . $result->{'module'});
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

=head2 function2

=cut

sub function2 {
}

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

1; # End of TrustAtHsH::Irondemo
