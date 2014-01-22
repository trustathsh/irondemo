package TrustAtHsH::Irondemo::ModuleFactory;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);

use Data::Dumper;


sub loadModule {
	my $class = shift;
	my $moduleName = shift;
	my $moduleArgs = shift;

	eval "require $moduleName";

	my $moduleObject = $moduleName->new($moduleArgs);

	return $moduleObject;
}


1;
