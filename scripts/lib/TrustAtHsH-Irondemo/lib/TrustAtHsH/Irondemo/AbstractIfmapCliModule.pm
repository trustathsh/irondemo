package TrustAtHsH::Irondemo::AbstractIfmapCliModule;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use Log::Log4perl;
use IPC::Run qw(run);
use Try::Tiny;
use lib '../../';
use parent 'TrustAtHsH::Irondemo::AbstractModule';


my $log = Log::Log4perl->get_logger();


### INSTANCE METHOD ###
# Purpose     : Calls the ifmapcli command-line tool.
# Returns     : True value on success, false value on failure
# Parameters  : ifmapcli tool name (required)
#				mode of the ifmapcli call, publish/delete (required)
#				argument list for the ifmapcli tool (required)
#				connection arguments (optional)
# Comments    :
sub callIfmapCli {
	my $self = shift;
	my $data = $self->{'data'};

	my ($cli_tool, $mode, $argsList, $connection_args) = @_;

	my $cli_jar       = $cli_tool . '.jar';
	my $ifmapcli_path = File::Spec->catdir($ENV{'HOME'}, "ifmapcli");
	chdir($ifmapcli_path) or die "Could not open directory $ifmapcli_path: $! \n";

	my $url = $connection_args->{'ifmap-url'}   || 'https://localhost:8443';
	my $user = $connection_args->{'ifmap-user'} || 'test';
	my $pass = $connection_args->{'ifmap-pass'} || 'test';
	my $keystorePath = $connection_args->{'ifmap-keystore-path'} || '/ifmapcli.jks';
	my $keystorePass = $connection_args->{'ifmap-keystore-pass'} || 'ifmapcli';
	my $verbosity = '-v';

	#construct array with command and argument list
	my @command =  qw (java -jar);
	push @command, $cli_jar, $mode;
	push @command, @{$argsList};

	push @command, '--url';
	push @command, $url;

	push @command, '--user';
	push @command, $user;

	push @command, '--pass';
	push @command, $pass;

	push @command, '--keystore-path';
	push @command, $keystorePath;

	push @command, '--keystore-pass';
	push @command, $keystorePass;

	push @command, $verbosity;

	$log->debug("Executing '@command'");
	my $result;
	try {
		$result = run \@command, '>', sub {$log->debug(@_)}, '2>', sub {$log->error(@_)};
	} catch {
		my $error = $_;
		log->error("Execution of $cli_tool failed: $error");
		croak($error);
	};
	return $result;
}

1;