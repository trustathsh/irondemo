package TrustAtHsH::Irondemo::AbstractIfmapCliModule;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use Log::Log4perl;
use lib '../../';
use parent 'TrustAtHsH::Irondemo::AbstractModule';


my $log = Log::Log4perl->get_logger();


### INSTANCE METHOD ###
# Purpose     : Calls the ifmapcli command-line tool.
# Returns     : Nothing # TODO return exit code of ifmapcli call
# Parameters  : ifmapcli tool name (required)
#				mode of the ifmapcli call, publish/delete (required)
#				argument list for the ifmapcli tool (required)
#				connection arguments (optional)
# Comments    :
sub callIfmapCli {
	my $self = shift;
	my $data = $self->{'data'};

	my ($cliTool, $mode, $argsList, $connectionArgs) = @_;

	my $ifmapcli_path = File::Spec->catdir($ENV{'HOME'}, "ifmapcli");
	chdir($ifmapcli_path) or die "Could not open directory $ifmapcli_path: $! \n";

	my $url = $connectionArgs->{'ifmap-url'} || $data->{'ifmap-url'};
	my $user = $connectionArgs->{'ifmap-user'} || $data->{'ifmap-user'};
	my $pass = $connectionArgs->{'ifmap-pass'} || $data->{'ifmap-pass'};
	my $keystorePath = $connectionArgs->{'ifmap-keystore-path'} || $data->{'ifmap-keystore-path'};
	my $keystorePass = $connectionArgs->{'ifmap-keystore-pass'} || $data->{'ifmap-keystore-pass'};

	my $argsString = "";
	for my $arg (@{$argsList}) {
		$argsString = $argsString." '$arg' ";
	}

	my $commandString = "java -jar $cliTool.jar $mode $argsString $url $user $pass $keystorePath $keystorePass";

	$log->debug("executing '$commandString'");
	my $result = system($commandString);
	$log->debug("executed '$cliTool', exit code is '$result'");

	#TODO check system's exit statuses and return something meaningful
}

1;