package TrustAtHsH::Irondemo::Modules::LoginSuccess;

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
my $USER_IP = 'user-ip';
my $CRED = 'cred';
my $SERVICE = 'service';
my $SSHAR = 'ssh-ar';
my $HOST = 'host';
my $PORT = 'port';
my $SERVICE_IP = 'service-ip';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = (
	$USER_LOGIN, $USER_IP, $CRED, $SERVICE, $HOST, $PORT, $SERVICE_IP);


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
	my $login_success_file = $path."login-success.xml";
	
	my $service_ip_file = $path."service-ip.xml";
	my $identifies_as_file = $path."identifies-as.xml";
	
	my $result = 1;
	
	my $device = "ssh-server";
	
	open (FILE, ">$service_file");
	print FILE "<simu:service type=\"$data->{$SERVICE}\" name=\"$data->{$HOST}\" port=\"$data->{$PORT}\" administrative-domain=\"\" xmlns:simu=\"http://simu-project.de/XMLSchema/1\" />";
	close(FILE);
	open (FILE, ">$login_success_file");
	print FILE "<simu:login-success ifmap-cardinality=\"singleValue\" xmlns:simu=\"http://simu-project.de/XMLSchema/1\"><simu:credential-type>$data->{$CRED}</simu:credential-type></simu:login-success>";
	close(FILE);

	my @argsListServiceIp = ("--sec-identifier-type",
	"ipv4",
	"--sec-identifier",
	$data->{$SERVICE_IP},
	"--meta-in",
	$service_ip_file,
	$service_file);
	
	my @argsListLoginSuccess = ("--sec-identifier-type",
	"ar",
	"--sec-identifier",
	$data->{$SSHAR},
	"--meta-in",
	$login_success_file,
	$service_file);
	
	my @argsListAuthAs = ($data->{$SSHAR}, $data->{$USER_LOGIN});
	
	my @argsListSshArIp = ($data->{$SSHAR}, $data->{$USER_IP});
	
	my @argsListIdentifiesAs = ("--sec-identifier-type",
	"id_user",
	"--sec-identifier",
	$data->{$USER_LOGIN},
	"--meta-in",
	$identifies_as_file,
	"ar",
	$data->{$SSHAR});
	
	my @argsListDevIp = ( $device, $data->{$SERVICE_IP} );
	my @argsListAuthBy = ( $data->{$SSHAR}, $device );
	
	my $connectionArgs = {
		"ifmap-user" => $data->{$IFMAP_USER},
		"ifmap-pass" => $data->{$IFMAP_PASS}
	};

	$result &= $self->call_ifmap_cli(
		{
			'cli_tool'        => "dev-ip",
			'mode'            => "update",
			'args_list'       => \@argsListDevIp,
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
			'args_list' => \@argsListLoginSuccess,
			'connection_args' => $connectionArgs});
	
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
			'cli_tool' => "ar-ip",
			'mode' => "update",
			'args_list' => \@argsListSshArIp,
			'connection_args' => $connectionArgs});
			
	$result &= $self->call_ifmap_cli({
			'cli_tool' => "ex-meta",
			'mode' => "update",
			'args_list' => \@argsListIdentifiesAs,
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