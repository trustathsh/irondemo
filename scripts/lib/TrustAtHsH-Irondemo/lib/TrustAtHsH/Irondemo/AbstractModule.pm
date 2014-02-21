package TrustAtHsH::Irondemo::AbstractModule;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use Log::Log4perl;
use File::Spec;

my @interface = qw[execute];

my $log = Log::Log4perl->get_logger();


### CONSTRUCTOR ###
# Purpose     : Constructor
# Returns     : Instance
# Parameters  : Hashref that is passed to sub classes' _init()
# Comments    : MUST NOT be overriden by sub classes
sub new {
	my $class = shift;
	my $args  = shift;

	my $self  = {};
	bless $self, $class;

	$self->_init($args);
	$self->_check_interface();

	return $self;
}

### INTERNAL_UTILITY ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub _bin_dir_for {
	my $self         = shift;
	my $project_id   = shift;
	my $scenario_dir = TrustAtHsH::Irondemo::Config->instance->get_current_scenario_dir;
	my $project_conf = TrustAtHsH::Irondemo::Config->instance->get_project_config( $project_id );
	
	return File::Spec->catdir( $scenario_dir, $project_conf->{executables_dir} );
}


### INTERNAL UTILITY ###
# Purpose     : Process constuctor parameters
# Returns     : Nothing
# Parameters  : Hashref, content to be defined by sub class
# Comments    :
sub _init {
	croak(caller() . ' is an abstract base class and must not be instantiated.');
}


### INTERNAL UTILITY ###
# Purpose     : Check if all required arguments are available
# Returns     : Nothing, throws exception if required argument is missing
# Parameters  : required and given argument lists
# Comments    :
sub _checkArgs {
	my $self = shift;
	my $required = shift;
	my $actual = shift;
	for my $req (@{$required}) {
		if (!defined $actual->{$req}) {
			my $error = "required argument '$req' not found";
			$log->error($error);
			croak($error);
		}
	}
}


### INTERNAL UTILITY ###
# Purpose     : Make sure sub classes implement all methods we expect
# Returns     : Nothing
# Parameters  : None
# Comments    :
sub _check_interface {
	my $self = shift;

	for my $method (@interface) {
		$self->can($method) or croak('Sub classes of ' . caller() . ' must implement' . $method . '.');
	}
}

1;