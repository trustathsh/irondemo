package TrustAtHsH::Irondemo::Modules::IrongenlogFreeradiusConnect;

use 5.16.0;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
#use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';
use TrustAtHsH::Irondemo::SimuUtilities;
use parent 'TrustAtHsH::Irondemo::ExtMeta';

my $ACCESS_REQUEST = 'access-request';
my $PDP = 'pdp';
my $IP = 'ip';
my $DEVICE = 'device';
my $ROLE = 'role';
my $NAME = 'name';
my $RADIUS_SERVICE_NAME = 'radius-service-name';
my $RADIUS_SERVICE_TYPE = 'radius-service-type';
my $RADIUS_SERVICE_PORT = 'radius-service-port';
my $LOGIN_SUCCESS = 'login-success';
my $LOGIN_FAILED = 'login-failed';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = (
	$ACCESS_REQUEST, $PDP, $IP, $DEVICE, $ROLE, $NAME, $IFMAP_USER, $IFMAP_PASS);

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $result = 1;

	my $connectionArgs = {
		"ifmap-user" => $data->{$IFMAP_USER},
		"ifmap-pass" => $data->{$IFMAP_PASS}};

	my @argsListArIp = ($data->{$ACCESS_REQUEST}, $data->{$IP});
    my @argsListAuthBy = ($data->{$ACCESS_REQUEST}, $data->{$PDP});
    my @argsListArDev = ($data->{$ACCESS_REQUEST}, $data->{$DEVICE});
    my @argsListAuthAs = ($data->{$ACCESS_REQUEST}, $data->{$NAME});
    my @argsListRole = ($data->{$ACCESS_REQUEST}, $data->{$NAME}, $data->{$ROLE});

	$result &= $self->call_ifmap_cli({
		'cli_tool' => "auth-by",
		'mode' => "update",
		'args_list' => \@argsListAuthBy,
		'connection_args' => $connectionArgs});
	$result &= $self->call_ifmap_cli({
		'cli_tool' => "ar-ip",
		'mode' => "update",
		'args_list' => \@argsListArIp,
		'connection_args' => $connectionArgs});
    $result &= $self->call_ifmap_cli({
        'cli_tool' => "auth-as",
        'mode' => "update",
        'args_list' => \@argsListAuthAs,
        'connection_args' => $connectionArgs});
    $result &= $self->call_ifmap_cli({
        'cli_tool' => "role",
        'mode' => "update",
        'args_list' => \@argsListRole,
        'connection_args' => $connectionArgs});
	$result &= $self->call_ifmap_cli({
		'cli_tool' => "ar-dev",
		'mode' => "update",
		'args_list' => \@argsListArDev,
		'connection_args' => $connectionArgs});
    
    # SIMU:LoginSuccess
    if (defined $data->{$LOGIN_SUCCESS}
        && defined $data->{$RADIUS_SERVICE_TYPE}
        && defined $data->{$RADIUS_SERVICE_NAME}
        && defined $data->{$RADIUS_SERVICE_PORT}) {
        my %service = ( extended =>
        TrustAtHsH::Irondemo::SimuUtilities->create_string_id_service({
            type     => $data->{$RADIUS_SERVICE_TYPE},
            name     => $data->{$RADIUS_SERVICE_NAME},
            port     => $data->{$RADIUS_SERVICE_PORT},
            })
        );
    
        my %ar;
        $ar{'standard'}->{'type'}  = 'ar';
        $ar{'standard'}->{'value'} = $data->{$ACCESS_REQUEST};
    
        my %meta_login_success = ( extended => TrustAtHsH::Irondemo::SimuUtilities->create_string_meta_login_success() );
    
        #Login-Success
        $result &= $self->publish( $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%service, \%meta_login_success, \%ar );
    }
    
    # SIMU:LoginFailed
    if (defined $data->{$LOGIN_FAILED}
        && defined $data->{$RADIUS_SERVICE_TYPE}
        && defined $data->{$RADIUS_SERVICE_NAME}
        && defined $data->{$RADIUS_SERVICE_PORT}) {
        my %service = ( extended =>
        TrustAtHsH::Irondemo::SimuUtilities->create_string_id_service({
            type     => $data->{$RADIUS_SERVICE_TYPE},
            name     => $data->{$RADIUS_SERVICE_NAME},
            port     => $data->{$RADIUS_SERVICE_PORT},
        })
        );
        
        my %ar;
        $ar{'standard'}->{'type'}  = 'ar';
        $ar{'standard'}->{'value'} = $data->{$ACCESS_REQUEST};
        
        my %meta_login_failed = ( extended =>
            TrustAtHsH::Irondemo::SimuUtilities->create_string_meta_login_failed ({
                reason          => 'wrong password',
                credential_type => 'password',
            })
        );
        
        #Login-Failure
        $result &= $self->publish( $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%service, \%meta_login_failed, \%ar );
    }
    
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
#                 pdp            ->
#                 access-request ->
#                 mac            ->
#                 ip-address     ->
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ($key, $val) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

1;
