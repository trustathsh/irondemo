package TrustAtHsH::Irondemo::Modules::DeviceDisconnects;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';


my $ACCESS_REQUEST = 'access-request';
my $PDP = 'pdp';
my $MAC = 'mac';
my $IP = 'ip-address';
my $VLAN = 'vlan';
my $SWITCH_PORT = 'switch-port';
my $SWITCH_DEVICE = 'switch-device';
my $DEVICE = 'device';
my $DEVICE_ATTRIBUTE = 'device-attribute';
my $USER_PDP = 'ifmap-user-pdp';
my $PASS_PDP = 'ifmap-pass-pdp';
my $USER_DHCP = 'ifmap-user-dhcp';
my $PASS_DHCP = 'ifmap-pass-dhcp';

my @REQUIRED_ARGS = (
	$ACCESS_REQUEST, $PDP, $MAC, $IP, $USER_PDP, $PASS_PDP, $USER_DHCP, $PASS_DHCP);

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my @argsListAuthBy = ($data->{$ACCESS_REQUEST}, $data->{$PDP});
	my @argsListLayer2 = ($data->{$ACCESS_REQUEST}, $data->{$SWITCH_DEVICE}, "--vlan-number", $data->{$VLAN}, "--port", $data->{$SWITCH_PORT});
	my @argsListDevAttr = ($data->{$ACCESS_REQUEST}, $data->{$DEVICE}, $data->{$DEVICE_ATTRIBUTE});
	my @argsListArDev = ($data->{$ACCESS_REQUEST}, $data->{$DEVICE});
	my @argsListArMac = ($data->{$ACCESS_REQUEST}, $data->{$MAC});
	my $connectionUserPdp = {
		"ifmap-user" => $data->{$USER_PDP},
		"ifmap-pass" => $data->{$PASS_PDP}};

	my @argsListIpMac = ($data->{$IP}, $data->{$MAC});
	my $connectionUserDhcp = {
		"ifmap-user" => $data->{$USER_DHCP},
		"ifmap-pass" => $data->{$PASS_DHCP}};

	$self->call_ifmap_cli("auth-by", "delete", \@argsListAuthBy, $connectionUserPdp);
	$self->call_ifmap_cli("layer2-info", "delete", \@argsListLayer2, $connectionUserPdp);
	$self->call_ifmap_cli("dev-attr", "delete", \@argsListDevAttr, $connectionUserPdp);
	$self->call_ifmap_cli("ar-dev", "delete", \@argsListArDev, $connectionUserPdp);
	$self->call_ifmap_cli("ar-mac", "delete", \@argsListArMac, $connectionUserPdp);
	$self->call_ifmap_cli("ip-mac", "delete", \@argsListIpMac, $connectionUserDhcp);
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