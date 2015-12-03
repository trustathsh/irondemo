package TrustAtHsH::Irondemo::Modules::InitPdpInfrastructure;

use 5.16.0;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';


my $PDP_DEVICE = "pdp";
my $PDP_IP_ADDRESS = "pdp-ip-address";
my $IPTABLES_DEVICE = "iptables";
my $IPTABLES_IP_ADDRESS = "iptables-ip-address";
my $SWITCH_DEVICE = 'switch';
my $SWITCH_IP_ADDRESS = 'switch-ip-address';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = (
	$PDP_DEVICE, $PDP_IP_ADDRESS, $IPTABLES_DEVICE, $IPTABLES_IP_ADDRESS, $SWITCH_DEVICE, $SWITCH_IP_ADDRESS, $IFMAP_USER, $IFMAP_PASS);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $result = 1;

	my @argsList = ($data->{$PDP_DEVICE}, $data->{$PDP_IP_ADDRESS});
	my $connectionArgs = {
		"ifmap-user" => $data->{$IFMAP_USER},
		"ifmap-pass" => $data->{$IFMAP_PASS}
	};
	my @argsListIpTables = ($data->{$IPTABLES_DEVICE}, $data->{$IPTABLES_IP_ADDRESS});
	my @argsListSwitch = ($data->{$SWITCH_DEVICE}, $data->{$SWITCH_IP_ADDRESS});

	$result &= $self->call_ifmap_cli({
			'cli_tool' => "dev-ip",
			'mode' => "update",
			'args_list' => \@argsList,
			'connection_args' => $connectionArgs});
	$result &= $self->call_ifmap_cli({
			'cli_tool' => "dev-ip",
			'mode' => "update",
			'args_list' => \@argsListIpTables,
			'connection_args' => $connectionArgs});
	$result &= $self->call_ifmap_cli({
			'cli_tool' => "dev-ip",
			'mode' => "update",
			'args_list' => \@argsListSwitch,
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