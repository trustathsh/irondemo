package SIMU::SIT::Irondemo::Modules::AddInterfaceToDevice;

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
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = ($DEVICE,$INTERFACE);


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
        my $ifmap_interface=$self->interface($interface);

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
