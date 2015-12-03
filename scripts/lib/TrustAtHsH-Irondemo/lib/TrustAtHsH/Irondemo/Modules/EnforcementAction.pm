package TrustAtHsH::Irondemo::Modules::EnforcementAction;

use 5.16.0;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';


my $PEP_DEVICE = "pep-device";
my $MODE       = "mode";
my $IP_ADDRESS = "ip-address";
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my $ENFORCEMENT_TYPE = "type";

my @REQUIRED_ARGS = (
	$PEP_DEVICE, $IP_ADDRESS, $IFMAP_USER, $IFMAP_PASS);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $result = 1;

	my @argsList = ($data->{$PEP_DEVICE}, "ipv4", $data->{$IP_ADDRESS}, $data->{$ENFORCEMENT_TYPE});
	my $connectionArgs = {
		"ifmap-user" => $data->{$IFMAP_USER},
		"ifmap-pass" => $data->{$IFMAP_PASS}
	};

	my $mode = $data->{$MODE} ? $data->{$MODE} : 'update';

	$result &= $self->call_ifmap_cli({
			'cli_tool' => "enf-report",
			'mode'     => $mode,
			'args_list' => \@argsList,
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
#                 pep-device          ->
#                 ip-address          ->
#                 type                ->(optional)
#
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ($key, $val) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}

	$self->{'data'}->{$ENFORCEMENT_TYPE} = "block" unless defined $self->{'data'}->{$ENFORCEMENT_TYPE};
}


1;
