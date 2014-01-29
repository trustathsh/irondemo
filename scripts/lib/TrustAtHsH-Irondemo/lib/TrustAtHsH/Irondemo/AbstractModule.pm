package TrustAtHsH::Irondemo::AbstractModule;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use Log::Log4perl;

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

	#default values for if-map modules
	$self->{'data'}->{'ifmap-user'} = 'test';
	$self->{'data'}->{'ifmap-pass'} = 'test';
	$self->{'data'}->{'ifmap-url'} = 'https://localhost:8443';
	$self->{'data'}->{'ifmap-keystore-path'} = '/ifmapcli.jks';
	$self->{'data'}->{'ifmap-keystore-pass'} = 'ifmapcli';

	$self->_init($args);
	$self->_check_interface();


	return $self;
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