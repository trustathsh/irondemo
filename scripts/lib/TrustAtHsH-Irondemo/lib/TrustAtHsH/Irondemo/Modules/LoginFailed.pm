package TrustAtHsH::Irondemo::Modules::LoginFailed;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use lib '../../../';
use TrustAtHsH::Irondemo::SimuUtilities;
use parent 'TrustAtHsH::Irondemo::ExtMeta';

my $log      = Log::Log4perl->get_logger();

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
	$USER_LOGIN, $USER_IP, $CRED, $REASON, $SERVICE, $HOST, $PORT, $SERVICE_IP, $DEVICE);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};
	my $result = 1;
	
	my ( %service, %ar, %meta_login_failed, %service_ip, %ar_ip, %meta_service_ip, %meta_identifies_as, %user);
	
	%service = ( extended =>
	  TrustAtHsH::Irondemo::SimuUtilities->create_string_id_service({
	    type     => $data->{$SERVICE},
	    name     => $data->{$HOST},
	    port     => $data->{$PORT},
	  })
	);

	%meta_login_failed = ( extended => 
	  TrustAtHsH::Irondemo::SimuUtilities->create_string_meta_login_failed ({
	    reason          => $data->{$REASON},
	    credential_type => $data->{$CRED},
	  })
	);
	
	%meta_service_ip = ( extended => TrustAtHsH::Irondemo::SimuUtilities->META_SERVICE_IP );
	
	%meta_identifies_as = ( extended => TrustAtHsH::Irondemo::SimuUtilities->META_IDENTIFIES_AS );
	  
	$ar{'standard'}->{'type'}  = 'ar';
	$ar{'standard'}->{'value'} = $data->{$AR};
	
	$service_ip{'standard'}-> {'type'}  = 'ipv4';
	$service_ip{'standard'}-> {'value'} = $data->{$SERVICE_IP};
	
	$user{'standard'}->{'type'}  = 'id_user';
	$user{'standard'}->{'value'} = $data->{$USER_LOGIN};
	
	$result &= $self->publish( $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%service, \%meta_service_ip, \%service_ip );
	$result &= $self->publish( $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%ar, \%meta_identifies_as, \%user);
	
	$result &= $self->call_ifmap_cli({
	  'cli_tool' => "ar-ip",
	  'mode' => "update",
	  'args_list' => [$data->{$AR}, $data->{$USER_IP}],
	  'connection_args' => 	{ "ifmap-user" => $data->{$IFMAP_USER}, "ifmap-pass" => $data->{$IFMAP_PASS} },
	});
	
	$result &= $self->publish( $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%service, \%meta_login_failed, \%ar );


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
#                 ifmap-pass          ->(op(optional)tional)
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