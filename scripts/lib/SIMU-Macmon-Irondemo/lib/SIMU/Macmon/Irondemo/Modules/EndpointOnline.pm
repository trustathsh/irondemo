package SIMU::Macmon::Irondemo::Modules::EndpointOnline;

use 5.16.0;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../..';
use lib '../../../../../../TrustAtHsH-Irondemo/lib';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';
use POSIX qw(strftime);

my $MACMON_DEV = "pep-device";

my $MAC_ADDRESS = "mac-address";
my $IP_ADDRESS  = "ip-address";
my $USERNAME	= "username";

my $DC_MANUFAC    = "manufacturer";
my $DC_MODEL      = "model";
my $DC_OS         = "os";
my $DC_OS_VERSION = "os-version";
my $DC_DEV_TYPE   = "device-type";
my $DC_METHOD     = "discovery-method";

my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = (
	$MACMON_DEV, $MAC_ADDRESS, $IP_ADDRESS,    $USERNAME,    $DC_MANUFAC,
	$DC_MODEL,   $DC_OS,       $DC_OS_VERSION, $DC_DEV_TYPE,
	$DC_METHOD,  $IFMAP_USER,  $IFMAP_PASS
);

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self   = shift;
	my $data   = $self->{'data'};
	my $result = 1;
	my $config = TrustAtHsH::Irondemo::Config->instance;
	my $path   = $config->get_current_scenario_dir();

	# Set MAPS connection credentials
	my $connectionArgs = {
		"ifmap-user" => $data->{$IFMAP_USER},
		"ifmap-pass" => $data->{$IFMAP_PASS}
	};

	# Publish auth-by
	my $accessRequest = "macmon:" . $data->{$MAC_ADDRESS};
	my @argsListAuthBy = ( $accessRequest, $data->{$MACMON_DEV} );
	$result &= $self->call_ifmap_cli(
		{
			'cli_tool'        => "auth-by",
			'mode'            => "update",
			'args_list'       => \@argsListAuthBy,
			'connection_args' => $connectionArgs
		}
	);
	
	# Publish auth-as
	my @argsListAuthAs = ( $accessRequest, $data->{$USERNAME} );
	$result &= $self->call_ifmap_cli(
		{
			'cli_tool'        => "auth-as",
			'mode'            => "update",
			'args_list'       => \@argsListAuthAs,
			'connection_args' => $connectionArgs
		}
	);

	# Publish access-request-mac
	my @argsListArMac = ( $accessRequest, $data->{$MAC_ADDRESS} );
	$result &= $self->call_ifmap_cli(
		{
			'cli_tool'        => "ar-mac",
			'mode'            => "update",
			'args_list'       => \@argsListArMac,
			'connection_args' => $connectionArgs
		}
	);

	# Publish discovered-by
	my @argsListDiscBy = ( "mac", $data->{$MAC_ADDRESS}, $data->{$MACMON_DEV} );
	$result &= $self->call_ifmap_cli(
		{
			'cli_tool'        => "disc-by",
			'mode'            => "update",
			'args_list'       => \@argsListDiscBy,
			'connection_args' => $connectionArgs
		}
	);

	# Publish ip-mac
	my @argsListIpMac = ( $data->{$IP_ADDRESS}, $data->{$MAC_ADDRESS} );
	$result &= $self->call_ifmap_cli(
		{
			'cli_tool'        => "ip-mac",
			'mode'            => "update",
			'args_list'       => \@argsListIpMac,
			'connection_args' => $connectionArgs
		}
	);

	# Publish device-characteristic
	my $device          = "dev:" . $data->{$MAC_ADDRESS};
	my $discTime        = strftime( "%FT%XZ", localtime );
	my @argsListDevChar = (
		"ar", $accessRequest, $device, $discTime, $data->{$MACMON_DEV},
		$data->{$DC_METHOD}
	);

  # TODO Publish device-characteristic after ifmapcli dev-char.jar but is fixed.

	return $result;
}

### INSTANCE METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub get_required_arguments {
	my $self = shift;

	return @REQUIRED_ARGS;
}

### INTERNAL UTILITY ###
# Purpose     :
# Returns     :
# Parameters  : data ->
#                 ifmap-user          ->(optional)
#                 ifmap-pass          ->(optional)
#                 ifmap-url           ->(optional)
#                 ifmap-keystore-path ->(optional)
#                 ifmap-keystore-pass ->(optional)
#                 pep-device          ->(optional)
#                 discovery-method    ->(optional)
#                 mac-address         ->
#                 ip-address          ->
#                 username            ->
#                 manufacturer        ->
#                 model               ->
#                 os                  ->
#                 version             ->
#                 type                ->
#
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ( $key, $val ) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

1;
