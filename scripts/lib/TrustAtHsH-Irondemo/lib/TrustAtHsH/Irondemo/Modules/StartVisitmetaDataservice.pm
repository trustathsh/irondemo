package TrustAtHsH::Irondemo::Modules::StartVisitmetaDataservice;

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
	my $visitmeta;
	
	if ( $^O eq 'MSWin32' ) {
		$visitmeta = File::Spec->catfile(
		  TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir(),
		  "visitmeta/start-dataservice.bat"
		);
	} else {
		$visitmeta = File::Spec->catfile(
		  TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir(),
		  "visitmeta/start-dataservice.sh"
		);
	}
	
	return $self->start_process( $visitmeta );
}

### INSTANCE METHOD ###
# Purpose     : Override
# Returns     : name of component
# Parameters  :
# Comments    :
sub _getIronName {
	 return "VisitMData";
}

1;