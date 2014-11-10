package SIMU::SIT::Irondemo::Modules::AddNetworkToAddress;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'SIMU::SIT::Irondemo::Modules::AbstractInfrastructurePublishModule';

my $INTERFACE = 'interface';
my $TYPE = 'type';
my $ADDRESS = 'address';
my $NETWORK = 'network';
my $SCOPE = 'scope';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = ($INTERFACE,$TYPE,$ADDRESS,$NETWORK,$SCOPE);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $interface = $data->{$INTERFACE};
	my $type = $data->{$TYPE};
	my $address = $data->{$ADDRESS};
	my $network = $data->{$NETWORK};
	my $scope = $data->{$SCOPE};

        my $ifmap_interface=$self->interface($interface);
        my $generic_address="";
        my $generic_network="";
        my $specific_address="";
        my $specific_network="";
        my $specific_address_network="";
        my $specific_interface_network="";
        my $specific_interface_address="";

        if (lc $type eq "ipv4")
        {
          $generic_address=$self->generic_ipv4_address($address);
          $generic_network=$self->generic_ipv4_network($network,$scope);
          $specific_address=$self->specific_ipv4_address($address);
          $specific_network=$self->specific_ipv4_network($network,$scope);
          $specific_address_network="ip-ipnet";
          $specific_interface_network="interface-ipnet";
          $specific_interface_address="interface-ip";
        }
        elsif (lc $type eq "ipv6")
        {
          $generic_address=$self->generic_ipv6_address($address);
          $generic_network=$self->generic_ipv6_network($network,$scope);
          $specific_address=$self->specific_ipv6_address($address);
          $specific_network=$self->specific_ipv6_network($network,$scope);
          $specific_address_network="ip-ipnet";
          $specific_interface_network="interface-ipnet";
          $specific_interface_address="interface-ip";
        }
        elsif ((lc $type eq "mac") || (lc $type eq "ethernet"))
        {
          $generic_address=$self->generic_mac_address($address);
          $generic_network=$self->generic_vlan($network,$scope);
          $specific_address=$self->specific_mac_address($address);
          $specific_network=$self->specific_vlan($network,$scope);
          $specific_address_network="mac-vlan";
          $specific_interface_network="interface-vlan";
          $specific_interface_address="interface-mac";
        }
        else
        {
          croak "Unknown address type $type";
        }

	my $updates00a = <<"END_MESSAGE";
<update lifetime="forever">
        $generic_address
        $generic_network
	<metadata>
		<io-meta:address-network ifmap-cardinality="singleValue" xmlns:io-meta="http://sit.fraunhofer.de/2014/INFRASTRUCTURE-METADATA/1"/>
	</metadata>
</update>
END_MESSAGE
	my $updates00b = <<"END_MESSAGE";
<update lifetime="forever">
        $specific_address
        $specific_network
	<metadata>
		<io-meta:$specific_address_network ifmap-cardinality="singleValue" xmlns:io-meta="http://sit.fraunhofer.de/2014/INFRASTRUCTURE-METADATA/1"/>
	</metadata>
</update>
END_MESSAGE
	my $updates01a = <<"END_MESSAGE";
<update lifetime="forever">
        $ifmap_interface
        $generic_network
	<metadata>
		<io-meta:interface-network ifmap-cardinality="singleValue" xmlns:io-meta="http://sit.fraunhofer.de/2014/INFRASTRUCTURE-METADATA/1"/>
	</metadata>
</update>
END_MESSAGE
	my $updates01b = <<"END_MESSAGE";
<update lifetime="forever">
        $ifmap_interface
        $specific_network
	<metadata>
		<io-meta:$specific_interface_network ifmap-cardinality="singleValue" xmlns:io-meta="http://sit.fraunhofer.de/2014/INFRASTRUCTURE-METADATA/1"/>
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

	my $result00a = $self->send_soap_publish_request({
		'update_elements' => $updates00a,
		'connection_args' => $connectionArgs});
	my $result00b = $self->send_soap_publish_request({
		'update_elements' => $updates00b,
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

	return $result00a && $result00b && $result01a && $result01b && $result02a && $result02b;
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
