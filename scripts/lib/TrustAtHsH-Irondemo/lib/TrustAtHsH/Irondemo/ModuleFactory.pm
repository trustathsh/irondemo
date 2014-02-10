package TrustAtHsH::Irondemo::ModuleFactory;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use Try::Tiny;
use Log::Log4perl;


my $log = Log::Log4perl->get_logger();


sub loadModule {
	my $class = shift;
	my $moduleName = shift;
	my $moduleArgs = shift;

	$log->debug("Trying to load $moduleName ...");
	try {
		eval "require $moduleName";
	} catch {
		my $error = $_;
		$log->error($error);
		croak($error);
	};
	my $moduleObject = $moduleName->new($moduleArgs);

	return $moduleObject;
}


1;
