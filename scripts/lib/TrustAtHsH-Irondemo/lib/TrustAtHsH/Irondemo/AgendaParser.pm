package TrustAtHsH::Irondemo::AgendaParser;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);

use Data::Dumper;

sub new {
	my $class = shift;
	my $args = shift;

	my $agenda_path = $args->{'path'};
	my $self = {};
	bless $self, $class;
	$self->{'data'} = [ {'Action' => 'MyAction',
			 'Args'   => {'Arg1' => 'Val1'},
			}];
	return $self;
}

sub getActions {
	my $self = shift;
	return $self->{'data'};
}

1;
