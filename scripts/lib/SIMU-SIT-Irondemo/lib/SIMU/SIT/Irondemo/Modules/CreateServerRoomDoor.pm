package SIMU::SIT::Irondemo::Modules::CreateServerRoomDoor;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapPublishModule';


my $ROOM = 'room';
my $DOOR = 'door';
my $DOORADDRESS = 'dooraddress';
my $DOORLOCK = 'doorlock';
my $DOORLOCKADDRESS = 'doorlockaddress';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = ($ROOM,$DOOR,$DOORADDRESS,$DOORLOCK,$DOORLOCKADDRESS);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $room = $data->{$ROOM};
	my $door = $data->{$DOOR};
	my $dooraddress= $data->{$DOORADDRESS};
	my $doorlock = $data->{$DOORLOCK};
	my $doorlockaddress= $data->{$DOORLOCKADDRESS};

	my $updates00 = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$room</name>
	</device>
	<device>
		<name>$door</name>
	</device>
	<metadata>
		<meta:associated-with ifmap-cardinality="singleValue" xmlns:meta="http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2"/>
	</metadata>
</update>
END_MESSAGE
	my $updates01 = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$door</name>
	</device>
	<device>
		<name>$doorlock</name>
	</device>
	<metadata>
		<meta:associated-with ifmap-cardinality="singleValue" xmlns:meta="http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2"/>
	</metadata>
</update>
END_MESSAGE
	my $updates02a = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$door</name>
	</device>
	<ip-address type="IPv4" value="$dooraddress"/>
	<metadata>
		<meta:device-ip ifmap-cardinality="singleValue" xmlns:meta="http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2"/>
	</metadata>
</update>
END_MESSAGE
	my $updates02b = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$doorlock</name>
	</device>
	<ip-address type="IPv4" value="$doorlockaddress"/>
	<metadata>
		<meta:device-ip ifmap-cardinality="singleValue" xmlns:meta="http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2"/>
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
	my $result01 = $self->send_soap_publish_request({
		'update_elements' => $updates01,
		'connection_args' => $connectionArgs});
	my $result02a = $self->send_soap_publish_request({
		'update_elements' => $updates02a,
		'connection_args' => $connectionArgs});
	my $result02b = $self->send_soap_publish_request({
		'update_elements' => $updates02b,
		'connection_args' => $connectionArgs});

	return $result00 && $result01 && $result02a && $result02b;
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
