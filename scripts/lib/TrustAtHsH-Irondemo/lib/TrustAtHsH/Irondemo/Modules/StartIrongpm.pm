package TrustAtHsH::Irondemo::Modules::StartIrongpm;

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
	my $irongpm;
	
	if ( $^O eq 'MSWin32' ) {
		$irongpm = File::Spec->catfile(
		  TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir(),
		  "irongpm/start.bat"
		);
	} else {
		$irongpm = File::Spec->catfile(
		  TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir(),
		  "irongpm/start.sh"
		);
	}
	
	return $self->start_process( $irongpm );
}

### INSTANCE METHOD ###
# Purpose     : Override
# Returns     : name of component
# Parameters  :
# Comments    : Override
sub _getIronName {
	 return "Irongpm";
}

1;
