package SIMU::SIT::Irondemo::Modules::CreateServerRack;

use 5.16.0;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapPublishModule';


my $ROOM = 'room';
my $RACK = 'rack';
my $DOORADDRESS = 'dooraddress';
my $KVMADDRESS = 'kvmaddress';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = ($ROOM,$RACK,$DOORADDRESS,$KVMADDRESS);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $room = $data->{$ROOM};
	my $rack = $data->{$RACK};
	my $dooraddress= $data->{$DOORADDRESS};
	my $kvmaddress= $data->{$KVMADDRESS};

	my $updates00 = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$room</name>
	</device>
	<device>
		<name>$rack</name>
	</device>
	<metadata>
		<meta:associated-with ifmap-cardinality="singleValue" xmlns:meta="http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2"/>
	</metadata>
</update>
END_MESSAGE
	my $updates01a = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$rack</name>
	</device>
	<device>
		<name>$rack.D1</name>
	</device>
	<metadata>
		<meta:associated-with ifmap-cardinality="singleValue" xmlns:meta="http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2"/>
	</metadata>
</update>
END_MESSAGE
	my $updates01b = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$rack</name>
	</device>
	<device>
		<name>$rack.K1</name>
	</device>
	<metadata>
		<meta:associated-with ifmap-cardinality="singleValue" xmlns:meta="http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2"/>
	</metadata>
</update>
END_MESSAGE
	my $updates02a = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$rack.D1</name>
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
		<name>$rack.K1</name>
	</device>
	<ip-address type="IPv4" value="$kvmaddress"/>
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
	my $result01a = $self->send_soap_publish_request({
		'update_elements' => $updates01a,
		'connection_args' => $connectionArgs});
	my $result01b = $self->send_soap_publish_request({
		'update_elements' => $updates01b,
		'connection_args' => $connectionArgs});
	my $result02a = $self->send_soap_publish_request({
		'update_elements' => $updates02a,
		'connection_args' => $connectionArgs});
	my $result02b = $self->send_soap_publish_request({
		'update_elements' => $updates02b,
		'connection_args' => $connectionArgs});

	return $result00 && $result01a && $result01b && $result02a && $result02b;
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
