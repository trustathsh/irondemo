package TrustAtHsH::Irondemo::Modules::PublishUpdateExample;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapPublishModule';


my $PDP = 'pdp';
my $ACCESS_REQUEST = 'access-request';

my @REQUIRED_ARGS = ($PDP, $ACCESS_REQUEST);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $pdp = $data->{$PDP};
	my $ar = $data->{$ACCESS_REQUEST};

	my $updates = <<"END_MESSAGE";
<update lifetime="forever">
	<access-request name="$ar"/>
	<device>
		<name>$pdp</name>
	</device>
	<metadata>
		<meta:authenticated-by ifmap-cardinality="singleValue" xmlns:meta="http://www.trustedcomputinggroup.org/2010/IFMAP-METADATA/2"/>
	</metadata>
</update>
END_MESSAGE

	my $result = $self->send_soap_publish_request({
		'update_elements' => $updates,
		'connection_args' => {}});

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
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ($key, $val) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

1;