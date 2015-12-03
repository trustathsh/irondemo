package TrustAtHsH::Irondemo::Modules::DeviceDisconnects;

use 5.16.0;
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
my $VLAN_NUMBER = 'vlan-number';
my $VLAN_NAME = 'vlan-name';
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

	my $result = 1;

	my $connectionUserPdp = {
		"ifmap-user" => $data->{$USER_PDP},
		"ifmap-pass" => $data->{$PASS_PDP}};

	my $connectionUserDhcp = {
		"ifmap-user" => $data->{$USER_DHCP},
		"ifmap-pass" => $data->{$PASS_DHCP}};

	# PDP
	my @argsListAuthBy = ($data->{$ACCESS_REQUEST}, $data->{$PDP});
	my @argsListArMac = ($data->{$ACCESS_REQUEST}, $data->{$MAC});
	
	$self->call_ifmap_cli({
			'cli_tool' => "auth-by",
			'mode' => "delete",
			'args_list' => \@argsListAuthBy,
			'connection_args' => $connectionUserPdp});
	$self->call_ifmap_cli({
			'cli_tool' => "ar-mac",
			'mode' => "delete",
			'args_list' => \@argsListArMac,
			'connection_args' => $connectionUserPdp});

	# optional PDP publishs
	if (defined $data->{$SWITCH_DEVICE} 
		&& defined $data->{$VLAN_NUMBER}
		&& defined $data->{$VLAN_NAME}
		&& defined $data->{$SWITCH_PORT}) {
		my @argsListLayer2 = ($data->{$ACCESS_REQUEST},
				$data->{$SWITCH_DEVICE},
				"--vlan-number",
				$data->{$VLAN_NUMBER},
				"--vlan-name",
				$data->{$VLAN_NAME},
				"--port",
				$data->{$SWITCH_PORT});
		$self->call_ifmap_cli({
				'cli_tool' => "layer2-info",
				'mode' => "delete",
				'args_list' => \@argsListLayer2,
				'connection_args' => $connectionUserPdp});
	}

	if (defined $data->{$DEVICE}
		&& defined $data->{$DEVICE_ATTRIBUTE}) {
		my @argsListDevAttr = ($data->{$ACCESS_REQUEST}, $data->{$DEVICE}, $data->{$DEVICE_ATTRIBUTE});
		$self->call_ifmap_cli({
				'cli_tool' => "dev-attr",
				'mode' => "delete",
				'args_list' => \@argsListDevAttr,
				'connection_args' => $connectionUserPdp});
	}

	if (defined $data->{$DEVICE}) {
		my @argsListArDev = ($data->{$ACCESS_REQUEST}, $data->{$DEVICE});
		$self->call_ifmap_cli({
				'cli_tool' => "ar-dev",
				'mode' => "delete",
				'args_list' => \@argsListArDev,
				'connection_args' => $connectionUserPdp});
	}

	# DHCP server
	my @argsListIpMac = ($data->{$IP}, $data->{$MAC});
	
	$self->call_ifmap_cli({
			'cli_tool' => "ip-mac",
			'mode' => "delete",
			'args_list' => \@argsListIpMac,
			'connection_args' => $connectionUserDhcp});

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