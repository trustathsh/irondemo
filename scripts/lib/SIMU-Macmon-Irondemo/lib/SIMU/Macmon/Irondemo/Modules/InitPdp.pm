package SIMU::Macmon::Irondemo::Modules::InitPdp;

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
my $MACMON_IP  = "pep-ip";

my $ADMIN_DOMAIN = "administrative-domain";

my $SERVICE_NAME = "macmon-service-name";
my $SERVICE_TYPE = "macmon-service-type";
my $SERVICE_PORT = "macmon-service-port";

my $IMPLEMENTATION_VALUE   = "macmon-implementation-value";
my $IMPLEMENTATION_VERSION = "macmon-implementation-version";

my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = (
	$MACMON_DEV,             $MACMON_IP,    $SERVICE_NAME,
	$SERVICE_TYPE,           $SERVICE_PORT, $IMPLEMENTATION_VALUE,
	$IMPLEMENTATION_VERSION, $IFMAP_USER,   $IFMAP_PASS
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

	# Publish service-discovered-by
	my $servDiscByFile = "$path/service-discovered-by.xml";
	my $serviceFile    = "$path/service.xml";
	open( FILE, ">$serviceFile" );
	print FILE "<simu:service type=\""
	  . $data->{$SERVICE_TYPE}
	  . "\" name=\""
	  . $data->{$SERVICE_NAME}
	  . "\" port=\""
	  . $data->{$SERVICE_PORT}
	  . "\" administrative-domain=\""
	  . $data->{$ADMIN_DOMAIN}
	  . "\" xmlns:simu=\"http://simu-project.de/XMLSchema/1\" />";
	close(FILE);
	my @argsListServDiscBy = (
		"--sec-identifier-type", "dev", "--sec-identifier",
		$data->{$MACMON_DEV}, "--meta-in", $servDiscByFile, $serviceFile
	);
	$result &= $self->call_ifmap_cli(
		{
			'cli_tool'        => "ex-ident",
			'mode'            => "update",
			'args_list'       => \@argsListServDiscBy,
			'connection_args' => $connectionArgs
		}
	);

	# Publish service-implementation
	my $servImplFile = "$path/service-implementation.xml";
	my $implFile     = "$path/implementation.xml";
	open( FILE, ">$implFile" );
	print FILE "<simu:implementation value=\""
	  . $data->{$IMPLEMENTATION_VALUE}
	  . "\" version=\""
	  . $data->{$IMPLEMENTATION_VERSION}
	  . "\" administrative-domain=\""
	  . $data->{$ADMIN_DOMAIN}
	  . "\" xmlns:simu=\"http://simu-project.de/XMLSchema/1\" />";
	close(FILE);
	my @argsListServImpl = (
		"--sec-identifier-type", "exid", "--sec-identifier", $serviceFile,
		"--meta-in", $servImplFile, $implFile
	);
	$result &= $self->call_ifmap_cli(
		{
			'cli_tool'        => "ex-ident",
			'mode'            => "update",
			'args_list'       => \@argsListServImpl,
			'connection_args' => $connectionArgs
		}
	);

	# Publish service-ip
	my $servIpFile     = "$path/service-ip.xml";
	my @argsListServIp = (
		"--sec-identifier-type", "ipv4", "--sec-identifier",
		$data->{$MACMON_IP}, "--meta-in", $servIpFile, $serviceFile
	);
	$result &= $self->call_ifmap_cli(
		{
			'cli_tool'        => "ex-ident",
			'mode'            => "update",
			'args_list'       => \@argsListServIp,
			'connection_args' => $connectionArgs
		}
	);

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
#                 ifmap-user            ->(optional)
#                 ifmap-pass            ->(optional)
#                 ifmap-url             ->(optional)
#                 ifmap-keystore-path   ->(optional)
#                 ifmap-keystore-pass   ->(optional)
#                 pep-ip                ->(optional)
#                 pep-device            ->(optional)
#                 administrative-domain ->(optional)
#                 macmon-service-name   ->(optional)
#                 macmon-service-type   ->(optional)
#                 macmon-service-port   ->(optional)
#                 macmon-implementation-value ->(optional)
#                 macmon-implementation-version ->(optional)
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
