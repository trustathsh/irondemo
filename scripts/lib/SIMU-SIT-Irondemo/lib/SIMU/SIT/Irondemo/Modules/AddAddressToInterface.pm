package SIMU::SIT::Irondemo::Modules::AddAddressToInterface;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'SIMU::SIT::Irondemo::Modules::AbstractInfrastructurePublishModule';

my $DEVICE = 'device';
my $INTERFACE = 'interface';
my $TYPE = 'type';
my $ADDRESS = 'address';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = ($DEVICE,$INTERFACE,$TYPE,$ADDRESS);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $device = $data->{$DEVICE};
	my $interface = $data->{$INTERFACE};
	my $type = $data->{$TYPE};
	my $address = $data->{$ADDRESS};

        my $ifmap_interface=$self->interface($interface);
        my $generic_address="";
        my $specific_address="";
        my $specific_device_address="";
        my $specific_device_address_ns="";
        my $specific_interface_address="";

        if (lc $type eq "ipv4")
        {
          $generic_address=$self->generic_ipv4_address($address);
          $specific_address=$self->specific_ipv4_address($address);
          $specific_device_address="meta:device-ip";
          $specific_device_address_ns="meta=\"http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2\"";
          $specific_interface_address="interface-ip";
        }
        elsif (lc $type eq "ipv6")
        {
          $generic_address=$self->generic_ipv6_address($address);
          $specific_address=$self->specific_ipv6_address($address);
          $specific_device_address="meta:device-ip";
          $specific_device_address_ns="meta=\"http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2\"";
          $specific_interface_address="interface-ip";
        }
        elsif (lc $type eq "mac")
        {
          $generic_address=$self->generic_mac_address($address);
          $specific_address=$self->specific_mac_address($address);
          $specific_device_address="io-meta:device-mac";
          $specific_device_address_ns="io-meta=\"http://sit.fraunhofer.de/2014/INFRASTRUCTURE-METADATA/1\"";
          $specific_interface_address="interface-mac";
        }
        else
        {
          croak "Unknown address type $type";
        }

	my $updates00 = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$device</name>
	</device>
        $ifmap_interface
	<metadata>
		<io-meta:device-interface ifmap-cardinality="singleValue" xmlns:io-meta="http://sit.fraunhofer.de/2014/INFRASTRUCTURE-METADATA/1"/>
	</metadata>
</update>
END_MESSAGE
	my $updates01a = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$device</name>
	</device>
        $generic_address
	<metadata>
		<io-meta:device-address ifmap-cardinality="singleValue" xmlns:io-meta="http://sit.fraunhofer.de/2014/INFRASTRUCTURE-METADATA/1"/>
	</metadata>
</update>
END_MESSAGE
	my $updates02a = <<"END_MESSAGE";
<update lifetime="forever">
        $ifmap_interface
        $generic_address
	<metadata>
		<io-meta:interface-address ifmap-cardinality="singleValue" xmlns:io-meta="http://sit.fraunhofer.de/2014/INFRASTRUCTURE-METADATA/1"/>
	</metadata>
</update>
END_MESSAGE
	my $updates01b = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$device</name>
	</device>
        $specific_address
	<metadata>
		<$specific_device_address ifmap-cardinality="singleValue" xmlns:$specific_device_address_ns/>
	</metadata>
</update>
END_MESSAGE
	my $updates02b = <<"END_MESSAGE";
<update lifetime="forever">
        $ifmap_interface
        $specific_address
	<metadata>
		<io-meta:$specific_interface_address ifmap-cardinality="singleValue" xmlns:io-meta="http://sit.fraunhofer.de/2014/INFRASTRUCTURE-METADATA/1"/>
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
	my $result02a = $self->send_soap_publish_request({
		'update_elements' => $updates02a,
		'connection_args' => $connectionArgs});
	my $result01b = $self->send_soap_publish_request({
		'update_elements' => $updates01b,
		'connection_args' => $connectionArgs});
	my $result02b = $self->send_soap_publish_request({
		'update_elements' => $updates02b,
		'connection_args' => $connectionArgs});

	return $result00 && $result01a && $result02a && $result01b && $result02b;
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
