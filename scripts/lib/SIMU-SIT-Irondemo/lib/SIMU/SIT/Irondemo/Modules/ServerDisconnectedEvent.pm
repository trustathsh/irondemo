package SIMU::SIT::Irondemo::Modules::ServerDisconnectedEvent;

use 5.16.0;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use Data::UUID;
use DateTime;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapPublishModule';


my $KVM = 'kvm';
my $SERVER = 'server';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = ($KVM, $SERVER);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};
        my $uuidgen = new Data::UUID;

	my $kvm = $data->{$KVM};
	my $server = $data->{$SERVER};
        my $name = $uuidgen->to_string($uuidgen->create());
        my $dt = DateTime->now();
        my $now = $dt->strftime("%FT%T%z");

	my $updates00 = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$server</name>
	</device>
	<device>
		<name>$kvm</name>
	</device>
	<metadata>
		<meta:event ifmap-cardinality="multiValue" xmlns:meta="http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2">
                    <name>$name</name>
                    <discovered-time>$now</discovered-time>
                    <discoverer-id>$kvm</discoverer-id>
                    <confidence>100</confidence>
                    <type>other</type>
                    <other-type-definition>kvm switch disconnected</other-type-definition>
                    <information>KVM switch $kvm disconnected from server $server at $now</information>
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
