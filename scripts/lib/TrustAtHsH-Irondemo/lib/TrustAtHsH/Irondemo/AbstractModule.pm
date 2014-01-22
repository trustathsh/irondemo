package TrustAtHsH::Irondemo::AbstractModule;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);

my @interface = qw[execute];

sub new {
	my $class = shift;
	my $args  = shift;

	my $self  = {};
	bless $self, $class;
	
	$self->init($args);
	$self->check_interface();

	return $self;
}

sub init {
	croak(caller() . ' is an abstract base class and must not be instantiated.');
}

sub check_interface {
	my $self = shift;

	for my $method (@interface) {
		$self->can($method) or croak('Sub classes of ' . caller() . ' must implement' . $method . '.');
	}
}

1;