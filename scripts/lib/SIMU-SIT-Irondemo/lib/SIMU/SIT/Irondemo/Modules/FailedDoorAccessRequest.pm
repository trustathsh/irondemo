package SIMU::SIT::Irondemo::Modules::FailedDoorAccessRequest;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use Data::UUID;
use DateTime;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapPublishModule';


my $USER = 'user';
my $ACS = 'acs';
my $DOORLOCK = 'doorlock';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = ($USER, $ACS, $DOORLOCK);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};
        my $uuidgen = new Data::UUID;

	my $user = $data->{$USER};
	my $acs = $data->{$ACS};
        my $doorlock = $data->{$DOORLOCK};
        
        my $name = $uuidgen->to_string($uuidgen->create());
        my $dt = DateTime->now();
        my $now = $dt->strftime("%FT%T%z");

	my $updates00 = <<"END_MESSAGE";
<update lifetime="forever">
	<identity type="username" name="$user"/>
        <device>
          <name>$doorlock</name>
        </device>
	<metadata>
		<meta:event ifmap-cardinality="multiValue" xmlns:meta="http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2">
                    <name>$name</name>
                    <discovered-time>$now</discovered-time>
                    <discoverer-id>$acs</discoverer-id>
                    <confidence>100</confidence>
                    <type>other</type>
                    <other-type-definition>invalid door token</other-type-definition>
                    <information>Access control system $acs detected invalid token for user $user at door lock $doorlock at $now</information>
                </meta:event>
	</metadata>
</update>
END_MESSAGE

	my $connectionArgs = {
		"ifmap-user" => $data->{$IFMAP_USER},
		"ifmap-pass" => $data->{$IFMAP_PASS}
	};

	my $result00 = $self->send_soap_publish_request({
		'update_elements' => $updates00,
		'connection_args' => $connectionArgs});

	return $result00;
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
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ($key, $val) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

1;
