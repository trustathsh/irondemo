package TrustAtHsH::Irondemo::Modules::AccessrequestNCP;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';


my $ACCESS_REQUEST = 'access-request';
my $NAME = 'identity';
my $DEVICE = 'device';
my $IP = 'ip';
my $VIP = 'vip';
my $HOST = 'hostname';
my $NCPCAP = 'ncpcap';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = (
	$ACCESS_REQUEST, $IP, $NAME, $IFMAP_USER, $IFMAP_PASS);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $result = 1;
	
	my @argsList = ($data->{$ACCESS_REQUEST}, $data->{$NAME});
	my @argsListRole = ($data->{$ACCESS_REQUEST}, $data->{$DEVICE});

	my $connectionArgs = {
		"ifmap-user" => $data->{$IFMAP_USER},
		"ifmap-pass" => $data->{$IFMAP_PASS}
	};

	$result &= $self->call_ifmap_cli({
			'cli_tool' => "auth-as",
			'mode' => "update",
			'args_list' => \@argsList,
			'connection_args' => $connectionArgs});
	$result &= $self->call_ifmap_cli({
			'cli_tool' => "auth-by",
			'mode' => "update",
			'args_list' => \@argsListRole,
			'connection_args' => $connectionArgs});
			
	my @argsListCapability = ($data->{$ACCESS_REQUEST}, $data->{$IP});
	$result &= $self->call_ifmap_cli({
			'cli_tool' => "ar-ip",
			'mode' => "update",
			'args_list' => \@argsListCapability,
			'connection_args' => $connectionArgs});
			
	if (defined $data->{$VIP}) {		
		my @argsList2 = ($data->{$ACCESS_REQUEST}, $data->{$VIP});
		$result &= $self->call_ifmap_cli({
				'cli_tool' => "ar-ip",
				'mode' => "update",
				'args_list' => \@argsList2,
				'connection_args' => $connectionArgs});
	}
	if (defined $data->{$HOST}) {		
	    my @argsList2 = ($data->{$ACCESS_REQUEST}, $data->{$HOST});
	    $result &= $self->call_ifmap_cli({
		'cli_tool' => "ar-dev",
		'mode' => "update",
		'args_list' => \@argsList2,
		'connection_args' => $connectionArgs});
	}
	if (defined $data->{$NCPCAP}) {		
	    my @argsList2 = ($data->{$ACCESS_REQUEST}, $data->{$NCPCAP});
	    $result &= $self->call_ifmap_cli({
		'cli_tool' => "cap",
		'mode' => "update",
		'args_list' => \@argsList2,
		'connection_args' => $connectionArgs});
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
