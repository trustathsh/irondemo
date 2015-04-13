package TrustAtHsH::Irondemo::Modules::IpTablesClearRules;

use 5.006;
use strict;
use warnings;
use File::Spec;
use lib '../../../';
use TrustAtHsH::Irondemo::Config;
use parent 'TrustAtHsH::Irondemo::AbstractProcessStarterModule';

#my @REQUIRED_ARGS = ();

### INSTANCE METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub execute {
#	croak( "FUCK OFF" );
	my $self = shift;
	
	my $data = $self->{'data'};
	my $command = "sudo iptables --flush";
	
	return $self->start_process( $command );
}

1;