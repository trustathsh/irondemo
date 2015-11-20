package TrustAtHsH::Irondemo::Modules::StartVisitmetaGUI;

use 5.006;
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
	my $visitmeta;
	
	if ( $^O eq 'MSWin32' ) {
		$visitmeta = File::Spec->catfile(
		  TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir(),
		  "visitmeta/start-visualization.bat"
		);
	} else {
		$visitmeta = File::Spec->catfile(
		  TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir(),
		  "visitmeta/start-visualization.sh"
		);
	}
	
	return $self->start_process( $visitmeta );
}

### INSTANCE METHOD ###
# Purpose     : Override
# Returns     : name of component
# Parameters  :
# Comments    : Override
sub _getIronName {
	 return "VisitMGUI";
}

1;