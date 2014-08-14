package TrustAtHsH::Irondemo::Modules::LoginFailed;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use Cwd;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';

my $log      = Log::Log4perl->get_logger();

my $USER_LOGIN = 'user-login';
my $USER_NAME = 'user-name';
my $SERVICE = 'service';
my $HOST = 'host';
my $SERVICE_IP = 'service-ip';
my $USER_IP = 'user-ip';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = (
	$USER_LOGIN, $USER_NAME, $SERVICE, $HOST, $SERVICE_IP, $USER_IP);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $config = TrustAtHsH::Irondemo::Config->instance;
	my $path = 	$config->get_current_scenario_dir()."/";

	my $service_file = $path."service.xml";
	my $login_failed_file = $path."login-failed.xml";
	my $service_ip_file = $path."service-ip.xml";
	my $login_failed_ip_file = $path."login-failed-ip.xml";
	my $login_failed_info_file = $path."login-failed-info.xml";
	my $login_failed_user_file = $path."login-failed-user.xml";
	my $login_failed_id_file = $path."login-failed-id.xml";

	my $count = $data->{'count'} || "1";
	my $ar = $data->{'access-request'} || "ar:1";
	my $pdp = $data->{'pdp'} || "pdp";
	my $result = 1;
	
	open (FILE, ">$service_file");
	print FILE "<simu:service name=\"$data->{$SERVICE}\" host-name=\"$data->{HOST}\" administrative-domain=\"\" xmlns:simu=\"http://simu-project.de/XMLSchema/1\" />";
	close(FILE);
	open (FILE, ">$login_failed_file");
	print FILE "<simu:login-failed user=\"$data->{$USER_LOGIN}\" ip=\"$data->{$USER_IP}\" service=\"$data->{$SERVICE}\" service-host=\"$data->{$HOST}\" administrative-domain=\"\" xmlns:simu=\"http://simu-project.de/XMLSchema/1\" />";
	close(FILE);
	open (FILE, ">$login_failed_info_file");
	print FILE "<simu:login-failed-info count=\"$count\" xmlns:simu=\"http://simu-project.de/XMLSchema/1\" ifmap-cardinality=\"singleValue\" />";
	close(FILE);


	my @argsListServiceIp = ("--sec-identifier-type",
	"ipv4",
	"--sec-identifier",
	$data->{$SERVICE_IP},
	"--meta-in",
	$service_ip_file,
	$service_file);
	
	my @argsListLoginFailed = ("--sec-identifier-type",
	"exid",
	"--sec-identifier",
	$service_file,
	"--meta-in",
	$login_failed_id_file,
	$login_failed_file);

	my @argsListLoginFailedIp = ("--sec-identifier-type",
	"ipv4",
	"--sec-identifier",
	$data->{$USER_IP},
	"--meta-in",
	$login_failed_ip_file,
	$login_failed_file);
	
	my @argsListLoginFailedUser = ("--sec-identifier-type",
	"id_user",
	"--sec-identifier",
	$data->{$USER_LOGIN},
	"--meta-in",
	$login_failed_user_file,
	$login_failed_file);
	
	my @argsListLoginFailedInfo = (
	"--meta-in",
	$login_failed_info_file,
	$login_failed_file);
	
	my @argsListArIp = ( $ar, $data->{$USER_IP} );
	my @argsListAuthAs = ( $ar, $data->{$USER_NAME} );
	my @argsListAuthBy = ( $ar, $pdp );
	
	my $connectionArgs = {
		"ifmap-user" => $data->{$IFMAP_USER},
		"ifmap-pass" => $data->{$IFMAP_PASS}
	};

	$result &= $self->call_ifmap_cli(
		{
			'cli_tool'        => "ar-ip",
			'mode'            => "update",
			'args_list'       => \@argsListArIp,
			'connection_args' => $connectionArgs
		}
	);
	$result &= $self->call_ifmap_cli(
		{
			'cli_tool'        => "auth-as",
			'mode'            => "update",
			'args_list'       => \@argsListAuthAs,
			'connection_args' => $connectionArgs
		}
	);
	$result &= $self->call_ifmap_cli(
		{
			'cli_tool'        => "auth-by",
			'mode'            => "update",
			'args_list'       => \@argsListAuthBy,
			'connection_args' => $connectionArgs
		}
	);

	$result &= $self->call_ifmap_cli({
			'cli_tool' => "ex-ident",
			'mode' => "update",
			'args_list' => \@argsListServiceIp,
			'connection_args' => $connectionArgs});
			
	$result &= $self->call_ifmap_cli({
			'cli_tool' => "ex-ident",
			'mode' => "update",
			'args_list' => \@argsListLoginFailed,
			'connection_args' => $connectionArgs});
			
	$result &= $self->call_ifmap_cli({
			'cli_tool' => "ex-ident",
			'mode' => "update",
			'args_list' => \@argsListLoginFailedIp,
			'connection_args' => $connectionArgs});
			
	$result &= $self->call_ifmap_cli({
			'cli_tool' => "ex-ident",
			'mode' => "update",
			'args_list' => \@argsListLoginFailedUser,
			'connection_args' => $connectionArgs});
			
	$result &= $self->call_ifmap_cli({
			'cli_tool' => "ex-ident",
			'mode' => "update",
			'args_list' => \@argsListLoginFailedInfo,
			'connection_args' => $connectionArgs});

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
#                 name                 >
#                 role                ->
#                 access-request      ->
#
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ($key, $val) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

1;