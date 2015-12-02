package TrustAtHsH::Irondemo::Modules::StartIronloggui;

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
	my $ironloggui;
	
	if ( $^O eq 'MSWin32' ) {
		$ironloggui = File::Spec->catfile(
		  TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir(),
		  "ironloggui/start.bat"
		);
	} else {
		$ironloggui = File::Spec->catfile(
		  TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir(),
		  "ironloggui/start.sh"
		);
	}
	
	return $self->start_process( $ironloggui );
}

### INSTANCE METHOD ###
# Purpose     : Override
# Returns     : name of component
# Parameters  :
# Comments    : Override
sub _getIronName {
	 return "Ironloggui";
}

1;