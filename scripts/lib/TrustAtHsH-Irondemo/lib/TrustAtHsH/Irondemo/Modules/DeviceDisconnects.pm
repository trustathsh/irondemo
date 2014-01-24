package TrustAtHsH::Irondemo::Modules::DeviceDisconnects;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractModule';

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};
	
	my $ifmapcli_path = File::Spec->catdir($ENV{'HOME'}, "ifmapcli");
	
	my $pdp = $data->{'pdp'};
	my $access_request = $data->{'access-request'};
	my $mac = $data->{'mac'};
	my $ip = $data->{'ip-address'};

	chdir($ifmapcli_path) or die "Could not open directory $ifmapcli_path: $! \n";
	
	# PDP
	system("java -jar auth-by.jar delete $access_request $pdp $data->{'ifmap-url'} $data->{'ifmap-user-pdp'} $data->{'ifmap-pass-pdp'} $data->{'ifmap-keystore-path'} $data->{'ifmap-keystore-pass'}");
	system("java -jar ar-mac.jar delete $access_request $mac $data->{'ifmap-url'} $data->{'ifmap-user-pdp'} $data->{'ifmap-pass-pdp'} $data->{'ifmap-keystore-path'} $data->{'ifmap-keystore-pass'}");
	
	# DHCP
	system("java -jar ip-mac.jar delete $ip $mac $data->{'ifmap-url'} $data->{'ifmap-user-dhcp'} $data->{'ifmap-pass-dhcp'} $data->{'ifmap-keystore-path'} $data->{'ifmap-keystore-pass'}");
	#TODO check system's exit statuses and return something meaningful
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
	#TODO should check if needed parameters have been defined or set defaults
	while ( my ($key, $val) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

1;