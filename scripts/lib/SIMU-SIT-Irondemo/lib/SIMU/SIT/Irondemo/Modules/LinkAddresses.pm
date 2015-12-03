package SIMU::SIT::Irondemo::Modules::LinkAddresses;

use 5.16.0;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'SIMU::SIT::Irondemo::Modules::AbstractInfrastructurePublishModule';

my $L2ADDRESS = 'l2address';
my $L3TYPE = 'l3type';
my $L3ADDRESS = 'l3address';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = ($L2ADDRESS,$L3TYPE,$L3ADDRESS);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $l2address = $data->{$L2ADDRESS};
	my $l3type = $data->{$L3TYPE};
	my $l3address = $data->{$L3ADDRESS};

        my $l2generic_address="";
        my $l3generic_address="";
        my $l2specific_address="";
        my $l3specific_address="";

        if (lc $l3type eq "ipv4")
        {
          $l3generic_address=$self->generic_ipv4_address($l3address);
          $l3specific_address=$self->specific_ipv4_address($l3address);
        }
        elsif (lc $l3type eq "ipv6")
        {
          $l3generic_address=$self->generic_ipv6_address($l3address);
          $l3specific_address=$self->specific_ipv6_address($l3address);
        }
        else
        {
          croak "Unknown layer3 address type $l3type";
        }

        $l2generic_address=$self->generic_mac_address($l2address);
        $l2specific_address=$self->specific_mac_address($l2address);

	my $updates00a = <<"END_MESSAGE";
<update lifetime="forever">
        $l3generic_address
        $l2generic_address
	<metadata>
		<io-meta:layer3address-layer2address ifmap-cardinality="multiValue" xmlns:io-meta="http://sit.fraunhofer.de/2014/INFRASTRUCTURE-METADATA/1"/>
	</metadata>
</update>
END_MESSAGE
	my $updates00b = <<"END_MESSAGE";
<update lifetime="forever">
        $l3specific_address
        $l2specific_address
	<metadata>
		<meta:ip-mac ifmap-cardinality="multiValue" xmlns:meta="http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2"/>
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

	return $result00a && $result00b;
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
