package TrustAtHsH::Irondemo::Modules::StartIrondetect;

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
	my $irondetect;
	
	if ( $^O eq 'MSWin32' ) {
		$irondetect = File::Spec->catfile(
		  TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir(),
		  "irondetect/start.bat"
		);
	} else {
		$irondetect = File::Spec->catfile(
		  TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir(),
		  "irondetect/start.sh"
		);
	}
	
	return $self->start_process( $irondetect );
}

### INSTANCE METHOD ###
# Purpose     : Override
# Returns     : name of component
# Parameters  :
# Comments    : Override
sub _getIronName {
	 return "Irondetect";
}

1;