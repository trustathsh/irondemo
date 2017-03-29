package TrustAtHsH::Irondemo::Modules::SelfPublish;

use 5.16.0;
use strict;
use warnings;
use Carp qw(croak);
use lib '../../../';
use TrustAtHsH::Irondemo::SimuUtilities;
use parent 'TrustAtHsH::Irondemo::ExtMeta';

my $SERVICE_TYPE           = 'service-type';
my $SERVICE_NAME           = 'service-name';
my $SERVICE_PORT           = 'service-port';
my $IP                     = 'ip';
my $DEVICE                 = 'device';
my $IMPLEMENTATION_NAME    = 'implementation-name';
my $IMPLEMENTATION_VERSION = 'implementation-version';
my $IFMAP_USER             = 'ifmap-user';
my $IFMAP_PASS             = 'ifmap-pass';

my @REQUIRED_ARGS = ( $SERVICE_TYPE, $SERVICE_NAME, $SERVICE_PORT, $IP, $DEVICE );

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
    my $self = shift;
    my $data = $self->{'data'};
    my $result = 1;
    
    my ( %service, %ip, %meta_service_ip );
    
    %service = ( extended =>
    TrustAtHsH::Irondemo::SimuUtilities->create_string_id_service({
        type     => $data->{$SERVICE_TYPE},
        name     => $data->{$SERVICE_NAME},
        port     => $data->{$SERVICE_PORT},
    })
    );
    
    if ( $data->{$IMPLEMENTATION_NAME} ) {
        my %implementation = ( extended =>
        TrustAtHsH::Irondemo::SimuUtilities->create_string_id_implementation({
            name     => $data->{$IMPLEMENTATION_NAME},
            version  => $data->{$IMPLEMENTATION_VERSION},
        })
        );
        
        my %meta_service_implementation = ( extended => TrustAtHsH::Irondemo::SimuUtilities->create_string_meta_service_implementation());
        
        $result &= $self->publish(
        $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%service, \%meta_service_implementation, \%implementation
        );
    }

    $ip{'standard'}-> {'type'}  = 'ipv4';
    $ip{'standard'}-> {'value'} = $data->{$IP};
    
    %meta_service_ip = ( extended => TrustAtHsH::Irondemo::SimuUtilities->create_string_meta_service_ip());
    
    $result &= $self->publish(
    $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%service, \%meta_service_ip, \%ip
    );
    
    $result &= $self->call_ifmap_cli({
        'cli_tool' => "dev-ip",
        'mode' => "update",
        'args_list' => [$data->{$DEVICE}, $data->{$IP}],
        'connection_args' => { 'ifmap-user' => $data->{$IFMAP_USER},
            'ifmap-pass' => $data->{$IFMAP_PASS}
        },
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
#                 service-type        ->
#                 service-name        ->
#                 service-port        ->
#                 ip                  ->
#                 device              ->(optional)
# Comments    : Override, called from parent's constructor
sub _init {
    my $self = shift;
    my $args = shift;
    
    while ( my ($key, $val) = each %{$args} ) {
        $self->{'data'}->{$key} = $val;
    }
}

1;
