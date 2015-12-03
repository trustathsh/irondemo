package TrustAtHsH::Irondemo::Modules::Break;

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
	my $data = $self->{'data'};
	my $result = 1;
	
	my $MESSAGE = 'message';

	if ( $data->{$MESSAGE} ) {
		print "<<<<< " . $data->{$MESSAGE} . " ";
	}

	print ">>>> waiting, press ctrl+D to proceed\n";
	my $userinput = <STDIN>;

	return $result;
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
	
	while ( my ($key, $val) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}


1;