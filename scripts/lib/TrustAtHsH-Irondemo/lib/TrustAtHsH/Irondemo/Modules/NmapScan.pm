package TrustAtHsH::Irondemo::Modules::NmapScan;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use TrustAtHsH::Irondemo::SimuUtilities;
use parent 'TrustAtHsH::Irondemo::ExtMeta';


my $DISCOVERER_DEVICE = "discoverer";
my $SERVICE_TYPE = "service-type";
my $SERVICE_NAME = "service-name";
my $SERVICE_IP = "service-ip";
my $SERVICE_PORT = 'service-port';
my $USER_NMAP = 'ifmap-user';
my $PASS_NMAP = 'ifmap-pass';

my @REQUIRED_ARGS = (
	$DISCOVERER_DEVICE, $SERVICE_IP, $SERVICE_PORT, $SERVICE_NAME, $SERVICE_TYPE, $USER_NMAP, $PASS_NMAP);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $result = 1;

	my ( %device, %service, %ip, %meta_service_ip, %meta_service_discovered_by );
	
	%service = ( extended =>
	  TrustAtHsH::Irondemo::SimuUtilities->create_string_id_service({
	    type     => $data->{$SERVICE_TYPE},
	    name     => $data->{$SERVICE_NAME},
	    port     => $data->{$SERVICE_PORT},
	  })
	);
	$device{'standard'}-> {'type'} = 'dev';
	$device{'standard'}-> {'value'} = 'nmap';

	$ip{'standard'}-> {'type'}  = 'ipv4';
	$ip{'standard'}-> {'value'} = $data->{$SERVICE_IP};
	
	%meta_service_ip = ( extended => TrustAtHsH::Irondemo::SimuUtilities->create_string_meta_service_ip());
	
	$result &= $self->publish(
	  $data->{$USER_NMAP}, $data->{$PASS_NMAP}, \%service, \%meta_service_ip, \%ip
	);
	
	%meta_service_discovered_by = ( extended => TrustAtHsH::Irondemo::SimuUtilities->create_string_meta_service_discovered());
	
	$result &= $self->publish(
	  $data->{$USER_NMAP}, $data->{$PASS_NMAP}, \%device, \%meta_service_discovered_by, \%service
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
#                 ifmap-user          ->(optional)
#                 ifmap-pass          ->(optional)
#                 ifmap-url           ->(optional)
#                 ifmap-keystore-path ->(optional)
#                 ifmap-keystore-pass ->(optional)
#                 pdp                 ->
#                 pdp-ip-address      ->
#                 iptables            ->
#                 iptables-ip-address ->
#                 switch              ->
#                 switch-ip-address   ->
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