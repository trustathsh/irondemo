package TrustAtHsH::Irondemo::Modules::IpTablesBlock;

use 5.006;
use strict;
use warnings;
use File::Spec;
use lib '../../../';
use TrustAtHsH::Irondemo::Config;
use parent 'TrustAtHsH::Irondemo::AbstractProcessStarterModule';

my $IP = 'ip-address';
my @REQUIRED_ARGS = ($IP);

### INSTANCE METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};
	my $command = "sudo iptables -I INPUT -s " . $data->{$IP} . " -j DROP";
	return $self->start_process( $command );
}

1;