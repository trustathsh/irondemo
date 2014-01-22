package TrustAtHsH::Irondemo::Executor;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);

sub new {
	my $class = shift;
	my $args  = shift;
	
	my $self  = {};
	bless $self, $class;
	
	return $self;
}

sub run {
	my $module = shift;
	
	$module->execute();
}

sub run_concurrent {
	croak('Concurrent execution of modules is not yet implemented. Very sadz and zory.');
}