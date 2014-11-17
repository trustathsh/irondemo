package TrustAtHsH::Irondemo::Modules::LoginSuccess;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use lib '../../../';
use TrustAtHsH::Irondemo::SimuUtilities;
use parent 'TrustAtHsH::Irondemo::ExtMeta';

my $USER_LOGIN = 'user-login';
my $USER_IP    = 'user-ip';
my $CRED       = 'cred';
my $REASON     = 'reason';
my $SERVICE    = 'service';
my $AR         = 'ar';
my $HOST       = 'host';
my $PORT       = 'port';
my $SERVICE_IP = 'service-ip';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';
my $DEVICE     = 'device';

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
	my $result = 1;
	
	
	my ( %service, %meta_service_ip, %service_ip, %ar, %meta_login_success, %user, %meta_identifies_as );
	
	%service = ( extended =>
	  TrustAtHsH::Irondemo::SimuUtilities->create_string_id_service({
	    type     => $data->{$SERVICE},
	    name     => $data->{$HOST},
	    port     => $data->{$PORT},
	  })
	);
	
	%meta_service_ip    = ( extended => TrustAtHsH::Irondemo::SimuUtilities->create_string_meta_service_ip() );
	%meta_identifies_as = ( extended => TrustAtHsH::Irondemo::SimuUtilities->create_string_meta_identifies_as() );
	%meta_login_success = ( extended => TrustAtHsH::Irondemo::SimuUtilities->create_string_meta_login_success() );
	
	$service_ip{'standard'}-> {'type'}  = 'ipv4';
	$service_ip{'standard'}-> {'value'} = $data->{$SERVICE_IP};
	$ar{'standard'}->{'type'}  = 'ar';
	$ar{'standard'}->{'value'} = $data->{$AR};
	$user{'standard'}->{'type'}  = 'id_user';
	$user{'standard'}->{'value'} = $data->{$USER_LOGIN};
	
	#Service-IP
	$result &= $self->publish( $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%service, \%meta_service_ip, \%service_ip );
	
	#Login-Success
	$result &= $self->publish( $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%service, \%meta_login_success, \%ar );
	
	#Auth-As
	$result &= $self->call_ifmap_cli({
	  'cli_tool' => "auth-as",
	  'mode' => "update",
	  'args_list' => [$data->{$AR}, $data->{$USER_LOGIN}],
	  'connection_args' => 	{ "ifmap-user" => $data->{$IFMAP_USER}, "ifmap-pass" => $data->{$IFMAP_PASS} },
	});
	
	#AR-IP
	$result &= $self->call_ifmap_cli({
	  'cli_tool' => "ar-ip",
	  'mode' => "update",
	  'args_list' => [$data->{$AR}, $data->{$USER_IP}],
	  'connection_args' => 	{ "ifmap-user" => $data->{$IFMAP_USER}, "ifmap-pass" => $data->{$IFMAP_PASS} },
	});
	
	#Identifies-As
	$result &= $self->publish( $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%ar, \%meta_identifies_as, \%user);
	
	#Device-IP
	$result &= $self->call_ifmap_cli({
	  'cli_tool' => "dev-ip",
	  'mode' => "update",
	  'args_list' => [$data->{$DEVICE}, $data->{$USER_IP}],
	  'connection_args' => 	{ "ifmap-user" => $data->{$IFMAP_USER}, "ifmap-pass" => $data->{$IFMAP_PASS} },
	});
	
	#Auth-By
	$result &= $self->call_ifmap_cli({
	  'cli_tool' => "auth-by",
	  'mode' => "update",
	  'args_list' => [$data->{$AR}, $data->{$DEVICE}],
	  'connection_args' => 	{ "ifmap-user" => $data->{$IFMAP_USER}, "ifmap-pass" => $data->{$IFMAP_PASS} },
	});
			
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