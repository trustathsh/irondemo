package SIMU::SIT::Irondemo::Modules::DeviceConnectionDetected;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'SIMU::SIT::Irondemo::Modules::AbstractInfrastructurePublishModule';

my $DEVICE01 = 'device01';
my $INTERFACE01 = 'interface01';
my $DEVICE02 = 'device02';
my $INTERFACE02 = 'interface02';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = ($DEVICE01,$INTERFACE01,$DEVICE02,$INTERFACE02);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $device01 = $data->{$DEVICE01};
	my $interface01 = $data->{$INTERFACE01};
	my $device02 = $data->{$DEVICE02};
	my $interface02 = $data->{$INTERFACE02};
        my $ifmap_interface01=$self->interface($interface01);
        my $ifmap_interface02=$self->interface($interface02);

	my $updates00 = <<"END_MESSAGE";
<update lifetime="forever">
	<device>
		<name>$device01</name>
	</device>
	<device>
		<name>$device02</name>
	</device>
	<metadata>
		<io-meta:devices-connected ifmap-cardinality="singleValue" xmlns:io-meta="http://sit.fraunhofer.de/2014/INFRASTRUCTURE-METADATA/1"/>
	</metadata>
</update>
END_MESSAGE
	my $updates01 = <<"END_MESSAGE";
<update lifetime="forever">
        $ifmap_interface01
        $ifmap_interface02
	<metadata>
		<io-meta:interfaces-connected ifmap-cardinality="singleValue" xmlns:io-meta="http://sit.fraunhofer.de/2014/INFRASTRUCTURE-METADATA/1"/>
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

	return $result00 && $result01;
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
