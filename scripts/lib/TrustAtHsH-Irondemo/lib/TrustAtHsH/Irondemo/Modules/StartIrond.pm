package TrustAtHsH::Irondemo::Modules::StartIrond;

use 5.16.0;
use strict;
use warnings;
use File::Spec;
use lib '../../../';
use TrustAtHsH::Irondemo::Config;
use parent 'TrustAtHsH::Irondemo::AbstractProcessStarterModule';

### INSTANCE METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub execute {
	my $self = shift;
	my $irond;
	
	if ( $^O eq 'MSWin32' ) {
		$irond = File::Spec->catfile(
		  TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir(),
		  "irond/start.bat"
		);
	} else {
		$irond = File::Spec->catfile(
		  TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir(),
		  "irond/start.sh"
		);
	}
	
	return $self->start_process( $irond );
}

### INSTANCE METHOD ###
# Purpose     : Override
# Returns     : name of component
# Parameters  :
# Comments    : Override
sub _getIronName {
	 return "Irond";
}

1;