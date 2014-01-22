package TrustAtHsH::Irondemo::Modules::DeviceConnects;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);

use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractModule';

sub execute {
	print "Binky \n";
}
1;