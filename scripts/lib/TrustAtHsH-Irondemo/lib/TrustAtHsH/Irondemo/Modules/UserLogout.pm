package TrustAtHsH::Irondemo::Modules::UserLogout;

use 5.16.0;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';


my $ACCESS_REQUEST = 'access-request';
my $ROLE = 'role';
my $NAME = 'name';
my $CAPABILITY = 'capability';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = (
	$ACCESS_REQUEST, $ROLE, $NAME, $IFMAP_USER, $IFMAP_PASS);


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
	my @argsListRole = ($data->{$ACCESS_REQUEST}, $data->{$NAME}, $data->{$ROLE});

	my $connectionArgs = {
		"ifmap-user" => $data->{$IFMAP_USER},
		"ifmap-pass" => $data->{$IFMAP_PASS}
	};

	$result &= $self->call_ifmap_cli({
			'cli_tool' => "auth-as",
			'mode' => "delete",
			'args_list' => \@argsList,
			'connection_args' => $connectionArgs});
	$result &= $self->call_ifmap_cli({
			'cli_tool' => "role",
			'mode' => "delete",
			'args_list' => \@argsListRole,
			'connection_args' => $connectionArgs});

	if (defined $data->{$CAPABILITY}) {
		my @argsListCapability = ($data->{$ACCESS_REQUEST}, $data->{$CAPABILITY});
		$result &= $self->call_ifmap_cli({
				'cli_tool' => "cap",
				'mode' => "delete",
				'args_list' => \@argsListCapability,
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