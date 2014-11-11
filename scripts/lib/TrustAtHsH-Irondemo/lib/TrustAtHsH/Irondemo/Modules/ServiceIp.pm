package TrustAtHsH::Irondemo::Modules::ServiceIp;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use lib '../../../';
use TrustAtHsH::Irondemo::SimuUtilities;
use parent 'TrustAtHsH::Irondemo::ExtMeta';

my $SERVICE    = 'service';
my $SERVICE_IP = 'service-ip';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';
my $HOST       = 'host';
my $DEVICE     = 'device';
my $PORT       = 'port';

my @REQUIRED_ARGS = ( $SERVICE, $SERVICE_IP, $HOST, $PORT );

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
	    type     => $data->{$SERVICE},
	    name     => $data->{$HOST},
	    port     => $data->{$PORT},
	  })
	);

	$ip{'standard'}-> {'type'}  = 'ipv4';
	$ip{'standard'}-> {'value'} = $data->{$SERVICE_IP};
	
	%meta_service_ip = ( extended => TrustAtHsH::Irondemo::SimuUtilities->create_string_meta_service_ip());
	
	$result &= $self->publish(
	  $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%service, \%meta_service_ip, \%ip
	);
	
	if ( $data->{$DEVICE} ) {
		$result &= $self->call_ifmap_cli({
		  'cli_tool' => "dev-ip",
		  'mode' => "update",
		  'args_list' => [$data->{$DEVICE}, $data->{$SERVICE_IP}],
		  'connection_args' => { 'ifmap-user' => $data->{$IFMAP_USER},
		    'ifmap-pass' => $data->{$IFMAP_PASS}
		  },
		});
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
#                 service             ->
#                 service-ip          ->
#                 host                ->
#                 device              ->(optional)
#                 port                ->
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ($key, $val) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

1;