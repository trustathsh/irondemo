package TrustAtHsH::Irondemo::Modules::Nothing;

use 5.16.0;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;

	# Nothing! 42!

	return 1;
}


### INSTANCE METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub get_required_arguments {
	my $self = shift;

	return ();
}


### INTERNAL UTILITY ###
# Purpose     :
# Returns     :
# Parameters  :
#
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;
}


1;